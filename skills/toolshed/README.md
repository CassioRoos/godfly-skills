# toolshed — mortal task state under `docs/work/`

Durable working state for **one coding task**, path **`docs/work/<slug>/`**,
skill name **toolshed**. Deleted at close. Survivors = ADR / spec / RFC.
*"BS if we keep it; under the same feature it is gold."*

**Not the Workbench product** (a separate Slack/highlights + MCP app).

Convention version: **2.0**.

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
SKILL=~/.claude/skills/toolshed   # or ~/.codex or ~/.grok
sh $SKILL/scripts/seed.sh transfer-retries "goal"
sh $SKILL/scripts/assert-started.sh transfer-retries   # after orient
sh $SKILL/scripts/assert-state.sh transfer-retries
# legacy fat STATE:
sh $SKILL/scripts/assert-state.sh demo-local-serving --soft
```

## Rhythm

1. Orient → `assert-started` **must** pass (fail fast).  
2. Record as you go (D/Q/E and/or PR/CI).  
3. Session end = **thin** (`session-end.md`). Full packet = **opt-in**.  
4. Close → genre-map → delete folder.

## Composition

Toolshed is a **state shelf**. Godfly, mean-qa, deployment-monitor, handoff,
safe-ops, incident-validator, and **PR/CI** carry proof and review. Do not
build the whole environment around toolshed.

## Gitignore

While testing, `docs/work/` may be gitignored (machine-local). Seed warns.
Prefer PR/permanent docs for durable evidence until you track `docs/work/` again.

## Test

```sh
rm -rf /tmp/tst && mkdir /tmp/tst && cd /tmp/tst && git init -q && echo "# t" > CLAUDE.md
SKILL=/path/to/harness/claude/skills/toolshed
sh $SKILL/scripts/seed.sh foo "goal"
sh $SKILL/scripts/assert-started.sh foo; test $? -ne 0 && echo "gate OK"
```

## Legacy

Older "workbench" skill installs are replaced by **toolshed**. Path
`docs/work/` unchanged. Pre-existing bloated STATE: use `--soft`; do not force
mid-flight rewrite.
