import './globals.css';

import { QueryClientProvider } from '@tanstack/react-query';
import { createRouter, RouterProvider } from '@tanstack/react-router';
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import { createTRPCOptionsProxy } from '@trpc/tanstack-react-query';
import { parse, stringify } from 'devalue';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { createQueryClient } from './lib/query-client';
import { routeTree } from './routeTree.gen';
import { TRPCProvider, type AppRouter } from './trpc';

const rootElement = document.getElementById('root');
if (!rootElement) {
  throw new Error('Root element not found');
}

const queryClient = createQueryClient();

const trpcClient = createTRPCClient<AppRouter>({
  links: [
    httpBatchLink({
      url: new URL('/_trpc', window.location.href).toString(),
      transformer: {
        deserialize: (object) => parse(object as string),
        serialize: (object) => stringify(object),
      },
    }),
  ],
});

const trpc = createTRPCOptionsProxy<AppRouter>({ client: trpcClient, queryClient });

const router = createRouter({
  routeTree,
  scrollRestoration: true,
  defaultPreload: 'intent',
  defaultPreloadStaleTime: 0,
  context: { trpc, queryClient },
});

createRoot(rootElement).render(
  <StrictMode>
    <TRPCProvider trpcClient={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </TRPCProvider>
  </StrictMode>,
);

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}
