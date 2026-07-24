# Message Evidence

Use message evidence when behavior depends on broker topics, queues, exchanges, routing keys, outbox relays, event consumers, DLQ/requeue behavior, webhooks, or downstream asynchronous delivery.

## When Required

Load this reference for:

- broker-only flows,
- event publication or consumption claims,
- invite/email/payment/accounting side effects,
- outbox relay behavior,
- `NO_ROUTE`, returned, unroutable, nack, retry, or publisher-confirm signals,
- DLQ/backlog/consumer health,
- cleanup or replay involving messages.

## Proof To Capture

Depending on repo tooling and safety:

- expected topic/routing key/exchange/queue,
- sanitized event input and output payload shape,
- binding exists or intentionally does not exist,
- publish attempt and broker acknowledgement/return,
- consumer count and queue depth,
- DLQ/backlog before/after,
- outbox row state and archive/processed state,
- downstream state record,
- Datadog/log correlation for publish and consume,
- exact time window and sanitized identifiers.

## Event Evidence Matrix

For flows that publish or consume events, include:

| Event/Topic | Expected effect | Produced? | Consumed? | Downstream state | Evidence | Verdict |
|---|---|---|---|---|---|---|

If a flow does not publish or consume events, mark message evidence `not applicable`. Do not invent RabbitMQ work just to look thorough.

## Safety

Broker replays and message publishes are mutations. Run them only against approved local/test/fake scope and only when repo rules allow it.

Any PROD-related broker tool execution, including read-only inspection of production queues, exchanges, bindings, messages, DLQs, or consumer state, requires explicit PROD confirmation (see SKILL.md Environment Boundary) before execution unless it is covered by a current bounded read-only PROD evidence envelope.

Do not publish, replay, purge, ack/nack, delete bindings, replay production messages, or modify production broker topology during QA unless the user explicitly confirms the exact operation, environment, target, and expected effect.

ST/local broker publishes, replays, and cleanup may execute when repo/user rules allow it and fake/safe scope is proven. Do not skip necessary event proof just because Rabbit is inconvenient.

## Classification

- Durable state marks message delivered/published but broker evidence shows returned/unroutable: `failed-backend`.
- Event expected but no broker/outbox proof available: `unproven`.
- Broker unrelated to the changed behavior: mark layer `not applicable`, not skipped suspiciously.
