# Shared CI Engine (`../RedSalamanders/.github`)

- **Repository**: `RedSalamanders/.github` (`Policy version: 1`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedSalamanders/.github/AGENTS.md), [Specs/CI.md](../../RedSalamanders/.github/Specs/CI.md), [README.md](../../RedSalamanders/.github/README.md) (or inside any project's synced `.ci-engine/`)

## Pipeline Lifecycle

1. **Compiler-Free PR Gate (`ci.yml` -> `pr.yml`)**:
   - Runs changed-source `clang-format` check, static/tooling validators, CodeQL (`build-mode: none`), and dependency review. Never provisions MSVC or compiles C++.
   - Manual `format.yml` commits formatting fixes to same-repo PR heads via fast-forward push and dispatches fresh checks.
2. **Main Coordinator & `ci-state` Admission (`coordinate.yml` -> `native.yml`)**:
   - Waits for **5 continuous quiet minutes** on `main`, computes cumulative input identity over meaningful Git tree blobs + `.ci/project.json` + engine SHA (prose-only commits reuse prior verdicts without hiding earlier code obligations), and records atomic state on the `ci-state` branch.
3. **Dual-Architecture Release Qualification & Production**:
   - Native `x64` and `ARM64` Release test builds run normal regression suites + active Release failure-detection negative controls (`queue: max`, non-cancelling).
   - **Global AND Gate**: Both architectures must pass before either `ProductionOnly` Release build/package smoke job begins.
4. **Explicit Publication (`publish.yml` — Applications Only)**:
   - `Prepare` -> `Release` (promotes exact qualified ZIP bytes without rebuilding) -> `Winget` (validates schema headers, installs inbox App Installer if needed, verifies real portable installation/aliases/smokeTests and clean uninstall on both architectures, then submits to `microsoft/winget-pkgs`).
5. **Pin Maintenance & Testing**:
   - Update a project's pin from a clean engine checkout via `./Tools/Update-ProjectPin.ps1 -Root ../<Project> -EngineRef <SHA>`.
   - Pin updates regenerate workflow callers and refresh adopted shims from the same engine commit. Product validation exercises the pinned changelog and build-console commands through their existing entry points. [Command contract](../../RedSalamanders/.github/Specs/ProjectCommands.md) · [Adoption and evidence](../Specs/Plans/WIP/Convergence_2026-11-17/DeferredTests.md#tooling-pin-wave--23-november-2026)
   - Callers with an explicit MSBuild summary can require its complete success footer through the shared console module. DxUi uses that mode for the main build, SDK and relocated consumer, with paired-run compiler-log evidence bound to the original source. RedSalamander applies it to the main build and its native build result. [DxUi adoption](../Specs/Plans/WIP/Convergence_2026-11-17/DeferredTests.md#dxui-shared-build-console--25-november-2026) · [RedSalamander adoption](https://github.com/RedSalamanders/RedSalamander/pull/407)
   - The version 2 scope manifest owns suite routing. The runner passes the same merge-base build stamp to build and test. Native reuse also checks a current report with no capability skips. The evidence module can retain a profile's failure output and bind current dumps to exact executable and symbol bytes. [Scoped testing](../../RedSalamanders/.github/Specs/ProjectCommands.md#scoped-testing)
   - The shared toolchain helpers resolve the selected Visual Studio toolset, generate vcpkg overlays, validate manifest arguments and restore complete pinned checkouts. Product adoption keeps the public command parameters, native dependency pins and compatible consumer bootstrap. The hosted MSVC action can use the product's contained installer transport after shared admission and signature verification. [Project command contract](https://github.com/RedSalamanders/.github/blob/7c2f428fa8d49791093bc782db65c7e0a3c97b18/Specs/ProjectCommands.md#shared-native-toolchain-helpers) · [Hosted MSVC contract](https://github.com/RedSalamanders/.github/blob/4b9b7b66ce22c248eed578f22a8d9d82580223c5/Specs/CI.md)
   - Root `AGENTS.md` can adopt the engine's native build guidance block. The block points to the reviewed profile revision and pin updates keep its content synchronized. Product-specific rules follow the closing marker. [Managed build guidance](https://github.com/RedSalamanders/.github/blob/212c80508608eaea80188271df759baa9d4efa01/Specs/ProjectCommands.md#shared-build-guidance)
   - Dependabot pull requests that bump a single `RedSalamanders/.github` workflow caller are notices that the engine moved. They change one `@SHA` without `.ci/project.json`, so adopt the new engine with `Update-ProjectPin.ps1` instead of merging them.
   - The standalone `../RedSalamanders/.github` checkout is only as current as its last fetch. Fetch it before reading engine docs there, or read the copy a product actually runs in `<repo>/.ci-engine/`.
   - Engine behavior tests run against the existing marked root: `./Tests/Test-Engine.ps1 -TestRoot D:/RedSalamander.Perf` (or `Z:/RedSalamander.Perf` where marked).

Return to [Index.md](Index.md).
