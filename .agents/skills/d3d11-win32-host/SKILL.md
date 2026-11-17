---
name: d3d11-win32-host
description: Implement or debug Win32 top-level windows, DPI transitions, Direct3D 11 monitor-matched devices, flip-model swap chains, occlusion, WARP, and device loss.
---

# Direct3D 11 & Win32 Real-Time Host Architecture

One rule set for every Win32 + Direct3D 11 host (`RedXe`, `RedPrism`). Product-specific facts are in [references/repository-facts.md](references/repository-facts.md); rule differences still to remove are listed under [Differences To Converge](#differences-to-converge). The repository's `AGENTS.md` and `Specs/` win on any conflict. For `RedSalamander` GDI/D2D windows and `PostMessagePayload` queues, use its `win32-wndproc` and `direct2d-rendering` skills.

## Before Editing

- Read the owning UI spec (`Specs/UI/UI_Windowing.md` or `Specs/UI/UI_XeneonDisplayWindowing.md`) before changing startup, window mode, display selection, sizing, DPI, swap-chain dimensions, resize, fullscreen or the hidden WARP contract. Update the spec in the same change when observable behavior changes.
- Read `Specs/Core/Core_PerformanceAndResources.md` for every rendering change ([performance-resources](../performance-resources/SKILL.md)). Cache size/DPI-derived state, avoid steady-state allocations, batch uploads and compatible draws, and never spin while rendering is suspended or occluded.
- Keep host graphics ownership inside `Renderer.*` and window ownership inside `Application.*` (`RedPrism/Renderer.*`, `RedPrism/Application.*`, `RedXe/Renderer.*`, `RedXe/Application.*`).
- When the work closes a WIP plan, merge lasting requirements into the owning domain spec before moving the plan to `Specs/Plans/Done/` ([spec-workflow](../spec-workflow/SKILL.md)).

## Win32 Window & Message Loop (`Application.*`)

- Bind `Application*` from `CREATESTRUCTW::lpCreateParams` in `WM_NCCREATE` (`GWLP_USERDATA`) and clear it in `WM_NCDESTROY`.
- Own the top-level window with `wil::unique_hwnd`: destroy via `.reset()`, `.release()` in `WM_NCDESTROY` when the HWND is already being destroyed, and unregister the class after the window is gone. Apply the [wil-raii](../wil-raii/SKILL.md) skill for other handles.
- Keep `WindowProcedure` small and route to narrow handlers when logic exceeds a few lines. No C++ exception may cross the callback boundary; use `HRESULT` or explicit state for fallible work.
- Create the window with `WS_EX_NOREDIRECTIONBITMAP`. Nothing paints the client with GDI.
- Do **not** use `CS_HREDRAW | CS_VREDRAW`. Suppress background erase and validate `WM_PAINT` without rendering; continuous or on-demand presentation belongs on the idle side of the message loop.
- Forward `WM_SIZE` to `Renderer::Resize`. A zero client width or height (minimized) suspends rendering cleanly without logging an error.
- Handle `WM_DPICHANGED` with the suggested destination rectangle. For a titled window, recompute the outer frame for the target DPI and the logical client canvas; leave fullscreen popup bounds monitor-controlled, as the owning UI spec says.
- A child created under the cursor may not receive `WM_SETCURSOR` until the mouse moves. When the parent owns a hover-created child HWND, apply the intended cursor from the parent's `WM_SETCURSOR` as well.
- Subscribe to `GUID_SESSION_DISPLAY_STATUS` and block rendering while the session display is powered off. Message dispatch must never make a hidden, minimized, suspended, or display-off window render one extra frame.
- Keep hidden-window creation working: `--self-test` and `.\test.ps1` depend on it.

## Direct3D 11 Device, Flip Swap Chain & Recovery (`Renderer.*`)

- Own all COM interfaces with `wil::com_ptr_nothrow<T>`: receive through `.put()`, access through `.get()`, never call `Release()` manually. Check every resource-creation `HRESULT` before using the result.
- Keep device-lifetime resources distinct from size-dependent render targets. A resize replaces the render target; device loss rebuilds device, swap chain, pipeline, buffers and target as one coherent operation.
- Create the device on the adapter whose output owns the window's monitor (`AdapterSelection.h` policy: `RedPrism/AdapterSelection.h`, `RedXe/AdapterSelection.h`; `Renderer::FindAdapterForMonitor`), never on the default adapter while a matching output exists. A window on no monitor, or `--warp`, uses the default/WARP path. Rebuild through `CreateDeviceResources` when the window moves to a monitor of another adapter (`Renderer::EnsureDeviceForWindowMonitor`); forced WARP never re-checks.
- Pass `D3D11_CREATE_DEVICE_BGRA_SUPPORT` when `DxUi` or Direct2D shares the device, and query `ID3D11DeviceContext1` at creation.
- Create a 2-buffer flip-model swap chain with `DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT` (maximum frame latency `1`, same flag passed to `ResizeBuffers`) and keep `DXGI_MWA_NO_ALT_ENTER` unless the project adds an explicit fullscreen policy. Wait on the waitable handle together with the message queue before building a frame so `Present` never blocks.
- Compile fixed HLSL shaders at build time and embed the bytecode; never depend on runtime `d3dcompiler` for fixed shaders. Keep shader input layouts, C++ vertex data and HLSL semantics synchronized in the same change.
- **Occlusion**: register a DXGI factory occlusion-status window message. On `DXGI_STATUS_OCCLUDED`, stop building frames, wait for that message, and probe recovery with `Present(0, DXGI_PRESENT_TEST)`. Never poll or use a periodic timer, and never log handled occlusion as an error.
- **Device loss**: on `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET` or `DXGI_ERROR_DRIVER_INTERNAL_ERROR`, tear down and recreate device, swap chain and targets coherently, flushing the immediate context after releasing the swap chain so `CreateSwapChainForHwnd` never fails with `E_ACCESSDENIED`.

## Verification

- Keep `--warp` green across renderer edits and run `.\test.ps1` after renderer changes.
- After lifetime, DPI or message-loop changes, use affected coverage for iteration and the domain's required profiles for qualification. With the person's agreement to the time, launch `.\build.ps1 -Run` manually when interactive behavior changed. DPI changes also need an agreed live cross-monitor move test with a Per-Monitor-V2 probe, so diagnostic virtualization cannot hide a sizing defect.

## Repository Facts

Frame order, chrome and canvas rules of each product, and the XENEON EDGE dock and fullscreen specifics: [references/repository-facts.md](references/repository-facts.md). Repository-local skills for the other hosts are linked there (`DxUi` `win32-host` and `embedded-rendering`, `RedSalamander` `win32-wndproc` and `direct2d-rendering`, `RedPrism` `hlsl-composition`).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Owning UI spec file name | `RedPrism`: `Specs/UI/UI_Windowing.md`. `RedXe`: `Specs/UI/UI_XeneonDisplayWindowing.md`. | Name the host windowing spec `Specs/UI/UI_Windowing.md` in both; `RedXe` renames its spec and keeps the XENEON EDGE sections inside it. |
| `--self-test` and WARP | `RedPrism`: `--self-test` forces WARP and refuses a non-WARP device. `RedXe`: only `--warp` sets `forceWarp`; `--self-test` does not. | `--self-test` forces WARP in both; `RedXe` changes. |
| Post-change verification steps | `RedXe` states affected coverage, `.\build.ps1 -Run` and the live cross-monitor DPI probe; `RedPrism` states none. | Verification section above applies to both; `RedPrism` confirms its `build.ps1 -Run` and DPI probe cover it. |
