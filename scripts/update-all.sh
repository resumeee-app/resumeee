#!/usr/bin/env bash
# scripts/update-all.sh — Fetches origin and fast-forwards each child repository on main.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

REPOS=(
  "core"
  "sql"
  "resumeee-auth-firebase"
  "server"
  "resumeee-web"
)

echo "=== Updating Resumeee Subrepositories ==="
cd "${ROOT_DIR}"

for repo in "${REPOS[@]}"; do
  if ! git -C "${repo}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[!] ${repo} is not a git repository, skipping."
    continue
  fi

  echo "[↓] Fetching ${repo}..."
  git -C "${repo}" fetch --prune origin

  branch="$(git -C "${repo}" symbolic-ref --short HEAD 2>/dev/null || true)"
  if [ "${branch}" = "main" ]; then
    git -C "${repo}" merge --ff-only origin/main
    echo "[✓] ${repo} updated to latest origin/main."
  else
    echo "[!] ${repo} is on '${branch:-detached HEAD}' (fetched origin, skipped fast-forward of main)."
  fi
done

"${SCRIPT_DIR}/sync-go-work.sh"

echo "=== Subrepositories Updated ==="
