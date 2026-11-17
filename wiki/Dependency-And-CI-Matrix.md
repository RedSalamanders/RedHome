# Dependency Pin & Local `.ci-engine` Matrix

This page records which file owns each pin and which API revision each repository consumes. It deliberately holds no commit SHAs: run `pwsh -NoProfile -File ./Tools/Get-WorkspaceStatus.ps1` from `RedHome` for live values, and treat the sibling lock files as authoritative. Dated pin snapshots and pending pin waves belong in [the active plans](../Specs/Plans/WIP/README.md).

## Pin Owners And Consumed API Revisions

| Repository (from `RedHome`) | Kind | Shared CI engine pin | `DxUi` | `RedMonitor` client |
| --- | --- | --- | --- | --- |
| [../DxUi](DxUi.md) | `sdk` | `.ci/project.json` `engine.ref` | Producer; API revision declared in `capabilities.json` (`5`) | None |
| [../RedSalamander](RedSalamander.md) | `application` | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json`, API `4` | `Dependencies/RedMonitor.lock.json`, API `1` |
| [../RedXe](RedXe.md) | `application` | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json`, API `4` | `Dependencies/RedMonitor.lock.json`, API `1` |
| [../RedPrism](RedPrism.md) | `application` | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json`, API `4` | `Dependencies/RedMonitor.lock.json`, API `1` |
| [../RedTilde](RedTilde.md) | `application` | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json`, API `5` | `Dependencies/RedMonitor.lock.json`, API `1` |
| [../RedMonitor](RedMonitor.md) | `application` | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json`, API `4` | Producer; API `1` |

In every repository the `@<40-hex-SHA>` in `.github/workflows/*.yml` callers must equal `engine.ref`, and `<repo>/.ci-engine` must be detached at that same commit.

## Why `DxUi` and `.ci-engine` Sync Differently

1. **`DxUi` (`restore-dxui.ps1`)**:
   - Restores automatically during `build.ps1` into `.build/dependencies/DxUi/source/<commit16>` (sparse, `core.longpaths=true`, reading local `../DxUi` when it already has the commit without mutating `../DxUi`).
   - Fingerprints MSVC toolset, Windows SDK, CRT, and optimization policy into `.build/dependencies/DxUi/<fingerprint16>` and writes `DxUi.resolved.<Platform>.props`.
   - `Show-DxUiUpdateNotice` (`ConsumerUpdate.psm1`) prints a read-only color-coded advisory when `DxUi` `main` moves ahead of `DxUi.lock.json`.
2. **`.ci-engine` (`.ci/project.json` + `.github/workflows/*.yml`)**:
   - GitHub Actions requires static `@<40-hex-SHA>` pins in workflow YAML files and checks out the engine to `<repo>/.ci-engine` (see [Shared-CI-Engine.md](Shared-CI-Engine.md)).
   - Local `build.ps1`, `test.ps1`, and `Test-Changes.ps1` import `.ci-engine/Tools/Modules/Ci.{Policy,SourceInputs,SdkConsumer,LocalSdkRuntime,DesktopLease}.psm1` at startup, and `Get-CiPinnedEngineInputsIdentity` throws if `<repo>/.ci-engine` is missing, dirty, or not detached at `.ci/project.json`'s `engine.ref`.
   - When pulling a commit that changed `.ci/project.json` in a sibling repo, verify `git -C .ci-engine status --porcelain` is clean, then sync:
     ```powershell
     $pin = (Get-Content .ci/project.json -Raw | ConvertFrom-Json).engine.ref
     git -C .ci-engine fetch origin $pin
     git -C .ci-engine checkout --detach $pin
     ```

3. **Dependabot engine notices are signals, not pin updates**:
   - A Dependabot pull request that bumps one `RedSalamanders/.github` workflow caller changes a single `@SHA` and leaves `.ci/project.json` behind. Merging it creates caller drift that then has to be reconciled.
   - Adopt a new engine only through `Update-ProjectPin.ps1` (see the `cross-repo-pins` skill), then close the notice.

Return to [Index.md](Index.md).
