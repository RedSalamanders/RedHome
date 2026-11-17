# WIL RAII detailed patterns

Rules live in [SKILL.md](../SKILL.md). Every Windows resource uses an RAII wrapper; `goto` is prohibited, so use `wil::scope_exit` for cleanup and common exit paths.

## WIL Wrapper Reference

| Resource | WIL Wrapper |
|----------|-------------|
| HICON | `wil::unique_hicon` |
| HWND | `wil::unique_hwnd` |
| HBITMAP | `wil::unique_hbitmap` |
| HFONT | `wil::unique_hfont` (WIL's typedef for `wil::unique_any<HFONT, decltype(&::DeleteObject), ::DeleteObject>`, which older code spells out) |
| HBRUSH | `wil::unique_hbrush` |
| HPEN | `wil::unique_hpen` |
| HMENU | `wil::unique_hmenu`, for a menu this code created or loaded |
| HDC | `wil::unique_hdc` |
| Paint | `wil::unique_hdc_paint` with `wil::BeginPaint(hwnd, &ps)` |
| COM | `wil::com_ptr_nothrow<T>` in `noexcept` / `HRESULT` code; `wil::com_ptr<T>` only where WIL exceptions are intentional |
| Cleanup | `wil::scope_exit` with lambda |

## Member Variables
```cpp
class MyWindow 
{
    wil::unique_hicon _icon;
    wil::unique_hwnd _tooltip;
    wil::unique_hfont _font;
};
```

## Paint Context (auto EndPaint)
```cpp
PAINTSTRUCT ps;
wil::unique_hdc_paint hdc = wil::BeginPaint(_hWnd, &ps);
FillRect(hdc.get(), &ps.rcPaint, brush);
// Automatic EndPaint on scope exit
```

## GDI Selection (auto restore)
```cpp
{
    auto oldBrush = wil::SelectObject(hdc, _brush.get());
    // Drawing...
} // Old brush automatically restored
```

## Multiple GDI Selections

```cpp
{
    auto oldPen = wil::SelectObject(hdc, _pen.get());
    {
        auto oldBrush = wil::SelectObject(hdc, _brush.get());
        // Draw with pen and brush
    } // Brush restored
    // Draw with pen only
} // Pen restored
```

## Direct2D BeginDraw/EndDraw
```cpp
{
    HRESULT hr = S_OK;
    {
        _d2dContext->BeginDraw();
        auto endDraw = wil::scope_exit([&] { hr = _d2dContext->EndDraw(); });
        // Drawing operations...
    }
    if (FAILED(hr)) { /* handle */ }
}
```

## COM Pointers

Use a WIL COM pointer for every COM interface lifetime and prefer single-step copy semantics. The examples below use `wil::com_ptr<T>`; see [SKILL.md](../SKILL.md) for which pointer type applies.

```cpp
// ✅ Copy (AddRef) in one step
wil::com_ptr<IFileSystem> fs = rawFs;
fs = rawFs;

// ✅ Receive an owning ref via out-param (avoids attach())
wil::com_ptr<IMuffin> muffin;
HRESULT hr = GetMuffin(muffin.put());
```

Avoid manual ref-counting + `attach()` on the same pointer:
```cpp
// ❌ Two-step hazard (can leak a ref if an exception occurs between lines)
rawFs->AddRef();
fs.attach(rawFs);
```

## Resource Creation and Access

```cpp
// LoadImageW without LR_SHARED transfers ownership; LoadIconW returns a shared handle.
_icon.reset(static_cast<HICON>(LoadImageW(instance, MAKEINTRESOURCEW(iconId), IMAGE_ICON, sizePx, sizePx, 0)));
_tooltip.reset(CreateWindowExW(...));

// Access raw handle for Win32 APIs
DrawIcon(hdc, x, y, _icon.get());
SendMessageW(_tooltip.get(), WM_SETFONT, 
    reinterpret_cast<WPARAM>(_font.get()), TRUE);

// Transfer ownership
wil::unique_hbitmap bitmap(CreateCompatibleBitmap(...));
_bitmaps.emplace_back(std::move(bitmap));

// Clear resources
_bitmaps.clear();  // All HBITMAPs automatically deleted
_icon.reset();     // Old icon destroyed, set to nullptr
```

## Destroying Owned Windows (`wil::unique_hwnd`)

If an `HWND` is owned by `wil::unique_hwnd`, destroy via the wrapper (do not call `DestroyWindow(_hWnd.get())`).

```cpp
// ✅ Preferred: destroy + clear ownership
_hWnd.reset();

// ✅ Transfer ownership explicitly (rare)
HWND hwnd = _hWnd.release();
DestroyWindow(hwnd);
```

## Menu Cleanup

Own a menu this code created with `wil::unique_hmenu`. Do not adopt a submenu from `GetSubMenu` or a menu already attached to a window; its parent destroys it.

```cpp
wil::unique_hmenu menu(CreatePopupMenu());
// Use menu.get()...
// Automatic DestroyMenu on scope exit
```

Older code reaches the same result with `wil::scope_exit`:

```cpp
HMENU menu = CreatePopupMenu();
auto menuCleanup = wil::scope_exit([&] { if (menu) DestroyMenu(menu); });
// Use menu...
// Automatic cleanup on scope exit
```

## Exception: Transfer-of-Ownership

Cross-thread icon passing is acceptable when properly documented and receiver takes RAII ownership:
```cpp
// Move unique_hicon across threads
wil::unique_hicon icon = ExtractOnBackgroundThread();
PostToUIThread([icon = std::move(icon)]() {
    // UI thread now owns the icon
});
```

## PROHIBITED

`goto` cleanup patterns are forbidden (prefer early returns + `wil::scope_exit`).

```cpp
// ❌ NEVER manual cleanup
DestroyIcon(_icon);
DeleteObject(font);
EndPaint(hWnd, &ps);

// ❌ NEVER destroy an owned HWND via .get()
DestroyWindow(_hWnd.get());

// ❌ NEVER raw handle with manual delete
HFONT font = CreateFontW(...);
// ... use font ...
DeleteObject(font);

// ❌ NEVER vector of raw handles
std::vector<HBITMAP> bitmaps;
for (auto bmp : bitmaps) {
    DeleteObject(bmp); // Manual cleanup loop
}
```
