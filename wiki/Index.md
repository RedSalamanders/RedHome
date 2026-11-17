# RedSalamanders Knowledge Base (`wiki/`)

Welcome to the `RedHome` LLM Wiki—the cross-repository navigation map, architecture synthesis, and operational guide for the **RedSalamanders** Windows C++/DirectX family.

> Authority rule: `wiki/` synthesizes and routes across sibling repositories (`../*` from `RedHome` root, `../../*` from `wiki/`). Normative product contracts, C++/COM ABIs, numeric goldens, and exact commit locks remain owned by each sibling repository's `Specs/` and `Dependencies/` folders.

## Cross-Cutting Maps

- [Ecosystem-Architecture.md](Ecosystem-Architecture.md) — Side-by-side comparison of UI hosting, Direct3D/Direct2D pipelines, plugin ABIs, threading, and settings across all products.
- [Shared-Engineering-Policies.md](Shared-Engineering-Policies.md) — Shared C++/WIL rules, native compiler profiles and repository exceptions, `Changes/` fragments, scoped testing (`Test-Changes.ps1`), harness captures, and drive-root output policy.
- [Dependency-And-CI-Matrix.md](Dependency-And-CI-Matrix.md) — Producer/consumer dependency graph (`DxUi.lock.json`, `RedMonitor.lock.json`, `.ci/project.json`, `.ci-engine`) and pin-wave runbook.
- [Glossary.md](Glossary.md) — Shared RedSalamanders terminology (`EmbeddedHost`, `WindowHost`, `ACP`, `ci-state`, desktop lease, short 16-hex fingerprints, etc.).
- [Working-From-RedHome.md](Working-From-RedHome.md) — Session start checklist, per-repository command map, branch and worktree conventions, harness discovery, and what to do when `RedHome` is not beside a repository.
- [Skill-Catalog.md](Skill-Catalog.md) — Every shared and repository-local skill, routed by task, with the per-repository references each shared skill carries.

## Application Dossiers

- [RedSalamander.md](RedSalamander.md) — `../RedSalamander` (`v7.0`): Dual-pane DirectX file manager, VFS/Viewer/Terminal COM plugins, background search service, and ~90 language satellites.
- [RedXe.md](RedXe.md) — `../RedXe` (`v1.0`): Win32 + Direct3D 11 XENEON EDGE dashboard, GPU/window widgets, `AVControl`, `Logicon` HID++ service, and `zoom.action.dll`.
- [RedPrism.md](RedPrism.md) — `../RedPrism` (`v0.1`): Win32 + Direct3D 11 + HLSL raster image editor, sparse rasters, `.prism` format-7 store, CPU/GPU kernels, and numeric goldens.
- [RedTilde.md](RedTilde.md) — `../RedTilde` (`v0.1`): Native Markdown writing app (Compose/Source/Split), atomic/hardlink-safe Unicode storage, bounded Mermaid diagrams, and native LaTeX math.
- [RedMonitor.md](RedMonitor.md) — `../RedMonitor` (`v0.1`): Standalone ETW/TraceLogging diagnostics viewer (`DxUi` + D2D/D3D11) and single-header `Client.h` producer SDK.

## Shared Producers & Infrastructure

- [DxUi.md](DxUi.md) — `../DxUi` (`v0.1` SDK): Canonical static UI library (`DxUi.lib`, 35 retained controls, `EmbeddedHost`, `RichTextEditor`, lossless `MarkdownSyntax`).
- [Shared-CI-Engine.md](Shared-CI-Engine.md) — `../RedSalamanders/.github` (`Policy v1`): Unified CI workflows, 5-minute quiet coordinator, dual-arch Release gate, local `Ci.*.psm1` modules, and Winget promotion.

## Plans

- [../Specs/Plans/WIP/README.md](../Specs/Plans/WIP/README.md) — Active cross-repository plans. Dated pin snapshots, branch inventories, and convergence steps live there, not in `wiki/`.
