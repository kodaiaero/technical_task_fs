package articles

import (
	"context"
	"errors"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"

	api "github.com/sliide/articles-backend/pkg/articles/api"
)

type Service struct {
	api.UnimplementedArticleAPIServer

	repository *Repository
}

func NewService(repository *Repository) *Service {
	return &Service{repository: repository}
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
