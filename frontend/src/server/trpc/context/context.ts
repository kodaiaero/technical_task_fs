import type { DescService } from '@bufbuild/protobuf';
import { createClient, type Client, type Transport } from '@connectrpc/connect';

import { env } from '@server/env';
import {
  createArticlesCoreTransport,
  createSessionManager,
} from '@server/trpc/services/articles-core';
import { middleware } from '../trpc';

/**
 * Injects a gRPC client for the given service into the tRPC context.
 *
 * @example
 *   const articlesProcedure = publicProcedure.use(
 *     articlesCoreClientMiddleware('articlesClient', ArticleAPI),
 *   );
 *
 *   articlesProcedure.query(async ({ ctx }) => {
 *     // ctx.articlesClient is a typed client for ArticleAPI.
 *   });
 */
export function articlesCoreClientMiddleware<
  TKey extends `${string}Client`,
  TService extends DescService,
>(key: TKey, service: TService) {
  return middleware<{ [K in TKey]: Client<TService> }>(async ({ ctx, next }) => {
    if (key in ctx) {
      throw new Error(`Context already has a property named ${key}.`);
    }

    return next({
      ctx: {
        [key]: createClient(service, ctx.transport),
      },
    });
  });
}

export interface Context {
  transport: Transport;
}

// Built once rather than per request, so the HTTP/2 connection is reused.
const sessionManager = createSessionManager(env.ARTICLES_CORE_URL);
const transport = createArticlesCoreTransport({
  sessionManager,
  url: env.ARTICLES_CORE_URL,
});

export function createContext(): Context {
  return { transport };
}
