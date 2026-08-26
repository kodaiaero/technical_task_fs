import { initTRPC, type DataTransformer } from '@trpc/server';
import { parse, stringify } from 'devalue';

import type { Context } from './context/context';

export const transformer: DataTransformer = {
  deserialize: (object) => parse(object as string),
  serialize: (object) => stringify(object),
};

const t = initTRPC.context<Context>().create({ transformer });

export const router = t.router;
export const publicProcedure = t.procedure;
export const middleware = t.middleware;
