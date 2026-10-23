---
name: bdd
description: Behaviour-driven development, the method, not the tool. Use whenever the work involves acceptance criteria, examples, scenarios, Gherkin or .feature files, "given when then", example mapping, or deciding what "done" means for a story. Use it to discover rules and examples from a ticket, write scenarios, review scenarios someone else wrote, or decide what to do with a failing or stale scenario.
---

# BDD

Three practices, in this order: discover, write, automate. Conversation beats capture
beats automation. Gherkin is the output of step two, never the method.

## Discover first

- Map the story before writing a single scenario: rules (the acceptance criteria), one
  or more concrete examples under each rule, and questions nobody can answer yet.
- Stop and ask when a rule has no example or an example has no agreed outcome. Never
  invent the outcome.
- More than six rules, or a wall of questions, means the story is too big. Split it
  along business lines, never technical ones.
- Skip scenarios for work everyone already understands. For highly uncertain work,
  spike first, write scenarios once the uncertainty is gone.

## Write

- One `Feature` per file, one `Rule:` per acceptance criterion, one scenario per
  example. Titles differ enough to tell scenarios apart by title alone.
- Given, When, Then, in that order, once each. One `When`: a single event. Givens are
  all of, and no more than, the context the outcome needs.
- `Then` is an outcome a reader can check from the text. Never internal state, never
  "it works".
- Declarative, in domain language. If the wording would change when the UI changes,
  it is wrong. No clicks, selectors, URLs, SQL, endpoints.
- Real values: "7 days late", "paused at 08:57". No foo, bar, test, TBD.
- Third person, present tense, one stable term per concept across the whole file.
- Three to five steps. Background under four lines, only for setup every scenario
  shares. Scenario Outline only when the behaviour varies by input.
- At least one failure path. When the repo has a convention for tracing scenarios to
  acceptance criteria or tagging failure paths, follow it.

## Review

- Check the rules above, then ask of each scenario: is it a concrete domain example or
  a tautology? Could a different outcome follow from the same givens? Would a product
  owner read it and object to a term?
- Report each finding as one sentence naming the problem, one on why it matters if
  needed, and the smallest fix. Say nothing when unsure.

## Evolve

- A failing scenario means one of three things. A bug: fix the code. The behaviour
  moved: move the scenario. The behaviour is no longer wanted: delete the scenario
  and say so.
- Refine wording as gaps surface. Automation changes under the scenario, never the
  scenario's words to suit the automation.
- A renamed concept is renamed in every scenario, or not at all.
- The spec is not the end of the conversation. When a scenario surprises someone,
  go back to discover.
