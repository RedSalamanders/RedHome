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
| Build, restore, package, toolchain failures | [native-build](../.agents/skills/native-build/SKILL.md) | Its `references/repository-facts.md`. Until its copy is removed: `RedSalamander` [cpp-build](../../RedSalamander/.github/skills/cpp-build/SKILL.md) |
| Tests, goldens, captures, evidence | [test-evidence](../.agents/skills/test-evidence/SKILL.md) | Its `references/repository-facts.md`; `RedPrism` [numeric-goldens](../../RedPrism/.agents/skills/numeric-goldens/SKILL.md). Until its copy is removed: `RedSalamander` [perf-validation](../../RedSalamander/.github/skills/perf-validation/SKILL.md) |
| `DxUi` pin bumps and consumer adapters | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | `DxUi` [consumer-integration](../../DxUi/.agents/skills/consumer-integration/SKILL.md), `RedPrism` [consumer-dxui](../../RedPrism/.agents/skills/consumer-dxui/SKILL.md), `RedTilde` [consumer-dxui](../../RedTilde/.agents/skills/consumer-dxui/SKILL.md) |
| `RedMonitor` client adoption and transport | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | `RedMonitor` [consumer-adoption](../../RedMonitor/.agents/skills/consumer-adoption/SKILL.md), `RedMonitor` [transport-client](../../RedMonitor/.agents/skills/transport-client/SKILL.md) |
| Shared CI engine pin, `.ci-engine` health | [cross-repo-pins](../.agents/skills/cross-repo-pins/SKILL.md) | [Shared-CI-Engine.md](Shared-CI-Engine.md) |
| Settings, preferences, themes | [app-settings](../.agents/skills/app-settings/SKILL.md), then [yyjson](../.agents/skills/yyjson/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [build-preferences-pages](../../RedSalamander/.github/skills/build-preferences-pages/SKILL.md), `RedSalamander` [theming](../../RedSalamander/.github/skills/theming/SKILL.md) |
| Crash dumps and failure diagnostics | [crash-dumps](../.agents/skills/crash-dumps/SKILL.md) | Its `references/repository-facts.md`; `RedSalamander` [red-salamander-crash-forensics](../../RedSalamander/.agents/skills/red-salamander-crash-forensics/SKILL.md) to investigate a dump |
| File open/save safety | [file-io-safety](../.agents/skills/file-io-safety/SKILL.md) | Its `references/repository-facts.md` |
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
| [native-build](../.agents/skills/native-build/SKILL.md) | [repository-facts](../.agents/skills/native-build/references/repository-facts.md) |
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

`build-redxe` and `settings-store` are folded into the shared [native-build](../.agents/skills/native-build/SKILL.md) and [app-settings](../.agents/skills/app-settings/SKILL.md) (convergence CV-2-12).

| Skill | Use it for |
| --- | --- |
| [plugin-development](../../RedXe/.agents/skills/plugin-development/SKILL.md) | Implement or revise RedXe native plugin interfaces, factory exports, PluginManager loading, bundled plugin DLLs, or generic widget instances. |

### RedPrism (`.agents/skills/`)

`build-redprism`, `test-harness`, `settings-store`, and `crash-handling` are folded into the shared [native-build](../.agents/skills/native-build/SKILL.md), [test-evidence](../.agents/skills/test-evidence/SKILL.md), [app-settings](../.agents/skills/app-settings/SKILL.md), and [crash-dumps](../.agents/skills/crash-dumps/SKILL.md) (convergence CV-2-12).

| Skill | Use it for |
| --- | --- |
| [consumer-dxui](../../RedPrism/.agents/skills/consumer-dxui/SKILL.md) | Add or update the pinned DxUi dependency, MSBuild imports, RedPrism theme or host adapters, and chrome built from DxUi controls. |
| [hlsl-composition](../../RedPrism/.agents/skills/hlsl-composition/SKILL.md) | Change or extend the RedPrism document-space GPU composition and its build-time HLSL (layer passes, coverage textures, clipping stacks, blend modes, blit, the brush compute kernel). |
| [numeric-goldens](../../RedPrism/.agents/skills/numeric-goldens/SKILL.md) | Maintain independent numeric expectations for RedPrism document, project I/O, rendering, tool and history behavior. |

### RedTilde (`.agents/skills/`)

`build-redtilde`, `file-safety`, `settings-crashes`, and `test-harness` are folded into the shared [native-build](../.agents/skills/native-build/SKILL.md), [file-io-safety](../.agents/skills/file-io-safety/SKILL.md), [app-settings](../.agents/skills/app-settings/SKILL.md) with [crash-dumps](../.agents/skills/crash-dumps/SKILL.md), and [test-evidence](../.agents/skills/test-evidence/SKILL.md) (convergence CV-2-12).

| Skill | Use it for |
| --- | --- |
| [consumer-dxui](../../RedTilde/.agents/skills/consumer-dxui/SKILL.md) | Adopt or update the exact DxUi rich-text pin and its public native APIs in RedTilde. |
| [desktop-ui](../../RedTilde/.agents/skills/desktop-ui/SKILL.md) | Revise RedTilde native layout, contextual commands, live appearance and keyboard or UIA behavior. |
| [markdown-editing](../../RedTilde/.agents/skills/markdown-editing/SKILL.md) | Implement RedTilde rich, source, split and local Markdown editing with shared history and selection. |
| [media-math](../../RedTilde/.agents/skills/media-math/SKILL.md) | Add or verify local images, native in-document math and supported Mermaid diagrams in RedTilde. |

### RedMonitor (`.agents/skills/`)

`build-redmonitor`, `file-safety`, and `test-harness` are folded into the shared [native-build](../.agents/skills/native-build/SKILL.md), [file-io-safety](../.agents/skills/file-io-safety/SKILL.md), and [test-evidence](../.agents/skills/test-evidence/SKILL.md) (convergence CV-2-12).

| Skill | Use it for |
| --- | --- |
| [consumer-adoption](../../RedMonitor/.agents/skills/consumer-adoption/SKILL.md) | Integrate the pinned single-header RedMonitor SDK and optional installed helper into an application. |
| [transport-client](../../RedMonitor/.agents/skills/transport-client/SKILL.md) | Change the RedMonitor producer SDK, wire decoder or ETW session lifecycle. |
| [viewer-lifetime](../../RedMonitor/.agents/skills/viewer-lifetime/SKILL.md) | Change RedMonitor rendering, queueing, retained text, search or UI worker lifetime. |

### DxUi (`.agents/skills/`)

`build-dxui` is folded into the shared [native-build](../.agents/skills/native-build/SKILL.md) (convergence CV-2-12).

| Skill | Use it for |
| --- | --- |
| [consumer-integration](../../DxUi/.agents/skills/consumer-integration/SKILL.md) | Add or update a pinned DxUi dependency, MSBuild imports and application adapters in a consumer. |
| [control-development](../../DxUi/.agents/skills/control-development/SKILL.md) | Implement or revise shared retained controls, their state and layout; not application-specific AV or file-manager behavior. |
| [embedded-rendering](../../DxUi/.agents/skills/embedded-rendering/SKILL.md) | Implement or inspect host-owned D3D11 integration, content preparation, cached surfaces and composition; not Win32 window presentation. |
| [input-accessibility](../../DxUi/.agents/skills/input-accessibility/SKILL.md) | Implement or verify pointer capture, keyboard, text/IME and UI Automation across DxUi hosts. |
| [win32-host](../../DxUi/.agents/skills/win32-host/SKILL.md) | Extract or revise the standalone HWND host, message handling, presentation and teardown; not the embedded RedXe renderer. |

`RedSalamanders/.github` has no skills; its `AGENTS.md` and `Specs/CI.md` are the whole contract (see [Shared-CI-Engine.md](Shared-CI-Engine.md)).

Return to [Index.md](Index.md).
