# agent-harness

Strict lint and type checks wired into Claude Code hooks, so the agent gets its mistakes back as errors and has to fix them.

```sh
cd my-project
~/agent-harness/bin/harness init   # or: init typescript | rust
~/agent-harness/bin/harness list
```

| | TypeScript | Rust |
|---|---|---|
| Before a shell command | block npm/npx/yarn/pnpm | same |
| After each edit | TS 7 LSP, oxfmt, oxlint | rust-analyzer LSP, `cargo fmt`, clippy |
| Before the agent stops | `tsc`, oxlint, fallow, exact pins + `bun.lock` | `cargo fmt --check`, clippy, `cargo test`, `cargo deny` |

Rust: clippy runs pedantic and bans `unwrap`/`expect`/`dbg!`/`todo!` outside tests. Every cargo call unsets `RUSTUP_TOOLCHAIN` so `rust-toolchain.toml` wins.

`init` also adds a `## Testing` section to `CLAUDE.md`: few tests, mostly end-to-end.

Copies into the project (skips existing files), then prints the install commands:
- `.claude/hooks/`, `.claude/harness.json`: the hooks and the commands they run
- `.claude/settings.json`: hook wiring and the LSP plugin (TypeScript uses `ts7-lsp` from this repo's marketplace)
- TypeScript: `.oxlintrc.json`, `.fallowrc.json`, `.harness/` (custom rules, pin check)
- Rust: `clippy.toml`, `deny.toml`

Review and commit them. Each project adds its own rules from there.

Test: `tests/run.sh`. Requires `bun`, `cargo` and `jq`.
