---
name: wiki-sync
description: Reconcile RedHome wiki pages against sibling repositories and capture durable multi-repository lessons and session handoffs.
---

# Wiki Sync & Session Handoff

Use this skill whenever sibling architectures, domain contract tables, `DxUi` capabilities, active WIP plans, or shared policies change, or when closing out a multi-repository investigation so lasting insights compound in `RedHome/wiki/`.

## Iron Laws

1. Keep `wiki/` flat-first with Title-Kebab filenames (`Ecosystem-Architecture.md`, `RedPrism.md`) and register every page in [wiki/Index.md](../../../wiki/Index.md); never dump dated chat logs into `wiki/`.
2. Summarize architecture, ownership boundaries, workflows, and entrypoints; link to `../../<Project>/Specs/<Domain>/*.md` from `wiki/` instead of copying mutable C++ struct definitions or large schemas verbatim.
3. Never claim native qualification, ARM64 runtime execution, interactive-focus coverage, or CI completion from partial/scoped runs; distinguish `LOCALLY_VALIDATED`, `CI_PENDING`, cross-compile-only, and `HOSTED_ACCEPTED` states truthfully.

## Workflow

1. Read [wiki/Index.md](../../../wiki/Index.md) and identify affected pages (`RedSalamander.md`, `RedXe.md`, `RedPrism.md`, `RedTilde.md`, `RedMonitor.md`, `DxUi.md`, `Skill-Catalog.md`, `Working-From-RedHome.md`, `Shared-CI-Engine.md`, `Dependency-And-CI-Matrix.md`, `Shared-Engineering-Policies.md`, `Ecosystem-Architecture.md`, `Glossary.md`).
2. Reconcile component ownership, plugin/module inventories, domain spec entrypoints, repo-specific skill lists, commands, and consumed API revisions (never commit SHAs: `Tools/Get-WorkspaceStatus.ps1` reports live pins, and dated snapshots belong in `Specs/Plans/WIP/`) against sibling `AGENTS.md`, `Specs/README.md`, `capabilities.json`, and lock files.
3. Run `pwsh -NoProfile -File ./validate.ps1 -CheckSiblings` in `RedHome` and fix any broken links or unindexed pages.
4. When ending a multi-repo session, emit a concise handoff naming touched repos/branches/SHAs, exact verified commands and receipts, and remaining qualification gates.
