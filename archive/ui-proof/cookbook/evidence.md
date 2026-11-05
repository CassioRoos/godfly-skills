# What counts as evidence

A screenshot proves something *rendered*. It does not prove the feature *works*. Verification means the rendered state, the interaction, and the layers beneath all agree.

## Each claim maps to a captured artifact

| Claim | Evidence |
|---|---|
| The screen renders correctly | screenshot of the final state (saved to disk, named) |
| The change does what it intended | **before/after** screenshots — old behavior vs new (use git stash / the base branch, or a prior screenshot) |
| An interaction works | the trail: screenshot before → action taken → `wait_for`'d result → screenshot after |
| Validation/error handling works | screenshot of each error/empty/loading state, not just success |
| Nothing broke underneath | `list_console_messages` showing no new errors/warnings + `list_network_requests` showing no failed/unexpected requests for the interaction |
| A request actually succeeded | the network entry: method, URL, **status**, and that the response drove the UI (not a 200 with an error body) |
| Responsive/layout change | screenshots at the relevant widths (`resize_page`/`emulate`) |

## Before/after is the strongest UI evidence

For a visual or behavioral change, one "after" screenshot is weak — a reviewer can't see what moved. Capture the base state too: stash the change (or check out the base branch / use the PR's base preview), screenshot the same screen, then apply the change and screenshot again. Side-by-side, the delta is undeniable.

## Console + network are not optional

The single most common UI false-positive: a screenshot that looks perfect over a console full of errors and a failed XHR. After each meaningful interaction, pull console and network and read them:
- **Console** — any error/warning the change introduced? (Distinguish pre-existing noise from new noise — check the base state's console too if unsure.)
- **Network** — any request that 4xx/5xx'd, hung, or returned an error payload behind a happy-looking screen?

A clean screen with a dirty console/network is a **finding**, not a footnote.

## Capture discipline

- **Probe a writable path before you drive anything.** `filePath` is enforced against the browser tooling's own workspace root, which is not your working directory and is often narrower — a path outside it is refused with an access-denied error naming "workspace roots". Take one throwaway capture into the intended run directory first; if it is refused, find a permitted directory, capture there, and move files in as you go. The refusal is silent in effect: omitting `filePath` still *shows* you the image, so the run feels evidenced while the disk stays empty. Never name an image you have not listed on disk.
- Save every screenshot to disk via `filePath` (absolute path) into **this run's** directory — `.proof/<YYYY-MM-DD>-<HHMM>-<short-target-slug>/` (see [publish.md](./publish.md)); name them in order (`01-…`, `02-…`) so the narrative reconstructs from filenames. Names only have to be unique within the run, so no cross-run prefixes are needed.
- Pull console/network *as you go*, not once at the end — a transient error is invisible after the next navigation.
- Pin the viewport (`resize_page`) so screenshots are reproducible, then clear the emulation when the run ends (`emulate {viewport: ""}`) so the user's window is theirs again.
- Note what you could **not** prove from the browser (a backend write, an email sent, a cross-service effect) — that's residual risk, or hand it to `pr-proof`. Never imply you proved more than you saw.
