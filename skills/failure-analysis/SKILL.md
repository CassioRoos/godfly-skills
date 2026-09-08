---
name: failure-analysis
description: Identify and prioritize concrete component and dependency failure modes, their consequences, containment and recovery. Use for FMEA, reliability assessment, single points of failure, or "how could this fail". General engineering verdicts belong to morpheus; active debugging to the troubleshooting reference in morpheus; past incident analysis to premortem-postmortem.
metadata:
  version: "1.1"
---

# Failure analysis

Produce a prioritized failure inventory grounded in the actual design/code,
not a list of imaginable disasters. Assessment does not authorize fixes,
chaos tests, live faults, deployment or data mutations.

## Consequence before arithmetic

For each credible failure mode, identify:

- Trigger and affected operation, backed by a path, artifact or stated assumption.
- Impact: who/what is harmed, blast radius, reversibility and time to damage.
- Exposure/likelihood with its evidence and uncertainty. Unknown is not rare.
- Detection and containment: does intervention occur **before** irreversible harm?
- Recovery: tested restoration/reconciliation versus merely a proposed plan.
- Existing controls, surviving gap, next proof and owner when known.

**No absolute RPN thresholds and no automatic risk acceptance.** Multiplying
ordinal severity/likelihood/detectability scores cannot decide release gates.
A catastrophic event scored 10×1×1=10 is not acceptable just because it is rare
and loud; alerting after a charge or disclosure does not undo it.

Prioritize credible uncontained irreversible harm first. Distinguish an active
incident (route to containment/troubleshooting) from a prospective release risk.
Block the affected release path when a credible severe failure lacks prevention,
bounded containment or demonstrated recovery. State what evidence clears it.
Lower-impact, recoverable degradation may be scheduled or explicitly accepted
by the authorized owner with rationale and monitoring; the skill cannot accept
risk for them. Controls that truly prevent the trigger may lower priority:
don't manufacture a blocker from severity alone.

## Dependency walk

Trace trigger → caller → storage/queue → consumer → external effect.
At each edge check failure, slowness, duplication, partial completion, exhaustion
and recovery. Follow all durable-write and retry boundaries, not just the
happy-path handler. Examples are investigation prompts, not findings.

Allocate deadlines within the end-to-end budget, propagate cancellation, and
leave time for cleanup/retries. A shorter caller deadline is not itself proof
of a bug: establish whether downstream work continues and causes harm.

## Output

Use a compact table when comparing several modes:

| Priority | Failure + trigger | Evidence / uncertainty | Consequence + existing controls | Required action / clearing proof |
|---|---|---|---|---|

Do not invent scores, frequencies, owners or successful recovery tests.
Separate observed defects from plausible risks and untested hypotheses.
Keep the conclusion scoped to inspected surfaces, not universal "release safe".

## Boundaries and optional detail

- General decision/review verdict: `morpheus`; use this skill for its detailed
  failure inventory, not a second competing verdict engine.
- Security attack paths and defenses: `red-blue-review`.
- Premortem/postmortem document and action ownership: `premortem-postmortem`.
- Failing now: [Morpheus troubleshooting](../morpheus/references/troubleshooting.md);
  understood past failure: `premortem-postmortem`; regression campaigns: `mean-qa`.
- Detailed inventories: [failure-modes.md](cookbook/failure-modes.md).
- Multi-hop failure propagation: [dependency-chain.md](cookbook/dependency-chain.md).
- Pattern prompts: [real-failures.md](cookbook/real-failures.md).
Read only the applicable reference. A catalog match is not proof.
