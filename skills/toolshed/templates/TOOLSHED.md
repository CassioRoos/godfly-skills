# Task toolsheds — the convention (v{{VERSION}})

This directory holds **task toolsheds**: durable working state for one coding
task (feature, investigation), one folder per task, under
**`docs/work/<slug>/`**. Any agent (Claude, Codex, Grok, …) and any human works
the same way. Skill name: **toolshed**. This file is the whole contract.

**Not the Workbench product** (Slack/highlights app + MCP). Different system.

## Reading order for a fresh session

1. `docs/work/<slug>/STATE.md` — thin resume surface.
2. Records: `decisions.md`, `questions.md`, `evidence.md`.
3. Optional `packet.md` only if a full ship packet was written.

## The law

The laws bind **the agent, not the owner**. An owner may **waive** a law: the
waiver is recorded in this file (see [Waivers](#waivers-owner-overrides)) as
`law N waived for <slug>: <reason, date>` — never in the mortal folder. The
agent states the consequence **once**, then complies. Silent erosion and
standoffs are both failures.

1. **Mortality.** Deleted in the closing PR. **Archive of record = the closing
   PR** (final packet/summary in its description) **plus at least one commit
   containing the folder that reached the default branch**. Bare "git history"
   is NOT enough: under squash-merge, a folder added and deleted inside one PR
   leaves **zero trace** on the main branch. `assert-close.sh` enforces the
   final-state preservation check: final contents must match a verified default
   ref, or use --pr-body-confirmed only after reading back the final records in
   the closing PR. An unknown default fails without that explicit attestation.
   Local refs are not live remote verification. *Why keeping it loses:* kept folders drift
   against the ADRs they duplicate, and superseded-but-decided records read as
   current guidance once they are permanent docs. Deliverables win by being the
   only copy.
2. **Slug identity; ticket optional.**
3. **Boundary rule.** Contract decisions promote the moment decided, **in the
   same PR as the change they govern** — and a decision made ahead of its
   implementation promotes with the PR that implements it. Promoted ADRs are
   immutable; partial supersession adds one pointer line to the amended ADR's
   **header**, never to its body.
4. **Survivors are evidence-self-sufficient** (or link PR/CI proof) and stamp
   `Toolshed: <repo>@<sha>, docs/work/<slug>/`.
5. **Evidence hygiene.** No payloads, customer IDs, or PII.
6. **Deliverable-shaped records.** Decisions are proto-ADRs (≥2 options +
   **flip condition**), so close is a transform, not a rewrite.
7. **Records are upsert-only.** Corrections are loud.
8. **One slug = one branch/worktree = one active agent.** No published
   convention safely handles two agents writing the same `STATE.md`
   concurrently. Parallel agents get parallel worktrees (usually parallel
   slugs); merge via git, not via hope.
9. **Branch-carried preferred.** Local-only (gitignored) is OK while testing —
   then promote survivors to PR/permanent docs before the machine is disposable.
   **Commit as you go**: an uncommitted toolshed protects nothing; it dies with
   the working tree.
10. **STATE is thin** (~120 lines for new toolsheds). No full packet inside STATE.
    Legacy mid-flight bloat: soft-warn until close; do not force rewrite mid-task.
11. **Understanding before proposal.** Template Understanding = not started.
    Share a concise evidence-backed orientation; do not pause already-authorized
    work unless a missing decision materially changes scope or approach.
12. **Freshness.** A toolshed nobody touched in 21+ days is presumed stale —
    resume it or close it (`stale-check.sh` reports; staleness is a smell, not
    a crime).

Evidence grades: **MEASURED** (I ran it, here is the command) · **CONFIRMED**
(two independent sources agree) · **REPORTED** (someone told us; unverified) ·
**UNRESOLVED** (tried, still unknown). Definitions live in each toolshed's
`evidence.md`.

**Never overclaim:** a record may not say it carries sources, scripts, or
harnesses unless they are in-tree and runnable — link what exists, name what
does not.

## Waivers (owner overrides)

Append one line per waiver; they survive the folders they were granted for.

_(none)_

## Session end vs full packet

- **Default session end:** update STATE Now/Next/Blocked + one session-log
  line; chat = verdict / blocker / next gate. No full packet.
- **Full packet:** only on explicit request, close ritual, or multi-repo ship
  gates — `packet.md` and/or chat, never inflate STATE.

## Composition

Toolshed is a **state shelf**, not the whole environment. Pair with morpheus,
mean-qa, monitoring runbooks, handoff, safe-ops, PR/CI as needed.

## Close-out

1. `assert-close.sh <slug>` — gates: final folder matches the verified default
   branch or explicit final PR-body attestation, no
   open questions, no `parked` question without a permanent home, no undecided
   (`proposed`) decisions, no template placeholders, clean tree.
2. Sweep unpromoted contract items.
3. Genre-map decisions → ADRs; contracts → specs; proposals → RFCs.
4. Stamp final toolshed SHA on deliverables.
5. **Closing PR description inlines the final load-bearing records**
   (decisions + key evidence) — it is the durable, squash-proof archive of
   the deleted folder. Do not rely on branch refs or GitHub PR refs
   surviving; only the PR body is contractual enough.
6. Delete `docs/work/<slug>/`. This convention file stays.
