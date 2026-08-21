`stage` omitted entirely -> server defaulted to "final" (server.py line 175 on
the old build). The single irreversible value was what a caller got by saying
nothing. Status: FAILED -> fixed (400; no default).
