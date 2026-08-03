# Verdict Graph -- Never Pay For The Same Investigation Twice

Every spar produces claims, evidence tiers, and verdicts. Without persistence,
all of it evaporates at session end, and the next session re-pays tens of
thousands of tokens to re-derive a question that was already settled. The
verdict graph fixes that asymmetry: retrieving a prior verdict costs hundreds
of tokens; re-deriving it costs a full investigation.

The design rule, learned from GraphRAG's cost collapse: **cheap structure,
lazy traversal, write-on-synthesis.** The graph grows one node per claim
actually settled, written at the moment the tokens are already spent. Never
batch-extract, never index a corpus, never summarize communities. Eager graph
construction is the token furnace; this graph only contains what was paid for
once and is worth never paying for again.

## Where It Lives

`docs/verdicts/` in the target repo, **tracked in git** -- an untracked graph
is machine-local and dies with the worktree, which makes "permanent" a lie.
One markdown file per settled claim, plus `INDEX.md` (below).

- Slug convention: `<area>-<claim-predicate>` (e.g.
  `payments-webhook-retry-unbounded`), named after the claim, not the task,
  so slugs cluster by area.
- First write: if `docs/verdicts/` doesn't exist, say so, create it with the
  first node and `INDEX.md`. Announce every node write in chat -- slug, claim,
  verdict -- the user should never discover files they didn't know I created.
- A claim spanning repos is written in the repo owning the offending code;
  other repos get a stub node pointing at it. Check a sibling repo's graph
  only when the question names that repo.

## INDEX.md

One line per node, appended in the same edit that writes the node:

```
- <slug> — <claim, one sentence> — <verdict>/<tier>/<status>/<date>
```

The index is the read path's entry point and the write path's dedup surface.
It is never allowed to drift from the node files: touch a node, touch the index.

## Node Format

```markdown
---
claim: <the assertion that was contested, one sentence>
verdict: held | yielded | synthesized
tier: S | A | B | C           # strongest evidence backing it; scale per evidence-grounding
date: YYYY-MM-DD
repo: <repo name>
anchor-sha: <HEAD sha at write time>
anchors: [<file>:<symbol or key>, ...]   # symbols, not line numbers -- lines drift silently
status: current | stale | superseded
supersedes: <slug>            # only when this node replaced another
superseded-by: <slug>         # required when status: superseded
---

## Position
<the settled position, 2-4 sentences, professional register -- this file
outlives the conversation and will be read by other humans>

## Evidence
- <evidence item> (Tier X) -- <source: file:symbol, URL, or measurement + how to reproduce>

## Flip Condition
<what evidence would reverse this verdict>

## Related
- [[<other-verdict-slug>]]
- ADR: <link, if promoted>
```

The flip condition is mandatory -- same rule as toolshed's proto-ADRs. A
verdict without a flip condition is dogma, and dogma is exactly what this
skill exists to kill.

Status semantics: `current` is trustworthy; `stale` means the anchors are gone
or the claim re-opened with no successor yet; `superseded` means a newer node
replaced it (`superseded-by` required, and the successor carries `supersedes`
back -- the history of being wrong is evidence too).

## Read Path (ABSORB)

The hub carries the recipe; this is the contract behind it:

1. Read `docs/verdicts/INDEX.md`. No directory or no index = no priors --
   continue the review, don't error.
2. Pick **at most 3-5 nodes** by claim relevance from the index lines. Budget
   is node count, not hop depth -- depth 1 with unbounded fan-out is not a
   budget.
3. Discard any node whose `status` is not `current`; for `superseded`, follow
   the `superseded-by` pointer to the living node instead.
4. **Recency check, mechanically:** `git log --oneline <anchor-sha>..HEAD --
   <anchor file paths>`. Empty output = fresh, cite it and move on. Non-empty
   = the code moved after the verdict; re-verify the anchors before leaning on
   it, and mark the node `stale` if they're gone.

A `current`, fresh hit at Tier S/A is reusable evidence. Anything else is a
hypothesis wearing a timestamp.

## Write Path (SYNTHESIZE)

A claim is settled when both sides have stopped bringing new evidence -- held,
yielded, or synthesized into something new. Write the node then, while the
evidence is still in context: the write costs almost nothing at synthesis time
and saves an investigation later. This applies to every command that
manufactures durable claims -- `*spar` and `*review` verdicts, `*alternatives`
recommendations (already verdict-shaped: recommendation + conditions for
switching = position + flip condition), and `*fail`'s rated failure modes.

- **Upsert, don't duplicate.** Scan INDEX.md claim lines (and `ls` the
  directory) for an existing node on the claim before creating one. Grep alone
  misses synonym phrasings; the index scan is the real dedup.
- **Supersede, don't delete.** A reversed verdict gets `status: superseded` +
  `superseded-by`; the successor gets `supersedes`.
- **Link liberally in `Related`, read narrowly.** A `[[slug]]` that doesn't
  exist yet marks a claim worth settling, not an error.
- **Unwritable repo?** Inline the node bodies in the output -- Rule 11 counts
  that as written. Tell the user where they belong.

## Boundary With Toolshed And ADRs

Three layers, three lifetimes. The routing test:

| The decision is... | It goes to... | When |
|---|---|---|
| Contract-changing | ADR / spec (via `spec-adr-builder`) | **the moment decided** -- toolshed law 3, never at close |
| Cross-task contested claim, not contract-changing | verdict node in `docs/verdicts/` | the moment it settles |
| Task-local trivia | toolshed `docs/work/<slug>/` | stays there and dies with the folder |

- A toolshed D-NNN that settled a cross-task claim and somehow wasn't promoted
  gets swept to a verdict node at task close, before the folder is deleted --
  toolshed's close ritual owns that sweep.
- Evidence-grade translation when promoting from toolshed: MEASURED -> S,
  CONFIRMED -> A, REPORTED -> B/C, UNRESOLVED -> no node (no verdict, no node).
- A PR-gate matrix row with Tier S/A evidence becomes a node whose `claim` is
  the row's Claim restated as an assertion and whose `verdict` is `held` when
  the row confirmed it.
- A verdict that turns out to be contract-changing promotes to an ADR; the
  node stays and links to it. Never duplicate ADR content into a node.

## Anti-Patterns

| Anti-pattern | Why it fails |
|---|---|
| Extraction pipeline over the codebase "to seed the graph" | Eager GraphRAG. Pays to index everything, queries almost nothing. Microsoft retreated from this at 1000x cost. |
| Verdict nodes for unsettled claims | The graph stores verdicts, not opinions. No verdict, no node. |
| Loading `docs/verdicts/` wholesale into context | Index + 3-5 nodes. The graph's value IS the selective traversal. |
| Citing a node without the recency check | Stale verdicts are how graphs rot into confident wrongness. |
| Treating a node as independent proof | A node records what was decided, by this same process. It is a cache, not a second opinion. |
| Writing nodes nobody will contest again | One-off trivia buries the signal. Toolshed exists for that. |
