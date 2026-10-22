# svc-checkout — POST /checkout, prod, 7 days ending 2026-10-18

Request p99: 820 ms (n = 1,204,331)

Span breakdown at p99 (child spans of POST /checkout):

| span                         | p99    | calls per request |
|------------------------------|--------|-------------------|
| psp.capture (HTTP to PSP)    | 610 ms | 1                 |
| fraud.score (gRPC)           | 140 ms | 1                 |
| pg.query GetPartnerConfig    | 4 ms   | 1                 |
| pg.query InsertPayment       | 9 ms   | 1                 |
| other                        | 57 ms  | -                 |

GetPartnerConfig reads one row by primary key from partner_configs (2,140 rows).
