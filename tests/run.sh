#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0

for fx in "$root"/fixtures/*/; do
  stack=$(basename "$fx")
  dir=$(mktemp -d)
  cp -R "$fx." "$dir"
  cd "$dir"
  "$root/bin/harness" init "$stack" >/dev/null
  bash -c "$(jq -r .deps "$root/presets/$stack/preset.json") --silent" >/dev/null
  for i in $(seq 301); do echo "export const v$i = $i;"; done > src/long.ts

  lint() { echo "{\"tool_input\":{\"file_path\":\"$dir/$1\"}}" | CLAUDE_PROJECT_DIR=$dir .claude/hooks/lint-changed.sh 2>&1; }
  expect() {
    local want=$1 file=$2 needle=$3 out code=0
    out=$(lint "$file") || code=$?
    if [[ $code != "$want" || $out != *"$needle"* ]]; then
      echo "FAIL $stack $file: exit $code, wanted $want with '$needle'"; echo "$out"; fail=1
    else
      echo "ok   $stack $file ${needle:+($needle)}"
    fi
  }

  expect 0 src/good.ts ""
  expect 2 src/bad.ts "No \`as\` casts"
  expect 2 src/bad.ts "No console"
  expect 2 src/bad.ts "through its index"
  expect 2 src/long.ts "Split it"

  if CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>/dev/null; then
    echo "FAIL $stack check-all passed"; fail=1
  else
    echo "ok   $stack check-all blocks"
  fi
  rm -rf src/bad.ts src/long.ts src/features
  if CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh; then
    echo "ok   $stack check-all passes clean"
  else
    echo "FAIL $stack check-all blocks clean project"; fail=1
  fi
  rm -rf "$dir"
done

exit $fail
