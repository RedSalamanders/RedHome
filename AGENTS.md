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
- [wiki/Shared-Engineering-Policies.md](wiki/Shared-Engineering-Policies.md) — Shared WIL/C++ rules, native compiler profiles and repository exceptions, `Changes/` fragments, scoped testing, desktop-focus lease, and drive-root output policy.
- [wiki/Ecosystem-Architecture.md](wiki/Ecosystem-Architecture.md) — Graphics, UI-host, plugin-ABI, and settings comparison across apps.
- [wiki/Glossary.md](wiki/Glossary.md) — Canonical RedSalamanders vocabulary.
- [wiki/Working-From-RedHome.md](wiki/Working-From-RedHome.md) — Session start, per-repository command map, branch and worktree conventions, and harness discovery.
- [wiki/Skill-Catalog.md](wiki/Skill-Catalog.md) — Every shared and repository-local skill, routed by task.
- [Specs/Plans/WIP/README.md](Specs/Plans/WIP/README.md) — Active cross-repository plans (currently the convergence plan).

## Shared Skills

Shared skills with `references/repository-facts.md` collect product-specific paths, helpers and checks there. They end with `Repository Facts` and `Differences To Converge`, in that order. Other skills carry the references their workflow needs.

- [cross-repo-pins](.agents/skills/cross-repo-pins/SKILL.md) — Read-only sibling checkout diagnostics and `DxUi`, `RedMonitor`, and `.ci-engine` pin waves.
- [wiki-sync](.agents/skills/wiki-sync/SKILL.md) — Reconcile `wiki/` pages with sibling repos and produce clean multi-repo session handoffs.
- [grill-cross-repo](.agents/skills/grill-cross-repo/SKILL.md) — Stress-test cross-repo proposals against `wiki/` and owning domain specs.
- [improve](.agents/skills/improve/SKILL.md) — Audit codebases or instruction ecosystems and produce evidence-backed findings and handoff plans.
- [spec-workflow](.agents/skills/spec-workflow/SKILL.md) — Maintain normative domain contracts and sequence single-repo or cross-repo `WIP -> Done` plans.
- [modern-cpp-windows](.agents/skills/modern-cpp-windows/SKILL.md) — C++23 `stdcpplatest`, repository warning profiles, Win32 header ordering, `HRESULT`, and ABI exception boundaries.
- [wil-raii](.agents/skills/wil-raii/SKILL.md) — WIL RAII ownership for COM interfaces, `HWND`s, GDI/D2D scopes, and `scope_exit` cleanup.
- [yyjson](.agents/skills/yyjson/SKILL.md) — Safe `yyjson` document lifetimes, mutable string copying (`*_strcpy`/`*_strncpy`), and validation.
- [localization](.agents/skills/localization/SKILL.md) — UTF-8 `.rc` `STRINGTABLE`/`MENU` resources, positional `{0}` placeholders, and UIA accessible names.
- [performance-resources](.agents/skills/performance-resources/SKILL.md) — Zero steady-state hot-path allocations, bounded storage, event-blocked idle states, and paired baselines.
- [d3d11-win32-host](.agents/skills/d3d11-win32-host/SKILL.md) — Win32 window rules for every host, then D3D11 device selection, flip swap chains, occlusion, WARP, and device loss for idle-loop and `WM_PAINT` hosts (`RedXe`, `RedPrism`, `RedMonitor`, `DxUi` `ControlHost`).
- [test-evidence](.agents/skills/test-evidence/SKILL.md) — Behavioral tests with independent expectations, hidden non-activating captures, shared-process suite isolation, source-bound receipts, and the performance-evidence workflow.
- [crash-dumps](.agents/skills/crash-dumps/SKILL.md) — Local minidumps and a pending marker from a fault path that allocates nothing, the next-start prompt, retention, and isolated child-process crash probes.
- [file-io-safety](.agents/skills/file-io-safety/SKILL.md) — Strict streaming validation before publishing, owned same-directory temporaries with flush and atomic replace, external-identity checks, and completion by request identity.
- [app-settings](.agents/skills/app-settings/SKILL.md) — The settings contract owns the fields, field-level fallback, cold recovery from the template, atomic saves, and the coalesced watcher that posts live reloads to the UI thread (plan D19).
- [native-build](.agents/skills/native-build/SKILL.md) — Root build, restore, and package entry points, the six-profile matrix, pinned dependencies under `.build`, a running-executable preflight that never kills, ARM64 cross-builds, and Release-only packages with a clean-extraction smoke.

Validate `RedHome` edits with `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings`.
