# RedPrism detail: `wil-raii`

> **Parity reference.** Body of `RedPrism/.agents/skills/wil-raii/SKILL.md` as of `8c27267f76c5`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedPrism`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Use the WIL package from `vcpkg.json`. Do not add a second WIL copy or return to WRL.

- Use `wil::com_ptr_nothrow<T>` in `noexcept`/`HRESULT` code, `.put()` for output parameters, `.get()` for borrowed
  access, and `.reset()` for release. Never call `Release()` manually.
- Use `wil::unique_hwnd` and matching wrappers for owned Windows resources.
- Destroy an owned HWND with `owner.reset()`, not `DestroyWindow(owner.get())`. Use `.release()` only to clear an
  already-destroyed HWND during `WM_NCDESTROY`.
- Use `wil::scope_exit` for temporary cleanup. Do not add `goto` cleanup paths.
- Keep every resource under one explicit owner immediately after successful creation.

Use scoped WIL include annotations to keep external diagnostics out of the zero-warning build gate; `/WX` remains disabled:

```cpp
#pragma warning(push)
#pragma warning(disable : 4625 4626 5026 5027 28182)
#include <wil/com.h>
#include <wil/resource.h>
#pragma warning(pop)
```
