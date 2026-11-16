---
name: modern-cpp-windows
description: Apply RedSalamanders C++23, Unicode, repository warning profiles, header-hygiene, HRESULT, and failure-handling conventions across native Windows code.
---

# Modern C++ for Windows (`stdcpplatest`)

Applies across `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`. Always check the target repository's `AGENTS.md` for repo-specific boundary exceptions.

## Compiler, Warnings & Formatting

- Compile as UTF-8 source (`/utf-8`) targeting wide-character Unicode Win32 APIs in `stdcpplatest` mode with `/permissive-` and `/sdl`. Follow the target repository's warning profile: `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `DxUi` use `/Wall` with `/WX` disabled and zero-warning acceptance; `RedMonitor` currently uses `/W4 /WX`. See the [shared policy summary](../../../wiki/Shared-Engineering-Policies.md) and the target's build manifests before changing flags.
- Fix actionable warnings in first-party code (`static_cast`, explicit signed/unsigned narrowing guards, deleted special members when subclassing non-copyable types (`C4625`/`C4626`/`C5026`/`C5027`), removing unused parameters/locals). Reserve narrow `#pragma warning(push)` suppressions for third-party/SDK headers with an inline reason.
- Naming: `PascalCase` types and public methods, `camelCase` locals/private helpers, `_member` fields, `kConstantName` constants. One variable declaration per line. Run `.\format.ps1 -Check` where provided.

## Ownership, STL & Strings

- Never use raw `new`/`delete` or C-style casts; use `std::unique_ptr`, value types, `std::span`, `std::wstring_view`, and WIL wrappers (`wil-raii` skill).
- Access `std::optional` via `.value()` or `.value_or()`, never `*opt`.
- Format strings with `std::format` or bounded `std::format_to_n`—ban `sprintf_s` / `swprintf_s` in ordinary code (preserving documented low-level crash-dump exceptions such as `RedPrism`'s `Common/CrashDumps.cpp`).
- Any cache keyed by a pointer/storage identity must retain ownership keeping that address alive so freed memory cannot alias a new allocation.

## Header Hygiene (`clang-format SortIncludes` Safety)

- Platform-neutral headers must use `<cstdint>` / `<cstddef>` (`uint32_t`, `size_t`) rather than `windows.h` typedefs (`UINT`, `DWORD`).
- When including Win32 headers, define `WIN32_LEAN_AND_MEAN` and `NOMINMAX`, and place `#include <windows.h>` in **its own blank-line-separated block** before headers requiring `ULONG`/`NTSTATUS` (`bcrypt.h`, `wincodec.h`). Likewise place `objbase.h` / `objidl.h` in their own block before `UIAutomation.h` or `XmlLite.h` so alphabetical `SortIncludes` never reorders prerequisites.

## Error Handling, Exceptions & ABI Boundaries

- Use `HRESULT` for Windows/DirectX/COM calls; capture `GetLastError()` immediately after a failing Win32 call. Do not log normal control flow (`WM_SIZE` 0x0, cancellation, handled occlusion).
- **Never** let C++ exceptions cross `wWinMain`, `WndProc`, threadpool callbacks, or COM/plugin DLL ABIs. Never pass `DxUi` C++ types, STL containers, or WIL wrappers across a plugin DLL ABI.
- **`catch (...)` is forbidden.** Where catching at an ABI/callback boundary is mandatory, catch only explicitly named exception types with a comment documenting the fallback. Under the API-5 failure policy, expected refusals return checked status/`HRESULT` values while unexpected C++ exceptions (including `std::bad_alloc`, outside explicitly bounded job runners) route to host-owned local minidump diagnostics and termination.
