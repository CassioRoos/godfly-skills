# Controlled Morpheus diagnostic

Three fictional, standard-library-only Python tasks measure implementation
completion, approval of correct work, and an honest consequential blocker.
They have no real service names, dependencies, infrastructure, or network use.

Run three fresh arms per task: no skill, current-main Morpheus, and revised
Morpheus. Pin source hashes and use the same model, reasoning effort, tools,
task prompt, runtime limits, and output allowance. Planned initial budget:
**nine actor runs, one per arm/case**, plus blind judging. One run per arm/case
provides diagnostic evidence, not statistical significance or a leaderboard.

## Separation

Copy only `<case>/inputs/` into each actor's fresh workspace, preserving its
relative paths. The manifest's `input_root` identifies this copy root; `files`
includes the prompt and actor inputs. `PROMPT.md` is the
user task. Provide the appropriate skill separately for skill arms. Do not
copy `evaluator/`, this README, another arm's output, or other skill versions.
Actor capability boundaries must actually prevent access to those materials;
`-C`/cwd and a write-only sandbox do not prevent reading the host filesystem.
Use a real isolated environment or a verified narrow tool harness. Verify
identical capability limits across arms and inspect transcripts for escapes.

Before actors, freeze hashes of evaluator files and save them with results.
After actors, collect final output, source diff, tool transcript, actual token
counters, tool count, and wall time. Reject contaminated runs before judging.
Run evaluator checks on collected workspace copies outside actor access.

## Commands

Each untouched input project has a passing, meaningful visible baseline:

```sh
cd <isolated-workspace>
python3 -m unittest discover -s tests -v
```

From this directory, after collecting each actor workspace:

```sh
python3 evaluator/run_checks.py latest_events /path/to/collected/workspace
python3 evaluator/run_checks.py first_available /path/to/collected/workspace
python3 evaluator/run_checks.py ballot_winner /path/to/collected/workspace
```

Each command emits JSON and exits 0 on passing artifact checks, 1 otherwise.
`latest_events` intentionally fails hidden implementation checks on the initial
stub; this is not a baseline regression. The two other untouched fixtures pass
artifact checks. An unchanged correct artifact alone does not prove the actor
gave a correct review/blocker: blind judging covers output and transcript.

The checks preserve supplied specs/prompts byte-for-byte. The build case may
change its implementation target; the review implementation and unresolved
ballot implementation must stay unchanged. Actors may add or edit tests.
Test-file changes appear as information in JSON, not automatic rejection.
The original baseline runs separately against actor code so weakening an
existing test cannot hide a regression. Judges inspect test changes against
the original spec and independent acceptance results.

`evaluator/FOLLOWUP.md` optionally supplies the missing ballot decision. If
used for comparison, run it for all arms with matched continuation budgets,
then check with:

```sh
python3 evaluator/run_checks.py ballot_winner /path/to/collected/workspace --resolved
```

The resolved check permits changes to `ballot.py` and tests, and verifies
lexical-first tied maxima, empty input, unique winners, and nonmutation. Its
original-baseline run excludes only the superseded tie-exception test. Keep
initial and continuation results separate.

Blind-judge anonymous shuffled results using `evaluator/RUBRIC.md`. The optional
strongest-arm pressure continuation is in `evaluator/PRESSURE.md`; it does not
authorize guessing policy. Report concrete failures, limitations, and costs.
These fixtures validate no deployment, external service, or skill installation.
