**Re: adopting `sentry-brief` v3 Monday — not signing off. The eval can't support the claim yet.**

To be clear about what I'm *not* saying: the v3 design changes (blast-radius-first, explicit UNKNOWN section, containment separated from fix) are good reliability practice on their own merits, and the packet deserves credit for honestly disclosing its own confounds — the network asymmetry, the variance re-run, the fabrication count, and the token cost are all in there. Nobody buried anything. The problem is that once you take those disclosures seriously, they say the experiment didn't measure what it claims to measure.

Concretely:

**1. The effect is smaller than the noise. This one is fatal on its own.**
Arm B re-ran at 41 and 49 on the raw sheet — an 8-point within-arm spread on the *same arm, same payload, same skill*. The v3-over-v2 margin is 2.0 weighted points, 1.2 after normalisation. You are reporting a result that is roughly one-sixth of your own measured run-to-run variance, from n=1 on both A and C. That's not a small-but-consistent win; "consistent" requires more than one observation. If you re-ran C you'd have a coin-flip chance of v2 winning.

**2. Arm C had capabilities A and B didn't.** C ran on your workstation with network access; A and B ran offline. D5 (the 404ing runbook) is *only* confirmable with network. So the arms weren't running the same task, and the version comparison is confounded with the environment. On top of that, A and B are scores from 2026-07-28 reused against a run from 2026-08-18 — different date, different sandbox, and the packet doesn't say whether A and B were graded under rubric v2.4 or June's rubric. If they weren't, the score table isn't comparable at all.

**3. The judge was not blind.** Outputs were handed over labelled `v1`, `v2`, `v3`. The judge therefore knew which one was newest, and the packet's own stated recommendation is "adopt v3". Look at the result: every soft axis rises monotonically with the version number (structure 12/15/18, checks 6/12/14, actionability 7/8/9). That's the exact fingerprint of label ordering bias, and with one judging pass there's nothing to distinguish it from a real effect.

**4. The arms were shown the grading rubric.** The task prompt included the five grading axes. So this measures "can the arm write toward axes it was just handed", not brief quality — and it structurally favours v3, whose output template (`IMPACT / SUSPECTS / CONTAIN / NEXT / UNKNOWN`) maps almost 1:1 onto the axis names. v3 was authored after v2's review, against these axes. That's a closed loop, not a test.

**5. What you're actually buying is 6 points of presentation for 4 points of fabrication safety.** Break the +2 down: structure +3, checks +2, actionability +1, fabrication **−4**. The fabrication regression is the single largest axis movement between v2 and v3, on the second-heaviest-weighted axis, and it's the only axis where a failure hurts someone at 3am. Meanwhile detection is pinned at 30 (6/6) for all three arms — 30% of the weight carrying zero signal, because the fixture is too easy to separate a February skill from an August one. So the entire measured "win" lives in the judge-subjective 45 points, while the hard axis is tied and the safety axis got worse.

**6. Two of the fabrications aren't cosmetic — they're fabricated verification.** "confirmed against `a3f1c09e...`" and a `reconcile.go:214` line reference that exists nowhere in the payload. A brief that says *confirmed* makes on-call stop looking. That doesn't cost you style points, it extends an outage on a settlement reconciliation service. And it's a direct violation of v3's own Rule 4 ("if the payload does not contain it, write 'not in payload'"). The skill's marquee safety rule is the rule its outputs broke, seven times.

**7. v3 also fails its own Rule 5, and the score sheet doesn't notice.** 2,400 words average. Rule 5 says "if the brief does not fit on one screen it is not a brief." 2,400 words is eight to ten screens. It scored 18/20 on the *"structure / one-screen"* axis. Either the judge wasn't applying the one-screen criterion or the word count is wrong; either way that axis is not measuring what it's named after. The 3.1x token cost is the least of it.

**8. Unauditable numbers.** Raw 41/49 becoming 87.0 via an undisclosed "rescale", plus an unexplained "normalisation adjustment" that shrinks the margin from 2.0 to 1.2 — and B went through a mean-of-two while A and C went through a single run, so the arms weren't even transformed the same way. Appendix C and `fixture-notes.md` are cited but not in the packet, so none of this is checkable from what's been circulated.

**9. "Reviewed and accepted, and this is settled" isn't a result.** The claim that the fabrication count is an artifact of v3 being more thorough is a perfectly reasonable *hypothesis* — and a cheaply testable one (re-run C offline; or normalise fabrications per 1,000 words). Sign-off from the platform lead resolves whether we're willing to accept a risk. It doesn't resolve whether the number means what we think it means. Right now we have one non-blind judging pass and no replication, so there's nothing to be settled about.

**10. Retiring v1 and v2 on Monday deletes the rollback path** and the ability to re-baseline, at the exact moment the comparison is in question. Don't.

**What I'd need to sign off — this is maybe two days of work, not a rewrite:**

- Re-run all three arms **same day, same harness, same rubric version, same network posture** (offline for everyone is cleanest). No reused July scores.
- **n ≥ 5 per arm.** Report mean and spread, and require the margin to exceed the observed within-arm spread before declaring a winner. On current evidence that bar is ~8 raw points; 2.0 doesn't clear it.
- **Blind the judge.** Shuffle to opaque arm IDs, no version identity, and ideally two independent passes so you can see judge disagreement.
- **Strip the grading axes out of the task prompt.**
- **Fix the fixture.** Detection at 6/6 across the board means it's not discriminating — add defects v1 actually misses, and use ≥3 payloads across ≥2 services including at least one real historical alert, before generalising to the whole platform team's alert surface.
- **Make fabrication a gate, not a weighted axis.** Any invented file path, commit SHA, or "confirmed against X" fails the run outright. Cite-and-verify or write "not in payload" — v3's Rule 4 should be enforced, not scored.
- **Enforce one-screen mechanically** (hard cap ~350 words / 40 lines, measured programmatically), rather than trusting a judge to notice 2,400 words isn't one screen.
- **Publish the normalisation formula**, or drop normalisation and report raw scores. Circulate Appendix C and `fixture-notes.md` with the packet.

**Recommendation for Monday:** keep **v2** as the team default, keep v1 and v2 in the repo, and offer v3 as opt-in to a couple of volunteers with an explicit tally of fabricated citations per brief. That gets v3 real-world exposure on the exact axis we're worried about while costing nothing if it turns out the fabrication delta is real. v3 may well be the better skill — I'd bet the design changes help. But right now we'd be standardising on it because a non-blind judge liked its section headers, and shipping a triage skill that invents commit SHAs to a reconciliation service on-call rotation is not a risk we should take on a 1.2-point margin we can't reproduce.
