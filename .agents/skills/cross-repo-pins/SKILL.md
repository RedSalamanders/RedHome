---
name: cross-repo-pins
description: Inspect sibling checkout health and coordinate DxUi, RedMonitor, and shared .ci-engine pin updates across producer and consumer repositories. Use when starting a cross-repository session, when a .ci-engine, DxUi.lock.json, or RedMonitor.lock.json pin looks wrong, when planning or applying a pin wave, or when Dependabot bumps a shared workflow caller.
---

# Cross-Repo Pins & Workspace Health

Use this skill at session start to check sibling checkout health, diagnose `.ci-engine` or `DxUi.lock.json` mismatches, or plan and execute dependency pin waves across RedSalamanders repositories.

## Iron Laws

1. Diagnostics are strictly read-only: never run `git reset`, `git checkout`, `git clean`, `restore-dxui.ps1`, or `Update-ProjectPin.ps1` until the user authorizes modifying a target checkout.
2. Producer qualification precedes consumer adoption: never bump a consumer's `DxUi.lock.json` or `.ci/project.json` to an unqualified or dirty producer commit, and never mutate a developer's sibling producer checkout (`../DxUi` or `../RedSalamanders/.github`) during consumer restores.
3. Even within the same numeric `DxUi` `apiRevision`, C++ layout changes require a full consumer rebuild (`build.ps1 -Rebuild`) across configurations. Crossing an API revision (such as API 4 to API 5) requires reading `../DxUi/CHANGELOG.md`, `../DxUi/Changes/`, and `../DxUi/docs/upgrade.md`, installing the consumer failure host, and updating `apiRevision` in `Dependencies/DxUi.lock.json`.
4. A Dependabot pull request that bumps one `RedSalamanders/.github` workflow caller is a notice that the engine moved, not a pin update: merging it changes a workflow `@SHA` without `.ci/project.json`. `DxUi` repaired exactly that drift in its #262 (2026-11-17). Adopt the engine with `Update-ProjectPin.ps1` and close the notice.

## Workflow

1. **Inspect Workspace Health (Read-Only)**:
   - Run `pwsh -NoProfile -File ./Tools/Get-WorkspaceStatus.ps1` from `RedHome` and consult [wiki/Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md).
   - Report branch, `HEAD` SHA, dirty state, `.ci/project.json` `engine.ref` vs `<repo>/.ci-engine` (`OK`, `MISSING`, `MISMATCH`, `DIRTY`), `DxUi.lock.json`, and `RedMonitor.lock.json`, plus any unexpected drive-root folders.
2. **Execute Pin Updates Safely**:
   - **Local `.ci-engine` sync**: Verify `git -C ../<Project>/.ci-engine status --porcelain --untracked-files=all` is clean (preserve dirty local work), then `fetch` and `checkout --detach` the exact `.ci/project.json` `engine.ref`.
   - **Shared CI Engine bump**: From a clean `../RedSalamanders/.github` checkout at the reviewed SHA, run `./Tools/Update-ProjectPin.ps1 -Root ../<Project> -EngineRef <40-hex-sha>` so `.ci/project.json` and workflow `@SHA` callers move together, sync `<repo>/.ci-engine`, and run compiler-free static checks.
   - **`DxUi` pin bump**: Read the target consumer's `DxUi` contract first (`Specs/Core/Core_DxUiIntegration.md` in `RedXe` and `RedPrism`, `Specs/Build/Build_Toolchain.md` in `RedSalamander` and `RedTilde`, `AGENTS.md` in `RedMonitor`, plus the `consumer-dxui` skill in `RedPrism` and `RedTilde`), update `Dependencies/DxUi.lock.json` on a feature branch, add one `Changes/` fragment, rebuild, and qualify x64 `Debug`, `Release`, `ASan Debug` plus ARM64 builds.
   - **`RedMonitor` client bump**: Use the consumer's `Verify-RedMonitorClient.ps1` / `Update-RedMonitorClient.ps1` helper so `ThirdParty/RedMonitor/include/RedMonitor/Client.h`, `LICENSE.txt`, and SHA-256 hashes stay aligned.
3. Refresh [wiki/Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md) after consumer branches merge.
