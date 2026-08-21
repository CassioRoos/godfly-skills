read_on "whenever" accepted. Readings are ordered by this column, and the value
sorts lexically above any ISO date, so it became the latest reading: ACC-5520
consumption flipped +47.0 -> -692.0 and the balance to -1407.10, i.e. the
utility now owed the customer 1407.10.

DISTINCT from the signed-off negative-consumption behaviour (TC-02). The
sign-off covers a physical meter swap. This is an unvalidated free-text date
silently redefining which readings are current. The fix validates the date and
does NOT clamp consumption -- TC-02 still carries its negative period.
Status: FAILED -> fixed (400 on a non-date; consumption unchanged at 47.0).
