# Local development entrypoint. Everything runs in Docker, so the only tools you
# need on your machine are Docker and Make.

QUEUE_ENDPOINT_LOCAL = http://localhost:9324/000000000000/article-status-changes
SQS_VERSION = 2012-11-05
GRPC_SERVICE = sliide.services.articles.api.ArticleAPI

# Request body for `make api-call`; override on the command line.
DATA ?= {}

.DEFAULT_GOAL := help

## Show this help
help:
	@echo ""
	@echo "Articles - local development"
	@echo ""
	@awk 'BEGIN { FS = ":.*" } /^## / { desc = substr($$0, 4); next } /^[a-zA-Z0-9_-]+:/ { if (desc != "") { printf "  \033[36m%-19s\033[0m %s\n", $$1, desc; desc = "" } }' $(MAKEFILE_LIST)
	@echo ""

# Not needed to run anything: `make up` installs dependencies inside the
# containers. This is purely so your editor can resolve imports and give you
# autocomplete and type checking.
## Install dependencies on your machine, for editor support
install:
	@if command -v pnpm > /dev/null 2>&1; then \
		echo "Installing web dependencies with local pnpm..."; \
		cd frontend && pnpm install; \
	elif command -v corepack > /dev/null 2>&1; then \
		echo "Installing web dependencies with corepack..."; \
		cd frontend && corepack pnpm install; \
	else \
		echo "No local Node found - installing web dependencies through Docker."; \
		echo "These are Linux builds: fine for your editor, but start the app with"; \
		echo "'make up' rather than running pnpm on your machine."; \
		docker run --rm -v "$(PWD)/frontend:/app" -w /app node:24-alpine \
				sh -c "corepack enable && pnpm install"; \
	fi
	@if command -v go > /dev/null 2>&1; then \
		echo "Downloading Go modules..."; \
		cd backend && go mod download; \
	else \
		echo "No local Go found - skipping Go modules. The API still builds in Docker."; \
	fi
	@echo "Done. Your editor should now resolve imports in backend/ and frontend/."

## Reinstall the web app's dependencies, after changing package.json
reinstall-frontend:
	@docker compose down frontend
	@docker volume rm articles_frontend_node_modules
	@docker compose up -d --build frontend

## Build and start the whole stack
up:
	@docker compose up -d --build
	@echo ""
	@echo "  Web app       http://localhost:5183"
	@echo "  BFF (tRPC)    localhost:3010"
	@echo "  gRPC API      localhost:8091"
	@echo "  Postgres      localhost:5442  (developer / devpassword / articles_db)"
	@echo "  Image CDN     localhost:8092  - external, see external/README.md"
	@echo "  Queue (SQS)   localhost:9324  - external, see external/README.md"
	@echo "  Queue stats   http://localhost:9325"
	@echo ""

## Stop the stack, keeping data
down:
	@docker compose down

## Follow logs from every service
logs:
	@docker compose logs -f

## Follow logs from our API service
logs-api:
	@docker compose logs -f api

## Follow logs from the web app and its BFF
logs-frontend:
	@docker compose logs -f frontend

## Follow logs from the external consumer
logs-consumer:
	@docker compose logs -f consumer

## Show the status of every container
ps:
	@docker compose ps

## Restart our API service
restart-api:
	@docker compose restart api

## Call an RPC directly, e.g. make api-call RPC=GetArticles DATA='{"count":3}'
api-call:
	@docker build -q -t articles-tools -f backend/Dockerfile.tools backend > /dev/null
	@DATA='$(DATA)'; docker run --rm --network articles_default articles-tools \
		buf curl --protocol grpc --http2-prior-knowledge \
		"http://api:8081/$(GRPC_SERVICE)/$(RPC)" -d "$$DATA"

## Regenerate Go code from the protobuf definitions
generate:
	@docker build -q -t articles-tools -f backend/Dockerfile.tools backend > /dev/null
	@docker run --rm -v "$(PWD)/backend:/app" -v articles_go_mod_cache:/go/pkg/mod articles-tools buf generate
	@echo "Generated Go written to backend/pkg/articles/api"
	@docker compose run --rm --no-deps frontend pnpm generate
	@echo "Generated TypeScript written to frontend/src/server/generated/grpc"

## Lint the protobuf definitions
lint-proto:
	@docker build -q -t articles-tools -f backend/Dockerfile.tools backend > /dev/null
	@docker run --rm -v "$(PWD)/backend:/app" articles-tools buf lint

## Open a psql shell against the local database
psql:
	@docker compose exec postgres psql -U developer -d articles_db

## Add 2000 more articles, to see how things behave with realistic volume
seed-large:
	@docker compose exec -T postgres psql -U developer -d articles_db -v ON_ERROR_STOP=1 < database/seed-large.sql

## Remove the bulk articles added by seed-large
seed-reset:
	@docker compose exec -T postgres psql -U developer -d articles_db -c "DELETE FROM articles WHERE title ~ ' \\([0-9]+\\)$$';"

## Destroy the database and rebuild it from the migrations
reset-db:
	@docker compose down -v
	@docker compose up -d --build
	@echo "Database recreated and migrations applied."

## Show queue depth and configuration (external service)
queue-attrs:
	@curl -s -X POST "$(QUEUE_ENDPOINT_LOCAL)" -d "Action=GetQueueAttributes" -d "AttributeName.1=All" -d "Version=$(SQS_VERSION)"
	@echo ""

## Publish a raw message to the queue by hand, e.g. make queue-send MSG='{"hello":1}'
queue-send:
	@MSG='$(MSG)' curl -s -X POST "$(QUEUE_ENDPOINT_LOCAL)" -d "Action=SendMessage" --data-urlencode "MessageBody=$$MSG" -d "Version=$(SQS_VERSION)"
	@echo ""

## Discard every message currently on the queue
queue-purge:
	@curl -s -X POST "$(QUEUE_ENDPOINT_LOCAL)" -d "Action=PurgeQueue" -d "Version=$(SQS_VERSION)"
	@echo ""

.PHONY: help install up down logs-frontend reinstall-frontend api-call generate lint-proto logs logs-api logs-consumer ps restart-api psql reset-db seed-large seed-reset queue-attrs queue-send queue-purge
