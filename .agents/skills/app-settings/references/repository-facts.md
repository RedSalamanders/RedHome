# Application settings: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md). A fact marked H-15 is today's behavior where it differs from the D19 rules in `SKILL.md`; it changes with that register row.

## Where each application keeps its settings

| Repository | Contract and schema | Store | Watcher | Files |
| --- | --- | --- | --- | --- |
| RedXe | [Specs/Core/Core_Settings.md](../../../../../RedXe/Specs/Core/Core_Settings.md), [Specs/SettingsStore.schema.json](../../../../../RedXe/Specs/SettingsStore.schema.json); performance in [Core_PerformanceAndResources.md](../../../../../RedXe/Specs/Core/Core_PerformanceAndResources.md) | `RedXe/Settings.cpp` (and `RedXe/SettingsV4.cpp`); templates in `Settings/` | `RedXe/SettingsWatcher.cpp` | `RedXe.settings.json`, `RedXe-debug.settings.json` |
| RedPrism | [Specs/Core/Core_Settings.md](../../../../../RedPrism/Specs/Core/Core_Settings.md) | `Common/SettingsStore.*`; the application side `RedPrism/ApplicationSettings.cpp`; the startup load `RedPrism/Main.cpp` | In `RedPrism/ApplicationSettings.cpp` | `settings.json`, `settings.debug.json` under `%LocalAppData%\RedPrism` |
| RedTilde | [Specs/Core/Core_Settings.md](../../../../../RedTilde/Specs/Core/Core_Settings.md), [SettingsStore.schema.json](../../../../../RedTilde/SettingsStore.schema.json) | `Common/Settings.cpp` | `SettingsWatcher` in `Common/Settings.cpp` | `RedTilde.settings.json` and `RedTilde-debug.settings.json` |
| RedSalamander | [Specs/Core/Core_SettingsStore.md](../../../../../RedSalamander/Specs/Core/Core_SettingsStore.md), [Specs/SettingsStore.schema.json](../../../../../RedSalamander/Specs/SettingsStore.schema.json) | `Common/Common/SettingsStore.cpp` | `RedSalamander/SettingsHotReload.cpp` | `<App>.settings.json`, `<App>-debug.settings.json` |
| RedMonitor | [Specs/Core/Core_Settings.md](../../../../../RedMonitor/Specs/Core/Core_Settings.md), [Specs/SettingsStore.schema.json](../../../../../RedMonitor/Specs/SettingsStore.schema.json) | `support/SettingsStore.cpp`, imported from RedSalamander's store (its contract calls the broad settings and theme types migration debt) | `src/SettingsWatcher.cpp` | `RedSalamanderMonitor-7.0.settings.json` (Release), `RedSalamanderMonitor-debug.settings.json` (Debug), with fallbacks to the legacy `RedSalamanderMonitor.settings.json` |
| DxUi | None: settings are consumer-owned | None | None | None |

Preferences pages in RedSalamander (dirty tracking, Apply/OK persistence, Cancel semantics, schema metadata): the repository-local [build-preferences-pages](../../../../../RedSalamander/AGENTS.md#skills-reference) skill.

## RedXe

Read the settings contract, the performance contract, and the canonical schema before changing behavior. Current document versions, field ranges, filenames and migration rules belong there and in the parser/templates. Use `yyjson` with WIL RAII for document/string and file/event ownership, keep UI delivery on `Application`'s thread, and apply `plugin-development` when settings recreate widgets.

- Keep `Settings/`, schema, parser, normative settings spec and Settings tests aligned. Never publish a setting the running application cannot apply.
- Follow [category-aware template coverage](../../../../../RedXe/Specs/Core/Core_Settings.md#selection-storage-and-deployed-defaults) using `RedXe/BundledPlugins.h`. Ordinary widgets appear in both templates, opt-in widgets in neither, Debug-only widgets only in Debug, and services in both without requiring a placed widget. Do not add forbidden examples to satisfy a blanket checklist.
- Optional host and dock preferences fall back individually. Unknown root and dock members survive both widget persist and dock edits. H-15 still covers document-level version, required layout, duplicate and closed plugin validation and their recovery rules. Preserve the source document, comments and BOM according to the owning contract. Loading is read-only and a no-op persist leaves the file untouched.
- Host persist merges a subset into the current instance and validates the complete result. Do not replace unspecified members or rewrite authored syntax into the internal layout model. Persist only against the accepted file identity while holding the contract's write-exclusion guard; record identity through the committed handle. A conflict/deferred write keeps the runtime patch and external bytes intact, with the bounded notice policy.
- Cold recovery backs up invalid bytes and installs the matching deployed template. Invalid live edits preserve both the edited file and last valid runtime state. Explicit portable settings have their separate fallback rules.
- Hidden self-tests parse deployed templates and keep writes in memory; they never touch normal user settings or initialize its diagnostic log directory.
- Watch the directory and block on stop/change events. The worker only coalesces and posts notification; parsing, widget changes, HWNDs and Direct3D remain on the owner thread. Stop/join the watcher before its target disappears.
- Acknowledge before reading and deduplicate accepted/rejected stamps. Preserve move/size and minimized-window deferral/replay, the active page when it survives, and the rule that live reload never writes the watched file.
- Apply valid changes to the running window, including dock-kind transitions. Reconfigure transactionally and roll back on apply failure. Suppress collect/persist side effects while adopting an external load.
- Use `Test-Changes.ps1 -Explain` and affected suites while editing; PrePush/Full and the owning domain contract determine final qualification. Cover invalid load, external conflict, unchanged writes, deferred replay and rollback with independent file/runtime assertions. Live foreground acceptance requires agreement to the time; hidden WARP and metadata checks do not establish that gate.

## RedPrism

- One JSON object; `schema` (integer ≥ 1) carries compatibility, the file name only tells Debug (`settings.debug.json`) from Release (`settings.json`). Never encode a version in the name.
- Adding a setting: a field in `AppSettings` with its default, a `Parse` branch that validates or clamps it (an unusable value takes the default, never the whole document), a `Serialize` `put`, a row in the spec's field table, an `IoTests` `settings.*` case for the field and its fallback, and the application side (`ApplySettings` for a live setting, the start-only path for the rest). Unknown fields must keep surviving a save.
- Cold invalid: back up the bytes (`<path>.invalid-<stamp>`) and write the template. Live invalid: keep the file, keep the last-good settings, say so on the debugger output, write nothing. A live load must never write the watched file.
- H-15: watching is one `FindFirstChangeNotification` on the directory waited beside the message queue (`MsgWaitForMultipleObjectsEx`), coalesced by a 250 ms timer; parse and apply only on the UI thread. No polling, no worker thread.
- The app's own save calls `NoteSettingsFileState` so it does not reload itself; saves are atomic (temporary file, `MoveFileExW` replace, write-through).
- `--self-test`, `--screenshot`, `--demo`, `--bench` and `--crash-probe` never read or write the user's file; the self-test proves the live reload from a file under `%TEMP%`.
- Use `yyjson` with WIL document ownership (`yyjson_mut_obj_put` replaces a key; `yyjson_doc_mut_copy` keeps the rest).

## RedTilde

- Settings have field-level fallback and atomic persistence; errors leave editing available. Apply changes live and honor high contrast.
- Read finite JSON5 with a BOM. The cold loader migrates the legacy text document when the selected JSON file is absent. The watcher coalesces changes for the UI thread, and saves preserve unknown members. Tests use the isolated `--data-dir`.
- Verify invalid settings separately from the dump, the pending marker, and the ordinary restart ([crash-dumps](../../crash-dumps/SKILL.md)).

## RedSalamander

- The watcher thread waits on the directory change and its stop event, coalesces, and posts the change to the window with `PostMessagePayload` (`WndMsg::kSettingsFileChanged`); the UI thread parses and applies.

## RedMonitor

- The worker watches the canonical profile's directory and its parent, then posts a coalesced notification. The UI thread reads the changed file with the no-recovery loader. Stop and join the watcher before shutdown saves or window destruction.
- Accepted edits apply to viewer preferences. Language and saved window placement take effect on the next start. Legacy fallback discovery belongs to startup.
