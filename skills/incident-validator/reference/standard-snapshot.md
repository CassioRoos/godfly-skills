<!-- SNAPSHOT of engineering/foundations/guides/production-issue-resolution-standard.md from the docs repo.
     Snapshot date: 2026-07-13. LAST-RESORT fallback only -- always prefer the live version.
     Refresh this file whenever the harness is released. -->

---
description: Service-agnostic standard for investigating, fixing, validating, and documenting production issues.
---

# Production Issue Resolution Standard

This standard applies to every production issue across every service.

The goal is not bureaucracy. The goal is to stop fixing production in the dark. A production fix is not complete because the code changed. It is complete when we can show what happened, who was affected, why it happened, how the fix prevents recurrence, how E2E coverage proves the production flow, and what we monitored after deployment.

## Operating Outcomes

This standard is anchored on four outcomes:

* We do not lose customer trust silently. Impact is measured, documented, and communicated when needed.
* We do not fix the same bug twice. Root cause versus mitigation is explicit, and the pattern is checked elsewhere.
* We detect the next one faster. Every incident produces a detection improvement or a deliberate written "no" with reasoning.
* A future engineer can understand what happened. Evidence is written down, not remembered.

## Required Outcomes

Every production issue must leave behind:

* A tracked investigation in Linear.
* Production evidence: logs, metrics, traces, dashboards, screenshots, incident links, customer reports, or database evidence.
* A clear root cause in the code, infrastructure, data, configuration, dependency, or process.
* An explicit mitigation versus root cause statement.
* Impact analysis.
* A recurrence check across related services, code paths, jobs, integrations, or infrastructure.
* Tests covering the root cause.
* Mandatory E2E coverage proving the affected production flow.
* A detection improvement, or a deliberate written "no" explaining why one is not worth it.
* A PR description that is easy to review and contains hard evidence.
* A deployment plan with rollback notes.
* A post-deploy monitoring window with an owner, duration, watched signals, and result.
* A postmortem for major incidents, using the Five W's.

## Severity and Documentation Depth

| Severity | Required documentation |
| --- | --- |
| P0 | Full postmortem, full PR evidence, mandatory E2E, deployment validation, monitoring window, follow-up ownership |
| P1 | Full postmortem unless explicitly waived by the engineering lead, full PR evidence, mandatory E2E, deployment validation, monitoring window |
| P2 | Lightweight RCA, full PR evidence, mandatory E2E, deployment validation, monitoring window |
| P3 | Lightweight RCA or Linear summary, PR evidence, mandatory E2E, deployment validation |

Documentation can be lighter for smaller issues. Validation cannot be lighter. "Small issue" is not a permission slip to skip evidence, impact analysis, E2E, or post-deploy monitoring.

## Full Postmortem Triggers

A full postmortem is required when any of these are true:

* Customer money or data was corrupted, miscounted, duplicated, or lost.
* More than one partner, tenant, or customer account was affected.
* A core flow was degraded for more than 15 minutes.
* The issue was silent: no alert fired, and it was discovered by a customer, support, manual inspection, or accident.
* The issue repeats an incident class we have already postmortemed.
* The fix requires backfill, replay, refund, data repair, manual cleanup, or customer communication.
* The rollback path was unclear, risky, or unavailable.

Anything below that bar can use a lightweight RCA, but the required outcomes still apply.

## Investigation Standard

Before implementing the fix, capture the investigation in Linear or the postmortem draft.

Include:

* Issue title and severity.
* Affected service or services.
* First seen time and current status.
* Detection source: alert, customer report, support ticket, manual inspection, dashboard, or deploy validation.
* Suspected deploy, PR, configuration change, upstream dependency, data condition, or scheduled job.
* Evidence links:
  * Datadog logs.
  * Metrics and dashboards.
  * APM traces.
  * Incident threads.
  * Linear tickets.
  * Screenshots or prints.
  * Database query output when relevant.
* Current hypothesis and what evidence supports it.
* Unknowns that still need validation.

Do not treat a theory as root cause until it explains both the production symptom and the code or system behavior.

## Investigation Handover Standard

When an investigation is deep, crosses services, or transfers ownership before the full fix ships, produce an investigation handover report. The handover is the artifact that lets an engineer who was not in the trenches pick up the incident and finish it.

A handover is required when any of these are true:

* The issue is P0 or P1.
* The causal chain crosses more than one service.
* The fix will ship in a different PR, by a different owner, or at a later time than the investigation.
* The investigation found a tempting-but-wrong shortcut that a future engineer could take.

The handover must include:

* Severity classification and an explicit check of the full postmortem triggers.
* Detection source.
* Incident window measured from when the failure started, not when it was noticed. A recurring job failure's window opens at the regressing change, not at the observed burst.
* The full causal chain, traced to the originating producer, not just the service where the failure surfaced. Every step needs both a code reference and runtime evidence.
* Mitigation versus root cause status, with the follow-up ticket, owner, target date, and risk-if-delayed when the root cause is not fully fixed.
* Impact analysis per this standard, focused on downstream, customer-facing impact. An internal error count is a symptom, not impact.
* Recurrence check across sibling services and integrations.
* Tests that would have failed before the fix, including a negative regression test for any documented dangerous shortcut.
* Detection improvement or an explicit "no" with reasoning.
* Linear tracking.
* Unknowns written as unknowns, each with what would be needed to know.

Quality bar, beyond the required sections:

* Every claim is paired with evidence: a code link, a log line, a measured count.
* Dangerous non-fixes are documented with why they are wrong, so the knowledge does not die with the investigator.
* Key findings carry a plain-language interpretation for readers who were not in the incident.
* "Merged" and "deployed" are never conflated. Say which one was verified.

## Mitigation vs Root Cause

Every production issue must state whether the root cause is fixed or only mitigated.

Use one of these:

* Root cause fixed: the broken assumption or failure mode is addressed, tested, deployed, and validated.
* Mitigated: the immediate customer or system impact is contained, but the root cause still exists.
* Partially fixed: one part of the root cause is addressed, but other affected paths remain.

If the issue is mitigated or partially fixed, the investigation must include:

* Follow-up Linear ticket.
* Owner.
* Target date.
* Risk if the follow-up is delayed.
* Detection or monitoring that protects us until the full fix ships.

"Fixed" must not silently mean "patched."

## Impact Analysis

Every production issue must answer:

* Which customers, partners, tenants, integrations, accounts, jobs, or payments were affected?
* What was the incident window?
* Was data lost, delayed, duplicated, corrupted, or silently wrong?
* Was money movement, payment state, reconciliation, authentication, notification, or customer access affected?
* Does the issue require backfill, replay, repair, refund, customer communication, or manual cleanup?
* How did we verify that the impact stopped?
* What remains unknown?

If the answer is "unknown", write "unknown" and explain what would be needed to know. Silent uncertainty is how the same problem comes back wearing a different hat.

## Recurrence Check

Every production issue must include a recurrence check.

Ask:

* Does this anti-pattern exist in other services?
* Does the same code path exist for other integrations, tenants, endpoints, jobs, or workers?
* Does the same retry, queue, cache, migration, feature flag, cron, or provider pattern exist elsewhere?
* Did a shared library, template, or documented pattern encourage the bug?
* Do monitors or dashboards hide the same issue in another service?

Write one bullet listing the checked areas and the plan:

```markdown
## Recurrence Check

Checked:
- <service/code path/pattern>
- <service/code path/pattern>

Result:
- <not present / present and fixed / present and tracked>

Follow-up:
- <Linear link, owner, target date>
```

If the recurrence check is skipped, write why. Skipping it silently is how one service teaches the next service the same bad trick.

## Root Cause and Tests

Every fix must include a test that would have failed before the fix.

The test should prove the real failure mode, not just exercise the new code. Prefer this order:

1. E2E test covering the production flow.
2. Integration test with real infrastructure dependencies, such as Postgres, RabbitMQ, Redis, S3, or the relevant provider fake.
3. Contract or regression test that catches the exact broken assumption.
4. Unit test for isolated logic, only when the production issue was genuinely isolated logic.

If a unit test passes while the production flow can still fail, the test is not enough. That is just a tiny green light taped over a broken machine.

## Mandatory E2E Coverage

E2E coverage is required for production issues.

The E2E must prove the affected production flow at the highest practical fidelity:

* Use real service entrypoints where possible.
* Use real database and queue dependencies where the issue involved persistence, jobs, retries, workers, or messages.
* Use fake upstream APIs only when the external provider cannot be safely used.
* Assert the business outcome, not only the internal method call.
* Cover recovery when the issue involved retries, pending state, failed jobs, circuits, reapers, or backfills.

If the team cannot add the final E2E in the same PR, the PR must include:

* Why the E2E cannot be added now.
* The temporary validation that proves the fix.
* A linked follow-up issue.
* An owner.
* A deadline.

That exception should be rare and explicitly approved by the engineering lead. The production issue cannot be closed until the E2E follow-up is completed. If exceptions become normal, the standard is fake.

## Detection Improvement

Every production issue must improve detection or explicitly document why detection should not change.

Valid detection improvements include:

* New alert or monitor.
* Dashboard update.
* Log or metric added to make the failure observable.
* Trace/span attribute added to make correlation possible.
* Runbook or playbook entry.
* Existing alert threshold corrected.
* Noise reduction that makes the next signal visible.

If no detection improvement is added, write:

```markdown
## Detection Decision

No detection change.

Reason:
<why this issue does not deserve an alert, dashboard, runbook, or telemetry change>
```

The point is not to create alerts for everything. The point is to stop pretending "we will notice next time" without a mechanism.

## PR Description Standard

Production fix PRs must be reviewable without making the reviewer reconstruct the incident from Slack.

The PR must include:

* Simple description of the issue.
* Simple description of the fix.
* Root cause.
* Mitigation versus root cause status.
* Impact analysis.
* Recurrence check.
* Hard evidence:
  * log links
  * metric links
  * trace links
  * dashboard links
  * incident links
  * incident channel links
  * Linear links
  * screenshots or prints when useful
  * before and after evidence when possible
* Tests added or updated.
* E2E evidence.
* Detection improvement or explicit "no" with reasoning.
* Rollout plan.
* Rollback plan.
* Post-deploy validation plan.
* Monitoring window:
  * duration
  * owner
  * signals watched
  * result after the window closes
* Residual risks.

Use this shape:

```markdown
## Summary

What broke and what this PR changes.

## Production Evidence

Links, screenshots, traces, log queries, dashboards, customer reports, or database evidence.

## Root Cause

The exact broken assumption or failure mode.

## Mitigation vs Root Cause

Root cause fixed, mitigated, or partially fixed. If not fully fixed, link the follow-up with owner and target date.

## Impact

Customers, time window, affected data/workflows, repair or backfill needs.

## Recurrence Check

Where else this pattern exists, what was checked, and follow-ups.

## Fix

What changed and why it addresses the root cause.

## Tests and E2E

Commands, test names, and before/after behavior.

## Detection Improvement

Alert, dashboard, telemetry, runbook, or explicit no with reasoning.

## Rollout and Rollback

How this will be deployed and how to back out.

## Post-Deploy Monitoring

Window, owner, signals, expected result.

## Residual Risk

What is still not solved.
```

## Post-Deploy Monitoring Window

Every production fix requires a monitoring window after deployment.

Define it before deploy:

* Owner.
* Start time.
* End time or duration.
* Dashboards and queries.
* Expected healthy signals.
* Rollback or escalation trigger.
* Final result.

The monitoring window should match the failure mode. A scheduled hourly job needs at least one successful scheduled cycle. A retry/reaper fix needs enough time for the retry or reaper path to run. A payment or data-integrity fix needs confirmation that the affected state transitions are correct.

The issue is not closed until the monitoring result is recorded.

## Postmortem Standard

Major incidents require a GitBook postmortem under `engineering/post-mortem`.

Postmortem filenames must start with the incident date:

```text
YYYY-MM-DD-<service-or-area>-<short-incident-slug>.md
```

Example:

```text
2026-04-30-integration-engine-qbo-cron-memory-eviction.md
```

The postmortem must include the Five W's:

* Who: who was affected?
* What: what happened?
* When: when did it happen?
* Where: where did it happen?
* Why: what was the root cause?

It must also include:

* Summary.
* Timeline with T0, T-detect, T-mitigate, T-resolve, and detection method.
* Production evidence.
* Impact analysis.
* Customer or stakeholder communication summary.
* Root cause.
* Mitigation versus root cause status.
* Contributing factors.
* Recurrence check.
* Resolution.
* Tests and E2E coverage.
* Deployment validation.
* Monitoring window result.
* Detection improvement or explicit "no" with reasoning.
* Residual risks.
* Action items with owners and target dates, tracked in Linear.

## Postmortem Template

Use this template for new postmortems. Do not remove required sections; if a section does not apply, write "Not applicable" and why.

```markdown
# Postmortem: <incident title>

**Date:** <date>
**Severity:** <P0/P1/P2/P3>
**Service(s):** <service names>
**Incident window:** <start - end>
**Owner:** <owner>
**Linear:** <link>
**PR:** <link>

## Summary

Short explanation of what happened, why it mattered, and current status.

## Production Evidence

Links to logs, metrics, traces, dashboards, screenshots, incident threads, customer reports, database evidence, or deploy evidence.

## The Five W's

### Who was affected?

Customers, partners, tenants, integrations, accounts, jobs, payments, or internal users affected.

### What happened?

Concrete production behavior.

### When did it happen?

Start, detection, mitigation, resolution, and monitoring window.

### Where did it happen?

Service, endpoint, worker, queue, job, database, region, cluster, provider, or product area.

### Why did it happen?

Root cause and broken assumptions.

## Timeline

| Time | Event |
| --- | --- |
| T0 | Issue started |
| T-detect | Issue detected by <alert/customer/support/manual/accident> |
| T-mitigate | Customer/system impact mitigated |
| T-resolve | Root cause fix deployed |
| T-monitoring-close | Monitoring window completed |

## Impact Analysis

Data, money movement, customer experience, delayed work, duplicate work, repair/backfill needs, and unknowns.

## Customer and Stakeholder Communication

Affected customers or stakeholders, whether they were contacted, repair/refund/backfill status, and whether the communication loop is closed.

## Mitigation vs Root Cause

Root cause fixed, mitigated, or partially fixed. If not fully fixed, link the follow-up with owner and target date.

## Contributing Factors

The conditions that let the root cause bite: missing tests, weak assertions, absent logging, review gaps, prior optimizations. Systems and decisions, not names.

## Recurrence Check

Where else this pattern exists, what was checked, and follow-ups.

## Resolution

What changed and why it fixes the root cause.

## Tests and E2E

Tests added, E2E coverage, commands, and before/after behavior.

## Deployment Validation

How the fix was validated after deployment.

## Monitoring Window

Owner, duration, signals watched, expected result, actual result.

## Detection Improvement

Alert, dashboard, telemetry, runbook, or explicit no with reasoning.

## Residual Risk

What remains unresolved.

## Action Items

| Action | Owner | Due date | Status |
| --- | --- | --- | --- |
| <action> | <owner> | <date> | <status> |
```

Action items must be tracked in Linear, not buried only in the postmortem prose. Use project: `Incident Follow-ups`. Review open incident follow-ups every two weeks until closed.

## Closure Standard

A production issue is closed only when:

* Post-deploy validation passed.
* Monitoring window completed and result was recorded.
* Customer or stakeholder communication loop is closed, if applicable.
* Backfill, replay, repair, refund, or manual cleanup is complete, if applicable.
* Action items are shipped or filed with owners and target dates.
* E2E coverage exists, or the engineering lead approved a temporary exception and the follow-up remains open.

Partial-rollout fixes close in stages. For example, a per-partner feature flag can close the affected partner impact, but full closure happens only when the fix is on by default or the rollout decision is documented.

## Blameless Standard

Postmortems are blameless.

The goal is to learn, not to assign fault. Honest "why" analysis only happens if people can write down what actually happened without getting punished for telling the truth. Blameless does not mean soft. It means we hold the system, process, and decisions accountable instead of hunting for a person to blame.

## Examples

Use these service-specific postmortems as examples for the expected shape:

These examples were referenced by the source standard but are not bundled here.
Treat them as unavailable references, not inspected incident evidence:

* Integration Engine: QBO cron worker memory eviction. Original source-relative path: `../../post-mortem/2026-04-30-integration-engine-qbo-cron-memory-eviction.md`.
* Integration Engine: upstream response body memory pressure. Original source-relative path: `../../post-mortem/2026-05-01-integration-engine-upstream-response-body-memory-pressure.md`.

Locate and read the actual source before relying on either example.
