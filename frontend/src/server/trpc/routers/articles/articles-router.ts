import { TRPCError } from '@trpc/server';
import { z } from 'zod';

import { ArticleAPI } from '@server/generated/grpc/article_service_pb';
import { articlesCoreClientMiddleware } from '@server/trpc/context/context';
import { publicProcedure, router } from '@server/trpc/trpc';
import { toArticlesTRPCError } from './articles-errors';
import { mapGrpcArticle, mapGrpcArticleDetails } from './articles-mapping';

const articlesProcedure = publicProcedure.use(
  articlesCoreClientMiddleware('articlesClient', ArticleAPI),
);

export const articlesRouter = router({
  getArticles: articlesProcedure.query(async ({ ctx }) => {
    try {
      const response = await ctx.articlesClient.getArticles({});

      return response.articles.map(mapGrpcArticle);
    } catch (error) {
      throw toArticlesTRPCError(error);
    }
  }),

  getArticleDetails: articlesProcedure
    // guid rather than uuid: Postgres accepts any 8-4-4-4-12 hex value, so
    // enforcing RFC 9562's version and variant bits here would reject ids the
    // database is perfectly happy with.
    .input(z.object({ id: z.guid() }))
    .query(async ({ ctx, input }) => {
      try {
        const response = await ctx.articlesClient.getArticleDetails({ id: input.id });

        if (!response.article) {
          throw new TRPCError({
            code: 'INTERNAL_SERVER_ERROR',
            message: 'articles-core returned no article.',
          });
        }

        return mapGrpcArticleDetails(response.article);
      } catch (error) {
        if (error instanceof TRPCError) {
          throw error;
        }

        throw toArticlesTRPCError(error);
      }
    }),
});
