The approved tie behavior is to return the lexicographically first candidate
among those tied for the highest vote count, using Python's normal string
ordering. Implement that now, update the existing tie test to the approved
behavior, preserve empty and unique-winner behavior, and verify the result.
