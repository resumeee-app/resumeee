.PHONY: clone up down status logs dev dev-down fmt fmt-check test-all

DEV_UID ?= $(shell id -u)
DEV_GID ?= $(shell id -g)

# Ensure all child repositories are cloned or linked into the workspace
clone:
	./scripts/clone-all.sh

# Build and start full stack in detached mode (Go API/MCP server + NGINX Web SPA)
up: clone
	docker compose up -d --build

# Stop full stack containers
down:
	docker compose down

# Show running container status
status:
	docker compose ps

# Follow container logs
logs:
	docker compose logs -f

# Run live-reload development stack (air for Go modules + Vite HMR on :5173)
dev: clone
	DEV_UID=$(DEV_UID) DEV_GID=$(DEV_GID) docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

# Stop live-reload development stack
dev-down:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down

# Format all Go workspace modules with gofmt
fmt: clone
	gofmt -w ./resumeee-core ./resumeee-storage-sql ./resumeee-auth-firebase ./resumeee-api

# Check gofmt formatting across all Go workspace modules
fmt-check: clone
	@unformatted=$$(gofmt -l ./resumeee-core ./resumeee-storage-sql ./resumeee-auth-firebase ./resumeee-api); \
	if [ -n "$$unformatted" ]; then \
		echo "The following files are not formatted with gofmt:"; \
		echo "$$unformatted"; \
		exit 1; \
	fi

# Run Go formatting check and tests across all workspace modules
test-all: fmt-check
	go test -race ./resumeee-core/... ./resumeee-storage-sql/... ./resumeee-auth-firebase/... ./resumeee-api/...
