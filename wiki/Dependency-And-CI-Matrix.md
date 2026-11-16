# Dependency Pin & Local `.ci-engine` Matrix

Last verified: `2026-11-16` (run `./Tools/Get-WorkspaceStatus.ps1` from `RedHome` for live checkout values; sibling lock files are authoritative).

## Current Pin Snapshot Across Siblings

| Repository (from `RedHome`) | Kind | `.ci/project.json` `engine.ref` | `Dependencies/DxUi.lock.json` | `Dependencies/RedMonitor.lock.json` |
| --- | --- | --- | --- | --- |
| [../DxUi](DxUi.md) | `sdk` | `766fd7e01aeef2e77ba18df83b9928516155014e` | *(Producer — API rev 5)* | *(None)* |
| [../RedSalamander](RedSalamander.md) | `application` | `a094b2ea66fc6fd7a8933488a71dacda262903a4` | API `4` @ `4cdf1ce52c77…` | API `1` @ `9ebea6577fe9…` |
| [../RedXe](RedXe.md) | `application` | `07bc6f1e56804390bd5b2ecfdd4027fac2493049` | API `4` @ `f2e328a0a26a…` | API `1` @ `9ebea6577fe9…` |
| [../RedPrism](RedPrism.md) | `application` | `07bc6f1e56804390bd5b2ecfdd4027fac2493049` | API `4` @ `f2e328a0a26a…` | API `1` @ `9ebea6577fe9…` |
| [../RedTilde](RedTilde.md) | `application` | `07bc6f1e56804390bd5b2ecfdd4027fac2493049` | API `5` @ `21fae0dc6600…` | API `1` @ `9ebea6577fe9…` |

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

Return to [Index.md](Index.md).
