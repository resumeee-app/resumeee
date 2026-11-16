<p align="center">
  <img src="./.github/logo-192x192.png" alt="Resumeee" width="96" />
</p>

# Resumeee

> **Single source of truth, infinite tailored resumes.**

**Resumeee** is a self-hosted career graph engine and interactive resume workspace. Maintain one master career profile and generate role-specific resumes across HTML, Markdown, and Plain Text without drift or invented credentials.

This repository (`github.com/resumeee-app/resumeee`) is the workspace and Docker Compose orchestrator that brings all Resumeee services together.

## Repositories

| Repository | Contents |
| :--- | :--- |
| [**`core`**](https://github.com/resumeee-app/core) | Domain models, career graph services, provenance validation, LLM clients, template rendering, and worker pool |
| [**`sql`**](https://github.com/resumeee-app/sql) | SQL persistence backend supporting SQLite, PostgreSQL, and MySQL |
| [**`server`**](https://github.com/resumeee-app/server) | REST API (`/api/v1/*`) and Model Context Protocol (MCP) server |
| [**`web`**](https://github.com/resumeee-app/web) | React Single-Page Application (SPA) |

## Quickstart

### 1. Clone Child Repositories & Configure Environment

```bash
./scripts/clone-all.sh
cp .env.example .env
# Add your GEMINI_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY to .env
```

### 2. Run Full Stack (Docker Compose)

```bash
docker compose up -d --build
# or: make up
```

- **Web UI**: [http://localhost:3000](http://localhost:3000)
- **REST API**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)
- **Health Check**: `curl http://localhost:8080/api/v1/health`

Stop containers with:

```bash
docker compose down
# or: make down
```

### 3. Run Development Stack (Live Reload)

Runs Go live-reload alongside Vite HMR:

```bash
make dev
```

- **Web UI (Vite HMR)**: [http://localhost:5173](http://localhost:5173)
- **REST API**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)

### 4. Optional Local LLM (Ollama)

```bash
docker compose --profile local-llm up -d --build
docker exec -it resumeee-ollama ollama pull llama3.3
```

### 5. Run Workspace Tests

```bash
make test-all
```

---

## License & Trademarks

### License
Resumeee is licensed under the **GNU Affero General Public License v3.0 or later** ([AGPL-3.0-or-later](LICENSE)).

You are free to use, modify, and host this software. Under the AGPL, any modified versions distributed or hosted over a network must make their complete source code freely available under the same license terms.

For commercial inquiries or custom closed-source licensing arrangements, contact Ruben Rivera.

### Contributor Agreement
All external contributions are welcomed under the terms of our [Contributor License Agreement (CLA)](CLA.md). See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Trademark Notice
"Resumeee" and the Resumeee branding and logo are trademarks of Ruben Rivera. The AGPLv3 license gives you rights to the software code, but does not grant rights to use the official name, logo, or trademarks for derivative products or publicity without prior written permission.
