# RedXe (`../RedXe`)

- **Repository**: `RedSalamanders/RedXe` (`versionBase: 1.0`, Winget: `RedSalamanders.RedXe`, alias `RedXe`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedXe/AGENTS.md), [Specs/README.md](../../RedXe/Specs/README.md), [README.md](../../RedXe/README.md), [Active WIP](../../RedXe/Specs/Plans/WIP/README.md)

## Overview & Architecture

Per-monitor-v2 DPI Win32 + Direct3D 11 dashboard foundation for **XENEON EDGE** (screen-edge app-bar dock, multi-page placement grid, DirectWrite `FluentIcons.h` host chrome with zero GDI/chrome HWNDs):

- **Host Core (`RedXe/`)**: `Application` (HWND & idle-loop rendering), `Renderer` (D3D11 device, flip swap chain, WARP fallback, device-loss recovery), `DashboardHost` (widget grid & frame scheduling), `PluginHost` (process-scoped modules, data providers, acquisition/network/launch/device-lane workers, JSONL logger), `PluginManager` (per-page COM instances; failed widgets degrade to placeholder tiles), `SettingsStore` + `SettingsWatcher` (`yyjson`), `TrayIcon`, `CrashHandler`.
- **COM Plugin ABI (`Common/PlugInterfaces/`)**: `sizeof`/`offsetof`-pinned interfaces (`Factory.h`, `Host.h`, `Widget.h`, `Data.h`, `Service.h`, `Action.h`). GPU widgets allocate/rasterize only in `OnDeviceCreated`, `OnTargetSizeChanged`, or `IRedXePreparedGpuWidget::Prepare`; `Render` is strictly allocation-free.
- **Bundled Plugins (`Plugins/`)**:
  - `MatrixRain` (default low-resource D3D11 rain), `RotatingTriangle`, `GdiOrbit` (opt-in child-HWND GDI example), `5H4D3R5` (14 build-time HLSL shaders/atmosphere), `ProcessViewer`, `Launcher`, `Weather`.
  - `AVControl`: `DxUi` retained controls + isolated audio/camera helper + virtual camera.
  - `Logicon`: Headless MX Creative Console keypad/dialpad HID++ & Raw Input service + Debug monitor tile.
  - `Actions/Zoom`: Browser-only `zoom.action.dll` (`zoom.open`, `zoom.join`).

## Repository-Specific Rules & Skills

- **Skills (`../../RedXe/.agents/skills/`)**: Repo-specific skill `plugin-development` (shared skills `spec-workflow`, `d3d11-win32-host`, `performance-resources`, `modern-cpp-windows`, `wil-raii`, `yyjson`, `test-evidence`, `crash-dumps`, `file-io-safety`, `app-settings`, `native-build` live in `RedHome/.agents/skills/`).
- **Aligned Catalogs**:
  - Adding/changing CLI switches requires updating `RedXe/CommandLine.h`, `docs/usage.md`, and `Specs/UI/UI_XeneonDisplayWindowing.md` together (`SettingsTests` enforces parity).
  - Adding/removing bundled widgets/services requires updating `RedXe/BundledPlugins.h`, `Specs/Settings.schema.json`, Debug & Release `Settings/*.json` templates, plugin contract, and `docs/plugins/<widget>.md`.
- **Deterministic Captures**: Use `RedXe.exe --screenshot <png> --page <id> --widget <ordinal>` on Debug builds.

## Key Commands

The pinned engine runs scoped testing. RedXe's manifest maps suites and profiles, and native reports retain each
suite's exit and capability skips. See the [build and validation contract](../../RedXe/Specs/Build/Build_Process.md#scoped-iteration-and-qualification).

```powershell
Set-Location ..\RedXe
.\build.ps1
.\Test-Changes.ps1 -Explain
.\test.ps1
.\test.ps1 -Full
.\validate-skills.ps1
.\package.ps1 -Platform x64
```

Return to [Index.md](Index.md).
