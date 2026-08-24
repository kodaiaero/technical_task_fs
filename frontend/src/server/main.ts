import { fastify } from 'fastify';

import { env } from './env';
import { configureServer } from './server';

const server = fastify();

configureServer(server);

const [host = '0.0.0.0', port = '3010'] = env.SERVER_LISTEN_ADDR.split(':');

await server.listen({ host, port: Number.parseInt(port, 10) });

console.log(`bff listening on ${host}:${port}`);
