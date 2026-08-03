---
name: toolshed
description: >
  Toolshed — durable, model-agnostic working state for ONE coding task
  (feature, fix, investigation) as docs/work/SLUG/ under docs/, DELETED at
  close. NOT the Workbench product/MCP (Slack highlights app). Seeds STATE +
  decisions/questions/evidence with grades and reproduction commands. Use for
  "start a toolshed", "seed the task", "/toolshed start|resume|session-end|close",
  or "where were we". Session end = thin STATE update. Full packet only when
  explicitly requested or on close/ship gates. Evidence may also live in PRs,
  CI, mean-qa, godfly, deployment-monitor — toolshed is a state shelf, not the
  whole environment. Pair with godfly, handoff, safe-ops, spec-adr-builder.
metadata:
  version: "2.0"
---

# Toolshed

Working state that survives sessions and models — but not the task.
Everything in `docs/work/<slug>/` dies at close. Survivors are formal genres
(ADR, spec, RFC) authored from deliverable-shaped records.
*"BS if we keep it; under the same feature it is gold."*

Path stays under **`docs/`**: `docs/work/<slug>/`. The skill name is **toolshed**.

## Name collision (read this)

| Name | What it is | Path / surface |
|---|---|---|
| **Toolshed** (this skill) | Mortal task state | `docs/work/<slug>/`, skill `toolshed`, `/toolshed` |
| **Workbench** (product) | Ops app: Slack/highlights/memory + MCP | separate product repo, `mcp_servers.workbench` |

If the user says "update the workbench" without a slug or `docs/work` path,
**ask which one** (product vs toolshed) before writing.

## The law (non-negotiable)

1. **Mortality.** Folder deleted in the closing PR. No archive directory.
   Git history is the archive when files are tracked (`git log`, SHA stamp on
   deliverables).
2. **Slug identity, ticket optional.** Never require a ticket to start.
3. **Boundary rule.** Contract-changing decisions promote to permanent home
   **the moment decided** — not at close. Toolshed links to them.
4. **Evidence self-sufficiency of survivors.** ADRs/specs inline dated, graded
   evidence + reproduction command when the evidence lives in toolshed.
   Evidence may also live in **PRs, CI, other skill artifacts** — toolshed
   does not own all proof; point at it.
5. **Evidence hygiene.** Aggregates, shapes, masked patterns: yes. Payloads,
   customer IDs, PII: never.
6. **Deliverable-shaped records.** Decisions are proto-ADRs (options +
   **flip condition**). Close is a transform, not a rewrite.
7. **Branch-carried preferred; local-only allowed while testing.** Default
   long-term: track `docs/work/` on the feature branch. **While the flow is
   under active change, repos may gitignore `docs/work/`** — then resume is
   machine-local; survivors **must** land in PR/permanent docs before the
   machine is disposable. `seed.sh` warns when ignored.
8. **STATE is a resume surface, not a novel.** Soft cap ~120 lines for
   **new** toolsheds. No full packet, no E-appendix, no W-registry dump inside
   STATE. Ledgers in D/Q/E; optional ship matrix in `packet.md`.
   **Legacy bloated STATE** (pre-toolshed / mid-flight): do not force a full
   rewrite — use `assert-state.sh --soft` (warn) until that task closes.
9. **Understanding before proposal.** Template Understanding = **not started**.
   `assert-started.sh` must pass before design/implementation.

Evidence grades: **MEASURED** · **CONFIRMED** · **REPORTED** · **UNRESOLVED**.

## Composition (not the whole environment)

Toolshed is **one shelf**. Do not stuff every activity into it.

| Need | Use |
|---|---|
| Task resume state | **toolshed** |
| Adversarial review | `godfly` |
| Settled cross-task claims | `docs/verdicts/` (godfly verdict graph) |
| ST/QA campaigns | `mean-qa` |
| Post-deploy watch | `deployment-monitor` |
| Incident paperwork | `incident-validator` |
| Risky ops | `safe-ops` |
| Off-repo note | `handoff` |
| ADR/spec at close | `spec-adr-builder` |
| Slack/memory product | **Workbench app** (not this skill) |
| Ship evidence of record | **PR + CI + permanent docs** (and/or E-NNN) |

## Flows

### Start — `/toolshed start <slug|TICKET-123> ["goal"]`

1. `bash <skill-dir>/scripts/seed.sh <slug> ["goal"]`
2. **Orient (mandatory):** fill Understanding (exists @ file:line, assumptions
   rated, unverified + how to verify). Present to owner before designing.
3. `bash <skill-dir>/scripts/assert-started.sh <slug>` — must pass.
   Until it passes, the toolshed is decor. Do not implement.

### Work (any session, any model)

- **Resume:** `assert-started.sh` then read `STATE.md` first. Do not re-derive
  answered records — append.
- `assert-state.sh <slug>` on new/thin trees; use `--soft` on known legacy
  bloated STATE (e.g. long-running EXP-class tasks).
- Tradeoffs → `decisions.md` when decided (+ commit hash).
- Functionality questions → `questions.md`; contracts → promote + mark
  `promoted`.
- Measurements → `evidence.md` **or** PR/CI/other skill artifact with a
  pointer from STATE/E-record.
- **Session end (default):** follow
  [`references/session-end.md`](references/session-end.md) only.
  Update Now/Next/Blocked + one session-log line. Chat = verdict / blocker /
  next gate. **Do not** emit a full packet.
- **Full packet:** only per
  [`references/full-packet.md`](references/full-packet.md) triggers
  (explicit ask, close ritual, multi-repo ship gates). Write to `packet.md`
  and/or chat — **never into STATE.md**.
- Records are upsert-only. Corrections are loud (History lines).

### Close — `/toolshed close <slug>`

1. `assert-started.sh`; `assert-state.sh` (soft if legacy).
2. Sweep unpromoted contract decisions (highest-risk failure mode). Also sweep
   settled cross-task claims that never got a verdict node — write them to
   `docs/verdicts/` (godfly's verdict graph) before the folder dies.
3. Genre-map → ADR / spec delta / RFC / runbook (`spec-adr-builder` if available).
   Inline load-bearing evidence that lives here; link PR/CI evidence otherwise.
4. Stamp deliverables: `Toolshed: <repo>@<sha>, docs/work/<slug>/`.
5. Optional: full packet for owner validation of multi-gate close.
6. Delete `docs/work/<slug>/` in the closing PR; leave `docs/work/WORKBENCH.md`
   (convention file name kept for path stability).
7. Present deliverable drafts for owner validation before push.

## STATE.md shape (hard for new toolsheds)

Allowed sections only:

1. Header (goal, ticket, opened, status one-liner)
2. Understanding
3. Now / Next / Blocked (short bullets — point at D/Q/E/PR IDs)
4. How to verify (runnable commands)
5. Session log (one line per session)

Everything else is a shape violation for new trees (`assert-state.sh`).

## Template map

| File | Role |
|---|---|
| `WORKBENCH.md` | convention once per repo (filename kept; content = toolshed law) |
| `STATE.md` | resume surface (thin) |
| `decisions.md` | proto-ADRs `D-NNN` |
| `questions.md` | `Q-NNN` upsert-only |
| `evidence.md` | `E-NNN` + reproduce |
| `packet.md` | optional full ship packet (not seeded) |

## Scripts

| Script | Job |
|---|---|
| `seed.sh` | create tree + pointers (v2.0) |
| `assert-started.sh` | Understanding gate (fail fast) |
| `assert-state.sh` | STATE shape / anti-novel (`--soft` for legacy) |

## What this skill is not

- **Not the Workbench product/MCP.**
- **Not an orchestrator** or the only place evidence may live.
- **Not a program playbook** (EXP-class permanent docs win when present).
- **Not documentation to keep** — write ADR/spec, delete the folder.
- **Not a mandatory full closeout engine** — session end is thin.
