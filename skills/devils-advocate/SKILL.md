---
name: devils-advocate
description: "Argue the opposing position: construct the strongest possible case for the alternative or against a pending decision. Use for make the case for NOT doing this, argue the other side, steelman the alternative, what would critics say. Produces an opposing-counsel brief, not a code review. For evidence-based critique of your own work, plans, or PRs use godfly; for attack-path and launch-readiness review use red-blue-review; for imagining failure before starting use premortem-postmortem."
allowed-tools: Read
---

# Devil's Advocate - Opposing Counsel

A decision is about to be made. Your job is to argue the other side like you actually believe it. Not to nitpick the chosen path - to build the strongest possible case that the alternative is right, or that the decision shouldn't happen at all. Better to hear the opposition in the lab than from reality in production.

## Core Principle

**Steelman the alternative, don't strawman it.** A devil's advocate who argues half-heartedly is worse than none - it inoculates the decision against real opposition without testing it. Argue as if you were paid to win.

## The Opposing-Brief Protocol

### 1. State the Position Being Opposed

One sentence. Name the decision, the chosen path, and what it's being chosen over.

> "The team is about to migrate the billing service to event sourcing instead of keeping the current CRUD model."

If you can't state it in one sentence, the decision isn't crisp enough to oppose - sharpen it first.

### 2. Build the Brief

Argue for the other side across four fronts:

- **Attack the load-bearing assumptions.** Every decision rests on a few claims that, if false, collapse the whole case. Name them explicitly and argue why each could be wrong. Not the peripheral assumptions - the ones the decision cannot survive without.
- **Present the alternative's genuine benefits.** What does the rejected path actually do well? Argue its merits as its best advocate would - concrete benefits, not faint praise. If the alternative is "do nothing," argue the real value of the status quo: stability, optionality, resources freed for other bets.
- **Name the costs and irreversibilities of the chosen path.** What does this decision spend that can't be recovered - time, money, credibility, architectural flexibility? Which doors does it close? One-way doors deserve far harder opposition than two-way doors.
- **State the conditions under which the opposition wins.** Under what circumstances does the alternative turn out to be right? Be specific: "If migration takes longer than one quarter," "if the vendor raises prices," "if the team loses its one event-sourcing expert." These are the scenarios where this brief becomes prophecy.

### 3. Close with an Honest Verdict

The brief is adversarial; the verdict is not. Step out of role and answer:

- **Is the opposing case strong enough to change the decision?** Yes, no, or yes-with-conditions. Say it plainly.
- **What evidence would settle it?** Name the cheapest test, data point, or spike that would decide between the two positions. Every unresolved argument should end with a way to resolve it.

## Guidelines

1. **Argue to win, judge to be fair** - Full commitment in the brief, full honesty in the verdict
2. **Separate creation from opposition** - Don't devil's advocate while the idea is still being formed
3. **Oppose the decision, not the decider** - This is about better outcomes, not scoring points
4. **Concrete beats abstract** - "This locks us into vendor X's pricing" lands; "this reduces flexibility" doesn't
5. **End with a path to resolution** - A brief that can't be settled by evidence is just an opinion with formatting

## When This Skill Works Best

- High-stakes decisions with limited reversibility
- When the room agrees too quickly and nobody has argued the other side
- When "the alternative" was dismissed without ever being seriously argued
- "Everyone knows we should do X" moments - especially those
- Before committing to a vendor, architecture, migration, or strategy

## Warning Signs You Need This

- "It's obviously the right call"
- "We already decided this" (but nobody remembers the case against)
- The alternative was rejected in one meeting with no advocate
- You catch yourself avoiding the strongest counterargument

## Not This Skill's Job

- **Critiquing your own work, plans, or PRs** - that's evidence-based review, use **godfly**
- **Attack-path and launch-readiness review** - use **red-blue-review**
- **Imagining failure before starting a project** - use **premortem-postmortem**; if you need help making the failure scenario vivid, see [cookbook/pre-mortem.md](./cookbook/pre-mortem.md)

## The Right Mindset

Devil's advocacy is an act of care, not contrarianism. If the decision is right, it deserves to win against the strongest opposition available - and if it's wrong, better to lose the argument now than the quarter later. The goal is never to kill decisions; it's to make sure the ones that survive deserved to.

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
