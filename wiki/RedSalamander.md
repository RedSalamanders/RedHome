# RedSalamander (`../RedSalamander`)

- **Repository**: `RedSalamanders/RedSalamander` (`versionBase: 7.0`, Winget: `RedSalamanders.RedSalamander`, command aliases `RedSalamander` and `red`)
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
- Both portable command aliases use the static-CRT launcher. It resolves the package executable and starts it with the package directory as its working directory. [WinGet contract](../../RedSalamander/Specs/Installer/WingetIntegration.md)
- The build and test maintainer owns adoption of the compatible DxUi API 6 pin and matching consumer qualification. [H5 receiving plan](https://github.com/RedSalamanders/RedSalamander/blob/main/Specs/Plans/WIP/DxUiApi6Adoption_2026-11-25.md)

## Repository-Specific Rules & Skills

- The [RedSalamander skill index](../../RedSalamander/AGENTS.md#skills-reference) owns the current package paths. The [skill catalog](Skill-Catalog.md#redsalamander) lists the product skills by task.
- **Tooling & Spec Governance**: Every file under `Tools/` must be classified in `Tools/tool-inventory.json` (`.\Tools\Get-ToolInventory.ps1 -Validate`). Spec reconciliation and immutable `Specs/Plans/Done/` protection (`Test-RSProtectedDoneHistory`) are checked by `.\Tools\Get-SpecInventory.ps1 -FailOnFindings`. Note: **never** read or touch `Specs/Plans/WIP/Notes_Scratch.md` unless explicitly instructed by name.
- **Fail-Closed Test Sandbox**: All test scratch/logs/evidence stay strictly inside the marked `RedSalamander.Perf` root on the fixed local drive the user selected (written `X:\RedSalamander.Perf` in that repository's `AGENTS.md`, where `X:` is a placeholder; never `.build`, never following links/junctions during cleanup, and purging any test-recycled items via `SelfTest::PurgeRecycledTestItems`).

## Key Commands

```powershell
Set-Location ..\RedSalamander
Import-Module .\Tools\Modules\Build\VcpkgInstallSafety.psm1
$vcpkg = Initialize-RSVcpkgToolContext -RepoRoot $PWD.Path
.\vcpkg-install.ps1 -Platform x64 -VcpkgExe $vcpkg.Executable -VcpkgRoot $vcpkg.RegistryRoot
.\format.ps1 -Check
.\build.ps1 -Configuration Debug
.\test.ps1 -Explain
.\test.ps1
.\test.ps1 -Mode PrePush -Explain
.\validate-skills.ps1
.\Verify-RedMonitorClient.ps1
.\Tools\Get-SpecInventory.ps1 -FailOnFindings
.\Tools\Get-ToolInventory.ps1 -Validate
.\Tools\Run-AllTests.ps1 -Suite Full -ValidationMode Fresh
```

`test.ps1 -Full` runs one unattended native profile. `-Mode PrePush` runs the host profiles and cross-builds the other architecture. `Test-Changes.ps1` retains the single-profile compatibility arguments. Use the [validation contract](../../RedSalamander/Specs/Testing/Testing_ValidationEvidence.md) for canonical evidence, explicit Resume and desktop admission. The [Core performance contract](https://github.com/RedSalamanders/RedSalamander/blob/main/Specs/Core/Core_PerformanceAndResources.md) routes measured scenarios and budgets to their owners.

Return to [Index.md](Index.md).
