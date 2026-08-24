import path from 'node:path';
import tailwindcss from '@tailwindcss/vite';
import { tanstackRouter } from '@tanstack/router-plugin/vite';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

export default defineConfig({
  root: import.meta.dirname,
  envDir: path.join(import.meta.dirname, '../../'),
  resolve: {
    alias: {
      '@client': path.join(import.meta.dirname, '.'),
      '@models': path.join(import.meta.dirname, '../models'),
    },
  },
  plugins: [
    tanstackRouter({
      target: 'react',
      routesDirectory: path.join(import.meta.dirname, './routes'),
      generatedRouteTree: path.join(import.meta.dirname, './routeTree.gen.ts'),
    }),
    react(),
    tailwindcss(),
  ],
  server: {
    host: '0.0.0.0',
    port: 5183,
    proxy: {
      '/_trpc': 'http://localhost:3010',
    },
  },
});
