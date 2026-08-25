# Full Stack Developer Technical Task

Congratulations on reaching this stage, and thank you for giving us your time.

We have tried to make this task feel like a normal Tuesday rather than an exam.
You are given a small but complete application - a Go backend, a Node
backend-for-frontend, a React web app and a Postgres database - and asked to add
one feature to it, then make the service around that feature more production
ready.

There is deliberately more here than anyone could finish. That is the point: we
are interested in what you choose to do and why, not in a completed checklist.

---

## Getting started

You need **Docker** and **Make**. Nothing else.

```bash
make up
```

That builds and starts everything. The first run takes a couple of minutes while
images build; after that it is about ten seconds.

Then open **<http://localhost:5183>** and you should see a list of forty
articles. Click one to read it.

If you would like your editor to give you autocomplete and type checking, also
run:

```bash
make install
```

That is only for your editor's benefit - the app itself runs entirely in Docker
and does not need it.

### Where everything lives

| | Address | |
| --- | --- | --- |
| Web app | <http://localhost:5183> | The React app - start here |
| BFF | `localhost:3010` | tRPC API the web app talks to |
| Go API | `localhost:8091` | gRPC API the BFF talks to |
| Postgres | `localhost:5442` | `developer` / `devpassword` / `articles_db` |
| Image CDN | <http://localhost:8092> | Article images (external) |
| Queue | `localhost:9324` | SQS-compatible queue (external) |
| Queue console | <http://localhost:9325> | A web view of the queue (external) |

These ports are deliberately unusual so they do not clash with anything else you
may have running.

---

## How the application fits together

This mirrors the shape of our real system, simplified down to one repository.

```
                      ┌──────────────────────────┐
   browser ──────────►│  frontend/               │
                      │    src/client   React    │
                      │    src/server   BFF      │
                      └────────────┬─────────────┘
                                   │  gRPC
                      ┌────────────▼─────────────┐
                      │  backend/                │
                      │    Go API                │──── publishes ───┐
                      └────────────┬─────────────┘                  │
                                   │  SQL                           │
                      ┌────────────▼─────────────┐        ┌─────────▼────────┐
                      │        Postgres          │        │   queue (SQS)    │
                      └────────────▲─────────────┘        └─────────┬────────┘
                                   │                                │
                                   │  SQL          ┌────────────────▼───────┐
                                   └───────────────│  external/consumer     │
                                                   │  (another team's       │
                                                   │   service)             │
                                                   └────────────────────────┘
```

- **`frontend/`** - React 19, TanStack Router and Query, Tailwind, and a Fastify
  server exposing a typed tRPC API. `src/models` holds types shared between the
  two.
- **`backend/`** - a Go gRPC service over Postgres. Protobuf definitions live in
  `backend/api/proto`.
- **`external/`** - stands in for things we do not own. **Please do not change
  anything in here.** See [external/README.md](external/README.md).

---

## Your task

### Part one: add a disable button

Editors need to be able to take an article down, and put it back up again. Add
that control to the article page.

The catch is how the change is applied. Our API does not write the change
itself - it publishes a message to a queue, and a service we do not own picks
that message up and applies it, usually a few seconds later. So the API can tell
you the request was *accepted*, but it can never tell you the change has
*happened*.

That leaves you with a genuinely interesting problem:

> **What do you show the person who just clicked the button?**

There is no single right answer, and we are far more interested in your
reasoning than in any particular implementation.

Worth thinking about, and worth writing down even if you do not build it:

- What if they reload the page while the change is in flight?
- What does a *different* editor see in the meantime?
- What if the message is lost, or takes a minute?
- What if they click the button five times?

You will need to touch every layer: the protobuf definition, the Go service, the
tRPC API, and the React app. The existing read path (`GetArticles` and
`GetArticleDetails`) is a worked example of that journey - follow it.

#### The message you need to publish

The service that applies the change is not ours, so your message has to match the
shape it expects:

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
| `trace_id` | no | Echoed into their logs, so you can follow one change across both services. |

Four things about the queue worth knowing before you design around it:

- **There is a five second delay** before the other service can see your
  message. That is deliberate, so the asynchronous behaviour is easy to watch.
  Turn it up or down while you work on the UI to test: `make queue-delay DELAY=30`.
- **Delivery is at-least-once**, so the same message may be applied more than
  once.
- **Messages are not ordered.** Two changes to the same article published a
  moment apart may be applied in either order.
- **A message they cannot understand is not silently dropped.** It is retried a
  few times and then set aside, and the reason appears in `make logs-consumer`.

You can publish a message by hand to see all this working before you write any
code:

```bash
make queue-send MSG='{"type":"article.status.changed","article_id":"9b7de9fe-b477-5418-b126-2cb5b8aa56a6","action":"disable"}'
make logs-consumer
```

[external/README.md](external/README.md) covers the rest: what happens in each
failure case, and how to inspect the dead letter queue.

### Part two: make it more production ready

The Go service works, but nobody would want to be on call for it. Have a look
through it with an operational eye and improve what you judge most important.

We would rather see **three things done properly, plus a written list of what
you would do next and why**, than twelve things half done. Deciding what matters
most is the interesting part of this exercise, so please tell us how you
prioritised.

The web app and BFF are in better shape - treat them as the standard to work to
rather than something needing repair.

---

## Useful commands

Run `make` on its own to see everything. The ones you are most likely to want:

```bash
make up                  # start everything
make down                # stop everything
make logs                # follow all logs
make logs-api            # just the Go service
make logs-frontend       # just the web app and BFF
make logs-consumer       # just the external consumer
make psql                # a database shell

make generate            # regenerate code after editing a .proto
make lint-proto          # lint the protobuf definitions

make api-call RPC=GetArticles                  # call the Go API directly
make api-call RPC=GetArticleDetails DATA='{"id":"..."}'

make queue-attrs         # what is sitting on the queue
make queue-send MSG='{}' # put a message on the queue by hand
make queue-delay DELAY=30 # hold messages for longer, to watch the async gap
make queue-purge         # empty the queue

make reset-db            # rebuild the database from the migrations
make seed-large          # add 2000 more articles
make seed-reset          # remove them again
```

`make generate` and `make lint-proto` run inside Docker, so you do not need
`buf`, `protoc` or Go installed to use them.

---

## Things that will save you time

**Adding a database migration.** Add a new numbered file in
`backend/internal/database/migrations/`. Migrations run automatically when the
API starts.

**Editing a migration that has already run does nothing.** Applied migrations
are not re-checked, so your change will be silently ignored. Either add a new
migration, or run `make reset-db` to rebuild from scratch.

**After changing `frontend/package.json`**, run `make reinstall-frontend`. The
container keeps its dependencies in a Docker volume, so a plain restart will not
pick up a new package.

**The protobuf files use `edition = "2023"`.** Scalar fields generate as
pointers in Go, so use the getters (`req.GetId()`) rather than reading fields
directly.

**When a queued message seems to vanish**, `make logs-consumer` will usually
tell you why, and `make queue-attrs` shows what is still waiting. A message the
consumer cannot understand is retried a few times and then set aside - see
[external/README.md](external/README.md).

**The queue's delay is configurable.** It is set to five seconds so the
asynchronous behaviour is easy to see. `make queue-delay DELAY=30` will hold
messages for longer, which is handy while you are working on the UI. It resets
to five seconds whenever the queue container restarts.

---

## How long to spend

**Please spend no more than around four hours on this.** We mean it - we are not
trying to consume your weekend, and we would rather read a focused submission
with honest notes about what you left out.

If you run out of time mid-thought, say so in your README. "I would have done X
next, for this reason" tells us as much as the code does.

## Using AI tools

Please **do** use them if that is how you normally work - we do. The only thing
we ask is that **you understand and can explain everything you submit**, because
we will go through it with you.

Include an `AI_USAGE.md` covering:

- The prompts that did the heavy lifting
- How you steered it when it went wrong
- How you checked the output was correct

If you would rather not use AI, that is completely fine too - just say so.

---

## Submitting your work

Please **do not** push to this repository. Either send us a link to your own
fork or repository, or zip up the project and email it to your recruiter.

Include a short **README** of your own covering:

- What you built, and how to run it if anything differs from the above
- The decisions you made, and any assumptions
- How you approached the "what do we show the user?" problem
- What you would do next, and why - especially for anything you spotted but did
  not have time to fix

Plus **`AI_USAGE.md`** if you used AI.

---

## Anything unclear?

Please ask - via your recruiter, any time. A question about the task is never
held against you, and it usually means we have written something ambiguously.

Once we have your submission we will review it and, if it looks good, invite you
to a call to walk us through it. That conversation is the part we enjoy most:
expect us to ask why, not to quiz you on syntax.

Good luck, and thank you again for your time.
