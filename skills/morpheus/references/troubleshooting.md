# Troubleshooting mode

The user has a failure and usually a theory. The theory is the most dangerous object in the room:
it arrived first, it explains the symptom, and it is wrong often enough that a senior treats it as
hypothesis number one, not as the plan. Use the procedure below with the project
runbook for investigation; use `premortem-postmortem` for the evidence timeline,
contributing factors, and corrective actions after an incident.

## Order of operations

1. **Contain before you diagnose, if it is live.** Bleeding money, corrupting data, or paging
   people: stop the bleeding first (feature flag, rollback, scale, kill the job), then find the
   cause. Root-causing while customers are double-charged is a hobby, not engineering.
2. **Reproduce, or declare blind.** A fix for a bug you cannot reproduce is a guess. Reproduce it in
   a test, a script, or a controlled request. If you cannot, say "fixing blind" in the first line
   and name the risk. Never let the word "fixed" appear without a reproduction that went red then
   green.
3. **Neutralize the theory.** "Bumping the timeout will fix it" becomes "would a longer timeout
   change the outcome, and what else explains the symptom?". Write down at least two competing
   hypotheses before touching anything. One hypothesis is a belief, not a diagnosis.
4. **Rank by likelihood times cost-to-test, and give each hypothesis one discriminating test.** A
   discriminating test is one whose result differs depending on which hypothesis is true. "Add more
   logging" is not a test. "Count open connections after 50 requests; pool exhaustion shows growth,
   a slow upstream does not" is.
5. **Run the cheapest discriminating test first.** Not the most interesting one.
6. **Symptom or cause?** Before recommending a fix, say which it treats. Raising a limit, adding a
   retry, or catching an exception is usually symptom treatment. That can be the right call under
   time pressure, but it is labeled as such, with the real fix named.
7. **Prove the fix.** The reproduction from step 2 goes green. Anything less is "should work".
8. **What to watch.** One line: the metric or log line that tells you in prod whether it is really
   gone.

## Never

- Shotgun five changes at once and see what sticks. You lose the ability to know which one mattered,
  and one of the other four is a new bug.
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

If containment is needed, it goes above the verdict as its own line and nothing waits on it.
