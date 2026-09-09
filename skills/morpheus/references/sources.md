# Sources behind the rules

Each rule in SKILL.md traces to at least one of these. Read this when the user asks why a rule
exists or proposes changing one.

## Verdict first, no preamble
- US Army AR 25-50, BLUF: main point in the first sentence; "the greatest weakness in ineffective
  writing is that it doesn't quickly transmit a focused message." https://en.wikipedia.org/wiki/BLUF_(communication)
- Amazon "Have Backbone; Disagree and Commit": challenge is a duty, but it ends in a decision.
  https://en.wikipedia.org/wiki/Disagree_and_commit

## Sycophancy and its mirror
- Sharma et al. 2023, "Towards Understanding Sycophancy in Language Models": five frontier
  assistants flip correct answers under pushback and tailor to stated beliefs; preference models
  reward it. https://arxiv.org/abs/2310.13548
- Dubois et al. 2026, UK AISI "Ask don't tell": rewriting the user's assertion as a neutral
  question beats a direct "do not be sycophantic" instruction. Sycophancy tracks assertion form and
  confidence. https://arxiv.org/abs/2602.23971v4
- Critical-persona steering reduces sycophancy without blind contrarianism, but the Mazur benchmark
  tracks a mirror failure: models that refuse to decide. https://arxiv.org/html/2605.21006v1
  https://github.com/lechmazur/sycophancy/
- Requirement-conformance review: LLMs reject correct code, and prompts demanding an explanation
  plus fix per item make it worse. https://arxiv.org/abs/2603.00539
- CriticGPT: recall vs hallucinated-bug trade-off needs a precision control.
  https://cdn.openai.com/llm-critics-help-catch-llm-bugs-paper.pdf

## Finding caps and never-flag lists
- Greptile post-mortem: "be less nitpicky" failed; self-rated 1-10 filtering failed ("nearly
  random"); only hard filtering moved the address rate from 19% to 55%.
  https://www.greptile.com/blog/make-llms-shut-up
- Anthropic code-review plugin: flag only definite compile/wrong-result/quotable-rule issues; never
  pre-existing, style, linter-catchable, or input-dependent maybes. "False positives erode trust."
  https://github.com/anthropics/claude-code/blob/main/plugins/code-review/commands/code-review.md
- Goedecke: a good review has at most five or six comments; approval means "merge even if you
  ignore my comments". https://www.seangoedecke.com/good-code-reviews/

## What review content gets acted on
- Bosu, Greiler, Bird 2015 (Microsoft, 1.5M comments): useful = functional defects, edge cases,
  right API; not useful = questions, praise, false reports, out-of-scope.
  https://www.microsoft.com/en-us/research/publication/characteristics-of-useful-code-reviews-an-empirical-study-at-microsoft/
- Google eng-practices: comment on the code not the developer, explain why, label severity;
  approve when the change improves code health, not when perfect; facts beat opinion.
  https://google.github.io/eng-practices/review/reviewer/standard.html
  https://google.github.io/eng-practices/review/reviewer/comments.html
- Conventional Comments: `label (decoration): subject`. https://conventionalcomments.org/
- RFC 2119: MUST/SHOULD only for interoperability or harm. https://www.rfc-editor.org/rfc/rfc2119

## Steelman rules
- Rapoport's rules via Dennett: restate so well the author says "I wish I'd put it that way".
  https://www.themarginalian.org/2014/03/28/daniel-dennett-rapoport-rules-criticism/
- Noah Smith, "Against Steelmanning": substituting your preferred argument for the author's is a
  failure ("sanewashing"). Preserve the real claim. https://www.noahpinion.blog/p/against-steelmanning

## Options and doors
- MADR: context, drivers, options, outcome with reason, consequences, confirmation.
  https://adr.github.io/madr/
- Google design docs: "alternatives considered" is mandatory; do-nothing and reuse are legitimate.
  https://www.industrialempathy.com/posts/design-docs-at-google/
- Bezos 2015 letter: one-way vs two-way doors; decide two-way doors with ~70% of the information.
  https://s2.q4cdn.com/299287126/files/doc_financials/annual/2015-Letter-to-Shareholders.PDF
- UK Green Book: "do minimum" always stays on the short list.
  https://www.gov.uk/government/publications/the-green-book-appraisal-and-evaluation-in-central-government/the-green-book-2020

## Voice
- Kim Scott, Radical Candor: challenge directly and care personally; obnoxious aggression is
  challenge without care; ruinous empathy is the most common failure; care is measured at the
  listener's ear. https://kimmalonescott.medium.com/what-is-radical-candor-learn-the-basic-principles-in-6-minutes-50391b3ad76a
- Bridgewater: believability-weighted opinions; cautionary evidence that blunt-without-care
  produces conformity and routing-around.
  https://factually.co/fact-checks/business/bridgewater-radical-transparency-controversies-governance-61a95e

## Skill authoring
- Anthropic skill best practices: third-person description, what plus when, under 1024 chars, body
  under 500 lines, references one level deep.
  https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
  https://code.claude.com/docs/en/skills
