# RedPrism (`../RedPrism`)

- **Repository**: `RedSalamanders/RedPrism` (`versionBase: 0.1`, Winget: `RedSalamanders.RedPrism`, alias `redprism`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedPrism/AGENTS.md), [Specs/README.md](../../RedPrism/Specs/README.md), [README.md](../../RedPrism/README.md), [Active WIP](../../RedPrism/Specs/Plans/WIP/README.md)

## Overview & Architecture

Windows-native GPU/CPU raster image editor built with Win32, Direct3D 11, DXGI, DirectWrite, build-time HLSL, `libzip` (`.prism` format-7 project archives), `Clipper2` (selection booleans), `yyjson`, WIC, and `DxUi`:

- **`Application` & `Renderer`**: Single HWND, single D3D11 device + flip-model swap chain, idle-loop `Present` (chrome layout -> canvas -> chrome). Settled documents execute **zero** composition passes per frame.
- **`CanvasRenderer` & `GpuBrushCoverage`**: Document-space HLSL layer passes, coverage textures, clipping stacks, sparse-raster residency, and `BrushCoverage.hlsl` compute kernel.
- **GPU & CPU Execution**:
  - `JobScheduler` (`Common/Jobs.*`): Bounded class/priority job scheduler (`std::bad_alloc` in worker runner translates to `E_OUTOFMEMORY`).
  - `GpuWorkQueue` & `GpuCommandStream` / `GpuCommandPump`: Bounded staging/copy slots, fence waits on shared `WaitPool`, and two-slot private deferred-context recording.
  - `Kernels` (`Common/Kernels_<Tier>_<Module>.*`): Immutable CPU SIMD dispatch tables + private `WorkerPool`.
- **`ChromeHost` (`DxUi::EmbeddedHost`)**: Tool rail with hash-pinned Lucide SVGs (`Dependencies/Lucide.lock.json`), Move/Selection/Brush/Gradient/Shape toolbars, custom-drawn adjustment cards (`AdjustControls.*` for curves, levels, spectrum, ramps), layer tree (`Splitter`, `NumericStepper`), floating `ColorPicker`, and canvas overlays.
- **`Document` (`Common/`)**: Sparse rasters (caches keyed by `Raster::Identity()` MUST hold the `Raster` alive so freed addresses cannot alias), history, transform/warp, Clipper2 selections/wand, brush/heal/clone/blur strokes, adjustments/filters, `.prism` I/O.

## Repository-Specific Rules & Skills

- **Skills (`../../RedPrism/.agents/skills/`)**: Repo-specific skills `build-redprism`, `test-harness`, `hlsl-composition`, `numeric-goldens`, `settings-store`, `crash-handling`, `consumer-dxui` (shared skills `spec-workflow`, `d3d11-win32-host`, `performance-resources`, `wil-raii`, `yyjson`, `modern-cpp-windows`, `localization`, `test-evidence`, `crash-dumps`, `file-io-safety`, `app-settings`, `native-build` live in `RedHome/.agents/skills/`).
- **Independent Numeric Goldens**: Every document, I/O, rendering, tool, and history behavior requires an independent mathematical/reference golden with documented tolerance—never screenshot diffs or rebaselining to match an implementation bug.
- **DxUi Press/Invalidation Discipline**: `ChromeHost` writes control setters and layout bounds only on state change (`_resync`) and never mutates layout/focus mid-press or inside a `Splitter` preview callback.

## Key Commands

```powershell
Set-Location ..\RedPrism
.\validate-skills.ps1
.\format.ps1 -Check
.\build.ps1 -Platform x64 -Configuration Debug
.\Test-Changes.ps1 -Explain
.\test.ps1 -Platform x64 -Configuration Debug
```

Return to [Index.md](Index.md).
