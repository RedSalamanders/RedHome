---
name: file-io-safety
description: Open, validate, and save user files without losing data across RedSalamanders C++ applications - strict streaming validation before publishing, an owned same-directory temporary with flush and atomic replace, failure and cancellation that preserve the target, and completion keyed by request identity. Use when changing open, import, save, export, recovery, or cancellation of a file, or writing fault tests for them.
---

# File I/O Safety

Read the target repository's file contract first; [references/repository-facts.md](references/repository-facts.md) names it with the helper that implements it. This skill applies in every repository that reads or writes user files, settings included; the repository's `AGENTS.md` and `Specs/` win on any conflict. Settings-specific rules (templates, backups, live reload) are in the settings skill of the target repository and its contract.

## Read And Validate Before Publishing

- **Stage, then publish.** Read and validate the whole input on an owned, cancellable worker before replacing the current document; a failed or cancelled open never replaces it.
- **Strict streaming validation.** Validate UTF-8 and UTF-16LE strictly, in bounded chunks. Reject NUL and invalid UTF-8, and enforce the byte and line budgets and the actual capacity of the consumer (an editor's real limit, not an assumed one).
- **Round-trip what the file holds.** Preserve the byte order mark and the line endings the file had.

## Save

- **Owned same-directory temporary, flush, atomic replace.** Write the complete content to a temporary file the operation owns, in the destination's directory; flush it; then replace the destination atomically. Never write the destination in place, except on the documented path of the owning contract.
- **Check the destination's identity.** Before replacing a file the user can also change outside the application, compare its identity and content stamp with the ones recorded at open or last save. A destination that changed requires an explicit overwrite choice.
- **Recovery never overwrites originals.** Recovery copies are per session, kept apart from the user's files.

## Failure, Cancellation, And Completion

- **Failure and cancellation preserve.** A failed or cancelled operation leaves the current document or the destination as it was, and keeps the dirty state and the path.
- **Completion by request identity.** File workers publish by request identity: a completion must match the session and the saved snapshot it was admitted for, and a stale completion is rejected. Edits made after admission remain dirty.

## Tests

- Exercise invalid encoding, boundary sizes, cancellation, and write and replace faults (fault-injection hooks, not real disk failures).
- Use isolated directories for failure, conflict, and cancel tests; never touch the user's unrelated files ([test-evidence](../test-evidence/SKILL.md)).

## Repository Facts

File contracts, replace helpers, temporary names, budgets, and fault hooks for every repository: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Replace sequence (register H-25) | RedTilde (`Common/Storage.cpp`, `RedTilde/Printing.cpp`): `ReplaceFileW` over an existing destination, `MoveFileExW(MOVEFILE_WRITE_THROUGH)` for a new one, as its contract requires. RedPrism projects and images (`Common/ProjectStore.cpp`, `Common/ImageCodecs.cpp`): `ReplaceFileW` with `REPLACEFILE_IGNORE_MERGE_ERRORS`, falling back to `MoveFileExW(MOVEFILE_REPLACE_EXISTING)` without write-through. RedPrism settings (`Common/SettingsStore.cpp`): `MoveFileExW(MOVEFILE_REPLACE_EXISTING \| MOVEFILE_WRITE_THROUGH)`. RedXe settings (`RedXe/Settings.cpp`): a flushed temporary renamed over the file with POSIX semantics (`FileRenameInfoEx`) while a guard handle on it stays open, as its `Core_Settings.md` requires (`CommitTemporaryFile` with `MoveFileExW` only copies the schema). RedMonitor (`support/LocalFileTransaction.h`): a handle rename (`SetFileInformationByHandle`, `FileRenameInfoEx`), then `MoveFileExW`; the only one with fault-injection hooks | One sequence, the strictest: `ReplaceFileW` over an existing destination after its identity check, `MoveFileExW(MOVEFILE_WRITE_THROUGH)` for a new one, as RedTilde's contract states, with one fault-injection hook per step as in RedMonitor. RedPrism and RedMonitor change; RedXe's guarded rename waits for an owner decision |
