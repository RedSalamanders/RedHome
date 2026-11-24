---
name: localization
description: Author and load UTF-8 Win32 STRINGTABLE and MENU resources with positional std::format placeholders and UI Automation accessible names. Use when adding or changing user-visible text, menus, resource strings or their placeholders, translations, or accessible names in any repository with a Win32 UI.
---

# Localization & Win32 Resource Strings

Applies in every repository with a Win32 UI: `RedSalamander`, `RedPrism`, `RedTilde`, `RedXe`, `RedMonitor` and the `DxUi` consumers.

## Mandatory `.rc` & Placeholder Rules

1. **All user-visible chrome text lives in `.rc` `STRINGTABLE` / `MENU` resources** (`#pragma code_page(65001)` UTF-8). Never hardcode English literals in `SetWindowTextW`, `MessageBoxW`, menus, tooltips, or status bars. (`OutputDebugStringW` diagnostics and persisted document data such as default layer names or sample Markdown content are not chrome.)
2. **Positional `std::format` placeholders only**:
   - Every placeholder must carry an explicit zero-based index (`{0}`, `{1}`, `{1:08X}`).
   - Bare `{}` / `{:08X}` and `printf` tokens (`%s`, `%d`, `%x`) are **forbidden** so translators can reorder arguments safely without `C4774` hazards. Never treat a resource string as a printf-format string and never suppress `C4774`.
3. **Sequential source argument order**:
   - Source strings introduce placeholders in call order (`{0}`, then `{1}`, then `{2}` with no skipped numbers), and `FormatStringResource(...)` passes arguments in that exact order.
4. **Translation token parity**:
   - Satellite `.rc` / `.resources.dll` translations may reorder `{0}` and `{1}` for grammar, but must preserve the exact placeholder count, indexes, and format specifiers of the source string. They must not add, drop, duplicate, renumber, or change format specs.
5. **Static menus live in `.rc` `MENU` resources.** Runtime code extends only dynamic parts (theme lists, custom themes from settings, per-user history entries).
6. **Language-neutral embedded tokens**:
   - Non-translatable technical tokens (protocol names, brand names, autonyms, hex skeletons) stay in the owning module's embedded `.rc` only and load via `LoadEmbeddedStringResource(hInstance, id)` / `FormatEmbeddedStringResource(hInstance, id, ...)`.
7. **Accessibility parity**:
   - Interactive `DxUi` and Win32 controls set their UI Automation accessible name (`SetAccessibleName`) from the same resource table (`IDS_*` label, tooltip, or `IDS_A11Y_*`).
8. **Run the owning repository's resource validation gate** after editing resource strings (see [Repository Facts](references/repository-facts.md)), or `validate.ps1` where the repository has no dedicated gate. Run it whenever a string contains braces.

## Load Strings

Load with `LoadStringResource(module, id)` and format with `FormatStringResource(module, id, args...)`; pass `nullptr` for the executable's own module. Examples for each helper, `.rc` snippets and the wrong/right pairs are in [references/patterns.md](references/patterns.md).

## Detailed Patterns

[references/patterns.md](references/patterns.md): resource helpers, `STRINGTABLE` examples, printf-style and unindexed formats to avoid, source argument order, menu resources, dynamic menu extension limits, language-neutral embedded resources, test-side loading, and accessible names.

## Repository Facts

[references/repository-facts.md](references/repository-facts.md): product-specific paths, helpers and gates, for example the `RedPrism` `kIds` table and the `RedSalamander` `ResourceLocalizationContracts.Tests.ps1` gate. `AGENTS.md` and `Specs/` of the owning repository win on any conflict.

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| String helpers | `RedSalamander`, `RedMonitor`, `RedTilde` and `RedXe` have the common load, format and message-box names. `RedPrism` has load and format helpers with a satellite and a raw-pattern fallback. | `RedPrism` adds the embedded variants and `MessageBoxResource`. Complete `RedXe`'s host-rendered chrome and dynamic notice audit. |
| Satellite layout | `RedSalamander`: `<dir>\Lang\<Module>-<culture>.dll` (`Common/Common/LocalizationManager.cpp`). `RedMonitor`: `Lang\RedSalamanderMonitor-<tag>.dll` (`src/Lang/<tag>/*.vcxproj`). `RedPrism`: `<exe dir>\Languages\<tag>\RedPrism.resources.dll`. `RedTilde`, `RedXe`: none. | `Lang\<Module>-<culture>.dll` (two repositories already use it); `RedPrism` would move. Confirm before changing. |
| Satellite loading | `RedSalamander`: `LoadStringResource` calls `Localization::LoadString` when `COMMON_EXPORTS` or `REDSAL_USE_COMMON_LOCALIZATION` is defined. `RedPrism`: `SetStringResourceSatellite` plus `Common/Localization.*`. `RedMonitor`: `LoadStringResource` falls back to `LoadEmbeddedStringResource` only. | One shared loader behind `LoadStringResource`; `RedMonitor` and `RedPrism` would adopt the `RedSalamander` `Localization` manager or the reverse. |
| Shipped translations | `RedSalamander`: `cs-CZ`, `fr-FR`, `ja-JP`, `sk-SK` (`RedSalamander/Lang/`, about 90 satellite projects in the solution). `RedMonitor`: the same four (`src/Lang/`). `RedPrism`: none in v1. `RedTilde`, `RedXe`: none. | English-only is allowed; keep ids stable so a satellite can be added without code changes. |
