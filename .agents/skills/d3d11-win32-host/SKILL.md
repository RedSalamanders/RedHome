---
name: d3d11-win32-host
description: Implement or debug Win32 top-level windows, DPI transitions, Direct3D 11 monitor-matched devices, flip-model swap chains, occlusion, WARP, and device loss.
---

# Direct3D 11 & Win32 Real-Time Host Architecture

Shared host foundation for `RedXe` and `RedPrism` (read the repo's `AGENTS.md` and `Specs/UI/UI_Windowing.md` or `Specs/UI/UI_XeneonDisplayWindowing.md` for product-specific frame order, chrome, or dock modes; for `RedSalamander` GDI/D2D windows and `PostMessagePayload` queues, use `RedSalamander`'s `win32-wndproc` and `direct2d-rendering` skills).

## Win32 Window & Message Loop (`Application.*`)

- Bind `Application*` from `CREATESTRUCTW::lpCreateParams` in `WM_NCCREATE` (`GWLP_USERDATA`) and clear it in `WM_NCDESTROY`. Own the top-level window with `wil::unique_hwnd` (destroy via `.reset()`, `.release()` in `WM_NCDESTROY` when already destroying).
- Keep `WindowProcedure` small, route to narrow handlers, and never allow C++ exceptions across the callback boundary.
- Do **not** use `CS_HREDRAW | CS_VREDRAW`, suppress background erase, and validate `WM_PAINT` without rendering—continuous/on-demand Direct3D presentation belongs on the idle side of the message loop.
- Forward `WM_SIZE` to `Renderer::Resize`; zero client width or height suspends rendering cleanly without logging an error.
- Handle `WM_DPICHANGED` using the suggested destination rectangle (recomputing outer titled frames for the logical canvas, or keeping fullscreen popups monitor-controlled per the owning UI spec).
- Subscribe to `GUID_SESSION_DISPLAY_STATUS` and block rendering while the display is powered off. Keep hidden-window startup working for `--self-test` / `--warp` harnesses.

## Direct3D 11 Device, Flip Swap Chain & Recovery (`Renderer.*`)

- Own all COM interfaces with `wil::com_ptr_nothrow<T>` (`wil-raii` skill) and keep device-lifetime resources distinct from size-dependent render targets.
- Select the DXGI adapter owning the window's monitor (`FindAdapterForMonitor`), falling back to default/WARP when off-monitor or when `--warp` is passed; rebuild device resources when moving across adapters.
- Pass `D3D11_CREATE_DEVICE_BGRA_SUPPORT` when `DxUi` or Direct2D shares the device, and query `ID3D11DeviceContext1` at creation.
- Create a 2-buffer flip-model swap chain with `DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT` (maximum frame latency `1`, preserved across `ResizeBuffers`) and `DXGI_MWA_NO_ALT_ENTER`; wait on the waitable handle alongside the message queue before building a frame so `Present` never blocks.
- Compile fixed HLSL shaders at build time—never depend on runtime `d3dcompiler` for static shaders.
- **Occlusion & Device Loss**:
  - On `DXGI_STATUS_OCCLUDED`, stop building frames, wait for a registered DXGI occlusion-status window message, and probe recovery with `Present(0, DXGI_PRESENT_TEST)` (never poll).
  - On `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`, or `DXGI_ERROR_DRIVER_INTERNAL_ERROR`, tear down and recreate device + swap chain + targets coherently (flushing the immediate context after releasing the swap chain so `CreateSwapChainForHwnd` never fails with `E_ACCESSDENIED`).
- Keep `--warp` green across renderer edits.

## Repository Detail

| Working in | Read |
| --- | --- |
| `RedPrism` | [Direct3D 11 rendering](references/redprism-direct3d11-rendering.md), [Win32 windowing](references/redprism-win32-windowing.md) |
| `RedXe` | [Direct3D 11 rendering](references/redxe-direct3d11-rendering.md), [Win32 windowing](references/redxe-win32-windowing.md) |
| `DxUi` | Repository-local [win32-host](../../../../DxUi/.agents/skills/win32-host/SKILL.md) and [embedded-rendering](../../../../DxUi/.agents/skills/embedded-rendering/SKILL.md) skills |
| `RedSalamander` | Repository-local [win32-wndproc](../../../../RedSalamander/.github/skills/win32-wndproc/SKILL.md) and [direct2d-rendering](../../../../RedSalamander/.github/skills/direct2d-rendering/SKILL.md) skills |
