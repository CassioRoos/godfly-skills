# Runtime Evidence

Use runtime evidence when a claim depends on deployed version, routing, service ownership, pod health, environment targeting, logs, traces, metrics, or platform-vs-legacy behavior.

## Sources

Prefer read-only sources:

- Datadog logs, traces, metrics, monitors, deployment markers,
- Kubernetes read-only get/describe/logs/events,
- GitHub/CI/CD deploy metadata,
- GitOps manifests and image tags,
- service logs through approved read-only tooling.

Any PROD-related runtime tool execution, including read-only inspection of production Kubernetes, GitOps, Datadog, logs, traces, or metrics, requires explicit PROD confirmation (see SKILL.md Environment Boundary) before execution unless it is covered by a current bounded read-only PROD evidence envelope.

Do not mutate production Kubernetes, Helm, GitOps, secrets, config maps, deployments, rollout state, monitors, or runtime configuration during QA unless the user explicitly confirms the exact operation, environment, target, and expected effect.

ST/local runtime actions may execute when repo/user rules allow it. If repo-local policy makes staging runtime read-only, obey that policy.

## Required Shape

Runtime proof should include:

- environment and org/source,
- UTC window,
- service/component,
- deployed version/image/SHA when available,
- request/correlation IDs or entity IDs when available,
- exact query/filter shape or sanitized equivalent,
- counts/statuses and decisive log/span snippets,
- unresolved evidence gaps.

## Datadog Discipline

Do not treat ambient logs as proof. Correlate by request ID, entity ID, operation name, route, service, environment, and time window.

If Datadog proves only service wiring but not the exact run, say that. Service-level evidence is not per-flow evidence.

## Classification

- Wrong backend handled the flow: `failed-backend` or `unproven`, depending on expected behavior.
- Runtime layer unavailable and required: `unproven`.
- Runtime evidence contradicts UI/API success: do not pass. Investigate or mark failed with the contradiction.
