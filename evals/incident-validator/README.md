# incident-validator evals — gauntlet IV1/IV2, 2026-08-12

Why this skill emitted 30-row gate matrices for plain "what is going on here"
questions, what fixed it, and what is still unproven.

## The defect

The full-matrix mandate was **not** in `SKILL.md` alone. Every rubric carried its own,
independently, and the cookbook won because it is read later and is more specific:

- `interview-flow.md` `## No Author Present` — "The matrix plus the grouped questions
  ARE the deliverable ... Never refuse to produce a matrix". Fires in exactly the
  validating-someone-else's-artifact case.
- `interview-flow.md` — "Never shrink the canonical matrix."
- `pr-rubric.md` — "A missing tool never blocks producing the matrix."
- `closure-gates.md` — closure gates "appear in the matrix" even for non-close targets
  (this produced the *second* table).
- `handover-rubric.md` — `quality:*` rows go "in the matrix"; `trigger-sweep` expands
  to one row per trigger.

Mandated rows per path: **handover 37, pr 27, postmortem 29.**

Second, separate defect: `interview-flow.md` defined an 8-level consequence priority
order scoped to "**interrogate** in this order" — interactive only. The batch/no-author
path said "emit every group at once", so the ranking was computed and discarded. That
is the mechanical cause of unordered action lists with paperwork ranked first.

## The fix (v1.2 → v1.6)

Passenger mode: when no decision target was requested, no matrix — terminal line,
≤5 failing gates in consequence order, ≤3 actions with done-conditions. Every
shape mandate removed from the cookbook; `SKILL.md` alone owns output shape, and
says so explicitly.

## Results — Codex arms, blind, shuffled labels

Handover path, four independent judgings:

| Version | Scores | Detection | Actionability | Presentability |
|---|---|---|---|---|
| v1.2 | 16, 16, 19 | 11-12/15 | **2/10** | **0/10** |
| control (no skill) | 25, 23, 26 | 5-6/15 | 8/10 | 10/10 |
| v1.3 | 34, 34 | 11/15 | 10/10 | 8/10 |
| **v1.4** | **38/40** | 13/15 | 10/10 | 10/10 |

Detection did not regress when output shrank, and beat the no-skill control by +7.
Zero fabrication in every capability-matched arm.

Table rows by path, v1.2 → fixed:

| Path | v1.2 | fixed | containment |
|---|---|---|---|
| handover | 32 | 0 | clean |
| pr | 29 / 38 / 30 | 0 | 2 of 3 runs clean |
| postmortem | 39 | 0 | fully clean (synthetic fixture) |

Cross-model: v1.2 emitted 42 rows on Claude, 32 on Codex; fixed versions 0 on both.

## Rules harvested into the skill

1. Gate slugs and mode names must not leak to the reader in passenger mode — the only
   axis where the fix initially lost to the control.
2. Never list a gate as open that the artifact satisfies.
3. `UNKNOWN` means absent evidence, never merely unverified evidence.
4. `recurrence-check`: per-service RESULTS are `documented` and pass; only a bare
   assertion is `claimed`. It is a protected gate, so before this it was structurally
   unpassable and was over-failed every run — a judgment rule in `SKILL.md` could never
   win against that mechanic.

## What is NOT proven

- **PR-path grading.** `rubric-pr-VOID.md` is kept as a warning, not a tool. Its
  fixture described a real service present on disk, so arms silently cross-checked it
  against real code and the judge scored TRUE findings as fabrications. Shape results
  on that path survive (structural); detection and fabrication numbers do not. A
  synthetic replacement is still needed.
- **Claude and Grok scoring.** Claude arms ran with tool access while Codex arms were
  sandboxed — not capability-matched, so their fabrication counts were artifacts.
  Grok's CLI was logged out. Only row counts transfer cross-model.
- **One fixture per path, one judge model family.** The handover result reproduced four
  times, but "38/40" means "against this handoff", not "this skill is good".
- Passenger mode reports `Passing: N gates` without naming them, so a specific gate
  cannot be verified as passing — only as not-flagged.

## Reproducing

Fixtures must be **synthetic** — see `gauntlet` Law 3. Verify containment before
judging:

```bash
grep -coE 'Documents/projects/[a-z]+/(svc-|docs)' <arm-output>   # must be 0
grep -coE '\b[0-9a-f]{40}\b' <arm-output>                       # must be 0
```

The handover fixture was a real internal investigation handoff and is deliberately
not committed here. `postmortem-fixture-synthetic.md` is safe to reuse and its
containment was pre-verified.
