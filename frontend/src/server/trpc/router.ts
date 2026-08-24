import { articlesRouter } from './routers/articles/articles-router';
import { router } from './trpc';

export const appRouter = router({
  articles: articlesRouter,
});

export type AppRouter = typeof appRouter;
