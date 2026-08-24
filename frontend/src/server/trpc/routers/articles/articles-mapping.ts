import { timestampDate } from '@bufbuild/protobuf/wkt';
import { TRPCError } from '@trpc/server';

import type * as grpc from '@server/generated/grpc/article_pb';
import type { Article, ArticleDetails } from '@models/article/article';

export function mapGrpcArticle(article: grpc.Article): Article {
  return {
    id: article.id ?? '',
    title: article.title ?? '',
    summary: article.summary ?? '',
    imagePath: article.imagePath ?? '',
    author: article.author ?? '',
    source: article.source ?? '',
    category: article.category ?? '',
    publishedAt: article.publishedAt ? timestampDate(article.publishedAt) : new Date(0),
    disabled: article.disabled ?? false,
  };
}

export function mapGrpcArticleDetails(details: grpc.ArticleDetails): ArticleDetails {
  if (!details.article) {
    throw new TRPCError({
      code: 'INTERNAL_SERVER_ERROR',
      message: 'Article details are missing the article.',
    });
  }

  return {
    ...mapGrpcArticle(details.article),
    body: details.body ?? '',
  };
}
