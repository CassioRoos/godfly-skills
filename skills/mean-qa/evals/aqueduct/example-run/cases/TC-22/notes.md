A 5000-character `reason` accepted and stored at full length (LENGTH = 5000).
Not filed as a defect: SQLite TEXT is unbounded and nothing truncated or
corrupted. Noted as residual risk -- the field is rendered in the ledger table
and a long value distorts the row. No maximum length was added, because no
documented limit exists to enforce.
