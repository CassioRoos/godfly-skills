# run-case helper:  rc <case-id> <curl-args...>
ROOT=/srv/aqueduct
RUN=$ROOT/.proof/2026-08-21-1500-aqueduct-billing-console
rc() {
  id=$1; shift
  d=$RUN/cases/$id; mkdir -p "$d"
  { printf '#!/bin/sh\ncurl -sS -w '"'"'\\nHTTP %%{http_code} in %%{time_total}s\\n'"'"' \\\n'
    for a in "$@"; do printf "  '%s' \\\\\n" "$a"; done
    printf '  ;\n'; } > "$d/request.sh"
  chmod +x "$d/request.sh"
  echo "===== $id ====="
  curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' "$@" 2>&1 | tee "$d/response.txt"
}
q() { sqlite3 "$ROOT/aqueduct.db" "$1"; }
