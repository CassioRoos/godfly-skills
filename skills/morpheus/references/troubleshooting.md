# Troubleshooting mode

The user has a failure and usually a theory. The theory is the most dangerous object in the room:
it arrived first, it explains the symptom, and it is wrong often enough that a senior treats it as
hypothesis number one, not as the plan. Use the procedure below with the project
runbook for investigation; use `premortem-postmortem` for the evidence timeline,
contributing factors, and corrective actions after an incident.

## Order of operations

1. **Prioritize containment if it is live.** Identify the immediate action that limits
   harm before deeper diagnosis. Execute a flag change, rollback, scaling change, or
   job stop only within existing authorization; otherwise name the action and who
   must authorize or perform it. A review request does not authorize production changes.
2. **Reproduce, or declare blind.** A fix for a bug you cannot reproduce is a guess. Reproduce it in
   a test, a script, or a controlled request. If you cannot, say "fixing blind" in the first line
   and name the risk. Never let the word "fixed" appear without a reproduction that went red then
   green.
3. **Neutralize the theory.** "Bumping the timeout will fix it" becomes "would a longer timeout
   change the outcome, and what else explains the symptom?". Compare plausible causes
   when the evidence is ambiguous; do not invent alternatives to an established cause.
4. **Rank by likelihood times cost-to-test, and give each hypothesis one discriminating test.** A
   discriminating test is one whose result differs depending on which hypothesis is true. "Add more
   logging" is not a test. "Count open connections after 50 requests; pool exhaustion shows growth,
   a slow upstream does not" is.
5. **Run the cheapest discriminating test first.** Not the most interesting one.
6. **Symptom or cause?** Before recommending a fix, say which it treats. Raising a limit, adding a
   retry, or catching an exception is usually symptom treatment. That can be the right call under
   time pressure, but label it honestly. Trace causal links only as far as needed to
   choose and verify the fix; cite each link and mark unknowns. Broader process analysis
   belongs here only when it changes that fix or the user requests it.
7. **Prove the fix.** The reproduction from step 2 goes green. Anything less is "should work".
8. **What to watch.** One line: the metric or log line that tells you in prod whether it is really
   gone.

## Never

- Stack speculative fixes. After a failed experiment, state what it ruled out before
  trying another; if it was inconclusive, say so. Keep unrelated changes out of it.
- Accept "it's flaky" as a cause. Flaky is a symptom with an unfound cause.
- Trust the error message's location. The line that panics is rarely the line that is wrong.
- Fix in prod first because it is faster. It is faster until it is not.

## Output shape

```
Verdict: <theory holds | theory does not hold | cannot tell yet> — <one clause>
Your position: <the user's theory and the evidence they have for it>
Hypotheses (ranked):
  1. <hypothesis> (<calibration>) — test: <the one discriminating test> — <expected result if true>
  2. ...
Findings: <only what you read, ran, or saw, cited>
Fix: <symptom | cause> — <what> — proof: <the reproduction that must go red then green>
Watch: <metric or log line>
```

If containment is needed, put it above the verdict and distinguish recommended
actions from actions actually authorized, executed, and verified.
