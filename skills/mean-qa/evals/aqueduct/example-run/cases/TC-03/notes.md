A credit note of -500 raised the balance from 51.57 to 551.57. Oracle: the
README formula subtracts credits, and the handler docstring states credit notes
cannot be voided -- so a sign error is a permanent charge through the one door
with no undo. Also reproduced through the UI (screenshots 06, 07: 9.00 ->
509.00). Reproduced 2/2. Status: FAILED -> fixed (400, must be > 0).
