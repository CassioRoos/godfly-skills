# Postmortem Rubric: Major-Incident Postmortem

Postmortems live in the docs repo under `engineering/post-mortem`. Validate against
the template in the resolved standard -- do not let required sections be removed;
"Not applicable" plus why is the only valid skip.

Decision target: `postmortem-publish` (terminal verdict `PUBLISHABLE` /
`BLOCKED: <gates>`). A publishable postmortem is not a closed incident; closure is a
separate target with its own gates.

## Gates

| Gate | What passes |
|---|---|
| `filename` | `YYYY-MM-DD-<service-or-area>-<short-incident-slug>.md`, date first. |
| `header-block` | Date, severity, service(s), incident window, owner, Linear link, PR link. |
| `five-ws` | Who affected / what happened / when / where / why. Each answered concretely, not restated from the title. |
| `timeline` | T0, T-detect, T-mitigate, T-resolve, T-monitoring-close, and the detection method. T0 is when the failure started, not when it was seen. |
| `production-evidence` | Linked and measured, same bar as the handover. |
| `impact-analysis` | The standard's seven questions, downstream and customer-facing. |
| `stakeholder-comms` | Who was contacted, repair/refund/backfill status, whether the loop is CLOSED. If customers were affected and this section is empty, the gate fails loudly. |
| `root-cause` | Explains symptom and code behavior. |
| `mitigation-vs-root-cause` | Explicit status; follow-up + owner + date if not fully fixed. |
| `contributing-factors` | The conditions that let the root cause bite: missing tests, weak assertions, absent logging, review gaps, prior "optimizations". Blameless: systems and decisions, not names. ADVISORY while the resolved standard's template has no Contributing Factors section -- today it is in the embedded snapshot only (see SKILL.md, "Does the resolved standard contain what the rubrics enforce?"). |
| `recurrence-check` | Cross-service, with the checked list and results. |
| `resolution` | What changed and why it fixes the root cause. |
| `tests-and-e2e` | Added coverage, commands, before/after behavior. |
| `deployment-validation` | How the fix was verified after deploy -- evidence that could have failed, not assertion: which version ran, proof the affected path executed on it, the error signature queried over pre/post windows. A deploy SHA plus a green check is not validation. |
| `monitoring-window-result` | Owner, duration, signals, expected result, ACTUAL result -- with the observed numbers and their denominator. A window without a recorded result is an open window; the incident is not closed. |
| `detection-improvement` | Improvement or explicit "no" with reasoning. |
| `residual-risk` | What remains unresolved. |
| `action-items` | Table with owner + due date + status, AND tracked in Linear under project `Incident Follow-ups` -- verify the tickets exist, do not take the table's word. |
| `blameless` | No person blamed. If a name appears where a decision or system should, flag it -- this is the one gate about how it is written, and it protects every future postmortem's honesty. |

## Closure

Closure gates -- including artifact-existence checks -- live in
`cookbook/closure-gates.md`. They are mandatory for the `incident-close` target,
whatever artifact was submitted, and informational (`NOT_APPLICABLE`, reason
`informational dependency for incident-close`) for `postmortem-publish`.
