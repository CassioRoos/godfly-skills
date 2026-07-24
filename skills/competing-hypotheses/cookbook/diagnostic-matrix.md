# Diagnostic Matrix

## Building the Matrix

### Step 1: Define Approaches (Columns)

List 3-5 genuinely different approaches. Each must pass these filters:
- **Real:** Used in production by at least one known team/company
- **Viable:** Could actually work for this specific problem
- **Distinct:** Represents a meaningfully different approach, not a minor variation

Bad example: "React vs React with Redux vs React with Zustand" -- these are variations, not competing hypotheses.

Good example: "Server-rendered monolith vs SPA with API vs Islands architecture" -- genuinely different approaches.

### Step 2: Define Evidence (Rows)

List ALL relevant evidence, constraints, and requirements:
- Hard requirements (must-haves)
- Soft requirements (nice-to-haves)
- Team constraints (skills, timeline, headcount)
- Technical constraints (existing architecture, infrastructure)
- Operational constraints (deployment, monitoring, on-call)
- Known risks (from failure analysis)

### Step 3: Rate Each Cell

For each approach-evidence intersection:

| Rating | Symbol | Meaning |
|--------|--------|---------|
| Strongly supports | `++` | This approach excels here |
| Supports | `+` | This approach handles this adequately |
| Neutral | `o` | No meaningful impact either way |
| Contradicts | `-` | This approach struggles here |
| Strongly contradicts | `--` | This approach fundamentally conflicts |
| Unknown | `?` | We don't have enough information |

### Step 4: Analyze

**Count contradictions, not supports.** A single `--` can eliminate an approach regardless of how many `+` ratings it has.

**Identify diagnostic evidence.** The most valuable evidence is evidence where approaches differ the most. If all approaches rate `+` on a requirement, that requirement doesn't help you choose.

**Flag unknowns.** Cells marked `?` represent gaps in your analysis. Before deciding, determine whether these unknowns could change the outcome.

## Example: Choosing a Sync Architecture

| Evidence | Polling | Webhooks | CDC (Change Data Capture) |
|----------|---------|----------|---------------------------|
| Real-time updates needed | -- | ++ | ++ |
| Third-party API limitations | ++ | - (requires endpoint) | -- (no DB access) |
| Team familiarity | ++ | + | - |
| Operational complexity | + | o | -- |
| Data consistency guarantee | + | - (delivery not guaranteed) | ++ |
| Existing infrastructure fit | + | + | - (need Debezium) |
| Scale to 1000 integrations | -- | + | ++ |

**Analysis:**
- Polling has the most `--` at scale -> eliminated for long-term
- CDC has the most `--` on feasibility -> eliminated (no DB access to third parties)
- Webhooks best fit overall, but delivery guarantee is a real concern
- **Decision:** Webhooks with idempotent processing and polling as fallback
- **Diagnostic evidence:** "Third-party API limitations" eliminated CDC entirely

## Reading the Matrix

### Red Flags
- An approach with any `--` on a hard requirement is eliminated
- An approach with many `?` needs more investigation before deciding
- All approaches rating `-` or `--` on the same evidence means the requirement needs rethinking

### Decision Criteria
1. **Eliminate first:** Remove approaches with fatal contradictions
2. **Differentiate:** Focus on evidence where remaining approaches differ
3. **Decide:** Choose the approach with fewest contradictions (not most supports)
4. **Document conditions:** "We'd switch to approach B if [condition changes]"

## Avoiding Bias

| Bias | How it shows up | Counter |
|------|----------------|---------|
| **Anchoring** | First approach gets the most `+` ratings | Rate all approaches for one evidence row at a time (horizontal) |
| **Confirmation** | Favorite approach gets generous ratings | Have someone else rate independently |
| **Availability** | Recent experience with one approach inflates ratings | Require citations for `++` and `--` ratings |
| **Sunk cost** | Existing approach rated `++` because of investment | Rate approaches blind to current implementation |
