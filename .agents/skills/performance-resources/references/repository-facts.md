# Repository facts: `performance-resources`

Product-specific facts that the common rules in [SKILL.md](../SKILL.md) do not cover. Unlinked paths are relative to the named repository's root. Each repository's `AGENTS.md` and `Specs/` win on any conflict.

Repository-local skill for RedSalamander: [perf-validation](../../../../../RedSalamander/AGENTS.md#skills-reference) (mandatory perf-first workflow).

| Repository | Fact | Where it is defined | Kept because |
| --- | --- | --- | --- |
| DxUi | Contract and rules: read [the owning contract](../../../../../DxUi/Specs/Core/Core_PerformanceAndResources.md) and [AGENTS.md](../../../../../DxUi/AGENTS.md). | `Specs/Core/Core_PerformanceAndResources.md`, `AGENTS.md` | Repository entry points. |
| DxUi | Measure dirty preparation separately from composition. | `Specs/Core/Core_PerformanceAndResources.md` | Library measurement split (see Differences To Converge: per-phase measurement). |
| DxUi | Every `test.ps1` run reports complex-UI FPS/memory; the paired baseline uses `performance-paired.ps1`. | `AGENTS.md`, `performance-paired.ps1` | Product script. |
| DxUi | A pull request that changes what the benchmark measures also runs the hosted paired gate. Its check fails for a confirmed degradation or an inconclusive run: repeat it or measure on a quiet machine before asking for advice, and never rebaseline. | "Hosted paired gate" in `Specs/Core/Core_PerformanceAndResources.md`; `.github/workflows/benchmark.yml` | Only repository with a hosted paired gate. |
| DxUi | Validate changed guidance with `validate-skills.ps1` and `validate-specs.ps1`. For source or build work run the affected `test.ps1` configurations and the additional validation the contract names. | `validate-skills.ps1`, `validate-specs.ps1`, `test.ps1` | Product scripts. |
| DxUi | Supported capabilities are recorded in `capabilities.json`; library tests do not replace consumer product qualification or deferred native-platform/IME/AT coverage. | `capabilities.json` | Library scope. |
| RedPrism | Read `Specs/Core/Core_PerformanceAndResources.md` before material architecture or rendering changes. Rendering changes keep the WARP `--self-test` path green. | `Specs/Core/Core_PerformanceAndResources.md` | Product test gate. |
| RedXe | Launcher icon textures, launch-animation `RequestFrame`, and forbidding extract/decode in `Render` are owned by `Specs/Core/Core_PerformanceAndResources.md` and `Specs/Plugins/Plugins_API.md`. | Both specs | Plugin and launcher product facts. |
| RedXe | Page pan/settle and raise/dismiss settle are presentation-paced motion; settled overlay chrome and close hover are not. | `Specs/Core/Core_PerformanceAndResources.md` | Product UI behavior. |
| RedXe | The JSONL log writer is one event-blocked thread with a 32×1024 ring; `IRedXeHost::Log` must not allocate, wait on disk, or emit per-frame success. The writer uses UTC-dated files and retention, not a 1 MiB rotate. | `Specs/Core/Core_PerformanceAndResources.md` | Product logging design. |
| RedXe | Rendering changes keep the WARP smoke test green and verify upload/draw counters when those counters are part of the contract. `measure-runtime.ps1` is the Release x64 receipt collector. | `Specs/Core/Core_PerformanceAndResources.md`, `measure-runtime.ps1` | Product test gate and script. |
| RedTilde | Paired runs use `performance-paired.ps1`. | [Core_PerformanceAndResources.md](../../../../../RedTilde/Specs/Core/Core_PerformanceAndResources.md) and `Specs/Testing/Testing_Performance.md` | Product runner and performance scenarios. |
| RedMonitor | Release performance uses paired, alternating baseline and candidate runs on the same fixture and machine. | [Core_PerformanceAndResources.md](../../../../../RedMonitor/Specs/Core/Core_PerformanceAndResources.md) and `Specs/Testing/Testing_Validation.md` | Product measurement and validation. |
| RedSalamander | Performance work uses archived selftests under `Specs/TestRuns/` and the repository-local [perf-validation](../../../../../RedSalamander/AGENTS.md#skills-reference) skill. | `AGENTS.md` ("Performance Validation is Mandatory"), `Specs/Testing/Testing_PerformanceValidation.md` | Product workflow. |
