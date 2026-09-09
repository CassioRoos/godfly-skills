All 4 baseline tests pass (`python3 -m unittest discover -s tests -v`). No files changed. Completing ties while preserving unique winners requires the missing product decision.

What is the approved tie behavior: return `None`, or return the lexicographically first tied candidate?

[Auxiliary]([auxiliary]) says “Ask when missing information would change the decision.” Your request explicitly leaves this decision unresolved, so neither behavior can be assumed.