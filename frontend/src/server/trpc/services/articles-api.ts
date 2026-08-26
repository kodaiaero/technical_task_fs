import type { Transport } from '@connectrpc/connect';
import { createGrpcTransport, Http2SessionManager } from '@connectrpc/connect-node';

/**
 * One session manager per upstream, created once at startup. Sharing it lets
 * every request reuse the same HTTP/2 connection instead of opening a new one.
 */
export function createSessionManager(url: string): Http2SessionManager {
  return new Http2SessionManager(url);
}

export interface CreateArticlesApiTransportOptions {
  sessionManager: Http2SessionManager;
  url: string;
}

export function createArticlesApiTransport(
  options: CreateArticlesApiTransportOptions,
): Transport {
  return createGrpcTransport({
    baseUrl: options.url,
    sessionManager: options.sessionManager,
  });
}
