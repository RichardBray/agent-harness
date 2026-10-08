# agent-harness

Strict lint and type checks wired into Claude Code hooks, so the agent gets its mistakes back as errors and has to fix them.

```sh
cd my-project
~/agent-harness/bin/harness init   # or: init typescript
~/agent-harness/bin/harness list
```

| When | Runs |
|---|---|
| Before a shell command | blocks npm/npx/yarn/pnpm: use Bun |
| After each edit | TypeScript 7 LSP diagnostics, oxfmt, oxlint on that file |
| Before the agent stops | `tsc`, oxlint, fallow (unused and duplicated code), exact-pinned versions and `bun.lock` |

Copies into the project (skips existing files), then prints the install commands:
- `.claude/hooks/`, `.claude/harness.json`: the hooks and the commands they run
- `.claude/settings.json`: hook wiring and the `ts7-lsp` plugin from this repo's marketplace
- `.oxlintrc.json`, `.fallowrc.json`, `.harness/` (custom rules, pin check)

Review and commit them. Each project adds its own rules from there.

Test: `tests/run.sh`. Requires `bun` and `jq`.
