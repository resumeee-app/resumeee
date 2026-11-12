#!/usr/bin/env bash
# scripts/clone-all.sh — Prepares the full Resumeee multi-module developer workspace.
# If sibling checkouts exist in the parent directory, symlinks are created.
# Otherwise, child repositories are cloned directly from https://github.com/resumeee-app/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

REPOS=(
  "resumeee-core"
  "resumeee-storage-sql"
  "resumeee-auth-firebase"
  "resumeee-api"
  "resumeee-web"
)

BASE_URL="https://github.com/resumeee-app"

echo "=== Resumeee Developer Workspace Setup ==="
cd "${ROOT_DIR}"

for repo in "${REPOS[@]}"; do
  if [ -e "${repo}" ]; then
    echo "[✓] ${repo} already present."
  elif [ -d "../${repo}" ]; then
    echo "[→] Found sibling directory ../${repo}, linking..."
    ln -s "../${repo}" "${repo}"
  else
    echo "[↓] Cloning ${BASE_URL}/${repo}.git..."
    git clone "${BASE_URL}/${repo}.git" "${repo}"
  fi
done

echo "=== Syncing Go Workspace ==="
go work sync || true

echo "=== Workspace Ready ==="
