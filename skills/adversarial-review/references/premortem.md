# Premortem

Use this before risky work, to prevent failure that could have been predicted.

## Frame the Failure Vividly

Asking "what could go wrong?" makes people defend the plan. Saying "it failed,
why?" turns criticism into analysis. Commit to the failure as a fact:

> "It's [date 6-12 months out]. This failed completely and is being shut
> down. Finance is asking what happened. We're here to explain why."

The concrete details (the date, the money, who is asking) are what unlock
honest answers. If nothing in the failure statement stings, it isn't vivid
enough.

## Steps

1. **Define success in measurable terms.**
2. **List failure causes independently before filtering.** Each one should be
   specific enough to act on. Not "timeline", but "we underestimated the bank
   integration and missed the settlement cutover".
3. **Classify each cause:**
   - **Real threats:** plausible, damaging, actionable.
   - **Noise:** scary but unlikely or unactionable. Drop these.
   - **Avoided truths:** what everyone suspected but nobody said aloud. This
     is the premortem's real payload.
4. **For the real threats and avoided truths, write down** the impact, the
   detectability, and the evidence for each. Likelihood gets a number only
   when a source backs it; otherwise write `UNDETERMINED`.
5. **Turn the top threats into controls**, each with an owner and a
   validation test. A design promise is not a control.
6. **Define launch gates and rollback triggers.**

## Framing Mistakes

- Hedging with "might" instead of "did" collapses the technique.
- Blaming only external factors ("the market changed") instead of "we didn't
  adapt".
- Stopping at surface reasons ("the timeline slipped") instead of "we
  underestimated X because Y".

## Template

```markdown
## Success Definition

## Failure Story

## Top Failure Causes
- Cause:
  Class: real threat / avoided truth
  Evidence:
  Impact:
  Detectability:
  Likelihood: sourced number, or UNDETERMINED
  Prevention:
  Detection:
  Owner:

## Launch Gates

## Rollback Triggers
```

The template is a thinking tool. Report its conclusions through the output
contract in SKILL.md.
