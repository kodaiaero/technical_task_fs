# Verification

Use the smallest set of checks that establishes the behavior being changed. Report commands run, observed results, and any unverified behavior.

## Prerequisites

Follow [README.md](../README.md) for Docker and local development setup. `make up` starts the complete stack. `make install` provides host-side dependencies for editor support and local checks; use the Node and Go versions specified by `frontend/package.json` and `backend/go.mod`.

## Local checks

From the repository root, run `make check` with local Go and pnpm installed. CI uses `make check-go` and `make check-web` separately. These targets run the commands below.

Run in `backend/`:

```sh
go test ./...
go vet ./...
```

Run in `frontend/`:

```sh
pnpm typecheck
pnpm test
```

The article service tests cover both status-change message actions, invalid input, missing articles, database and publish failures, and request deadline propagation using fake dependencies. They do not establish real SQS delivery or consumer behavior. `go vet` and TypeScript checking also do not establish runtime behavior.

For protobuf changes, run from the repository root:

```sh
make lint-proto
make generate
```

Review regenerated files and rerun the relevant Go and TypeScript checks. Generation uses Docker and can take longer on its first run.

## Article read smoke check

With the stack running:

1. Open `http://localhost:5183`. With the initial seed data, the list contains 40 articles with images and status badges.
2. Open an article. Check that its title, metadata, and body appear, then return to the list.
3. Open a detail URL containing a well-formed article UUID that is absent from the database. Check that the UI reports the failure rather than displaying an unrelated article.
4. When investigating a failure, use `make logs-frontend` and `make logs-api` to inspect the BFF and Go API respectively.

To inspect the Go API independently of the UI and BFF, run from the repository root:

```sh
make api-call RPC=GetArticles
make api-call RPC=GetArticleDetails DATA='{"id":"<article-id>"}'
```

Replace `<article-id>` with an ID from the list response. These checks exercise the read path only. See [external/README.md](../external/README.md) for queue inspection and manual message publishing; a successful queue send is not evidence that a database update completed.

## Automation

[CI](../.github/workflows/ci.yml) runs on pull requests targeting `master` or `main`, pushes to either branch (including merges), and manual dispatch. Independent jobs run Go tests/vet and TypeScript checking using the same Make targets as local development.

Go and Node versions come from `backend/go.mod` and `frontend/package.json`; pnpm uses the latter's `packageManager` field. Frontend dependencies are installed with `--frozen-lockfile`.

CI does not currently run browser tests, the external consumer, protobuf generation checks, or dependency-direction rules. It checks the behavior covered by the Go unit tests and static correctness; passing it does not establish end-to-end behavior. Making these checks mandatory before merging requires repository branch protection configuration.

## Focused behavior coverage

- Go service tests use stub dependencies to check the mutation contract and failure boundaries.
- Shutdown tests use an in-memory gRPC server with a blocked real RPC to check draining and forced termination.
- Node tests check BFF action mapping/rejection and sequential confirmation reads, transient errors, deadline cancellation, and page-exit cancellation. They do not mount React components.
- No coverage quota or browser automation suite is included.

## Status-change manual checks

1. Disable an enabled article. The badge should remain Live while the request is accepted and pending, then change only after a fresh read observes Disabled. Verify the list too.
2. Enable the article and confirm the reverse path.
3. Temporarily set `make queue-delay DELAY=45`. At the 30-second UI deadline, verify an unconfirmed message and `Check status`. A fresh mismatch permits `Retry request`; the original queued request may still apply. Restore the previous queue delay afterward.
4. Leave or reload the page while pending. The old request is not cancelled; the new view reads current article state and does not restore the old operation.

The default local delay is five seconds. Runtime delay changes are local test configuration, not changes to `external/`.
