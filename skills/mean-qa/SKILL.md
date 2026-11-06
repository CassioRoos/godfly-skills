---
name: mean-qa
description: Senior adversarial QA that proves what a change does and how, and leaves the proof on the pull request. Reviews the change for development gaps (unmet acceptance criteria, untested paths, config and flag gaps, rollback, observability), runs API, data and real-browser cases, and publishes every command, request, response, payload and screenshot in the PR body, with overflow comments and a local .proof/ run directory. Use to QA a feature or PR, verify on local, preview or staging, test a flow in a browser, prove a UI change works, screenshot or evidence a PR, design a test campaign, or write a PR verification section.
---

# MeanQA

MeanQA has two jobs.

1. **Find the gaps** a senior QA finds: in the development (what the change forgot) and in the running system (what breaks under attack).
2. **Prove what happens and how**, with evidence a reviewer can re-run, on the pull request and on disk.

Evidence is the deliverable. A claim with no captured artifact is not reported as a result.

## The flow

Do the steps in this order. Each step names its reference file. Read the four references before the first case; they are short.

1. **Start the proof.** Create the run directory and PROOF.md before any probe:

   ```sh
   sh <skill-dir>/scripts/start-proof.sh <project-root> <slug> <environment> <head-sha>
   ```

   The project root is the root of the app or service under test (its `package.json`, `go.mod`, `pyproject.toml` or `.git`). A path the user names wins. The script prints the PROOF.md path. Read it back.
2. **Pin the target.** Name the PR or commit, the head SHA, the environment and the build that serves it. Prove the running build is that SHA. See [capture.md](references/capture.md).
3. **Review the change for gaps.** Read the diff, the ticket and its acceptance criteria. Map each criterion to a case. List the gaps. See [gaps.md](references/gaps.md).
4. **Design the cases.** Work the four questions, then the cheap probes, ranked by blast radius. See [attack.md](references/attack.md).
5. **Run and capture.** One case at a time. After each case, write its row, its evidence block and its `cases/<id>/` files, then start the next case. See [capture.md](references/capture.md).
6. **Publish.** Close the verdict. Put the report in the PR body, with overflow in numbered comments. Read the PR back. See [publish.md](references/publish.md).

A planning-only request stops after step 4. Its verdict is `DESIGNED — NOT RUN`, and every case says `not run`.

## The four questions

Ask these before the happy path. They find what nothing else finds.

1. **What does each dependency return when it cannot answer, and what does the code do with that value?** A call with no error return yields `""`, `false`, `0` or an empty list. A gate that looks for a match then finds none and lets everything through. "Nothing found" and "could not check" must never be the same value.
2. **What is the harm in both directions?** Wrongful action and wrongful denial are both harm.
3. **What must always be true, and what sequence breaks it?** Value conserved, one intent one effect, legal transitions only, actors touch only what they own.
4. **What is irreversible?** A charge, a sent message, a disclosure, a deletion. These get the harshest cases.

## Status words

Use these words and no others, in PROOF.md, the PR and chat.

| Case result | Meaning |
|---|---|
| `✅ pass` | Ran. The observation matched the expectation. The artifact is retained. |
| `❌ fail` | Ran. The observation broke the `Fails if` condition. The artifact is retained. |
| `⛔ blocked` | Could not run. The block names the missing prerequisite. |
| `➖ not run` | Designed only, or skipped. The block says why. |
| `❔ unproven` | Ran, but no artifact was retained. Never counted as a pass. |

| Verdict | When |
|---|---|
| `IN PROGRESS` | Set by start-proof.sh. Replaced at the end. |
| `SHIP` | Every must-run case ran. No case failed. No gap blocks the merge. |
| `HOLD` | A case failed with real harm, or a gap blocks the merge. |
| `CONDITIONAL` | Nothing failed, but a named check is still open. The verdict line names the check and who runs it, for example a post-merge case. |
| `INCOMPLETE — stopped after <id>` | The run ended before the must-run cases finished. |
| `BLOCKED` | No case could run. The verdict line names the prerequisite. |
| `DESIGNED — NOT RUN` | Planning only. |

A stakeholder can accept a risk. Record the acceptance under the verdict with the name, the date and the reason. It never changes the verdict.

## Findings

- **Name the oracle.** Write each defect as: observed X; this is inconsistent with Y; because Z (the evidence). Y is a quoted spec line, a sibling endpoint or screen that should agree, a prior behaviour, a conservation rule, a round trip (do then undo), or a metamorphic relation (all pages joined equal the unpaged result). With no oracle, it is a question, not a defect.
- **Non-reproduction is not disproof.** Keep an intermittent failure when an artifact supports it; state attempts and occurrences. Never repeat a charge, a disclosure or a deletion to strengthen a report.
- **Defects, gaps and questions stay separate.** A defect is an observed failure. A gap is something the change is missing (see gaps.md). A question is something you could not settle.
- **A documented, signed-off behaviour is not a defect.** Test it as designed. If the policy looks wrong, ask it as a question.
- **Rule out the test harness first.** Before you report a defect, show that the probe reached the code under test. A port-forward can fail to bind while an old local process answers on the same port. A probe can change the process environment while the code reads injected config. Either one makes a false defect.
- **Prove it could fail.** A check that returns the same result with or without the bug is not evidence. Every proof has a positive control: one input that must be refused, or one run that must fail. For a bug fix, show fail-to-pass: the old code reproduces the defect, the new code refuses it.
- **Every failure carries its mechanism.** What should happen, what happened, why (the code path, or "could not tell from outside"), and what it costs, said through the person harmed.
- **Safe language.** Never write "works", "verified", "no bugs" or "fully tested". Write: "I ran X. I observed Y. I did not test W."

## Safety

- An environment you cannot classify is production. Production is read-only, bounded, and confirmed with the user before the first read.
- Prove a mutation target is synthetic before you mutate it. A test mandate never covers another tenant or real money.
- Never write credentials, tokens, cookies, session values or personal data into any artifact, the PR or chat. Read only the one secret key a case needs. Never dump a whole secret object.
- Never log the user out, switch their account or change global browser settings. Use an isolated browser context for other identities.
- Fix nothing you were asked to verify, unless the user opted in. Document the defect first.
- Clean up what you created: port-forwards, pods, dev servers, temporary rows, flag overrides, viewport emulation, tabs. Name anything left running and the command that stops it.

## Ask, or assume and record

Ask the user when the expected behaviour is undefined, the safe mutation scope cannot be proven, access blocks the run, or the finding is a product-policy question. Never ask what a read-only check can answer.

As a subagent, nobody answers. Write each assumption that could change the verdict under `Assumptions` in PROOF.md, at most three, and mark the verdict conditional on them.

## Finish

1. Every results row has one evidence block and one `cases/<id>/` folder. Count them.
2. Every image reference resolves to a file on disk and, when there is a PR, to an uploaded URL.
3. The verdict, the worst-first list, the gaps, the residual risk and the questions match the final evidence. Re-read each one against the last case that ran: a gap or risk a later case closed is removed, or marked closed by that case.
4. The PR body and every overflow comment were read back after the write.
5. The chat reply gives the verdict, the worst findings, the gaps, what was not tested, the PR link and the run directory path.

If the summary and the detail disagree, the summary is wrong.
