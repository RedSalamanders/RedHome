# Divergence register

Companion to [the convergence plan](../Convergence_2026-11-17.md). It lists every known option, rule, or file that is not the same in all repositories, with one common target each. The owner's rule decides every row: at the end, all projects are as close as possible. A difference survives only when the product requires it, and then the reason is written in the row.

**Source.** Four file-level inventories of the six `main` branches at the plan's baseline commits (build and toolchain, script entry points, guidance and documentation, CI and project configuration), the `Differences To Converge` tables of the shared skills, and spot checks of the high-impact rows. Effective MSBuild evaluation was not run; property rows come from reading the files. Correct a row here when a repository proves it wrong.

**Abbreviations.** RS `RedSalamander`, Xe `RedXe`, Pr `RedPrism`, Ti `RedTilde`, Mo `RedMonitor`, Dx `DxUi`, Home `RedHome`.

**Columns.** *Target* is the single end state. *Changes* names the repositories that must move. *In* is the plan phase that converges the row; "PR open" means this plan's first product pull requests already carry it. *Choice* marks rows where two uniform end states are possible and the owner picks one.

## A. Agent guidance and discovery

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| A-01 | `CLAUDE.md` pointer | RS, Xe, Mo: three different texts. Pr, Ti, Dx: absent, so Claude Code loads no guidance there | One identical file | All six | PR open | |
| A-02 | Claude Code skill discovery | No repository enabled it; skills were reached only through `AGENTS.md` | `.claude/settings.json` enabling the `redhome` plugin, identical everywhere | All six, Home | PR open | |
| A-03 | `.github/copilot-instructions.md` | RS, Xe, Mo: three texts. Pr, Ti, Dx: absent | One identical file | All six | 6 | |
| A-04 | Prose exclusion of `.github/copilot-instructions.md` | Not in any `.ci/project.json` `exclude`, so adding or editing it changes native inputs (`CLAUDE.md`, `.claude/**`, `.agents/**` are excluded) | Excluded by the engine template | Engine, then all six | 6 | |
| A-05 | Shared-skill pointer sentence | Identical text in all six; placement differs (bullet in RS, no `Skills` heading in Mo) | Directly under `## Skills` | RS, Mo | 6 | |
| A-06 | `AGENTS.md` title and skills heading | Titles: "development guidance" (Ti, Mo, Dx) and two other styles. Heading: `## Skills` (Xe, Pr, Dx), `Skills Reference` (RS), `Focused skills` (Ti), none (Mo) | `# <Name> development guidance`, `## Skills` | RS, Xe, Pr, Ti, Mo | 6 | |
| A-07 | `AGENTS.md` shared sections | Unified CI: identical in five (Dx variant). Shared native build policy: identical in five (Mo lacks it). Changes workflow: identical in four. Drive-root output policy: five wordings. Scoped testing: three wordings and two dates. Mo carries them as bullets | One text per section from one engine template, product names as parameters | All six | 6 | |
| A-08 | Interactive desktop lease rule | Stated only in RS and Dx | One text, in every `AGENTS.md` or in the shared policy page | Xe, Pr, Ti, Mo | 6 | |
| A-09 | Skill folder | `.agents/skills/` in five. RS: 11 skills in `.github/skills/`, 1 in `.agents/skills/` | `.agents/skills/` | RS | 2 | |
| A-10 | Skill front matter | `name` and `description` only in five. RS adds `metadata.author` and `metadata.version` to 8 skills | `name` and `description` only | RS | 2 | |
| A-11 | Codex `agents/openai.yaml` | Present in Xe (3 skills), Ti (8), RS (3). Absent in Pr, Mo, Dx, Home | All skills or none | Three repositories either way | 2 | Yes |
| A-12 | Other tool folders | `.codex/`, `.github/agents/`, `.vscode/` only in RS. `.agents/guidance.json` only in Ti | Each adopted everywhere or removed | RS, Ti or the others | 6 | Yes |
| A-13 | `capabilities.json` | Ti, Mo, Dx (keys `implemented` in Ti and Mo, `supported` in Dx). Absent in RS, Xe, Pr | Present everywhere with one key vocabulary | RS, Xe, Pr; key rename in one group | 6 | |

## B. Specifications, documents, and metadata

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| B-01 | `Specs/README.md` structure | Three shapes: RS catalog; Xe and Pr workflow with six shared headings; Ti, Mo, Dx headings only | The Xe and Pr structure | RS, Ti, Mo, Dx | 6 | |
| B-02 | WIP index format | Five formats; bullets with `**ACTIVE**:` (Ti, Dx, RS), tables (Xe, Pr), `— ACTIVE;` suffix (Mo). Extra labels `DRAFT` (RS), `SPEC READY` (Dx) | `- **STATUS**: [Title](File.md) — purpose` with `ACTIVE`, `HOLD`, `DECISION`, `RETIRED` | Xe, Pr, Mo; labels in RS, Dx | 6 | |
| B-03 | `Specs/Plans/Done/README.md` | Missing in RS | Present | RS | 6 | |
| B-04 | Plan file names | `<Topic>_<yyyy-mm-dd>.md` is the rule; undated plans exist in RS (41), Xe (8 `RFC_*`), Pr (1), Dx (1) | Dated names for every active plan; completed history stays untouched | RS, Xe, Pr, Dx for active plans | 6 | |
| B-05 | `Specs/` top level | `Testing/` missing in Xe; `UI/` missing in Mo; stray `Specs/Done/` in Dx; settings schema named `SettingsStore.schema.json` (RS, Mo) and `Settings.schema.json` (Xe) | Same folders and one schema file name | Xe, Mo, Dx | 6 | |
| B-06 | Performance contract | `Specs/Core/Core_PerformanceAndResources.md` in Dx, Xe, Pr. Ti: `Specs/Testing/Testing_Performance.md` only. RS: `Specs/Testing/Testing_PerformanceValidation.md` only. Mo: none | The `Core` file everywhere; procedure stays under `Testing/` | Ti, RS, Mo | 6 | |
| B-07 | `Specs/Core/Core_Changes.md` | Identical in Xe, Ti, Mo; three other variants | One text owned by the engine | RS, Pr, Dx, then all link | 6 | |
| B-08 | `Specs/Build/Build_UnifiedCI.md` | Six different documents | One skeleton; only adapter sections differ | All six | 6 | |
| B-09 | `README.md` | `## Recording changes` in five (not Mo); Pr has no H1 | Same common sections | Mo, Pr | 6 | |
| B-10 | `CHANGELOG.md` header | Same in RS, Xe, Pr, Ti; Mo lacks the intro; Dx differs | One header | Mo, Dx | 6 | |
| B-11 | Licence files | `LICENSE.txt` in all six; Xe also has a different `LICENSE`. Holder "RedSalamander" in five, "RedSalamanders" in Pr. Mo's file is a byte copy of RS's, including RS's third-party list. Home has no licence | One file name, one holder spelling, correct third-party text, and a licence in Home | Xe, Pr, Mo, Home | 6 | Yes |
| B-12 | Other root files | `THIRD-PARTY-NOTICES.md`, `CONTRIBUTING.md`: Dx only. `.github/CODEOWNERS`: RS, Dx. Pull request template: RS. `.editorconfig`: Xe, Dx (different). `.vsconfig`: Xe | Each present everywhere with one text, or nowhere | Up to five each | 6 | Yes |

## C. Build and toolchain

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| C-01 | Warning profile | `/Wall`, `/WX` off, zero-warning gate in five. Mo: `/W4 /WX` | `/Wall`, `/WX` off, zero warnings | Mo | 6 | |
| C-02 | `Build/NativeBuildPolicy.targets` | Identical in RS, Xe, Pr, Ti; Dx differs by one include line; Mo has none (so no shared disabled-warning list, Release LTCG and ICF, or Debug edit-and-continue format) | One file delivered by the engine | Dx, Mo | 5 | |
| C-03 | Compiler switches in root props | `/utf-8` in five, not RS. `/Zc:preprocessor` in four, not RS or Mo. `/FS` only in RS and Mo. Windows version defines only in RS and Mo | The same switch set | RS, Mo for the first two; Xe, Pr, Ti, Dx for the others | 6 | |
| C-04 | Intermediate directory | `.build\Intermediate\...` in four; `.build\obj\...` in Ti and Mo | `.build\Intermediate\...` | Ti, Mo | 6 | |
| C-05 | ASan Debug property set | Five set the full set; Ti sets only `EnableASAN` | The full set | Ti | 6 | |
| C-06 | vcpkg baseline | `9eec002d…` in Xe, Pr, Mo, Dx; `aeb162b7…` in RS; Ti has no vcpkg | One baseline; Ti stays without vcpkg only if it keeps no vcpkg dependency | RS | 4 | |
| C-07 | vcpkg tool pin and triplets | Four different `vcpkg-tool.json` commits. Mo uses `*-windows-static-md`; the others the standard triplets | One tool commit and one triplet set | RS, Pr, Mo and the Xe/Dx pair | 4 | |
| C-08 | `Build/PinnedDxUiPolicy.targets` | Identical in Dx, Xe, Pr, Ti; RS variant; Mo none | The `DxUi` file, consumed through the pin | RS, Mo | 5 | |
| C-09 | Minimum Windows version | Windows 11 22000.2600 stated in RS and Pr; Winget minimum `10.0.22000.2600` in RS, Pr, Mo; Xe supports Windows 10 (`10.0.19041.0`); Ti declares none | One minimum | Xe or the others; Ti declares it | 6 | Yes |

## D. Formatting and text conventions

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| D-01 | `.clang-format` | One 155-line file (column limit 160) in RS, Mo, Dx. Xe and Pr: 120 columns, 13 keys. Ti: 150 columns, 7 keys | The 155-line file; each adopter reformats in one dedicated pull request | Xe, Pr, Ti | 6 | |
| D-02 | Formatter pin | clang-format 22.1.3 pinned in RS and Mo (`Build/clang-format.json`) and hard-coded in Dx; unpinned in Xe, Pr, Ti | One pin from the engine policy | Xe, Pr, Ti, Dx | 5 | |
| D-03 | `.gitattributes` and `.gitignore` | Six different files each | One common block plus repository lines | All six | 6 | |
| D-04 | Script line endings | CRLF in Xe, Ti, Mo, Dx adapters; LF in RS, Pr | One rule in `.gitattributes` | RS, Pr or the others | 6 | |

## E. Script entry points

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| E-01 | Validation | `validate.ps1`: Pr, Ti, Mo, Dx. `validate-skills.ps1`: Xe, Pr, Dx. `validate-specs.ps1`: Dx only (RS uses `Tools/Get-SpecInventory.ps1`) | All three at every root | All six | 6 | |
| E-02 | Formatting | `format.ps1 -Check`: Pr, Ti, Mo, Dx. Xe: no `-Check`. RS: `format-all.ps1` | `format.ps1 -Check` | Xe, RS | 6 | |
| E-03 | Tests | Root `test.ps1` in five; RS uses `Tools/Run-AllTests.ps1` | Root `test.ps1` | RS | 6 | |
| E-04 | `Test-Changes.ps1` parameters | Identical in Xe, Pr, Ti. Mo has only `-Explain`, `-Mode`, `-Force`. RS differs in `-BaseRef` default and extras. Dx adds `-ParallelSuites` and a separate `Test-PrePush.ps1` | One parameter set from the engine planner | Mo, RS, Dx | 5 | |
| E-05 | `build.ps1` parameters | Only `Configuration`, `Platform`, `ProductionOnly` are common; `-Clean`, `-Rebuild`, `-MaxCpuCount`, `-BuildNumber` vary | One common set | Ti, Mo, Dx, RS | 6 | |
| E-06 | Packaging | `package.ps1` in Xe, Pr, Ti, Mo; RS packages through `build.ps1 -Zip`. Output: `.build/packages` (Xe, Pr, Mo), `.build/package` (Ti), `.build/AppPackages` (RS) | `package.ps1` writing `.build/packages` | RS, Ti | 6 | |
| E-07 | `DxUi` scripts | `restore-dxui.ps1` at the root in Xe, Pr, Ti, Mo; `Tools/Restore-DxUi.ps1` in RS. `Update-DxUi.ps1` only in RS (`Tools/`) and Xe (root) | Same names at the root, implemented once in `DxUi` | RS, Pr, Ti, Mo | 5 | |
| E-08 | `RedMonitor` client scripts | Root in Xe, Pr, Ti; `Tools/` in RS | Root, implemented once in `RedMonitor` | RS | 5 | |
| E-09 | `vcpkg-install.ps1` | Absent in Ti; RS defaults `-Platform` to `All`, the others to `x64` | Same defaults | RS | 5 | |
| E-10 | Performance entry point and gate | `performance-paired.ps1` in Ti and Dx; `measure-*.ps1` in Xe; none in RS, Pr, Mo. Hosted paired gate (`benchmark.yml`) only in Dx | `performance-paired.ps1` and the hosted gate everywhere | Xe, RS, Pr, Mo; gate in five | 6 | |

## F. Tooling that exists more than once

The plan's inventory table lists the copies. Each row converges by giving the tool one owner and thin consumers (Phase 5).

| Id | Tool | Owner after convergence |
| --- | --- | --- |
| F-01 | Changelog suite (four scripts and `Changelog.psm1`; three variants) | Engine |
| F-02 | `BuildConsole.psm1`, `NativeBuildPolicy.targets`, `Get-CiNativeScope.ps1` | Engine |
| F-03 | `ScopedTesting.psm1`, `TestRunEvidence.psm1`, `Test-Changes.ps1` (four forks) | Engine |
| F-04 | Skill grammar and package integrity (seven implementations, one of them in Home) | Engine |
| F-05 | `DxUiPaths.psm1`, `restore-dxui.ps1`, `DxUiRestore.psm1`, `DxUiProvenance.psm1` | `DxUi` consumer interface |
| F-06 | `Update-RedMonitorClient.ps1`, `Verify-RedMonitorClient.ps1` | `RedMonitor` |
| F-07 | `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1` | Engine or `DxUi` |
| F-08 | `.github/actions/setup-msvc` (`action.yml` in three variants, `Setup.ps1` in five) | Engine |

## G. CI and project configuration

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| G-01 | Engine pin | Four commits: Dx `766fd7e`, Mo `d6a33c5`, Xe/Pr/Ti `07bc6f1`, RS `a094b2e` | One commit | Dx, Mo, Xe, Pr, Ti | 4 | |
| G-02 | Dependabot engine `ignore` | `RedSalamanders/.github` does not match the reusable-workflow names, so weekly notices are opened | Add `RedSalamanders/.github/*` | Dx, Xe, Pr, Ti, Mo now. RS with its test `HistoricalTerminalProfile.Tests.ps1`, which pins the list to one entry, once its `main` is green | PR open; RS 4 | |
| G-03 | `dependabot.yml` | Identical in Xe, Pr, Mo, Dx. Ti has no vcpkg block. RS adds `exclude-paths`, a vcpkg `ignore` list, and a group | One file from an engine template | RS, Ti | 6 | |
| G-04 | `.ci/project.json` lists | `legacy/**` missing from Pr's `exclude`; `Plugins/**/README.md` only in Xe; `Tools` is a format root only in RS and Dx | Same lists apart from real content differences | Pr, Xe or RS, four for `Tools` | 6 | |
| G-05 | Winget block | `minimumOSVersion` missing in Ti; `smokeTests` only in Xe; alias mixed case in RS | Same fields everywhere | Ti, four for smoke tests, RS | 6 | |
| G-06 | Repository-only workflows | RS has ten extra workflows; Pr `native-arm64-feasibility.yml`; Dx `benchmark.yml` | Shared ones become engine templates; the rest carry a recorded reason | RS, Pr, Dx | 6 | |
| G-07 | CI adapter | Same parameters; RS has six extra `QualificationScope` values; static-phase commands differ in every repository | One static phase calling `validate.ps1` | All six | 6 | |
| G-08 | Tests layout | `<Suite>Tests/<Suite>Tests.vcxproj` (RS, Xe, Pr); flat `Tooling.Tests.*.ps1` (Ti, Mo); `DxUi.*Tests.vcxproj` (Dx) | One layout | Three repositories | 6 | Yes |
| G-09 | Winget manifests in the repository | `Installer/` in RS and Xe only | Generated from `.ci/project.json` everywhere | RS, Xe | 6 | |
| G-10 | `RedHome` CI | Its own `validate.yml`, outside the engine | Engine-run once the engine has a documentation kind | Home, engine | 5 | |

## H. Code conventions

Each row is also the `Differences To Converge` entry of a shared skill, which carries the evidence.

| Id | Option | Today | Target | Changes | In | Choice |
| --- | --- | --- | --- | --- | --- | --- |
| H-01 | `DxUi` API revision and commit | API 5 in Ti (`21fae0dc`); API 4 in Xe, Pr, Mo (`f2e328a0`) and RS (`7fb2ab71`) | One revision and commit | RS, Xe, Pr, Mo | 4 | |
| H-02 | Unexpected-exception and `std::bad_alloc` policy | API 5 policy in Dx and Ti; four different API 4 rules | The API 5 policy | RS, Xe, Pr, Mo with H-01 | 4 | |
| H-03 | COM smart pointer | `wil::com_ptr<T>` in RS; `wil::com_ptr_nothrow<T>` in `HRESULT` code elsewhere | `wil::com_ptr_nothrow<T>` | RS | 6 | |
| H-04 | WIL include guard | RS guards only `<wil/resource.h>` | One block that also wraps `<wil/com.h>` | RS | 6 | |
| H-05 | Logging helpers | `Debug::` in RS and Mo; `DxUi::Debug` in Dx; none in Xe, Pr, Ti | One family with the same names | Three or four repositories | 6 | Yes |
| H-06 | Resource string helpers | RS and Mo share one set; Pr has its own; Ti a local `LoadStringW` wrapper; Xe has none and no `STRINGTABLE` | One helper set; chrome strings in resources everywhere | Pr, Ti, Xe | 6 | |
| H-07 | Satellite layout and loader | `Lang\<Module>-<culture>.dll` in RS and Mo; `Languages\<tag>\RedPrism.resources.dll` in Pr; none in Ti, Xe | One layout and loader | Pr or RS and Mo | 6 | Yes |
| H-08 | Resource-string gate | RS and Pr only | A gate wherever a `STRINGTABLE` exists | Mo, Ti, Xe | 6 | |
| H-09 | `yyjson` read flags for configuration | JSON5 and BOM in RS and Mo; comments, trailing commas, BOM in Xe; BOM only in Pr | JSON5 and BOM | Xe, Pr | 6 | |
| H-10 | Settings format | JSON through `yyjson` in RS, Xe, Pr, Mo; line-based `key=value` text in Ti | JSON through `yyjson` | Ti | 6 | Yes |
| H-11 | `--self-test` and WARP | Forces WARP in Pr; not in Xe | Forces WARP | Xe | 6 | |
| H-12 | Host windowing spec name | `UI_Windowing.md` in Pr; `UI_XeneonDisplayWindowing.md` in Xe | `UI_Windowing.md` | Xe | 6 | |
| H-13 | Stale rule | The former `RedPrism` skill allowed `new (std::nothrow)` only in `Main.cpp`; the source also uses it in `AccessibilityRoot.cpp` | Rule and code agree, stated once | Pr | 6 | |

## Rows that stay different by design

| Item | Reason |
| --- | --- |
| `kind` (`sdk` for Dx, `application` elsewhere) and the workflows that follow from it | `DxUi` is a library with no public release |
| `versionBase` | Each product has its own release line |
| Product specifications, plugin ABIs, numeric goldens | They are the products |
| `RedSalamander` Ghostty and terminal-engine workflows, `RedPrism` ARM64 feasibility workflow | Product-specific until a second repository needs them |
