---
name: handoff
description: >
  Create a compact handoff document for another agent session to continue
  the work. Use when the user asks for a handoff, next-agent context, continuation
  note, session summary, resume brief, or wants another agent to pick up without
  reconstructing the thread.
metadata:
  version: "1.0"
---

# Handoff

Write a handoff that lets a fresh agent continue without spelunking the entire conversation.

## Workflow

1. Identify what the next session will do. If the user gave a focus, tailor the handoff to that.
2. Save the handoff outside the current repository in a durable location: `~/.agent-handoffs/` (create it if missing), named `<YYYY-MM-DD>-<short-slug>.md`. Never use the OS temporary directory — a handoff that must survive into a future session cannot live somewhere the OS wipes.
3. Include only operationally useful context. Do not duplicate artifacts that already exist; reference paths, PRs, commits, docs, logs, or notebooks instead.
4. Redact secrets, tokens, credentials, private personal data, and unnecessary customer data.
5. Include suggested skills and why they should be used.
6. Include exact commands already run only when they matter for continuation or verification.

## Output Shape

```markdown
# Handoff: [short title]

## Next Goal

## Current State

## Key Decisions And Evidence

## Files, Branches, PRs, Or Artifacts

## Commands Already Run

## Suggested Skills

## Risks And Open Questions

## Recommended Next Steps
```

## Composition with toolshed

- **In-repo multi-session task state** lives in `docs/work/<slug>/` via the
  **toolshed** skill (thin STATE + D/Q/E). Prefer updating toolshed
  session-end over writing a fat handoff when the next agent will open the
  same repo.
- **Handoff** is for **off-repo** or cross-machine continuation: no clone,
  toolshed gitignored/local-only, or a compact note outside the tree.
- Do **not** re-serialize a full toolshed closeout packet into the handoff.
  Point at `docs/work/<slug>/STATE.md`, PR URLs, and SHAs.
- **Not** the Workbench product/MCP (Slack/highlights app).

## Rules

- Keep it compact.
- Prefer links, paths, commit SHAs, and command names over prose.
- Distinguish verified facts from assumptions.
- Say where the file was saved.
- Suggested skills should use current names (`toolshed`, not `workbench` for task state).
