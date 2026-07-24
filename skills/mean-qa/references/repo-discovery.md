# Repo Discovery

MeanQA does not own product truth. The repository owns product truth.

## Read First

In the current repo, discover and read relevant local instructions before testing:

- `AGENTS.md`, `.agents/**`, `.codex/**`, or equivalent agent instructions.
- QA contracts, runbooks, ledgers, scenario catalogs, evidence templates, and artifact indexes.
- Existing Playwright/Cypress/e2e harnesses, API/gRPC scripts, test fixtures, and cleanup tools.
- Service docs describing deployment, routing, environment, fake data, and safety boundaries.
- Sibling repos or legacy checkouts only when local instructions say they are authoritative.

Use `rg --files` and `rg` first. Do not guess paths from memory.

For large ledgers, read the summary/state table and targeted flow/run sections first. Do not dump the whole ledger into context unless the repo format leaves no safer way to recover state.

## Authority Order

1. System/developer safety rules.
2. Current user instruction.
3. Repo-local instructions and QA contracts.
4. Current ledger/run state.
5. Source code, tests, config, and runtime evidence.
6. This generic MeanQA skill.

If this skill conflicts with repo-local QA safety rules, follow the stricter rule.

## What To Extract

Before testing, identify:

- environment and base URL/API target,
- environment class: `prod`, `staging` (ST), `local`, or `unknown` — treat `unknown` as PROD for every boundary rule until evidence proves otherwise,
- whether any planned tool action has a PROD relation and therefore needs explicit PROD confirmation (see SKILL.md Environment Boundary) before execution,
- expected behavior and flow IDs,
- current known failures and blocked flows,
- fake/safe fixture scope,
- mutation and cleanup policy,
- artifact directory and ledger update rules,
- expected backend boundaries,
- required regression-test harness,
- available read-only tool surfaces for browser, data, runtime, observability, and messaging evidence,
- unavailable tools or known evidence gaps.

When tool availability is unclear, inspect it before planning evidence. If a required tool is unavailable, record the missing layer as an evidence gap instead of quietly weakening the pass criteria.

## Portable Rule

Never put repo-specific service facts into the global skill. Link or read them from the repo every run. Frozen product facts in a reusable skill are stale evidence waiting to lie.
