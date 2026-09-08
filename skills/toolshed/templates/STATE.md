# {{SLUG}} — toolshed state

**Read this file first in every session, any model**, then the records:
[decisions.md](./decisions.md) · [questions.md](./questions.md) ·
[evidence.md](./evidence.md). Convention: [./TOOLSHED.md](./TOOLSHED.md).
**Shape law:** resume surface, soft cap ~120 lines — ledgers live in D/Q/E, a
full packet in `packet.md`, never here (`assert-state.sh` warns).

- **Goal:** {{GOAL}}
- **Ticket:** _none yet — attach here if/when one exists_
- **Opened:** {{DATE}} · **Repo:** {{REPO}} · **Convention:** v{{VERSION}}
- **Status:** understanding
- **Verified:** _(none yet — e.g. `build+test green @ <sha>, branch <b>, tree clean`)_
- **Behavior changes shipped:** _(none yet — one line per user-visible or
  contract change this task shipped; a rule that lives only in the code is what
  the next session pays for)_

## Understanding (evidence before proposal — the gate)

> Replace this placeholder during orient. A toolshed whose Understanding is
> still template text is **not started** (`assert-started.sh` fails). Write:
> what exists today (file:line), what is assumed (rated: verified / uncertain /
> untested), what is unverified and how to verify it. No proposal work until
> an owner has seen this section.

_(not yet written)_

## Now / Next / Blocked

Keep short. Point at record IDs or PR checks; do not restate ledgers.

- **Now:** orient — fill Understanding, then `assert-started.sh {{SLUG}}`
- **Next:** —
- **Blocked:** —

## How to verify (keep runnable)

> Commands a fresh session can run blind (tests, curls, queries). PR/CI links OK.

_(none yet)_

## Session log (append-only, one line per session)

- {{DATE}} — seeded (toolshed v{{VERSION}}).
