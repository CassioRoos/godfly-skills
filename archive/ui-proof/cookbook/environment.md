# Establishing the target, the running URL, and the browser profile

You're proving a UI change. Three things must be concrete before you drive anything: **what** you're testing, **which URL** serves that code, and **who** the browser is logged in as.

## 1. Resolve the target

| User said… | Target | How to read the change surface |
|---|---|---|
| "test the checkout flow with a declined card" | a named flow | the flow is the spec — no diff needed |
| passed / mentioned a PR | a PR | `gh pr view <n> --json title,body,headRefName,files,state` then `gh pr diff <n>` |
| nothing, "test my changes" | current uncommitted changes | `git status` + `git diff` + `git diff --cached` |
| a commit SHA / range | a commit | `git show <sha>` or `git diff <base>..<head>` |

If a PR is present, evidence goes **to the PR** (publish.md). Otherwise it goes to a **local proof doc**.

## 2. Resolve the running URL under test

The UI must be running somewhere you can point a browser at, and it must be running *the target code*.

- **Local dev server** — usual for current changes / a commit. Find the command and port: check `package.json` scripts (`dev`, `start`), `README`, `vite.config`/`next.config`, `.env`. Don't assume `localhost:3000` — many apps use 5173 (Vite), 8080, etc. Confirm the right branch is checked out first.
- **Preview deploy** — usual for a PR. A Vercel/Netlify PR preview URL is often in the PR's checks or a bot comment: `gh pr view <n> --json statusCheckRollup` or `gh pr view <n> --comments`. A preview is built from the PR head, so it's already the target code — still confirm the deploy is for *this* PR's latest commit.
- **Staging** — only if that's where the change lands. Note staging may lag the branch.

If nothing is running and it's a local server, start it (background it) and wait for it to be ready before navigating. If you can't tell how the app is served, **ask** — don't guess a URL.

## 3. Confirm you're looking at the new code (do this in Phase 2)

A green dev server or preview URL doesn't guarantee the new code rendered (cached bundle, wrong branch, HMR not applied). Confirm with a marker tied to the diff: a changed string, a new element, a version stamp. Navigate, then `wait_for` that marker before trusting any screenshot.

## 4. The persistent profile + login state

This skill assumes the Chrome MCP drives a **persistent profile that's already logged in** — so you test a representative authenticated session, not a cold anonymous browser.

**At runtime (what this skill does):** after navigating, confirm the expected logged-in user via a snapshot/screenshot (account menu, username, an authenticated-only element). If logged out or the wrong account, **stop and ask** — re-authenticating silently can land you on the wrong tenant/account and invalidate the evidence.

**One-time MCP config (outside this skill — a server launch flag, not runtime).** The default `chrome-devtools-mcp` launch uses a persistent profile dir already, but to pin it to a known logged-in profile, configure the server with a dedicated user-data dir:

```jsonc
// in the chrome MCP server definition (e.g. ~/.claude.json mcpServers.chrome)
{
  "command": "npx",
  "args": [
    "-y", "chrome-devtools-mcp@latest",
    "--user-data-dir", "/Users/<you>/.config/ui-proof-chrome-profile"
  ]
}
```

Log in once in that profile; it persists across runs. (`--isolated` would do the opposite — a throwaway profile each run — so do **not** set it. `--browser-url` would attach to an already-running Chrome instead, an alternative if you prefer driving your real browser.) A skill cannot change these flags at runtime — if the profile isn't persistent/logged-in, fix the config once, then re-run.
