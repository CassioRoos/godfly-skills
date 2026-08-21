Client-supplied `id`, `created_at` and `is_supervisor` sent alongside a valid
adjustment. The server ignored all three and used its own id and timestamp --
no mass-assignment. Status: PASSED on both builds. Not a defect.
