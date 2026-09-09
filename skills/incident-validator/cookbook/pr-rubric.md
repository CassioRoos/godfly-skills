# PR Rubric: Production-Fix PR

A production fix PR must be reviewable without reconstructing the incident from
Slack. Validate the description AND the diff -- the description can claim anything;
the diff is what ships.

Decision target: `pr-merge` (terminal verdict `MERGEABLE` / `BLOCKED: <gates>`) --
unless the user is asking whether the INCIDENT can close, which pulls in
`cookbook/closure-gates.md` as well.

## Always Fetch Live State First

Via `gh`:

```bash
gh pr view <n> --repo <org/repo> --json title,body,state,headRefOid,files,reviews,statusCheckRollup
gh pr diff <n> --repo <org/repo>
```

**`pr-body-only` ingestion** (no `gh`, or only pasted text): do not refuse, and do
not pretend. Grade the description gates, mark every live-state and diff gate
`UNKNOWN` with the reason `pr-body-only ingestion`, and say in one line that
`MERGEABLE` is unavailable this run. A missing tool never blocks producing a
VERDICT; it does block a positive one. What gets printed to carry that verdict --
the full matrix, or the short passenger shape -- is SKILL.md's call by mode, never
this rubric's: a rubric decides what passes, not what is on the page.

## Gates -- Description

| Gate | What passes |
|---|---|
| `summary` | What broke and what this PR changes, in plain language. |
| `production-evidence` | Links: logs, metrics, traces, dashboards, incident threads, Linear, screenshots, before/after where possible. |
| `root-cause` | The exact broken assumption or failure mode. |
| `mitigation-vs-root-cause` | Explicit status. If not fully fixed: linked follow-up with owner and target date. |
| `impact-analysis` | Customers, window, affected data/workflows, repair/backfill needs. |
| `recurrence-check` | Where else the pattern exists, what was checked, follow-ups. |
| `fix-description` | What changed and why it addresses the root cause, stated in the PR body itself -- not only inferable from the diff. |
| `tests-and-e2e` | Commands, test names, before/after behavior -- and the before/after must be demonstrated, not narrated: pass at head plus failure at base/reverted/mutated, per the evidence ladder's "Evidence Must Be Capable of Failing". E2E is MANDATORY for production issues -- see exception gate below. |
| `e2e-exception` | Only if E2E is absent: why it cannot be added now + temporary validation + linked follow-up + owner + deadline + engineering-lead approval. All six, or the gate fails. The approval must be a LINKED artifact (Slack message, Linear comment, PR review) naming this exception and this PR -- "our lead approved it" in prose is `claimed` and fails. An approved exception can make the PR `MERGEABLE`; it never makes the incident closeable. |
| `detection-improvement` | Improvement, or explicit "no" with reasoning. |
| `rollout-plan` | How this deploys. |
| `rollback-plan` | How to back out. If rollback is unclear or risky, that is itself a full-postmortem trigger. |
| `monitoring-window` | Duration + owner + signals watched, defined BEFORE deploy. Window must match the failure mode: an hourly cron fix needs at least one scheduled cycle; a retry/reaper fix needs the retry path to actually run. |
| `residual-risk` | What is still not solved. |

## Gates -- Diff (semantic)

For diff semantics -- surviving paths, entry-point coverage, blast radius across
registered callers -- use Morpheus for the evidence-backed review and read
[fix-boundary-review.md](fix-boundary-review.md) for the incident-specific
boundary checks. Consume that evidence here; this rubric grades compliance
of the ARTIFACT, not a second independent semantic review.

What stays here are the gates the standard itself demands of the artifact:

| Gate | What passes |
|---|---|
| `failure-mode-eliminated` | The diff actually eliminates the failure mode named in the root cause, and the mechanism is labelled honestly: `offender-fix` / `invariant-enforced` / `contained` / `mitigation`. Locators are typed, not assumed to be code -- code lines, config revision, infrastructure plan, data migration, dependency bump, or process control. Compare the claimed root-cause locator against what the diff (or the config/infra change) touches. `mitigation` is not a failure: it is a truthful label that pulls in `mitigation-vs-root-cause` and its five-part follow-up. |
| `test-reaches-boundary` | At least one test drives the real boundary: published message, DB query shape, queue fanout, state transition. A helper-only unit test fails this gate even if coverage is green. |
| `deploy-verified` | For merged PRs, and only when the decision target needs it: the running production version includes this change (image tag / git SHA / Datadog version tag), plus evidence the affected path ran on it. Merged is not deployed. |
