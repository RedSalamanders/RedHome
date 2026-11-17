# Ecosystem Architecture Comparison

All RedSalamanders products target modern Windows (Windows 11 22000.2600+; `RedXe` also supports Windows 10) using Visual Studio 2026 (`v145`, MSVC `14.52.x`), Windows SDK `10.0.26100`, `stdcpplatest`, Unicode UTF-16 Win32 APIs, and WIL RAII.

## Product Matrix

| Dimension | [RedSalamander](RedSalamander.md) | [RedXe](RedXe.md) | [RedPrism](RedPrism.md) | [RedTilde](RedTilde.md) | [DxUi](DxUi.md) |
| --- | --- | --- | --- | --- | --- |
| **Sibling path (from `RedHome`)** | `../RedSalamander` | `../RedXe` | `../RedPrism` | `../RedTilde` | `../DxUi` |
| **Version base** | `7.0` | `1.0` | `0.1` | `0.1` | `0.1` (Static SDK) |
| **Primary domain** | Dual-pane file manager & VFS/viewers | XENEON EDGE widget dashboard & services | GPU/CPU raster layer editor (`.prism`) | Native Markdown editor (Compose/Source/Split) | Retained DirectX control & RichText library |
| **Graphics stack** | D3D11 + D2D + DirectWrite + DXGI | D3D11 flip swap chain + DirectWrite glyph atlas | D3D11 + build-time HLSL + compute (`BrushCoverage.hlsl`) + D2D/DWrite | DxUi `WindowHost`/controls + Direct2D + DirectWrite | Borrowed-device `EmbeddedHost` + standalone `WindowHost` |
| **DxUi integration** | Pinned `DxUi.lib` (API 4 -> API 5 pending) | Pinned `DxUi.lib` (API 4, used in `AVControl`) | Pinned `DxUi.lib` (API 4, full `ChromeHost` shell) | Pinned `DxUi.lib` (API 5, `RichTextEditor` + shell) | Canonical producer (`src/DxUi.vcxproj`) |
| **Plugin ABI** | COM-style `RedSalamanderCreate` (`IFileSystem`, `IViewer`, `IHost`) | Strict COM (`sizeof`/`offsetof`-pinned `Widget.h`, `Service.h`, `Action.h`) | None (monolithic `RedPrism.exe`; future ABI COM/POD only) | None (monolithic `RedTilde.exe`) | Static `.lib` only; never pass `DxUi` C++ across DLL ABIs |
| **Settings store** | [JSON/JSON5 through `yyjson`](../../RedSalamander/Specs/Core/Core_SettingsStore.md) under `%LOCALAPPDATA%\RedSalamander\Settings` + `SettingsStore.schema.json` | `%LOCALAPPDATA%\RedXe` JSON (`yyjson`) + event-blocked watcher | `%LOCALAPPDATA%\RedPrism` JSON (`yyjson`, atomic save + live reload) | `%LOCALAPPDATA%\RedTilde` JSON + live theme/syntax apply | Consumer-owned (`ThemeColors.h` supplied by host) |
| **Skill folder** | `.github/skills/` (+ `.agents/skills/` meta-skills) | `.agents/skills/` | `.agents/skills/` | `.agents/skills/` | `.agents/skills/` |

## Critical Cross-Boundary Rules

1. **`DxUi` Never Crosses a Plugin DLL Boundary**: Consumers link one static `DxUi.lib`. Neither `DxUi` C++ types, STL containers, WIL wrappers, nor C++ exceptions may cross `RedSalamander` or `RedXe` plugin ABIs.
2. **`EmbeddedHost` vs `WindowHost`**:
   - `EmbeddedHost` (`RedPrism` `ChromeHost`, `RedXe` `AVControl`) borrows the application's `ID3D11Device` and owns **no** swap chain, HWND, worker thread, or timer. `Prepare(w, h, dpi)` rasterizes changed content; `Composite(ctx, viewport)` draws with premultiplied alpha. Note: `EmbeddedHost::Prepare` clobbers PS SRV slot 0 and OM render targets—rebind downstream pipeline state afterward.
   - `WindowHost` / `ControlHost` (`RedTilde`, standalone `DxUi` hosts) manages Win32 presentation, TSF/IME text services, and UI Automation providers directly.
3. **Zero Polling & Bounded Queues**: Across every product, idle, hidden, minimized, and occluded windows block on OS events (`WaitPool`, directory change handles, fence events) and consume zero steady-state passes.

Return to [Index.md](Index.md).
