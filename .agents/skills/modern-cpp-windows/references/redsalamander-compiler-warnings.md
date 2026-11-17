# RedSalamander detail: `compiler-warnings`

> **Parity reference.** Body of `RedSalamander/.github/skills/compiler-warnings/SKILL.md` as of `53d0a9d58257`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedSalamander`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

**Objective: zero actionable warnings under `/Wall`**.

## Critical Rule

Production/runtime projects should fix warnings at the root cause or suppress locally with `#pragma warning(push/disable/pop)` and a rationale.

New project-wide suppressions require:
- rationale,
- owner,
- expiry/review task,
- narrowest possible scope.

Test projects may carry broader project-local suppressions only when they intentionally aggregate SDK/WIL/STL/product-source-heavy translation units, and the project file documents the exception.

## Acceptable Global Suppressions

- `/wd5045` - Spectre mitigation
- `/wd4820` - Padding
- `/wd4710` - Not inlined
- `/wd4711` - Auto inline
- `/wd4514` - Unreferenced inline

## Required Fixes (Project Code)

| Warning | Fix |
|---------|-----|
| C4365 | `static_cast<T>()` for signed/unsigned |
| C5219 | Explicit cast for data loss |
| C5264 | Remove unused or add `[[maybe_unused]]` |
| C4464 | Fix include paths, avoid `..` |
| C4774 | Do not use runtime printf-format strings; use `FormatStringResource(...)` (resources) or `std::format` |

## C4774: Format String Not String Literal

**Do not suppress C4774** to keep using `swprintf_s` with a runtime format string (especially from resources).

Preferred fixes:
- Localized/user-facing: change the `.rc` string to `std::format`-style positional placeholders (`{0}`, `{1:08X}`, ...), keep source placeholder order aligned with the `FormatStringResource(...)` argument order, and use `FormatStringResource(...)`.
- Diagnostics: use `std::format` / `std::format_to_n` instead of `*printf_s`.

## Pragma Patterns

### WIL/System Headers
```cpp
#pragma warning(push)
#pragma warning(disable: 4625 4626 5026 5027 4514 28182) // Deleted operators
#include <wil/resource.h>
#pragma warning(pop)
```

### Windows SDK
```cpp
#pragma warning(push)
#pragma warning(disable: 4820) // Padding
#include <windows.h>
#pragma warning(pop)
```

## Fix Patterns

```cpp
// Signed/unsigned conversion
size_t count = items.size();
int intCount = static_cast<int>(count);

// Unsigned literals
for (size_t i = 0u; i < count; ++i) { }

// Unused variable
[[maybe_unused]] const int kDebugFlag = 1;
```

## Always Comment Suppressions

```cpp
#pragma warning(disable: 4625) // Copy constructor deleted
```

For project-file suppressions, include XML comments for owner, rationale, expiry/review, and scope. `C5039` callback exception-spec warnings are production-sensitive: fix or locally justify them at the callback boundary instead of hiding them at project scope.

## Additional Fix Patterns

```cpp
// Double-casting for complex type chains
auto val = static_cast<float>(static_cast<int>(source));

// Template safety with static_assert
template<typename T>
void Process(T value) {
    static_assert(std::is_integral_v<T>, "T must be integral");
}
```

## Build Configuration

- Support Debug and Release configurations
- Enable `/Wall` (`EnableAllWarnings`) for first-party projects
- Use static analysis tools (PVS-Studio, Clang-Tidy)
- Configure proper optimization flags for Release

## Testing and Quality

- Use static analysis tools regularly
- Follow consistent formatting (.clang-format)
- Write unit tests for complex logic
- Perform regular code reviews
- Profile graphics-intensive operations
- Test with large datasets
- Validate memory usage patterns
- Test on different DPI settings
