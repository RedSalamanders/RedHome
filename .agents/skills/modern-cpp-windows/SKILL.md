---
name: modern-cpp-windows
description: Apply RedSalamanders C++23, Unicode, repository warning profiles, header-hygiene, HRESULT, and failure-handling conventions across native Windows code. Use when writing or reviewing C++ in any RedSalamanders repository, fixing compiler warnings, ordering Win32 headers, or deciding how errors and exceptions cross a callback or ABI boundary.
---

# Modern C++ for Windows (`stdcpplatest`)

Applies across `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`. One rule set; the target repository's `AGENTS.md` and `Specs/` win on any conflict. Product-specific facts are in [references/repository-facts.md](references/repository-facts.md). Rule differences that are still open are in [Differences To Converge](#differences-to-converge).

## Compiler, Warnings & Formatting

- Compile as UTF-8 source (`/utf-8`) targeting wide-character Unicode Win32 APIs in `stdcpplatest` mode with `/permissive-` and `/sdl`. Keep `.rc` files UTF-8 with `#pragma code_page(65001)`.
- Warning profile: `/Wall` with `/WX` disabled and zero-warning acceptance. See the [shared policy summary](../../../wiki/Shared-Engineering-Policies.md) and the target's build manifests before changing flags. `RedMonitor` still uses `/W4 /WX` (see Differences To Converge).
- Fix actionable warnings in first-party code (`static_cast`, explicit signed/unsigned narrowing guards, deleted special members when subclassing non-copyable types (`C4625`/`C4626`/`C5026`/`C5027`), removing unused parameters/locals). Reserve narrow `#pragma warning(push)` suppressions for third-party/SDK headers with an inline reason. Details: [compiler-warnings](references/compiler-warnings.md).
- Naming: `PascalCase` types and public methods, `camelCase` locals/private helpers, `_member` fields, `kConstantName` constants. One variable declaration per line.
- Run the formatter check for changed C++ (`.\format.ps1 -Check`) and apply the formatter when needed; preserve the owning validation gates. The entry point is not yet the same everywhere (see Differences To Converge).

## Ownership, STL & Strings

- Prefer value types and deterministic RAII. Use `std::unique_ptr`, `std::span`, `std::wstring_view`, and WIL wrappers for Windows resources (`wil-raii` skill). Never manually destroy an owned handle. Never use raw `new`/`delete`, `goto`, or C-style casts.
- Delete copying for unique resource owners. Make cleanup idempotent so partial initialization remains safe.
- Use explicit casts at signed/unsigned and pointer-sized Win32 boundaries.
- Access `std::optional` via `.value()` or `.value_or()`, never `*opt`.
- Format strings with `std::format` or bounded `std::format_to_n`. Ban `sprintf_s` / `swprintf_s` in ordinary code; preserve documented low-level exceptions (see [repository facts](references/repository-facts.md)).
- User-visible text comes from the STRINGTABLE (`localization` skill).
- Any cache keyed by a pointer/storage identity must retain ownership keeping that address alive so freed memory cannot alias a new allocation.
- Keep headers small, include what they use, and avoid global mutable state.

## Header Hygiene (`clang-format SortIncludes` Safety)

- Platform-neutral headers must use `<cstdint>` / `<cstddef>` (`uint32_t`, `size_t`) rather than `windows.h` typedefs (`UINT`, `DWORD`), so any test can include them first.
- When including Win32 headers, define `WIN32_LEAN_AND_MEAN` and `NOMINMAX`, and place `#include <windows.h>` in **its own blank-line-separated block** before headers requiring `ULONG`/`NTSTATUS` (`bcrypt.h`, `wincodec.h`). Likewise place `objbase.h` / `objidl.h` in their own block before `UIAutomation.h` or `XmlLite.h` so alphabetical `SortIncludes` never reorders prerequisites.

## Error Handling, Exceptions & ABI Boundaries

- Use `HRESULT` for Windows/DirectX/COM calls; capture `GetLastError()` immediately after a failing Win32 call. Use `wil::com_ptr_nothrow<T>` or `wil::com_ptr<T>` for COM (see Differences To Converge). Do not log normal control flow (`WM_SIZE` 0x0, cancellation, handled occlusion).
- Log a failure once, at the point of failure, with context. Do not log again in callers. Never log sensitive data.
- **Never** let C++ exceptions cross `wWinMain`, `WndProc`, threadpool callbacks, or COM/plugin DLL ABIs. Never pass `DxUi` C++ types, STL containers, or WIL wrappers across a plugin DLL ABI.
- **`catch (...)` is forbidden.** Where catching at an ABI/callback boundary is mandatory, catch only explicitly named exception types with a comment documenting the fallback, and never let a broader `catch (const std::exception&)` swallow `std::bad_alloc`.
- A `noexcept` annotation alone is not error handling.
- User-facing errors: fail gracefully, use resource strings, give actionable information.
- Examples and the `Debug::` logging table: [error-handling](references/error-handling.md).
- **The unexpected-exception policy is tied to the `DxUi` API revision a repository consumes** ([Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md)). `DxUi` API 5 and its API-5 consumers (`RedTilde` today) return checked status/`HRESULT` values for expected refusals and route unexpected C++ exceptions, including `std::bad_alloc` outside explicitly bounded job runners, to host-owned local minidump diagnostics and termination. API-4 consumers follow their own `AGENTS.md`; the per-repository behaviour is listed under Differences To Converge.

## Detailed Patterns

- [C++ style, naming, RAII, shared-helper reuse](references/cpp-style.md)
- [Error handling, `Debug::` logging, exceptions](references/error-handling.md)
- [Warning fixes and suppression policy](references/compiler-warnings.md)

## Repository Facts

Product-specific paths, helpers and test gates: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Warning profile | `RedMonitor`: `/W4 /WX`. `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`: `/Wall`, `/WX` disabled, zero warnings. | `/Wall`, `/WX` disabled, zero warnings. `RedMonitor` changes. |
| `std::bad_alloc` | `RedSalamander`: fatal, `std::terminate()`. `RedMonitor`: fatal. `RedPrism`: `E_OUTOFMEMORY` in the `JobScheduler` worker runner and at explicit `noexcept` admission boundaries, only when the caller fails the operation. `DxUi` API 5 / `RedTilde`: host-owned minidump diagnostics and termination. | Fatal with host-owned diagnostics (the `DxUi` API 5 policy). `RedPrism` limits `E_OUTOFMEMORY` translation to bounded job runners. |
| Unexpected-exception policy | API 5 (`DxUi`, `RedTilde`): host-owned fatal diagnostics. API 4 (`RedSalamander`, `RedXe`, `RedPrism`, `RedMonitor`): each repository's own `AGENTS.md` rules. | API 5 policy everywhere. API-4 consumers change when they move to API 5. |
| COM smart pointer | `RedSalamander`: `wil::com_ptr<T>`. `RedPrism`, `RedXe`: `wil::com_ptr_nothrow<T>` in HRESULT code. `DxUi`, `RedTilde`, `RedMonitor`: no stated rule. | `wil::com_ptr_nothrow<T>` in HRESULT code. `RedSalamander` changes. |
| Logging helpers | `RedSalamander` (`Common/Helpers.h`) and `RedMonitor` (`support/Helpers.h`): the `Debug::` family. `DxUi`: `DxUi::Debug` (`src/Support/Diagnostics.h`). `RedXe`, `RedPrism`, `RedTilde`: no `Debug::` helpers. | One logging family with the same names in every repository. Needs an owner decision on which one. |
| Formatter entry point | `RedPrism`, `RedTilde`, `RedMonitor`, `DxUi`: `format.ps1 -Check`. `RedXe`: `format.ps1` without `-Check`. `RedSalamander`: `format-all.ps1` (`-WhatIf` previews). | `format.ps1 -Check` everywhere. `RedXe` and `RedSalamander` change. |
