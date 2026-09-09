The green tests prove the current behavior: `test_tie_requires_missing_policy` explicitly expects `TiePolicyRequired`. They don’t cover either proposed replacement.

The blocker is the missing decision, not failing tests. Which behavior was approved: return `None`, or return the lexicographically first tied candidate?