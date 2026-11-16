---
name: wil-raii
description: Manage Windows handles, GDI/Direct2D scopes, and COM interfaces with WIL RAII across all RedSalamanders C++ repositories.
---

# WIL RAII Resource Management

All RedSalamanders C++ code owns Windows and COM resources exclusively through WIL (`vcpkg.json` or pinned SDK). Manual resource cleanup (`Release()`, `DestroyWindow()`, `DestroyIcon()`, `DeleteObject()`, `EndPaint()`, `CloseHandle()`) and `goto` cleanup paths are prohibited.

## Scoped Header Inclusion

Isolate vendor warnings locally according to the target repository's warning profile so first-party diagnostics remain visible (see the [shared policy summary](../../../wiki/Shared-Engineering-Policies.md)):

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
  - Receive outputs via `.put()`, pass borrowed pointers via `.get()`, and release via `.reset()`.
  - Never perform the two-step `raw->AddRef(); ptr.attach(raw);` hazard—assign directly (`ptr = raw;`).
- **Windows & GDI handles**:
  - `HWND` -> `wil::unique_hwnd`
  - `HICON` -> `wil::unique_hicon` (`LoadImageW` without `LR_SHARED` transfers ownership; `LoadIconW` returns a shared handle and must not be adopted)
  - `HBITMAP` -> `wil::unique_hbitmap`
  - `HDC` -> `wil::unique_hdc` or `wil::unique_hdc_paint` (`wil::BeginPaint(hwnd, &ps)`)
  - `HFONT` / `HBRUSH` / `HPEN` -> `wil::unique_any<HFONT, decltype(&::DeleteObject), ::DeleteObject>` and `auto old = wil::SelectObject(hdc, brush.get());`
- **Destroying owned `HWND`s (`wil::unique_hwnd`)**:
  - Destroy via `_hWnd.reset()`—never `DestroyWindow(_hWnd.get())` (double-destroy bug).
  - Use `_hWnd.release()` only for an explicit ownership transfer or inside `WM_NCDESTROY` when Windows is already destroying the handle.
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
- **Custom resource wrapper classes**: Delete copy operations and `= default` move operations over `wil::unique_*` members—never write a raw `HANDLE` member with a defaulted C++ move.
