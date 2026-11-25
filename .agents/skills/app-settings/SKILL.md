---
name: app-settings
description: Store, validate, save, and live-reload application settings across RedSalamanders C++ applications - the contract owns the fields, an unusable value takes its field's default, only an unparseable file is invalid, a coalesced watcher posts to the UI thread, a live reload never writes the watched file, and harness runs never touch the user's file. Use when adding or changing a setting, the settings file, its schema or template, cold recovery, or live reload.
---

# Application Settings

Read the target repository's settings contract and schema first; [references/repository-facts.md](references/repository-facts.md) names them, with the store, the watcher, and the file names. This skill applies in every application; the repository's `AGENTS.md` and `Specs/` win on any conflict. Parse and build the document with [yyjson](../yyjson/SKILL.md) under [wil-raii](../wil-raii/SKILL.md) ownership, and save it as [file-io-safety](../file-io-safety/SKILL.md) says. The reload, validation, and unknown-member rules below are the convergence plan's decision D19 (register H-15); the `Differences To Converge` table says which store does not follow them yet.

## The Contract Owns The Fields

- Document versions, field ranges, file names, and migration rules belong to the settings contract, the schema, the parser, and the templates, never to a second copy in a skill.
- Keep the templates, the schema, the parser, the contract, and the settings tests aligned. Never publish a setting the running application cannot apply.
- **Adding a setting**: a field with its default; a parse branch that validates or clamps it; a serialize step; a row in the contract's field table; a settings test for the field and its fallback; and the application side (applied live for a live setting, on the start-only path for the rest).

## Reading

- Loading is read-only.
- A value of the wrong type or out of range takes that field's default or is clamped, and the rest of the document applies. An unusable value never invalidates the whole document. Only a file that cannot be parsed is invalid.
- Unknown members are ignored on read and kept across a save: copy the parsed document into the mutable one and replace only the keys the application owns.
- Preserve the source document's comments and byte order mark as the owning contract says.

## Invalid Files

- **Cold start**: back up the invalid bytes and install the matching deployed template.
- **Live reload**: keep the file and the last good settings, report it on the diagnostic output, and write nothing.
- An error leaves the application usable: editing and the rest of the user interface stay available.

## Saving

- Publish settings atomically under the [guarded-save requirement](../file-io-safety/SKILL.md). Defer a conflicting write and preserve the in-memory change. A no-op persist leaves the document untouched.
- The application's own save records the file state it committed, so its watcher does not reload its own write.

## Live Reload

- A worker thread waits on the directory change and a stop event, coalesces, and posts one notification to the UI thread. Parsing and applying stay on the UI thread, with every window, widget, and device change. No polling.
- Stop and join the watcher before its target disappears.
- Acknowledge the change before reading, and deduplicate accepted and rejected file stamps.
- A live reload never writes the watched file.

## Harness Runs And Tests

- Self-tests, screenshots, demos, benchmarks and crash probes use deployed templates or settings under the product's authorized, isolated test root. Use in-memory writes where the scenario allows.
- Prove live reload with a fixture file in that test root. The product harness owns the file, watcher and cleanup.
- Cover invalid load, external conflict, unchanged writes, and each field with its fallback, with independent assertions on the file and on the running state. Verify invalid settings separately from the crash and restart checks ([crash-dumps](../crash-dumps/SKILL.md)).

## Repository Facts

Contracts, schemas, stores, watchers, file names, and product rules for every application: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Reload, validation, and unknown members (H-15, D19) | RedXe, RedSalamander, RedTilde and RedMonitor use workers that coalesce changes and post to the UI thread. RedPrism waits beside the message queue. RedPrism and RedTilde apply field fallback and keep unknown members. RedXe applies defaults to optional host and dock preferences and keeps additive members in those objects. | RedPrism adopts the worker. Each owner reconciles document-level validation and recovery and verifies the supported round trips. |
| Settings format (register H-10) | All five application stores use JSON through `yyjson`. RedTilde migrates legacy text on cold start. | JSON through `yyjson` |
| File and contract names (register H-26) | RedXe, RedSalamander and RedTilde use the named Debug and Release JSON files. RedPrism uses `settings.json` and `settings.debug.json`. RedMonitor's Release name moves with S4. RedXe, RedPrism, RedMonitor and RedTilde own `Core_Settings.md`. RedSalamander uses `Core_SettingsStore.md`. | `<Product>.settings.json`, `<Product>-debug.settings.json` and `Specs/Core/Core_Settings.md` everywhere |
