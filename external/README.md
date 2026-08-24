# External services

Nothing in this directory belongs to the application you are working on. It
stands in for infrastructure and services owned by other teams, so that the
whole stack can be started locally with one command.

**You should not need to change anything in here.**

## `elasticmq/`

[ElasticMQ](https://github.com/softwaremill/elasticmq) is an SQS-compatible
queue server. In production this is a real AWS SQS queue managed by the platform
team; locally it runs as a container so you can talk to it with the ordinary AWS
SDK.

Queue: `article-status-changes`

| Setting | Value | Meaning |
| --- | --- | --- |
| `delay` | 5 seconds | A published message is invisible to the consumer for this long. |
| `defaultVisibilityTimeout` | 30 seconds | How long a received message is hidden from other consumers before it can be received again. |
| `deadLettersQueue` | after 3 receives | A message that is received 3 times without being deleted is moved to `article-status-changes-dead-letters`. |

The `delay` is the one setting worth changing while you work - turn it up to
give yourself longer to watch what happens, or down to iterate faster.

Useful commands:

```bash
make queue-attrs                      # queue depth and configuration
make queue-send MSG='{"hello":1}'     # publish a message by hand
make queue-purge                      # discard everything on the queue
make logs-consumer                    # what the consumer is doing
```

There is also a web view of the queues at http://localhost:9325.

## `cdn/`

Stands in for the CDN that serves article images. In production these are
uploaded by the ingestion pipeline and served from object storage behind a
CDN; locally an nginx container serves the same files from disk.

Base URL: http://localhost:8092

The `image_path` stored against an article is relative to that base - for
example `/articles/technology-01.svg` - so the host is configuration rather
than data. The frontend is given the base URL through the environment, which
is why changing the port here does not require reseeding the database.

```bash
curl -I http://localhost:8092/articles/technology-01.svg
```

## `consumer/`

Stands in for `article-ingestion-service`, which owns article state in
production and applies status changes published to the queue.

In production it would have its own database and the API would read article
state through it. Here it shares the local Postgres database, purely to keep the
local setup small.
