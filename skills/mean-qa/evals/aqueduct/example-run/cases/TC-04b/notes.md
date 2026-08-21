amount NaN -> sqlite3.IntegrityError -> HTTP 500 carrying the full traceback,
including absolute source paths and the Python install location.
Status: FAILED -> fixed (400 "amount must be a finite number").
