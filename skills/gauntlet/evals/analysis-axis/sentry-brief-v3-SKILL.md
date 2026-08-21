---
name: sentry-brief
description: >
  Turn a raw alert payload into a one-screen incident brief: blast radius,
  suspected cause, the three checks that discriminate between causes, and the
  containment action. Use when paged, when triaging an alert, or when handing
  an incident to the next responder.
metadata:
  version: "3.0"
---

# Sentry Brief

An alert is data. A brief is a decision. Convert one into the other in under
a screen.

## Rules

1. **Blast radius before cause.** Name who is currently harmed and how, before
   theorising about mechanism.
2. **Three discriminating checks.** Every suspected cause ships with the check
   that would falsify it. A check that every hypothesis passes is not a check.
3. **Containment is separate from fix.** State the action that stops harm now,
   even if it is ugly, and mark it as containment.
4. **Unknowns stay unknown.** If the payload does not contain it, write "not in
   payload". Never infer a customer count, a region, or a dollar figure.
5. **One screen.** If the brief does not fit on one screen it is not a brief.

## Output

```
IMPACT   -> who is harmed, right now, and how
SUSPECTS -> ranked causes, each with its discriminating check
CONTAIN  -> the action that stops harm now
NEXT     -> the single next diagnostic step and its owner
UNKNOWN  -> what the payload does not tell us
```
