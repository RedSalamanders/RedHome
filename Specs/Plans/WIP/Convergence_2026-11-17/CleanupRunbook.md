# Cleanup runbook (Phase 0)

Companion to [the convergence plan](../Convergence_2026-11-17.md). These are the hygiene steps that delete something. **None of them has been run.** They are written for the owner to run in PowerShell 7 on the Windows host, where the clones live under `D:\`. Do not run them from WSL or a sandbox: Windows worktree paths are invisible there.

Each step has the same shape: look, archive, delete, check. Stop at the first surprise.

**State at the review of 2026-11-17 (21:45 CET), read from the clones on the Windows host.** Steps 1, 2, 5, and 7 show as done: the engine clone is at `a094b2e`, every clone has only live remote-tracking refs and no extra worktree, and no engine notice is open. The local branches of step 6 are gone except `RedSalamander` `master`. The archive of step 4 was not found: `D:\Archive` does not exist. Before anything else, either record where the bundles are, or recover the experiment branches. Their commits are still in the object stores: `git fsck --no-reflogs` reports 23 dangling branch tips in `RedTilde`, 22 of them committed between 2026-10-24 and 2026-10-29, and 24 in `DxUi`, 8 of them between 2026-10-25 and 2026-10-27. They stay only until git prunes them, and they are already older than git's two-week grace period, so do not run `git gc` in those clones first. To keep them, give each tip a ref (`git update-ref refs/rescue/<n> <sha>`) and then bundle those refs as in step 4. Step 3 is open for three repositories, not two: the engine repository also has automatic deletion off. `RedSalamander` `master` has since been through steps 4 and 6 (CV-0-06): its bundle is the only file in `D:\Archive\RedSalamanders-20261117`, and the branch is deleted.

**State on 2026-11-18, after the owner accepted D10.** Steps 2, 3, and 6 are done: every clone is pruned to the branches GitHub has, automatic deletion is on in all eight repositories (step 3 now also covers `RedSalamanders/.github`), and the merged head branches left on GitHub (`RedHome` #2 and #3, `RedMonitor` #63) are deleted. Step 4 is half done: instead of `refs/rescue/<n>`, every unreferenced commit in `RedTilde` (28) and `DxUi` (24) has a local ref under `refs/archive/unreferenced-20261118/`, so nothing can be pruned, and no bundle is written yet. The bundle location is open: `$archive` below is at a drive root, which the drive-root output policy allows only for `<Project>.Perf` and only after the owner authorizes the exact path. Once the location is settled, bundle the pinned commits with `git bundle create <file> --glob=refs/archive/unreferenced-20261118`, verify it, then delete the refs with `git for-each-ref --format='delete %(refname)' refs/archive/unreferenced-20261118 | git update-ref --stdin`.

```powershell
$repos = [ordered]@{
    RedHome       = 'D:\RedHome'
    DxUi          = 'D:\DxUi'
    RedSalamander = 'D:\RedSalamander'
    RedXe         = 'D:\RedXe'
    RedPrism      = 'D:\RedPrism'
    RedTilde      = 'D:\RedTilde'
    RedMonitor    = 'D:\RedMonitor'
    Engine        = 'D:\RedSalamanders\.github'
}
$archive = 'D:\Archive\RedSalamanders-20261117'
New-Item -ItemType Directory -Force $archive | Out-Null
```

## 0. Before and after

Record the numbers before the first step and after the last one. The script changes nothing.

```powershell
pwsh -NoProfile -File D:\RedHome\Tools\Get-WorkspaceStatus.ps1 -Hygiene
```

Target after the runbook: `LocalOnly`, `Merged`, `UpstreamGone`, and `ExtraWorktrees` are 0 everywhere, and `RemoteRefs` matches the branch count on GitHub.

## 1. Bring the engine clone up to date (CV-0-01)

The local engine clone is about 70 pull requests behind.

```powershell
git -C $repos.Engine status -sb          # look: which branch, any local change
git -C $repos.Engine fetch --prune origin
git -C $repos.Engine switch main
git -C $repos.Engine merge --ff-only origin/main
git -C $repos.Engine log -1 --format='%h %s'   # check: a094b2e or newer
```

## 2. Prune stale remote-tracking refs (CV-0-02, first half)

GitHub already deleted these branches. This only removes the local memory of them.

```powershell
foreach ($name in $repos.Keys) {
    git -C $repos[$name] fetch --prune origin
    '{0}: {1} remote-tracking refs' -f $name, @(git -C $repos[$name] for-each-ref refs/remotes/origin).Count
}
```

Expected afterwards (GitHub on 2026-11-17, including `main` and `ci-state`): `RedHome` 2, `DxUi` 4, `RedSalamander` 2, `RedXe` 7, `RedPrism` 7, `RedTilde` 7, `RedMonitor` 7, engine 3. Add one for `origin/HEAD`.

## 3. Turn on automatic deletion of head branches (CV-0-03)

It was on in five repositories and off in three; it is on in all eight since 2026-11-18. This is a repository setting, not a deletion.

```powershell
gh api -X PATCH repos/RedSalamanders/RedHome    -F delete_branch_on_merge=true --jq .delete_branch_on_merge
gh api -X PATCH repos/RedSalamanders/RedMonitor -F delete_branch_on_merge=true --jq .delete_branch_on_merge
gh api -X PATCH repos/RedSalamanders/.github    -F delete_branch_on_merge=true --jq .delete_branch_on_merge
```

## 4. Archive every local branch that GitHub does not have (CV-0-04, CV-0-06)

One bundle per repository holds every local branch except `main`: the 29 experiment branches in `RedTilde`, the 6 in `DxUi`, `RedSalamander` `master`, and anything else that was never pushed. A bundle is a single file that `git clone` and `git fetch` can read.

```powershell
foreach ($name in $repos.Keys) {
    $path = $repos[$name]
    $branches = @(git -C $path for-each-ref refs/heads --format='%(refname:short)' | Where-Object { $_ -ne 'main' })
    if (-not $branches) { "${name}: nothing to archive"; continue }
    $bundle = Join-Path $archive "$name-local-branches.bundle"
    git -C $path bundle create $bundle @branches
    git -C $path bundle verify $bundle
    $inBundle = @(git bundle list-heads $bundle).Count
    '{0}: {1} branches, {2} heads in bundle' -f $name, $branches.Count, $inBundle
    if ($inBundle -ne $branches.Count) { throw "$name bundle is incomplete. Stop." }
}
```

Check: every repository prints the same number twice, and `bundle verify` says the bundle is okay. Copy `$archive` to a second disk before the next step.

## 5. Remove finished worktrees (CV-0-05)

`RedTilde` has 48 registrations, `DxUi` 44, the engine clone 11. A branch that is checked out in a worktree cannot be deleted, so worktrees go first.

```powershell
foreach ($name in 'RedTilde', 'DxUi', 'Engine') {
    $path = $repos[$name]
    $worktrees = @(git -C $path worktree list --porcelain | Where-Object { $_ -like 'worktree *' } | ForEach-Object { $_.Substring(9) })
    foreach ($wt in $worktrees | Select-Object -Skip 1) {      # the first entry is the main clone
        if (-not (Test-Path -LiteralPath $wt)) { continue }     # folder already gone; pruned below
        $dirty = git -C $wt status --porcelain
        if ($dirty) { Write-Warning "$wt has uncommitted changes. Skipped."; continue }
        git -C $path worktree remove $wt
    }
    git -C $path worktree prune -v                              # drops registrations whose folder is gone
    '{0}: {1} worktrees left' -f $name, (@(git -C $path worktree list).Count - 1)
}
```

Check: every skipped worktree is listed with a warning. Look at each one by hand; its work is not in the bundle unless it was committed.

## 6. Delete the archived local branches (CV-0-02 second half, CV-0-04, CV-0-06)

Only after step 4 printed matching counts and the archive is copied. `main` is kept; a branch that still has an open pull request is kept.

```powershell
foreach ($name in $repos.Keys) {
    $path = $repos[$name]
    git -C $path switch main
    $branches = @(git -C $path for-each-ref refs/heads --format='%(refname:short)' | Where-Object { $_ -ne 'main' })
    foreach ($branch in $branches) {
        $open = if ($name -eq 'Engine') { gh pr list --repo RedSalamanders/.github --head $branch --state open --json number --jq length }
                else { gh pr list --repo "RedSalamanders/$name" --head $branch --state open --json number --jq length }
        if ($open -ne '0') { "${name}: kept $branch (open pull request)"; continue }
        git -C $path branch -D $branch
    }
}
```

`RedSalamander` `master` (3,102 commits that `main` does not have, local only) was deleted this way on 2026-11-17 and stays recoverable from `RedSalamander-local-branches.bundle`. Its code is already on `main` (commit `397e15ad` has the same tree); only its history is in the bundle. Running step 4 again in `RedSalamander` finds nothing to archive, so it does not overwrite that bundle. To make the history visible on GitHub as well, restore the branch from the bundle and push it as a tag: `git -C D:\RedSalamander tag archive/master-20261117 master; git -C D:\RedSalamander push origin archive/master-20261117`.

To restore any branch later: `git -C <clone> fetch <bundle> <branch>:<branch>`.

## 7. Close the engine notices (CV-4-03)

After the step 1 pull request of a repository is merged, Dependabot stops opening these. The 20 that are open must be closed, not merged: each one bumps a single workflow caller.

```powershell
foreach ($name in 'RedXe', 'RedPrism', 'RedTilde', 'RedMonitor') {
    $notices = gh pr list --repo "RedSalamanders/$name" --author 'app/dependabot' --state open --json number,headRefName |
        ConvertFrom-Json | Where-Object { $_.headRefName -like 'dependabot/github_actions/RedSalamanders/dot-github/*' }
    foreach ($pr in $notices) {
        gh pr close $pr.number --repo "RedSalamanders/$name" --delete-branch --comment 'Engine pins move in one wave through Update-ProjectPin.ps1, not one caller at a time.'
    }
}
```

## 8. Left for a decision, not deleted

- `DxUi` has two unmerged branches on GitHub: `ej/api4-maintenance-4cdf1ce5` and `ej/dxui-performance-motion-impl-wip`. They look like work in progress. Merge, archive as a tag, or delete them by hand.
- The engine repository has two open Dependabot branches for `github/codeql-action`. They are ordinary dependency updates.
