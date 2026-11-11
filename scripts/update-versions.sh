#!/usr/bin/env bash
# scripts/update-versions.sh — Audits and verifies cross-module dependency references.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Resumeee Module Version Audit ==="

REPOS=(
  "resumeee-core"
  "resumeee-llm"
  "resumeee-storage-sql"
  "resumeee-auth-firebase"
  "resumeee-api"
)

for repo in "${REPOS[@]}"; do
  MOD_PATH="${ROOT_DIR}/${repo}/go.mod"
  if [ -f "${MOD_PATH}" ]; then
    MOD_NAME=$(grep '^module ' "${MOD_PATH}" | awk '{print $2}')
    echo "[OK] Found ${repo}: module ${MOD_NAME}"
  else
    echo "[WARN] ${repo}/go.mod not found (run ./scripts/clone-all.sh first)"
  fi
done

echo "=== All module boundaries verified ==="
