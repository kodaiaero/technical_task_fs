-- +goose Up
CREATE TABLE articles (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title        TEXT NOT NULL,
    summary      TEXT NOT NULL,
    body         TEXT NOT NULL,
    image_path   TEXT NOT NULL,
    author       TEXT NOT NULL,
    source       TEXT NOT NULL,
    category     TEXT NOT NULL,
    published_at TIMESTAMPTZ NOT NULL,
    disabled     BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX articles_published_at_idx ON articles (published_at DESC);

-- +goose Down
DROP TABLE articles;
