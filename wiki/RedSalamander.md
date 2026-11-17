# RedSalamander (`../RedSalamander`)

- **Repository**: `RedSalamanders/RedSalamander` (`versionBase: 7.0`, Winget: `RedSalamanders.RedSalamander`, aliases `RedSalamander.exe` / `red.exe`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedSalamander/AGENTS.md), [Specs/README.md](../../RedSalamander/Specs/README.md), [README.md](../../RedSalamander/README.md), [Active WIP](../../RedSalamander/Specs/Plans/WIP/README.md)

## Overview & Architecture

Dual-pane DirectX/Direct2D/DirectWrite Windows file manager inspired by Open Salamander (~21 core native projects + ~90 localization satellite DLL projects):

- **`RedSalamander/`**: `FolderWindow` (dual-pane shell), `FolderView` (~10 `.cpp` units for DirectX list rendering, selection, drag-drop), Command Palette, Preferences dialog, modeless Find Files & Directories, and `SelfTest\` suites.
- **`Common/` & `Common/PlugInterfaces/`**: Shared helpers (`Core_SharedHelpers.md`), [JSON/JSON5 `SettingsStore`](../../RedSalamander/Specs/Core/Core_SettingsStore.md) under `%LOCALAPPDATA%\RedSalamander\Settings` (read/write through `yyjson`), `IconCache` (STA init on UI thread; MTA required on worker threads), token-registered cross-thread `PostMessagePayload` / `TakeMessagePayload`, and COM-style plugin interfaces (`RedSalamanderCreate`: `IFileSystem`, `IViewer`, `IHost`).
- **`Plugins/`**:
  - **VFS**: `FileSystem` (local/NTFS), `FileSystem7z`, `FileSystemCurl` (FTP/SFTP/SCP/IMAP), `FileSystemS3`, `FileSystemGoogleDrive`, `FileSystemMicrosoftDrive`, `FileSystemMtp` (MTA WPD workers, read-only default), `FileSystemDummy`.
  - **Terminal**: `Terminal` (embedded & floating sessions).
  - **Viewers**: `ViewerText`, `ViewerSqlite`, `ViewerSpace`, `ViewerImgRaw`, `ViewerVLC`, `ViewerPE`, `ViewerWeb` (WebView2).
- **Companion Executables**: `RedSalamanderSearchService` (SQLite + named-pipe indexing service), `RedConfigure`, `RedLauncher`.

## Repository-Specific Rules & Skills

- **Skills location**: Repo-specific skills live in `../../RedSalamander/.github/skills/` (`cpp-build`, `perf-validation`, `direct2d-rendering`, `icon-cache`, `win32-wndproc`, `plugin-callbacks`, `file-actions`, `build-preferences-pages`, `tooling-governance`, `theming`, `async-threading`) plus `../../RedSalamander/.agents/skills/red-salamander-crash-forensics/`. Shared skills (`modern-cpp-windows`, `wil-raii`, `yyjson`, `localization`, `improve`, `spec-workflow`) live in `RedHome/.agents/skills/`.
- **Tooling & Spec Governance**: Every file under `Tools/` must be classified in `Tools/tool-inventory.json` (`.\Tools\Get-ToolInventory.ps1 -Validate`). Spec reconciliation and immutable `Specs/Plans/Done/` protection (`Test-RSProtectedDoneHistory`) are checked by `.\Tools\Get-SpecInventory.ps1 -FailOnFindings`. Note: **never** read or touch `Specs/Plans/WIP/Notes_Scratch.md` unless explicitly instructed by name.
- **Fail-Closed Test Sandbox**: All test scratch/logs/evidence stay strictly inside the marked `RedSalamander.Perf` root on the fixed local drive the user selected (written `X:\RedSalamander.Perf` in that repository's `AGENTS.md`, where `X:` is a placeholder; never `.build`, never following links/junctions during cleanup, and purging any test-recycled items via `SelfTest::PurgeRecycledTestItems`).

## Key Commands

```powershell
Set-Location ..\RedSalamander
.\vcpkg-install.ps1
.\build.ps1 -Configuration Debug
.\Test-Changes.ps1 -Explain
.\Test-Changes.ps1
.\Tools\Get-SpecInventory.ps1 -FailOnFindings
.\Tools\Get-ToolInventory.ps1 -Validate
.\Tools\Run-AllTests.ps1 -Suite Full -ValidationMode Fresh
```

Return to [Index.md](Index.md).
