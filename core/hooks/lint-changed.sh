#!/usr/bin/env bash
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"
cfg=.claude/harness.json
file=$(jq -r '.tool_input.file_path // empty')
[[ -n $file && $file =~ $(jq -r .lint_match "$cfg") ]] || exit 0
run() { bash -c "$1 \"\$1\"" _ "$file" 2>&1; }
fmt=$(jq -r '.format // empty' "$cfg")
[[ -z $fmt ]] || run "$fmt" >/dev/null || true
out=$(run "$(jq -r .lint "$cfg")") || { printf '%s\n' "$out" >&2; exit 2; }
