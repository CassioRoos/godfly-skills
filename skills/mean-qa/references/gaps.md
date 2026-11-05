# Gaps — what the change forgot

A defect is something the running system does wrong. A gap is something the change does not do, does not test, or does not plan for. A senior QA finds gaps by reading, before running anything. Gaps go in their own report section. Never mix them into the defect list.

## 1. Trace the requirements

1. Read the ticket, the PR description and any linked spec. Copy each acceptance criterion and each Definition of Done item, word for word.
2. Give each one an ID (`AC-1`, `AC-2`, …).
3. Map each ID to the cases that prove it.
4. Read the diff. List each behaviour the diff adds or changes.
5. Compare the two lists.

| Result | What it is |
|---|---|
| A criterion with no case | Coverage gap. Design the case, or mark the criterion `➖ not run` with the reason. |
| A criterion the diff does not implement | Gap. Quote the criterion and name where it should live. |
| A behaviour in the diff that no criterion asks for | Question: intended or scope creep? |
| A criterion that cannot be tested as written | Question: ask for an observable outcome. |

Example trace table for the report:

| AC | Criterion (quoted) | Cases | Status |
|---|---|---|---|
| AC-1 | "A paid expense cannot be approved again" | TC-02, TC-03 | ❌ fail (TC-02) |
| AC-2 | "Approvers see only their own team's expenses" | — | gap: no case, no ownership check in `approve()` |

When there is no ticket, say so and trace against the PR description and the diff.

## 2. Find the untested paths in the diff

1. For each changed function, branch and error path, search the test files for a test that reaches it.
2. A new error return with no negative test is a gap.
3. A test that cannot fail is a gap: it asserts non-null, "no exception" or a bare 200, or it mocks away the code under test.
4. A bug fix with no test that failed before the fix is a gap. The fail-to-pass pair is the proof.
5. Cite each gap as `file:line`, with what is missing.

## 3. Check the change against its surroundings

Ask each question. Write a gap only when the answer is "no" or "unknown", with the evidence.

- **Config parity.** Does every new variable, flag or secret exist in every environment it ships to (local, preview, staging, production)? What does the code do when it is missing or empty? Fail closed, or silently allow?
- **Flags.** Is each flag-gated path tested in both states, and across a flip in the middle of a session? Is the flag scoped to a test identity, and restored afterwards?
- **Data.** Does the migration handle existing rows? Does old code run safely against the new schema while pods roll? Is there a backfill, and is it idempotent?
- **Contracts.** Did an API, event or file format change? Is every consumer updated, or is the change backward compatible? Name the consumers you checked.
- **Authorization.** Does every new endpoint or action check who the caller is and what they own?
- **Observability.** If this breaks in production, which log line, metric or alert shows it? A new failure path with no signal is a gap.
- **Rollback.** Can the change be reverted with no data loss? Which effects are irreversible once it ships?
- **Neighbours.** Which modules import the changed code? Did their tests run on the head SHA?
- **Deploy order.** Does this change need another change, a secret or a migration first? Is that order written down?

## 4. Write each gap

Use this shape:

```markdown
- **GAP-3 — A missing approver limit lets any approver approve any amount.** `approve.go:41` reads the limit from config and treats `0` as "no limit". Staging config has no `APPROVER_LIMIT`, so every amount passes. Missing: a fail-closed default and a test for the empty value. Who is harmed: finance, through approvals above policy.
```

Each gap names:

1. what is missing,
2. where (file:line, config key, ticket line),
3. the consequence, through the person harmed,
4. what would close it (a test, a check, a config entry).

A gap with no evidence pointer is a question.
