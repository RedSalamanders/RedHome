# RedPrism detail: `yyjson`

> **Parity reference.** Body of `RedPrism/.agents/skills/yyjson/SKILL.md` as of `8c27267f76c5`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedPrism`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Use yyjson from `vcpkg.json`; do not vendor its source. Apply `wil-raii` to document and write-buffer ownership.

- A `yyjson_doc*` or `yyjson_mut_doc*` owns all values and borrowed strings obtained from it. Never retain a
  `yyjson_val*` or `yyjson_get_str()` result after the document is freed.
- Own documents unconditionally with WIL:

```cpp
using unique_yyjson_doc = wil::unique_any<yyjson_doc*, decltype(&yyjson_doc_free), yyjson_doc_free>;
using unique_yyjson_mut_doc = wil::unique_any<yyjson_mut_doc*, decltype(&yyjson_mut_doc_free), yyjson_mut_doc_free>;
```

- Pass a mutable buffer to `yyjson_read_opts()`, capture `yyjson_read_err`, check the root and every value's type,
  and reject invalid ranges before narrowing numeric values.
- Convenience `yyjson_mut_obj_add_*` functions borrow their keys. Use `*_strcpy` / `*_strncpy` for temporary strings.
- For a dynamic key, allocate both key and value as document-owned `yyjson_mut_val*` values and call
  `yyjson_mut_obj_add()`.

- `yyjson_obj_get` returns the first occurrence of a duplicated key; tests that override a field inject it first.
- Swift `Codable` shapes on disk (`.prism`): non-optional properties are always present, optional ones are omitted
  when nil, and a dictionary keyed by an enum that is not `CodingKeyRepresentable` is an alternating key/value
  array (`["Reds", {…}, "Master", {…}]`) in unspecified order. Read both array and object forms; write the array
  form in a fixed order. See `Specs/IO/IO_ProjectFormat.md`.

Project manifests (C5) and settings (C14) must follow this ownership. Do not introduce a second JSON library.
