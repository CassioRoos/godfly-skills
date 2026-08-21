# Commands — Full Walkthroughs

The hub lists the commands one line each. This leaf holds the step-by-step
process for each, plus the question style used when input is needed.

## *spar {topic}

1. **Absorb** -- Read the actual code/plan/design. Check the verdict graph for
   prior settled claims (recipe in the hub's Protocol step 1)
2. **Steelman** -- The Steelman Guarantee: your ask, your strongest case, your
   broadest invariant checked first
3. **Assumptions** -- Surface and rate hidden assumptions (read `assumptions-check` skill)
4. **Investigate** -- Gather evidence from codebase, web, precedents (read `evidence-grounding` skill)
5. **Challenge** -- Evidence-backed challenges, one at a time
6. **Rounds** -- Back and forth. Evidence decides.
7. **Synthesize** -- Something better than either starting point. Write settled
   claims as verdict nodes (read `verdict-graph.md`)

## *review

1. **Read** -- The real code/design. Not the summary. PR, branch, or incident
   fix? The gate in `pr-incident-gate.md` is non-skippable.
2. **Steelman** -- What is this change trying to achieve, at its strongest?
   What would make it right?
3. **Assumptions** -- What is this code assuming? (read `assumptions-check` skill)
4. **Evidence** -- Search codebase for patterns, check for known failure modes
   (read `evidence-grounding` and `failure-analysis` skills)
5. **Position** -- What I'd change and why, with evidence
6. **Challenges** -- the hub's Challenge Structure format. Live sparring:
   one at a time, resolved, then next. One-shot deliverable: ordered by
   severity, each standing alone so any can be dropped without orphaning
   the rest.
7. **Verdict** -- What survived, what changed, what I'd still fight about,
   and the minimum bar to proceed **in dependency order** (a fix that
   silently no-ops without a prerequisite migration is listed after it).
   Settled claims go to the verdict graph.

Deliverable discipline: FMEA tables, gate matrices, and pre-mortems are
analysis tools, not deliverables -- surface their conclusions, and include the
full artifact only when it changes what the reader does next. Sanity-check
framework output against judgment: if RPN ranks a missing metric above a live
money bug, the score is an artifact -- say so or reorder. Target a review
another engineer absorbs in five minutes; every finding stated once, in the
section where it lands hardest.

## *assumptions

1. Extract all assumptions (technical, user, business, team, environment)
2. Rate each: verified / confident / uncertain / untested / fragile
3. For uncertain/untested/fragile: invert, find evidence, propose test
4. Produce the assumptions brief
5. Read `assumptions-check` SKILL.md and cookbook

## *alternatives

1. List 3-5 genuinely different approaches (not strawmen)
2. Each must be real -- used in production somewhere
3. Build evidence matrix: what supports/contradicts each
4. Identify most diagnostic evidence
5. Recommend with reasoning and conditions for switching
6. Read `competing-hypotheses` SKILL.md and cookbook
7. The recommendation is verdict-shaped (position + flip condition) -- write
   it as a verdict node (read `verdict-graph.md`)

## *fail

1. Identify specific failure modes (not vague risks)
2. FMEA: rate severity x probability x detectability
3. Trace dependency chains
4. Check for known failure patterns (thundering herd, poison pill, etc.)
5. Prioritize by RPN, focus on silent failures
6. Read `failure-analysis` SKILL.md and cookbook
7. Failure modes someone will re-litigate get verdict nodes (read
   `verdict-graph.md`)

## *pre-mortem

1. Set the scene: "It's [future date]. This failed completely."
2. Generate failure causes independently
3. Classify: Tigers (real threats), Paper Tigers (noise), Elephants (avoided
   truths nobody wants to say)
4. Mitigate Tigers and Elephants. Ignore Paper Tigers.
5. Read `premortem-postmortem` SKILL.md for the full process and launch gates

## *invert

1. Define success clearly
2. Invert: "To guarantee failure, I would..."
3. Check: "Are we accidentally doing any of these?"
4. Fix what we found

## Question Style

No forty-one one-by-one questions unless the user explicitly wants an interview
grind. Default is grouped questions by decision branch:

```markdown
## Position I Think You Are Taking

## Evidence Already Checked

## Decision Branches

### 1. [Branch name]
- What I need from you:
- My recommended answer:
- Why this branch matters:
- Fastest validation:
```

One follow-up at a time only when the next answer controls the entire branch.
