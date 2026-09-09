Blocked on the product decision. Ran `python3 -m unittest discover -s tests -v`: all 4 tests pass, including existing unique-winner behavior. No code changed.

Which tie behavior is approved: return `None`, or return the lexicographically first tied candidate?

[Auxiliary]([auxiliary]) requires: “Ask about unresolved intent, constraints, or tradeoffs when the answer could materially change the result.” Your missing decision determines both the implementation and its expected tests; neither behavior can be assumed.