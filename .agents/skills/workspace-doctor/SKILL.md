---
name: workspace-doctor
description: Inspect read-only sibling checkout health across RedSalamander, RedXe, RedPrism, RedTilde, DxUi, and shared CI pins without mutating any repository.
---

# Workspace Doctor

Use this skill when starting a multi-repo session, diagnosing build/restore mismatches (such as `.ci-engine` pin drift or `DxUi.lock.json` differences), or checking which sibling repositories are clean and ready.

## Iron Law

Read-only inspection only. Never run `git reset`, `git checkout`, `git clean`, `restore-dxui.ps1`, or `Update-ProjectPin.ps1` during diagnostics unless the user explicitly asks to repair a specific checkout.

## Workflow

1. Run `pwsh -NoProfile -File ./Tools/Get-WorkspaceStatus.ps1` from `RedHome` (or inspect `../*` directly if bootstrapping).
2. For each present sibling (`../DxUi`, `../RedSalamander`, `../RedXe`, `../RedPrism`, `../RedTilde`, `../RedMonitor`, `../RedSalamanders/.github`), report:
   - Current branch, `HEAD` commit prefix, and working-tree status (`Clean` vs `Dirty`).
   - `.ci/project.json` `engine.ref` vs `../<Project>/.ci-engine` `HEAD` and cleanliness (`Missing`, `Mismatch`, `Dirty`, or `Verified`).
   - `Dependencies/DxUi.lock.json` (`apiRevision` and `commit`) compared against `../DxUi` `HEAD`.
   - `Dependencies/RedMonitor.lock.json` (`apiRevision` and `commit`).
3. Flag actionable blockers clearly:
   - Missing or mismatched `.ci-engine` checkouts block local `build.ps1`, `test.ps1`, and `Test-Changes.ps1`.
   - Dirty `.ci-engine` checkouts refuse local evidence reuse in `Ci.SourceInputs.psm1` and must be inspected before detaching.
   - Any unexpected folders at the parent drive root violating the Drive-Root Output Policy.
