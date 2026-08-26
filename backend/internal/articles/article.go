package articles

import "time"

type Article struct {
	ID          string
	Title       string
	Summary     string
	ImagePath   string
	Author      string
	Source      string
	Category    string
	PublishedAt time.Time
	Disabled    bool
}

type ArticleDetails struct {
	Article Article
	Body    string
}
