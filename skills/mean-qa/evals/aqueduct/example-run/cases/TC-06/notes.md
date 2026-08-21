A `final` notice -- the stage that dispatches a crew -- was accepted for an
account with zero prior notices, from actor "temp-intern", and flipped the
account to shutoff_pending. Oracle: the README disconnection policy, quoted
verbatim: stages "must be issued in order" and final "may only be issued by a
supervisor and only after the two earlier notices exist". db-read.txt shows the
notice row and the status change. Reproduced 2/2. Status: FAILED -> fixed
(409 on ordering, 403 without a supervisor claim).
