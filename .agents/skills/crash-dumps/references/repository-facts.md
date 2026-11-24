# Crash dumps: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md). Artifact names, retention, prompts, and probe switches that differ between repositories are also rows of the skill's `Differences To Converge` table.

## Where each repository records a crash

| Repository | Contract | Handler | Crash folder | Probe |
| --- | --- | --- | --- | --- |
| RedPrism | [Specs/Core/Core_CrashHandling.md](../../../../../RedPrism/Specs/Core/Core_CrashHandling.md) | `Common/CrashDumps.*`; installed in `RedPrism/Main.cpp` | `%LocalAppData%\RedPrism\Crashes` | `--crash-probe <directory>`, `--crash-probe-worker` |
| RedTilde | [Specs/Core/Core_SettingsAndCrashes.md](../../../../../RedTilde/Specs/Core/Core_SettingsAndCrashes.md) | `Common/CrashHandler.cpp`; the next-start check in `RedTilde/Main.cpp` | `Crashes` under the data directory; harness runs use their own `RedTilde-Harness-<pid>` data root under `%TEMP%` | `--crash-probe` |
| RedXe | [Specs/Core/Core_CrashHandling.md](../../../../../RedXe/Specs/Core/Core_CrashHandling.md) | `RedXe/CrashHandler.cpp`; `SIGABRT` through `Common/FailureReports.h` | `%LocalAppData%\RedXe\Crashes` | `--crash-test`, `--crash-test-stack-overflow` |
| RedSalamander | None of its own; the probe is in [Specs/Core/Core_StartupBootstrap.md](../../../../../RedSalamander/Specs/Core/Core_StartupBootstrap.md) | `RedSalamander/CrashHandler.cpp`; the next-start offer in `RedSalamander/CrashQuarantine.cpp` | `%LOCALAPPDATA%\RedSalamander\Crashes` | `--crash-test` |
| RedMonitor | [Core_CrashHandling.md](https://github.com/RedSalamanders/RedMonitor/blob/5555ff99b63a65bdceaabddd483b3a23b8641403/Specs/Core/Core_CrashHandling.md) | src/CrashReports.cpp | %LOCALAPPDATA%\RedMonitor\Crashes | --crash-probe and --crash-probe-worker |
| DxUi | [Specs/Core/Core_FailureHandling.md](../../../../../DxUi/Specs/Core/Core_FailureHandling.md): the library routes an unexpected failure to the host, which owns the dump | `src/Foundation/Failure.cpp`; the sample host `Samples/Shared/FailureHost.cpp`; `RedTilde`'s host adapter is `Common/DxUiFailureHost.cpp` | The host's | The host's |

## RedPrism

- `CrashDumps::InstallCrashHandler(directory)` installs the exception, terminate, invalid-parameter, pure-call and `SIGABRT` handlers before startup work. One filter writes a `RedPrism-report-*.dmp` and publishes `pending.txt` in the local crash directory. The process exits with the failure code. [RedPrism #70](https://github.com/RedSalamanders/RedPrism/pull/70)
- The crash path uses fixed `wchar_t[kPathCapacity]` buffers, `swprintf_s`, `CreateFileW`, `MiniDumpWriteDump`.
- A healthy ordinary start claims the pending marker once and offers to select the local dump in Explorer.
- `--crash-probe <directory>` installs the handler with that directory and raises an access violation; keep it before any window or COM initialization. The companion `--crash-probe-worker` creates two private-pool threads (and their implicit MTA cookie), verifies the per-thread terminate handler and overlapping faults, and still produces one dump/marker. In an AddressSanitizer build the probe raises `0xE0000005` rather than an access violation.
- Ordinary startup retains the newest ten owned dumps and preserves legacy reports. Harnesses use an isolated directory under `.build/crash-probe-artifacts`.
- In-process tests (`HostTests` `crash.*`) cover the writer without an exception, pruning and the marker.

## RedTilde

- Dumps are `RedTilde-report-<yyyyMMdd>-<HHmmss>-<pid>-<16 hex digits>.dmp`. Protocol-2 reports add a `.record` sidecar. The `pending.txt` marker names the dump and the next healthy interactive launch claims it once. Retention keeps the newest ten new dumps by write time and removes their previous pairs. Legacy dumps and unrelated files remain intact. [RedTilde #182](https://github.com/RedSalamanders/RedTilde/pull/182)
- The next start reads `pending.txt` when it is not headless, then removes it.
- Initialize crash-path state before UI/workers; use fixed buffers and preloaded DbgHelp at a fault. Keep dump retention/marker inspection in healthy startup. Never upload automatically or attempt recovery writes in the fault handler. Crash probes run in isolated child processes/data roots.
- Verify the dump and pending marker, ordinary restart behavior and real ASan detection separately (and invalid settings, which the settings rules cover).

## RedXe

- A completed `RedXe-report-*.dmp` and its matching `RedXe-report-*.txt` call-stack report stay in the local store. `last_crash.txt` records the dump path. The healthy startup retains the newest ten owned pairs and preserves legacy reports. [RedXe #143](https://github.com/RedSalamanders/RedXe/pull/143)
- DbgHelp loads at handler installation, and `SetThreadStackGuarantee` reserves space for a stack-overflow capture.
- The next ordinary start claims the marker once before the prompt. The titled and fullscreen windows own their prompt; the dock uses its separate unowned notice.
- The HostSmoke suite uses isolated fatal-process and stack-overflow children. Probe directories and raw dump retention stay under the repository's `.build` and outside CI uploads.

## RedMonitor

- The viewer preloads system DbgHelp before UI and starts one local writer for all fatal paths. The producer SDK stays independent.
- Each successful dump records a UTF-16 pending filename. The next ordinary launch claims the marker once and shows the local report path. Retention keeps the newest ten owned dumps. Crash probes use an isolated repository-local store excluded from CI artifact uploads. [RedMonitor #123](https://github.com/RedSalamanders/RedMonitor/pull/123)

## RedSalamander

- Dumps are `RedSalamander-<yyyyMMdd>-<HHmmss>-p<pid>.dmp`, with a `.txt` report beside each and the marker `last_crash.txt`. No pruning.
- The next start (`CrashQuarantine::OfferPluginDisableIfPreviousCrashDetected`) offers to disable the plugin the crash implicates.
- Investigating dumps, sidecar stacks, fatal dialogs, and hangs: the repository-local [red-salamander-crash-forensics](../../../../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) skill.
