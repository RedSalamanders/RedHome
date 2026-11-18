# Build, restore, and package: repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md). The command blocks below are each repository's own today; the skill's `Differences To Converge` table names the register rows that make them one table.

## Contracts and entry points

| Repository | Build contract | Build | Restore | Package | Banner and log |
| --- | --- | --- | --- | --- | --- |
| RedSalamander | [Specs/Build/Build_Toolchain.md](../../../../../RedSalamander/Specs/Build/Build_Toolchain.md) | `build.ps1` | MSBuild manifest mode, `vcpkg-install.ps1`, `Tools/Restore-DxUi.ps1` | `build.ps1 -Zip`, `Installer/zip/build-zip.ps1` (`.build\AppPackages`) | `.build\logs\msbuild-*.log` |
| RedXe | [Specs/Build/Build_Process.md](../../../../../RedXe/Specs/Build/Build_Process.md), [Build_Packaging.md](../../../../../RedXe/Specs/Build/Build_Packaging.md) | `build.ps1` | `vcpkg-install.ps1`, `restore-dxui.ps1` | `package.ps1`, `winget-manifest.ps1` (`.build/packages`) | The RedXe build-signal banner; `.build/logs/` |
| RedPrism | [Specs/Build/Build_Toolchain.md](../../../../../RedPrism/Specs/Build/Build_Toolchain.md), [Build_Packaging.md](../../../../../RedPrism/Specs/Build/Build_Packaging.md) | `build.ps1` | `vcpkg-install.ps1`, `restore-dxui.ps1` | `package.ps1` (`.build/packages/`) | The framed pixel-art banner of `Build/BuildPresentation.psm1` |
| RedTilde | [Specs/Build/Build_Toolchain.md](../../../../../RedTilde/Specs/Build/Build_Toolchain.md) | `build.ps1` | `restore-dxui.ps1` (no vcpkg) | `package.ps1` (`.build/package`) | Build logs kept apart from test receipts |
| RedMonitor | [Specs/Build/Build_Consumption.md](../../../../../RedMonitor/Specs/Build/Build_Consumption.md) | `build.ps1` | `restore.ps1`, `vcpkg-install.ps1`, `restore-dxui.ps1` | `package.ps1` (`.build/packages`) | |
| DxUi | [Specs/Build/Build_ToolchainAndConsumption.md](../../../../../DxUi/Specs/Build/Build_ToolchainAndConsumption.md) | `build.ps1` (the single `DxUi.lib`) | `vcpkg-install.ps1` | None: a library with no release package | |

## RedSalamander

Quick build commands:

```powershell
# Build entire solution (default)
.\build.ps1

# Build in Release configuration
.\build.ps1 -Configuration Release

# Build specific project
.\build.ps1 -ProjectName RedSalamander
.\build.ps1 -ProjectName Common

# Clean and rebuild
.\build.ps1 -Clean
.\build.ps1 -Rebuild

# Bound worker processes when the host cannot sustain MSBuild's default
.\build.ps1 -Rebuild -MaxCpuCount 4
```

| Parameter | Values | Default |
|-----------|--------|---------|
| `-Configuration` | Debug, Release, ASan Debug | Debug |
| `-Platform` | x64, ARM64 | x64 |
| `-ProjectName` | RedSalamander, Common, FileSystem | All projects |
| `-Clean` | Switch | False |
| `-Rebuild` | Switch | False |
| `-MaxCpuCount` | 0-256 | 0 (MSBuild default) |

- **Output locations**: Debug: `.build\x64\Debug\*.exe, *.dll`; Release: `.build\x64\Release\*.exe, *.dll`; Debug (ARM64): `.build\ARM64\Debug\*.exe, *.dll`; Release (ARM64): `.build\ARM64\Release\*.exe, *.dll`.
- **Build order**: **Common** (shared library, no dependencies), **FileSystem** (plugin, no dependencies), then **RedSalamander** (main app; depends on Common and the solution's plugins/search service).
- **RedMonitor is independent.** Ordinary builds verify the vendored Client.h, license and immutable lock locally; they never clone/build/stage a viewer. Use Tools/Update-RedMonitorClient.ps1 only for an explicit reviewed header update. Debug may launch an installed production Release helper; the consumer package contains only the client notice. See Specs/Core/Core_RedSalamanderMonitor.md.
- **Visual Studio build**: open `RedSalamander.sln` in the toolchain that `Specs/Build/Build_Toolchain.md` requires, select the configuration/platform declared by the current solution and its qualification contract, then Build → Build Solution (Ctrl+Shift+B).
- **vcpkg**: dependencies are in `vcpkg.json`; the executable checkout is independently pinned by `vcpkg-tool.json`, and local installs and CI must validate the exact Git commit. Do not use global `vcpkg integrate install`. Keep both pin files intentional and reviewed.
- **Dependencies**: **WIL** (RAII wrappers), **yyjson** (JSON/JSON5), **DirectX** (D2D, D3D11, DXGI). CI ARM64 builds install `Microsoft.VisualStudio.Component.VC.Tools.ARM64` with the Visual Studio 2026 VC++ workload and verify `Hostx64\arm64\cl.exe` before building.

### Runtime dependency staging

- Root `RuntimeDependencies.props` is the canonical list of app-local plugin runtime DLLs
- `Directory.Build.targets` owns required-file failure, copying, and stale-output removal
- Do not add plugin-local `PostBuildEvent` or `xcopy` dependency batches; extend the canonical manifest
- `Installer/zip/build-zip.ps1` consumes the same manifest and runs a fresh-extraction app/plugin smoke
- See `Specs/Installer/Installer_PortableZip.md`

### Tooling changes

Read `Specs/Testing/Testing_ToolingGovernance.md`, `Tools/README.md`, and `.github/skills/tooling-governance/SKILL.md` (the repository-local [tooling-governance](../../../../../RedSalamander/.github/skills/tooling-governance/SKILL.md) skill) before changing a build script or helper. Keep stable build entrypoints at the Tools root, place reusable implementation in explicit modules, update `Tools/tool-inventory.json`, and prove that workflow cache keys include every imported module, patch, notice, schema, and version input that can change produced artifacts.

### Operation Startrail build evidence

Build evidence Phase 1 is active. `build.ps1` invalidates the mutable receipt pointer before artifact mutation, forces `Rebuild` for first/incompatible attestation, checks the source snapshot before final publication, and writes content-addressed targeted/full receipts only after all selected build/package operations succeed. Do not add an output or post-build staging step without adding it to the attested closure or re-attesting it before the final banner.

`Run-AllTests.ps1 -SkipBuild` is receipt-gated: it requires a test-enabled full-solution receipt for the exact checkout/profile and verifies every artifact digest. CI/nightly cross-job handoff must publish and verify the portable same-workflow attestation using the reusable workflow's attestation/toolchain outputs, then rebind paths locally. Never accept a local receipt's absolute diagnostic paths as portable authority. Fresh Full establishes complete execution/qualification where required by the owning acceptance contract; editing and PrePush follow scoped testing without duplicating equivalent obligations. Exact Resume and Affected never weaken receipt verification or turn pending/non-equivalent coverage into a complete pass.

An artifact-writer re-attestation is a build, not only a digest refresh. Apply the same suite build environment used for the initial build and restore the caller environment afterward. Full specifically requires `RSBuildEnableTests=true` even when invoked with `-SkipBuild`; otherwise a valid receipt may bind a Monitor binary that cannot run the declared Full selftest entry.

Build source identity now uses the canonical Phase 3 workspace snapshot: committed base, index, and worktree bytes are distinct, dirty/untracked/delete/rename state is bound, and mtime-only or generated evidence changes do not invalidate it. A validation entry fingerprint consumes the verified receipt ID, declared outputs/runtime closure, and current artifact epoch; it never substitutes for receipt compatibility. Compute the complete receipt/runtime-closure binding digest once per run and bind that immutable digest into every entry fingerprint; do not recanonicalize the full receipt per entry.

Validation examples:

```powershell
.\Tools\Run-AllTests.ps1 -Suite Full -ValidationMode Fresh -BuildNumber 1
.\Tools\Run-AllTests.ps1 -Suite Full -ValidationMode Resume -ResumeFrom <run-id> -SkipBuild
.\Tools\Run-AllTests.ps1 -Suite Full -ValidationMode Affected -ImpactBase origin/master
```

The executable build summary is printed exactly once after all selected build/package work and receipt publication. Every `Run:` line must remain copy/paste executable.

### Shared MSBuild defaults

- Shared first-party VC++ defaults live in `Directory.Build.props` and `Directory.Build.targets`
- Family-level overrides live in `Plugins/Directory.Build.props`, `Tests/Directory.Build.props`, and `PoC/Directory.Build.props`
- Prefer changing shared toolchain, output-path, versioning, and common compile defaults in those shared files instead of copying edits across individual `.vcxproj` files
- First-party projects default to `LanguageStandard=stdcpplatest` and `WarningLevel=EnableAllWarnings`
- First-party VC++ projects also default to `/FS`, so solution-targeted builds remain stable under the repo-wide `/MP` compiler settings
- Plugin DLLs and console test executables inherit shared external-header, include-path, and subsystem defaults from their family-level props files
- First-party `Application` and `DynamicLibrary` projects default to repo version stamping through `Directory.Build.targets` unless they explicitly opt out
- First-party proof-of-concept projects use the same late `/Wall`, `/WX`-disabled, zero-warning policy as other native projects. Keep any reviewed PoC exception local and documented; earlier property defaults do not override the common final policy.

### Build script features

- Discovers the supported MSBuild/toolchain as specified by `Specs/Build/Build_Toolchain.md`
- Builds entire solution when no ProjectName specified
- Resolves most `-ProjectName` builds to the target `.vcxproj` directly; `RedSalamander` stays on the solution build graph so the solution can also build its bundled plugin/search-service outputs (`Plugins\*.dll`, `RedSalamanderSearchService.exe`)
- Reuses the saved local beta build number by default, so ordinary repeated local builds stay incremental instead of forcing a fresh version stamp on every invocation
- Resolve-and-persist version state only through `Resolve-RSVersionContext`, which owns the exclusive repository-local version-state file lease and atomic counter/context publication. The file lease coordinates Windows sessions and checkout aliases and is released by process termination. Use pure `New-RSVersionContext` when a caller already has an explicit build number. `Read-RSVersionContext` is the locked, validated diagnostics-only reader; raw unlocked lock/read/save primitives are private, and the version lease never spans MSBuild or another native child.
- Plain consoles that support child-console output keep MSBuild's native console output/color while still capturing a `.build\logs\msbuild-*.log` file; Windows Terminal and redirected hosts such as Codex use the replay helper so build progress stays visible, with replayed errors/warnings/project completion colorized in the console
- MSBuild launches always use the sanitized environment helper so duplicate `Path`/`PATH` process-environment aliases are collapsed to canonical `Path` before MSBuild starts compiler tool tasks
- Artifact operations are exclusive by normalized repository root plus `Platform|Configuration`. Builds/tests for the same output profile serialize; disjoint profile artifact lifecycles and worktrees do not block one another merely because they are RedSalamander operations. `target` and `suite` are diagnostics, not lock partitions. Every production caller must pass both profile fields; the unscoped fallback is compatibility/test infrastructure only.
- `Run-AllTests.ps1` may execute only the canonical `RedSalamander.exe` beneath its selected repository/platform/configuration output. Its `-ExePath` parameter is compatibility syntax for explicitly naming that same normalized path, not permission to run a foreign or differently scoped artifact; mismatches fail before lock acquisition.
- MSBuild and direct vcpkg installation also hold the narrower repository+platform `shared-dependency` lock because Debug, Release, and ASan share `.build\vcpkg_installed\<triplet>`. It covers only dependency-capable phases, matches residual tools regardless of configuration, and never blocks the other platform or ordinary test execution. Multi-triplet installation acquires scopes in stable x64-then-ARM64 order. Explicit custom triplets must begin with `x64-` or `arm64-`; reject every architecture without a reviewed platform-lock mapping before mutating staging or install state. Apply the same mapping to path-qualified residual `vcpkg`, compiler, and linker evidence for custom installed/staging paths; a process name, foreign checkout, or opposite platform never suffices.
- The Ghostty runtime's `.build\TerminalEngine` state is shared across configurations and platforms within one repository, so its state mutex is derived only from normalized repository root; same-repository x64/ARM64 operations serialize, while different worktrees do not. A validated cache hit never takes the session-wide `R:` lease. Only an actual rebuild holds that lease, narrowly around mapping, contained overlay/build work, cleanup, and unmapping; a pre-existing mapping fails with inspection/removal guidance and is never cleared automatically.
- Portable ZIP and Winget generation uses a repository-wide `packaging` scope only after compilation because platforms share package inputs and `.build\AppPackages`. Standalone packagers that read compiled output acquire the artifact profile first and packaging second. Nested calls under `build.ps1` are balanced same-thread leases. Packaging abandonment fails closed for reviewed restoration rather than being cleared by a profile rebuild.
- ZIP and Winget packaging require the explicit positive build number or complete version they consume; Winget also requires both exact-version x64/ARM64 archive names. Never infer completed-artifact provenance from saved repository context or allocate a new number during packaging. Caller-selected package paths must remain beneath their guarded repository roots with every existing path component proven non-reparse before and after directory creation.
- Per-profile owner records authenticate PID, process start time, executable path, lock path, and token. Distinct same-thread nested scopes release LIFO. Only a same-thread nested call or an immediate child admitted by the one-use delegation handshake inside the owner's kill-on-close Job Object may reuse ownership; that child may reenter locally but cannot delegate a second generation. Never treat inherited environment variables alone as proof.
- Residual-tool checks require boundary-aware evidence for this repository and the same profile. A process name, an ambiguous substring, another configuration/platform, or another worktree is not enough to block or terminate anything.
- `Invoke-SanitizedMsbuild.ps1` requires explicit Configuration and Platform properties, including combined MSBuild property lists; it must never fall back to a repository-wide production lock.
- `build.ps1` never kills an independently launched application. If its executable path exactly equals an output the selected profile can replace, the build fails with PID/path/command-line diagnostics and asks the operator to close it. Automatic cleanup is limited to descendants launched and contained by the current operation.
- Interrupted launch trees are contained by a kill-on-close Job Object. An abandoned owner contaminates only its platform/configuration; run a full-solution `build.ps1 -Rebuild` for that same profile before trusting its incremental outputs or starting its tests.
- Shows build time and output file sizes
- Supports multi-processor builds (`/m`) and an explicit `-MaxCpuCount` stability bound
- Displays both executables when building full solution

### Required validation loop

For perf-sensitive work, building is only the first step; the workflow is in [test-evidence](../../test-evidence/SKILL.md#performance-evidence). After a successful build: run the deterministic selftest or scenario for the changed subsystem; confirm a new archived run appears under `Specs/TestRuns/`; compare the baseline and candidate runs before claiming an improvement; if the work finishes a plan, move that plan to `Specs/Plans/Done/` and update the authoritative subsystem spec or repo guidance with the lasting requirement. See `Specs/Testing/Testing_PerformanceValidation.md`, `Specs/TestRuns/README.md`, and `.github/skills/perf-validation/SKILL.md`.

## RedXe

Read the validation section of the owning normative spec before choosing the final build matrix. Use `Specs/UI/UI_XeneonDisplayWindowing.md` for display, window, fullscreen, fallback, manifest-DPI, and resize work.

```powershell
.\vcpkg-install.ps1 -Platform All        # Optional up-front install
.\build.ps1                              # Debug x64
.\build.ps1 -Configuration Release
.\build.ps1 -Platform ARM64
.\build.ps1 -Rebuild
.\build.ps1 -Run
.\test.ps1                               # Build + the suites your changes affect (Test-Changes.ps1)
.\test.ps1 -Full                         # Build + every suite, hidden WARP smoke test included: the full gate
.\build.ps1 -Configuration Release                   # Stamps 1.0.<commit count of HEAD>; -BuildNumber 42 overrides
.\package.ps1 -Platform x64                          # Portable ZIP under .build/packages, smoke-tested
.\winget-manifest.ps1 -Version 1.0.<n>               # Winget manifest from both packages (the version package.ps1 printed)
```

- Packaging, the in-package installer, the `RedXe` command-alias launcher (`RedXeLauncher/`), and the release and winget workflows follow `Specs/Build/Build_Packaging.md`; a new bundled plugin DLL becomes a required package entry automatically through `RedXe/BundledPlugins.h`, and a new self-terminating command-line switch is marked in the shared `RedXe/CommandLine.h` catalog that the launcher reads.
- Outputs are always `.build/<Platform>/<Configuration>/`. Intermediate files are under `.build/Intermediate/`. `build.ps1` ensures manifest dependencies are installed first.
- Every build starts with the RedXe build-signal banner. Plain interactive consoles retain MSBuild's native color; Codex, Windows Terminal, redirected, and non-interactive hosts use colored line replay. Each invocation captures a plain-text log beneath `.build/logs/` and reports diagnostic counts plus elapsed time.
- A running `RedXe.exe` whose normalized path exactly matches `.build/<Platform>/<Configuration>/RedXe.exe` blocks the build with identifying diagnostics and is never terminated. If this preflight changes, follow `Specs/Build/Build_Process.md` and keep `Tests/BuildProcessTests/BuildProcessTests.ps1` green.
- Qualification uses PrePush/Full accounting and the owning domain gates: factory ABI, borrowed descriptors, COM identity, rendering-IID negotiation, settings and hidden WARP presentation remain required when affected.
- Run ASan Debug tests natively (`test.ps1 -Full -Configuration 'ASan Debug'`).
- Scheduling changes also require the live hidden, minimized, suspended, and occluded idle checks in `Specs/Core/Core_PerformanceAndResources.md`.
- Before closeout, the plan's lasting requirements go into the authoritative domain spec (`Specs/README.md`).

## RedPrism

```powershell
.\vcpkg-install.ps1 -Platform x64
.\build.ps1
.\build.ps1 -Configuration Release
.\build.ps1 -Configuration "ASan Debug"
.\build.ps1 -Platform ARM64
.\build.ps1 -Rebuild
.\test.ps1
.\package.ps1 -Platform x64
```

- Outputs are always `.build/<Platform>/<Configuration>/`. Intermediates are under `.build/Intermediate/`.
- Every x64 build scans all five linked images for misplaced VEX/EVEX instructions and compiles passing/failing controls. It requires `llvm-objdump` and `llvm-pdbutil` (VS C++ Clang tools) plus matching full PDBs. Keep tier TUs at default `/arch`; runtime exceptions belong only in the reviewed `Build/IsaRuntimeAllowlist.psd1`.
- vcpkg builds with the Visual Studio installation and default MSVC toolset of the MSBuild `build.ps1` found (`vcpkg-install.ps1 -MSBuildPath`), never the newest toolset it finds, through pinned copies of every triplet in `.build/vcpkg-triplets/`; see `Specs/Build/Build_Toolchain.md`.
- `package.ps1` builds Release and stages the portable ZIP (`.build/packages/`, never committed) with the app-local Visual C++ CRT and the vcpkg DLLs the import table names, then proves a clean extraction runs `--help` and `--self-test --warp` with a system-only `Path`. It never packages Debug (`Specs/Build/Build_Packaging.md`).
- Every build, clean, and rebuild preflights the selected `RedPrism.exe` output.
- Run `test.ps1` after a successful host-architecture build.
- DxUi restore is C2 work. Do not add an unpinned sibling checkout to the build. A normal build asks DxUi whether `main` is newer than the lock and prints that advisory without changing the pin. The restore is a sparse checkout with Git long paths (no `Measurements/`, `docs/gallery` or `Specs/`); if `.build/dependencies/DxUi/source/<first-16-commit-hex>` is damaged, delete that directory and restore again.

## RedTilde

Use `build.ps1 -Platform x64|ARM64 -Configuration Debug|Release|'ASan Debug'`. Restore through `restore-dxui.ps1`; it discovers Visual Studio and fingerprints the exact library/compiler. Never compile the sibling checkout or repair a pin mismatch by resetting it. Check selected output process locks without killing apps. Keep build logs and test receipts separate. Cross-build success does not establish native runtime support. Package only after validation; retain dependency notices and the experimental-capability note.

## RedMonitor

```powershell
./build.ps1 -Platform x64 -Configuration Debug
./build.ps1 -Platform ARM64 -Configuration Release
./package.ps1 -Platform x64 -Configuration Release
```

The ARM64 command cross-builds on x64; it does not run ARM64 tests. Packaging is a separate Release operation, not a default build step. Verify the owning profile matrix, dependency closure and receipts separately; do not borrow sibling outputs or terminate independently launched apps. Outputs stay beneath the repository `.build`.

## DxUi

- Use root build.ps1 and test.ps1. Select x64/ARM64 and Debug/Release/ASan Debug explicitly. Build the single DxUi.lib and run the Foundation, controls and embedded suites; Foundation alone does not validate control or rendering changes. Cross-build receipts must not imply native execution.
- Restore with `vcpkg-install.ps1` first. It builds the dependencies with the Visual Studio installation and default MSVC toolset that build.ps1's MSBuild uses, through an overlay triplet it writes under the output root (`vcpkg-triplets/<platform>/<triplet>.cmake`; the first restore after a change rebuilds the packages). It prints the installation and toolset it pinned; a restore that fails starts at the first vcpkg configure log under `vcpkg_buildtrees`, and a missing or malformed `VC/Auxiliary/Build/Microsoft.VCToolsVersion.default.txt` fails before vcpkg runs.
- Iterate on one control test with `test.ps1 -Suites <Suite> -Tests <Name>` (`DxUi.ControlTests.exe --suite=<Suite> --test=<Name>`); an unknown name fails the run, and a filtered run never replaces a suite's receipt. Register every new control test as `DXUI_RUN_TEST(TestName);` in its suite runner so the filter can select it and the watchdog can bound it: a test that outlives its deadline (300 s; `--test-timeout=<seconds>`, `test.ps1 -TestTimeout`, 0 off) ends the run with `TIMEOUT: <TestName> after <N> s` and exit code 124. A driver thread of a blocking menu starts with `DismissMenusIfDriverFails`.
- The suites that need the person's real desktop (`Menu`, `NativeTextInput` and the two menu resource fixtures) run deliberately through `test.ps1 -Interactive` (`-Suites` to pick, `-SkipBuild` after a build): it refuses without an interactive desktop, asks first (Cancel is the default), warns while it runs and restores the foreground window, focus and pointer however the run ends. Run it, or any of those suites, only when the person at the desktop has agreed to the time; leave them out of `-Suites` otherwise. When that person also explicitly approves automatic start, add `-InteractiveAutoStart` to `-Interactive`. Its visible dialog defaults to Start and starts after 30 seconds without a click; Cancel, Esc, closing the dialog and Ctrl+C still stop it. It retains desktop refusal, the warning, verified restoration and native mode/countdown receipt checks. Ordinary `-Interactive` keeps the Cancel default; never infer automatic-start approval from silence.
- Validate changed guidance with `validate-skills.ps1` and `validate-specs.ps1`. For source/build work run the affected `test.ps1` configurations and the additional validation named by the contract. Supported capabilities are recorded in `capabilities.json`; library tests do not replace consumer product qualification or deferred native-platform/IME/AT coverage.
