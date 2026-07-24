# Full packet (opt-in only)

A reconstructable multi-gate handoff for **ship / multi-owner / multi-session
programs**. This is **not** the default end of a coding session.

## Triggers (any one — otherwise use session-end only)

1. the user explicitly asks for a full closeout, detailed handoff, or
   in-depth summary; **or**
2. `/toolshed close` is running and survivors need a gate matrix for owner
   validation; **or**
3. the task spans **multiple repos or environments** *and* merge/deploy/
   enablement gates are in play *and* the user (or program playbook) requested
   a ship-readiness packet.

**Not triggers:** toolshed active · five or more material checks · long investigation.

## Where it lives

| Surface | Rule |
|---|---|
| Chat | Progressive disclosure. First screen = verdict/blocker/next gate. |
| Repo | Prefer `docs/work/<slug>/packet.md` — **never** paste into `STATE.md`. |
| Outside repo | `handoff` skill if toolshed is local-only or next agent has no clone. |
| PR | Often better than packet.md for ship evidence of record. |

## Progressive presentation

1. **First screen:** executive verdict, blocking chain, exact next gate.
2. **Relationship view:** Mermaid only when ≥3 dependent gates — not flat inventories.
3. **Findings:** by decision/claim — conclusion, why, evidence IDs/PR links, caveat, action.
4. **Ledgers last:** evidence / work items by ID.

Reader-facing tables: ≤4 columns.

## Required schema (when triggered)

Include every applicable section. If empty, write `None` + why.

1. Executive verdict  
2. Status delta  
3. Relationship view (if non-linear)  
4. Gate path (local · PR/CI · review · merge · deploy · enablement · prod) — pin SHAs  
5. Findings and decisions  
6. Changed artifacts  
7. Work items (W-NNN) with owner/next/acceptance  
8. Rollout / rollback / safety  
9. Exact next gate  
10. Evidence appendix (or PR/CI pointers with what they proved)

## Invalid-output checks (full packet only)

- required section missing  
- first screen lacks verdict + blocker + next gate  
- STATE.md used as the packet dump  
- remote claims lack exact SHA  
- actionable work lacks owner/next/acceptance  
- "Toolshed updated" stands in for synthesis  
