#!/bin/sh
# Industrial account: 4313 m3 consumed, service_class has no tariffs row
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' http://localhost:8413/api/accounts/ACC-4471
