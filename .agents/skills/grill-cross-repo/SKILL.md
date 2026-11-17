---
name: grill-cross-repo
description: Stress-test a proposed cross-repository feature, shared DxUi control, or policy change against the RedHome wiki and owning sibling domain specs.
---

# Grill Cross-Repo

Adapted from Matt Pocock's `grill-with-docs` and `grill-me` skills for the RedSalamanders ecosystem. Use this skill before writing specs or code whenever a request spans multiple projects (for example adding a control to `DxUi` for `RedPrism`/`RedTilde`, aligning build/CI scripts, or sharing diagnostics).

## Iron Laws

1. Ground every question in actual repository contracts—read [wiki/Glossary.md](../../../wiki/Glossary.md), [wiki/Ecosystem-Architecture.md](../../../wiki/Ecosystem-Architecture.md), and the owning `../<Project>/Specs/<Domain>/*.md` files before questioning the user.
2. Never assume a control belongs in `DxUi` if it carries application-specific settings, AV devices, file-manager actions, or document models (those stay in consumer adapters per `../DxUi/AGENTS.md`).
3. Ask focused, high-leverage design questions branch-by-branch rather than dumping boilerplate checklists.

## Workflow

1. Map affected owners across `../DxUi`, `../RedSalamander`, `../RedXe`, `../RedPrism`, `../RedTilde`, and `../RedSalamanders/.github`.
2. Check boundary invariants against the owning contracts:
   - **Ownership**: Shared retained control vs consumer adapter? COM/POD plugin boundary respected (no `DxUi` C++, STL, WIL, or exceptions across a DLL plugin ABI)?
   - **Performance & Resources**: Zero steady-state heap allocation on composition/render paths? Event-blocked idle/hidden/occluded state (no busy polling)? Paired baseline measurement fixture identified?
   - **Accessibility, Input & Localization**: TSF/IME, keyboard navigation, UIA snapshot publication, `.rc` `STRINGTABLE` positional `{0}` placeholders, and high-DPI scaling covered?
   - **Failure & File Safety**: Checked non-throwing `HRESULT` for expected refusal vs fatal host diagnostics on unexpected C++ exceptions?
3. Present concrete trade-offs and resolve open product decisions with the user, then use [spec-workflow](../spec-workflow/SKILL.md) to record the agreed work in the owning repositories.
