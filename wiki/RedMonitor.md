# RedMonitor (`../RedMonitor`)

- **Repository**: `RedSalamanders/RedMonitor` (`versionBase: 0.1`, Winget: `RedSalamanders.RedMonitor`, alias `redmonitor`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedMonitor/AGENTS.md), [Specs/README.md](../../RedMonitor/Specs/README.md), [README.md](../../RedMonitor/README.md), [capabilities.json](../../RedMonitor/capabilities.json), [Active WIP](../../RedMonitor/Specs/Plans/WIP/README.md)

## Overview & Architecture

Independent Windows-native diagnostics viewer and single-header TraceLogging producer SDK extracted from `RedSalamander`:

- **Producer SDK (`include/RedMonitor/Client.h`)**: Single-header C++ client vendored by `RedSalamander`, `RedXe`, `RedPrism`, and `RedTilde` via hash-pinned `Dependencies/RedMonitor.lock.json` (`apiRevision: 1`). Zero background workers/timers in the producer header, zero allocation/formatting on the disabled path, and optional discovery of the separately installed Release `RedMonitor.exe` helper on bare Debug startup.
- **Standalone Viewer (`src/` & `support/`)**:
  - Receives the Red-family ETW TraceLogging stream, renders bounded colored logs with Direct2D/DirectWrite/Direct3D 11 and an exact pinned `DxUi` (`API 4`) archive, and opens/exports streaming UTF-8/UTF-16LE text files off the UI thread.
  - `support/` holds a private statically linked MIT migration closure (never exposed to consumers and never linked against `RedSalamander`'s `Common.dll`).
  - Never stops a foreign ETW session; preserves wire GUID, field names/types, severity/filter mapping, and bounded oldest eviction with immutable UI snapshots.

## Repository-Specific Rules & Skills

- **Skills (`../../RedMonitor/.agents/skills/`)**: Repo-specific skills `build-redmonitor`, `transport-client`, `viewer-lifetime`, `file-safety`, `consumer-adoption`, `test-harness` (shared C++/WIL, `spec-workflow`, `test-evidence`, `crash-dumps`, `file-io-safety`, and `app-settings` skills live in `RedHome/.agents/skills/`).
- **Compiler Warnings**: Compiles with `/W4 /WX /permissive- /sdl` across all six `x64`/`ARM64` `Debug`/`Release`/`ASan Debug` profiles, as declared by [Directory.Build.props](../../RedMonitor/Directory.Build.props). This is the current exception to the five other repositories' `/Wall` policy.
- **Live ETW Gate**: `test.ps1 -IncludeLiveEtw` exercises the real ETW transport roundtrip and treats permission denial as a test failure rather than an empty pass.

## Key Commands

```powershell
Set-Location ..\RedMonitor
.\validate.ps1
.\Tests\Tooling.Tests.ps1
.\build.ps1 -Platform x64 -Configuration Debug
.\test.ps1 -Platform x64 -Configuration Debug
.\Test-Changes.ps1 -Explain
```

Return to [Index.md](Index.md).
