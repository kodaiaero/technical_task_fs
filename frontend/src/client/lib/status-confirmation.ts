// A read can confirm the current state, not which queued request produced it.
export async function confirmStatus(
  read: (signal: AbortSignal) => Promise<{ disabled: boolean }>,
  disabled: boolean,
  signal: AbortSignal,
  { timeoutMs = 30_000, intervalMs = 2_000 } = {},
): Promise<'observed' | 'unconfirmed' | 'cancelled'> {
  const deadline = new AbortController();
  const timer = setTimeout(() => deadline.abort(), timeoutMs);
  const boundedSignal = AbortSignal.any([signal, deadline.signal]);
  try {
    while (!boundedSignal.aborted) {
      try {
        const article = await read(boundedSignal);
        if (!boundedSignal.aborted && article.disabled === disabled) return 'observed';
      } catch {
        // Read failure says nothing about whether the queued change was applied.
      }
      if (boundedSignal.aborted) break;
      await new Promise<void>((resolve) => {
        const finish = () => {
          clearTimeout(delay);
          boundedSignal.removeEventListener('abort', finish);
          resolve();
        };
        const delay = setTimeout(finish, intervalMs);
        boundedSignal.addEventListener('abort', finish, { once: true });
      });
    }
    return signal.aborted ? 'cancelled' : 'unconfirmed';
  } finally {
    clearTimeout(timer);
  }
}
