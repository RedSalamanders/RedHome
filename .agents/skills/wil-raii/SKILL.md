---
name: wil-raii
description: Manage Windows handles, GDI/Direct2D scopes, and COM interfaces with WIL RAII across all RedSalamanders C++ repositories.
---

# WIL RAII Resource Management

All RedSalamanders C++ code owns Windows and COM resources exclusively through WIL (`vcpkg.json` or pinned SDK). Manual resource cleanup (`Release()`, `DestroyWindow()`, `DestroyIcon()`, `DeleteObject()`, `EndPaint()`, `CloseHandle()`) and `goto` cleanup paths are prohibited.

- Use the WIL package from `vcpkg.json`. Do not add a second WIL copy or return to WRL.
- Keep every resource under one explicit owner immediately after successful creation. Cleanup must remain safe after partial initialization.

## Scoped Header Inclusion

Isolate vendor warnings locally according to the target repository's warning profile so first-party diagnostics remain visible (see the [shared policy summary](../../../wiki/Shared-Engineering-Policies.md)). Owned code must pass zero-warning validation:

```cpp
#pragma warning(push)
#pragma warning(disable : 4625 4626 5026 5027 28182)
#include <wil/com.h>      // when wil::com_ptr / wil::com_ptr_nothrow is used
#include <wil/resource.h>
#pragma warning(pop)
```

## Core Wrapper & COM Rules

- **COM pointers**:
  - Use `wil::com_ptr_nothrow<T>` in `noexcept` / `HRESULT` code (`DxUi`, `RedXe`, `RedPrism`, `RedTilde`, ABI boundaries); use `wil::com_ptr<T>` only where WIL exceptions are intentionally used.
  - Receive outputs via `.put()`, pass borrowed pointers via `.get()`, and release via `.reset()`. Never call `Release()` manually.
  - Never perform the two-step `raw->AddRef(); ptr.attach(raw);` hazard—assign directly (`ptr = raw;`).
- **Windows & GDI handles**:
  - `HWND` -> `wil::unique_hwnd`
  - `HICON` -> `wil::unique_hicon` (`LoadImageW` without `LR_SHARED` transfers ownership; `LoadIconW` returns a shared handle and must not be adopted)
  - `HBITMAP` -> `wil::unique_hbitmap`
  - `HDC` -> `wil::unique_hdc` or `wil::unique_hdc_paint` (`wil::BeginPaint(hwnd, &ps)`)
  - `HFONT` / `HBRUSH` / `HPEN` -> `wil::unique_any<HFONT, decltype(&::DeleteObject), ::DeleteObject>` and `auto old = wil::SelectObject(hdc, brush.get());`
  - Use the matching WIL wrapper for any other owned Windows resource.
- **Destroying owned `HWND`s (`wil::unique_hwnd`)**:
  - Destroy via `_hWnd.reset()`—never `DestroyWindow(_hWnd.get())` (double-destroy bug).
  - Use `_hWnd.release()` only for a documented ownership transfer or inside `WM_NCDESTROY` when Windows is already destroying the handle.
- **Scoped cleanup without a dedicated wrapper (`HMENU`, D2D `EndDraw`)**:
  - Bind `wil::scope_exit` immediately after acquisition so partial initialization and early returns clean up unconditionally:
    ```cpp
    HRESULT hr = S_OK;
    {
        _d2dContext->BeginDraw();
        auto endDraw = wil::scope_exit([&] { hr = _d2dContext->EndDraw(); });
        // Draw...
    }
    ```
  - Prefer early returns plus `wil::scope_exit` over any `goto` cleanup.
- **Custom resource wrapper classes**: Delete copy operations and `= default` move operations over `wil::unique_*` members—never write a raw `HANDLE` member with a defaulted C++ move.
- **Cross-thread transfer**: Pass a handle across threads only when documented and the receiver takes RAII ownership (see patterns).

## Detailed Patterns

Member variables, paint context, GDI selection, Direct2D, COM pointers, `HWND` destruction, menu cleanup, multiple GDI selections, documented ownership transfer, and prohibited patterns with code: [references/patterns.md](references/patterns.md).

## Repository Facts

Product-specific facts only: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| COM pointer type | `RedSalamander`: `wil::com_ptr<T>` for members and locals. `DxUi`, `RedXe`, `RedPrism`, `RedTilde`: `wil::com_ptr_nothrow<T>` in `noexcept` / `HRESULT` code. | `wil::com_ptr_nothrow<T>` in `noexcept` / `HRESULT` code; `wil::com_ptr<T>` only where WIL exceptions are intentional. `RedSalamander` changes members and locals it holds in `noexcept` / `HRESULT` code. |
| WIL include and pragma list | The warning list `4625 4626 5026 5027 28182` is identical everywhere. `RedSalamander` shows only `<wil/resource.h>` in the guarded block; `RedXe`, `RedPrism` and the shared skill also guard `<wil/com.h>`. | One guarded block with the same warning list that also wraps `<wil/com.h>` whenever a COM pointer is used. `RedSalamander` changes. |
| Post-change verification | `RedXe` states: run `.\test.ps1` after ownership changes and build ARM64 for shared declarations. No other WIL source states a verification step. | Every repository runs its own test entrypoint after ownership changes and builds ARM64 when changing declarations shared across platforms (the `RedXe` wording). Every repository except `RedXe` would add this rule. |
