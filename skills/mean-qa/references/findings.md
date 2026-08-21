# Findings — what earns the right to be reported

A run produces **candidates**. This produces **findings**. The tail gets dropped,
not appended as "minor observations".

The cost model is asymmetric: one false finding costs a reader seconds, a hundred
cost you the reader permanently. In 2026 the curl project ended its bug bounty
after AI-generated submissions overwhelmed it — roughly a fifth showed AI
hallmarks, about one in twenty was genuine. The reports were not gibberish. They
used correct terminology, cited real functions, described plausible scenarios.
**Fluency is not evidence.**

## Name the oracle, or it is not a defect

An oracle is how you **recognise** a problem — never a means of determining
correctness. Nothing tells you a system is right. Every oracle is an
**inconsistency claim**: you are never saying "this is wrong", you are saying
"this is inconsistent with *that*", and naming the *that* is the discipline.

Write every finding as: **Observed** *X*. **This is inconsistent with** *&lt;what&gt;*
**because** *&lt;evidence&gt;*.

Prefer an oracle backed by an artifact you actually read — a quoted spec line, a
cited prior behaviour, a named sibling endpoint that differs, a cited standard.

**The downgrade rule.** If the only thing you can point at is "this isn't how
software usually works", **it is not a defect — it is a question for the team.**
That prior is exactly where a confident, fluent, wrong finding comes from. File
it as a question, every time.

**When the oracle and the product disagree, one of them is broken and you do not
yet know which.** Say that, rather than assuming the product lost. An old spec
against current code may mean the spec is the defect.

### Deriving oracles when there is no spec

In rough order of strength: **internal consistency** (two endpoints, two screens,
two records that should agree — strongest available without documentation,
because both sides are observable) · **metamorphic relations** (all pages
concatenated equal the unpaginated result; two exclusive filters return disjoint
sets; a narrowing filter returns a subset) · **conservation** (the system's unit
of value is not created or destroyed by an operation that should not) ·
**round-trip** (export then import, do then undo) · **a reference model you
wrote**.

## Defects and questions, separately

- A **defect** is a concern about the product.
- A **question** is about the testing or the project — something you could not
  determine, an ambiguity, a missing credential, a testability gap.

"How is this supposed to behave at the boundary?" is a question. "It behaves
differently at the boundary than the spec states" is a defect. Collapsing the two
is the most common way QA output turns to noise. An agent's uncertainty naturally
produces more questions than defects; that is a normal, honest run.

**Anything that fails reproduction is a question, not a defect.**

## Before emitting a defect

- **Reproduce it twice from a clean state**, with the exact steps recorded. No
  "sometimes", no "appears to".
- **Minimise it.** Bisect to the smallest sequence that still fails. An unshrunk
  repro gets closed as "cannot reproduce" and takes your credibility with it.
- **Find the worst consequence**, not the first one you saw.
- **Check one sibling surface** — the adjacent endpoint, the same operation under
  another role — and report the true scope.
- **State impact through a named stakeholder**: who is harmed, how badly. Not
  "severity: high".
- **Neutral tone.** No blame, no adjectives doing work evidence should do.

The worst-consequence and sibling checks require *additional experiments*. Under
output pressure the failure mode is to narrate a plausible worst case instead of
testing it. **If you did not run it, write "not attempted."** That is honest and
costs nothing. Inventing it costs everything.

## Proof standard

A finding is proven when there is an observation that **would have come out
differently if the defect were absent.**

- The strongest form is fail-to-pass: a test failing on current code, passing
  once fixed. Demonstrate the failing state first.
- A check that cannot fail is not evidence. If your probe returns the same result
  whether or not the bug exists, it has no positive control.
- Weak assertions — non-null, "no exception", bare 200 — are the characteristic
  defect of this category of test.

## Safety language — the highest-value rule here

Testing is not verification. Your output mixes machine-checked propositions with
a much larger volume of inference. Never conflate them.

**Banned:** "it works", "verified", "confirmed working", "no bugs", "fully
tested", "all good", "looks good".

**Required form:** *"I ran X. I observed Y. I did not observe Z. I did not test
W."*

Every clean result is **an absence of observed failure under a stated
configuration** — never the presence of correctness. "The flow worked in the
three cases I ran on staging" is honest; "the flow works" is a claim you cannot
support.

Overconfident summary is the signature defect of a fluent machine.

## Confidence

Every finding carries what would **falsify** it — the single observation that
would make you withdraw it. If nothing would, it is not a finding, it is an
opinion. Split confidence when the parts differ: "high that the path is
unguarded; medium that it has occurred in production, which depends on operator
behaviour I cannot see."
