# PR Rubric: Production-Fix PR

A production fix PR must be reviewable without reconstructing the incident from
Slack. Validate the description AND the diff -- the description can claim anything;
the diff is what ships.

## Always Fetch Live State First

Never validate from a pasted summary. Via `gh`:

```bash
gh pr view <n> --repo <org/repo> --json title,body,state,headRefOid,files,reviews,statusCheckRollup
gh pr diff <n> --repo <org/repo>
```

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
| `tests-and-e2e` | Commands, test names, before/after behavior. E2E is MANDATORY for production issues -- see exception gate below. |
| `e2e-exception` | Only if E2E is absent: why it cannot be added now + temporary validation + linked follow-up + owner + deadline + engineering-lead approval. All six, or the gate fails. The approval must be a LINKED artifact (Slack message, Linear comment, PR review) -- "our lead approved it" in prose is `claimed` and fails. |
| `detection-improvement` | Improvement, or explicit "no" with reasoning. |
| `rollout-plan` | How this deploys. |
| `rollback-plan` | How to back out. If rollback is unclear or risky, that is itself a full-postmortem trigger. |
| `monitoring-window` | Duration + owner + signals watched, defined BEFORE deploy. Window must match the failure mode: an hourly cron fix needs at least one scheduled cycle; a retry/reaper fix needs the retry path to actually run. |
| `residual-risk` | What is still not solved. |

## Gates -- Diff (semantic)

| Gate | What passes |
|---|---|
| `offender-changed` | The diff modifies the actual offender (the query/function/queue/state machine named in the root cause) -- not just gates entry to it, not a neighboring path. Compare claimed root-cause location against `gh pr diff` file paths. Label honestly: fix / gate-only / neighbor. |
| `surviving-paths` | Unmodified paths that can still reach the offender are listed or ruled out: other integrations, REST/admin/shadow entrypoints, retry/fanout paths. |
| `blast-radius` | For shared publishers/workers/registries: behavior verified for every registered caller, not just the incident's integration. |
| `test-reaches-boundary` | At least one test drives the real boundary: published message, DB query shape, queue fanout, state transition. A helper-only unit test fails this gate even if coverage is green. |
| `deploy-verified` | For merged PRs in gate mode: the running production version includes this change (image tag / git SHA / Datadog version tag). Merged is not deployed. |

## Verdict Matrix (gate mode)

```markdown
| Claim | Evidence | Verdict |
|---|---|---|
| Original offender changed? | file/function/query | yes/no/partial |
| All entry paths gated? | paths searched | yes/no/unknown |
| Full/unbounded path remains? | file/function | yes/no |
| Cross-integration behavior safe? | callers checked | yes/no/unknown |
| Regression reaches real boundary? | test/log/metric | yes/no/partial |
| Mitigation or fix? | reason | mitigation/fix/partial |
```
