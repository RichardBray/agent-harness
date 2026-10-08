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
  bash -c "$(jq -r .deps "$preset") --silent" >/dev/null
  for i in $(seq 301); do echo "export const v$i = $i;"; done > src/long.ts

  lint() { echo "{\"tool_input\":{\"file_path\":\"$dir/$1\"}}" | CLAUDE_PROJECT_DIR=$dir .claude/hooks/lint-changed.sh 2>&1; }
  ok() { echo "ok   $stack $1"; }
  bad() { echo "FAIL $stack $1"; fail=1; }
  expect() {
    local want=$1 file=$2 needle=$3 out code=0
    out=$(lint "$file") || code=$?
    if [[ $code != "$want" || $out != *"$needle"* ]]; then
      bad "$file: exit $code, wanted $want with '$needle'"; echo "$out"
    else
      ok "$file ${needle:+($needle)}"
    fi
  }

  if jq -e --slurpfile p "$preset" '.enabledPlugins // {} | contains($p[0].settings.enabledPlugins // {})' .claude/settings.json >/dev/null; then
    ok "lsp plugin enabled"
  else
    bad "lsp plugin not enabled"
  fi

  bunonly() { echo "{\"tool_input\":{\"command\":\"$1\"}}" | .claude/hooks/bun-only.sh >/dev/null 2>&1; }
  for c in "npm install x" "cd a && npx foo" "yarn add x"; do
    if bunonly "$c"; then bad "bun-only allowed: $c"; else ok "bun-only blocks: $c"; fi
  done
  for c in "bun add x" "grep npm README.md" "bunx oxlint ."; do
    if bunonly "$c"; then ok "bun-only allows: $c"; else bad "bun-only blocked: $c"; fi
  done

  expect 0 src/good.ts ""
  expect 2 src/bad.ts "No \`as\` casts"
  expect 2 src/bad.ts "No console"
  expect 2 src/bad.ts "through its index"
  expect 2 src/long.ts "Split it"

  if jq -e .format .claude/harness.json >/dev/null; then
    printf 'export const  a={b:1}\n' > src/fmt.ts
    lint src/fmt.ts >/dev/null || true
    if [[ $(cat src/fmt.ts) == "export const a = { b: 1 };" ]]; then ok "formats on edit"; else bad "did not format: $(cat src/fmt.ts)"; fi
    rm src/fmt.ts
  fi

  out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1) && code=0 || code=$?
  if [[ $code == 2 && $out == *"No console"* ]]; then ok "check-all blocks"; else bad "check-all: exit $code"; echo "$out" | tail -5; fi
  rm -rf src/bad.ts src/long.ts src/features

  body='export function sum(xs: number[]): number {
  let total = 0;
  for (const x of xs) {
  if (x > 0) total += x;
  else total -= x;
  }
  const avg = total / xs.length;
  return avg > 10 ? total : avg;
}'
  echo "$body" > src/dup1.ts
  echo "$body" | sed 's/sum/sum2/' > src/dup2.ts
  printf 'export { sum } from "./dup1.js";\nexport { sum2 } from "./dup2.js";\n' >> src/index.ts
  out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1) && code=0 || code=$?
  if [[ $code == 2 && $out == *"Duplicated code"* ]]; then ok "check-all blocks duplication"; else bad "duplication: exit $code"; echo "$out" | tail -5; fi
  rm src/dup1.ts src/dup2.ts
  cp "$fx/src/index.ts" src/index.ts

  cp package.json package.json.bak
  jq '.dependencies = {"left-pad": "^1.3.0"}' package.json.bak > package.json
  out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1) && code=0 || code=$?
  if [[ $code == 2 && $out == *"Pin the exact version"* ]]; then ok "check-all blocks version ranges"; else bad "pins: exit $code"; echo "$out" | tail -5; fi
  mv package.json.bak package.json

  echo 'export const orphan = 1;' > src/orphan.ts
  out=$(CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh 2>&1) && code=0 || code=$?
  if [[ $code == 2 && $out == *"Unused code"* ]]; then ok "check-all blocks unused code"; else bad "unused: exit $code"; echo "$out" | tail -5; fi
  rm src/orphan.ts
  if CLAUDE_PROJECT_DIR=$dir .claude/hooks/check-all.sh; then ok "check-all passes clean"; else bad "check-all blocks clean project"; fi

  cd "$root"
  rm -rf "$dir"
done

exit $fail
