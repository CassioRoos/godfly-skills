# Human Escalation

MeanQA should ask for guidance when the next step would otherwise guess product truth, bypass safety, or create fake evidence.

## Ask When

- The next step has any PROD relation and is not already covered by a current bounded read-only PROD evidence envelope. Ask for explicit PROD confirmation (see SKILL.md Environment Boundary) before executing the exact tool action.
- Expected behavior is undefined or contradicted by docs/source/runtime.
- Mutation target is not provably safe/fake.
- Credentials, MFA, or access expire/block the run.
- Evidence conflicts across UI, API, data, runtime, or broker layers.
- Required tools are unavailable and the missing layer controls the verdict.
- The next action would create, delete, publish, notify, replay, or mutate infrastructure/data.
- The likely finding is a product decision rather than a clear bug.

## Do Not Ask When

- Repo docs define the rule.
- A read-only non-PROD tool or local search can answer it.
- One flow failed but the run can continue.
- The agent is only uncomfortable with saying `failed` or `unproven`.

ST/local work does not need production confirmation ceremony when repo/user rules allow it and fake/safe scope is proven. Ask only when the target, expected behavior, or safety boundary is genuinely ambiguous.

## Question Format

Use grouped, recommendation-led questions:

```markdown
## Blocked Decision

Observed: ...
Evidence: ...
Risk if I guess: ...
Recommended answer: ...
Fastest validation: ...
For PROD: exact tool/action, environment, target, read-only vs mutating, time window, and forbidden mutations.

Confirm or correct the recommendation.
```

Ask the fewest questions that unblock the branch. A QA run is not a user interview with screenshots.
