# agent-harness

Strict checks wired into Claude Code hooks, so the agent gets its mistakes back as errors and has to fix them.

```sh
cd my-project
~/agent-harness/bin/harness init   # detects presets per folder, or: init <preset>
~/agent-harness/bin/harness baseline   # existing codebase: block only new issues
~/agent-harness/bin/harness list
```

| Preset | Applies to | After each edit | Before the agent stops |
|---|---|---|---|
| typescript | `tsconfig.json` at root | TS 7 LSP, oxfmt, oxlint | `bun run typecheck` (or `tsc`), oxlint, fallow (unused + duplicated code), exact pins + `bun.lock` |
| react | packages depending on `react` | react-hooks and a11y rules | Open Graph tags |
| astro | `astro.config.*` | | Open Graph tags |
| rust | each `Cargo.toml` | rust-analyzer LSP, `cargo fmt`, clippy | `cargo fmt --check`, clippy, `cargo test`, `cargo deny` |

Every project also gets:
- a hook that blocks npm/npx/yarn/pnpm (use Bun)
- after `gh pr create`, a prompt to have a different model review the PR
- a `## Testing` section in `CLAUDE.md`: few tests, mostly end-to-end

Open Graph tags (`og:title`, `og:description`, `og:image`) are required for Astro sites and for React packages with a `wrangler.*` or `vercel.json`.

Rust: clippy runs pedantic and bans `unwrap`/`expect`/`dbg!`/`todo!` outside tests. Cargo calls unset `RUSTUP_TOOLCHAIN` so `rust-toolchain.toml` wins.

Existing codebase with lots of failures? Run `harness baseline`: the stop check then only blocks on new issues, while per-edit lint still flags every issue in files the agent touches, so old ones get fixed as files are edited. Re-run it to shrink the baseline.

`init` copies hooks, configs and `.claude/harness.json` (the commands the hooks run), skips files that exist, and prints install commands. Review and commit them; each project adds its own rules from there.

Test: `tests/run.sh`. Requires `bun`, `cargo` and `jq`.
