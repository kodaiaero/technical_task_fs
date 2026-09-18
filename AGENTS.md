# Agent guidance

## Where to look

Read the document relevant to the change rather than loading every document up front.

| Working on | Start here |
| --- | --- |
| Setup and available commands | [README.md](README.md) and [Makefile](Makefile) |
| Service boundaries and request flow | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Validation and manual checks | [docs/verification.md](docs/verification.md) |
| Queue messages and external dependencies | [external/README.md](external/README.md) |

## Working practices

- Inspect the existing implementation before changing behavior.
- Keep changes within the requested scope. Leave unrelated cleanup for a separate task.
- Follow the existing project structure and conventions unless there is a clear reason to change them.
- Treat `external/` as an integration boundary owned by other teams; do not modify it.
- Edit API contracts in `backend/api/proto/`, then run `make generate`. Include generated Go and TypeScript changes together with the source contract; do not hand-edit generated clients.
- A successful queue publish confirms acceptance, not an applied database change. Consult the external contract before changing status-related behavior.
- Run checks relevant to the changed code and report what was verified.
- Explain meaningful design choices and trade-offs so the work can be reviewed.
- Update the relevant documentation when behavior, boundaries, or verification steps change.
- Write code, comments, commit messages, and PR descriptions in English.

## Quick checks

- From the repository root: `make check` runs the same Go and TypeScript checks as CI. Use `make check-go` or `make check-web` for a single stack.
- In `backend/`: `go test ./...` and `go vet ./...`.
- In `frontend/`: `pnpm typecheck` and `pnpm test`.
- After protobuf edits: `make lint-proto` and `make generate` from the repository root.

See [verification](docs/verification.md) for prerequisites and the limits of these checks.
