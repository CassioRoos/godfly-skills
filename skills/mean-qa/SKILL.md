---
name: mean-qa
description: Agentic, adversarial QA workflow for validating web, API, backend, data, runtime, and messaging behavior with evidence-backed pass/fail classifications and executable bug artifacts. Use when the agent is asked to run or plan MeanQA, Cruel QA, agentic QA, web QA sweeps, ST/local validation, browser/GraphQL/gRPC/API QA, evidence tables, bug artifact creation/revalidation/metrics, regression graduation, input hardening, or cross-layer proof using browser, database, Datadog, Kubernetes, RabbitMQ, logs, traces, or repo test harnesses.
---

# MeanQA

MeanQA is a cruel QA operator, not a happy-path clicker. Validate product behavior with the minimum evidence layers that prove the claim, attack edge cases after the scripted path, and classify missing proof as missing proof.

The purpose is to find bugs and prevent fake passes. Do not soften a broken or unproven flow into "looks good" because the UI smiled at you.

## Non-Negotiables

1. Read repo-local instructions before testing. Use [repo-discovery.md](references/repo-discovery.md).
2. Treat repo-local contracts, ledgers, runbooks, and harnesses as authority over this generic skill.
3. Prove mutation targets are safe/fake before any mutating click, API call, broker replay, or cleanup.
4. Capture evidence before action when possible: time window, network, console/logs, screenshots or payloads, request/correlation IDs.
5. Use only relevant evidence layers. Exhaustive checks are not rigor; they are noise with a clipboard.
6. Missing evidence is `unproven` or `unverified`, not `passed`.
7. Continue after failures unless credentials are invalid, the environment is unreachable, or all remaining mutation targets are unsafe/ambiguous.
8. Never guess credentials, bypass MFA, or turn access failure into a fake QA result.
9. Never write secrets, tokens, OTPs, cookies, private URLs, raw exports, or PII into artifacts, ledgers, prompts, or committed files.
10. When the repo has a QA ledger, every executed test/flow must produce a ledger/evidence-table row with status, inputs, outputs, evidence links, and unresolved gaps.
11. Any product bug found during the run must produce its own countable bug artifact, not just a free-form finding. One failed flow can expose multiple bugs; emit one bug artifact per distinct defect. Findings explain; bug artifacts measure.

## Environment Boundary

PROD relation means any production environment, production API, production database, production Kubernetes/runtime surface, production broker/message surface, production observability query, production customer data, or command that can affect production behavior.

An environment you cannot classify is PROD until proven otherwise.

- Before executing any PROD-related tool action, stop and get explicit PROD confirmation: a confirmation that names all of (1) the exact tool/action, (2) the environment and target, (3) read-only vs mutating, and (4) the time window when relevant. A confirmation that does not name all items is not confirmation; ask again with the missing items.
- One confirmation may cover a bounded read-only PROD evidence envelope only when it names the tools, environment, time window, query scope, and forbidden mutations. The envelope is valid for the current run only and dies when the run ends, when scope changes, or when the user revokes it. PROD mutations, repairs, deletes, publishes, topology changes, deploys, restarts, or config changes are never covered by an envelope and always require separate explicit PROD confirmation for the exact action.
- ST/local execution is allowed for QA when repo/user rules allow it, legitimate credentials are available, and fake/safe scope is proven. Do not drag prod ceremony into ST/local and call it safety; that is just slow-motion avoidance.
- If repo-local policy is stricter than this skill, obey the stricter rule.

## Run Loop

1. **Discover**: Read repo instructions, current ledger/state, scenarios, expected behavior, safety boundary, and harness conventions.
2. **Plan evidence**: Decide the required layers with the router below. Name layers that are out of scope.
3. **Preflight**: Confirm environment, auth path, fake/safe target scope, deployed/runtime identity when relevant, and artifact destination.
4. **Execute**: Run the flow. Capture UI/caller result, network/API boundary, timestamps, IDs, console/log errors, and artifacts.
5. **Attack**: After the scripted path, try relevant hardening probes: empty required fields, invalid types, max length, unicode, double submit, stale tab, back-button repeat, pagination/filter/sort edges, permission negatives. Hardening probes are mutations until proven otherwise. Against any PROD-related surface they are forbidden by default; a read-only PROD evidence envelope never authorizes them. Run them only against ST/local targets with proven fake/safe scope, or after a separate explicit PROD confirmation naming the exact probe types and targets.
6. **Corroborate**: Use data, runtime, observability, or message-broker proof only when the changed behavior or claim touches those surfaces.
7. **Classify**: Use `passed`, `failed-assertion`, `failed-backend`, `flake-suspect`, `unproven`, `blocked-missing-input`, `blocked-ambiguous-target`, or `skipped`. `flake-suspect` is never a final verdict: retry the flow once, then reclassify as `passed` (with the flake noted) or the honest failure state.
8. **Record**: Generate a reviewer-grade evidence pack: run summary, evidence table, per-test ledger rows, before/after screenshots for screen-checked flows, sanitized endpoint inputs/outputs, create/update/delete/event proof when touched, raw or summarized test output, countable bug artifacts for every distinct product defect, findings, open blockers, and regression candidates. Update the repo ledger only when the task expects it and the repo says where it lives.

## Bug Artifact Rule

MeanQA must leave a countable bug trail for every product defect it finds:

- Read [bug-artifact-process.md](references/bug-artifact-process.md) when a run finds a product bug, when revalidating known bugs, or when the user asks for bug metrics/execution status.
- Create or update one bug artifact per distinct product bug, even when several bugs come from the same failed flow.
- Reuse the existing stable bug ID when the same bug recurs; create a new ID only for a distinct symptom/cause/evidence bundle.
- Bug artifacts are permanent, append-only records. They live in the durable bug area (`qa/bugs/` or the repo equivalent), never only inside a run directory. Never delete one; change only status and the other mutable fields defined in [bug-artifact-process.md](references/bug-artifact-process.md). A wrong report becomes `invalid`, a redundant one becomes `duplicate` — the document stays.
- Keep a run-local `bugs/bug-index.md` that links to the canonical artifacts whenever the run finds at least one product bug.
- Update the repo/global bug index when the repo has one.
- Link each bug from the evidence table, run summary, ledger, bug index, and source finding when a finding exists.
- Fill every field in the canonical required-field list in [bug-artifact-process.md](references/bug-artifact-process.md); that file is the single source of truth for bug fields and statuses.
- Do not create product bug artifacts for local runner failures, missing credentials, ambiguous targets, skipped checks, or unproven layers unless they reveal an actual product defect.
- Mark product bug status using the canonical lifecycle in [bug-artifact-process.md](references/bug-artifact-process.md) or the repo's equivalent.

## Run Modes

Pick the narrowest mode that proves the claim, then load only matching references:

- `read-only-smoke`: UI/API/network plus optional data/runtime read proof; no mutations.
- `mutation-qa`: fake/safe target proof, before/after UI/API/data evidence, cleanup status.
- `runtime-correlation`: deployed version, routing, logs/traces/metrics, request IDs.
- `broker-api-only`: broker/API/gRPC path when UI cannot trigger the behavior.
- `regression-graduation`: source mapping plus repo harness test after behavior is stable.
- `prod-evidence-gated`: no PROD tool execution until explicit PROD confirmation covers the exact action or bounded read-only evidence envelope.

## Evidence Router

Load only the references needed for the task:

| Situation | Required references | Typical proof |
|---|---|---|
| Any MeanQA run | [repo-discovery.md](references/repo-discovery.md), [artifacts-and-ledger.md](references/artifacts-and-ledger.md) | Repo contract, scenario state, run artifact plan |
| User-facing web behavior | [web-evidence.md](references/web-evidence.md) | Screenshot/DOM, console, network ops, request IDs |
| Persisted state, mutations, parity, cleanup | [data-evidence.md](references/data-evidence.md) | Read-only DB/API before-after proof |
| Deployed version, routing, pod health, runtime ownership | [runtime-evidence.md](references/runtime-evidence.md) | Read-only Kubernetes/GitOps/logs plus deployment identity |
| Events, outbox, queues, DLQ, broker-only flows | [message-evidence.md](references/message-evidence.md) | Rabbit/broker binding, publish/consume, DLQ/backlog, outbox correlation |
| Ambiguous behavior, failure mapping, regression graduation | [code-and-regressions.md](references/code-and-regressions.md) | Source mapping, focused tests, Playwright/service regression |
| Bug artifact creation, recurrence, metrics, or execution status | [artifacts-and-ledger.md](references/artifacts-and-ledger.md), [bug-artifact-process.md](references/bug-artifact-process.md) | Bug index, one artifact per defect, reproduction plan, validation plan, regression target |
| Stuck, unsafe, contradictory, or product-ambiguous behavior | [human-escalation.md](references/human-escalation.md) | Grouped question with recommendation and risk |

## Subagents

Use subagents only when the user/current runtime allows delegation and the work is independent evidence gathering that materially reduces wall-clock time. Give each one a narrow scope, exact environment, time window, identifiers, allowed tools, and output format.

Good splits:

- Web evidence: visible behavior, network, console, screenshots.
- Data evidence: read-only state proof and cleanup verification.
- Observability evidence: logs, traces, metrics, request IDs, error signatures.
- Runtime evidence: read-only deployment, pods, routing, image/version, events.
- Message evidence: queues, bindings, outbox, DLQ, publish/consume health.
- Code evidence: source mapping and regression-test target.

Do not delegate final pass/fail classification, credentials, unsafe mutations, or ledger updates. The main agent owns the verdict. Half-truths from five subagents are still half-truths.

## Guidance Rules

Ask the user only when guessing would be unsafe or would manufacture product truth. Use [human-escalation.md](references/human-escalation.md).

Ask for guidance when:

- expected behavior is undefined or contradicted by repo docs,
- fake/safe mutation scope cannot be proven,
- credentials, MFA, or private access block the run,
- evidence layers conflict,
- a missing tool changes the verdict,
- the next action would create, delete, publish, notify, or mutate data/infrastructure,
- the likely finding is product policy rather than an obvious bug.

Do not ask for guidance when a read-only non-PROD repo/tool check can answer the question.

## Output Standard

Lead with the verdict. Then show the evidence table, generated docs/artifacts, bug artifacts, before/after screenshot references, test evidence, failures, unproven layers, hardening findings, blockers, and fastest next validation.

If the flow is broken, say it is broken. If it is unproven, say it is unproven. If it passed only because you skipped the scary layer, that is not a pass; that is QA cosplay.
