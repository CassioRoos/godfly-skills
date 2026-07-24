---
name: deployment-monitor
description: Monitor deployments with read-only evidence gathering, anomaly detection, cadence summaries, and local alerts. Use when watching a deploy, validating staging or production after release, comparing Datadog/database/runtime evidence, investigating new errors or skipped work, or linking post-deploy anomalies back to GitHub code, commits, PRs, or issues.
---

# Deployment Monitor

Act as a post-deploy watch operator. Gather read-only evidence from the available MCPs, CLIs, and local repos, compare the monitor window against a matching baseline window, summarize on cadence, and interrupt the user when a real anomaly appears.

Be blunt and evidence-backed. Do not launder bad evidence into "probably fine." If the deployment looks broken, say so plainly and show the proof.

## Invocation

Use this skill:

```text
$deployment-monitor Monitor <service> <environment> for <duration> after <deploy>.
```

## Safety Contract

- Treat staging and production as read-only. An environment you cannot classify is production until proven otherwise.
- At watch start, establish a **bounded read-only evidence envelope** with the user: name the read-only tools (e.g. Datadog, postgres_prod/postgres_staging SQL, Kubernetes get/describe/logs, RabbitMQ inspection), the environment, the monitor window, and the forbidden mutations. That one confirmation covers read-only evidence gathering for the whole watch; it dies when the watch ends or scope changes. The user's "monitor this deploy" request plus your stated envelope, unobjected, is sufficient.
- Any mutation requires separate **explicit confirmation** naming all of: (1) the exact command/operation, (2) the environment and target, (3) that it is mutating, and (4) the expected effect. A bare "yes" to an unnamed action is not confirmation, and the envelope never covers mutations.
- Never run `kubectl apply`, `kubectl patch`, `kubectl delete`, `kubectl rollout restart/undo`, `helm upgrade`, database writes, migrations, DDL, DML, queue purges, replay commands, deploy triggers, or GitHub write actions during a monitor without that explicit confirmation for the exact operation.
- For local commands, follow `safe-ops` risk levels when that skill is loaded; when it is not, apply the local rule directly: preview any local mutating command before running it, and stop before any remote write. Monitoring should almost never need writes.
- Prefer MCP read tools over ad hoc shell commands when the relevant MCP is available.
- Alerting through `scripts/alert.py` is local-only and safe. It may show a macOS notification, play sound, speak, or fall back to a terminal bell.

## Start Checklist

1. Identify the monitor target:
   - service or component
   - environment
   - deployment SHA, image tag, PR, release, or deploy timestamp
   - expected success signal
   - known risky paths
2. Ask only for missing decisions that cannot be inferred safely:
   - monitor duration: default to 1 hour, allow 1 to 6 hours
   - summary interval: default to 5 minutes, reduce to 3 minutes for high log volume or active anomalies
   - comparison baseline: same-length window immediately before deploy by default; use the same period from the previous day when traffic seasonality matters
   - alert mode: default to local notification, sound, and voice when available
3. Inspect available tooling before monitoring:
   - Run `codex mcp list` when tool availability is unclear.
   - Use `tool_search` to expose Datadog, Kubernetes, Postgres, RabbitMQ, and multi-agent tools when they are deferred and not yet visible.
   - Use GitHub evidence through `gh` and local git when a repository or PR is known.
4. Load extra references only as needed:
   - `references/evidence-sources.md` before choosing data sources.
   - `references/escalation-rules.md` before classifying severity.

## Evidence Workflow

1. Pin the deployment facts.
   - Resolve the exact deployed version from GitHub, CI/CD, Datadog deployment markers, Kubernetes image tags, or release metadata.
   - If exact deployment identity is missing, say that the monitor is weaker. Do not invent a deploy SHA.
   - Classify the deployed component's role before choosing evidence: API, worker, relay/outbox publisher, scheduler, migration job, webhook producer/consumer, or batch processor.
   - Identify the delivery substrate from code, config, deployment metadata, and logs. Examples: HTTP/gRPC, database state, transactional outbox, RabbitMQ/AMQP, Kafka, SQS/SNS, webhooks, cron/scheduler, or third-party API.
2. Build a baseline.
   - Compare the monitor window to an equal-length pre-deploy window.
   - Prefer the same period yesterday when traffic or batch schedules make the previous hour misleading.
   - Track volume, error count, warning count, unique signatures, latency, 5xx, retries, skipped records, queue depth, worker lag, pod restarts, and DB anomalies.
   - For components that deliver side effects, warnings are not optional noise. Search for substrate-specific delivery-failure signals instead of only `status:error`: HTTP/gRPC non-2xx, deadline, unavailable, or timeout responses; DB/outbox stuck, skipped, duplicate, or prematurely-completed records; broker returned/nacked/unroutable publishes; webhook delivery failures; scheduler missed/overlapping runs.
   - Apply RabbitMQ/AMQP checks only when the component uses that path. Then include `BasicReturnMessage`, `NO_ROUTE`, `basic.return`, `returned`, `unroutable`, publisher confirms, mandatory-publish failures, DLX growth, and queue lag.
3. Monitor Datadog first, then corroborate.
   - Use Datadog logs/APM/metrics/monitors/deployment markers as the primary signal when available.
   - Corroborate with read-only database queries for skips, divergent state, stuck records, terminal failures, or suspicious growth.
   - For any delivery pipeline, compare transport evidence with the durable state of record. A record marked delivered, published, completed, or notified after a transport failure is a delivery anomaly, even if Datadog labels the log as `warn` and the backlog is empty.
   - For transactional outbox relays, specifically corroborate returned/unroutable publish warnings against outbox rows and archive tables.
   - Use Kubernetes read-only evidence for image tag, pod health, restarts, events, and recent logs.
   - Use broker-specific read-only evidence only when a broker is part of the path: queue/topic depth, publish/consume rates, redeliveries, confirms, consumer lag, dead-letter growth, and binding/subscription health.
4. Link errors to GitHub.
   - For every new or materially worse error signature, map stack traces, logger names, endpoint names, job names, SQL names, or package paths to files using local repo search.
   - Use `git blame`, `git log`, PR metadata, and `gh pr view`/`gh search` when available.
   - Report the best GitHub link: PR, commit, file path, or issue. If no exact link exists, say what was searched and why the mapping is unresolved.
5. Summarize on cadence.
   - Every interval, send a concise pill:
     - `STATUS`: OK, WATCH, BAD, or STOP-THE-LINE
     - `WINDOW`: time range monitored
     - `DELTA`: current vs baseline
     - `EVIDENCE`: top 3 signals with source names
     - `ACTIONS`: what is being checked next
   - Do not dump raw logs unless the user asks or the snippet is decisive.

## Parallel Investigation

Use subagents or parallel tool calls for read-heavy, bounded evidence tasks when the client supports them and they materially speed up investigation.

Good splits:

- Datadog investigator: logs, APM, metrics, monitors, error signatures, baseline deltas.
- Database investigator: read-only queries for stuck, skipped, duplicated, terminal, divergent, or high-growth records.
- Runtime investigator: Kubernetes health plus the relevant delivery substrate, such as broker queues/topics, HTTP/gRPC upstreams, scheduler jobs, or webhook delivery state.
- Code/GitHub investigator: map error signatures to files, commits, PRs, and owners.

Rules:

- Keep final synthesis in the main thread.
- Give each worker a narrow task, exact time window, service, environment, and required output format.
- Copy the Safety Contract's read-only rules into every subagent prompt: the subagent is read-only, its evidence envelope is the one established for this watch, and it must not execute any mutation. A subagent that never saw the contract is not bound by it.
- Do not spawn write-heavy agents during a deployment watch.
- Do not duplicate the same investigation across workers.
- Close subagents when their evidence is integrated.

## Alerting

Trigger an immediate alert when any of these occur:

- new error signature after deploy
- error, warning, or skipped-work volume materially exceeds baseline
- divergence from the comparison window in DB state, queue depth, latency, retries, 5xx, or job completion
- transport delivery failures such as broker returned messages, `NO_ROUTE`, unroutable mandatory publishes, HTTP/gRPC delivery failures, webhook failures, or durable records marked delivered after failed transport
- panic, fatal error, crash loop, or restart growth
- authentication, token refresh, permission, lock, timeout, deadlock, migration, schema, or data-integrity failure
- a user-defined watch condition trips

Use the local alert helper when available:

```bash
ALERT_SCRIPT="${SKILL_DIR:-$HOME/.claude/skills/deployment-monitor}/scripts/alert.py"  # set SKILL_DIR if installed elsewhere; alerts use macOS notifiers, terminal bell on other OSes
python3 "$ALERT_SCRIPT" --level BAD --title "Deployment anomaly" --service-name "svc-x"
```

Keep the audible/local alert short: `Deployment issue detected on <service_name>`. Put evidence, counts, links, and recommendations in the chat message, not in the spoken alert.

If the helper fails, fall back to the strongest available local signal: `osascript` notification, `say`, `afplay`, terminal bell, or a blunt high-visibility message in the conversation. Do not claim a real alert was delivered unless the command succeeded.

## Output Standard

- `OK`: no meaningful anomaly found; name what was checked.
- `WATCH`: suspicious but not proven broken; name the next proof needed.
- `BAD`: anomaly is real; show evidence, likely blast radius, GitHub link, and next action.
- `STOP-THE-LINE`: customer, data, payment, security, crash-loop, runaway-volume, or corruption risk; alert immediately and recommend rollback or mitigation without executing it.

Every anomaly report must include:

- time range
- affected service/env/version
- current value vs baseline
- source links or exact tool/source names
- error signature or query result
- GitHub link or unresolved mapping note
- recommended next action and whether it requires confirmation

## References

- `references/evidence-sources.md`: source selection and MCP usage expectations.
- `references/escalation-rules.md`: severity and anomaly classification.
