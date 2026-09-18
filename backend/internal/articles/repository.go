package articles

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
)

var ErrNotFound = errors.New("article not found")

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) Exists(ctx context.Context, id string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, "SELECT EXISTS (SELECT 1 FROM articles WHERE id = $1)", id).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("check article existence: %w", err)
	}
	return exists, nil
}

const listQuery = `
	SELECT id, title, summary, image_path, author, source, category, published_at, disabled
	FROM articles
	ORDER BY published_at DESC, id`

// List returns every article, newest first.
func (r *Repository) List() (articles []Article, err error) {
	rows, err := r.db.Query(listQuery)
	if err != nil {
		return nil, fmt.Errorf("query articles: %w", err)
	}
	defer rows.Close()

	for rows.Next() {
		var article Article
		if err := rows.Scan(
			&article.ID,
			&article.Title,
			&article.Summary,
			&article.ImagePath,
			&article.Author,
			&article.Source,
			&article.Category,
			&article.PublishedAt,
			&article.Disabled,
		); err != nil {
			return nil, fmt.Errorf("scan article: %w", err)
		}

		articles = append(articles, article)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate articles: %w", err)
	}

	return articles, nil
}

const getQuery = `
	SELECT id, title, summary, image_path, author, source, category, published_at, disabled, body
	FROM articles
	WHERE id = $1`

func (r *Repository) Get(id string) (ArticleDetails, error) {
	var details ArticleDetails

	err := r.db.QueryRow(getQuery, id).Scan(
		&details.Article.ID,
		&details.Article.Title,
		&details.Article.Summary,
		&details.Article.ImagePath,
		&details.Article.Author,
		&details.Article.Source,
		&details.Article.Category,
		&details.Article.PublishedAt,
		&details.Article.Disabled,
		&details.Body,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return ArticleDetails{}, ErrNotFound
	}
	if err != nil {
		return ArticleDetails{}, fmt.Errorf("query article: %w", err)
	}

	return details, nil
}
