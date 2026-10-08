#!/usr/bin/env bash
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}"
export ROOT=$PWD
failed=0
while IFS= read -r cmd; do
  out=$(bash -c "$cmd" 2>&1) || { printf '%s\n' "$out" >&2; failed=1; }
done < <(jq -r '.check[]' .claude/harness.json)
[[ $failed == 0 ]] || exit 2
