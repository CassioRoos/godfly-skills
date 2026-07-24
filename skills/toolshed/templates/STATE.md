# {{SLUG}} — toolshed state

Convention: [../WORKBENCH.md](../WORKBENCH.md) (read it once; it is short).
**Read this file first in every session, any model.** Then work the records:
[decisions.md](./decisions.md) · [questions.md](./questions.md) ·
[evidence.md](./evidence.md).

Skill: **toolshed** (`/toolshed`). Path under **docs/**: `docs/work/{{SLUG}}/`.

**Shape law:** resume surface (soft cap ~120 lines for new toolsheds). No full
closeout packet, no evidence appendix, no W-registry dump here. Ledgers in
D/Q/E; optional ship matrix → `packet.md`. Evidence may also live in **PR/CI**.
Gates: `assert-started.sh` / `assert-state.sh` (`--soft` for legacy bloat).

- **Goal:** {{GOAL}}
- **Ticket:** _none yet — attach here if/when one exists_
- **Opened:** {{DATE}} · **Repo:** {{REPO}} · **Convention:** v{{VERSION}}
- **Status:** understanding

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
