# Codebase Evidence Gathering

Language-neutral moves for turning "I think this code is wrong" into Tier A
evidence. The moves below apply to any language or stack; a Go worked example
follows at the end to show them in practice.

## The Core Moves

Before challenging any implementation, run these moves systematically:

### 1. Find the Test That Pins the Behavior

Is the behavior you're challenging (or relying on) actually asserted anywhere?

- Locate the test files that correspond to the module in question, using
  whatever convention the stack follows (a parallel test directory, a sibling
  test file, a spec folder).
- Search test code for the function, type, route, or behavior by name.
- Check whether any integration or end-to-end test exercises the specific path
  you care about, not just the happy path around it.

No test pinning the behavior = untested assumption. The code might work by
accident, and your claim about what it does is weaker than it feels.

### 2. Find the Entry Point

Where does execution actually start for the path in question?

- Find where the route, command, handler, job, or event subscription is
  registered or wired up.
- Confirm the code you're reading is actually reachable -- dead code and
  superseded implementations are a classic source of false Tier A claims.

### 3. Trace the Call Path

Follow the code from entry point to the line you're challenging:

- Walk the call chain step by step; do not assume intermediate layers are
  pass-throughs (middleware, decorators, wrappers, and ORMs frequently change
  behavior).
- Note where errors are handled, swallowed, or transformed along the way.
- Trace the consequence forward too: what does the caller do with the result
  you claim is wrong?

### 4. Check Config and Flags

Behavior often lives outside the code:

- Search configuration files, environment variable reads, and feature-flag
  lookups that gate the path in question.
- Confirm which values are active in the environment you're making claims
  about -- a code path behind a disabled flag is not evidence of current
  behavior.

### 5. Find Existing and Contradicting Patterns

Does the codebase already solve this problem elsewhere, or solve it
differently?

- Search for similar implementations of the same concern (error handling,
  retries, database access, API calls) in neighboring modules.
- If a proven pattern already exists, the burden of proof shifts to "why do
  something different?"
- If the rest of the codebase handles the concern differently from the code
  under review, either this code is wrong or the rest is. Determine which.

### 6. Find TODOs and Known Issues

Does the team already know about problems here?

- Search relevant files for TODO, FIXME, HACK, XXX, WORKAROUND markers.
- Check version-control history for the area (high churn = instability;
  a recent revert = a known landmine).

## What Constitutes Strong Codebase Evidence

| Strong (Tier A) | Weak (not evidence) |
|-----------------|-------------------|
| "Line 47 doesn't check the error return" | "This function looks complex" |
| "This query has no index -- EXPLAIN shows full scan" | "This might be slow" |
| "The lock is acquired but never released on the error path" | "This could have race conditions" |
| "This interface has 12 methods -- only 3 are used here" | "This interface is too big" |
| "The retry loop has no jitter -- all 1000 consumers retry at t+5s" | "The retry logic could be better" |

## Presenting Codebase Evidence

Always include:
1. **File and line number** -- so the user can verify
2. **The specific code** -- quote the relevant lines
3. **Why it matters** -- connect the code to the concern
4. **What happens** -- trace the consequence (not hypothetical, actual)

Format:
```
EVIDENCE (Tier A): [file:line] The failing operation's result is discarded and never checked.
CONSEQUENCE: If the write fails (timeout, constraint violation, connection loss),
the function reports success -- caller assumes success, publishes to queue,
consumer processes a record that doesn't exist in the database.
```

## Worked Example: A Go Service

The same moves, applied to a typical Go codebase:

1. **Find the test that pins the behavior:** glob for `*_test.go` in the same
   package, grep for the function/type name in those files, and look for
   integration tests that cover the path.
2. **Find the entry point:** grep for the route registration
   (e.g. `mux.HandleFunc`, router setup) that wires `handler.go` into the
   server.
3. **Trace the call path:** follow handler -> service -> repository; check
   each `if err != nil` along the way for swallowed or wrapped errors.
4. **Check config and flags:** grep for `os.Getenv`, config struct fields, and
   feature-flag client calls that gate the handler.
5. **Find patterns:** grep for how sibling handlers in the same package handle
   the same concern (error responses, transactions, retries).
6. **Find known issues:** grep for TODO/FIXME in the package; run `git log`
   on the file for recent churn.

Result, in the standard format:
```
EVIDENCE (Tier A): [handler.go:47] The error from db.Exec is assigned to _ and never checked.
CONSEQUENCE: If the write fails (timeout, constraint violation, connection loss),
the function returns nil -- caller assumes success, publishes to queue,
consumer processes a record that doesn't exist in the database.
```
