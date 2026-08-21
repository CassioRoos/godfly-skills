A service class absent from `tariffs` was billed at rate 0.00 / fee 0.00 and
reported as owing nothing. Oracle: the README billing formula plus the four
sibling accounts whose classes ARE on file and bill correctly.
db-read.txt shows the tariffs table has no INDUSTRIAL row.
oracle-join.txt recomputes every account from the raw tables.
Reproduced 2/2 from a clean seed. Status: FAILED -> fixed (billing_status
"blocked", balance_due null).
