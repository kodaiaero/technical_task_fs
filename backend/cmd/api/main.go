package main

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/sliide/articles-backend/internal/articles"
	"github.com/sliide/articles-backend/internal/database"
	"github.com/sliide/articles-backend/internal/queue"
	api "github.com/sliide/articles-backend/pkg/articles/api"
)

const (
	databaseURL = "postgres://developer:devpassword@postgres:5432/articles_db?sslmode=disable"
	listenAddr  = ":8081"
)

func main() {
	if err := run(); err != nil {
		slog.Error("API stopped", "error", err)
		os.Exit(1)
	}
}

func run() error {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	db, err := database.Open(databaseURL)
	if err != nil {
		return fmt.Errorf("open database: %w", err)
	}

	defer db.Close()

	if err := database.Migrate(db); err != nil {
		return fmt.Errorf("migrate database: %w", err)
	}

	publisher := queue.NewPublisher(os.Getenv("QUEUE_ENDPOINT"), os.Getenv("QUEUE_URL"))

	listener, err := net.Listen("tcp", listenAddr)
	if err != nil {
		return fmt.Errorf("listen on %s: %w", listenAddr, err)
	}

	server := grpc.NewServer()
	defer server.Stop()
	api.RegisterArticleAPIServer(server, articles.NewService(articles.NewRepository(db), publisher))
	reflection.Register(server)

	serveErrors := make(chan error, 1)
	go func() { serveErrors <- server.Serve(listener) }()

	fmt.Println("api listening on", listenAddr)
	fmt.Println("article status changes go to", publisher.QueueURL())

	select {
	case err := <-serveErrors:
		return err
	case <-ctx.Done():
	}
	stop()
	slog.Info("draining API requests", "timeout", shutdownTimeout)
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()
	shutdown(shutdownCtx, server)
	return nil
}

const shutdownTimeout = 7 * time.Second

func shutdown(ctx context.Context, server *grpc.Server) {
	done := make(chan struct{})
	go func() {
		server.GracefulStop()
		close(done)
	}()
	select {
	case <-done:
		slog.Info("API requests drained")
	case <-ctx.Done():
		slog.Warn("shutdown deadline reached; forcing RPC shutdown")
		server.Stop()
	}
}
