# Closure Gates

Run these in gate mode on top of the artifact rubric -- ANY artifact type. They
come from the standard's Closure Standard, plus the artifact-existence checks that
make "gate incident closure" actually true: the fastest way to a green matrix must
never be "don't submit the artifact that would fail."

## Artifact Existence -- check FIRST

| Gate | What passes |
|---|---|
| `postmortem-exists-if-required` | If any full-postmortem trigger fired, or severity is P0 (or P1 without an explicit, LINKED engineering-lead waiver), a postmortem for this incident exists in the team's postmortem archive. Verify by glob/tracker search, not by asking. FAIL otherwise -- regardless of which artifact was submitted for validation. |
| `handover-exists-if-required` | If the standard's handover conditions apply (P0/P1, causal chain crosses more than one service, fix ships under a different owner/PR/time, or a dangerous shortcut was documented), an investigation handover exists and is linked from Linear. FAIL otherwise. |
| `linear-investigation-exists` | The tracked investigation ticket exists in Linear. Verify live when Linear is available. |

A CLOSEABLE verdict asserts the INCIDENT meets the standard, not just the one
document in front of you. If you cannot check for the other artifacts (no docs
checkout, no Linear), the existence gates are `unknown` -- and unknown blocks
CLOSEABLE.

## Closure Standard Gates

| Gate | What passes |
|---|---|
| `post-deploy-validation` | Passed, with evidence. |
| `monitoring-result-recorded` | Window completed and the actual result written down. A window without a recorded result is an open window. |
| `comms-loop-closed` | If customers/stakeholders were affected: contacted, repair/refund/backfill status communicated, loop explicitly closed. |
| `repair-complete` | Backfill/replay/refund/manual cleanup done, if applicable, with evidence. |
| `action-items-filed` | Shipped, or filed in Linear with owners and target dates -- verify the tickets exist, do not take a table's word. |
| `e2e-exists` | E2E coverage exists, or an engineering-lead-approved exception (LINKED approval) with the follow-up still open. |
| `staged-closure` | Partial rollouts (per-partner flags) close in stages; full closure only when on-by-default or the rollout decision is documented. |
