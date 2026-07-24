# Constraint Challenge (First Principles)

The Five Whys chain ends at a systemic cause. This technique asks the next question: **what inherited assumption or constraint produced that cause — and does it still hold?** Instead of reasoning by analogy ("that's how it's always been set up"), reason from what must actually be true.

Most systemic causes exist because someone, at some point, accepted a constraint: a design decision, a process rule, a resource limit, a "best practice". Failures recur when that constraint outlives its justification.

## When to Use

- The why-chain terminated at a design decision, process, or limit and nobody can say why it exists
- The proposed fix works *around* the systemic cause instead of removing it
- The same class of failure keeps appearing under different symptoms
- The root cause is being defended with "that's just how it works"

## The Process

### Step 1: State the Constraint Behind the Systemic Cause

Take the systemic cause from the causal chain and name the constraint or assumption it rests on.

**Examples**:
- Systemic cause: "test env differs from prod" → Constraint: "test environments are provisioned manually because IaC was 'too heavy' for them"
- Systemic cause: "no rate limiting on internal API" → Assumption: "internal callers are trusted and well-behaved"
- Systemic cause: "single shared database credential" → Constraint: "per-service credentials were too costly to manage when the system was 3 services"

### Step 2: List the Embedded Assumptions

Write every assumption the constraint depends on.

**Questions to surface them**:
- "What had to be true for this decision to be reasonable when it was made?"
- "What are we taking for granted?"
- "What would an outsider find strange about this?"

### Step 3: Test Each Assumption Against Current Reality

For each assumption, ask: "Was this ever true? Is it still true *here, now*?" — and back the verdict with evidence, same rule as the why-chain.

| Assumption | Evidence For | Evidence Against | Verdict |
|------------|--------------|------------------|---------|
| [Assumption] | [Support] | [Counter] | Holds / Broken / Uncertain |

**Types of challenges**:
- **Empirical**: Is there data showing this is true today?
- **Historical**: Was it true when decided, and has the context changed? (Team size, traffic, scale, tooling)
- **Contextual**: True in general, but true for this system?
- **Logical**: Does the constraint even follow from the assumption?

### Step 4: Separate Real Constraints from Inherited Ones

What must be true regardless?

- **Real constraints**: physics, math, law, contractual obligation, hard resource limits. These stay.
- **Inherited constraints**: past team size, old tooling, a vendor long since replaced, a scale that no longer describes the system. These are the failure factories.

Very few constraints are real. If you can't defend one with evidence after a few whys, it's inherited.

### Step 5: Derive the Fix Target

If the assumption behind the systemic cause is broken, the fix target is the constraint itself — not another patch downstream of it.

**Questions**:
- "If this constraint were lifted, does the whole failure class disappear?"
- "What's the cheapest change that removes the broken assumption?"
- "What does keeping the constraint cost per recurrence, versus removing it once?"

**Example**:

Systemic cause: manual test-env setup → Constraint: "IaC is too heavy for test envs" → Assumptions: (a) IaC setup cost is high — was true in 2022 with 2 engineers, broken now with existing prod IaC modules to reuse; (b) test envs change rarely — broken, env diff shows 14 drift items in 3 months.

Fix target: extend existing prod IaC modules to test environments. This removes the failure class (env drift), not just this instance.

Feed the result into the output contract: the fix target goes in **recommended fix targets**, with the broken assumption and its evidence as justification.

## Tips

### Ask when the constraint was born
Constraints are usually correct for the moment they were created. Date the decision, then diff the context.

### Look for "everybody knows"
When a constraint is obvious to everyone, it's often unexamined. Obviousness is not evidence.

### Question the experts' "why"
Long-tenured owners often know *how* the system works without re-checking *why* it's shaped that way. They may be the most anchored to the inherited constraint.

### Distinguish challenge from removal
This technique tests whether the constraint still holds. Whether removing it is worth the cost is a separate decision — hand that to the fix-target recommendation with the evidence attached.

## Common Mistakes

- **Calling preferences "fundamentals"**: "We prefer monorepos" is not a law of physics
- **Ignoring real constraints**: Some things (physics, law, math, contracts) actually can't change
- **Challenging constraints unrelated to the failure**: Stay anchored to the systemic cause from the chain — this is causal analysis, not a redesign exercise
- **Throwing away valid constraints**: Sometimes the assumption still holds; verify before recommending removal
- **Infinite regression**: Stop when you reach either a real constraint or a broken assumption with a clear fix target
