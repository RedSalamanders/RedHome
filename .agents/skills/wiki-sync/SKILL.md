---
name: wiki-sync
description: Audit and update RedHome wiki pages from sibling AGENTS.md, Specs/README.md, capabilities.json, lock manifests, and active WIP plan indexes.
---

# Wiki Sync

Use this skill whenever sibling architectures, domain contract tables, `DxUi` capabilities, active WIP plans, or shared build/CI policies change and `RedHome/wiki/` needs reconciliation.

## Iron Laws

1. Keep `wiki/` flat-first with Title-Kebab filenames (`Ecosystem-Architecture.md`, `RedPrism.md`) and register every page in [wiki/Index.md](../../../wiki/Index.md).
2. Summarize architecture, ownership boundaries, workflows, and entrypoints; link to `../../<Project>/Specs/<Domain>/*.md` from `wiki/` instead of copying mutable C++ struct definitions or large schemas verbatim.
3. Stamp point-in-time pin or WIP tables with `Last verified: YYYY-MM-DD` and note that machine manifests in sibling checkouts are authoritative.

## Workflow

1. Read [wiki/Index.md](../../../wiki/Index.md) and identify affected dossiers (`RedSalamander.md`, `RedXe.md`, `RedPrism.md`, `RedTilde.md`, `DxUi.md`, `Shared-CI-Engine.md`, `Dependency-And-CI-Matrix.md`, `Shared-Engineering-Policies.md`, `Ecosystem-Architecture.md`, `Glossary.md`).
2. Read the corresponding sibling sources (`AGENTS.md`, `README.md`, `Specs/README.md`, `Specs/Plans/WIP/README.md`, `capabilities.json`, `Dependencies/*.lock.json`, `.ci/project.json`).
3. Reconcile:
   - Component ownership tables and plugin/module inventories.
   - Domain specification entrypoints and local skill tables.
   - Build, scoped-testing (`Test-Changes.ps1`), packaging, and harness-capture commands.
   - Current API revision and pin matrix in [wiki/Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md).
4. Run `pwsh -NoProfile -File ./validate.ps1 -CheckSiblings` and resolve any broken links or unindexed pages.
