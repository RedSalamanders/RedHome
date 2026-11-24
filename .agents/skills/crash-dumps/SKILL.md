---
name: crash-dumps
description: Record a crash as a local minidump and pending marker from a fault path that allocates nothing, show it at the next start, and prove it with isolated child-process probes, across RedSalamanders C++ applications. Use when installing or changing a crash handler, adding a failure path that must leave a dump, changing dump retention or the restart prompt, or adding a crash probe. Never for uploading anything.
---

# Crash Dumps

Read the target repository's crash contract first; [references/repository-facts.md](references/repository-facts.md) names it, with the handler's files, artifact names, and probe switch. This skill applies in every application; the repository's `AGENTS.md` and `Specs/` win on any conflict. Investigating a dump that already exists is a different task: `RedSalamander` has the repository-local [red-salamander-crash-forensics](../../../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) skill for it.

## Install

- Install the crash handler first, right after the command line is parsed and before any window, COM, UI, or worker thread exists. Initialize every piece of crash-path state there, including the event other faulting threads wait on and the preloaded DbgHelp.
- Initialization returns an `HRESULT` and fails startup when the crash-path state cannot be created; an application never runs without its handler.
- Every fatal path ends in one filter: the unhandled-exception filter, `std::terminate`, the invalid-parameter handler, the pure-call handler, and `SIGABRT`. The filter writes the dump and the marker, then the process exits with the exception code.

## The Fault Path

- **It allocates nothing.** Fixed `wchar_t` buffers, `swprintf_s`, `CreateFileW`, `MiniDumpWriteDump`, and DbgHelp loaded before the fault. A heap corruption is the case it exists for; keep it that way.
- **One dump per crash.** A recursive fault on the dumping thread gives up. Another faulting thread waits on the pre-created event until the dump and marker attempt finishes.
- **No recovery writes.** The fault handler writes the dump and the marker and nothing else: no settings, no document recovery, no log flush that allocates.

## Local Only

Never upload, never open a network connection, never phone home; there is no telemetry. The dump and its marker stay in the application's local crash folder.

## The Next Start

- Dump retention and marker inspection run on an ordinary, healthy start only, never in the fault handler.
- On the next healthy interactive start, consume the pending marker once and show one prompt naming the local dump. Preserve product recovery choices, including RedSalamander's implicated-plugin action. Headless runs leave the user's pending notice intact.
- The agreed adoption target (H-16, D24) keeps each product's newest ten post-adoption dumps and their associated sidecars. Identify the new collection positively, for example by a versioned directory, and preserve all pre-adoption and unrelated evidence. Prune owned pairs on a healthy start. Cover ten and eleven entries, legacy evidence and a repeated restart in an isolated fixture.
- The self-test, screenshots, demos, benchmarks, and every other harness run never touch the user's crash folder: no pruning, no prompt, no dump.

## Probes And Tests

- Nothing in the crash path runs in a harness switch except the crash probe. The probe installs the handler with a directory it is given, in an isolated child process with its own data root, and raises an access violation. `test.ps1` requires a nonzero exit, one dump above zero bytes, and a marker naming it.
- Run the ordinary probe before any window or COM initialization. A worker probe faults from worker threads, overlapping, and still produces one dump and one marker.
- In an AddressSanitizer build the probe raises a custom exception code instead of an access violation, because the sanitizer runtime reports access violations itself and exits before any filter runs. Real ASan detection is a separate check from the crash probe.
- In-process tests cover the writer without an exception, pruning, and the marker; they use the product's acquired test sandbox. A test never installs the handlers in its own process ([test-evidence](../test-evidence/SKILL.md) routes test-process failures away from dialogs instead).
- Verify the dump and pending marker, the ordinary restart behavior, and real ASan detection separately; one passing does not show the others.

## Repository Facts

Crash contracts, handler files, artifact names, crash folders, retention, the next-start prompt, and probe switches for every repository: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Artifacts, retention, and the next-start prompt (register H-16) | RedPrism: `RedPrism-<yyyyMMdd-HHmmss>-<pid>.dmp` and `pending.txt`; ten newest kept; a message box naming the dump and offering its folder. RedTilde: `RedTilde-report-<date>-<time>-<pid>-<16 hex>.dmp`, optional `.record` and `pending.txt`; ten post-adoption dumps, legacy reports retained, and one prompt on the next interactive start. RedXe: `RedXe-<date>-<time>-p<pid>-t<tid>.dmp` and `last_crash.txt`; its spec forbids deleting dumps automatically; a one-shot prompt owned by the titled or fullscreen window. RedSalamander: `RedSalamander-<date>-<time>-p<pid>.dmp`, a `.txt` report, and `last_crash.txt`; no pruning; the next start offers to disable the plugin implicated in the crash. RedMonitor: none | D24 adopts a local dump and pending marker, one next-interactive-start prompt and the newest ten post-adoption dumps with their sidecars. Preserve existing evidence and product recovery actions. |
| Crash handler coverage and contract (register H-24) | RedPrism, RedTilde, RedXe: one filter for the unhandled-exception filter, `std::terminate`, invalid parameter, pure call, and `SIGABRT` (RedXe's `SIGABRT` through `Common/FailureReports.h`). RedSalamander: no `SIGABRT` handler. RedMonitor: no crash handler. Contract: `Specs/Core/Core_CrashHandling.md` in RedPrism and RedXe; inside `Specs/Core/Core_SettingsAndCrashes.md` in RedTilde; none in RedSalamander (its probe is in `Specs/Core/Core_StartupBootstrap.md`) or RedMonitor. DxUi is a library: `Specs/Core/Core_FailureHandling.md` leaves the dump to the host | Every application installs one handler for all five paths and has `Specs/Core/Core_CrashHandling.md`. RedSalamander adds `SIGABRT`; RedMonitor adds the handler; RedTilde and RedSalamander add or split the contract |
| Crash-probe switch (register E-13) | `--crash-test` in RedXe and RedSalamander; `--crash-probe` in RedPrism and RedTilde (RedPrism also `--crash-probe-worker`); none in RedMonitor | One switch name, from the E-13 vocabulary |
