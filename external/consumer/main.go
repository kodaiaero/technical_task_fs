// Package main stands in for a service owned by another team, which consumes
// article status change events from the queue and applies them.
//
// It is NOT part of the application you are working on, and you should not need
// to change anything in this directory. It is here so the queue has something
// on the other end of it.
package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"regexp"
	"syscall"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	_ "github.com/jackc/pgx/v5/stdlib"
)

// The published contract for this queue. See ../README.md.
const (
	eventTypeArticleStatusChanged = "article.status.changed"

	actionDisable = "disable"
	actionEnable  = "enable"
)

var articleIDPattern = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)

// articleStatusChangedEvent is the only message this service understands.
type articleStatusChangedEvent struct {
	Type      string `json:"type"`
	ArticleID string `json:"article_id"`
	Action    string `json:"action"`
	TraceID   string `json:"trace_id"`
}

func (e articleStatusChangedEvent) validate() error {
	if e.Type != eventTypeArticleStatusChanged {
		return fmt.Errorf("type is %q, expected %q", e.Type, eventTypeArticleStatusChanged)
	}

	if !articleIDPattern.MatchString(e.ArticleID) {
		return fmt.Errorf("article_id %q is not a UUID", e.ArticleID)
	}

	if e.Action != actionDisable && e.Action != actionEnable {
		return fmt.Errorf("action is %q, expected %q or %q", e.Action, actionDisable, actionEnable)
	}

	return nil
}

const (
	receiveWait      = 5 * time.Second
	receiveBatchSize = 10
	receiveBackoff   = 2 * time.Second
	handleTimeout    = 10 * time.Second
	startupTimeout   = 2 * time.Minute
	startupInterval  = 2 * time.Second

	logKeyError = "error"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := openDatabase(ctx, os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		logger.Error("could not reach the database", logKeyError, err)
		os.Exit(1)
	}
	defer db.Close()

	queueURL := os.Getenv("QUEUE_URL")
	client := newQueueClient(os.Getenv("QUEUE_ENDPOINT"))

	logger.Info("consuming article status changes", "queue_url", queueURL)

	consume(ctx, consumer{client: client, queueURL: queueURL, db: db, logger: logger})

	logger.Info("shutdown complete")
}

type consumer struct {
	client   *sqs.Client
	queueURL string
	db       *sql.DB
	logger   *slog.Logger
}

func consume(ctx context.Context, c consumer) {
	for ctx.Err() == nil {
		out, err := c.client.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(c.queueURL),
			MaxNumberOfMessages: receiveBatchSize,
			WaitTimeSeconds:     int32(receiveWait.Seconds()),
		})
		if err != nil {
			if ctx.Err() != nil {
				return
			}

			c.logger.ErrorContext(ctx, "could not receive messages", logKeyError, err)
			wait(ctx, receiveBackoff)

			continue
		}

		for _, message := range out.Messages {
			c.handle(ctx, message)
		}
	}
}

// handle processes one message. A message is only deleted once it has been
// dealt with: anything left undeleted becomes visible again when its visibility
// timeout expires, and lands on the dead letter queue after maxReceiveCount
// attempts. That is deliberate - a message we cannot understand leaves a trail
// rather than disappearing.
func (c consumer) handle(ctx context.Context, message types.Message) {
	ctx, cancel := context.WithTimeout(ctx, handleTimeout)
	defer cancel()

	body := aws.ToString(message.Body)

	var event articleStatusChangedEvent
	if err := json.Unmarshal([]byte(body), &event); err != nil {
		c.logger.ErrorContext(ctx, "message is not valid JSON, leaving it for redelivery",
			logKeyError, err, "body", body)

		return
	}

	if err := event.validate(); err != nil {
		c.logger.ErrorContext(ctx, "message does not match the contract, leaving it for redelivery",
			logKeyError, err, "body", body)

		return
	}

	logger := c.logger.With(
		"article_id", event.ArticleID,
		"action", event.Action,
		"trace_id", event.TraceID,
	)

	applied, err := c.apply(ctx, event)
	if err != nil {
		// Could be transient, so leave the message for redelivery.
		logger.ErrorContext(ctx, "could not apply the status change", logKeyError, err)

		return
	}

	if !applied {
		// Retrying cannot make a missing article appear, so drop it rather than
		// filling the dead letter queue with messages that can never succeed.
		logger.WarnContext(ctx, "no such article, discarding the message")
		c.delete(ctx, message)

		return
	}

	logger.InfoContext(ctx, "applied article status change")
	c.delete(ctx, message)
}

// apply writes the new status. Reports false when no such article exists.
//
// Setting the same status twice is harmless, which matters because the queue
// guarantees at-least-once delivery: the same message can legitimately arrive
// more than once.
func (c consumer) apply(ctx context.Context, event articleStatusChangedEvent) (bool, error) {
	result, err := c.db.ExecContext(ctx,
		"UPDATE articles SET disabled = $1 WHERE id = $2",
		event.Action == actionDisable,
		event.ArticleID,
	)
	if err != nil {
		return false, err
	}

	affected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return affected > 0, nil
}

func (c consumer) delete(ctx context.Context, message types.Message) {
	_, err := c.client.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl:      aws.String(c.queueURL),
		ReceiptHandle: message.ReceiptHandle,
	})
	if err != nil {
		c.logger.ErrorContext(ctx, "could not delete message", logKeyError, err)
	}
}

func newQueueClient(endpoint string) *sqs.Client {
	return sqs.NewFromConfig(aws.Config{
		Region:       "eu-west-1",
		Credentials:  credentials.NewStaticCredentialsProvider("local", "local", ""),
		BaseEndpoint: aws.String(endpoint),
	})
}

// openDatabase waits for both the database and the articles table, so the
// consumer tolerates being started before the API has run its migrations.
func openDatabase(ctx context.Context, databaseURL string, logger *slog.Logger) (*sql.DB, error) {
	db, err := sql.Open("pgx", databaseURL)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(4)
	db.SetMaxIdleConns(2)
	db.SetConnMaxLifetime(30 * time.Minute)

	deadline := time.Now().Add(startupTimeout)

	for {
		var ready bool
		err = db.QueryRowContext(ctx, "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'articles')").Scan(&ready)

		switch {
		case err == nil && ready:
			return db, nil
		case ctx.Err() != nil:
			return nil, ctx.Err()
		case time.Now().After(deadline):
			if err == nil {
				err = errors.New("the articles table does not exist")
			}

			return nil, err
		}

		logger.Info("waiting for the articles table")
		wait(ctx, startupInterval)
	}
}

func wait(ctx context.Context, d time.Duration) {
	timer := time.NewTimer(d)
	defer timer.Stop()

	select {
	case <-ctx.Done():
	case <-timer.C:
	}
}
