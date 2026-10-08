if jq -e '[.edit[].match] | any(startswith("^packages/engine/"))' .harness/harness.json >/dev/null; then ok "rust preset scoped to packages/engine"; else bad "rust not scoped"; fi
if [[ -e packages/engine/clippy.toml && ! -e clippy.toml ]]; then ok "rust files in crate dir"; else bad "rust files misplaced"; fi

expect 0 packages/app/src/index.ts ""
printf 'export const n = JSON.parse("1") as number;\n' > packages/app/src/bad.ts
expect 2 packages/app/src/bad.ts "No \`as\` casts"
rm packages/app/src/bad.ts

printf 'pub fn port(s: &str) -> u16 {\n    s.parse().unwrap()\n}\n' > packages/engine/src/bad.rs
echo 'pub mod bad;' >> packages/engine/src/lib.rs
expect 2 packages/engine/src/bad.rs "unwrap"
blocks "unwrap"
rm packages/engine/src/bad.rs
cp "$fx/packages/engine/src/lib.rs" packages/engine/src/lib.rs

passes
