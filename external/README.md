# External services

Nothing in this directory belongs to the application you are working on. It
stands in for infrastructure and services owned by other teams, so that the
whole stack can be started locally with one command.

**You should not need to change anything in here.**

## `elasticmq/`

[ElasticMQ](https://github.com/softwaremill/elasticmq) is an SQS compatible queue server, standing in for a managed queue. It runs as a container so you can
talk to it with the ordinary AWS SDK.

Queue: `article-status-changes`

| Setting | Value | Meaning |
| --- | --- | --- |
| `delay` | 5 seconds | A published message is invisible to the consumer for this long. |
| `defaultVisibilityTimeout` | 30 seconds | How long a received message is hidden from other consumers before it can be received again. |
| `deadLettersQueue` | after 3 receives | A message that is received 3 times without being deleted is moved to `article-status-changes-dead-letters`. |

The `delay` is the one setting worth changing while you work. You do not need to
edit this file to do it:

```bash
make queue-delay DELAY=30
```

That takes effect immediately without a restart, and reverts to the five seconds
configured here whenever the queue container restarts.

Useful commands:

```bash
make queue-attrs                      # queue depth and configuration
make queue-send MSG='{"hello":1}'     # publish a message by hand
make queue-purge                      # discard everything on the queue
make logs-consumer                    # what the consumer is doing
```

There is also a web view of the queues at http://localhost:9325.

## `cdn/`

Stands in for the CDN that serves article images. Here an nginx container serves
them from disk.

Base URL: http://localhost:8092

The `image_path` stored against an article is relative to that base. For example `/articles/technology-01.svg`. 
This is so the host is configuration rather than data. The frontend is given the base URL through the environment, which
is why changing the port here does not require reseeding the database.

```bash
curl -I http://localhost:8092/articles/technology-01.svg
```

## `consumer/`

A service owned by another team. It reads article status change events from the
queue and applies them.

Treat the rest of this section as their API documentation. It is what your service has to publish against.

### Message contract

The queue carries one event type. The message body is JSON:

```json
{
  "type": "article.status.changed",
  "article_id": "9b7de9fe-b477-5418-b126-2cb5b8aa56a6",
  "action": "disable",
  "trace_id": "any-correlation-id"
}
```

| Field | Required | Notes |
| --- | --- | --- |
| `type` | yes | Must be exactly `article.status.changed`. |
| `article_id` | yes | The article's UUID, in the usual hyphenated form. |
| `action` | yes | Either `disable` or `enable`. |
| `trace_id` | no | Echoed into our logs. Send one and you can follow a single change across both services. |

### What happens to your message

| Outcome | What we do |
| --- | --- |
| Applied successfully | Deleted from the queue. Logged at `INFO` with your `trace_id`. |
| No article with that id | Logged at `WARN` and discarded. Retrying cannot make a missing article appear. |
| Not valid JSON, or does not match the contract above | Logged at `ERROR` and **left on the queue**. It becomes visible again after 30 seconds and is retried up to three times, then moved to `article-status-changes-dead-letters`. |
| Our database is briefly unavailable | Same as above: left on the queue and retried. |

So a message we cannot understand does not vanish silently, it leaves a trail in our logs and ends up on the dead letter queue. 
`make logs-consumer` is the fastest way to find out why nothing happened.

### Delivery guarantees

**At least once.** The same message can be delivered more than once, so applying
a status change is idempotent on our side. Setting the same status twice has no
additional effect. Your side should assume a publish may be seen twice.

**Not ordered.** This is a standard queue, not a FIFO one. Two changes to the
same article published a moment apart may be applied in either order. If that
matters to you, it is worth thinking about what you send rather than relying on
the queue.

**Delayed.** Messages are held for five seconds before we can see them, so
expect at least that long between publishing and the change landing. The delay
is configured in `elasticmq/elasticmq.conf` and is the one setting here worth
changing while you work.

### Debugging

```bash
make logs-consumer      # what we did with your message, and why
make queue-attrs        # how many messages are waiting
make queue-delay DELAY=30  # hold messages for longer before we see them
make queue-purge        # throw away everything currently queued

# publish a message by hand, without going through your API
make queue-send MSG='{"type":"article.status.changed","article_id":"...","action":"disable"}'

# how many messages have been given up on
curl -s -X POST http://localhost:9324/000000000000/article-status-changes-dead-letters \
  -d Action=GetQueueAttributes -d AttributeName.1=ApproximateNumberOfMessages \
  -d Version=2012-11-05
```
