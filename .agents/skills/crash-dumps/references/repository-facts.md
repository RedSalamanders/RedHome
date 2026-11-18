# Crash dumps: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md). Artifact names, retention, prompts, and probe switches that differ between repositories are also rows of the skill's `Differences To Converge` table.

## Where each repository records a crash

| Repository | Contract | Handler | Crash folder | Probe |
| --- | --- | --- | --- | --- |
| RedPrism | [Specs/Core/Core_CrashHandling.md](../../../../../RedPrism/Specs/Core/Core_CrashHandling.md) | `Common/CrashDumps.*`; installed in `RedPrism/Main.cpp` | `%LocalAppData%\RedPrism\Crashes` | `--crash-probe <directory>`, `--crash-probe-worker` |
| RedTilde | [Specs/Core/Core_SettingsAndCrashes.md](../../../../../RedTilde/Specs/Core/Core_SettingsAndCrashes.md) | `Common/CrashHandler.cpp`; the next-start check in `RedTilde/Main.cpp` | `Crashes` under the data directory; harness runs use their own `RedTilde-Harness-<pid>` data root under `%TEMP%` | `--crash-probe` |
| RedXe | [Specs/Core/Core_CrashHandling.md](../../../../../RedXe/Specs/Core/Core_CrashHandling.md) | `RedXe/CrashHandler.cpp`; `SIGABRT` through `Common/FailureReports.h` | `%LocalAppData%\RedXe\Crashes` | `--crash-test`, `--crash-test-stack-overflow` |
| RedSalamander | None of its own; the probe is in [Specs/Core/Core_StartupBootstrap.md](../../../../../RedSalamander/Specs/Core/Core_StartupBootstrap.md) | `RedSalamander/CrashHandler.cpp`; the next-start offer in `RedSalamander/CrashQuarantine.cpp` | `%LOCALAPPDATA%\RedSalamander\Crashes` | `--crash-test` |
| RedMonitor | None | None | None | None |
| DxUi | [Specs/Core/Core_FailureHandling.md](../../../../../DxUi/Specs/Core/Core_FailureHandling.md): the library routes an unexpected failure to the host, which owns the dump | `src/Foundation/Failure.cpp`; the sample host `Samples/Shared/FailureHost.cpp`; `RedTilde`'s host adapter is `Common/DxUiFailureHost.cpp` | The host's | The host's |

## RedPrism

- `CrashDumps::InstallCrashHandler(directory)` is the first thing `RunApplication` does after parsing the command line. The unhandled-exception filter, `std::terminate`, the invalid-parameter handler, the pure-call handler and `SIGABRT` all end in one filter that writes `RedPrism-<yyyyMMdd-HHmmss>-<pid>.dmp` and `pending.txt` into `%LocalAppData%\RedPrism\Crashes`, then the process exits with the exception code (`0xE000000n` for the CRT paths).
- The crash path uses fixed `wchar_t[kPathCapacity]` buffers, `swprintf_s`, `CreateFileW`, `MiniDumpWriteDump`.
- The next start shows a message box naming the dump and offering its folder.
- `--crash-probe <directory>` installs the handler with that directory and raises an access violation; keep it before any window or COM initialization. The companion `--crash-probe-worker` creates two private-pool threads (and their implicit MTA cookie), verifies the per-thread terminate handler and overlapping faults, and still produces one dump/marker. In an AddressSanitizer build the probe raises `0xE0000005` rather than an access violation.
- Pruning (`PruneDumps`, ten newest) and the prompt run on an ordinary start only.
- In-process tests (`HostTests` `crash.*`) cover the writer without an exception, pruning and the marker.

## RedTilde

- Dumps are `RedTilde-<yyyyMMdd>-<HHmmss>-<pid>-<16 hex digits>.dmp`, each with a `.record` sidecar, and the marker is `pending.txt`. Retention keeps the ten newest dumps and removes the sidecar with its dump.
- The next start reads `pending.txt` when it is not headless, then removes it.
- Initialize crash-path state before UI/workers; use fixed buffers and preloaded DbgHelp at a fault. Keep dump retention/marker inspection in healthy startup. Never upload automatically or attempt recovery writes in the fault handler. Crash probes run in isolated child processes/data roots.
- Verify the dump and pending marker, ordinary restart behavior and real ASan detection separately (and invalid settings, which the settings rules cover).

## RedXe

- Dumps are `RedXe-<yyyyMMdd>-<HHmmss>-p<pid>-t<tid>.dmp`; the marker `last_crash.txt` holds the dump path. DbgHelp is loaded when the handler is installed.
- Its contract forbids uploading, transmitting, or automatically deleting dumps, and asks for `SetThreadStackGuarantee` so a real stack overflow keeps room for a bounded capture.
- The next start removes the marker before a one-shot prompt that identifies the saved dump. The titled and fullscreen windows own the prompt; a dock does not.
- `test.ps1 -Full` validates crash capture by launching an isolated child process; it requires no desktop automation and must not write to the user's normal crash directory.

## RedSalamander

- Dumps are `RedSalamander-<yyyyMMdd>-<HHmmss>-p<pid>.dmp`, with a `.txt` report beside each and the marker `last_crash.txt`. No pruning.
- The next start (`CrashQuarantine::OfferPluginDisableIfPreviousCrashDetected`) offers to disable the plugin the crash implicates.
- Investigating dumps, sidecar stacks, fatal dialogs, and hangs: the repository-local [red-salamander-crash-forensics](../../../../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) skill.
