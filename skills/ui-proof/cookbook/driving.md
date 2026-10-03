# Driving the Chrome DevTools MCP reliably

The browser is a single stateful resource. Drive it serially, deterministically, and confirm each state before acting on the next. The reliable unit is **snapshot → act → wait → capture**.

## Snapshot first, act by uid

Don't guess selectors. `take_snapshot` returns the accessibility tree with a `uid` for each element; act on those uids.

- `take_snapshot` — current page structure + uids. Re-snapshot after any navigation or DOM change; uids go stale.
- `click {uid}` — click an element.
- `fill {uid, value}` / `type_text` — enter text into an input.
- `fill_form {elements:[{uid,value}...]}` — fill several fields at once.
- `hover {uid}`, `drag`, `select_page`, `press_key`, `upload_file` — for the rest.

If a uid no longer resolves, re-`take_snapshot` — the DOM changed under you.

## Wait for state — never sleep-and-hope

After an action that triggers async work (navigation, fetch, render), `wait_for` the expected text/condition before screenshotting. A screenshot taken mid-transition is evidence of nothing.

- `wait_for {text}` — block until expected text appears (success message, new row, error banner).
- `navigate_page {type:"url", url}` / `new_page {url}` — navigation; pair with a `wait_for`.

## Capture as you go

- `take_screenshot` — page or element (`uid`), `fullPage` for long pages. **Save to disk** with `filePath` (absolute) so you can hand it to `gh image` / reference it in the proof doc. Use a stable naming scheme: `01-login.png`, `02-form-empty.png`, `03-validation-error.png`.
- `list_console_messages` / `get_console_message` — pull console after each meaningful step; an error that appears only during one interaction is easy to miss if you only check at the end.
- `list_network_requests` / `get_network_request` — confirm requests succeeded; catch a silent 4xx/5xx behind a happy-looking screen.

## Cover the states that hide regressions

Don't stop at the happy path. For the changed surface, drive and capture:
- **empty state** (no data yet),
- **loading state** (in-flight),
- **validation errors** (bad/missing input),
- **error/failure state** (request fails, not-found, forbidden),
- **success / final state**.

UI regressions cluster in the non-happy states — a broken empty state or an unstyled error banner is exactly what a screenshot-only happy-path pass misses.

## Isolation, when you need a clean slate

The persistent profile is logged-in state you *want* to reuse. But if a case needs a clean session (e.g. testing the logged-out landing or first-run experience) without disturbing the main session, open it in a named isolated context: `new_page {url, isolatedContext:"clean"}`. Pages in different contexts don't share cookies/storage. Return to the default context for authenticated cases.

## Viewport

`resize_page` to a known size before screenshots so evidence is reproducible.

**If the change touches responsiveness or layout, evidence it at every width it targets — mobile and desktop at minimum, before and after at each.** A single desktop capture proves the half you happened to look at, and layout regressions cluster at the narrow end: content overflowing its container, a label wrapping onto two lines and pushing a control off-screen, a table that scrolls the page instead of itself, a fixed element covering what it sits beside. Use `resize_page` for a raw width or `emulate` for a device profile, and put the width in the filename (`03-cart-390.png`, `04-cart-1440.png`) so a reviewer can tell the pair apart.

**Always clear the override when you finish.** Viewport emulation is sticky: it survives the run and leaves the browser pinned to whatever width you set, so the user can no longer resize their own window. It is *their* browser — a persistent profile they use for real work — and leaving it locked at 1440×900 is a side effect they did not ask for.

Clear it with an empty viewport string:

```
emulate {viewport: ""}
```

You can tell it worked because tool responses stop echoing the `Emulating viewport: {...}` line, and `window.innerWidth` goes back to matching the real window instead of the emulated size.

Do this as the last step of the run, including when the run ends early — a failed verification is exactly when you are most likely to forget, and it leaves the browser in the worst state.
