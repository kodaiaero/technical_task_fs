package articles

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"testing"
	"time"

	api "github.com/sliide/articles-backend/pkg/articles/api"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
)

const testArticleID = "9b7de9fe-b477-5418-b126-2cb5b8aa56a6"

type stubRepository struct {
	exists bool
	err    error
	calls  int
	ctx    context.Context
	id     string
}

func (*stubRepository) List() ([]Article, error)           { panic("unexpected List") }
func (*stubRepository) Get(string) (ArticleDetails, error) { panic("unexpected Get") }
func (r *stubRepository) Exists(ctx context.Context, id string) (bool, error) {
	r.calls++
	r.ctx, r.id = ctx, id
	return r.exists, r.err
}

type stubPublisher struct {
	calls int
	body  string
	ctx   context.Context
	err   error
}

func (p *stubPublisher) Publish(ctx context.Context, body string) error {
	p.calls++
	p.ctx, p.body = ctx, body
	return p.err
}

func TestRequestArticleStatusChangePublishesContract(t *testing.T) {
	for _, tt := range []struct {
		name   string
		action api.ArticleStatusAction
	}{
		{"disable", api.ArticleStatusAction_ARTICLE_STATUS_ACTION_DISABLE},
		{"enable", api.ArticleStatusAction_ARTICLE_STATUS_ACTION_ENABLE},
	} {
		t.Run(tt.name, func(t *testing.T) {
			repo := &stubRepository{exists: true}
			publisher := &stubPublisher{}
			ctx, cancel := context.WithTimeout(context.Background(), time.Second)
			defer cancel()
			response, err := NewService(repo, publisher).RequestArticleStatusChange(ctx, &api.RequestArticleStatusChangeRequest{
				Id: proto.String(testArticleID), Action: tt.action.Enum(),
			})
			if err != nil || response == nil {
				t.Fatalf("response=%v error=%v", response, err)
			}
			if repo.calls != 1 || repo.id != testArticleID || publisher.calls != 1 {
				t.Fatalf("existence calls=%d id=%s publish calls=%d", repo.calls, repo.id, publisher.calls)
			}
			var body map[string]string
			if err := json.Unmarshal([]byte(publisher.body), &body); err != nil {
				t.Fatal(err)
			}
			if len(body) != 3 || body["type"] != "article.status.changed" || body["article_id"] != testArticleID || body["action"] != tt.name {
				t.Fatalf("unexpected contract: %v", body)
			}
			deadline, ok := publisher.ctx.Deadline()
			wantDeadline, _ := ctx.Deadline()
			if !ok || !deadline.Equal(wantDeadline) || repo.ctx != publisher.ctx {
				t.Fatal("caller deadline/context was not propagated")
			}
			if proto.Size(response) != 0 {
				t.Fatal("acceptance must not contain an applied article state")
			}
		})
	}
}

func TestRequestArticleStatusChangeRejectsBeforePublishing(t *testing.T) {
	valid := func() *api.RequestArticleStatusChangeRequest {
		return &api.RequestArticleStatusChangeRequest{Id: proto.String(testArticleID), Action: api.ArticleStatusAction_ARTICLE_STATUS_ACTION_DISABLE.Enum()}
	}
	for _, tt := range []struct {
		name      string
		request   *api.RequestArticleStatusChangeRequest
		exists    bool
		repoError error
		code      codes.Code
		reads     int
	}{
		{"nil request", nil, true, nil, codes.InvalidArgument, 0},
		{"invalid id", &api.RequestArticleStatusChangeRequest{Id: proto.String("not-a-uuid"), Action: api.ArticleStatusAction_ARTICLE_STATUS_ACTION_DISABLE.Enum()}, true, nil, codes.InvalidArgument, 0},
		{"missing action", &api.RequestArticleStatusChangeRequest{Id: proto.String(testArticleID)}, true, nil, codes.InvalidArgument, 0},
		{"unknown action", &api.RequestArticleStatusChangeRequest{Id: proto.String(testArticleID), Action: api.ArticleStatusAction(99).Enum()}, true, nil, codes.InvalidArgument, 0},
		{"missing article", valid(), false, nil, codes.NotFound, 1},
		{"database failure", valid(), false, errors.New("private database detail"), codes.Internal, 1},
	} {
		t.Run(tt.name, func(t *testing.T) {
			repo := &stubRepository{exists: tt.exists, err: tt.repoError}
			publisher := &stubPublisher{}
			response, err := NewService(repo, publisher).RequestArticleStatusChange(context.Background(), tt.request)
			if response != nil || status.Code(err) != tt.code {
				t.Fatalf("response=%v error=%v", response, err)
			}
			if publisher.calls != 0 || repo.calls != tt.reads {
				t.Fatalf("reads=%d publishes=%d", repo.calls, publisher.calls)
			}
			if strings.Contains(err.Error(), "private database detail") {
				t.Fatal("RPC exposed database details")
			}
		})
	}
}

func TestRequestArticleStatusChangePublishFailureIsUnconfirmed(t *testing.T) {
	repo := &stubRepository{exists: true}
	publisher := &stubPublisher{err: errors.New("private queue detail")}
	started := time.Now()
	response, err := NewService(repo, publisher).RequestArticleStatusChange(context.Background(), &api.RequestArticleStatusChangeRequest{
		Id: proto.String(testArticleID), Action: api.ArticleStatusAction_ARTICLE_STATUS_ACTION_DISABLE.Enum(),
	})
	if response != nil || status.Code(err) != codes.Unavailable || publisher.calls != 1 {
		t.Fatalf("response=%v error=%v publishes=%d", response, err, publisher.calls)
	}
	if !strings.Contains(err.Error(), "could not be confirmed") || strings.Contains(err.Error(), "private queue detail") {
		t.Fatalf("unexpected error: %v", err)
	}
	deadline, ok := publisher.ctx.Deadline()
	if !ok || deadline.Before(started) || deadline.After(time.Now().Add(5*time.Second)) {
		t.Fatal("mutation must have a bounded deadline")
	}
}
