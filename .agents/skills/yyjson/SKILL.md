---
name: yyjson
description: Parse, validate, and serialize JSON/JSON5 safely with yyjson across RedSalamanders C++ projects without lifetime, string-borrowing, or leak bugs. Use when reading or writing JSON with yyjson, building a mutable document, or reviewing yyjson code for document lifetime, borrowed strings, or unchecked allocations.
---

# Safe `yyjson` Usage

Consume `yyjson` from `vcpkg.json`; never vendor a duplicate copy and never introduce a second JSON library. Apply the [wil-raii](../wil-raii/SKILL.md) skill to document and write-buffer ownership so cleanup is unconditional.

## Document & Buffer Ownership

- A `yyjson_doc*` or `yyjson_mut_doc*` owns every `yyjson_val*` and borrowed `const char*` (`yyjson_get_str()`) read from it. Never store them beyond the document lifetime; copy/convert strings to `std::wstring`/`std::string` before freeing the document.
- Free `yyjson_doc*` with `yyjson_doc_free()` and `yyjson_mut_doc*` with `yyjson_mut_doc_free()`, on every path (prefer RAII).
- Never `delete`/`delete[]` a `yyjson` allocation. Free buffers returned by `yyjson_write*()` / `yyjson_mut_write*()` with `free()` (or `alc->free` when a custom `yyjson_alc` was passed).
- The RAII aliases are in [references/patterns.md](references/patterns.md#memory-management-raii-patterns).

## Mutable Document String Lifetime (Most Common Bug)

`yyjson_mut_obj_add_*` convenience functions **never copy the key**, and `*_str` / `*_strn` **do not copy value bytes**. Only `*_strcpy` / `*_strncpy` copy value bytes into the doc. Borrowing is safe only when the string outlives the doc (literals, static storage, buffers you keep alive).

| Function | Copies Key? | Copies Value? | Safe Usage |
| --- | --- | --- | --- |
| `yyjson_mut_obj_add_str` | No | No | Only when both key and value are string literals or outlive the doc |
| `yyjson_mut_obj_add_strcpy` | No | Yes | Literal/static key + temporary `const char*` value |
| `yyjson_mut_obj_add_strncpy` | No | Yes | Literal/static key + known-length UTF-8 (`str.data()`, `str.size()`) |
| `yyjson_mut_obj_add_val` | No | n/a | Literal/static key + doc-owned `yyjson_mut_val*` |
| `yyjson_mut_obj_add` | Yes (via `yyjson_mut_val*`) | Yes (via `yyjson_mut_val*`) | **Required for dynamic keys**: allocate key with `yyjson_mut_strncpy(doc, k.data(), k.size())` |
| `yyjson_mut_str` / `yyjson_mut_strn` | n/a | No | Only for literals/static buffers |
| `yyjson_mut_strcpy` / `yyjson_mut_strncpy` | n/a | Yes | Preferred for any temporary/converted UTF-8 |

- For a dynamic key, allocate both key and value as document-owned `yyjson_mut_val*` values and call `yyjson_mut_obj_add()`.
- Check all pointer-returning allocations (`*_new`, `yyjson_mut_obj/arr`, `yyjson_mut_*str*`, `yyjson_mut_*number*`) and all `*_add_*` boolean returns when complete output is required. Propagate `E_OUTOFMEMORY`/failure; treat `false` as out of memory.

## Parsing & Validation

- Prefer `yyjson_read_opts()` and capture `yyjson_read_err` for error details.
- Pass a mutable buffer (`std::string` / `std::vector<char>`, never a string literal) to `yyjson_read_opts()`.
- Avoid `YYJSON_READ_INSITU` unless you intend the input buffer to be modified and to outlive the parsed doc.
- Check the root and every value's type (`yyjson_is_*`) before reading (`yyjson_get_*`); validate numeric bounds before narrowing casts.
- `yyjson_obj_get` returns the **first** occurrence of a duplicate key: test fixtures overriding fields must prepend (inject first) the overrides.
- Read flags for user-facing configuration: see [Differences To Converge](#differences-to-converge).

## Serialization

- Use `yyjson_write_err` with `yyjson_write_opts()` / `yyjson_mut_write_opts()` when you need diagnostics.
- Use the returned `len` when building strings; do not rely on a null terminator alone.

## Detailed Patterns

DO/DON'T code examples, RAII aliases, the read and write API notes, and the review checklist: [references/patterns.md](references/patterns.md).

## Repository Facts

Product-specific formats and test gates are in [references/repository-facts.md](references/repository-facts.md). RedMonitor follows this skill and its repository guidance. DxUi settings are consumer-owned.

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Read flags for user-facing configuration | RedSalamander, RedMonitor, RedTilde and RedXe read authored settings as JSON5 with BOM. RedPrism uses `YYJSON_READ_ALLOW_BOM` in `Common/SettingsStore.cpp`. | RedPrism adds `YYJSON_READ_JSON5` and verifies finite numeric validation and round trips. |
| JSON library and settings format | All five application stores use JSON through `yyjson`. RedTilde's cold loader migrates its legacy text document. DxUi settings are consumer-owned. | Apply [app-settings](../app-settings/SKILL.md) for storage behavior. |
