#!/usr/bin/env bash
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"
cfg=.claude/harness.json
file=$(jq -r '.tool_input.file_path // empty')
[[ -n $file && $file =~ $(jq -r .lint_match "$cfg") ]] || exit 0
out=$(bash -c "$(jq -r .lint "$cfg") \"\$1\"" _ "$file" 2>&1) || { printf '%s\n' "$out" >&2; exit 2; }
