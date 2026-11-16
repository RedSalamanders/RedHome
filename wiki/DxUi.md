# DxUi (`../DxUi`)

- **Repository**: `RedSalamanders/DxUi` (`kind: sdk`, `apiRevision: 5`, static archive `DxUi.lib`)
- **Authoritative sibling docs**: [AGENTS.md](../../DxUi/AGENTS.md), [Specs/README.md](../../DxUi/Specs/README.md), [README.md](../../DxUi/README.md), [capabilities.json](../../DxUi/capabilities.json), [Active WIP](../../DxUi/Specs/Plans/WIP/README.md)

## Overview & Architecture

Canonical home of shared DirectX UI controls and rich Markdown/text layout for RedSalamanders:

- **Public Headers (`include/DxUi/`)**:
  - `DxUi.h`, `ControlCatalog.h`, `ThemeColors.h`, `FrameRuntime.h`, `Diagnostics.h`: 35 retained controls, `FlexPanel`, `FormPanel`/`FormField`, neutral theme, frame clock, and reduced-motion support.
  - `Embedded.h`: Borrowed-device `GraphicsDevice` pool and `EmbeddedHost` (`Prepare` / `PrepareInteraction` / `Composite` / `UpdateAccessibility`).
  - `RichDocument.h`, `RichMarkdown.h`, `RichTextLayout.h`, `MarkdownSyntax.h`: Lossless Unicode GFM block/inline parser, `RichTextEditor` with TSF/IME (`TextStoreACP`) and UIA providers, bounded HTML/math/Mermaid rendering, and `FileDrop` / `RichImage` SVG & bitmap support.
- **Consumer Interface (`capabilities.json`)**:
  - Consumers import only `Build/DxUi.Consumer.props`, `Build/DxUi.Consumer.targets`, `Build/DxUi.AddressSanitizer.targets`, and `src/DxUi.vcxproj`, and call only exported helpers in `Tools/ConsumerBuild.psm1`, `Tools/ConsumerUpdate.psm1`, `Tools/VisualStudio.psm1`, `Tools/VcpkgTriplet.psm1`, `Tools/validate_consumer.ps1`, and `vcpkg-install.ps1`.
  - API 5 requires installing the application-owned failure host before constructing controls or entering `DxUi` scopes.

## Repository-Specific Rules & Skills

- **Skills (`../../DxUi/.agents/skills/`)**: `build-dxui`, `control-development`, `embedded-rendering`, `win32-host`, `input-accessibility`, `performance-resources`, `modern-cpp-wil`, `spec-workflow`, `consumer-integration`.
- **New Control Checklist**: Requires `ControlCatalog` entry, interaction tests, populated gallery tile (`gallery.ps1 -PublishDocs`), `docs/controls.md` entry, and `Specs/UI/UI_DesignSystem.md` guideline + preview.
- **Paired Complex-UI Performance**: Every `test.ps1` run reports complex-UI (83-control) FPS and memory; changes require paired before/after baseline comparison.
- **No Hosted Public Release**: `DxUi` has no public GitHub Release or Winget workflow; qualified SDK ZIPs (verified with clean extracted-SDK consumer builds, license closure, and LNK4099 PDB-isolation negative controls) remain internal CI artifacts.

## Key Commands

```powershell
Set-Location ..\DxUi
.\validate.ps1
.\format.ps1 -Check
.\Test-Changes.ps1 -Explain
.\test.ps1 -Configuration Debug -Platform x64
.\gallery.ps1 -SkipBuild
```

Return to [Index.md](Index.md).
