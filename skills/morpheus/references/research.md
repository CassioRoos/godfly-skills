# Research mode

The user wants to know what is true about something external: a library, a protocol, a vendor
behavior, a pattern, a "right way". The failure modes are specific: repeating the most-upvoted
answer from years ago, treating a blog post and a vendor doc as equal, and delivering a survey when
the user wanted a decision. For bulk fetching and synthesis, use `knowledge-harvester`
if separately installed; otherwise gather and compare sources directly. Apply the
discipline below and the provenance labels in `SKILL.md` to judge the evidence.

## Discipline

1. **Preserve the requested result.** Answer a factual question directly. For a choice,
   identify the constraints that distinguish the options. Do not turn an explanation
   or source summary into an unsolicited decision exercise.
2. **Primary sources first.** Vendor documentation, the standard, the source code, the changelog,
   the maintainers' issue tracker. Then conference talks and engineering blogs from people who run
   the thing. Then everything else. A highly upvoted answer is a claim about the past, not the
   present.
3. **Date every fact.** SDK behavior, deprecations, defaults, and prices all move. A finding without
   a date is a finding you cannot trust next quarter. Check the date on the source and say it.
4. **Believability-weight, explicitly.** Rank each source you lean on: maintainer or vendor doc,
   practitioner with production experience, secondary summary, unknown. Weight the conclusion by
   that, not by how many pages say the same thing (they copy each other).
5. **Separate consensus from contested.** Say what every credible source agrees on, what is
   argued, and what is simply unknown. A senior who says "this part is contested and here is why"
   is worth more than one who picks a side quietly.
6. **Check the codebase before recommending.** A pattern that is right in general can be wrong
   here because of a constraint the repo already carries. Read what exists.
7. **Resolve the question.** When a choice was requested, recommend an option and name
   what would change it. Otherwise deliver the requested explanation or synthesis;
   omit decision-only sections below.
8. **Flag staleness in the popular answer when you find it.** The user probably read it already.
   Saying "the top Stack Overflow answer is from 2019 and predates the v2 SDK" saves them from
   arguing with you on a premise you both know is dead.

## Output shape

```
Question: <the user's question>
Answer: <one or two sentences, with calibration>
Evidence:
  - <fact> (<source type>, <date>) <URL>
  - ...
Consensus vs contested: <what everyone agrees on; what is argued and why>
Applies here: <what in this repo changes the general answer, cited, or "nothing found">
Recommendation: <do X because Y>. Flips if: <Z>.
Stale: <popular answer that is outdated, one line, or omit>
```

Keep the evidence list to what carried the conclusion: at most five entries. Five sources you
actually read beat fifteen you skimmed, and the first run of this skill listed ten when five did
the work.
