# The Finding Gate — What Earns The Right To Be Reported

A run produces **candidates**. This gate produces **findings**. Nothing crosses
without passing, and the tail is dropped rather than appended.

The cost model is asymmetric and worth internalising: one false finding costs a
reader seconds, a hundred cost you the reader permanently. In January 2026 the
curl project ended its bug bounty after AI-generated submissions overwhelmed it
— roughly a fifth showed AI hallmarks and about one in twenty was genuine. The
reports were not gibberish. They used correct terminology, cited real functions,
and described plausible scenarios. **Fluency is not evidence.** This gate exists
so that your findings are never mistaken for that.

## Bug or Issue — separate them first

From Session-Based Test Management (Jonathan & James Bach, 2000):

- A **Bug** is a concern about the quality of the product.
- An **Issue** is a question or obstacle about the *testing or the project* —
  something you could not determine, an ambiguity in intended behaviour, a
  missing credential, a testability gap.

"How is this supposed to behave at the boundary?" is an Issue. "It behaves
differently at the boundary than the spec states" is a Bug. Collapsing the two
is the most common way QA output turns into noise, and an agent's uncertainty
naturally produces far more Issues than Bugs. That is fine. Report them as
Issues. **Anything that fails reproduction is an Issue, not a Bug.**

## RIMGEN — the gate

Cem Kaner's bug advocacy heuristic (BBST, <https://bbst.courses/rimgen/>). A bug
report is a persuasion artifact under a fix budget, not a log entry. No Bug is
emitted until every letter is satisfied.

**R — Replicate.** Reproduced at least twice from a clean state, with the exact
request, command, or step sequence recorded verbatim. No "sometimes", no "looks
like", no "appears to". If it will not reproduce, it is an Issue describing what
you saw once.

**I — Isolate.** Every unnecessary step removed and the reduction re-confirmed.
If you found it with a forty-step sequence, bisect to the minimum that still
fails. An unshrunk repro gets closed as "cannot reproduce" and takes your
credibility with it.

**M — Maximize.** Find the *worst* consequence this defect can produce, not the
first one you saw. A validation gap that returns a wrong error message may also
permit a state that corrupts data — try it.

**G — Generalize.** Check at least one sibling surface: the adjacent endpoint,
the adjacent field, the same operation under a different role, the same pattern
in a neighbouring module. Report the true scope.

**E — Externalize.** State impact through a named stakeholder's eyes: who is
harmed, how, and how badly. Not "severity: high" — *who*, and *what happens to
them*.

**N — Neutral tone.** No "obviously", no exclamation marks, no blame, no
adjectives doing work that evidence should do. The developer whose code this is
will read it.

### M and G are the two you will be tempted to fake

They require *additional experiments*. Under output pressure the failure mode is
to narrate a plausible worst case and a plausible sibling instead of testing
them. **If you did not run it, you did not maximize and you did not generalize.**
Write "not attempted" — that is honest and costs you nothing. Inventing it costs
you everything.

## Proof standard

A finding is proven when there is an observation that **would have come out
differently if the defect were absent.**

- The strongest form is fail-to-pass: a test that fails on the current code and
  passes once the defect is fixed. **Demonstrate the failing state first** — a
  test that passes on broken code proves nothing, whatever it asserts.
- A check that cannot fail is not evidence. If your probe would produce the same
  result whether the bug exists or not, it has no positive control.
- Watch for weak assertions. Non-null, "no exception thrown", bare HTTP 200 — an
  empirical study of bug-reproducing tests found weak assertions to be the
  characteristic defect of exactly this category of test. Assert the specific
  value.

## Volume discipline

More findings is not better. Generating more tests has been shown not to improve
results; precision does.

- Cap findings per report. Rank by blast radius and **drop the tail** — do not
  append it as "minor observations".
- One bug per artifact. If one flow exposes three defects, that is three
  artifacts with three IDs, not one with three paragraphs.
- Duplicate suspicion is cheap to check and expensive to skip: if it looks like
  a known bug, say so and point at the ID.

## Confidence and falsification

Every finding carries:

- **Confidence**, and what drives it — split it when the parts differ ("high
  that the path is unguarded; medium that it has actually occurred in
  production, which depends on operator behaviour I cannot see").
- **What would falsify this** — the single observation that would make you
  withdraw it. If nothing would, it is not a finding, it is an opinion.

## Safety language

Testing is not verification, and an agent's output is a mix of machine-checked
propositions and a much larger volume of inference. Never conflate the two.

**Banned:** "it works", "verified", "confirmed working", "no bugs", "fully
tested", "all good", "looks good".

**Required form:** *"I ran X. I observed Y. I did not observe Z. I did not test
W."*

Every clean result is reported as **an absence of observed failure under a
stated configuration** — never as the presence of correctness. Past tense and
explicit scope: "the flow worked in the three cases I ran on ST" is honest;
"the flow works" is a claim you cannot support.

This is the single highest-value line in this file, because overconfident
summary is the signature defect of a fluent machine.
