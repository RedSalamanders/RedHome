# C++ Style Patterns

Common detail for every repository. The rules summary is in [SKILL.md](../SKILL.md); product-specific facts are in [repository-facts.md](repository-facts.md).

## Project Requirements

- **MSVC stdcpplatest** mode
- **Unicode UTF-16** encoding
- Compile source as UTF-8 (`/utf-8`) while calling wide-character Win32 APIs. `.rc` files carry `#pragma code_page(65001)`.
- Minimum Windows version: see [repository-facts.md](repository-facts.md).

## Smart Pointers

```cpp
// ✅ Exclusive ownership
std::unique_ptr<Widget> widget = std::make_unique<Widget>();

// ✅ Shared ownership (only when needed)
std::shared_ptr<Resource> resource = std::make_shared<Resource>();

// ❌ NEVER raw new/delete
Widget* widget = new Widget();
delete widget;
```

## STL Usage

```cpp
// ✅ std::format for strings
auto msg = std::format(L"Found {} files", count);

// ✅ std::optional (NEVER use * to access)
std::optional<int> result = FindValue();
if (result.has_value()) {
    Use(result.value());
}
int val = result.value_or(0);

// ✅ Range-based for
for (const auto& item : items) { }

// ✅ Structured bindings
auto [key, value] = GetPair();

// Fixed buffers are reserved for boundaries that require bounded storage.
```

### Formatting Into Fixed Buffers (When Required)

Prefer `std::format_to_n` over `*printf_s` when you must write into an existing fixed buffer (e.g. `noexcept` hot paths, Win32 APIs).

```cpp
std::array<wchar_t, 32> buf{};
constexpr size_t max = buf.size() - 1;
const auto r         = std::format_to_n(buf.data(), max, L"VK_{:02X}", vk);
buf[(r.size < max) ? r.size : max] = L'\0';
```

## Naming Conventions

| Type | Style | Example |
|------|-------|---------|
| Classes / Structs | PascalCase | `ColorTextView` |
| Public methods | PascalCase | `RenderText()` |
| Private methods | camelCase | `calculateLayout()` |
| Locals / Parameters | camelCase | `textLayout` |
| Public `struct` / DTO fields | camelCase | `scrollOffset` |
| Private & protected non-static members | Strict `_camelCase` (`_[a-z][A-Za-z0-9]*`) | `_scrollY` |
| Constants | kName | `kMaxBufferSize` |

- **Strict `_camelCase` rule**: Private and protected non-static class/struct data members MUST start with `_` followed strictly by a lowercase ASCII letter `[a-z]`.
- **Member-scope only**: Leading `_` is permitted **only** on private/protected class or struct data members.
- **Banned forms**:
  - Trailing underscore `name_` (e.g., `handle_`)
  - Unprefixed bare private/protected fields (e.g., `scrollY`) or Hungarian/Microsoft prefixes (`m_name`)
  - `_Uppercase` anywhere (e.g., `_Handle`, `_Impl`) — reserved identifier
  - `__double` underscore anywhere (e.g., `__value`, `foo__bar`) — reserved identifier
  - Leading `_` at file, namespace, or global scope (e.g., `namespace { int _counter; }`, file-static `_instance`) — reserved identifier (`bugprone-reserved-identifier` / ISO C++ `[lex.name]`)
- **Public DTOs**: Public `struct`/DTO data members remain `camelCase` without a leading underscore.

### Canonical `.clang-tidy` Configuration (`H-27`)

Enforce member naming and reserved-identifier hygiene via a repository-root `.clang-tidy`:

```yaml
Checks: '-*,bugprone-reserved-identifier,readability-identifier-naming'
HeaderFilterRegex: '^(?:Common|RedTilde|RedPrism|RedXe|RedMonitor|RedSalamander|DxUi|src|include|Tests)/.*'
CheckOptions:
  - key: readability-identifier-naming.PrivateMemberCase
    value: camelBack
  - key: readability-identifier-naming.PrivateMemberPrefix
    value: '_'
  - key: readability-identifier-naming.ProtectedMemberCase
    value: camelBack
  - key: readability-identifier-naming.ProtectedMemberPrefix
    value: '_'
  - key: readability-identifier-naming.PublicMemberCase
    value: camelBack
  - key: readability-identifier-naming.IgnoreMainLikeFunctions
    value: true
```

## Code Style

```cpp
// ✅ One declaration per line
int width;
int height;

// ❌ Multiple declarations
int width, height;

// ✅ Use auto appropriately
auto iter = container.begin();

// ✅ constexpr for compile-time
constexpr int kBufferSize = 1024;

// ✅ string_view and span for non-owning views
void Process(std::wstring_view text);
void Process(std::span<const int> data);
```

## C++ Core Guidelines

Follow [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines):
- Prioritize safety, simplicity, and maintainability
- Avoid undefined behavior
- Use GSL concepts where applicable

## RAII Pattern

Use the existing WIL owner rather than writing a raw-handle destructor and defaulting its moves:
```cpp
class Resource 
{
    wil::unique_handle _handle;
public:
    explicit Resource(wil::unique_handle handle) noexcept : _handle(std::move(handle)) {}
    Resource(const Resource&) = delete;
    Resource& operator=(const Resource&) = delete;
    Resource(Resource&&) noexcept = default;
    Resource& operator=(Resource&&) noexcept = default;
};
```

WIL move assignment releases the destination's previous owned handle and empties the source. A defaulted move of a scalar `HANDLE` does neither. Borrowed/shared Win32 handles are not adopted into an owning wrapper unless the acquisition API explicitly transfers ownership.

Delete copying for unique resource owners. Make cleanup idempotent so partial initialization remains safe.

## File Organization

- **Headers**: Keep interfaces minimal, use forward declarations
- **Implementation**: Group related functionality together
- **Dependencies**: Minimize header includes
- **Platform**: Isolate platform-specific code when possible

Keep headers small, include what they use, and avoid global mutable state.

## Shared Helper Reuse

Before defining a local helper, consult the repository's shared-helper catalog and search its common code folder (`Common/`, or
`Tests/TestSupport/` for test infrastructure). `RedSalamander` keeps its catalog in `Specs/Core/Core_SharedHelpers.md`; see
[repository-facts.md](repository-facts.md). If an existing helper has the required semantics, use it directly.
Do not create a differently named copy or a leaf wrapper that only forwards the same policy.

If the existing helper is at the correct dependency layer but lacks a generally useful operation, extend it and
add focused tests. Keep a local implementation only when it intentionally differs in policy, dependency, ABI,
ownership, failure handling, or hot-path constraints; name and document that difference. When adding a canonical
shared helper, update the catalog and its authoritative domain spec, and add a source-contract guard when a
regression could silently recreate prior copies.

## Win32 Includes

- Define `WIN32_LEAN_AND_MEAN` and `NOMINMAX` before `#include <windows.h>`.
- Put `windows.h` in its own include block (blank line after it) before
  `bcrypt.h`, `wincodec.h`, or other SDK headers that need `ULONG`/`NTSTATUS`.
  clang-format `SortIncludes` is alphabetical inside a block and will otherwise
  put `bcrypt.h` first, which fails to compile.
- After `WIN32_LEAN_AND_MEAN` + `windows.h`, include `objbase.h` / `objidl.h` in
  their own block before `UIAutomation.h` or `XmlLite.h`. Those headers need
  COM `interface` types that lean Windows does not provide, and `SortIncludes`
  puts `UIAutomation.h` / `XmlLite.h` before `objbase.h` / `objidl.h`.

## Comments and Documentation

- Write self-documenting code with meaningful names
- Document public APIs with Doxygen-style comments
- Explain "why" rather than "what"
- Include performance notes for critical sections
- For perf-sensitive features or hot-path changes, define the protected scenario and required measurement path in code/docs early rather than after the implementation is complete

## Patterns to Avoid

- `new`/`delete` (use smart pointers)
- C-style casts (use `static_cast`, `reinterpret_cast`)
- `goto` (use early returns + RAII / `wil::scope_exit`)
- Raw Windows handles (use WIL wrappers)
- `sprintf_s` / `swprintf_s` in non-PoC code
- `catch (...)` (FORBIDDEN; catch explicitly named exception types only, and document why catching is mandatory at that boundary)
- Global state and singletons unless absolutely necessary
- Blocking UI thread with synchronous operations
- String concatenation in loops (use `std::format` or reserve capacity)
- Multiple variable declarations on same line
- Perf-sensitive feature work with no instrumentation, no deterministic selftest, or no archived evidence
