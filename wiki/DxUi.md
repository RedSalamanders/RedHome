# DxUi (`../DxUi`)

- **Repository**: `RedSalamanders/DxUi` (`kind: sdk`, `apiRevision: 6`, static archive `DxUi.lib`)
- **Authoritative sibling docs**: [AGENTS.md](../../DxUi/AGENTS.md), [Specs/README.md](../../DxUi/Specs/README.md), [README.md](../../DxUi/README.md), [capabilities.json](../../DxUi/capabilities.json), [Active WIP](../../DxUi/Specs/Plans/WIP/README.md)

## Overview & Architecture

Canonical home of shared DirectX UI controls and rich Markdown/text layout for RedSalamanders:

- **Public Headers (`include/DxUi/`)**:
  - `DxUi.h`, `ControlCatalog.h`, `ThemeColors.h`, `FrameRuntime.h`, `Diagnostics.h`: 35 retained controls, `FlexPanel`, `FormPanel`/`FormField`, neutral theme, frame clock, and reduced-motion support.
  - `Embedded.h`: Borrowed-device `GraphicsDevice` pool and `EmbeddedHost` (`Prepare` / `PrepareInteraction` / `Composite` / `UpdateAccessibility`).
  - `RichDocument.h`, `RichMarkdown.h`, `RichTextLayout.h`, `MarkdownSyntax.h`: Lossless Unicode GFM block/inline parser, `RichTextEditor` with TSF/IME (`TextStoreACP`) and UIA providers, bounded HTML/math/Mermaid rendering, and `FileDrop` / `RichImage` SVG & bitmap support.
- **Consumer Interface (`capabilities.json`)**:
  - The manifest lists every supported source import, script and exported module function. Import `Build/NativeBuildPolicy.props` through `Directory.Build.props` before MSVC selects its tools. That default preserves an explicit compiler-host choice.
  - Source consumers opt in to shared Release optimization by setting `NativeBuildReleaseOptimization` before importing `Build/NativeBuildPolicy.targets`. SDK consumers set it before importing `DxUi.Sdk.props`. The repository's build spec owns the import order and exact requirements. [Build and consumption contract](../../DxUi/Specs/Build/Build_ToolchainAndConsumption.md)
  - API 5 introduced the requirement to install the application-owned failure host before constructing controls or entering `DxUi` scopes.

The [source import archive](../../DxUi/Specs/SourceImport/README.md) records attribution, test disposition and migration history. DxUi's validation tools read those records.

## Repository-Specific Rules & Skills

- **Skills (`../../DxUi/.agents/skills/`)**: Repo-specific skills `control-development`, `embedded-rendering`, `win32-host`, `input-accessibility`, `consumer-integration` (shared skills `performance-resources`, `modern-cpp-windows`, `spec-workflow`, `test-evidence`, `native-build` live in `RedHome/.agents/skills/`).
- **New Control Checklist**: Requires `ControlCatalog` entry, interaction tests, populated gallery tile (`gallery.ps1 -PublishDocs`), `docs/controls.md` entry, and `Specs/UI/UI_DesignSystem.md` guideline + preview.
- **Paired Complex-UI Performance**: Every `test.ps1` run reports complex-UI (83-control) FPS and memory; changes require paired before/after baseline comparison.
- **No Hosted Public Release**: `DxUi` has no public GitHub Release or Winget workflow; qualified SDK ZIPs (verified with clean extracted-SDK consumer builds, license closure, and LNK4099 PDB-isolation negative controls) remain internal CI artifacts.

- Scoped testing uses the pinned shared runner. DxUi owns direct native build receipts, SDK attestation and paired benchmark evidence. [Validation](../../DxUi/Specs/Testing/Testing_Validation.md)

## Key Commands

```powershell
Set-Location ..\DxUi
.\validate.ps1
.\format.ps1 -Check
.\Test-Changes.ps1 -Explain
.\Test-Changes.ps1 -Mode PrePush -Explain
.\test.ps1 -Configuration Debug -Platform x64
.\gallery.ps1 -SkipBuild
```

Return to [Index.md](Index.md).
