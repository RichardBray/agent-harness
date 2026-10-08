# agent-harness

Strict lint and type checks wired into Claude Code hooks, so the agent gets its mistakes back as errors and has to fix them.

```sh
cd my-project
~/agent-harness/bin/harness init          # detect stack, ESLint
~/agent-harness/bin/harness init --ox     # oxlint + oxfmt instead
~/agent-harness/bin/harness list
```

| When | Runs |
|---|---|
| After each edit | LSP diagnostics, format (Ox only), lint that file |
| Before the agent stops | `tsc`, lint, jscpd (duplication), knip (unused code) |

Copies into the project (skips existing files), then prints the install commands:
- `.claude/hooks/`, `.claude/harness.json`: the hooks and the commands they run
- `.claude/settings.json`: hook wiring and the LSP plugin
- linter config, `.harness/rules.mjs` (custom rules), `knip.json`

Review and commit them. Each project adds its own rules from there.

Test: `tests/run.sh`. Requires `jq`.
