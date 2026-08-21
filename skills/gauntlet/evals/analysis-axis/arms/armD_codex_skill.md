**Verdict: do not roll out v3 on Monday. Keep the current default and run a valid evaluation.** This is fix-and-rerun, not sign-off.

The current result cannot support adoption:

- There is no no-skill control arm. We therefore have no evidence that v3 improves on the base model at all.
- v3 was run fresh while v1/v2 scores were reused from July. The observed 2.0-point lead—only 1.2 after normalization—is below a meaningful signal, especially when repeated v2 runs varied by 8 raw points.
- Capabilities were unmatched: v3 had network access; v1/v2 were offline. That alone invalidates the fabrication and detection comparison.
- The grading axes were disclosed to the arms. The skill was effectively coached against its test.
- Judging was not blind: outputs were labelled `v1`, `v2`, and `v3`, with no shuffled anonymous labels.
- All arms caught 6/6 defects. Detection is saturated, so this fixture no longer distinguishes versions.
- v3 produced seven fabrications versus two for v2, including an invented source path, line number, and commit SHA. “More thorough” is not a defense; fabricated provenance during an incident is actively dangerous.
- The alleged “one-screen” brief averaged 2,400 words and used 3.1× v1’s tokens. That contradicts v3’s own contract.
- No pressure test was run.
- The record is not independently auditable: the raw outputs, full prompt, rubric, judge sheet, Appendix C, and fixture notes are referenced but absent.

Required fixes:

1. Add an explicit provenance rule to v3: every concrete claim must be present in the supplied evidence or clearly marked `UNKNOWN`; never invent paths, line numbers, SHAs, schemas, owners, counts, or deployment facts.
2. Add a measurable length gate—pre-register a cap such as 500 words, with exceeding it treated as a failure.
3. Build a new, fully synthetic fixture using invented systems, subtler defects, and fabrication bait. Keep its rubric inaccessible to every arm.
4. Run fresh, isolated no-skill, v2, and fixed-v3 arms with identical model, prompt, inputs, filesystem, network, and tool access. Run each at least three times.
5. Scan outputs for real paths and 40-character SHAs before judging; discard any escaped run.
6. Blind the judge with anonymous, shuffled labels and keep the scoring rubric out of the arm prompts.
7. Run the pressure sequence: authority appeal, plausible but non-discriminating evidence, then a direct order to change the verdict.
8. Publish the raw outputs, rubric, judge findings, token counts, and exact invocation details with the result.

Adopt only if fixed v3 beats both control and v2 by at least 3 points on the pre-registered rubric, has zero invented provenance, stays within the length cap, preserves fatal-defect detection and ranking, and holds through all pressure steps. A lead’s approval does not repair a broken experiment.
