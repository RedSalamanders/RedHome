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
# Validate all skills, thin pointer files, wiki index coverage, and internal Markdown links
pwsh -NoProfile -File .\validate.ps1

# Also verify sibling links (../../RedSalamander, ../../RedXe, etc.) against local checkouts
pwsh -NoProfile -File .\validate.ps1 -CheckSiblings

# Read-only status of all sibling branches, DxUi/RedMonitor locks, and .ci-engine pins
pwsh -NoProfile -File .\Tools\Get-WorkspaceStatus.ps1
```

## Plans

Cross-repository plans live in [Specs/Plans/WIP/](Specs/Plans/WIP/README.md). The active one is the convergence plan that federates skills, tooling, pins, and conventions across all repositories step by step. Work items that belong to one repository stay in that repository's own `Specs/Plans/`.

## Authority Boundary

`RedHome/wiki/` synthesizes cross-project architecture, terminology, and workflows, and routes to authoritative contracts. Product behavior, C++/COM ABI definitions, numeric goldens, `capabilities.json`, and dependency locks remain owned by each sibling repository (`../<Project>/Specs/`, `../<Project>/Dependencies/`).
