# RedMonitor (`../RedMonitor`)

- **Repository**: `RedSalamanders/RedMonitor` (`versionBase: 0.1`, Winget: `RedSalamanders.RedMonitor`, alias `redmonitor`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedMonitor/AGENTS.md), [Specs/README.md](../../RedMonitor/Specs/README.md), [README.md](../../RedMonitor/README.md), [capabilities.json](../../RedMonitor/capabilities.json), [Active WIP](../../RedMonitor/Specs/Plans/WIP/README.md)

## Overview & Architecture

Independent Windows-native diagnostics viewer and single-header TraceLogging producer SDK extracted from `RedSalamander`:

- **Producer SDK (`include/RedMonitor/Client.h`)**: Single-header C++ client vendored by `RedSalamander`, `RedXe`, `RedPrism`, and `RedTilde` via hash-pinned `Dependencies/RedMonitor.lock.json` (`apiRevision: 1`). Zero background workers/timers in the producer header, zero allocation/formatting on the disabled path, and optional discovery of the separately installed Release `RedMonitor.exe` helper on bare Debug startup.
- **Client tooling**: RedMonitor publishes the canonical update and offline verification scripts with SHA-256 hashes. Adopting consumers keep their root commands. The tooling revision lives in the existing client lock beside the header and notice hashes. [Producer manifest](https://github.com/RedSalamanders/RedMonitor/blob/93fdb0a19acbd48ed59182f4aa42d214cacda6b1/Tools/ClientSdk/manifest.json)
- **Standalone Viewer (`src/` & `support/`)**:
  - Receives the Red-family ETW TraceLogging stream, renders bounded colored logs with Direct2D/DirectWrite/Direct3D 11 and an exact pinned `DxUi` (`API 4`) archive, and opens/exports streaming UTF-8/UTF-16LE text files off the UI thread.
  - `--warp` selects software Direct3D for the viewer and both chrome surfaces. The non-activating `--warp --chrome-selftest` verifies the rendering path. [Viewer contract](../../RedMonitor/Specs/UI/UI_Viewer.md)
  - Settings saves hold a guard for the accepted file version through replacement. A different version raises a revision conflict and a competing new file is preserved. [Settings contract](../../RedMonitor/Specs/Core/Core_Settings.md)
  - The settings watcher coalesces edits to the canonical profile and posts them to the viewer's UI thread. Theme and log-view preferences apply live. Language and saved window placement apply on the next start. [Settings contract](../../RedMonitor/Specs/Core/Core_Settings.md#live-settings)
  - Text export binds overwrite confirmation to the observed destination version. The worker preserves intervening edits and competing new files, and reports a conflict to the viewer. [Export contract](../../RedMonitor/Specs/Core/Core_Architecture.md)
  - `support/` holds a private statically linked MIT migration closure (never exposed to consumers and never linked against `RedSalamander`'s `Common.dll`).
  - Never stops a foreign ETW session; preserves wire GUID, field names/types, severity/filter mapping, and bounded oldest eviction with immutable UI snapshots.

## Repository-Specific Rules & Skills

- **Skills (`../../RedMonitor/.agents/skills/`)**: Repo-specific skills `transport-client`, `viewer-lifetime`, `consumer-adoption` (shared C++/WIL, `spec-workflow`, `test-evidence`, `crash-dumps`, `file-io-safety`, `app-settings`, and `native-build` skills live in `RedHome/.agents/skills/`).
- All six profiles use `/Wall /permissive- /sdl` with `/WX` disabled and a zero-warning build gate. [Build contract](../../RedMonitor/Specs/Build/Build_Consumption.md)
- Open the root `RedMonitor.sln` after dependency restore for all six profiles. The root build command uses `RedMonitor.proj` and records the exact native build receipt. Every native project checks the required MSVC family before preparing the build. [Build contract](../../RedMonitor/Specs/Build/Build_Consumption.md)
- **Live ETW Gate**: `test.ps1 -IncludeLiveEtw` exercises the real ETW transport roundtrip and treats permission denial as a test failure rather than an empty pass.
- **Scoped testing**: The pinned engine reads `Tests/test-scopes.json`. Live ETW is explicit. Release PrePush adds the contained installation smoke. PrePush runs tests on x64 and builds the three ARM64 profiles for native qualification on their own runner. [RedMonitor validation contract](../../RedMonitor/Specs/Testing/Testing_Validation.md)
- Five native projects live in suite folders under `Tests/`. The solution targets and test executable names are stable. [Suite layout change](https://github.com/RedSalamanders/RedMonitor/pull/147)

The root `performance-paired.ps1` and manual benchmark collect x64 Release WARP timing for the chrome, synthetic
burst and scrollback fixture. Review the retained observations under the product's performance contract.
[Validation contract](../../RedMonitor/Specs/Testing/Testing_Validation.md)

## Key Commands

```powershell
Set-Location ..\RedMonitor
.\validate.ps1
.\validate-specs.ps1
.\Tests\Tooling.Tests.ps1
.\build.ps1 -Platform x64 -Configuration Debug
.\build.ps1 -Rebuild -Platform x64 -Configuration Debug -MaxCpuCount 2
.\test.ps1 -Platform x64 -Configuration Debug
.\Test-Changes.ps1 -Explain
.\Test-Changes.ps1 -Mode PrePush -Explain
```

Return to [Index.md](Index.md).
