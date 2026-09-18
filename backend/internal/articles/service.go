package articles

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"regexp"
	"time"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"

	api "github.com/sliide/articles-backend/pkg/articles/api"
)

type articleRepository interface {
	List() ([]Article, error)
	Get(string) (ArticleDetails, error)
	Exists(context.Context, string) (bool, error)
}

type statusPublisher interface {
	Publish(context.Context, string) error
}

type Service struct {
	api.UnimplementedArticleAPIServer

	repository articleRepository
	publisher  statusPublisher
}

func NewService(repository articleRepository, publisher statusPublisher) *Service {
	return &Service{repository: repository, publisher: publisher}
}

var articleIDPattern = regexp.MustCompile(`^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$`)

func (s *Service) RequestArticleStatusChange(ctx context.Context, req *api.RequestArticleStatusChangeRequest) (*api.RequestArticleStatusChangeResponse, error) {
	if !articleIDPattern.MatchString(req.GetId()) {
		return nil, status.Error(codes.InvalidArgument, "article id must be a hyphenated UUID")
	}
	var action string
	switch req.GetAction() {
	case api.ArticleStatusAction_ARTICLE_STATUS_ACTION_DISABLE:
		action = "disable"
	case api.ArticleStatusAction_ARTICLE_STATUS_ACTION_ENABLE:
		action = "enable"
	default:
		return nil, status.Error(codes.InvalidArgument, "action must be disable or enable")
	}

	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	exists, err := s.repository.Exists(ctx, req.GetId())
	if err != nil {
		slog.ErrorContext(ctx, "could not check article existence", "article_id", req.GetId(), "error", err)
		return nil, status.Error(codes.Internal, "could not verify article; request was not published")
	}
	if !exists {
		return nil, status.Error(codes.NotFound, "article not found")
	}

	body, err := json.Marshal(struct {
		Type      string `json:"type"`
		ArticleID string `json:"article_id"`
		Action    string `json:"action"`
	}{Type: "article.status.changed", ArticleID: req.GetId(), Action: action})
	if err != nil {
		return nil, status.Error(codes.Internal, "could not prepare status change request")
	}
	if err := s.publisher.Publish(ctx, string(body)); err != nil {
		slog.ErrorContext(ctx, "article status request acceptance unconfirmed", "article_id", req.GetId(), "action", action, "error", err)
		return nil, status.Error(codes.Unavailable, "request acceptance could not be confirmed; check article status before retrying")
	}
	return &api.RequestArticleStatusChangeResponse{}, nil
}

func (s *Service) GetArticles(_ context.Context, _ *api.GetArticlesRequest) (*api.GetArticlesResponse, error) {
	found, err := s.repository.List()
	if err != nil {
		return nil, err
	}

	response := &api.GetArticlesResponse{Articles: make([]*api.Article, 0, len(found))}
	for _, article := range found {
		response.Articles = append(response.Articles, toProtoArticle(article))
	}

	return response, nil
}

func (s *Service) GetArticleDetails(_ context.Context, req *api.GetArticleDetailsRequest) (*api.GetArticleDetailsResponse, error) {
	details, err := s.repository.Get(req.GetId())
	if errors.Is(err, ErrNotFound) {
		return nil, status.Error(codes.NotFound, "article not found")
	}
	if err != nil {
		return nil, err
	}

	return &api.GetArticleDetailsResponse{
		Article: &api.ArticleDetails{
			Article: toProtoArticle(details.Article),
			Body:    proto.String(details.Body),
		},
	}, nil
}

func toProtoArticle(article Article) *api.Article {
	return &api.Article{
		Id:          proto.String(article.ID),
		Title:       proto.String(article.Title),
		Summary:     proto.String(article.Summary),
		ImagePath:   proto.String(article.ImagePath),
		Author:      proto.String(article.Author),
		Source:      proto.String(article.Source),
		Category:    proto.String(article.Category),
		PublishedAt: timestamppb.New(article.PublishedAt),
		Disabled:    proto.Bool(article.Disabled),
	}
}
