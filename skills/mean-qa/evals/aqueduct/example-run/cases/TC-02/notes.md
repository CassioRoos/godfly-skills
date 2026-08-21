SIGNED-OFF BEHAVIOUR, tested as designed, not as a defect. README and the
consumption() docstring state a swapped meter restarts at zero and the negative
period is carried, not clamped (Billing sign-off 2026-06). Posting a 0 reading
after 1301.5 produced consumption -1301.5 and charges -1844.13. Confirmed still
true after the fixes -- see reverify-positive.txt. Status: PASSED both builds.
NOT filed as a defect.
