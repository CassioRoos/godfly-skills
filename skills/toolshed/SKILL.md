---
name: toolshed
description: >
  Toolshed — durable, model-agnostic working state for ONE coding task
  (feature, investigation) as docs/work/SLUG/ under docs/, DELETED at close.
  Seeds STATE + decisions/questions/evidence with grades and reproduction
  commands. Use for
  "start a toolshed", "seed the task", "/toolshed start|resume|session-end|close",
  or "where were we". Session end = thin STATE update. Full packet only when
  explicitly requested or on close/ship gates. Evidence may also live in PRs,
  CI, mean-qa, morpheus, monitoring runbooks — toolshed is a state shelf, not the
  whole environment. Pair with morpheus, handoff, safe-ops, spec-adr-builder.
metadata:
  version: "2.1"
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
| **Workbench** (product) | Ops app: Slack/highlights/memory + MCP | `altpay/workbench`, `mcp_servers.workbench` |

If the user says "update the workbench" without a slug or `docs/work` path,
**ask which one** (product vs toolshed) before writing.

## The law (non-negotiable)

The laws bind **the agent, not the owner**. An owner may **waive** a law: the
waiver is recorded in `docs/work/TOOLSHED.md` (the survivor file — never the
mortal folder) as `law N waived for <slug>: <reason, date>`, and the agent
states the consequence **once**, then complies. Silent erosion and standoffs
are both failures.

1. **Mortality.** Folder deleted in the closing PR. No archive directory.
   **Archive of record = the closing PR** (final packet/summary in its
   description) **plus ≥1 commit containing the folder that reached the
   default branch**. Bare "git history" is not enough: under **squash-merge**
   a folder added and deleted inside one PR leaves **zero trace** on main.
   `assert-close.sh` enforces the merged-commit precondition; deliverables
   still stamp the final SHA.
   *Why keeping it loses:* kept folders drift against the ADRs they duplicate;
   STATE becomes a resume surface for a task nobody resumes; and
   superseded-but-decided records — correct in a ledger — read as current
   guidance once they are permanent docs. Deliverables win by being the only copy.
2. **Slug identity, ticket optional.** Never require a ticket to start.
3. **Boundary rule.** Contract-changing decisions promote to permanent home
   **the moment decided** — not at close, and **in the same PR as the change
   they govern** (after-the-fact ADRs are ratification theater — the
   named, documented way this practice dies). A decision made **ahead** of its
   implementation promotes **with the PR that implements it**: an ADR for a
   contract the code does not have is the mirror image of ratification theater.
   Toolshed links to them.
   Once promoted/accepted, an ADR is **immutable** — supersede, never edit.
   **Partial supersession:** the amending ADR adds one pointer line to the
   amended ADR's **header**; the amended body stays immutable.
4. **Evidence self-sufficiency of survivors.** ADRs/specs inline dated, graded
   evidence + reproduction command when the evidence lives in toolshed.
   Evidence may also live in **PRs, CI, other skill artifacts** — toolshed
   does not own all proof; point at it.
5. **Evidence hygiene.** Aggregates, shapes, masked patterns: yes. Payloads,
   customer IDs, PII: never.
6. **Deliverable-shaped records.** Decisions are proto-ADRs (options +
   **flip condition**). Close is a transform, not a rewrite.
7. **Records are upsert-only.** Corrections are loud (History lines) — never
   silent edits, never deletions; supersede instead.
8. **One slug = one branch/worktree = one active agent.** No published
   convention safely handles two agents writing the same `STATE.md`
   concurrently — don't be the experiment. Parallel agents get parallel
   worktrees (and usually parallel slugs); merge via git, not via hope.
9. **Branch-carried preferred; local-only allowed while testing.** Default
   long-term: track `docs/work/` on the feature branch **and commit as you
   go** — an uncommitted toolshed protects nothing; it dies with the working
   tree. **While the flow is under active change, repos may gitignore
   `docs/work/`** — then resume is machine-local; survivors **must** land in
   PR/permanent docs before the machine is disposable. `seed.sh` warns when
   ignored; `stale-check.sh` flags never-committed and abandoned toolsheds.
10. **STATE is a resume surface, not a novel.** Soft cap ~120 lines for
    **new** toolsheds. No full packet, no E-appendix, no W-registry dump inside
    STATE. Ledgers in D/Q/E; optional ship matrix in `packet.md`.
    **Legacy bloated STATE** (pre-toolshed / mid-flight): do not force a full
    rewrite — use `assert-state.sh --soft` (warn) until that task closes.
11. **Understanding before proposal.** Template Understanding = **not started**.
    `assert-started.sh` must pass before design/implementation.
12. **Freshness.** A toolshed untouched for 21+ days is presumed stale —
    resume it or close it. `stale-check.sh [--strict]` reports (CI-friendly).
    Staleness is a smell, not a crime; the response is triage, not archive.

When modifying close/seed helpers, run both `sh scripts/acceptance.sh` and
`python3 scripts/close-regressions.py` from the skill directory before and after.
These mutate only isolated fixtures, not the user's working repository.

Close checks require Python 3.9+. A parked question needs one explicit
`Home` or `Promoted` field: an existing repo-relative permanent file outside
**all** `docs/work/`, or a remote URL. Check that the destination contains the
final question and wake-up trigger; file existence alone does not prove this.
For remote homes, read back the destination before `--remote-homes-confirmed`;
the flag is an attestation, not an API check.

For ignored/local-only toolsheds, `--pr-body-confirmed` can clear the Git archive
gate only after reading back a PR body containing the **final local records**.
A promised future copy, stale snapshot or link into the folder is insufficient.
This does not authorize PR publication or deletion; reuse existing authorization
or request the missing scope. Tracked toolsheds still require their clean final
commit. Keep the source folder whenever preservation remains uncertain.

Evidence grades: **MEASURED** · **CONFIRMED** · **REPORTED** · **UNRESOLVED**.

## Composition (not the whole environment)

Toolshed is **one shelf**. Do not stuff every activity into it. Rows marked
*(Codex CLI)* ship only to `codex:skills` / `grok:skills` — on a Claude-only
install they are not there, so do the work inline rather than chasing them.

| Need | Use |
|---|---|
| Task resume state | **toolshed** |
| Adversarial review | `morpheus` |
| ST/QA campaigns | `mean-qa` *(Codex CLI)* |
| Post-deploy watch | Project monitoring runbook and live read-only evidence |
| Incident paperwork | `incident-validator` |
| Risky ops | `safe-ops` |
| Off-repo note | `handoff` *(Codex CLI)* |
| ADR/spec at close | `spec-adr-builder` *(Codex CLI)* |
| Slack/memory product | **Workbench app** (not this skill) |
| Ship evidence of record | **PR + CI + permanent docs** (and/or E-NNN) |

## Flows

### Start — `/toolshed start <slug|TICKET-123> ["goal"]`

1. `sh <skill-dir>/scripts/seed.sh <slug> ["goal"]`
2. **Orient (mandatory):** fill Understanding (exists @ file:line, assumptions
   rated, unverified + how to verify). Summarize it in a progress update;
   ask only when a missing decision changes the authorized scope or approach.
3. `sh <skill-dir>/scripts/assert-started.sh <slug>` — must pass.
   Until it passes, the toolshed is decor. Do not implement. The script only
   checks that the sentinel is gone and the section is non-empty; it cannot
   judge quality. Step 2 is an evidence check, not a new approval loop for
   work the user already authorized.

### Work (any session, any model)

- **One slug = one branch/worktree = one active agent** (law 8). Give a
  parallel agent a parallel worktree, and usually a parallel slug.
- **Resume:** read `STATE.md` first, recheck its current branch/build and next
  action, then run `assert-started.sh`. Reuse answered records; amend with a
  dated History line only when new evidence changes them.
- `assert-state.sh <slug>` on new/thin trees; use `--soft` on known legacy
  bloated STATE (e.g. long-running EXP-class tasks).
- Tradeoffs → `decisions.md` when decided (+ commit hash).
- Functionality questions → `questions.md`; contracts → promote + mark
  `promoted`.
- Measurements → `evidence.md` **or** PR/CI/other skill artifact with a
  pointer from STATE/E-record.
- **Session end (default):** follow
  [`references/session-end.md`](references/session-end.md) only.
  Update Now/Next/Blocked + one session-log line, and record the **verify**
  and **behavior changes shipped** one-liners. Chat = verdict / blocker /
  next gate. **Do not** emit a full packet.
- **Full packet:** only per
  [`references/full-packet.md`](references/full-packet.md) triggers
  (explicit ask, close ritual, multi-repo ship gates). Write to `packet.md`
  and/or chat — **never into STATE.md**.
- Records are upsert-only. Corrections are loud (History lines).
- **Never overclaim.** A record may not say it carries sources, scripts, or
  harnesses unless they are in-tree and runnable — link what exists, name
  what does not.

### Close — `/toolshed close <slug>`

1. `assert-close.sh <slug>` — **must pass**: the folder reached the **default
   branch** (final folder contents match it), no open questions, no `parked` question without
   a permanent home, no `proposed` decisions, no placeholders, clean tree. It
   also runs the started gate and `assert-state.sh --soft` (legacy bloat warns
   loudly). `--pr-body-confirmed` is the only escape from the merged-commit
   gate, and asserting it means you read back the actual PR body and it inlines
   the final records. Unknown default branch fails closed. The script checks
   local refs, not live GitHub or PR contents: pin/fetch the real default branch
   first. A flag is a human/agent attestation, not independent archive proof.
2. Sweep unpromoted contract decisions (highest-risk failure mode —
   `assert-close.sh` warns when decided records carry no promotion/ADR link).
3. Genre-map → ADR / spec delta / RFC / runbook (`spec-adr-builder` if available).
   Inline load-bearing evidence that lives here; link PR/CI evidence otherwise.
4. Stamp deliverables: `Toolshed: <repo>@<sha>, docs/work/<slug>/` — the SHA
   the evidence was **measured** at, plus "this commit" for the deliverable
   itself; amending a record to chase your own new SHA is forbidden.
5. **Inline the final load-bearing records (decisions + key evidence) into
   the closing PR description** — not just a summary. After squash-merge the
   branch's granular edit trail is unreachable from main, and GitHub's
   `refs/pull/N/head` persistence is empirical, not contractual. The PR body
   is the archive tier you can actually rely on.
6. Optional: full packet for owner validation of multi-gate close — routing
   lives in [`references/closeout-packet.md`](references/closeout-packet.md)
   (which is also where older "closeout packet" references land).
7. Delete `docs/work/<slug>/` in the closing PR; leave `docs/work/TOOLSHED.md`
   (`seed.sh` migrates legacy `WORKBENCH.md` files to the new name).
8. Review the final diff. Push or publish the closing PR only if authorized;
   reuse existing scoped authorization under `safe-ops`. Closing is not merging.

## STATE.md shape (hard for new toolsheds)

Allowed sections only:

1. Header (goal, ticket, opened, status, verified, behavior changes shipped —
   one line each)
2. Understanding
3. Now / Next / Blocked (short bullets — point at D/Q/E/PR IDs)
4. How to verify (runnable commands)
5. Session log (one line per session)

Everything else belongs in D/Q/E or `packet.md`, not in STATE.

`assert-state.sh` does **not** parse that section list — it spot-checks the
line count (soft cap 120) and the telltale dump patterns (full-packet headings,
`W-NNN` registries, `E-NNN` evidence appendices). Passing it is evidence
against bloat, not proof the shape is right; the list above is the contract.

## Template map

| File | Role |
|---|---|
| `TOOLSHED.md` | convention once per repo (legacy `WORKBENCH.md` auto-migrated by `seed.sh`) |
| `STATE.md` | resume surface (thin) |
| `decisions.md` | proto-ADRs `D-NNN` |
| `questions.md` | `Q-NNN` upsert-only |
| `evidence.md` | `E-NNN` + reproduce |
| `packet.md` | optional full ship packet (not seeded) |

## Scripts

| Script | Job |
|---|---|
| `seed.sh` | create tree + pointers; migrate legacy `WORKBENCH.md` (v2.1) |
| `assert-started.sh` | Understanding gate (fail fast) |
| `assert-state.sh` | STATE shape / anti-novel (`--soft` for legacy) |
| `assert-close.sh` | close gate: folder reached the default branch, no open Q / homeless parked Q / proposed D, clean tree; runs started + state (`--soft`) gates (`--pr-body-confirmed` waives the merge check) |
| `stale-check.sh` | freshness report: stale / never-committed toolsheds (`--strict` for CI) |
| `acceptance.sh` | self-test: walks seed → gates → close → hostile input in a throwaway repo |

## What this skill is not

- **Not for work that ends this session.** Do **not** seed for a task that will
  plausibly finish this session **and** produces no contract-changing decision
  — use inline notes / the task list. Seed at the **first real resume** or the
  **first contract decision**, whichever comes first.
- **Not the Workbench product/MCP.**
- **Not an orchestrator** or the only place evidence may live.
- **Not a program playbook** (EXP-class permanent docs win when present).
- **Not documentation to keep** — write ADR/spec, delete the folder.
- **Not a mandatory full closeout engine** — session end is thin.
