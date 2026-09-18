import { useQueryClient } from '@tanstack/react-query';
import { TRPCClientError } from '@trpc/client';
import { useEffect, useRef, useState } from 'react';

import { confirmStatus } from '@client/lib/status-confirmation';
import { useTRPC, useTRPCClient } from '@client/trpc';

type Action = 'disable' | 'enable';
type Operation = {
  action: Action;
  phase: 'sending' | 'waiting' | 'unknown' | 'checking' | 'retry';
};

export function ArticleStatusControl({ id, disabled }: { id: string; disabled: boolean }) {
  const trpc = useTRPC();
  const client = useTRPCClient();
  const cache = useQueryClient();
  const [operation, setOperation] = useState<Operation | null>(null);
  const [message, setMessage] = useState('');
  const active = useRef<AbortController | null>(null);
  useEffect(() => () => active.current?.abort(), []);

  const detailKey = trpc.articles.getArticleDetails.queryKey({ id });
  const listKey = trpc.articles.getArticles.queryKey();
  const buttonStyle = 'rounded bg-slate-900 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700 disabled:cursor-wait disabled:opacity-50';

  async function read(signal: AbortSignal) {
    // Use the network directly: a five-minute cached value cannot confirm a change.
    const article = await client.articles.getArticleDetails.query({ id }, { signal });
    signal.throwIfAborted();
    cache.setQueryData(detailKey, article);
    return article;
  }

  function observed() {
    setOperation(null);
    setMessage('Requested status observed.');
    void cache.invalidateQueries({ queryKey: listKey });
  }

  async function send(action: Action) {
    if (active.current) return;
    const controller = new AbortController();
    active.current = controller;
    setOperation({ action, phase: 'sending' });
    setMessage('Sending request…');
    try {
      // Prevent an older background detail read from overwriting confirmation reads.
      await cache.cancelQueries({ queryKey: detailKey });
      controller.signal.throwIfAborted();
      await client.articles.requestArticleStatusChange.mutate({ id, action }, {
        signal: AbortSignal.any([controller.signal, AbortSignal.timeout(8_000)]),
      });
      if (controller.signal.aborted) return;
      setOperation({ action, phase: 'waiting' });
      setMessage('Request accepted. Waiting for the update…');
      void cache.invalidateQueries({ queryKey: listKey, refetchType: 'none' });
      const result = await confirmStatus(read, action === 'disable', controller.signal);
      if (result === 'cancelled') return;
      if (result === 'observed') observed();
      else {
        setOperation({ action, phase: 'unknown' });
        setMessage('Update not confirmed yet. Processing may still be in progress.');
      }
    } catch (error) {
      if (controller.signal.aborted) return;
      const code = error instanceof TRPCClientError ? error.data?.code : undefined;
      if (code === 'BAD_REQUEST' || code === 'NOT_FOUND') {
        setOperation(null);
        setMessage('Request rejected. The article may be missing or the input invalid.');
      } else {
        setOperation({ action, phase: 'unknown' });
        setMessage("We couldn't confirm whether your request was accepted. Check status before retrying.");
      }
    } finally {
      active.current = null;
    }
  }

  async function check() {
    if (!operation || active.current) return;
    const { action } = operation;
    const controller = new AbortController();
    active.current = controller;
    setOperation({ action, phase: 'checking' });
    setMessage('Checking current status…');
    try {
      const article = await read(AbortSignal.any([controller.signal, AbortSignal.timeout(6_000)]));
      if (article.disabled === (action === 'disable')) observed();
      else {
        setOperation({ action, phase: 'retry' });
        setMessage('Requested status not observed. You can check again or resend the same request. The earlier request may still apply.');
      }
    } catch {
      if (controller.signal.aborted) return;
      setOperation({ action, phase: 'unknown' });
      setMessage("Couldn't read the current status. Check again; the change may still be processing.");
    } finally {
      active.current = null;
    }
  }

  const busy = operation && ['sending', 'waiting', 'checking'].includes(operation.phase);
  return (
    <section aria-label="Article status" className="mt-4 rounded-lg border border-slate-200 bg-slate-50 p-4">
      <div className="flex flex-wrap gap-2">
        {!operation || busy ? (
          <button type="button" className={buttonStyle} disabled={!!busy}
            onClick={() => void send(disabled ? 'enable' : 'disable')}>
            {disabled ? 'Enable article' : 'Disable article'}
          </button>
        ) : (
          <>
            <button type="button" className={buttonStyle} onClick={() => void check()}>Check status</button>
            {operation.phase === 'retry' && (
              <button type="button" className={buttonStyle} onClick={() => void send(operation.action)}>Retry request</button>
            )}
          </>
        )}
      </div>
      <p role="status" aria-live="polite" className="mt-2 text-sm text-slate-600">
        {message || 'Changes are applied asynchronously. The badge shows the last observed status.'}
      </p>
    </section>
  );
}
