# agent-harness

Strict lint and type checks wired into Claude Code hooks, so the agent gets its mistakes back as errors and has to fix them.

```sh
cd my-project
~/agent-harness/bin/harness init   # or: init typescript
```

Copies into the project (skips existing files):
- `.claude/hooks/lint-changed.sh`: after each edit, lints that file
- `.claude/hooks/check-all.sh`: before the agent stops, runs the full check
- `.claude/harness.json`: the commands both hooks run
- the preset's config files, e.g. `eslint.config.mjs`

Then review and commit them. Each project adds its own rules from there.

Test: `tests/run.sh`. Requires `jq`.
