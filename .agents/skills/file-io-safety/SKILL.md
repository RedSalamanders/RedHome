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
- **Guard a replacement against concurrent edits.** For an existing file, validate the identity and content stamp accepted by the caller and protect the destination through publication. Preserve a competing write, replacement or newly created destination and report the conflict to the caller. Keep the pending change available for retry. An explicit overwrite applies to the version the user confirmed. Each product owns the mechanism and its supported-filesystem fallbacks (H-25, D23).
- **Recovery never overwrites originals.** Recovery copies are per session, kept apart from the user's files.

## Failure, Cancellation, And Completion

- **Failure and cancellation preserve.** A failed or cancelled operation leaves the current document or the destination as it was, and keeps the dirty state and the path.
- **Completion by request identity.** File workers publish by request identity: a completion must match the session and the saved snapshot it was admitted for, and a stale completion is rejected. Edits made after admission remain dirty.

## Tests

- Test an intervening write, rename, delete and create at the publication boundary. Check the external bytes and the retained in-memory change. Exercise the actual filesystem fallback as well as the primary path.
- Exercise invalid encoding, boundary sizes, cancellation, and write and replace faults (fault-injection hooks, not real disk failures).
- Use isolated directories for failure, conflict, and cancel tests; never touch the user's unrelated files ([test-evidence](../test-evidence/SKILL.md)).

## Repository Facts

File contracts, replace helpers, temporary names, budgets, and fault hooks for every repository: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Guarded replacement (H-25) | RedXe settings hold a guard through a POSIX handle rename where supported. Its contract describes the final name-check window and classic-rename fallback. RedTilde, RedPrism and RedMonitor use different replacement paths. Product-specific mechanisms are in the repository facts. | D23 makes protection against a lost concurrent edit common. Prove the guard or a conflict-preserving refusal on each supported path. RedMonitor's fault hooks can exercise the publish boundary. |
