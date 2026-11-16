# RedHome

Central AI-agent workspace for the **RedSalamanders** organization. Start sessions here so cross-repo work sees the whole system. `CLAUDE.md` and `.github/copilot-instructions.md` are one-line pointers to this file.

## Other Repos

All sibling repositories live beside `RedHome` (`..`):

- **RedSalamander** (C++23 dual-pane DirectX file manager, VFS/Viewer/Terminal plugins): `../RedSalamander`. Clone from https://github.com/RedSalamanders/RedSalamander.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it (repo skills live in `.github/skills/`). Context: [wiki/RedSalamander.md](wiki/RedSalamander.md).
- **RedXe** (Win32 + D3D11 XENEON EDGE dashboard, widget/service/action COM plugins): `../RedXe`. Clone from https://github.com/RedSalamanders/RedXe.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedXe.md](wiki/RedXe.md).
- **RedPrism** (Win32 + D3D11 + HLSL raster image editor, `.prism` store, numeric goldens): `../RedPrism`. Clone from https://github.com/RedSalamanders/RedPrism.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedPrism.md](wiki/RedPrism.md).
- **RedTilde** (Native Windows Markdown editor with Compose/Source/Split, math, and Mermaid): `../RedTilde`. Clone from https://github.com/RedSalamanders/RedTilde.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedTilde.md](wiki/RedTilde.md).
- **DxUi** (Shared DirectX static UI and RichText library `DxUi.lib`): `../DxUi`. Clone from https://github.com/RedSalamanders/DxUi.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it; library changes never implicitly update consumers, and never reset this checkout during consumer restores. Context: [wiki/DxUi.md](wiki/DxUi.md).
- **RedMonitor** (Independent ETW/TraceLogging diagnostics viewer and single-header `Client.h` SDK): `../RedMonitor`. Clone from https://github.com/RedSalamanders/RedMonitor.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it; apps vendor only hash-pinned `Client.h`. Context: [wiki/Dependency-And-CI-Matrix.md](wiki/Dependency-And-CI-Matrix.md).
- **RedSalamanders/.github** (Shared Unified CI policy v1, reusable workflows, `Update-ProjectPin.ps1`): `../RedSalamanders/.github`. Clone from https://github.com/RedSalamanders/.github.git if missing (each product also keeps a clean detached pin at `<repo>/.ci-engine`). Read its `AGENTS.md` and `Specs/CI.md` before changing it. Context: [wiki/Shared-CI-Engine.md](wiki/Shared-CI-Engine.md).

## Shared Docs

- [wiki/Index.md](wiki/Index.md) — Cross-project wiki hub (synthesizes and routes; never overrides a repo's `Specs/` or lock files).
- [wiki/Shared-Engineering-Policies.md](wiki/Shared-Engineering-Policies.md) — Shared WIL/C++ rules, `/Wall` native build policy, `Changes/` fragments, scoped testing, desktop-focus lease, and drive-root output policy.
- [wiki/Ecosystem-Architecture.md](wiki/Ecosystem-Architecture.md) — Graphics, UI-host, plugin-ABI, and settings comparison across apps.
- [wiki/Glossary.md](wiki/Glossary.md) — Canonical RedSalamanders vocabulary.

## Skills

- [workspace-doctor](.agents/skills/workspace-doctor/SKILL.md) — Read-only sibling checkout, lock, and `.ci-engine` health check.
- [wiki-sync](.agents/skills/wiki-sync/SKILL.md) — Reconcile `wiki/` pages with sibling `Specs/`, locks, and WIP indexes.
- [cross-repo-pins](.agents/skills/cross-repo-pins/SKILL.md) — Coordinate `DxUi`, `RedMonitor`, and `.ci-engine` pin waves safely.
- [grill-cross-repo](.agents/skills/grill-cross-repo/SKILL.md) — Stress-test cross-repo proposals against `wiki/` and owning domain specs.
- [to-project-wip](.agents/skills/to-project-wip/SKILL.md) — Decompose cross-repo designs into producer-first sibling `Specs/Plans/WIP/` plans.
- [handoff-note](.agents/skills/handoff-note/SKILL.md) — Capture durable cross-repo lessons in `wiki/` and produce a clean handoff.

Validate `RedHome` edits with `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings`.
