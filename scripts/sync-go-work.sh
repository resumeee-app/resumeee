#!/usr/bin/env bash
# scripts/sync-go-work.sh — Regenerates go.work with exact pseudo-version replacements
# so offline/containerized Go builds resolve sibling modules from the workspace.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

if command -v go >/dev/null 2>&1; then
  rm -f go.work
  go work init ./server ./core ./sql
  grep -h -o -E 'github\.com/resumeee-app/(core|sql) v[^ ]+' \
    server/go.mod sql/go.mod 2>/dev/null \
    | sort -u \
    | while read -r mod ver; do
        dir="${mod##*/}"
        go work edit -replace "${mod}@${ver}=./${dir}"
      done
fi
