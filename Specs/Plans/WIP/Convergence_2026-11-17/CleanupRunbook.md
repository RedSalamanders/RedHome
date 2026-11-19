# Phase 0 cleanup record

**Completed on 17–18 November 2026.** This is the recovery record for CV-0-01 through CV-0-11 in the [convergence plan](../Convergence_2026-11-17.md#phase-0-clean-baseline-hygiene-no-content-change). Phase 0 has no outstanding deletion. New worktrees and branches belong to their current work.

## Preserved history

D14 authorizes the private archive `D:\Archive\RedSalamanders-20261117`. Treat these files as immutable recovery evidence. The original operation verified bundle integrity, ref identity and recovery in an empty repository. The inventory on 19 November confirmed all three files and the archived `master` tip. A second-disk copy was requested. Its verification is still unrecorded.

| Archive file | Preserved content |
| --- | --- |
| `RedSalamander-local-branches.bundle` | The retired local `master` at `582d644b`, including its private history. Its source snapshot is already present on public `main`. Recovery stays local. |
| `RedTilde-unreferenced-and-backups-20261118.bundle` | 28 recovered unreferenced commits and three backup refs. |
| `DxUi-unreferenced-and-backups-20261118.bundle` | 24 recovered unreferenced commits and seven backup refs. |

The following inspection reads the existing files and refs. Run it from the RedHome sibling workspace.

```powershell
$archiveDirectory = 'D:\Archive\RedSalamanders-20261117'
$masterBundle = Join-Path $archiveDirectory 'RedSalamander-local-branches.bundle'
Get-ChildItem -LiteralPath $archiveDirectory -File -Filter '*.bundle' | Select-Object Name, Length
git -C ../RedSalamander bundle verify $masterBundle
git bundle list-heads $masterBundle refs/heads/master
```

For recovery, inspect the named bundle on a private local machine and select the exact archived ref. Restore into a new private local checkout or an unused recovery ref. D14 keeps the historical commits, tags and bundles off public remotes.

## Results of the original operation

The engine clone was brought current. Stale tracking refs, finished worktrees and the archived experiment branches were retired. Automatic deletion of merged PR heads was enabled in all eight repositories. The 20 single-caller engine notices were closed. DxUi's supported API 4 line was renamed and protected as `maintenance/api4`. Its unfinished motion branch, the recorded tool-owned refs and the DxUi stash were retained. RedSalamander's hosted regression was triaged separately under CV-0-07.

## Future cleanup

Start a new inventory for each future cleanup. `Tools/Get-WorkspaceStatus.ps1 -Hygiene` reports the local checkouts at inspection time. Record each proposed ref and its exact tip, worktree, owner, open or unsubmitted work, and intended disposition. An absent PR, clean worktree or merged tip alone does not establish that a worktree is finished. Preserve dirty, untracked, ignored evidence and active work with their owner.

An owner-approved retirement uses a fresh, unused bundle filename. Verify the exact ref-to-commit map, recoverability and second copy before retiring those specific refs. Recheck their tips and worktree ownership immediately before action. Keep all three historical bundles, protected maintenance branches and tool-owned refs. The historical inventory confers no permission to prune a current checkout or publish any archive.
