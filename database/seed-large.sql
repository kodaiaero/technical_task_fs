-- Bulk sample data, for checking how the application behaves with a realistic
-- number of articles rather than the forty the migrations seed.
--
-- Run with: make seed-large
--
-- Safe to run more than once: it clears its own rows first, and leaves the
-- forty seeded articles alone.

DELETE FROM articles WHERE title ~ ' \([0-9]+\)$';

INSERT INTO articles (title, summary, body, image_path, author, source, category, published_at, disabled)
SELECT
    seed.title || ' (' || generated.n || ')',
    seed.summary,
    seed.body,
    seed.image_path,
    seed.author,
    seed.source,
    seed.category,
    NOW() - (generated.n || ' hours')::interval,
    generated.n % 17 = 0
FROM generate_series(1, 2000) AS generated(n)
CROSS JOIN LATERAL (
    SELECT title, summary, body, image_path, author, source, category
    FROM articles
    WHERE title !~ ' \([0-9]+\)$'
    ORDER BY id
    LIMIT 1 OFFSET (generated.n % 40)
) AS seed;

SELECT count(*) AS total_articles, count(*) FILTER (WHERE disabled) AS disabled_articles FROM articles;
