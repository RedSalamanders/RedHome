# RedTilde (`../RedTilde`)

- **Repository**: `RedSalamanders/RedTilde` (`versionBase: 0.1`, experimental API-5 consumer; `.ci/project.json` declares Winget `RedSalamanders.RedTilde`, alias `redtilde`)
- **Authoritative sibling docs**: [AGENTS.md](../../RedTilde/AGENTS.md), [Specs/README.md](../../RedTilde/Specs/README.md), [README.md](../../RedTilde/README.md), [capabilities.json](../../RedTilde/capabilities.json), [Active WIP](../../RedTilde/Specs/Plans/WIP/README.md)

## Overview & Architecture

Native Windows Markdown writing studio (**"Words, beautifully in flow"**) built on `DxUi` API 5 (`RichTextEditor` + lossless `MarkdownSyntax`), DirectWrite, and Direct2D:

- **Single Authoritative Document (`RedTilde/`)**: Switching between **Compose** (`Ctrl+1`), **Source** (`Ctrl+2`), and **Split** (`Ctrl+3`) never serializes rendered view state; the rich editor owns the single authoritative Markdown buffer, ACP selection, and undo/redo history. Split's source pane and equation inspectors are read-only derived mirrors.
- **Unicode File Safety & Recovery (`Common/`)**:
  - Preserves UTF-8 BOM and original EOLs; rejects invalid UTF-8, NUL bytes, or files exceeding current bounded unit limits before replacing the open document.
  - Ordinary saves write to a staged file in the destination directory and atomically replace. Symlinks save through to their followed target. Multiple hardlinks create an independent durable recovery copy before in-place overwrite so all aliases survive.
  - External modification conflicts prompt `Reload`, `Save As`, `Overwrite`, or `Cancel`. Debounced crash snapshots under `%LOCALAPPDATA%\RedTilde` restore into a dirty untitled/copy state requiring `Save As` so original files are never silently overwritten.
  - Optional persistent **Files** workspace pane (`Ctrl+Shift+O` / `Ctrl+Shift+E`) retains per-file edits, selection, and undo history across switches.
- **Safe Media, Math & Mermaid**:
  - Never executes HTML, scripts, or Mermaid directives. Links stay inert until confirmed external dispatch. Remote HTTP(S) images are disabled by default (opt-in bounded anonymous fetch in Settings).
  - Supports bounded native syntax coloring (C-like, JSON, PowerShell, diff), inline/display LaTeX math (`$...$`, multi-line `$$...$$`, `\[...\]`), and bounded Mermaid profiles (flowchart, state, class, sequence, pie, ER, Gantt, mind-map); unsupported syntax remains editable source.

## Repository-Specific Rules & Skills

- **Skills (`../../RedTilde/.agents/skills/`)**: Repo-specific skills `consumer-dxui`, `markdown-editing`, `desktop-ui`, `media-math` (shared `spec-workflow`, `test-evidence`, `crash-dumps`, `file-io-safety`, `app-settings`, and `native-build` live in `RedHome/.agents/skills/`).
- **Capability ledger**. [capabilities.json](../../RedTilde/capabilities.json) records supported features and outstanding gates. The [active plan index](../../RedTilde/Specs/Plans/WIP/README.md) tracks current work. The [Done index](../../RedTilde/Specs/Plans/Done/README.md) links to the archived v1.0.0 qualification plans.

## Key Commands

```powershell
Set-Location ..\RedTilde
.\validate.ps1
.\format.ps1 -Check
.\build.ps1 -Configuration Debug
.\Test-Changes.ps1 -Explain
.\Test-Changes.ps1
```

Return to [Index.md](Index.md).
