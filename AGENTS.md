# RedHome — Multi-Repository Agent Headquarters

`RedHome` is the central AI-agent launchpad, cross-repository skill hub, and curated `wiki/` knowledge graph for the **RedSalamanders** Windows C++/DirectX ecosystem (adapted from Matt Pocock's Home Repo + LLM Wiki pattern).

Start with [wiki/Index.md](wiki/Index.md) for cross-project architecture, terminology, and project dossiers.

## Sibling Workspace Map

All RedSalamanders repositories live as direct siblings of `RedHome` under the same parent workspace root (`..`):

| Project | Sibling Path | Kind | Summary & Wiki Entry |
| --- | --- | --- | --- |
| **RedSalamander** | `../RedSalamander` | Application (`7.0`) | Dual-pane DirectX file manager, VFS/Viewer/Terminal plugins, search service — [wiki/RedSalamander.md](wiki/RedSalamander.md) |
| **RedXe** | `../RedXe` | Application (`1.0`) | Win32 + D3D11 XENEON EDGE dashboard, GPU/window widgets, AVControl, Logicon — [wiki/RedXe.md](wiki/RedXe.md) |
| **RedPrism** | `../RedPrism` | Application (`0.1`) | Win32 + D3D11 + HLSL raster image editor, sparse rasters, `.prism` store, kernels — [wiki/RedPrism.md](wiki/RedPrism.md) |
| **RedTilde** | `../RedTilde` | Application (`0.1`) | Native Markdown editor (Compose/Source/Split), bounded Mermaid & LaTeX math — [wiki/RedTilde.md](wiki/RedTilde.md) |
| **DxUi** | `../DxUi` | Static SDK (`0.1`) | Shared retained DirectX controls & RichText (`DxUi.lib`, 35 controls) — [wiki/DxUi.md](wiki/DxUi.md) |
| **RedMonitor** | `../RedMonitor` | Application / Header | Independent ETW diagnostics viewer; apps vendor hash-pinned `Client.h` — [wiki/Dependency-And-CI-Matrix.md](wiki/Dependency-And-CI-Matrix.md) |
| **Shared CI** | `../RedSalamanders/.github` | CI Engine (`v1`) | Unified CI workflows, `Update-ProjectPin.ps1`, `Ci.*.psm1` modules — [wiki/Shared-CI-Engine.md](wiki/Shared-CI-Engine.md) |

Use portable parent-relative paths (`../RedSalamander`, `../RedXe`, `../RedPrism`, `../RedTilde`, `../DxUi`) from the `RedHome` root (and `../../<Project>` from inside `wiki/`)—never hardcode developer drive letters.

## Iron Laws (Mandatory Boundaries)

1. **Sibling Entry Protocol**: Before editing any file inside `../<Project>/`, you MUST read:
   - `../<Project>/AGENTS.md`
   - `../<Project>/Specs/README.md`
   - The owning domain contract under `../<Project>/Specs/<Domain>/*.md`
   - The applicable project-local skill (`../<Project>/.agents/skills/` or `../RedSalamander/.github/skills/`).
2. **Synthesize & Route — Never Override Authority**: `RedHome/wiki/` synthesizes cross-project knowledge and links to authoritative sources. It never overrides a sibling repository's `Specs/<Domain>/*.md`, COM/C++ ABI headers, numeric goldens, `capabilities.json`, `Dependencies/*.lock.json`, or `.ci/project.json`.
3. **Producer-Consumer Isolation**: Changing `../DxUi`, `../RedMonitor`, or `../RedSalamanders/.github` never implicitly updates any consumer. Never `git reset`, `clean`, or `checkout` a developer's sibling repository during dependency restore or inspection.
4. **Drive-Root Output Policy**: Never create scratch, caches, evidence, copied checkouts, or output directories directly at a drive root (`D:\`, `C:\`, `Z:\`). Keep `RedHome` generated outputs strictly under `RedHome/.build/`. Creating `<Project>.Perf` or any new drive-root folder requires explicit user authorization of the exact path first.
5. **No Shadow Product Backlogs**: Active implementation plans belong in each owning repository's `Specs/Plans/WIP/README.md`, sequenced producer-first (`DxUi` / `.github`) and consumer-second (`RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`).
6. **Non-Destructive Process & Focus Rules**: Never kill independently launched product executables (`RedSalamander.exe`, `RedXe.exe`, `RedPrism.exe`, `RedTilde.exe`). Never take foreground desktop focus for interactive test suites without explicit agreement from the person at the desktop. Never use desktop screenshot tools or Computer Use for product docs/specs—use each application's deterministic harness capture.

## Canonical Guidance & Pointer Parity

- `AGENTS.md` (this file) is the single canonical instruction source for `RedHome`.
- `CLAUDE.md` and `.github/copilot-instructions.md` are thin pointers to `AGENTS.md`; keep them free of divergent rules.
- Repository skills live in `.agents/skills/` and are validated by `./validate.ps1` (PowerShell 7, no Python).

## Skills

| Skill | Use it for |
| --- | --- |
| [workspace-doctor](.agents/skills/workspace-doctor/SKILL.md) | Read-only health check across sibling checkouts: branches, dirty worktrees, `DxUi`/`RedMonitor` locks, and `.ci-engine` alignment |
| [wiki-sync](.agents/skills/wiki-sync/SKILL.md) | Reconcile `wiki/*.md` pages against sibling `AGENTS.md`, `Specs/README.md`, locks, and WIP indexes |
| [cross-repo-pins](.agents/skills/cross-repo-pins/SKILL.md) | Plan or audit `DxUi`, `RedMonitor`, and `.ci-engine` pin updates across producer and consumer repositories |
| [grill-cross-repo](.agents/skills/grill-cross-repo/SKILL.md) | Stress-test a cross-project feature, shared `DxUi` control request, or build/CI change against `wiki/` and owning specs |
| [to-project-wip](.agents/skills/to-project-wip/SKILL.md) | Turn a settled cross-repo design into sequenced, indexed `Specs/Plans/WIP/` plans in the owning repositories |
| [handoff-note](.agents/skills/handoff-note/SKILL.md) | Distill multi-repo debugging/architecture discoveries into permanent `wiki/` notes and a clean session handoff |

## Validation

Run before declaring any `RedHome` edit complete:

```powershell
pwsh -NoProfile -File .\validate.ps1 -CheckSiblings
```
