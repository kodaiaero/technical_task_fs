// Package main stands in for article-ingestion-service: the service that owns
// article state in production and applies status changes published to SQS.
//
// It is NOT part of the service you are working on, and you should not need to
// change anything in this directory. It is here so the queue has something on
// the other end of it.
package main

import (
	"context"
	"database/sql"
	"errors"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	_ "github.com/jackc/pgx/v5/stdlib"
)

const (
	receiveWait      = 5 * time.Second
	receiveBatchSize = 10
	receiveBackoff   = 2 * time.Second
	handleTimeout    = 10 * time.Second
	startupTimeout   = 2 * time.Minute
	startupInterval  = 2 * time.Second
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	db, err := openDatabase(ctx, os.Getenv("DATABASE_URL"), logger)
	if err != nil {
		logger.Error("could not reach the database", "error", err)
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

			c.logger.Error("could not receive messages", "error", err)
			wait(ctx, receiveBackoff)

			continue
		}

		for _, message := range out.Messages {
			c.handle(ctx, message)
		}
	}
}

// handle processes one message. A message is only deleted once it has been
// applied: anything left undeleted becomes visible again when its visibility
// timeout expires, and lands on the dead letter queue after maxReceiveCount
// attempts.
func (c consumer) handle(ctx context.Context, message types.Message) {
	ctx, cancel := context.WithTimeout(ctx, handleTimeout)
	defer cancel()

	body := aws.ToString(message.Body)

	c.logger.Info("received message", "body", body)

	c.delete(ctx, message)
}

func (c consumer) delete(ctx context.Context, message types.Message) {
	_, err := c.client.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl:      aws.String(c.queueURL),
		ReceiptHandle: message.ReceiptHandle,
	})
	if err != nil {
		c.logger.Error("could not delete message", "error", err)
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
