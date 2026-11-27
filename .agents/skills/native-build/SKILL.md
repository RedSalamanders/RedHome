---
name: native-build
description: Build, restore, and package RedSalamanders C++ repositories through their root entry points - the six-profile matrix, pinned dependencies under .build, Visual Studio discovery, a running-executable preflight that never kills, ARM64 cross-builds, a real ASan probe, and Release-only packages with a clean-extraction smoke. Use when building, restoring, or packaging, or when diagnosing a compiler, linker, toolchain, or dependency failure.
---

# Build, Restore, And Package

Read the target repository's build contract and the validation section of the owning domain spec before choosing the final build matrix. Each repository's commands are in [references/repository-facts.md](references/repository-facts.md); where they still differ, the `Differences To Converge` table names the register rows (E-01 to E-12) that make them one table. This skill applies in every repository; the repository's `AGENTS.md` and `Specs/` win on any conflict. Compiler switches and warnings are in [modern-cpp-windows](../modern-cpp-windows/SKILL.md), producer pins in [cross-repo-pins](../cross-repo-pins/SKILL.md), and what a test run proves in [test-evidence](../test-evidence/SKILL.md).

## Entry Points

- Use the repository's root entry points (`build.ps1`, `test.ps1`, `package.ps1`, and the restore scripts) instead of assembling ad hoc MSBuild commands. Select the platform and the configuration explicitly.
- `build.ps1` discovers Visual Studio, including prerelease instances. Never hardcode a developer's installation path or toolset in project files or scripts.
- Change shared toolchain, output-path, versioning, and compile defaults in `Directory.Build.props` and `Directory.Build.targets` (and the family-level props files), not by copying edits across individual `.vcxproj` files.
- Before changing a build script or helper, follow the repository's tooling rules (its facts name them).

## Profiles

- Six profiles: x64 and ARM64, each in Debug, Release, and ASan Debug.
- Build Debug, Release, and ASan Debug when changing project properties, manifests, or compiler behavior. Build x64 and ARM64 when changing vcpkg, platform mapping, or dependency paths.
- **ARM64 is a cross-build.** On an x64 host the ARM64 build runs no ARM64 test, and a cross-build success does not establish native runtime support. ARM64 runtime tests require a native ARM64 host.
- **ASan Debug is real.** Run its tests natively; the deliberate isolated probe must produce an AddressSanitizer diagnostic.
- Build with `/Wall` and `/WX` disabled. Build acceptance requires zero warnings and errors across all six profiles.

RedSalamander keeps its portable `RedLauncher.exe` on the static CRT. Verify the executable's imports and launch from a clean package on x64 and native ARM64. [WinGet integration](../../../../RedSalamander/Specs/Installer/WingetIntegration.md)

## Outputs And Dependencies

- Outputs are always `.build/<Platform>/<Configuration>/`, and every intermediate and generated file stays beneath the repository's `.build/`.
- The pinned vcpkg checkout and all package state stay beneath `.build/`. Never substitute a developer-global install, and never use `vcpkg integrate install`; the repository supplies its manifest and toolchain integration explicitly. The tool commit is pinned (`vcpkg-tool.json`); keep the pin files intentional and reviewed.
- vcpkg builds with the Visual Studio installation and default MSVC toolset that the build's MSBuild uses, never the newest toolset it finds, through pinned triplets under the output root. Never hard-code an installation or toolset, or set `VCPKG_OVERLAY_TRIPLETS`, to get around a restore.
- Consume `DxUi` and `RedMonitor` only through their pins: never compile a sibling checkout, borrow its outputs, add an unpinned sibling checkout to the build, or repair a pin mismatch by resetting it. A build may report that a producer's `main` is newer than the lock; it never changes the pin.
- Each build captures its log; read it for the first compiler error when the terminal truncates a diagnostic. Keep build logs and test receipts separate, and verify the profile matrix, the dependency closure, and the receipts separately.

## Running Executables

Every build, clean, and rebuild preflights the outputs the selected profile replaces. A running process whose normalized path exactly matches one of them blocks the build with its process ID, path, and command line, and is never terminated; same-name processes from another checkout or profile are ignored. Automatic cleanup is limited to descendants launched and contained by the current operation.

## Packaging

- Packaging is a separate Release operation, never a default build step, and it never packages Debug. Package only after validation.
- The package is staged under `.build/` and never committed, with the app-local Visual C++ runtime, the dependency DLLs the import table names, and their notices.
- A clean extraction of the package must start with a system-only `Path`, at least `--help` and the hidden WARP self-test.

## Diagnosing A Failure

1. For a dependency failure, run the restore for the exact platform and fix the first vcpkg diagnostic (the first configure log under `vcpkg_buildtrees`).
2. Re-run `build.ps1` with the exact configuration and platform that failed.
3. Fix every project-code diagnostic; read the captured log when the terminal truncates it.
4. After a successful build, iterate with `Test-Changes.ps1 -Explain` and the affected suites. A focused repair run is partial evidence and does not close the final obligations. Full and PrePush are explicit: use the owning scoped-testing contract to account for matching CI obligations and exact local evidence instead of repeating unchanged identical tests. Pending CI or foreground or platform acceptance is not a repository pass.
5. Before closeout, confirm that the authoritative domain spec matches the validated behavior, and move a finished WIP plan to `Specs/Plans/Done/` only after merging its lasting requirements into that spec ([spec-workflow](../spec-workflow/SKILL.md)).

## Repository Facts

The command table, parameters, outputs, packaging, and product build rules of every repository: [references/repository-facts.md](references/repository-facts.md).

## Differences To Converge

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| `build.ps1` parameters (register E-05) | Common: `-Configuration`, `-Platform`, `-ProductionOnly`. `-Clean`, `-Rebuild`, `-MaxCpuCount`, `-BuildNumber`, `-Run`, `-ProjectName` vary | One common set |
| Packaging (register E-06) | All five applications publish `package.ps1` with `.build/packages` as the canonical location. RedSalamander and RedTilde retain legacy package discovery. | Record RedSalamander's native clean-package and installed-alias evidence. |
| Restore entry points (registers E-07, E-09, E-12) | All six repositories publish `restore.ps1` and default `vcpkg-install.ps1` to x64. RedSalamander retains `Tools/Restore-DxUi.ps1` for its pinned consumer restore. | Verify RedSalamander's clean x64 and ARM64 restores and bring the DxUi consumer tooling forward through its API 6 plan. |
| Test entry point (register E-03) | Root `test.ps1` in five; RedSalamander `Tools/Run-AllTests.ps1` | Root `test.ps1` |
| Intermediate directory (register C-04) | `.build\Intermediate\...` in four; `.build\obj\...` in RedTilde and RedMonitor | `.build\Intermediate\...` |
| Where profile values are set (C-11) | RedTilde moved its common settings to root props. RedSalamander and RedMonitor already centralize most values. RedXe, RedPrism and DxUi retain per-project settings. | Centralize common settings and verify meaningful exceptions, including RedLauncher's static CRT (D25). |
| vcpkg restore model (register C-14) | All six native repositories use scripted project restore with the shared tool pin and baseline. Product contracts own their triplets. RedTilde uses static-md and sanitizer triplets. RedMonitor packages `yyjson.dll`. | Verify RedSalamander's explicit link inputs and portable packages under CV-4-07. Read the manifest and tool lock for the current pin. |
