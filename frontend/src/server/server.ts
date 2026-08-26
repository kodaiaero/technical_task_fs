import { fastifyTRPCPlugin } from '@trpc/server/adapters/fastify';
import type { FastifyInstance } from 'fastify';

import { createContext } from './trpc/context/context';
import { appRouter } from './trpc/router';

export function configureServer(server: FastifyInstance) {
  server.register(fastifyTRPCPlugin, {
    prefix: '/_trpc',
    trpcOptions: {
      router: appRouter,
      createContext,
    },
  });
}
