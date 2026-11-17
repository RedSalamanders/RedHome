# RedXe detail: `wil-raii`

> **Parity reference.** Body of `RedXe/.agents/skills/wil-raii/SKILL.md` as of `87735d578659`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedXe`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Use the WIL package from `vcpkg.json`. Do not add a second WIL copy or return to WRL.

## Required patterns

- Use `wil::com_ptr_nothrow<T>` in `noexcept`/`HRESULT` code, `.put()` for output parameters, `.get()` for borrowed
  access, and `.reset()` for release. Use `wil::com_ptr<T>` only in code that intentionally uses WIL exceptions. Never
  call `Release()` manually.
- Use `wil::unique_hwnd`, `wil::unique_hicon`, `wil::unique_hbitmap`, `wil::unique_hdc`, and other matching wrappers for
  owned Windows resources.
- Destroy an owned HWND with `owner.reset()`, not `DestroyWindow(owner.get())`. Use `.release()` only for a documented
  ownership transfer or to clear an already-destroyed HWND during `WM_NCDESTROY`.
- Use `wil::scope_exit` for temporary cleanup that has no dedicated unique wrapper. Do not add `goto` cleanup paths.
- Keep every resource under one explicit owner immediately after successful creation. Cleanup must remain safe after
  partial initialization.

Wrap the WIL include locally to isolate reviewed vendor diagnostics; owned code must pass zero-warning validation:

```cpp
#pragma warning(push)
#pragma warning(disable : 4625 4626 5026 5027 28182)
#include <wil/com.h>      // when wil::com_ptr is needed
#include <wil/resource.h>
#pragma warning(pop)
```

Run `.\test.ps1` after ownership changes. Build ARM64 too when changing declarations shared across platforms.
