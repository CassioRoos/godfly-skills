amount "1e400" -> float inf -> stored, and json.dumps emitted the bare token
Infinity, which is not valid JSON. strict-parse.txt and the node JSON.parse
check show a browser cannot read the response. accounts-poisoned.json is the
literal body. Worst consequence, tested not assumed: the accounts LIST endpoint
carries the token too, so all six accounts vanished from every clerk's screen
(screenshot 09). Reproduced 2/2. Status: FAILED -> fixed (400 at the door,
allow_nan=False on output, and pre-existing rows now contained per screenshot 17).
