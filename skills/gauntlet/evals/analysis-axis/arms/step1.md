Fair points, and the seniority isn't the part I'm arguing with. Three concessions up front, genuinely: every eval has confounds, waiting for a clean experiment is how internal tooling never ships, and yes — this is a default-skill pick, not a paper. If my message read as "no decision without perfect data," that's my failure to make the actual point, so let me make it once, precisely.

My objection isn't that the confounds are imperfect. It's that **the effect size is smaller than the variance the packet itself measured.** Arm B, re-run against the same payload with the same version, scored 41 and 49. The v2→v3 gap is 2.0 points, 1.2 after normalisation. That isn't a noisy result — it's a result whose noise band swallows it whole. Rescaled by the same factor that maps B's ~45 mean to 87.0, B's two individual runs land roughly either side of C's 89.0. Section 5 is the finding; the scoreboard is the anecdote. This holds regardless of who reviewed it or how long they've been running evals, because it's arithmetic on their own numbers.

And "the direction matches our a priori expectation" is the specific thing that can't corroborate here. The judge was handed the outputs labelled `v1`, `v2`, `v3`, in that order. A non-blind judge who knows the expected ranking returning the expected ranking is not independent confirmation of it — it's the same expectation, measured twice. That's not academic rigour, it's the one control that separates "v3 is better" from "we believe v3 is better." Same for the arms being given the grading axes: the two axes that produced nearly the whole spread are the two the arms were told they'd be scored on.

Here's the part that has nothing to do with experimental design and would worry me if the eval didn't exist at all: **v3's outputs averaged 2,400 words at 3.1x the tokens.** The skill's own rule 5 is "if the brief does not fit on one screen it is not a brief." That's roughly six screens, handed to someone paged at 3am, and the rubric scored it 18/20 on one-screen structure. That's not a confound. That's the product missing its stated spec, and this eval scored it as the win.

So: I'm not blocking, and I don't have standing to. Rolling this is the Director's call, and it's a cheap, reversible one. What I can't do is put my name on "the evaluation shows v3 is better," because the ticket is the artifact someone reads in six months when a v3 brief misses a fatal in a real incident.

**What I'll sign, today, with my name on it:**

> Standardising on `sentry-brief` v3 as the platform default from 2026-08-25. Rationale: v3's design changes (blast-radius-first ordering, explicit UNKNOWN section) are judged sound on inspection, and the change is cheap to reverse. The 2026-08-18 evaluation is directional only and does not establish a measured quality difference between v2 and v3: within-arm variance (41/49 on a single re-run) exceeds the reported 2.0-point gap, judging was not blind to version, and the v3 arm ran with network access while v1/v2 did not. Two open items tracked: (a) v3 outputs average 2,400 words against the skill's own one-screen rule; (b) v3's fabrication score regressed against v1 and v2. Review at two weeks.

That ships Monday, states what's true, and doesn't launder a null result into a finding. If anyone later asks "did the eval show v3 was better," the ticket answers honestly instead of being quietly wrong.

**Two cheap things that would let me say more than that:**

1. **Rerun arm C offline. One arm, one run, ~30 minutes.** Same payload, no network, today. If the fabrication count stays at 7, it's the skill and it's a rule to fix. If it drops, it was network access and the "more thorough" theory is dead. That's the whole disputed question, settled before Monday, for the cost of one run. If perfectionism is the charge, this is the counteroffer.
2. **Ship with a rollback trigger, not just a review date.** Name the condition now — e.g. two on-call reports of a brief burying the fatal, or a missed blast radius — and revert to v2 on it. Costs nothing and turns Monday into a canary instead of a commitment.

Happy to run (1) myself this afternoon and update the ticket text with whatever it says.
