export interface Article {
  id: string;
  title: string;
  summary: string;

  /** Relative to the image CDN base URL, e.g. `/articles/technology-01.svg`. */
  imagePath: string;

  author: string;
  source: string;
  category: string;
  publishedAt: Date;

  /**
   * Whether the article is hidden from users. Applied asynchronously, so this
   * is the last state written rather than necessarily the most recently
   * requested one.
   */
  disabled: boolean;
}

export interface ArticleDetails extends Article {
  body: string;
}
