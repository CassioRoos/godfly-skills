# Handover Rubric: Investigation Handover Report

The handover is the deep RCA produced during or after the investigation, handed to
the team before or alongside the fix. It is the artifact that lets someone who was
not in the trenches pick up the incident and finish it. It has two halves:
**standard compliance** (the gates) and **analysis quality** (the bar).

## Gates

Derive final wording from the resolved standard; these map to its sections.

| Gate | What passes |
|---|---|
| `severity-classified` | Explicit P0-P3 with reasoning. |
| `trigger-sweep` | Every full-postmortem trigger explicitly checked: money/data corruption, multi-tenant impact, >15min core-flow degradation, silent issue, repeat incident class, backfill/repair needed, unclear rollback. "None fired" must be stated, not implied. |
| `detection-source` | How was this found: alert, customer, support, manual inspection, accident. If manual/customer/accident, the SILENT trigger fires -> full postmortem required. |
| `incident-window` | First-seen and current status. The window opens when the failure STARTED (often the regressing deploy), not when it was observed. A recurring cron bug's window is "every hour since <deploy>", not one burst. |
| `affected-services` | All services in the chain, producer to victim. |
| `production-evidence` | Measured numbers, timestamps, linked queries/dashboards/logs. Claims without links are `claimed`, not `documented`. |
| `root-cause` | Explains BOTH the production symptom and the code/system behavior. Code links to the exact offending lines. |
| `causal-chain-to-producer` | Chain traced to the ORIGINATING producer, not the visible victim. If the analysis stops at the service that errored, it stopped early. |
| `mitigation-vs-root-cause` | Explicit: root cause fixed / mitigated / partially fixed. "Band-aid" honesty in the summary, not buried. |
| `follow-up-if-not-fixed` | If mitigated/partial: Linear ticket + owner + target date + risk-if-delayed + interim detection. ALL five. This is the gate mitigated incidents most often fail. |
| `impact-analysis` | The standard's seven questions answered: who affected, window, data lost/delayed/duplicated/wrong, money/payment/auth/notification impact, backfill/replay/comms needed, how impact-stop was verified, what remains unknown. Downstream customer-facing impact, not internal error counts. |
| `recurrence-check` | Other services/integrations/tenants with the same pattern checked and listed. In a multi-integration codebase, "do the sibling integrations have the same hourly full-pull?" is the question. |
| `tests-specified` | Tests that would have FAILED before the fix, including a negative regression test for any dangerous shortcut identified. |
| `detection-improvement` | Alert/dashboard/log/metric/runbook improvement, or an explicit written "no" with reasoning. |
| `linear-tracking` | The investigation is tracked in Linear. A 700-line report with zero Linear links fails this gate. |
| `unknowns-honest` | Unknowns written as unknowns, each with what would be needed to know. |

## Analysis Quality Bar

These are what separate a great handover from a compliant one. Coach toward them;
report a `quality:*` row only where it changes a verdict or earns a place in the work
list -- this is a coaching bar, not five more rows to fill.

- `quality:evidence-per-claim` -- every claim is paired with a code link or runtime
  evidence. "The consumer drops UpdatedSince" plus the line link plus the log line
  that proves it ran that way in prod.
- `quality:dangerous-non-fix` -- when a tempting shortcut exists that would be
  wrong (the partial-filter-plus-reconcile data-loss trap), it is documented with
  WHY it is wrong and a negative regression test that catches it. This is knowledge
  that otherwise dies in someone's head.
- `quality:plain-language` -- key findings have a non-technical interpretation.
  The report will be read by people who were not in the incident.
- `quality:deploy-honesty` -- merged is not deployed. The report distinguishes
  "PR merged" from "verified running in production" and says which one it proved.
- `quality:restraint-documented` -- probes NOT run (live calls to partner systems,
  prod mutations) are listed with the reasoning for restraint.

## Reference Exemplar

The analysis-quality bar comes from a real handover (a webhook-burst incident
against a billing integration): complete causal chain with evidence per step,
exemplary mitigation-vs-root-cause honesty, a model dangerous-non-fix section, and
honest unknowns. It is ALSO the compliance lesson: when first validated, it failed
a large number of standard gates despite the analysis quality. Excellent analysis
and an unclosed incident are not the same thing -- that gap is exactly what this
skill exists to catch.

If the artifact you are validating IS this exemplar, ignore this note entirely and
derive every verdict independently. This section is a teaching reference, never an
answer key.
