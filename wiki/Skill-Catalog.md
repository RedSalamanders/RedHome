# Skill Catalog

Every skill available across RedSalamanders, grouped by owner. Pick the row for the task, open the shared skill first, then the repository-local skill. Shared skills live in `RedHome/.agents/skills/`; repository-local skills stay with their repository and are linked here so a session started in `RedHome` reaches them directly.

Each repository's `AGENTS.md` and `Specs/` still decide product behavior. A skill never overrides them.

## Route By Task

| Task | Shared skill | Then, in the target repository |
| --- | --- | --- |
| C++ style, warnings, header hygiene, error handling | [modern-cpp-windows](../.agents/skills/modern-cpp-windows/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [async-threading](../../RedSalamander/.github/skills/async-threading/SKILL.md) for threading |
| Windows handle and COM ownership | [wil-raii](../.agents/skills/wil-raii/SKILL.md) | Its `references/repository-facts.md` |
| JSON parsing and serialization | [yyjson](../.agents/skills/yyjson/SKILL.md) | Its `references/repository-facts.md`; [app-settings](../.agents/skills/app-settings/SKILL.md) for settings documents |
| User-visible strings, menus, accessible names | [localization](../.agents/skills/localization/SKILL.md) | Its `references/repository-facts.md` |
| Hot paths, allocation, idle behaviour, baselines | [performance-resources](../.agents/skills/performance-resources/SKILL.md), then [test-evidence](../.agents/skills/test-evidence/SKILL.md) for the measurement | Their `references/repository-facts.md`; `RedSalamander` [perf-validation](../../RedSalamander/.github/skills/perf-validation/SKILL.md) until its copy is removed |
| Win32 window, D3D11 device, swap chain, device loss | [d3d11-win32-host](../.agents/skills/d3d11-win32-host/SKILL.md) | `RedSalamander` [win32-wndproc](../../RedSalamander/.github/skills/win32-wndproc/SKILL.md), `RedSalamander` [direct2d-rendering](../../RedSalamander/.github/skills/direct2d-rendering/SKILL.md), `DxUi` [win32-host](../../DxUi/.agents/skills/win32-host/SKILL.md), `DxUi` [embedded-rendering](../../DxUi/.agents/skills/embedded-rendering/SKILL.md), `RedPrism` [hlsl-composition](../../RedPrism/.agents/skills/hlsl-composition/SKILL.md) |
| Specs, WIP and Done plans, closeout | [spec-workflow](../.agents/skills/spec-workflow/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [tooling-governance](../../RedSalamander/.github/skills/tooling-governance/SKILL.md) |
| Build, restore, package, toolchain failures | — | `RedSalamander` [cpp-build](../../RedSalamander/.github/skills/cpp-build/SKILL.md), `RedXe` [build-redxe](../../RedXe/.agents/skills/build-redxe/SKILL.md), `RedPrism` [build-redprism](../../RedPrism/.agents/skills/build-redprism/SKILL.md), `RedTilde` [build-redtilde](../../RedTilde/.agents/skills/build-redtilde/SKILL.md), `RedMonitor` [build-redmonitor](../../RedMonitor/.agents/skills/build-redmonitor/SKILL.md), `DxUi` [build-dxui](../../DxUi/.agents/skills/build-dxui/SKILL.md) |
| Tests, goldens, captures, evidence | [test-evidence](../.agents/skills/test-evidence/SKILL.md) | Its `references/repository-facts.md`; `RedPrism` [numeric-goldens](../../RedPrism/.agents/skills/numeric-goldens/SKILL.md). Until their copies are removed: `RedPrism` [test-harness](../../RedPrism/.agents/skills/test-harness/SKILL.md), `RedTilde` [test-harness](../../RedTilde/.agents/skills/test-harness/SKILL.md), `RedMonitor` [test-harness](../../RedMonitor/.agents/skills/test-harness/SKILL.md), `RedSalamander` [perf-validation](../../RedSalamander/.github/skills/perf-validation/SKILL.md) |
| `DxUi` pin bumps and consumer adapters | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | `DxUi` [consumer-integration](../../DxUi/.agents/skills/consumer-integration/SKILL.md), `RedPrism` [consumer-dxui](../../RedPrism/.agents/skills/consumer-dxui/SKILL.md), `RedTilde` [consumer-dxui](../../RedTilde/.agents/skills/consumer-dxui/SKILL.md) |
| `RedMonitor` client adoption and transport | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | `RedMonitor` [consumer-adoption](../../RedMonitor/.agents/skills/consumer-adoption/SKILL.md), `RedMonitor` [transport-client](../../RedMonitor/.agents/skills/transport-client/SKILL.md) |
| Shared CI engine pin, `.ci-engine` health | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | [Shared-CI-Engine.md](Shared-CI-Engine.md) |
| Settings, preferences, themes | [app-settings](../.agents/skills/app-settings/SKILL.md), then [yyjson](../.agents/skills/yyjson/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [build-preferences-pages](../../RedSalamander/.github/skills/build-preferences-pages/SKILL.md), `RedSalamander` [theming](../../RedSalamander/.github/skills/theming/SKILL.md). Until their copies are removed: `RedXe` [settings-store](../../RedXe/.agents/skills/settings-store/SKILL.md), `RedPrism` [settings-store](../../RedPrism/.agents/skills/settings-store/SKILL.md), `RedTilde` [settings-crashes](../../RedTilde/.agents/skills/settings-crashes/SKILL.md) |
| Crash dumps and failure diagnostics | [crash-dumps](../.agents/skills/crash-dumps/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [red-salamander-crash-forensics](../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) to investigate a dump. Until their copies are removed: `RedPrism` [crash-handling](../../RedPrism/.agents/skills/crash-handling/SKILL.md), `RedTilde` [settings-crashes](../../RedTilde/.agents/skills/settings-crashes/SKILL.md) |
| File open/save safety | [file-io-safety](../.agents/skills/file-io-safety/SKILL.md) | Its `references/repository-facts.md`. Until their copies are removed: `RedTilde` [file-safety](../../RedTilde/.agents/skills/file-safety/SKILL.md), `RedMonitor` [file-safety](../../RedMonitor/.agents/skills/file-safety/SKILL.md) |
| Plugin ABIs | — | `RedSalamander` [plugin-callbacks](../../RedSalamander/.github/skills/plugin-callbacks/SKILL.md), `RedXe` [plugin-development](../../RedXe/.agents/skills/plugin-development/SKILL.md) |
| Shared controls, input, accessibility | — | `DxUi` [control-development](../../DxUi/.agents/skills/control-development/SKILL.md), `DxUi` [input-accessibility](../../DxUi/.agents/skills/input-accessibility/SKILL.md), `RedTilde` [desktop-ui](../../RedTilde/.agents/skills/desktop-ui/SKILL.md) |
| Cross-repository design review | [grill-cross-repo](../.agents/skills/grill-cross-repo/SKILL.md) | Then [spec-workflow](../.agents/skills/spec-workflow/SKILL.md) |
| Audits and improvement plans | [improve](../.agents/skills/improve/SKILL.md) | — |
| Wiki upkeep and session handoff | [wiki-sync](../.agents/skills/wiki-sync/SKILL.md) | — |

## Shared Skills

Each shared skill is one rule set for every repository. `references/` holds the detailed patterns and `repository-facts.md`, the product-specific paths, helpers, and gates. Every skill that covers code ends with a `Differences To Converge` table; the [convergence plan](../Specs/Plans/WIP/README.md) collects those rows into one register.

| Shared skill | Reference files |
| --- | --- |
| [modern-cpp-windows](../.agents/skills/modern-cpp-windows/SKILL.md) | [compiler-warnings](../.agents/skills/modern-cpp-windows/references/compiler-warnings.md), [cpp-style](../.agents/skills/modern-cpp-windows/references/cpp-style.md), [error-handling](../.agents/skills/modern-cpp-windows/references/error-handling.md), [repository-facts](../.agents/skills/modern-cpp-windows/references/repository-facts.md) |
| [wil-raii](../.agents/skills/wil-raii/SKILL.md) | [patterns](../.agents/skills/wil-raii/references/patterns.md), [repository-facts](../.agents/skills/wil-raii/references/repository-facts.md) |
| [yyjson](../.agents/skills/yyjson/SKILL.md) | [patterns](../.agents/skills/yyjson/references/patterns.md), [repository-facts](../.agents/skills/yyjson/references/repository-facts.md) |
| [localization](../.agents/skills/localization/SKILL.md) | [patterns](../.agents/skills/localization/references/patterns.md), [repository-facts](../.agents/skills/localization/references/repository-facts.md) |
| [performance-resources](../.agents/skills/performance-resources/SKILL.md) | [repository-facts](../.agents/skills/performance-resources/references/repository-facts.md) |
| [d3d11-win32-host](../.agents/skills/d3d11-win32-host/SKILL.md) | [repository-facts](../.agents/skills/d3d11-win32-host/references/repository-facts.md) |
| [spec-workflow](../.agents/skills/spec-workflow/SKILL.md) | [repository-facts](../.agents/skills/spec-workflow/references/repository-facts.md) |
| [test-evidence](../.agents/skills/test-evidence/SKILL.md) | [patterns](../.agents/skills/test-evidence/references/patterns.md), [repository-facts](../.agents/skills/test-evidence/references/repository-facts.md) |
| [crash-dumps](../.agents/skills/crash-dumps/SKILL.md) | [repository-facts](../.agents/skills/crash-dumps/references/repository-facts.md) |
| [file-io-safety](../.agents/skills/file-io-safety/SKILL.md) | [repository-facts](../.agents/skills/file-io-safety/references/repository-facts.md) |
| [app-settings](../.agents/skills/app-settings/SKILL.md) | [repository-facts](../.agents/skills/app-settings/references/repository-facts.md) |
| [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | None (cross-repository by nature) |
| [grill-cross-repo](../.agents/skills/grill-cross-repo/SKILL.md) | None (cross-repository by nature) |
| [wiki-sync](../.agents/skills/wiki-sync/SKILL.md) | None (cross-repository by nature) |
| [improve](../.agents/skills/improve/SKILL.md) | [audit-playbook](../.agents/skills/improve/references/audit-playbook.md), [closing-the-loop](../.agents/skills/improve/references/closing-the-loop.md), [plan-template](../.agents/skills/improve/references/plan-template.md) |

## Repository-Local Skills

### RedSalamander (`.github/skills/` and `.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [async-threading](../../RedSalamander/.github/skills/async-threading/SKILL.md) | Threading model and async operation patterns for Windows applications. |
| [build-preferences-pages](../../RedSalamander/.github/skills/build-preferences-pages/SKILL.md) | Create or update RedSalamander settings-backed Preferences pages without breaking dirty tracking, Apply/OK persistence, Cancel semantics, schema metadata, localization, accessibility, or tests. |
| [cpp-build](../../RedSalamander/.github/skills/cpp-build/SKILL.md) | Build RedSalamander C++ projects using the PowerShell wrapper; the independently installed RedMonitor helper is outside this solution. |
| [direct2d-rendering](../../RedSalamander/.github/skills/direct2d-rendering/SKILL.md) | Direct2D and DirectWrite graphics rendering patterns for Windows. |
| [file-actions](../../RedSalamander/.github/skills/file-actions/SKILL.md) | File-action ID rules for viewer/editor/user-menu settings, parameterized commands, resolver behavior, and regression coverage. |
| [icon-cache](../../RedSalamander/.github/skills/icon-cache/SKILL.md) | Shell icon management and caching using IconCache class. |
| [perf-validation](../../RedSalamander/.github/skills/perf-validation/SKILL.md) | Performance-first development contract for RedSalamander. |
| [plugin-callbacks](../../RedSalamander/.github/skills/plugin-callbacks/SKILL.md) | Plugin callback patterns with cookie-based context for INavigationMenuCallback, IFileSystemCallback, and IFileSystemSearchCallback interfaces. |
| [theming](../../RedSalamander/.github/skills/theming/SKILL.md) | Theme system and color key management for RedSalamander. |
| [tooling-governance](../../RedSalamander/.github/skills/tooling-governance/SKILL.md) | Add, change, move or retire RedSalamander tooling with its inventory, help, callers, compatibility, dependency closure and owning specifications. |
| [win32-wndproc](../../RedSalamander/.github/skills/win32-wndproc/SKILL.md) | Win32 window procedure and message handling patterns. |
| [red-salamander-crash-forensics](../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) | Preserve and investigate RedSalamander dumps, sidecar stacks, fatal dialogs, hangs, timeouts, and failed selftest runs before rerunning a focused scenario. |

### RedXe (`.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [build-redxe](../../RedXe/.agents/skills/build-redxe/SKILL.md) | Build, clean, run, or smoke-test the RedXe Visual Studio solution. |
| [plugin-development](../../RedXe/.agents/skills/plugin-development/SKILL.md) | Implement or revise RedXe native plugin interfaces, factory exports, PluginManager loading, bundled plugin DLLs, or generic widget instances. |
| [settings-store](../../RedXe/.agents/skills/settings-store/SKILL.md) | Implement or revise RedXe settings paths, Debug and Release settings files, schemas, cold recovery, file stamps, directory watching, and UI-thread live reload. |

### RedPrism (`.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [build-redprism](../../RedPrism/.agents/skills/build-redprism/SKILL.md) | Build, clean, run, or smoke-test the RedPrism Visual Studio solution. |
| [consumer-dxui](../../RedPrism/.agents/skills/consumer-dxui/SKILL.md) | Add or update the pinned DxUi dependency, MSBuild imports, RedPrism theme or host adapters, and chrome built from DxUi controls. |
| [crash-handling](../../RedPrism/.agents/skills/crash-handling/SKILL.md) | Change how RedPrism records a crash (local minidumps, the pending marker, the next-start prompt, the --crash-probe gate) or add a failure path that must leave a dump. |
| [hlsl-composition](../../RedPrism/.agents/skills/hlsl-composition/SKILL.md) | Change or extend the RedPrism document-space GPU composition and its build-time HLSL (layer passes, coverage textures, clipping stacks, blend modes, blit, the brush compute kernel). |
| [numeric-goldens](../../RedPrism/.agents/skills/numeric-goldens/SKILL.md) | Maintain independent numeric expectations for RedPrism document, project I/O, rendering, tool and history behavior. |
| [settings-store](../../RedPrism/.agents/skills/settings-store/SKILL.md) | Implement or revise RedPrism settings (the JSON document under %LocalAppData%\RedPrism, its schema, cold recovery, atomic saves and the UI-thread live reload). |
| [test-harness](../../RedPrism/.agents/skills/test-harness/SKILL.md) | Write or extend RedPrism in-process tests, WARP goldens, fixture materialization, and harness screenshots under Tests/ and test.ps1. |

### RedTilde (`.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [build-redtilde](../../RedTilde/.agents/skills/build-redtilde/SKILL.md) | Build, restore or package RedTilde and diagnose its Windows compiler and dependency outputs. |
| [consumer-dxui](../../RedTilde/.agents/skills/consumer-dxui/SKILL.md) | Adopt or update the exact DxUi rich-text pin and its public native APIs in RedTilde. |
| [desktop-ui](../../RedTilde/.agents/skills/desktop-ui/SKILL.md) | Revise RedTilde native layout, contextual commands, live appearance and keyboard or UIA behavior. |
| [file-safety](../../RedTilde/.agents/skills/file-safety/SKILL.md) | Implement RedTilde Unicode open/save, dirty prompts, external-conflict handling and recovery. |
| [markdown-editing](../../RedTilde/.agents/skills/markdown-editing/SKILL.md) | Implement RedTilde rich, source, split and local Markdown editing with shared history and selection. |
| [media-math](../../RedTilde/.agents/skills/media-math/SKILL.md) | Add or verify local images, native in-document math and supported Mermaid diagrams in RedTilde. |
| [settings-crashes](../../RedTilde/.agents/skills/settings-crashes/SKILL.md) | Implement RedTilde live settings, local crash reports and restart diagnostics without telemetry. |
| [test-harness](../../RedTilde/.agents/skills/test-harness/SKILL.md) | Write RedTilde behavioral tests, deterministic hidden app captures and source-bound validation receipts. |

### RedMonitor (`.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [build-redmonitor](../../RedMonitor/.agents/skills/build-redmonitor/SKILL.md) | Build, restore or package standalone RedMonitor and diagnose toolchain failures. |
| [consumer-adoption](../../RedMonitor/.agents/skills/consumer-adoption/SKILL.md) | Integrate the pinned single-header RedMonitor SDK and optional installed helper into an application. |
| [file-safety](../../RedMonitor/.agents/skills/file-safety/SKILL.md) | Change RedMonitor Unicode file import, transactional export or cancellation. |
| [test-harness](../../RedMonitor/.agents/skills/test-harness/SKILL.md) | Add or run standalone RedMonitor behavioral tests, captures or source-bound evidence. |
| [transport-client](../../RedMonitor/.agents/skills/transport-client/SKILL.md) | Change the RedMonitor producer SDK, wire decoder or ETW session lifecycle. |
| [viewer-lifetime](../../RedMonitor/.agents/skills/viewer-lifetime/SKILL.md) | Change RedMonitor rendering, queueing, retained text, search or UI worker lifetime. |

### DxUi (`.agents/skills/`)

| Skill | Use it for |
| --- | --- |
| [build-dxui](../../DxUi/.agents/skills/build-dxui/SKILL.md) | Build, test or diagnose the standalone DxUi library and consumer outputs; use for toolchain/configuration failures. |
| [consumer-integration](../../DxUi/.agents/skills/consumer-integration/SKILL.md) | Add or update a pinned DxUi dependency, MSBuild imports and application adapters in a consumer. |
| [control-development](../../DxUi/.agents/skills/control-development/SKILL.md) | Implement or revise shared retained controls, their state and layout; not application-specific AV or file-manager behavior. |
| [embedded-rendering](../../DxUi/.agents/skills/embedded-rendering/SKILL.md) | Implement or inspect host-owned D3D11 integration, content preparation, cached surfaces and composition; not Win32 window presentation. |
| [input-accessibility](../../DxUi/.agents/skills/input-accessibility/SKILL.md) | Implement or verify pointer capture, keyboard, text/IME and UI Automation across DxUi hosts. |
| [win32-host](../../DxUi/.agents/skills/win32-host/SKILL.md) | Extract or revise the standalone HWND host, message handling, presentation and teardown; not the embedded RedXe renderer. |

`RedSalamanders/.github` has no skills; its `AGENTS.md` and `Specs/CI.md` are the whole contract (see [Shared-CI-Engine.md](Shared-CI-Engine.md)).

Return to [Index.md](Index.md).
