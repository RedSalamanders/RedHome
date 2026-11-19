# File I/O safety: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md). The replace sequence, which still differs, is the skill's `Differences To Converge` row H-25.

| Repository | Contract | Files it reads and writes | Helper | Kept because |
| --- | --- | --- | --- | --- |
| RedTilde | [Specs/Core/Core_FileSafety.md](../../../../../RedTilde/Specs/Core/Core_FileSafety.md) | Markdown documents (Unicode open and save, dirty prompts, external conflicts, recovery), printing output | `Common/Storage.cpp`, `RedTilde/Printing.cpp` | Document editing exists only in RedTilde |
| RedMonitor | [Specs/Core/Core_Architecture.md](../../../../../RedMonitor/Specs/Core/Core_Architecture.md) | Log import and transactional export | `support/LocalFileTransaction.h` | Log import and export exist only in RedMonitor |
| RedPrism | [Specs/IO/IO_ProjectFormat.md](../../../../../RedPrism/Specs/IO/IO_ProjectFormat.md), [Specs/IO/IO_ImageCodecs.md](../../../../../RedPrism/Specs/IO/IO_ImageCodecs.md) | `.prism` projects, image import and export, settings | `Common/ProjectStore.cpp`, `Common/ImageCodecs.cpp`, `Common/SettingsStore.cpp` | Product formats |
| RedXe | [Specs/Core/Core_Settings.md](../../../../../RedXe/Specs/Core/Core_Settings.md) | Settings | `RedXe/Settings.cpp` (`CommitTemporaryFile`) | Settings only |
| RedSalamander | [Specs/FileSystem/FileSystem_FileOperations.md](../../../../../RedSalamander/Specs/FileSystem/FileSystem_FileOperations.md) | File operations are the product: copy, move, and delete of the user's files, owned by that spec | The file-operation engine and its plugins | Product behavior |
| DxUi | None | None: the library reads and writes no user file | None | Library |

## RedTilde

- Stage/validate before replacing the current document. Preserve BOM/EOLs, reject NUL/invalid UTF-8 and the actual editor capacity.
- Save with an owned same-directory temporary, flush and atomic replace; failed or cancelled operations preserve dirty state/path. The contract then uses `ReplaceFileW` for an existing destination or `MoveFileExW` for a new destination. An existing document whose `ReplaceFileW` returns `ERROR_NOT_SUPPORTED`, `ERROR_INVALID_FUNCTION` or `ERROR_CALL_NOT_IMPLEMENTED` may use the contract's recovery-protected in-place writer, as a hardlink save does.
- Check external identity and require an explicit overwrite choice. Worker completion must match the session and saved snapshot; edits after admission remain dirty.
- Recovery is per-session and never overwrites originals.
- Use isolated directories for failure/conflict/cancel tests; never touch the user's unrelated files.

## RedMonitor

- Retain strict streaming UTF-8/UTF-16LE validation and byte/line budgets: retention of 100,000 lines and 64 MiB of UTF-16 text, and 100,000 search matches (its contract).
- Open streams on an owned cancellable worker; a failed or cancelled open never replaces the document. Export writes strict UTF-8 with a BOM through a sibling temporary and an atomic replace.
- File workers publish by request identity. Cancel/failure preserves the current document or destination.
- Exercise invalid encoding, boundary sizes, cancellation and write/replace faults. `support/LocalFileTransaction.h` has the fault hooks (for example `FailNextLocalFileTransactionFlush`).

## RedXe

- RedXe's settings store validates the applied stamp on a guard handle, flushes an owned sibling temporary, rechecks the path identity and uses `FileRenameInfoEx` with POSIX semantics while the guard stays open. The documented final check-to-rename window and the classic-rename fallback need coverage under D23. A refused persist retains the in-memory change. `CopyFileAtomically` and `CommitTemporaryFile` refresh the deployed schema. [RedXe settings contract](../../../../../RedXe/Specs/Core/Core_Settings.md)
