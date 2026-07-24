# Evidence Sources

Use this reference to choose read-only evidence sources during a deployment monitor.

## Codex Tool Discovery

- Inspect available MCP servers when tool state is unclear: `codex mcp list`.
- Use `tool_search` to expose task-specific tools for Datadog, Kubernetes, Postgres, RabbitMQ, and multi-agent workflows when they are deferred and not yet visible.
- Prefer Datadog, read-only Postgres, read-only Kubernetes, RabbitMQ, and GitHub evidence over hand-wavy local guesses.
- If an expected MCP is missing, say so and continue with the strongest available read-only fallback. Do not pretend the evidence exists.

## Datadog

Use Datadog as the primary source when available.

Collect:

- deployment markers or version tags
- log volume by level and service
- unique error signatures
- new stack traces
- APM error rate, latency, throughput, and 5xx
- monitor state changes
- service/resource-specific tags

Compare:

- monitor window vs equal-length pre-deploy window
- monitor window vs same period yesterday when traffic is seasonal
- new signatures vs known historical signatures

## Postgres

Use Postgres MCPs for read-only corroboration. Choose the environment that matches the monitor target.

Collect only `SELECT` evidence:

- counts by status/state
- skipped, failed, terminal, pending, duplicate, or divergent records
- recent growth rates
- oldest pending/stuck timestamps
- error or retry reason distributions
- lock wait, timeout, or transaction symptoms when exposed by safe read-only views

Never run writes, migrations, DDL, DML, manual cleanup, or replay operations without the explicit confirmation defined in SKILL.md's Safety Contract (naming the exact operation, environment and target, that it is mutating, and the expected effect).

## Kubernetes

Use Kubernetes read-only tools for runtime state.

Collect:

- deployed image tags and pod age
- rollout/pod health
- restart counts
- pod events
- recent pod logs only when needed to corroborate Datadog or fill gaps
- resource pressure symptoms

Never mutate cluster state during the monitor.

## RabbitMQ

Use RabbitMQ read-only tools for queue health when the service uses AMQP/RabbitMQ.

Collect:

- queue depth
- publish, deliver, ack, nack, redelivery, and confirm rates
- consumer count
- dead-letter growth
- oldest message age when available
- channel/connection churn

Treat rising backlog plus stable or falling consumers as a serious signal.

## GitHub And Code Mapping

Use local repo search and `gh` when a repo, PR, commit, or file path is known.

Map errors by:

- exact stack frame path
- package/module/logger name
- job or handler name
- SQL/query name
- endpoint path
- error constant or message fragment

Prefer links in this order:

1. PR that introduced or touched the failing code.
2. Commit that introduced or last changed the line.
3. File path and line.
4. Existing issue or incident note.

If mapping is unresolved, report the searched terms and likely owner area.
