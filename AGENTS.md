# RedHome

Central AI-agent workspace for the **RedSalamanders** organization. Start sessions here so cross-repo work sees the whole system. `CLAUDE.md` and `.github/copilot-instructions.md` are one-line pointers to this file.

## Other Repos

All sibling repositories live beside `RedHome` (`..`):

- **RedSalamander** (C++23 dual-pane DirectX file manager, VFS/Viewer/Terminal plugins): `../RedSalamander`. Clone from https://github.com/RedSalamanders/RedSalamander.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it (repo skills live in `.github/skills/`). Context: [wiki/RedSalamander.md](wiki/RedSalamander.md).
- **RedXe** (Win32 + D3D11 XENEON EDGE dashboard, widget/service/action COM plugins): `../RedXe`. Clone from https://github.com/RedSalamanders/RedXe.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedXe.md](wiki/RedXe.md).
- **RedPrism** (Win32 + D3D11 + HLSL raster image editor, `.prism` store, numeric goldens): `../RedPrism`. Clone from https://github.com/RedSalamanders/RedPrism.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedPrism.md](wiki/RedPrism.md).
- **RedTilde** (Native Windows Markdown editor with Compose/Source/Split, math, and Mermaid): `../RedTilde`. Clone from https://github.com/RedSalamanders/RedTilde.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it. Context: [wiki/RedTilde.md](wiki/RedTilde.md).
- **DxUi** (Shared DirectX static UI and RichText library `DxUi.lib`): `../DxUi`. Clone from https://github.com/RedSalamanders/DxUi.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it; library changes never implicitly update consumers, and never reset this checkout during consumer restores. Context: [wiki/DxUi.md](wiki/DxUi.md).
- **RedMonitor** (Independent ETW/TraceLogging diagnostics viewer and single-header `Client.h` SDK): `../RedMonitor`. Clone from https://github.com/RedSalamanders/RedMonitor.git if missing. Read its `AGENTS.md` and `Specs/README.md` before changing it; apps vendor only hash-pinned `Client.h`. Context: [wiki/RedMonitor.md](wiki/RedMonitor.md).
- **RedSalamanders/.github** (Shared Unified CI policy v1, reusable workflows, `Update-ProjectPin.ps1`): `../RedSalamanders/.github`. Clone from https://github.com/RedSalamanders/.github.git if missing (each product also keeps a clean detached pin at `<repo>/.ci-engine`). Read its `AGENTS.md` and `Specs/CI.md` before changing it. Context: [wiki/Shared-CI-Engine.md](wiki/Shared-CI-Engine.md).

## Shared Docs

- [wiki/Index.md](wiki/Index.md) — Cross-project wiki hub (synthesizes and routes; never overrides a repo's `Specs/` or lock files).
- [wiki/Shared-Engineering-Policies.md](wiki/Shared-Engineering-Policies.md) — Shared WIL/C++ rules, `/Wall` native build policy, `Changes/` fragments, scoped testing, desktop-focus lease, and drive-root output policy.
- [wiki/Ecosystem-Architecture.md](wiki/Ecosystem-Architecture.md) — Graphics, UI-host, plugin-ABI, and settings comparison across apps.
- [wiki/Glossary.md](wiki/Glossary.md) — Canonical RedSalamanders vocabulary.

## Shared Skills

- [cross-repo-pins](.agents/skills/cross-repo-pins/SKILL.md) — Read-only sibling checkout diagnostics and `DxUi`, `RedMonitor`, and `.ci-engine` pin waves.
- [wiki-sync](.agents/skills/wiki-sync/SKILL.md) — Reconcile `wiki/` pages with sibling repos and produce clean multi-repo session handoffs.
- [grill-cross-repo](.agents/skills/grill-cross-repo/SKILL.md) — Stress-test cross-repo proposals against `wiki/` and owning domain specs.
- [improve](.agents/skills/improve/SKILL.md) — Audit codebases or instruction ecosystems and produce evidence-backed findings and handoff plans.
- [spec-workflow](.agents/skills/spec-workflow/SKILL.md) — Maintain normative domain contracts and sequence single-repo or cross-repo `WIP -> Done` plans.
- [modern-cpp-windows](.agents/skills/modern-cpp-windows/SKILL.md) — C++23 `stdcpplatest`, `/Wall` zero-warning rules, Win32 header ordering, `HRESULT`, and ABI exception boundaries.
- [wil-raii](.agents/skills/wil-raii/SKILL.md) — WIL RAII ownership for COM interfaces, `HWND`s, GDI/D2D scopes, and `scope_exit` cleanup.
- [yyjson](.agents/skills/yyjson/SKILL.md) — Safe `yyjson` document lifetimes, mutable string copying (`*_strcpy`/`*_strncpy`), and validation.
- [localization](.agents/skills/localization/SKILL.md) — UTF-8 `.rc` `STRINGTABLE`/`MENU` resources, positional `{0}` placeholders, and UIA accessible names.
- [performance-resources](.agents/skills/performance-resources/SKILL.md) — Zero steady-state hot-path allocations, bounded storage, event-blocked idle states, and paired baselines.
- [d3d11-win32-host](.agents/skills/d3d11-win32-host/SKILL.md) — Real-time Win32 windowing, per-monitor D3D11 device selection, flip swap chains, occlusion, WARP, and device loss.

Validate `RedHome` edits with `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings`.
