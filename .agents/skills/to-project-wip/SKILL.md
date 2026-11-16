---
name: to-project-wip
description: Decompose an agreed cross-repository design into sequenced producer and consumer WIP plans under each owning project's Specs/Plans/WIP directory.
---

# To Project WIP

Adapted from Matt Pocock's `to-spec` and `to-tickets` skills to RedSalamanders' `Specs/Plans/WIP/` governance. Use this skill after `grill-cross-repo` once cross-repository design decisions are settled.

## Iron Laws

1. Never store active product execution backlogs only in `RedHome`. Each repository owns its execution plan in `../<Project>/Specs/Plans/WIP/` and indexes it once in `../<Project>/Specs/Plans/WIP/README.md` (or appends to `RemainingWork_*.md` where a repo's WIP index mandates single-plan consolidation, as in `DxUi` and `RedTilde`).
2. Sequence producer work (`DxUi`, `RedMonitor`, `RedSalamanders/.github`) ahead of consumer adoption (`RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`), keeping consumer pin-bump and product-qualification gates explicit.
3. Never reuse a retired or archived plan ID in `RedSalamander` (`Test-RSProtectedDoneHistory` / `Get-SpecInventory.ps1`).

## Workflow

1. Read `../<Project>/Specs/README.md` and `../<Project>/Specs/Plans/WIP/README.md` in every affected repository to check whether new work enters an existing consolidated `RemainingWork_*.md` plan (`DxUi`, `RedTilde`) or a dedicated `Title_YYYY-MM-DD.md` indexed entry (`RedSalamander`, `RedXe`, `RedPrism`).
2. For each affected repository, draft a self-contained plan naming:
   - Exact normative domain specs (`Specs/<Domain>/*.md`) expected to change at closeout.
   - Ordered implementation slices with explicit producer commit/API prerequisites.
   - Independent numeric goldens (`RedPrism`), deterministic harness captures (no desktop takeover), paired performance baselines, `Changes/` fragment requirement, and x64 (`Debug`, `Release`, `ASan Debug`) + ARM64 build/runtime gates.
3. Run each touched repository's spec/skill validator (`validate.ps1`, `validate-specs.ps1`, or `Tools/Get-SpecInventory.ps1 -FailOnFindings`).
