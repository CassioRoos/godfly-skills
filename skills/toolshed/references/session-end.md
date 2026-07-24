# Session end (default — always this)

Default close of a work session is **thin**. It does not dump ledgers into
chat. It updates the files that survive into the next session.

Do **not** produce a full closeout packet unless a trigger in
[`full-packet.md`](./full-packet.md) fires.

## Required acts (in order)

1. **Flush records** — any decision/question/evidence produced this session
   that is still only in chat lands in D/Q/E (or is linked from a PR/CI note).
2. **Update STATE.md only:**
   - one-line **Status**
   - **Now / Next / Blocked** (short bullets)
   - one **Session log** line: `YYYY-MM-DD — <what changed, highest gate, next>`
3. **Chat reply (first screen only):**
   - Verdict (done / not done)
   - Primary blocker (or `None`)
   - Exact next gate + who acts
   - Pointers: `docs/work/<slug>/STATE.md` (+ E/D/Q or PR IDs if material)

## Forbidden at default session end

- Pasting the full evidence appendix into chat
- Re-serializing every E-NNN / W-NNN into STATE.md
- Embedding a "Canonical closeout packet" section inside STATE.md
- Declaring the toolshed closed (that is `/toolshed close`)

## If the next human/agent only reads chat

They still get verdict + blocker + next gate. Everything else is in files or PR.
Off-repo portable note → **handoff** skill — do not fatten STATE.md.
