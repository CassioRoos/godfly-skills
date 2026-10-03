# Closure Gates

These decide ONE thing: whether the INCIDENT can close. They are mandatory for the
`incident-close` decision target, whatever artifact type was submitted. For
`pr-merge` and `postmortem-publish` they are still GRADED, but reported as a single
summary line -- "closure gates: NOT_APPLICABLE for this target (informational
dependency for incident-close); N will need evidence before the incident can close"
-- not enumerated as ten `NOT_APPLICABLE` rows. Enumerate them only when the target
IS `incident-close`, or when the reader asks. The author still sees what is coming;
they never block those decisions. Do not block an unmerged PR on post-deploy evidence
that cannot exist yet.

They come from the standard's Closure Standard, plus the artifact-existence checks
that make "gate incident closure" actually true: the fastest way to a green matrix
must never be "don't submit the artifact that would fail."

## Artifact Existence -- check FIRST

| Gate | What passes |
|---|---|
| `postmortem-exists-if-required` | If any full-postmortem trigger fired, or severity is P0 (or P1 without an explicit, LINKED engineering-lead waiver), a postmortem for this incident exists under `engineering/post-mortem/` in the docs repo. Verify by glob/Linear search, not by asking. FAIL otherwise -- regardless of which artifact was submitted for validation. |
| `handover-exists-if-required` | If the standard's handover conditions apply (P0/P1, causal chain crosses more than one service, fix ships under a different owner/PR/time, or a dangerous shortcut was documented), an investigation handover exists and is linked from Linear. FAIL otherwise -- but ADVISORY, non-blocking, whenever the resolved standard has no Investigation Handover Standard section (see SKILL.md, "Does the resolved standard contain what the rubrics enforce?"). |
| `linear-investigation-exists` | The tracked investigation ticket exists in Linear. Verify live when Linear is available. |

A CLOSEABLE verdict asserts the INCIDENT meets the standard, not just the one
document in front of you. If you cannot check for the other artifacts (no docs
checkout, no Linear), the existence gates are `unknown` -- and unknown blocks
CLOSEABLE.

## Closure Standard Gates

| Gate | What passes |
|---|---|
| `post-deploy-validation` | Passed, with evidence that could have failed: deployment identity PLUS proof the affected path ran after it PLUS the error signature queried over pre/post windows. A green health check is not post-deploy validation. |
| `monitoring-result-recorded` | Window completed and the actual result written down. A window without a recorded result is an open window. |
| `comms-loop-closed` | If customers/stakeholders were affected: contacted, repair/refund/backfill status communicated, loop explicitly closed. |
| `repair-complete` | Backfill/replay/refund/manual cleanup done, if applicable, with the reconciliation the evidence ladder requires: expected affected set, attempted/succeeded/failed/skipped counts, and a positive-control record. "Replay ran, no errors" is an empty replay's output too. |
| `action-items-filed` | Shipped, or filed in Linear with owners and target dates -- verify the tickets exist, do not take a table's word. |
| `e2e-exists` | E2E coverage exists AND passes. An approved exception does NOT satisfy this gate: it can make the PR mergeable, but the standard says the production issue cannot close until the E2E follow-up is completed. Exception approved + follow-up still open = `BLOCKED: e2e-exists` for `incident-close`. |
| `staged-closure` | Partial rollouts (per-partner flags) close in stages; full closure only when on-by-default or the rollout decision is documented. |

The standard contradicts itself on E2E: its Closure Standard bullet allows closure
with an approved exception and an open follow-up, while its Mandatory E2E Coverage
section says "the production issue cannot be closed until the E2E follow-up is
completed." The specific rule wins -- the exception unblocks the merge, not the
closure. Name the ambiguity in the output and send the author to the docs repo to fix
it rather than arguing it with the validator.
