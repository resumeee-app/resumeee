# Resumeee

> **Single source of truth, infinite tailored resumes.**  
> Multi-Repository Workspace & Docker Compose Orchestrator.

---

## Overview

**Resumeee** is a self-hosted, contract-first career graph engine and interactive resume workspace. It maintains a single Master Profile and branches it into targeted, role-specific resumes across HTML, Markdown, and Plain Text formats while enforcing a strict **Provenance & Grounding Validator ("No Lies" invariant)**.

This repository (**`github.com/resumeee-app/resumeee`**) is the top-level workspace and Docker Compose orchestrator that brings all Resumeee services up together.

---

## Ecosystem Repositories

| Repository | Responsibility |
| :--- | :--- |
| [**`core`**](https://github.com/resumeee-app/core) | Core domain entities, interfaces (`LLMClient`, `LLMProvider`, repositories), prompt compiler, JSON schemas, built-in LLM transport clients (Gemini, OpenAI, Anthropic, OpenAI-Compat), provenance validator, template renderer, and worker pool |
| [**`sql`**](https://github.com/resumeee-app/sql) | SQL persistence adapter (`sqlite`, `postgres`, `dbutil`) with automatic migrations and default profile/preset/template seeding |
| [**`resumeee-auth-firebase`**](https://github.com/resumeee-app/resumeee-auth-firebase) | Authentication provider registry, RS256 Firebase JWT verifier, and local single-user Admin Mode provider |
| [**`server`**](https://github.com/resumeee-app/server) | OpenAPI 3.1 contract, HTTP REST router (`/api/v1/*`), and Model Context Protocol server (`cmd/server`, `cmd/mcp`, `/mcp/*`) |
| [**`resumeee-web`**](https://github.com/resumeee-app/resumeee-web) | Pure client-side React 18 + Radix UI Single-Page Application (Zero SSR) |

---

## Quickstart (Docker Compose)

### 1. Clone Child Repositories & Configure Environment

```bash
# Clone or symlink all child repositories into the workspace
./scripts/clone-all.sh

# Create your local .env configuration
cp .env.example .env
# Add your GEMINI_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY to .env
```

### 2. Run Full Stack (Production Containers)

Builds and runs the Go API/MCP server (`:8080`) with persistent SQLite storage (`resumeee-data:/data`) and the NGINX Web SPA (`:3000`):

```bash
docker compose up -d --build
# or: make up
```

- **Web UI**: [http://localhost:3000](http://localhost:3000)
- **REST API**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)
- **Health Check**: `curl http://localhost:8080/api/v1/health`

To stop:
```bash
docker compose down
# or: make down
```

### 3. Run Development Stack with Live Reload (`air` + Vite HMR)

Runs Go live-reload (`air` watching `core`, `sql`, `resumeee-auth-firebase`, and `server`) alongside Vite HMR (`resumeee-web`):

```bash
DEV_UID=$(id -u) DEV_GID=$(id -g) docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
# or: make dev
```

- **Web UI (Vite HMR)**: [http://localhost:5173](http://localhost:5173)
- **REST API (`air`)**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)

### 4. Optional: Local Ollama Container (`local-llm` profile)

```bash
docker compose --profile local-llm up -d --build
docker exec -it resumeee-ollama ollama pull llama3.3
```

---

## Multi-Module Go Workspace (`go.work`)

After running `./scripts/clone-all.sh`, `go.work` links all four Go repositories for unified local development and testing:

```bash
make test-all
```

---

## License

GNU Affero General Public License v3.0 (AGPL-3.0). See [LICENSE](./LICENSE) for details.
