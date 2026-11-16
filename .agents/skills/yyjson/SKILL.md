---
name: yyjson
description: Parse, validate, and serialize JSON/JSON5 safely with yyjson across RedSalamanders C++ projects without lifetime, string-borrowing, or leak bugs.
---

# Safe `yyjson` Usage

Consume `yyjson` from `vcpkg.json` (never vendor a duplicate copy) and combine with the `wil-raii` skill for unconditional cleanup.

## Document & Buffer Ownership

- A `yyjson_doc*` or `yyjson_mut_doc*` owns every `yyjson_val*` and borrowed `const char*` (`yyjson_get_str()`) read from it. Copy/convert strings to `std::wstring`/`std::string` before freeing the document.
- Own documents and serialized buffers via WIL RAII (never `delete`/`delete[]` a `yyjson` allocation; write buffers use `free()` unless a custom `yyjson_alc` was passed):

```cpp
using unique_yyjson_doc     = wil::unique_any<yyjson_doc*, decltype(&yyjson_doc_free), yyjson_doc_free>;
using unique_yyjson_mut_doc = wil::unique_any<yyjson_mut_doc*, decltype(&yyjson_mut_doc_free), yyjson_mut_doc_free>;
using unique_malloc_string  = wil::unique_any<char*, decltype(&free), free>;
```

## Mutable Document String Lifetime (Most Common Bug)

`yyjson_mut_obj_add_*` convenience functions **never copy the key**, and `*_str` / `*_strn` **do not copy value bytes**:

| Function | Copies Key? | Copies Value? | Safe Usage |
| --- | --- | --- | --- |
| `yyjson_mut_obj_add_str` | No | No | Only when both key and value are string literals or outlive the doc |
| `yyjson_mut_obj_add_strcpy` | No | Yes | Literal/static key + temporary `const char*` value |
| `yyjson_mut_obj_add_strncpy` | No | Yes | Literal/static key + known-length UTF-8 (`str.data()`, `str.size()`) |
| `yyjson_mut_obj_add_val` | No | n/a | Literal/static key + doc-owned `yyjson_mut_val*` |
| `yyjson_mut_obj_add` | Yes (via `yyjson_mut_val*`) | Yes (via `yyjson_mut_val*`) | **Required for dynamic keys**: allocate key with `yyjson_mut_strncpy(doc, k.data(), k.size())` |

Check all `yyjson_mut_*` pointer allocations and `*_add_*` boolean returns when complete output is required, propagating `E_OUTOFMEMORY` on failure.

## Parsing & Validation

- Pass a mutable buffer (`std::string` / `std::vector<char>`, never a string literal) to `yyjson_read_opts()`, capture `yyjson_read_err`, and avoid `YYJSON_READ_INSITU` unless mutating and retaining the input buffer is intentional.
- Check root and field types (`yyjson_is_*`) before reading (`yyjson_get_*`), and validate numeric bounds before narrowing casts.
- Note: `yyjson_obj_get` returns the **first** occurrence of a duplicate key (test fixtures overriding fields must prepend overrides). Use the `len` returned by `yyjson_write_opts` / `yyjson_mut_write_opts` when constructing strings.
