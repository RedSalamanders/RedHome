# Tests and evidence: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md) and [patterns.md](patterns.md). Switch names, entry points, and evidence folders that differ between repositories are also rows of the skill's `Differences To Converge` table.

## Where each repository states its gates

| Repository | Validation contract | Run evidence | Evidence folder | Root test entry point |
| --- | --- | --- | --- | --- |
| RedPrism | [Specs/Testing/Testing_Validation.md](../../../../../RedPrism/Specs/Testing/Testing_Validation.md) | [Specs/Testing/Testing_RunEvidence.md](../../../../../RedPrism/Specs/Testing/Testing_RunEvidence.md); benchmarks in [Testing_Benchmarks.md](../../../../../RedPrism/Specs/Testing/Testing_Benchmarks.md) | `Specs/TestRuns/`, `Measurements/` | `test.ps1` (all nine suites), `-Suites`, `-Full` |
| RedTilde | [Specs/Testing/Testing_Validation.md](../../../../../RedTilde/Specs/Testing/Testing_Validation.md); performance in [Testing_Performance.md](../../../../../RedTilde/Specs/Testing/Testing_Performance.md) | [Specs/Testing/Testing_RunEvidence.md](../../../../../RedTilde/Specs/Testing/Testing_RunEvidence.md) | `Measurements/` | `test.ps1` (`Core`), `-Suite`, `-Suites`, `-Full`; `test-interactive.ps1`; `performance-paired.ps1` |
| RedMonitor | [Specs/Testing/Testing_Validation.md](../../../../../RedMonitor/Specs/Testing/Testing_Validation.md), which also holds its receipt rules | None of its own | `Measurements/` | `test.ps1` (everything), `-IncludeLiveEtw` |
| RedSalamander | [Specs/Testing/Testing_PerformanceValidation.md](../../../../../RedSalamander/Specs/Testing/Testing_PerformanceValidation.md), [Testing_SelfTests.md](../../../../../RedSalamander/Specs/Testing/Testing_SelfTests.md) | [Specs/Testing/Testing_ValidationEvidence.md](../../../../../RedSalamander/Specs/Testing/Testing_ValidationEvidence.md), [Specs/TestRuns/README.md](../../../../../RedSalamander/Specs/TestRuns/README.md) | `Specs/TestRuns/`, `Measurements/` | No root `test.ps1`: `Tools/Run-AllTests.ps1`, `Test-Changes.ps1` |
| RedXe | The owning domain spec of the change (its `AGENTS.md`, "Before declaring a change complete") | [Specs/Build/Build_TestRunEvidence.md](../../../../../RedXe/Specs/Build/Build_TestRunEvidence.md) | `Measurements/` | `test.ps1` (affected suites), `-Full`; `measure-runtime.ps1`, `measure-av-views.ps1` |
| DxUi | [Specs/Testing/Testing_Validation.md](../../../../../DxUi/Specs/Testing/Testing_Validation.md) | [Specs/Testing/Testing_RunEvidence.md](../../../../../DxUi/Specs/Testing/Testing_RunEvidence.md) | `Measurements/` | `test.ps1`, `-Interactive`, `-ParallelSuites`; `Test-PrePush.ps1`; `performance-paired.ps1` and the hosted `benchmark.yml` |

## Failure reports and keyboard state

| Repository | Fact | Where it is defined | Kept because |
| --- | --- | --- | --- |
| RedPrism | Every suite's `wmain` starts with `RedPrismTestFailureReports::RouteAwayFromDialogs()`, so a failed CRT or STL check ends the run with its report and exit code 3. A new suite answers `--failure-report-self-test` and is added to the list of suites in `Tests/BuildProcessTests/FailureReportTests.ps1`, which runs the switch of each one. | `Tests/Support/Support.Tests.FailureReports.h` | Helper and test list are RedPrism's |
| RedPrism | The self-test runs on a keyboard of its own: input code reads modifiers with `KeyboardState::Held` / `Read`, never `GetKeyState` / `GetKeyboardState`, and self-test drivers hold keys with `KeyboardState::Write` (`HandleAccelerator` does). | `RedPrism/KeyboardState.h` | Only RedPrism has the type (register H-23) |
| RedXe | `RedXeFailureReports::RouteAwayFromDialogs`; `test.ps1` runs `--failure-report-self-test` | `Common/FailureReports.h` | Helper name |
| DxUi | `DxUiTestFailureReports::RouteAwayFromDialogs`; suites answer `--failure-report-self-test` | `Tests/Support/Support.Tests.FailureReports.h` | Helper name |
| RedSalamander, RedMonitor | `RedSalamander::TestSupport::RouteFailureReportsAwayFromDialogs`, the same file in both, modeled on DxUi's. RedSalamander runs `--failure-report-self-test` from `Tools/Tests/FailureReportRouting.Tests.ps1`; RedMonitor has no such switch (register H-22) | `Tests/TestSupport/TestSupport.Tests.FailureReports.h` | Helper name |
| RedTilde | No test-process routing; the application's crash handler sets its own handlers | `Common/CrashHandler.cpp` | Register H-22 |

## RedPrism

Suites:

| Executable | Scope | Notes |
| --- | --- | --- |
| `HostTests` | Pure host functions, worker/scheduler state and lifetime, DirectWrite glyph presence, STRINGTABLE of `RedPrism.exe` | Scheduler gates may create a message-only HWND; no visible window or device. `--asan-probe` is the sanitizer probe |
| `DocumentTests` | `Common/Document.*`, `DocumentHistory`, `TransformEdit`, `Selection` (Clipper2), `BrushStroke` (sparse rasters, the CPU kernel), `Heal`, `ImageFilters`, `WarpStroke` | CPU only |
| `IoTests` | `ProjectStore`, `ImageCodecs` | Needs COM (`CoInitializeEx`), writes under `%TEMP%\RedPrism.IoTests` |
| `CompositionTests` | `CanvasRenderer`, `CanvasViewport`, `GpuBrushCoverage` (the compute brush against the CPU kernel), sparse upload and stroke preview | Creates its own WARP device; reads pixels back |
| `RedPrism.exe --self-test --warp` | Window + swap chain + chrome + composition lifetime | Hidden; exit 0 only when every assertion holds |
| `RedPrism.exe --screenshot` | Harness captures for docs and specs | `Common/WindowCapture.cpp`; never Computer Use |
| `RedPrism.exe --bench brush` | The legacy 4K brush benchmark on the selected device (`--warp` for WARP) | Prints `BRUSH BENCH` lines; record them under `Specs/TestRuns/`, never as a gate |

Product rules:

- Assertions are `Expect(condition, "suite.case")`. On a golden failure print the actual values (`PrintPixels`).
- Goldens are independent numeric expectations: the repository-local [numeric-goldens](../../../../../RedPrism/.agents/skills/numeric-goldens/SKILL.md) skill. Keep existing legacy goldens unchanged.
- GPU tests use 2×2 documents with `LayerSampling::Nearest` unless the case is about sampling; `Harness::Render` invalidates, composes and reads back BGRA rows.
- Fixture manifests are hand-written JSON checked in under `Tests/IoTests/Fixtures/`; the PNG assets are generated by the test (`EncodePngFile`). Remove stale files before writing (`std::filesystem::remove`). `MinimalManifest(version, extraLayerFields, extraRootFields)` injects overrides first so yyjson's first-key-wins lookup sees them.
- Negative cases assert the exact `ProjectIoStatus` / `ImageCodecStatus` / `DocumentStatus`.
- Brush goldens compare the two coverage engines, sparse and dense sampling, and stroke against source-over coverage within a named tolerance (2/255) rather than against fixed pixels; "never materialized" is asserted with `Raster::IsMaterialized()` after commit, thumbnail, display and the next stroke.
- ASan Debug: parser and tile code must pass there before a phase closes.

## RedTilde

- Native test filenames use `Scope.Tests.Behavior.cpp/.h` (its validation contract).
- Capture: `--capture --scenario`; crash probe: `--crash-probe`; interactive captures and focus tests: `test-interactive.ps1`, under the interactive desktop lease.
- For S5, follow [the performance contract](../../../../../RedTilde/Specs/Testing/Testing_Performance.md) and use `performance-paired.ps1`.

## RedMonitor

Choose the needed scope:

```powershell
./validate.ps1
./Tests/Tooling.Tests.ps1
./test.ps1 -Platform x64 -Configuration Debug
./test.ps1 -Platform x64 -Configuration Debug -IncludeLiveEtw
./Test-Changes.ps1 -Explain -Mode Full
```

- The first two commands check tooling without a native build.
- Default `test.ps1` builds and runs console cases; the explicit live-ETW gate adds the real transport roundtrip and treats permission denial as failure.
- `-SkipBuild` requires an exact successful source/profile/artifact receipt.
- Full/PrePush also require the other profiles and installation controls named by `Test-Changes.ps1`.

## RedSalamander

The repository-local [perf-validation](../../../../../RedSalamander/.github/skills/perf-validation/SKILL.md) skill is the source of the performance workflow in [SKILL.md](../SKILL.md#performance-evidence) and of the shared-process rules in [patterns.md](patterns.md#shared-process-suites).

- **Deterministic validation**: prefer `--commands-selftest` for real UI/window paths, `--compare-selftest` for Compare/search engine paths, and `--fileops-selftest` for file-operation paths.
- **Protected scenarios**, for example: warm Find Files progress storm; cold folder open with icon churn; FileOps pre-calc cancel; Compare Directories content-progress queue churn.
- **Metric prefixes**: `find.ui.*`, `compare.ui.*`, `FileOps.*`, `render.*`, `icons.*`.
- **Archive**: a new folder under `Specs/TestRuns/<MachineHash>/<Area>/...`; keep `results.json`, `trace.txt`, and `perf_metrics.jsonl` intact. Curation, size limits, and `Tools\Test-TestRunArchive.ps1` are in [Specs/TestRuns/README.md](../../../../../RedSalamander/Specs/TestRuns/README.md).

### Operation Startrail planning scenarios

Changes to affected-set planning, evidence lookup, or resume must measure `validation.plan.warm_explain_ms`, `validation.plan.cold_snapshot_ms`, and the controlled `validation.plan.fileops_resume_avoided_ms` comparison. Emit component timings for snapshot acquisition, hashing, plan construction, evidence verification, serialization, and runner launch. Archive same-machine evidence under `Specs/TestRuns/<MachineHash>/Validation/<RunId>/`; treat cross-machine comparisons as directional and never use estimated savings as a trust decision.

Report Git discovery, content hashing, canonicalization, impact matching, schema validation, evidence lookup, receipt-closure binding, and entry fingerprints separately. If Commands remains a monolithic executable, archive `validation.plan.fileops_resume_avoided_ms` as blocked with zero Full avoidance; a focused family process is not an independently reusable payload. Use an existing same-machine Validation archive as baseline only when the fixture/profile still match.

## RedXe

- Before declaring a change complete: build the affected configuration, run `test.ps1 -Full` (or `Test-Changes.ps1 -Mode PrePush`), and satisfy the validation contract in the owning domain spec. Rendering changes keep the WARP smoke test green. `test.ps1 -Full` also validates crash capture in an isolated child process (register A-18 records the conflict with scoped testing).
- Capture: `--screenshot`; crash probe: `--crash-test`; hidden production `--self-test`; `--warp`.

## DxUi

- Interactive suites: `test.ps1 -Interactive` (and `-InteractiveAutoStart`, only after the person at the desktop agrees to automatic start and the time).
- `-SkipBuild` requires the current build attestation and the complete native test-source/artifact receipt; a missing or stale identity fails closed.
