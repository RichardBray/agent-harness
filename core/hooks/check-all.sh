#!/usr/bin/env bash
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"
out=$(bash -c "$(jq -r .check .claude/harness.json)" 2>&1) || { printf '%s\n' "$out" >&2; exit 2; }
