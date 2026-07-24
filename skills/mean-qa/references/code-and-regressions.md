# Code And Regressions

Use code evidence when runtime behavior is ambiguous, a failure must be mapped to source, expected behavior needs confirmation, or a stable finding should become a regression test.

## Source Mapping

Search local code and config for:

- operation names,
- endpoint paths,
- gRPC methods,
- queue/topic/routing keys,
- log messages,
- database table names,
- feature flags and rollout phases,
- serializers/deserializers,
- permission gates,
- retry/fanout loops.

Use `rg`/`rg --files` first.

## Regression Standard

A regression should hit the real boundary that failed:

- UI flow: repo e2e harness with auth/session conventions.
- API/GraphQL/gRPC: service or integration test at the request boundary.
- Persistence bug: query/repository/domain test plus read/write behavior.
- Broker bug: publish/consume/outbox/retry boundary.
- Runtime observability bug: log/metric/span branch test where feasible.

Tests that prove only a helper are not enough when the real bug lived at the workflow boundary.

## Test Evidence

When tests are run or generated, record:

- exact command,
- working directory,
- target environment or base URL when relevant,
- pass/fail status,
- short decisive output,
- artifact path for full output when output is long,
- whether the test is smoke, regression, exploratory, or graduation evidence,
- what behavior the test proves and what remains unproven.

If a test is added but not run, say `not run` and name the blocker. Do not let checked-in test code masquerade as passing evidence.

## Graduation

Only create or refresh regression tests when repo rules allow it and the behavior is stable enough:

- evidence exists,
- expected behavior is clear,
- two-pass/graduation rules are satisfied if the repo requires them,
- the target harness is known,
- the test can run without secrets or unsafe side effects.

If a repo says specs belong in a sibling frontend repo, use that repo's harness. Do not build a parallel harness because it is convenient.
