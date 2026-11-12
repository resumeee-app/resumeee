# Resumeee

> **AI-Powered Career Profile & Targeted Resume Tailoring Engine**  
> Flagship Distribution, Multi-Container Orchestrator & Developer Workspace Hub.

---

## Overview

**Resumeee** is an autonomous, contract-first platform for career management and resume tailoring. It treats candidate career histories as living graph structures, enabling job seekers to create targeted resume branches, run ATS qualification and keyword gap analysis, tailor achievements using multi-provider LLMs with strict provenance tracking, and render ATS-friendly resumes across formats.

This repository (**`github.com/resumeee-app/resumeee`**) serves as the **flagship distribution and orchestration hub**. It uses Docker Compose to launch all services together and provides master Go workspace orchestration (`go.work`) for contributors.

---

## 30-Second Quickstart (Docker Compose)

Spin up the complete Resumeee stack (API server, Single-Page Application, and PostgreSQL database) using Docker:

```bash
# Clone the flagship distribution repository
git clone https://github.com/resumeee-app/resumeee.git
cd resumeee

# Bring up all services with Docker Compose
docker compose up -d
```

Once running:
- **Web User Interface**: [http://localhost:3000](http://localhost:3000)
- **REST API & Swagger Specs**: [http://localhost:8080/api/v1/health](http://localhost:8080/api/v1/health)
- **PostgreSQL Database**: `localhost:5432` (`resumeee` / `resumeee_secure_pass`)

To shut down:
```bash
docker compose down
```

---

## Resumeee Orchestration CLI

The flagship repository includes a lightweight CLI (`resumeee`) for managing multi-container service lifecycle:

```bash
# Build the orchestration binary
make build-all

# Launch all containerized services
./bin/resumeee up

# Check status of container fleet
./bin/resumeee status

# Stream container logs
./bin/resumeee logs

# Stop all containers
./bin/resumeee down
```

---

## Ecosystem Architecture & Repositories

Resumeee is organized across five decoupled, contract-governed repositories under the [`resumeee-app`](https://github.com/resumeee-app) organization:

| Repository | Role & Layer | Tech Stack |
| :--- | :--- | :--- |
| [**`resumeee-core`**](https://github.com/resumeee-app/resumeee-core) | Pure domain entities, validators, PII obfuscation, prompt compiler, LLM schemas, injectable `LLMClient` transport providers, worker pool, and business services | Go (Zero ORM dependencies) |
| [**`resumeee-storage-sql`**](https://github.com/resumeee-app/resumeee-storage-sql) | Dialect-agnostic SQL storage adapter with TLS enforcement and DSN sanitization | Go, GORM, SQLite, PostgreSQL, MySQL |
| [**`resumeee-auth-firebase`**](https://github.com/resumeee-app/resumeee-auth-firebase) | RS256 token verification adapter with fail-closed key caching and dev verifier | Go, Google JWKS, RS256 |
| [**`resumeee-api`**](https://github.com/resumeee-app/resumeee-api) | Unified HTTP REST server (`/api/v1/*`) and Model Context Protocol server (`cmd/mcp`, `/mcp/*`) | Go, OpenAPI 3.1, MCP Protocol SDK |
| [**`resumeee-web`**](https://github.com/resumeee-app/resumeee-web) | Pure client-side Single-Page Application (Zero SSR) deployed to object storage & CDN | React 18, Vite, Radix UI, TypeScript |

---

## Developer Workspace Setup (`go.work`)

For developers contributing across multiple repositories simultaneously, this repository provides a master Go workspace:

```bash
# 1. Clone or symlink all child repositories into the workspace
make clone
# or: ./scripts/clone-all.sh

# 2. Run tests across all Go repositories in the workspace
make test-all

# 3. Launch local live-reload development containers
make dev
```

---

## Deployment Templates

Production deployment manifests are provided under [`deploy/`](./deploy/):
- **Docker Compose**: [`docker-compose.yml`](./docker-compose.yml) (official multi-container production stack)
- **Kubernetes Helm Chart**: [`deploy/helm/`](./deploy/helm/)
- **Fly.io Manifest**: [`deploy/fly/fly.toml`](./deploy/fly/fly.toml)

---

## License

GNU Affero General Public License v3.0 (AGPL-3.0). See [LICENSE](./LICENSE) for details.
