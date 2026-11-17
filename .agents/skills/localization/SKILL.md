---
name: localization
description: Author and load UTF-8 Win32 STRINGTABLE and MENU resources with positional std::format placeholders and UI Automation accessible names.
---

# Localization & Win32 Resource Strings

Applies across `RedSalamander`, `RedPrism`, `RedTilde`, and localized UI components.

## Mandatory `.rc` & Placeholder Rules

1. **All user-visible chrome text lives in `.rc` `STRINGTABLE` / `MENU` resources** (`#pragma code_page(65001)` UTF-8). Never hardcode English literals in `SetWindowTextW`, `MessageBoxW`, menus, tooltips, or status bars. (`OutputDebugStringW` diagnostics and persisted document data such as default layer names or sample Markdown content are not chrome.)
2. **Positional `std::format` placeholders only**:
   - Every placeholder must carry an explicit zero-based index (`{0}`, `{1}`, `{1:08X}`).
   - Bare `{}` / `{:08X}` and `printf` tokens (`%s`, `%d`, `%x`) are **forbidden** so translators can reorder arguments safely without `C4774` hazards.
3. **Sequential source argument order**:
   - Source strings introduce placeholders in call order (`{0}`, then `{1}`, then `{2}` with no skipped numbers), and `FormatStringResource(...)` passes arguments in that exact order.
4. **Translation token parity**:
   - Satellite `.rc` / `.resources.dll` translations may reorder `{0}` and `{1}` for grammar, but must preserve the exact placeholder count, indexes, and format specifiers of the source string.
5. **Language-neutral embedded tokens (`RedSalamander`)**:
   - Non-translatable technical tokens (protocol names, brand names, autonyms, hex skeletons) stay in the owning module's embedded `.rc` only and load via `LoadEmbeddedStringResource(hInstance, id)` / `FormatEmbeddedStringResource(hInstance, id, ...)`.
6. **Accessibility parity**:
   - Interactive `DxUi` and Win32 controls set their UI Automation accessible name (`SetAccessibleName`) from the same resource table (`IDS_*` label, tooltip, or `IDS_A11Y_*`).

Run the owning repository's resource validation gate (`ResourceLocalizationContracts.Tests.ps1` in `RedSalamander`, `HostTests` in `RedPrism`, or `validate.ps1`) after editing resource strings.

## Repository Detail

| Working in | Read |
| --- | --- |
| `RedSalamander` | [references/redsalamander.md](references/redsalamander.md): `Common/Helpers.h` resource helpers, language-neutral embedded strings, `.rc` menus, and the limits on runtime menu extension, with examples |
| `RedPrism` | [references/redprism.md](references/redprism.md): the `HostTests` string-table gate, chord captions, satellite DLL layout, and accessible names |
| `RedTilde` and other localized UI | No separate skill existed; follow this file and that repository's `AGENTS.md`. |
