# Evidence-Backed Five Whys

Reach the systemic cause by repeatedly asking "why?" — but every answer must be backed by evidence. Originally from Toyota's manufacturing process; hardened here so the chain is a proof, not a story.

## When to Use

- The failure already happened and the immediate mechanism is understood
- The same problem keeps recurring despite fixes
- You need to explain *why it was possible*, not just *what broke*

## The Evidence Rule

Every "why" answer must cite at least one of:

- A **log line** (with timestamp and source)
- A **code path** (file:line, commit, or function)
- A **config value** (key, value, where it's set)
- A **data record** (query result, row, metric reading)
- A **timeline fact** (deploy time, alert time, change event)

**No evidence → not a causal link.** Record the answer anyway, but mark it `[ASSUMPTION]` and treat everything downstream of it as provisional until verified. A chain built on an assumption produces a hypothesis, not a root cause.

## The Process

### Step 1: State the Problem Clearly

Define what happened in specific, observable terms.

**Bad problem statements**:
- "Performance was bad" (vague)
- "The system didn't work" (undefined)

**Good problem statements**:
- "p99 latency exceeded 5s from 14:02 to 14:41 UTC on the checkout service"
- "Deployment of release 4.2.1 failed 3 times on 2026-06-28"

### Step 2: Ask "Why?" — With Evidence at Every Link

**Format**:
```
Problem: [Observable problem]
Why 1: [Cause] — evidence: [log/code/config/data/timeline]
Why 2: [Deeper cause] — evidence: [...]
Why 3: [Deeper still] — evidence: [...]
...
Why n: [Systemic cause the team can change]
```

Gather evidence as you go: grep logs, read the code path, diff the config, query the data, reconstruct the timeline. If a link cannot be evidenced, mark it `[ASSUMPTION]` and note what would verify it.

**Tips for asking why**:
- Follow the chain of causation, not blame
- "I don't know" is a signal to go collect evidence, not to guess
- Sometimes you need more than 5 whys, sometimes fewer

### Step 3: Stop at a Changeable Cause — Never at "Human Error"

The chain terminates when it reaches a cause the team can actually change: a process, a design decision, a constraint, a missing guardrail.

- "Why? Because someone made a mistake" is **not** a stopping point. Ask: why was the mistake possible? Why did nothing catch it? The root is the system that let the error matter.
- "Why? Because the vendor/library behaves this way" is only a root if the team can respond to it (wrap it, replace it, guard it) — the changeable cause is the team's exposure to that behavior.

**Root cause tests**:
- If we change this, does the original problem class go away?
- Can we go deeper with evidence? (If yes, keep going)
- Is this within the team's power to change?
- Does this explain other related failures?

### Step 4: Branch When Causes Branch

Real failures rarely have a single cause. When a "why" has multiple evidenced answers, follow each branch to its own root.

```
Problem: Deployment failed
├── Why? Tests failed — evidence: CI run #4812 log
│   ├── Why? Test env differs from prod — evidence: env diff, missing FEATURE_X flag
│   │   └── Why? Env setup is manual — evidence: no IaC for test env in repo
│   │       └── Root: no infrastructure-as-code for test environments
│   └── Why? New test was flaky — evidence: passes 7/10 reruns
│       └── Why? Test races on async write — evidence: the test at line 141 does not wait for the write
│           └── Root: missing async-safety convention in test guidelines
└── Why? Deploy script errored — evidence: deploy.log line 233
    └── Why? Script not updated for new service — evidence: git log, script last touched 4 months ago
        └── Root: no checklist item linking new services to deploy script
```

Roots from branches that enabled or amplified — but didn't directly cause — the failure go in the **contributing factors list**.

## Output Contract

Every Five Whys analysis produces:

**1. Causal chain table**

| Link | Claim | Evidence | Status |
|------|-------|----------|--------|
| Symptom | [observable problem] | [metric/log/timeline] | verified |
| Why 1 | [cause] | [log line / code path / config / data / timeline fact] | verified |
| Why 2 | [cause] | [...] | verified / ASSUMPTION |
| ... | ... | ... | ... |
| Systemic cause | [changeable process/design/constraint] | [...] | verified |

One table per branch, or a tree plus per-link evidence.

**2. Contributing factors list** — branch causes that enabled or amplified the failure, each with evidence.

**3. Recommended fix targets** — for each root: what to change (process, design, constraint), and what evidence shows the change addresses the root. Never "be more careful".

## Common Mistakes

- **Stopping too early**: Surface causes feel like root causes
- **Stopping at human error**: "Someone made a mistake" is a symptom of a missing guardrail
- **Narrative links**: A plausible story is not a causal chain — no evidence, no link
- **Single chain thinking**: Missing that multiple factors contribute
- **Unlabeled assumptions**: An unverified link silently poisons everything below it
- **Asking "who" instead of "why"**: This is about systems, not people

## When Five Whys Isn't Enough

Five Whys works best for traceable cause-and-effect. For failures with many interacting factors, build the branched tree first, and consider fault tree analysis or the failure-analysis skill for systematic failure-mode coverage. Five Whys is the spine of the analysis, not always the whole skeleton.
