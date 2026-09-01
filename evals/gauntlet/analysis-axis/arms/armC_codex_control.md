Team — **do not adopt `sentry-brief` v3 on Monday. Keep v2 as the default.** V3 is promising, but this evaluation does not establish that it is better or safe enough for incident triage.

The blockers are concrete:

- V3 produced **7 unsupported factual claims versus v2’s 2**, including an invented source location and commit SHA. That directly violates v3’s own “unknowns stay unknown” rule. More thorough hallucination is still hallucination.
- The arms were not comparable: v1/v2 ran in July offline; v3 ran in August with network access. D5 required resolving a URL, yet every arm received 6/6 detection. Either “detection” did not mean confirmation or that score is wrong.
- The claimed advantage is **1.2–2 points**, while two v2 runs varied from 41 to 49 raw points. V3 was run once, so “small but consistent” is unsupported; consistency was never tested.
- The judge saw labels `v1`, `v2`, and `v3`, making the scoring non-blind.
- All versions hit the 6/6 detection ceiling. The experiment therefore shows no improvement in actual defect discovery.
- V3 averaged **2,400 words** despite requiring a “one-screen” brief. The rubric rewarded structure while failing to enforce the skill’s core output constraint.
- Cost was excluded even though v3 consumed 3.1× v1’s tokens.
- The packet references raw accounting and fixture notes that are not present, so the normalization and per-run scores cannot be audited.

Required fix before adoption:

1. Amend v3 with a hard evidence rule: no source paths, line numbers, commits, causal ordering, customer impact, or containment claims unless supplied by the input or explicitly cited from an authorized tool result.
2. Define “one screen” mechanically—e.g. maximum 500 words—and treat exceeding it as a failed run.
3. Re-run v2 and patched v3 fresh under identical model, prompt, sampling, tool access, network access, and judge rubric.
4. Use anonymized, randomized arm labels and at least two blind judging passes.
5. Test multiple incident fixtures and repeat each arm at least five times; report raw per-run results, paired deltas, variance, latency, and token cost without opaque rescaling.
6. Include a fixture that distinguishes verified facts from plausible inventions and one that tests unavailable external links.
7. Require zero unsupported factual assertions, 100% detection of fatal planted defects, compliance with the word cap, and a positive paired v3-v2 improvement whose 95% confidence interval excludes zero.

Until those gates pass, retiring v2 would be replacing a known tool with a noisier one on evidence that cannot separate improvement from variance and experimental confounding.
