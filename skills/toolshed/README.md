# toolshed — mortal task state under `docs/work/`

Durable working state for **one coding task**, path **`docs/work/<slug>/`**,
skill name **toolshed**. Deleted at close. Survivors = ADR / spec / RFC.
*"BS if we keep it; under the same feature it is gold."*

**Not the Workbench product** (`altpay/workbench` Slack/highlights + MCP).
The per-repo convention file is `docs/work/TOOLSHED.md` (legacy `WORKBENCH.md`
is auto-migrated by `seed.sh`).

Convention version: **2.1**.

**Archive of record:** the closing PR (final packet in its description) plus
≥1 commit containing the folder that reached the default branch. Under
**squash-merge**, a folder added and deleted inside one PR leaves zero trace on
main — so `assert-close.sh` requires a commit reachable from the default branch,
not merely a local one. Final contents must match that default ref; an old
snapshot does not preserve later records. Unknown default refs fail closed.
The caller must refresh/pin the default ref; the script cannot verify live PR
contents. Closing before the merge is normal: pass
`--pr-body-confirmed` once you have checked that the PR body inlines the final
records, because at that point it is the only archive.

**Why not Claude Code's native Tasks?** Tasks are durable but Claude-only,
live outside the repo, and are invisible to PR review. A toolshed is plain
files in the diff: model-agnostic (Codex, Grok, a human with `cat`), reviewable,
and it carries graded evidence + proto-ADR decisions, which a todo list does not.

## Use

**Claude** (after install):

```
/toolshed start transfer-retries "make transfer retries idempotent"
/toolshed resume
/toolshed session-end transfer-retries
/toolshed close transfer-retries
```

**Codex / Grok:**

```
"use the toolshed skill — start toolshed for transfer retries"
"assert-started then resume docs/work/transfer-retries"
"session-end only — no full packet"
```

**Shell:**

```sh
SKILL=~/.claude/skills/toolshed   # or ~/.codex/skills/toolshed, ~/.grok/skills/toolshed
sh $SKILL/scripts/seed.sh transfer-retries "goal"
sh $SKILL/scripts/assert-started.sh transfer-retries   # after orient
sh $SKILL/scripts/assert-state.sh transfer-retries
sh $SKILL/scripts/assert-close.sh transfer-retries     # before deleting
sh $SKILL/scripts/stale-check.sh --days 21             # add --strict in CI
# legacy fat STATE:
sh $SKILL/scripts/assert-state.sh exp-1842-local-serving --soft
```

## Rhythm

1. Orient → `assert-started` **must** pass (fail fast).  
2. Record as you go (D/Q/E and/or PR/CI) — **commit as you go** too; an
   uncommitted toolshed dies with the working tree.
3. Session end = **thin** (`session-end.md`). Full packet = **opt-in**.  
4. Close → `assert-close` **must** pass → genre-map → final packet into the
   closing PR description → delete folder.

## Composition

Toolshed is a **state shelf**. Morpheus, mean-qa, monitoring runbooks, handoff,
safe-ops, incident-validator, and **PR/CI** carry proof and review. Do not
build the whole environment around toolshed.

## Enforcement (optional but recommended)

Every file-based agent-state system in the wild fails the same way: nobody
maintains the files ("instruction fade" — documented for Cline Memory Bank,
beads, CLAUDE.md itself). Enforcement comes in two tiers.

### Tier 1 — model-agnostic (the tier of record)

Plain POSIX + git; identical for Claude, Codex, Grok, and humans:

- **Gate scripts** — `assert-started.sh` / `assert-state.sh` /
  `assert-close.sh` run the same everywhere. These are the contract.
- **CI freshness check** (scheduled, not per-PR — mid-task folders on main
  are legitimate between PRs of a multi-PR task):

```yaml
# .github/workflows/toolshed-stale.yml
on: {schedule: [{cron: "0 9 * * 1"}], workflow_dispatch: {}}
jobs:
  stale:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: {fetch-depth: 0}
      # vendor stale-check.sh into the repo (e.g. scripts/toolshed/) —
      # CI has no agent home dirs; the script is plain POSIX, dependency-free
      - run: sh scripts/toolshed/stale-check.sh --days 21 --strict
```

- **Health signals** org-wide: promotion rate (slugs closing with zero
  promoted decisions = records aren't honest) and ADR supersession rate
  (0%/year = decisions aren't recorded where they can be challenged).

### Tier 2 — per-runtime hooks (optional extras)

Session-end nudges; support varies by runtime, so never make these the only
enforcement:

| Runtime | Mechanism | Status |
|---|---|---|
| Claude Code | `Stop` hook (block + reason; guard `stop_hook_active`) | supported, documented |
| Codex CLI | `Stop` event exists (~5 hook events) | reported, single-source — verify before relying |
| Grok CLI | no hook mechanism found | unverified — rely on Tier 1 |

**Claude Code example** — refuse to end a work turn that touched code but not
the toolshed (pattern proven by Harmonist's session-handoff gate). Add to the
repo's `.claude/settings.json` (needs owner sign-off):

```json
{"hooks": {"Stop": [{"hooks": [{"type": "command",
  "command": "sh .claude/hooks/toolshed-stop-gate.sh"}]}]}}
```

where the script blocks (exit 2) when `git status --porcelain docs/work/`
shows a seeded toolshed whose STATE.md wasn't touched this session. Honest
limit: Stop hooks fire only on voluntary turn end — a killed process skips
them. They raise the cost of forgetting; they don't make it impossible.

### Rules-file budgets (why the pointer block stays tiny)

The seeded CLAUDE.md/AGENTS.md pointer is ~12 lines by design. Hard limits by
runtime: Grok caps each rules file at **10,000 chars** (truncates with a
warning; reads both `AGENTS.md` and `CLAUDE.md`) — observed with Grok CLI
0.2.111, not a documented contract; Codex caps AGENTS.md at **32 KiB** (silent
truncation). Never inline toolshed schemas into root rules files — point, don't
paste.

## Gitignore

While testing, `docs/work/` may be gitignored (machine-local). Seed warns.
Prefer PR/permanent docs for durable evidence until you track `docs/work/` again.

## Test

`acceptance.sh` builds its own throwaway git repo and walks the whole
lifecycle — seed, orient gate, shape gate, close gate (open question, proposed
decision, placeholder, dirty tree), promotion-link warning, workbench-era
migration, and hostile slugs. One `PASS`/`FAIL` line per step; non-zero exit
if any step fails.

```sh
sh /path/to/harness/claude/skills/toolshed/scripts/acceptance.sh
```

It pins two regressions specifically: a **pristine** seed must be able to
close (the templates carry `- **Status:** open`/`proposed` inside `<!-- -->`
skeletons, which the close gate must not read as live records), and a filled
Understanding must pass the orient gate (the template's instructional
blockquote is not a placeholder).

## Legacy

Older "workbench" skill installs are replaced by **toolshed**. Path
`docs/work/` unchanged. Pre-existing bloated STATE: use `--soft`; do not force
mid-flight rewrite.
