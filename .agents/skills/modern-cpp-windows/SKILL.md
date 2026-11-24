---
name: modern-cpp-windows
description: Apply RedSalamanders C++23, Unicode, repository warning profiles, header-hygiene, HRESULT, and failure-handling conventions across native Windows code. Use when writing or reviewing C++ in any RedSalamanders repository, fixing compiler warnings, ordering Win32 headers, or deciding how errors and exceptions cross a callback or ABI boundary.
---

# Modern C++ for Windows (`stdcpplatest`)

Applies across `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`. One rule set; the target repository's `AGENTS.md` and `Specs/` win on any conflict. Product-specific facts are in [references/repository-facts.md](references/repository-facts.md). Rule differences that are still open are in [Differences To Converge](#differences-to-converge).

## Compiler, Warnings & Formatting

- Compile as UTF-8 source (`/utf-8`) targeting wide-character Unicode Win32 APIs in `stdcpplatest` mode with `/permissive-` and `/sdl`. Keep `.rc` files UTF-8 with `#pragma code_page(65001)`.
- Warning profile: `/Wall` with `/WX` disabled and zero-warning acceptance. See the [shared policy summary](../../../wiki/Shared-Engineering-Policies.md) and the target's build manifests before changing flags.
- Fix actionable warnings in first-party code (`static_cast`, explicit signed/unsigned narrowing guards, deleted special members when subclassing non-copyable types (`C4625`/`C4626`/`C5026`/`C5027`), removing unused parameters/locals). Reserve narrow `#pragma warning(push)` suppressions for third-party/SDK headers with an inline reason. Details: [compiler-warnings](references/compiler-warnings.md).
- Naming: `PascalCase` types and public methods, `camelCase` locals/private helpers/public `struct`/DTO data members, `kConstantName` constants. One variable declaration per line.
  - Private and protected non-static class/struct data members MUST use strict `_camelCase` (`_[a-z][A-Za-z0-9]*`, leading `_` followed strictly by a lowercase ASCII letter `[a-z]`). Trailing `name_` and bare unprefixed private/protected fields are forbidden.
  - **Member-scope only**: strictly ban `_Uppercase`, `__double`, and leading `_` at file, namespace, or global scope (`bugprone-reserved-identifier` / ISO C++ `[lex.name]`).
  - **Mandatory `.clang-tidy` enforcement**: enforce via a repository-root `.clang-tidy` enabling `readability-identifier-naming` and `bugprone-reserved-identifier` ([cpp-style.md](references/cpp-style.md#naming-conventions)). `RedTilde` adopts first (`H-27`); sibling repositories migrate in focused per-repo PRs.
- Run `.\format.ps1 -Check` for changed C++ and apply the formatter when needed. Follow the owning repository's validation gates.

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
| `std::bad_alloc` | `RedSalamander`: fatal, `std::terminate()`. `RedMonitor`: fatal. `RedPrism`: `E_OUTOFMEMORY` in the `JobScheduler` worker runner and at explicit `noexcept` admission boundaries, only when the caller fails the operation. `DxUi` API 5 / `RedTilde`: host-owned minidump diagnostics and termination. | Follow the current product contract at each boundary. Reconcile host-owned fatal diagnostics with the published API 6 contract during consumer adoption (D20). |
| Unexpected-exception policy | DxUi and RedTilde use the API 5 host-owned fatal diagnostics. RedSalamander, RedXe, RedPrism and RedMonitor consume API 4 and follow their product contracts. | D20 assigns cross-revision adoption to each consumer's API 6 plan. Use the failure contract published for that revision and qualify the rebuilt consumer. |
| COM smart pointer | RedSalamander, RedMonitor and parts of DxUi's `ControlHost` use `wil::com_ptr<T>` in HRESULT paths. | Follow the [WIL ownership rule](../wil-raii/SKILL.md) and register H-03 when migrating these paths to `wil::com_ptr_nothrow<T>`. |
| Logging helpers | `RedSalamander` (`Common/Helpers.h`) and `RedMonitor` (`support/Helpers.h`): the `Debug::` family. `DxUi`: `DxUi::Debug` (`src/Support/Diagnostics.h`). `RedXe`, `RedPrism`, `RedTilde`: no `Debug::` helpers. | One logging family with the same names in every repository: `DxUi::Debug` (owner default, register H-05). It is private to `DxUi` today (`src/Support/Diagnostics.h`), so `RedSalamander` and `RedMonitor` adopt it once `DxUi` publishes it, with the API 6 adoption. |
| Formatter source and scope | All six products use `Install-CiFormatter` and their pinned manifest scope. All six style blobs match. | Verify whole-tree formatting, selected files and blame references under CV-6-05. |
| Private/protected member naming & `.clang-tidy` (`H-27`) | Drift across `2,881` tracked files: `RedSalamander` (`8,432` `_name`, `1` `name_`), `RedPrism` (`3,945` `_name`, `74` `name_`, `1` `m_name`), `DxUi` (`1,684` `_name`, `412` `name_`), `RedXe` (`1,490` `_name`, `0` `name_`), `RedMonitor` (`251` `_name`, `0` `name_`), `RedTilde` (`3` `_name`, `48` `name_` plus bare `camelCase` members). RedTilde now configures both checks in its root `.clang-tidy`. | Strict `_camelCase` (`_[a-z][A-Za-z0-9]*`, member-scope only; banning `name_`, bare private/protected fields, `_Uppercase`, `__`, and global `_name`; public `struct`/DTO fields remain `camelCase`), enforced by repository-root `.clang-tidy` (`readability-identifier-naming` + `bugprone-reserved-identifier`). `RedTilde` adopts first; sibling repositories migrate in focused per-repo PRs (`H-27`). |
