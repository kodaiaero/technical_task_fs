import assert from 'node:assert/strict';
import { test } from 'node:test';
import { confirmStatus } from './status-confirmation';

const signal = () => new AbortController().signal;

test('acceptance alone is not confirmation: read until the requested state is observed', async () => {
  let reads = 0;
  const result = await confirmStatus(async () => ({ disabled: ++reads === 3 }), true, signal(), { intervalMs: 1 });
  assert.equal(result, 'observed');
  assert.equal(reads, 3);
});

test('a transient read error does not fail the change', async () => {
  let reads = 0;
  const result = await confirmStatus(async () => {
    if (++reads === 1) throw new Error('read unavailable');
    return { disabled: false };
  }, false, signal(), { intervalMs: 1 });
  assert.equal(result, 'observed');
  assert.equal(reads, 2);
});

test('the deadline aborts a slow read without starting overlapping reads', async () => {
  let reads = 0;
  const result = await confirmStatus((readSignal) => {
    reads++;
    return new Promise((_, reject) => {
      readSignal.addEventListener('abort', () => reject(new Error('aborted')), { once: true });
    });
  }, true, signal(), { intervalMs: 1, timeoutMs: 20 });
  assert.equal(result, 'unconfirmed');
  assert.equal(reads, 1);
});

test('leaving the page stops confirmation without interpreting it as failure', async () => {
  const controller = new AbortController();
  let reads = 0;
  const result = await confirmStatus(async () => {
    reads++;
    controller.abort();
    return { disabled: true };
  }, true, controller.signal);
  assert.equal(result, 'cancelled');
  assert.equal(reads, 1);
});
