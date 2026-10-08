#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0

for fx in "$root"/fixtures/*/; do
  stack=$(basename "$fx")
  preset="$root/presets/$stack/preset.json"
  dir=$(mktemp -d)
  cp -R "$fx." "$dir"
  cd "$dir"
  "$root/bin/harness" init "$stack" >/dev/null
  bash -c "$(jq -r '.deps // "true"' "$preset")" >/dev/null 2>&1

  ok() { echo "ok   $stack $1"; }
  bad() { echo "FAIL $stack $1"; fail=1; }
  lint() { echo "{\"tool_input\":{\"file_path\":\"$dir/$1\"}}" | CLAUDE_PROJECT_DIR=$dir .claude/hooks/lint-changed.sh 2>&1; }
  expect() {
    local want=$1 file=$2 needle=$3 out code=0
    out=$(lint "$file") || code=$?
    if [[ $code != "$want" || $out != *"$needle"* ]]; then
      bad "$file: exit $code, wanted $want with '$needle'"; echo "$out" | tail -8
    else
      ok "$file ${needle:+($needle)}"
    fi
  }
  formats() {
    lint "$1" >/dev/null || true
    if [[ $(cat "$1") == "$2" ]]; then ok "formats on edit"; else bad "did not format: $(cat "$1")"; fi
  }
  blocks() {
    local out code=0
    out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1) || code=$?
    if [[ $code == 2 && $out == *"$1"* ]]; then ok "check-all blocks ($1)"; else bad "check-all ($1): exit $code"; echo "$out" | tail -8; fi
  }
  passes() {
    local out
    if out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1); then ok "check-all passes clean"; else bad "check-all blocks clean project"; echo "$out" | tail -8; fi
  }

  if jq -e --slurpfile p "$preset" '.enabledPlugins // {} | contains($p[0].settings.enabledPlugins // {})' .claude/settings.json >/dev/null; then
    ok "lsp plugin enabled"
  else
    bad "lsp plugin not enabled"
  fi
  if grep -q 'end-to-end' CLAUDE.md; then ok "CLAUDE.md testing rule"; else bad "CLAUDE.md testing rule missing"; fi

  bunonly() { echo "{\"tool_input\":{\"command\":\"$1\"}}" | .claude/hooks/bun-only.sh >/dev/null 2>&1; }
  for c in "npm install x" "cd a && npx foo" "yarn add x"; do
    if bunonly "$c"; then bad "bun-only allowed: $c"; else ok "bun-only blocks: $c"; fi
  done
  for c in "bun add x" "grep npm README.md" "bunx oxlint ."; do
    if bunonly "$c"; then ok "bun-only allows: $c"; else bad "bun-only blocked: $c"; fi
  done

  prreview() { echo "{\"tool_input\":{\"command\":\"$1\"}}" | .claude/hooks/pr-review.sh 2>&1; }
  if out=$(prreview "gh pr create --fill"); then bad "pr-review silent on gh pr create"; elif [[ $out == *"codex review"* ]]; then ok "pr-review asks for review"; else bad "pr-review message"; fi
  if prreview "gh pr view" >/dev/null; then ok "pr-review ignores other gh"; else bad "pr-review fired on gh pr view"; fi

  source "$root/tests/$stack.sh"

  cd "$root"
  rm -rf "$dir"
done

exit $fail
