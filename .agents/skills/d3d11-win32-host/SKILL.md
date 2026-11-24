---
name: d3d11-win32-host
description: Implement or debug Win32 windows that present through Direct3D 11, with window rules for every host and device, flip-model swap chain, WARP, occlusion, and device-loss rules for Direct3D hosts. Use when changing window creation, the message loop, sizing, DPI, adapter selection, presentation, or device-loss recovery in RedXe, RedPrism, RedMonitor, or a DxUi ControlHost window such as RedTilde's.
---

# Direct3D 11 & Win32 Host Architecture

One rule set in three layers. The [window rules](#window-rules-every-host) apply to every host window. The [Direct3D 11 rules](#direct3d-11-rules-every-direct3d-host) apply to every host that owns a Direct3D 11 device and swap chain. The presentation rules depend on where the host builds its frames: [from the idle side of the message loop](#presenting-from-the-idle-side-of-the-loop) or [inside `WM_PAINT`](#presenting-from-wm_paint). Product-specific facts are in [references/repository-facts.md](references/repository-facts.md); rule differences still to remove are listed under [Differences To Converge](#differences-to-converge). The repository's `AGENTS.md` and `Specs/` win on any conflict.

| Host | Window rules | Direct3D 11 rules | Builds frames |
| --- | --- | --- | --- |
| `RedXe`, `RedPrism` (`Application.*` owns the window, `Renderer.*` the graphics) | Yes | Yes | On the idle side of the loop |
| `RedMonitor` log view `ColorTextView` (`src/ColorTextView.*`) | Yes | Yes | In `WM_PAINT` |
| `DxUi` `ControlHost` (also named `WindowHost`): `RedTilde`'s main window, `RedMonitor`'s toolbar and status bar | Yes; the application owns the window and forwards its messages | Yes, implemented once inside `DxUi`; change them there, not in the application | In `WM_PAINT` |
| `RedSalamander` GDI and Direct2D windows | The same subjects in its `win32-wndproc` skill (fold planned with CV-2-12) | None: no Direct3D swap chain of their own | In `WM_PAINT` |

For `RedSalamander` GDI/D2D windows and `PostMessagePayload` queues, use its `win32-wndproc` and `direct2d-rendering` skills. Rendering in `WM_PAINT` is correct for every host in the last three rows; it stays different by design from the idle-loop hosts.

## Before Editing

- Read the owning spec before changing startup, window mode, display selection, sizing, DPI, swap-chain dimensions, resize, fullscreen or the hidden WARP contract: `Specs/UI/UI_Windowing.md` in `RedPrism`, `Specs/UI/UI_XeneonDisplayWindowing.md` in `RedXe`, and the files [repository facts](references/repository-facts.md) name for `RedMonitor`, `RedTilde`, and `DxUi`. Update the spec in the same change when observable behavior changes.
- Read `Specs/Core/Core_PerformanceAndResources.md` for every rendering change ([performance-resources](../performance-resources/SKILL.md); register B-06 names the repositories that keep their performance contract elsewhere). Cache size/DPI-derived state, avoid steady-state allocations, batch uploads and compatible draws, and never spin while rendering is suspended or occluded.
- Keep graphics ownership in one renderer type and window ownership in one application type. In the idle-loop hosts that is `Renderer.*` and `Application.*` (`RedPrism/Renderer.*`, `RedPrism/Application.*`, `RedXe/Renderer.*`, `RedXe/Application.*`); the other hosts are listed in the table above.
- When the work closes a WIP plan, merge lasting requirements into the owning domain spec before moving the plan to `Specs/Plans/Done/` ([spec-workflow](../spec-workflow/SKILL.md)).

## Window Rules (every host)

- Bind the owning object (`Application*`, `ColorTextView*`, the `WindowHost*` a thunk forwards to) from `CREATESTRUCTW::lpCreateParams` in `WM_NCCREATE` (`GWLP_USERDATA`) and clear it in `WM_NCDESTROY`.
- Own the top-level window with `wil::unique_hwnd`: destroy via `.reset()`, `.release()` in `WM_NCDESTROY` when the HWND is already being destroyed, and unregister the class after the window is gone. Apply the [wil-raii](../wil-raii/SKILL.md) skill for other handles.
- Keep `WindowProcedure` small and route to narrow handlers when logic exceeds a few lines. No C++ exception may cross the callback boundary; use `HRESULT` or explicit state for fallible work.
- Handle `WM_DPICHANGED` with the suggested destination rectangle. For a titled window, recompute the outer frame for the target DPI and the logical client canvas; leave fullscreen popup bounds monitor-controlled, as the owning UI spec says.
- A child created under the cursor may not receive `WM_SETCURSOR` until the mouse moves. When the parent owns a hover-created child HWND, apply the intended cursor from the parent's `WM_SETCURSOR` as well.
- Keep the window creation that the repository's harness depends on working: hidden creation for `--self-test`, captures and `.\test.ps1`, and `RedMonitor`'s non-activating `--chrome-selftest` window (each repository's switches are in the repository facts).

## Direct3D 11 Rules (every Direct3D host)

- Own all COM interfaces with `wil::com_ptr_nothrow<T>`: receive through `.put()`, access through `.get()`, never call `Release()` manually. Check every resource-creation `HRESULT` before using the result.
- Suppress background erase (`WM_ERASEBKGND` returns nonzero, or the class has no background brush): the renderer fills every client pixel.
- A zero client width or height (minimized) suspends rendering cleanly without logging an error.
- Keep device-lifetime resources distinct from size-dependent render targets. A resize replaces the render target; device loss rebuilds device, swap chain, pipeline, buffers and target as one coherent operation.
- A host with its own device targets the adapter whose output owns the window's monitor and rebuilds when it crosses adapters. Follow `AdapterSelection.h` in RedPrism and RedXe. Forced WARP uses the software path. DxUi's `ControlHost` shares one device per owner thread on the default adapter with WARP fallback, as its rendering contract specifies. Reuse that device for hosted controls. RedMonitor's independently owned `ColorTextView` still needs monitor-matched selection (H-17).
- Pass `D3D11_CREATE_DEVICE_BGRA_SUPPORT` when `DxUi` or Direct2D shares the device. A host that draws with Direct3D itself queries `ID3D11DeviceContext1` at creation.
- Create a 2-buffer flip-model swap chain and keep `DXGI_MWA_NO_ALT_ENTER` unless the project adds an explicit fullscreen policy. The first present after creating or resizing the buffers draws and presents the whole target.
- Compile fixed HLSL shaders at build time and embed the bytecode; never depend on runtime `d3dcompiler` for fixed shaders. Keep shader input layouts, C++ vertex data and HLSL semantics synchronized in the same change.
- Message dispatch must never make a hidden or minimized window render one extra frame.
- **Device loss**: on `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`, `DXGI_ERROR_DEVICE_HUNG` or `DXGI_ERROR_DRIVER_INTERNAL_ERROR`, and on `D2DERR_RECREATE_TARGET` where Direct2D draws to the swap chain, tear down and recreate device, swap chain and targets coherently, flushing the immediate context after releasing the swap chain so `CreateSwapChainForHwnd` never fails with `E_ACCESSDENIED`.

## Presenting From The Idle Side Of The Loop

`RedXe` and `RedPrism`: continuous or on-demand frames are built after the message queue drains, never in `WM_PAINT`.

- Create the window with `WS_EX_NOREDIRECTIONBITMAP`. Nothing paints the client with GDI.
- Do **not** use `CS_HREDRAW | CS_VREDRAW`. Suppress background erase and validate `WM_PAINT` without rendering; continuous or on-demand presentation belongs on the idle side of the message loop.
- Forward `WM_SIZE` to `Renderer::Resize`.
- Use `DXGI_SWAP_EFFECT_FLIP_DISCARD`: every frame redraws the whole target.
- Create the swap chain with `DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT` (maximum frame latency `1`, same flag passed to `ResizeBuffers`). Wait on the waitable handle together with the message queue before building a frame so `Present` never blocks.
- Subscribe to `GUID_SESSION_DISPLAY_STATUS` and block rendering while the session display is powered off. Message dispatch must never make a suspended or display-off window render one extra frame.
- **Occlusion**: `DXGI_STATUS_OCCLUDED` is not a usable signal for a flip-model swap chain. On Windows 11 25H2, `Present` and `Present(0, DXGI_PRESENT_TEST)` return `S_OK` while the window is shown, minimized, cloaked, hidden, or covered (`DxUi` `Measurements/FlipModelOcclusion_2026-11-19/`), and `RedXe` has seen the status when its own native child window covered the swap chain. Take occlusion from signals the application owns: minimize and restore (`WM_SIZE`), visibility, cloaking (`DWMWA_CLOAKED`) and display power. Block on those events; never poll or use a periodic timer, and never log handled occlusion as an error.

## Presenting From `WM_PAINT`

`RedMonitor`'s `ColorTextView` and `DxUi`'s `ControlHost`: a frame is built only when the window is invalidated.

- Validate with `wil::BeginPaint` and render that frame in the same `WM_PAINT`. Request a frame with `InvalidateRect(hwnd, rect, FALSE)`; never draw outside `WM_PAINT`.
- Use `DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL`, so a partial frame can present with `Present1` and dirty rectangles (and a scroll rectangle in `RedMonitor`).
- After device loss, discard the device resources, request a full redraw and invalidate the window; the next `WM_PAINT` rebuilds them.
- Known occlusion comes from the application (`ControlHost::SetNativePresentationVisible(false)` in `DxUi`). Never infer it by polling other windows or installing hooks.

## Verification

- Keep `--warp` green across renderer edits and run `.\test.ps1` after renderer changes.
- After lifetime, DPI or message-loop changes, use affected coverage for iteration and the domain's required profiles for qualification. With the person's agreement to the time, launch `.\build.ps1 -Run` manually when interactive behavior changed. DPI changes also need an agreed live cross-monitor move test with a Per-Monitor-V2 probe, so diagnostic virtualization cannot hide a sizing defect.
- A change to `DxUi`'s `ControlHost` is qualified in `DxUi` and then in each consumer that locks the new commit; `DxUi` tests do not replace the consumer's own run.

## Repository Facts

Frame order, chrome and canvas rules of each product, the XENEON EDGE dock and fullscreen specifics, `RedMonitor`'s log view, and how `RedTilde` and `RedMonitor` attach `DxUi`'s `ControlHost`: [references/repository-facts.md](references/repository-facts.md). Repository-local skills for the other hosts are linked there (`DxUi` `win32-host` and `embedded-rendering`, `RedSalamander` `win32-wndproc` and `direct2d-rendering`, `RedPrism` `hlsl-composition`).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Owning UI spec file name | `RedPrism`: `Specs/UI/UI_Windowing.md`. `RedXe`: `Specs/UI/UI_XeneonDisplayWindowing.md`. | Name the host windowing spec `Specs/UI/UI_Windowing.md` in both; `RedXe` renames its spec and keeps the XENEON EDGE sections inside it. |
| `--self-test` and WARP | `RedPrism`: `--self-test` forces WARP and refuses a non-WARP device. `RedXe`: only `--warp` sets `forceWarp`; `--self-test` does not. | `--self-test` forces WARP in both; `RedXe` changes. |
| Post-change verification steps | `RedXe` states affected coverage, `.\build.ps1 -Run` and the live cross-monitor DPI probe; `RedPrism` states none. | Verification section above applies to both; `RedPrism` confirms its `build.ps1 -Run` and DPI probe cover it. |
| Adapter selection (register H-17) | `RedXe`, `RedPrism`: the adapter that owns the window's monitor, rebuilt on a move to another adapter. `RedMonitor` `ColorTextView` and `DxUi` `ControlHost`: `DxUi::CreateD3D11DeviceWithWarpFallback` on the default adapter, then WARP; `ControlHost` shares one device per owner thread. | The monitor-matched adapter in every Direct3D host that owns its device, the stricter option; `RedMonitor` changes. `DxUi`'s `Rendering_Win32Host.md` records why `ControlHost`'s per-thread shared device stays on the default adapter (`DxUi` #274), so that part is different by design. |
| Alt+Enter (register H-18) | `RedXe`, `RedPrism`, `RedMonitor`: `MakeWindowAssociation(hwnd, DXGI_MWA_NO_ALT_ENTER)`. `DxUi` `ControlHost` makes no window association, and neither does `RedTilde`, so `RedTilde`'s window and `RedMonitor`'s toolbar and status bar keep DXGI's default association. | `DXGI_MWA_NO_ALT_ENTER` on every swap-chain window; `DxUi`'s `ControlHost` sets it. |
| Device-loss results (register H-19) | `RedXe`, `RedPrism` renderers: `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`, `DXGI_ERROR_DRIVER_INTERNAL_ERROR`. `DxUi` (`IsDeviceLossHResult`): `D2DERR_RECREATE_TARGET`, `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`, `DXGI_ERROR_DEVICE_HUNG`. `RedMonitor` `ColorTextView`: `D2DERR_RECREATE_TARGET`, `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`. | One set everywhere, the union: `DXGI_ERROR_DEVICE_REMOVED`, `DXGI_ERROR_DEVICE_RESET`, `DXGI_ERROR_DEVICE_HUNG`, `DXGI_ERROR_DRIVER_INTERNAL_ERROR`, and `D2DERR_RECREATE_TARGET` where Direct2D draws to the swap chain. |
| Occlusion of flip-model swap chains (register H-20) | RedXe and RedPrism consume DXGI occlusion messages and status. DxUi documents measurements on Windows 11 25H2. RedXe has also observed the status under its own child window. | Use application-owned visibility, minimize, cloak and display-power signals to suspend rendering. DxUi #275 and #278 document the limits of the DXGI status. RedXe and RedPrism still need the change. |
| Top-level window ownership (register H-21) | `RedXe`, `RedPrism`, `RedTilde`: an `Application` bound in `WM_NCCREATE` and a `wil::unique_hwnd` member. `RedMonitor`: the main window is created with no `lpCreateParams`, its `wil::unique_hwnd` is released into the global `HWND g_hMainWindow`, and its window procedure reads globals. | The window rules above; `RedMonitor` changes. |
| COM pointer type (register H-03) | `RedMonitor` `ColorTextView` holds its Direct3D, DXGI and Direct2D interfaces in `wil::com_ptr<T>`, and `RedMonitor` has no `wil::com_ptr_nothrow<T>`. `DxUi`'s `ControlHost` (`src/Controls/DxUi.WindowHost.cpp` at the commit `RedTilde` locks) holds its shared device, factories and swap-chain surfaces in `wil::com_ptr<T>` inside `noexcept` functions: 18 uses, against 1 `wil::com_ptr_nothrow<T>`. | As [wil-raii](../wil-raii/SKILL.md) states: `wil::com_ptr_nothrow<T>` in `noexcept` / `HRESULT` code. |
