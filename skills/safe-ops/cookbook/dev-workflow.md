# Git, CI and PRs

Apply the authorization policy in ../SKILL.md. Routine authorized Git work
gets one short preview, not approval at every command.

## Local commit

Read status, unstaged diff and cached diff. Preserve unrelated dirty files and
index entries. Stage only named files/hunks belonging to this task; never
`git add -A` by default. If a commit would include unrelated staged work,
isolate the intended commit safely or ask; do not unstage someone else's work.
Inspect the actual staged patch before committing. Run required baseline and
post-change tests. A commit does not authorize push. No Co-Authored-By trailer.

## Fast-forward push

1. Resolve repository, remote and destination branch. Inspect upstream and
   branch protection/CI side effects as relevant; do not assume origin/main.
2. Pin the current local SHA and fetch/query the exact destination. Show the
   commits and diff from its observed SHA to the proposed SHA. A new branch
   uses its intended base; say that the remote ref does not exist yet.
3. With existing push authorization, push the explicit SHA to the exact ref:
   `git push <remote> <new-sha>:refs/heads/<branch>`.
   A normal push preserves the non-fast-forward rejection guard.
4. Read back `git ls-remote <remote> refs/heads/<branch>` and compare the SHA.
   A rejected push is not permission to force, rebase published work or merge
   someone else's changes automatically.

## Merge preview

Use `git merge-tree --write-tree <base-sha> <topic-sha>` for supported Git
versions; exit 1 is conflict evidence. Read the output. This may add objects but
leaves HEAD/index/worktree untouched. A diff alone is not a conflict test.
Never merge into the user's checkout just to preview, and do not automatically
stash/switch their dirty tree. Use an isolated worktree if deeper checks need it.

## History rewrite or rollback

Capture and show exact old/new SHAs, affected commits, target, impact and
recovery before requesting approval of a rewrite. Preserve the old commit.
Use an explicit lease, never --force or a +refspec:

```sh
git push --force-with-lease=refs/heads/<branch>:<expected-old-sha> <remote> <new-sha>:refs/heads/<branch>
```

If an approved rollback must restore the captured old SHA:

```sh
git push --force-with-lease=refs/heads/<branch>:<expected-new-sha> <remote> <captured-old-sha>:refs/heads/<branch>
```

These are templates, not executable commands until exact values are resolved.
Read back the remote after either operation. Lease rejection requires a new
inspection; never replace the expected SHA merely to get the push through.
Prefer a revert for shared history; that changes code and needs its own proof.
Hard reset/deletion also needs loss inventory, including untracked/ignored data.
Do not claim a plain stash backs up everything.

## PRs, CI and releases

- Reading PR state/checks is not publishing. Pin all conclusions to current
  head SHA; stale green checks cannot validate a newer head.
- If requested to create/update a PR, show the destination and content scope,
  then publish without another generic approval. Preserve unrelated body text,
  use an exact body file, and read back the result.
- A PR, green CI or MERGEABLE is neither merge authorization nor release proof.
  Merge/tag/release/deploy are separate actions; check exact head, dependencies,
  review state and relevant protections before an authorized merge.
- Re-run/cancel CI only for named runs/workflows and refs within authority.
  Discover their side effects; do not blindly retry a deployment workflow.
- Remote deletion needs the exact ref, retained SHA, dependent PR/work check,
  approval of the deletion preview, and read-back of absence.
