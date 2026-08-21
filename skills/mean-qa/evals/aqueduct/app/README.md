# Aqueduct — billing console

Internal console the revenue clerks use to look at a water account, add a meter
reading, correct a bill, and start the disconnection process. Small Python
service, SQLite behind it, plain HTML/JS front end. Nothing here is public.

## Run it

```bash
python3 seed.py            # rebuilds aqueduct.db from the fixture data
python3 server.py 8410     # http://localhost:8410
```

`seed.py` drops and recreates everything, so it is safe to re-run whenever the
data gets messy.

## What the screens do

- **Accounts** — every account with its current consumption and balance due.
- **Account detail** (`/account/ACC-1188`) — meter readings, the ledger of
  adjustments / credit notes / shutoff notices, and the three clerk actions.
- **Reports** — not built yet, the nav link is a placeholder.

## Clerk actions

| Action | Endpoint | Notes |
|---|---|---|
| Add meter reading | `POST /api/readings` | `{account_id, meter_m3, read_on?}` |
| Apply adjustment | `POST /api/adjustments` | `{account_id, amount, reason, actor}` |
| Issue credit note | `POST /api/credit-notes` | `{account_id, amount, reason, actor}` |
| Issue shutoff notice | `POST /api/shutoff` | `{account_id, actor, stage}` |

Read side: `GET /api/accounts`, `GET /api/accounts/<id>`.

## Billing rules

`balance_due = standing_fee + (rate_per_m3 × consumption) + adjustments − credits`

Consumption is the latest reading minus the one before it. Rates live in the
`tariffs` table, one row per service class, refreshed from the Revenue team's
weekly export.

**Negative consumption is intentional.** When a meter is swapped the new unit
starts at zero, so that period reads negative. Billing signed this off in June
2026: the negative period is carried, not clamped, so the customer is not
charged twice for the same water. Please do not "fix" this.

## Disconnection policy

A disconnection is a three-step process and the stages must be issued in order:
`reminder`, then `warning`, then `final`. A `final` notice is what actually
sends a crew, so it may only be issued by a supervisor and only after the two
earlier notices exist for that account. Once a crew is dispatched the
disconnection is not reversible from the console.

## Known gaps

- `audit_log` table exists but nothing writes to it yet.
- No login. The console runs on the office network and the `actor` field is
  whatever the client sends.
- Reports screen is unbuilt.
