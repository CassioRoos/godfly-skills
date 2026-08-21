Body "not json at all {{{" -> 500 with json.decoder traceback and the Python
install path. Oracle: the read side of the same codebase returns a clean 404
for a missing account (TC-19b), so a 500 here is an internal inconsistency, not
house style. Status: FAILED -> fixed (400 "request body is not valid JSON").
