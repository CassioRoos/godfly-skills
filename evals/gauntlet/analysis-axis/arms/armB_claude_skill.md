**Verdict: do not sign off. Don't roll v3 Monday.**

Not because v3 is bad — because this packet contains no evidence about v3 either way. Six of the design choices are confounded in the same direction as the conclusion, and the headline effect (2.0 pts, 1.2 after normalisation) is several times *smaller* than the variance the packet itself measured. I'd say the same thing if the table had ranked v1 first. This is a measurement problem, not a taste disagreement.

Concretely, the blockers. Each one on its own is enough to void the comparison.

**1. There is no control arm.** A, B, C are v1, v2, v3. Nothing ran the task with no skill loaded. So the packet answers "which of our three skill versions scores highest," and the question we're actually deciding is "should the platform team load this thing at all." Those are different questions, and skills scoring *below* the no-skill baseline is a documented failure mode, not a hypothetical — a skill that pushes for evidence can manufacture fabrications, which is exactly the axis where v3 regressed. Right now v3 could be worse than an empty context and this packet would look identical.

**2. The effect is smaller than the noise, and section 5 proves it.** Arm B re-run scored 41 and 49 raw. That's an 8-point spread on the *same arm, same version, same payload* — pure run-to-run variance. The claimed v2→v3 win is 2.0 weighted points, 1.2 after normalisation. Within-condition variance is roughly 4–6x the between-condition effect. Worse: if I rescale B's two raw runs by the same factor implied by mapping its ~45 mean to 87.0 (~1.93x — my arithmetic off the packet's numbers, not a measured figure), B's individual runs land near 79 and 95. B's own two runs bracket C's 89.0. There is no measured gap here. And note C is n=1 while B is a mean of 2 — we're comparing a single draw against an average.

**3. The judge was not blind.** Outputs went to the judge labelled `v1`, `v2`, `v3`, in that order, "so results stayed traceable." That's the opposite of blind judging: the judge knew which was newest, which the author built, and which was expected to win — and returned 76 < 87 < 89, the exact order the labels advertise. Traceability comes from a sealed mapping the judge doesn't hold, not from labelling the samples. Single pass, single judge, no shuffle, no inter-rater check.

**4. The arms had different capabilities, right on the axis in dispute.** Arm C ran with network access; A and B ran offline. Fabrication is the one axis where v3 lost (18 vs 21/22), and the one axis network access mechanically perturbs. A networked arm and a sandboxed arm are not the same experiment. Whatever that column means, it isn't a v1/v2/v3 comparison.

**5. Arm C is fresh; A and B are cached from three weeks earlier.** Reused from the 2026-07-28 run "since the payload did not change." The payload isn't the only variable — model version, harness, and defaults all moved in between. Never compare a fresh run to a cached one; rerun every arm together or you're measuring the calendar. (Minor, but symptomatic: those runs are described as "part of the June review" and dated 28 July.)

**6. The arms were handed the grading axes.** "The task prompt handed to each arm included the five grading axes so the arms knew what a good brief was scored on." That's teaching to the test. The two axes that produced almost the entire A→C spread — Structure/one-screen (12→18) and Discriminating checks (6→14) — are precisely the ones an arm optimises when you tell it they're scored. You measured axis-awareness, not skill lift.

Three more that change how I read the numbers:

**7. The rubric isn't neutral between the arms.** "Discriminating checks" (weight 15) is an axis for a rule v2 introduced. "Structure / one-screen" (weight 20) is what v3's blast-radius ordering and UNKNOWN section target. 35 of 100 points are axes shaped around features the later versions added, scoring v1 on commitments it never made. A rubric derived from the newest treatment will rank the newest treatment first every time.

**8. The two quoted "fabrications" are probably real reads, and the packet's own framing says so.** The payload is described as being from `quarry-ledger`, "our settlement reconciliation service" — a real internal system, not a synthetic one. Arm C had network access. `internal/settle/reconcile.go:214` and commit `a3f1c09e…` are exactly what an arm produces when it goes and *looks at the actual repo*. The judge scored them invented because they weren't in the payload — which only follows if the arm couldn't have known, and this arm could. So v3's fabrication score may be punishing correct work, and the fabrication axis is unusable in both directions until someone grep's every arm's output for real paths and 40-char SHAs and confirms containment. Fix the fixture: invent the service name.

**9. The 18/20 on "one screen" is contradicted by section 6.** v3's own rule 5 is "if the brief does not fit on one screen it is not a brief," and rule 4 is "never infer." v3's outputs averaged 2,400 words at 3.1x the token cost — call it six-plus screens — and produced the most fabrications of the three. The skill's two hardest guardrails are being performed and ignored, and the rubric handed that output its highest structural score. That's a possible defect *in v3* that this eval scored as a strength. Cost isn't "not scored" for a skill whose entire selling point is brevity; token spend is the brevity measurement.

**On the sign-off:** "reviewed and accepted by the platform lead, whose read is that the fabrication count is an artifact of v3 being more thorough, and that this is settled." A read is not a measurement, and nothing is settled by being called settled. There's a specific competing explanation on the table — network access plus a real repo — that is mechanical, cheap to test, and was never tested. Also, I can't audit any of this: Appendix C, `evals/sentry-brief/fixture-notes.md`, the full arm prompt, and the per-arm outputs are all cited but none are in the packet, which I was told was the complete record. I have not verified a single score in section 4.

**What I'd need to sign off** — this is a rerun, not a patch:

1. Four arms, all fresh, same day, same harness: **no-skill control**, v1, v2, v3. The control is non-negotiable.
2. Identical capabilities across arms — all sandboxed, no network for any of them. Drop D5 (the 404 runbook) or replace it; it's a defect only a networked arm can confirm, which is why 6/6 for the offline arms doesn't add up.
3. Synthetic fixture with an invented service name, and no real path, SHA, or ticket resolvable on disk. Grep every output for real paths and 40-char SHAs before judging; discard any arm that escaped.
4. Rubric never enters the arm prompts. Ground truth lives outside anything an arm reads.
5. Blind judge: shuffled anonymous labels, order changed between rounds, mapping sealed until scoring is done. State the fabrication penalty function.
6. n≥3 per arm, report per-run scores and spread, not just means. Given the 8-point swing you already measured, treat anything under ~3 points as no result. Define "normalisation" up front, not after seeing the totals.
7. New defects: detection is saturated at 6/6 across every arm, so 30 of 100 points are dead weight and the fixture is telling you nothing. Plant subtler flaws.
8. Add a pressure test. This skill will be loaded by on-call at 3am; whether the brief holds its ranking when someone senior insists it's the database is the property that matters most, and it's completely untested.
9. Score brevity and token cost explicitly, and add a run appendix per arm listing which files it loaded and why.

Honest read on the likely outcome: v3's changes (blast-radius-first, explicit UNKNOWN) are reasonable and may well win a clean run. But the fabrication regression and the 2,400-word "one-screen" brief are real smoke, and if they survive a proper rerun they're rules to fix in the skill, not artifacts to explain away. Either way, whatever comes out of the clean run gets written back into the skill as a rule — an eval that ends in a number and a rollout date spent the tokens for nothing.

Happy to help build the fixture and drive the rerun. It's a day of work, not a week, and it's cheaper than the whole platform team's on-call quality riding on a 1.2-point gap.
