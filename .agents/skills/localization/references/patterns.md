# Localization patterns

Common how-to for every repository. Rules are in [SKILL.md](../SKILL.md); product-specific names are in [repository-facts.md](repository-facts.md).

## Resource Helpers

The shared helper names and their owners are listed in [Differences To Converge](../SKILL.md). The first parameter of the real helpers is the owning module (`nullptr` for the executable); the example omits it.

```cpp
// Load string from resources
std::wstring title = LoadStringResource(IDS_APP_TITLE);

// Format with arguments
std::wstring msg = FormatStringResource(IDS_FILE_COUNT, fileCount);

// Load a documented language-neutral string from the owner module only
std::wstring token = LoadEmbeddedStringResource(g_hInstance, IDS_PLUGIN_PROTOCOL_NAME);

// Format a documented language-neutral skeleton from the owner module only
std::wstring codepage = FormatEmbeddedStringResource(g_hInstance, IDS_CODEPAGE_FORMAT, codepageId);

// Message box from resources
MessageBoxResource(_hWnd, IDS_ERROR_MSG, IDS_ERROR_TITLE, MB_OK | MB_ICONERROR);
```

## Language-Neutral Resource Rule

Stable non-translatable tokens still live in resources, but only in the
embedded `.rc` for the executable or plugin that owns them. Do not duplicate
those IDs in satellite `.rc` files. Load them with `LoadEmbeddedStringResource`
or `FormatEmbeddedStringResource`, passing the owner `HINSTANCE`; plugin code
must pass the plugin DLL handle such as `g_hInstance`, not `nullptr`.

Examples: language autonyms in a language picker, product/protocol/brand names,
file format identifiers, keyboard glyphs, sample technical paths, placeholder-
only layout skeletons, and technical formats such as hex/HRESULT strings.
Ordinary UI labels, tooltips, sentences, command names, and grammar-bearing
formats remain localizable even when translations currently match English.

## STRINGTABLE in .rc

```rc
STRINGTABLE
BEGIN
IDS_APP_TITLE       "RedSalamander"
IDS_FILE_COUNT      "{0} files selected"
IDS_ERROR_MESSAGE   "An error occurred: {0} in {1}"
IDS_HRESULT_DETAILS "0x{0:08X}: {1}"
END
```

## Avoid printf-style resource formats

```rc
// ❌ Wrong (printf-style):
IDS_FATAL_EXCEPTION_FMT "Fatal Exception: %s (0x%08X)"

// ✅ Correct (std::format-style positional):
IDS_FATAL_EXCEPTION_FMT "Fatal Exception: {0} (0x{1:08X})"
```

## Avoid unindexed std::format resource formats

```rc
// ❌ Wrong (cannot be safely reordered by translators):
IDS_SAVE_FAILED "Failed to save {0}: 0x{:08X}"

// ✅ Correct (every argument is indexed):
IDS_SAVE_FAILED "Failed to save {0}: 0x{1:08X}"
```

## Keep source argument order obvious

```rc
// ❌ Wrong (source string uses argument 1 before argument 0):
IDS_ARCHIVE_DONE "Extracted {1} entries from {0}."

// ✅ Correct (code passes entry count first, archive path second):
IDS_ARCHIVE_DONE "Extracted {0} entries from {1}."
```

```cpp
auto msg = FormatStringResource(nullptr, IDS_ARCHIVE_DONE, entryCount, archivePath);
```

Translations may reorder placeholders, but must preserve the exact source
placeholder tokens. For example, a translation of `{0:L} file{1:s}: {2}
selected` can move `{2}`, but it cannot invent `{3}` or change `{2}` to
`{2:s}` unless the source also has that exact token.

## Menu Resources in .rc

```rc
IDR_MAINMENU MENU
BEGIN
    POPUP "&File"
    BEGIN
        MENUITEM "&Open",   ID_FILE_OPEN
        MENUITEM "&Save",   ID_FILE_SAVE
        MENUITEM SEPARATOR
        MENUITEM "E&xit",   ID_FILE_EXIT
    END
END
```

## Dynamic Menu Extensions

Runtime code may **only** extend dynamic parts:
- Theme lists from `Themes\*.theme.json5`
- Custom themes from settings
- Per-user history entries

Base menu structure must remain in `.rc` files.

## Pattern

```cpp
// ✅ Correct - load from resources
auto title = LoadStringResource(IDS_TITLE);

// ❌ Wrong - hardcoded
SetWindowTextW(hWnd, L"My Title");
```

## Menu Captions With Chords

Menu captions may keep a `\t` column in the table, but menus show the effective chord. Build chord text from the modifier-name strings (`IDS_KEY_*`) and the keyboard layout's key names, never from literals. Tooltips take the name and the effective chord as arguments; no key is baked into a string. The helpers that implement this in `RedPrism` are listed in [repository-facts.md](repository-facts.md).

## Data That Is Not Chrome

- `OutputDebugStringW` diagnostics stay literal and English.
- Document data that the model persists or compares (default `Layer N` / `Folder N` names, blend mode names on disk) stays in code exactly as the file format writes it.
- Never call `MessageBoxW(..., L"literal", ...)` or `SetWindowTextW(..., L"literal")` in product code.

## Satellite Translations

A translated table is a resource-only DLL built from the same `.rc` and ids. A satellite supplies translations; an id it lacks falls back to the embedded English. Keep ids stable so a translation can be added later. Satellite layouts differ per repository; see [Differences To Converge](../SKILL.md).

## Tests

Tests load the executable's table with `LoadLibraryExW(..., LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_IMAGE_RESOURCE)` and pass that module to the helpers; nothing in `Tests/` runs the product executable's code (`RedPrism.exe` for `RedPrism`) to read strings.

## Accessible Names

Accessible names are chrome strings too. Every interactive `DxUi` control gets `SetAccessibleName` from the same table (a label id, a tooltip id or an `IDS_A11Y_*` id). A self-test that fails on a control without a name proves it.
