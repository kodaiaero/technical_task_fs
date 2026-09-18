import assert from 'node:assert/strict';
import { test } from 'node:test';
import { Code, ConnectError, createRouterTransport } from '@connectrpc/connect';
import { ArticleAPI, ArticleStatusAction } from '@server/generated/grpc/article_service_pb';
import { articlesRouter } from './articles-router';

const id = '9b7de9fe-b477-5418-b126-2cb5b8aa56a6';

test('the BFF maps both actions and returns acceptance, not article state', async () => {
  const actions: ArticleStatusAction[] = [];
  const caller = articlesRouter.createCaller({ transport: createRouterTransport((router) => {
    router.service(ArticleAPI, { requestArticleStatusChange(request) {
      assert.equal(request.id, id);
      actions.push(request.action);
      return {};
    } });
  }) });
  assert.deepEqual(await caller.requestArticleStatusChange({ id, action: 'disable' }), { accepted: true });
  assert.deepEqual(await caller.requestArticleStatusChange({ id, action: 'enable' }), { accepted: true });
  assert.deepEqual(actions, [ArticleStatusAction.DISABLE, ArticleStatusAction.ENABLE]);
  await assert.rejects(caller.requestArticleStatusChange({ id: 'invalid', action: 'disable' }), { code: 'BAD_REQUEST' });
  assert.equal(actions.length, 2);
});

test('an uncertain upstream outcome is not reported as acceptance or input rejection', async () => {
  const caller = articlesRouter.createCaller({ transport: createRouterTransport((router) => {
    router.service(ArticleAPI, { requestArticleStatusChange() {
      throw new ConnectError('request acceptance could not be confirmed', Code.Unavailable);
    } });
  }) });
  await assert.rejects(caller.requestArticleStatusChange({ id, action: 'disable' }), {
    code: 'INTERNAL_SERVER_ERROR', message: 'request acceptance could not be confirmed',
  });
});
