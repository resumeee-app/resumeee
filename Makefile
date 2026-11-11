.PHONY: all dev up down status logs clone test-all build-all clean

all: build-all

# Docker multi-container composition targets
up:
	docker compose up -d

down:
	docker compose down

status:
	docker compose ps

logs:
	docker compose logs -f

dev:
	docker compose -f docker-compose.dev.yml up --build

dev-down:
	docker compose -f docker-compose.dev.yml down

# Workspace multi-module developer targets
clone:
	./scripts/clone-all.sh

test-all:
	go test -race ./...

build-all:
	go build -o bin/resumeee ./cmd/resumeee

clean:
	rm -rf bin/
