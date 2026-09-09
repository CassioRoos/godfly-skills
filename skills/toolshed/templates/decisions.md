# {{SLUG}} — decisions (proto-ADRs)

Upsert-only. Contract-changing decisions promote to their permanent home the
moment they are decided (boundary rule — see [./TOOLSHED.md](./TOOLSHED.md)),
**in the same PR as the change they govern**. At close, `decided` records
transform into ADRs; keep them ADR-shaped as you write them and close-out is
mechanical.

**Scope bar:** record a decision when it is hard to reverse, spans components,
or affects security/operability. Trivial choices don't get records — archive
sprawl kills the practice as surely as missing records do.

**No advocacy documents:** every record needs ≥2 real options and at least one
honest downside of the chosen one. A decision with zero admitted negatives is
a sales pitch, and engineers learn to distrust the whole ledger.

<!-- Record skeleton — copy, increment, fill:

### D-001 — <one-line decision>
- **Status:** proposed · **Date:** YYYY-MM-DD
- **Context:** <the forcing situation, in two sentences>
- **Options:**
  1. <option> — for: … / against: …
  2. <option> — for: … / against: …
- **Encouraged option:** <n> — wins on <dimensions>. **Flip condition:** <what
  evidence/event would reverse this>.
- **Consequences:** <what this commits us to>
- **Evidence:** E-00x, E-00y, and/or PR/CI links
- **Commits:** <hash(es) once implemented>
- **History (YYYY-MM-DD):** <status changes, corrections — appended, loud>
-->

_(no decisions yet)_
