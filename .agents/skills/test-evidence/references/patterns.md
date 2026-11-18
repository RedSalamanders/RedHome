# Tests and evidence: detailed patterns

Common rules are in [SKILL.md](../SKILL.md). Apply them in every repository; the owning repository's `AGENTS.md` and `Specs/` win on any conflict. Product names below say where a pattern was first written down, not where it stops applying.

## Shared-process suites

These rules come from `RedSalamander`'s commands self-test (`--commands-selftest`), which runs every case in one process, in normal, repeat, and shuffled order. They hold for any suite that runs several cases in one process.

- **One isolation boundary for every order.** Cases run behind the same per-case isolation boundary in normal, repeat, and shuffled order. A fixture that mutates runtime managers, deferred plugin unload state, retained overlays, menu mode, focus, or pane state must restore and verify that state before returning; an isolated exact-case retry is not evidence that the broad process is clean.
- **Process-scoped window lookup.** Retained-window metrics and teardown assertions obtain HWNDs from process-owned debug hooks or another process-scoped lookup, never from class-only `FindWindowW(...)` evidence that can resolve a different running app instance.
- **Dedicated cases for global commands.** Broad command-dispatch smoke cases leave whole-runtime settings/plugin reload commands and provider/OS lifecycle commands that prepare before user confirmation to dedicated deterministic cases.
- **Restore presentation, not only settings.** After any dispatched command can mutate navigation or presentation state, restore the fixture's in-memory settings snapshot, re-establish both pane providers and paths, and reapply each pane's live display mode, sort key/direction, and visibility options. Then prove both current-folder enumerations have settled before the next dispatch. Restoring the settings object alone does not reapply already-mutated FolderView state, and matching path text alone is not quiescence evidence.
- **Quiet baseline before counters.** Navigation-shell stability cases that first change provider, path, or focus must pump messages and require a bounded multi-sample quiet baseline before capturing refresh, path, focus, or selection counters.
- **Focus after a modal.** When an owned pane modal closes, validate the real FolderView focus after the modal loop unwinds. Product teardown should combine a synchronous best-effort restore with the owning window's queued, foreground-safe focus restore; record Win32 focus, active/foreground owners, and the foreground process on failure.
- **Asynchronous cleanup.** For asynchronous file/lease cleanup, poll to a bounded quiet point and retry transient filesystem observation errors. Report the terminal path, existence, error, and observation count so an observer race is not classified as retained work.
- **Tab traversal.** For bidirectional tab-traversal coverage, explicitly re-establish and verify the boundary control before testing the opposite-direction wrap, and include logical plus native focus identities in failures.
- **Redraw churn.** For UI redraw-churn coverage, prove settling and render-to-invalidation attribution first; hard-bound the invalidation source instead of using a smaller fixed render cap that rejects attributable work under broad-process load.
- **UI Automation close and reopen.** For a same-process UIA close/reopen scenario, wait for the old HWND to close, release thread-held UIA clients, pump teardown, and reacquire the current window, page, host, and provider on every bounded mutation attempt. Treat Value, Toggle, and Selection operations as idempotent state-setting: success requires observing the requested state, not only a successful provider call. Preferences category selection must remain stable for repeated samples and reassert the target when queued initialization restores an earlier page; take render/invalidation baselines only after any subsequent focus transition also settles.
- **Order-dependent failures.** When a failure reproduces only in broad Commands order, run the failed case with its immediate predecessor cluster in one process and repeat that cluster after the repair. Then run canonical Commands once. A standalone exact-case pass does not prove process cleanliness, and increasing the timeout does not repair stale UIA identity or lifecycle state.

## Performance metrics

### Metric families

Prefer subsystem-prefixed metric names, one prefix per subsystem; the prefixes each repository uses are in [repository-facts.md](repository-facts.md). Good metrics include:

- queue coalesced/drained counts,
- input-to-visible or progress-to-visible latency,
- stage timings,
- rebuild counts,
- lock hold time,
- bytes rewritten,
- visible-work counters.

### Patterns expected

- For queue-storm work, instrument coalesced counts and drained counts, not just total time.
- For UI work, prefer visible-latency metrics over raw callback timing alone.
- For large-list/grid work, keep bounded visible-work instrumentation.
- For rendering work, separate synchronous refresh cost from downstream paint when possible.
- For storage or background services, keep correctness selftests and perf measurements together.

### Archiving

- Confirm that the run created a new folder in the repository's evidence folder, named by machine, area, and run.
- Keep the raw outputs (results, trace, and metric streams) intact; use same-machine comparisons whenever possible.
- A benchmark mode that prints numbers (for example `RedPrism`'s `--bench brush`) is recorded in the evidence folder and never used as a gate.

## Gate checklist

Before a change that adds or changes a test is complete:

1. The test file has a contextual `Scope.Tests.Behavior` name and its assertions are named `suite.case`.
2. Every expected value comes from the owning spec or an independent reference, with its tolerance in the spec.
3. The suite's entry point routes failure reports away from dialogs and answers `--failure-report-self-test`.
4. The test acquires no clipboard, foreground, or cursor, or it is an interactive test behind the lease.
5. `test.ps1` runs the new executable after the existing suites, throws on a nonzero exit, and keeps expected-failure children out of `$LASTEXITCODE`; the validation contract has the gate row.
6. The run that proves it is archived with its receipt, and the report says whether it was a focused pass, a build, or qualification.
