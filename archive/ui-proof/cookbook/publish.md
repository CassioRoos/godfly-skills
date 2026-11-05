# Publishing the evidence

Two destinations, decided by whether a PR exists (Phase 0).

## A) PR present — attach with `gh image` + write a verification section

`gh image` (drogers0/gh-image, installed as a `gh` extension) uploads images to GitHub and **prints the markdown image references** to stdout. There is no `upload` subcommand — you pass paths directly:

```bash
gh image <path>...                      # repo inferred from the git remote
gh image --repo owner/repo <path>...    # or pin the repo explicitly
```

Run it from the repo dir so the remote is inferred, or pass `--repo`. Capture the printed markdown — each line is an `![](https://…)` ref you drop into the PR body.

**Auth gotcha — it needs a browser session token, not your `gh` PAT.** `gh image` uploads to GitHub's user-attachments CDN, which requires the same session token a browser uses when you drag an image into an issue. By default it extracts that token from your browser. If it fails:

```bash
gh image check-token            # verify the auto-extracted token, prints your username
gh image extract-token          # print the token it would use
GH_SESSION_TOKEN=<tok> gh image <path>...   # or supply one explicitly
```

If token extraction can't work in this environment, surface that to the user — don't silently fall back to leaving images unattached.

**Then update the PR description.** Add a **UI verification** section to the final body (state the final content only — no revision markers, no changelog). **The evidence is always a table** — one row per case, a Result column, and an Evidence column with the inline `gh image` ref. Never list the screenshots loosely; the table is what a reviewer scans. Follow it with console/network/residual-risk lines:

```markdown
## UI verification
**Tested:** <flow/surface> on <running URL / preview> as <logged-in user>

| Case | Result | Evidence |
|------|--------|----------|
| Happy path | ✅ | ![happy](https://…) |
| Validation error | ✅ | ![validation](https://…) |
| Empty state | ✅ | ![empty](https://…) |

**Console:** clean (no new errors/warnings).
**Network:** all requests 2xx; no failures behind the UI.
**Residual risk:** <what the browser could not prove — backend writes, cross-service effects, prod-only behavior>.
```

Add a row for every case you drove — cover the non-happy states, not just the happy path. Use ❌ (not a silent omission) for any case that failed, and make that a finding.

```bash
gh pr view <n> --json body -q .body > /tmp/body.md   # keep the author's intro if accurate
# append/replace the UI verification section, then:
gh pr edit <n> --body-file /tmp/body.md
```

## B) No PR — local images + a markdown proof doc

Every run gets **its own directory** inside `.proof/`, named `<YYYY-MM-DD>-<HHMM>-<short-target-slug>` — **the time is not optional**, or the second run today lands on the first and destroys it:

```
.proof/
  2026-07-20-profile-address-reveal/
    PROOF.md
    01-view-mode.png
    02-edit-revealed.png
  2026-07-26-events-calendar/
    PROOF.md
    01-home-preview.png
    02-list-grouped.png
```

Rules:

- **Never write files into `.proof/` itself.** One flat directory across runs is why this convention changed: images pile up unbounded with no way to tell which run owns which file, and every run's `PROOF.md` silently overwrites the previous run's — destroying the evidence for work that already shipped.
- **Derive the slug from the target**, not from the date alone: the flow name, the PR topic, or the changed surface (`events-calendar`, `checkout-declined-card`, `profile-address-reveal`). Keep it short and kebab-case.
- **Reuse the current run's directory while iterating** on the same target — including after a Phase 6 fix, where you overwrite the affected screenshots in place. Start a new directory for a different target, or when returning to the same target on a later day.
- **Image refs are relative within the run dir** (`![happy](01-happy.png)`), so the directory stays self-contained and can be moved or attached elsewhere.
- `.proof/` should be gitignored. If it is not, add it rather than committing evidence.

**The evidence is always a table** — the same shape as the PR's UI-verification section, just with relative image paths:

```markdown
# UI proof — <short description>
**Target:** <named flow | current changes | commit <sha>>
**Tested:** <running URL> as <logged-in user>, <date>

## What changed
<plain-language description of the change, tied to the diff/flow>

## Evidence

| Case | Result | Evidence |
|------|--------|----------|
| Happy path | ✅ | ![happy](./01-happy.png) |
| Validation error | ✅ | ![validation](./03-validation.png) |
| Empty state | ✅ | ![empty](./04-empty.png) |

**Console:** clean (no new errors/warnings).
**Network:** all requests 2xx; no failures behind the UI.

## Residual risk
<what the browser could not prove>
```

One row per case you drove — cover the non-happy states, and use ❌ for any that failed. Use relative image paths so the doc renders wherever the dir is opened. Reference real captured screens only — every image in the doc must be one you actually took this run.
