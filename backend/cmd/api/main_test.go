package main

import (
	"context"
	"net"
	"testing"
	"time"

	api "github.com/sliide/articles-backend/pkg/articles/api"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/test/bufconn"
)

type blockingAPI struct {
	api.UnimplementedArticleAPIServer
	entered chan struct{}
	release chan struct{}
}

func (s *blockingAPI) GetArticles(ctx context.Context, _ *api.GetArticlesRequest) (*api.GetArticlesResponse, error) {
	close(s.entered)
	select {
	case <-s.release:
		return &api.GetArticlesResponse{}, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func TestShutdownHandlesInFlightRPC(t *testing.T) {
	for _, force := range []bool{false, true} {
		name := "drain"
		if force {
			name = "force after deadline"
		}
		t.Run(name, func(t *testing.T) {
			listener := bufconn.Listen(1024 * 1024)
			server := grpc.NewServer()
			service := &blockingAPI{entered: make(chan struct{}), release: make(chan struct{})}
			api.RegisterArticleAPIServer(server, service)
			go server.Serve(listener)
			t.Cleanup(server.Stop)
			conn, err := grpc.NewClient("passthrough:///test", grpc.WithTransportCredentials(insecure.NewCredentials()), grpc.WithContextDialer(func(context.Context, string) (net.Conn, error) { return listener.Dial() }))
			if err != nil {
				t.Fatal(err)
			}
			defer conn.Close()
			rpcCtx, cancelRPC := context.WithTimeout(context.Background(), 2*time.Second)
			defer cancelRPC()
			result := make(chan error, 1)
			go func() {
				_, err := api.NewArticleAPIClient(conn).GetArticles(rpcCtx, &api.GetArticlesRequest{})
				result <- err
			}()
			select {
			case <-service.entered:
			case <-rpcCtx.Done():
				t.Fatal("RPC did not start")
			}
			grace := time.Second
			if force {
				grace = 20 * time.Millisecond
			}
			ctx, cancel := context.WithTimeout(context.Background(), grace)
			defer cancel()
			stopped := make(chan struct{})
			go func() { shutdown(ctx, server); close(stopped) }()
			if !force {
				select {
				case <-stopped:
					t.Fatal("shutdown did not wait for in-flight RPC")
				case <-time.After(20 * time.Millisecond):
				}
				close(service.release)
			}
			select {
			case err := <-result:
				if force && err == nil {
					t.Fatal("forced shutdown unexpectedly completed the blocked RPC")
				}
				if !force && err != nil {
					t.Fatalf("graceful shutdown interrupted RPC: %v", err)
				}
			case <-rpcCtx.Done():
				t.Fatal("RPC did not finish")
			}
			select {
			case <-stopped:
			case <-rpcCtx.Done():
				t.Fatal("shutdown did not finish")
			}
		})
	}
}
