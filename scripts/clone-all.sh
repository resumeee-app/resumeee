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

# Regenerate go.work with exact pseudo-version replacements so offline/containerized
# Go builds resolve private sibling modules from the workspace without network access.
if command -v go >/dev/null 2>&1; then
  rm -f go.work
  go work init ./resumeee-api ./resumeee-auth-firebase ./resumeee-core ./resumeee-storage-sql
  grep -h -E 'github\.com/resumeee-app/resumeee-(core|storage-sql|auth-firebase) v' \
    resumeee-api/go.mod resumeee-storage-sql/go.mod resumeee-auth-firebase/go.mod 2>/dev/null \
    | awk '{print $1 "@" $2 "=./" substr($1, index($1, "/resumeee-")+1)}' \
    | sort -u \
    | while read -r rep; do
        go work edit -replace "${rep}"
      done
fi

echo "=== Workspace Ready ==="
