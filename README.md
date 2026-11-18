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

### Option A: Single Docker Container (Prebuilt Image)

Run the unified container (Web SPA + REST API + SQLite persistence in `/data`):

```bash
docker run -p 8080:8080 -p 8081:8081 -v resumeee-data:/data \
  -e GEMINI_API_KEY=your_api_key \
  ghcr.io/resumeee-app/resumeee:latest
```

- **Web UI**: [http://localhost:8080](http://localhost:8080)
- **REST API (via NGINX proxy)**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)
- **REST API (direct backend port)**: [http://localhost:8081/api/v1](http://localhost:8081/api/v1)
- **Health Check**: `curl http://localhost:8080/api/v1/health`

*(Optional: pass `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or `OPENAI_COMPAT_BASE_URL` via `-e`. Separate service images are also published at `ghcr.io/resumeee-app/server:latest` and `ghcr.io/resumeee-app/web:latest`.)*

### Option B: Clone & Run from Source (Docker Compose)

#### 1. Clone Child Repositories & Configure Environment

```bash
git clone https://github.com/resumeee-app/resumeee.git
cd resumeee
./scripts/clone-all.sh
cp .env.example .env
# Add your GEMINI_API_KEY, OPENAI_API_KEY, or ANTHROPIC_API_KEY to .env
```

#### 2. Build & Run Full Stack (Docker Compose)

```bash
docker compose up --build
# or detached: make up
```

- **Web UI**: [http://localhost:3000](http://localhost:3000)
- **REST API**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)
- **Health Check**: `curl http://localhost:8080/api/v1/health`

Stop containers with:

```bash
docker compose down
# or: make down
```

#### 3. Run Manually Without Docker (or Dev Stack)

Run the Go live-reload + Vite HMR development stack via Docker:

```bash
make dev
```

Or run the Go API server (`:8080`) and React SPA (`:5173`) directly on your host:

```bash
PORT=8080 ADMIN_MODE=true go -C server run ./cmd/server
npm --prefix web install && npm --prefix web run dev
```

- **Web UI (Vite)**: [http://localhost:5173](http://localhost:5173)
- **REST API**: [http://localhost:8080/api/v1](http://localhost:8080/api/v1)

#### 4. Optional Local LLM (Ollama)

```bash
docker compose --profile local-llm up --build
docker exec -it resumeee-ollama ollama pull llama3.3
```

#### 5. Run Workspace Tests

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
