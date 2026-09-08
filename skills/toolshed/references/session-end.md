# Session end (default — always this)

Default close of a work session is **thin**. It does not dump ledgers into
chat. It updates the files that survive into the next session.

Do **not** produce a full closeout packet unless a trigger in
[`full-packet.md`](./full-packet.md) fires.

## Required acts (in order)

1. **Flush records** — any decision/question/evidence produced this session
   that is still only in chat lands in D/Q/E (or is linked from a PR/CI note).
2. **Verify, then record the git facts.** Run the repo's build/test if it is
   runnable, and write the result into STATE's **Verified** line as facts a
   resumer would otherwise have to reconstruct from git:
   `verified: build+test green @ <sha>, branch <b>, tree clean`. If it is not
   runnable, say so and why (`not runnable: <reason>`) — never leave it implying
   a green run that never happened.
3. **Update STATE.md only:**
   - one-line **Status**
   - **Verified** (above) and **Behavior changes shipped** — one line per
     user-visible or contract change this task actually shipped. A normalization
     rule that exists only in the code is the gap that costs the most later.
   - **Now / Next / Blocked** (short bullets)
   - one **Session log** line: `YYYY-MM-DD — <what changed, highest gate, next>`
4. **Chat reply (first screen only):**
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
