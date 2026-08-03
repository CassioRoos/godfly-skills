# Oracles — How You Know It Is A Bug

An oracle is a means by which you **recognize** a problem when you encounter
one. It is not a means of determining correctness. Nothing tells you a system
is right; oracles only tell you when something looks wrong.

Every oracle is an **inconsistency claim**. You are never saying "this is
wrong." You are always saying "this is inconsistent with *that*", and naming
the *that* is the whole discipline.

Adapted from Michael Bolton's FEW HICCUPPS
(<https://developsense.com/blog/2012/07/few-hiccupps>), part of Rapid Software
Testing by James Bach and Michael Bolton.

## The oracles

| | Oracle | The claim you are making |
|---|---|---|
| **F** | Familiarity | Consistent with a *known failure pattern* — this resembles a class of bug I have seen before |
| **E** | Explainability | Inconsistent with any coherent explanation I can give of the behaviour |
| **W** | World | Inconsistent with observable facts about the world |
| **H** | History | Inconsistent with how the product behaved before |
| **I** | Image | Inconsistent with the reputation the organisation wants |
| **C** | Comparable products | Inconsistent with how similar systems behave |
| **C** | Claims | Inconsistent with a spec, doc, help text, ticket, or a statement someone made |
| **U** | User desires | Inconsistent with what a reasonable user would want |
| **P** | Product | **Internally** inconsistent — a sibling endpoint, screen, or field behaves differently |
| **P** | Purpose | Inconsistent with the system's explicit or implicit intended use |
| **S** | Standards & statutes | Inconsistent with a law, regulation, or formal standard |

## The rule

Never report a bug without naming its oracle. Write every finding as:

> **Observed** *X*. **This is inconsistent with** *&lt;oracle&gt;* **because** *&lt;evidence&gt;*.

Prefer oracles backed by an artifact you actually read:

- **Claims** — quote the spec line, the doc sentence, the ticket text.
- **History** — cite the prior behaviour, commit, or release note.
- **Product** — cite the sibling that behaves differently, by name.
- **Standards & statutes** — cite the rule, and see the warning below.

## The downgrade rule — this is the one that matters

**If the only oracle you can name is Familiarity or World — "this isn't how
software usually works" — it is not a bug. It is a question for the team.**

That prior is exactly where a confident, fluent, wrong finding comes from. It
is the mechanism behind AI-generated bug reports that use correct technical
vocabulary, cite real functions, describe plausible scenarios, and are
substanceless. In 2026 the curl project shut down its bug bounty over precisely
this pattern. A finding whose only backing is "models like me expect otherwise"
belongs in **Issues**, phrased as a question, every time.

## Oracles are fallible, and that cuts both ways

Bolton's own caveat: oracle principles are *"fallible and context-dependent; to
be applied, not followed."*

- A **Claims** oracle is worthless if the spec is stale. Old spec, current code:
  the finding may be that the spec is wrong.
- A **Comparable products** oracle assumes the comparison is apt.
- An **Image** oracle needs brand context you probably do not have. Usually skip it.

**When the oracle and the product disagree, one of them is broken and you do not
yet know which.** Say that, rather than assuming the product lost.

## Regulated domains: the oracle is often outside the code

In clinical, legal, financial, safety, and public-sector systems the correct
behaviour is frequently defined in a statute, a standard, a clinical protocol,
or a court rule — not in the repo. There, neither the spec nor the code is the
oracle.

If a rule of that kind is load-bearing for a finding: **name it, cite it if you
have it, and ask if you do not.** Never infer a regulatory or clinical
requirement from general knowledge and report it as established fact. Being
confidently wrong about a statute is worse than finding nothing.

## Deriving oracles when there is no spec

Common, and not a blocker. In rough order of strength:

1. **Internal consistency (Product).** Two endpoints, two screens, two records
   that should agree. The strongest oracle available without documentation,
   because both sides are observable.
2. **Metamorphic relations.** You may not know the right output, but you know
   how outputs must *relate*: all pages concatenated equal the unpaginated
   result; two mutually exclusive filters return disjoint sets; a narrowing
   filter returns a subset; splitting an operation N ways equals doing it once.
   Violations are defects without knowing any correct value.
3. **Conservation and the harm model.** From `attack-design.md` — whatever the
   system's unit of value is, it should not be created or destroyed by an
   operation that is not supposed to create or destroy it.
4. **Round-trip.** Export then import, do then undo, encode then decode.
5. **A reference model you wrote.** For a well-understood core, a hundred lines
   replaying operations in order and comparing results — including error codes —
   is a real oracle and often the only one that catches ordering bugs.

## Record it

Every test case and every finding records the oracle it used. A case without a
recorded oracle cannot be re-judged later: a future run sees the assertion but
not *why* that was the expected value, and cannot tell a real regression from a
changed intention.
