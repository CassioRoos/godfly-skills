# Task toolsheds — the convention (v{{VERSION}})

This directory holds **task toolsheds**: durable working state for one coding
task (feature, ad-hoc fix, investigation), one folder per task, under
**`docs/work/<slug>/`**. Any agent (Claude, Codex, Grok, …) and any human works
the same way. Skill name: **toolshed**. This file is the whole contract.

**Not the Workbench product** (Slack/highlights app + MCP). Different system.

## Reading order for a fresh session

1. `docs/work/<slug>/STATE.md` — thin resume surface.
2. Records: `decisions.md`, `questions.md`, `evidence.md`.
3. Optional `packet.md` only if a full ship packet was written.

## The law

1. **Mortality.** Deleted in the closing PR. Git history is the archive when tracked.
2. **Slug identity; ticket optional.**
3. **Boundary rule.** Contract decisions promote the moment decided.
4. **Survivors are evidence-self-sufficient** (or link PR/CI proof) and stamp
   `Toolshed: <repo>@<sha>, docs/work/<slug>/`.
5. **Evidence hygiene.** No payloads, customer IDs, or PII.
6. **Records are upsert-only.** Corrections are loud.
7. **Branch-carried preferred.** Local-only (gitignored) is OK while testing —
   then promote survivors to PR/permanent docs before the machine is disposable.
8. **STATE is thin** (~120 lines for new toolsheds). No full packet inside STATE.
   Legacy mid-flight bloat: soft-warn until close; do not force rewrite mid-task.
9. **Understanding before proposal.** Template Understanding = not started.

Evidence grades: **MEASURED** · **CONFIRMED** · **REPORTED** · **UNRESOLVED**.

## Session end vs full packet

- **Default session end:** update STATE Now/Next/Blocked + one session-log
  line; chat = verdict / blocker / next gate. No full packet.
- **Full packet:** only on explicit request, close ritual, or multi-repo ship
  gates — `packet.md` and/or chat, never inflate STATE.

## Composition

Toolshed is a **state shelf**, not the whole environment. Pair with godfly,
mean-qa, deployment-monitor, handoff, safe-ops, PR/CI as needed.

## Close-out

1. Sweep unpromoted contract items.
2. Genre-map decisions → ADRs; contracts → specs; proposals → RFCs.
3. Stamp final toolshed SHA on deliverables.
4. Delete `docs/work/<slug>/`. This convention file stays.
