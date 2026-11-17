# RedHome

Multi-repository AI-agent headquarters, cross-project skills hub, and curated `wiki/` knowledge base for the **RedSalamanders** Windows C++/DirectX product family (adapted from Matt Pocock's Home Repo + LLM Wiki pattern).

Start with [AGENTS.md](AGENTS.md) for agent operating rules and [wiki/Index.md](wiki/Index.md) for the complete cross-project knowledge graph.

## Sibling Workspace Layout

Clone `RedHome` alongside the RedSalamanders product and library repositories under the same parent workspace root:

```text
<WorkspaceRoot>/
├── RedHome/                  # This repository (launch multi-repo coding agents here)
├── RedSalamander/            # Dual-pane DirectX file manager & VFS/Viewer/Terminal plugins
├── RedXe/                    # Win32 + D3D11 XENEON EDGE dashboard & widget/service runtime
├── RedPrism/                 # Win32 + D3D11 + HLSL raster image editor
├── RedTilde/                 # Native Markdown writing app (Compose / Source / Split)
├── DxUi/                     # Canonical shared DirectX static UI library (DxUi.lib)
├── RedMonitor/               # Optional local checkout of the independent diagnostics viewer
└── RedSalamanders/
    └── .github/              # Optional local checkout of the shared Unified CI engine
```

Tip: Open `RedHome\wiki` in **RedTilde** (`Ctrl+Shift+O` -> select `wiki`) or VS Code to browse all project dossiers with native Markdown rendering.

## Quick Commands

Requires PowerShell 7 (`pwsh`) and Git:

```powershell
# Validate all skills, thin pointer files, wiki and plan index coverage, and internal Markdown links
pwsh -NoProfile -File .\validate.ps1

# Also verify sibling links (../../RedSalamander, ../../RedXe, etc.) and the shared-skill pointer in each sibling
pwsh -NoProfile -File .\validate.ps1 -CheckSiblings

# Read-only status of all sibling branches, DxUi/RedMonitor locks, and .ci-engine pins
pwsh -NoProfile -File .\Tools\Get-WorkspaceStatus.ps1

# The same, plus clone hygiene: last fetch, local-only and merged branches, stale refs, extra worktrees
pwsh -NoProfile -File .\Tools\Get-WorkspaceStatus.ps1 -Hygiene
```

The `Validate RedHome` workflow runs both validations on every pull request, on `main`, and weekly, with the sibling repositories checked out beside `RedHome`.

## Claude Code Plugin

`RedHome` is also a Claude Code plugin marketplace (`.claude-plugin/`), so the shared skills load natively in Claude Code from any repository as `redhome:<skill>`:

```text
/plugin install redhome --marketplace RedSalamanders/RedHome
```

`.claude/settings.json` enables the plugin for this repository, and the product repositories opt in with the same file. Codex reads the same skills directly from `.agents/skills/` when started in `RedHome`.

## Plans

Cross-repository plans live in [Specs/Plans/WIP/](Specs/Plans/WIP/README.md). The active one is the convergence plan that federates skills, tooling, pins, and conventions across all repositories step by step. Work items that belong to one repository stay in that repository's own `Specs/Plans/`.

## Authority Boundary

`RedHome/wiki/` synthesizes cross-project architecture, terminology, and workflows, and routes to authoritative contracts. Product behavior, C++/COM ABI definitions, numeric goldens, `capabilities.json`, and dependency locks remain owned by each sibling repository (`../<Project>/Specs/`, `../<Project>/Dependencies/`).
