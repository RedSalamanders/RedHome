---
name: spec-workflow
description: Create, update, or reconcile normative domain specifications and sequence single-repo or cross-repo WIP-to-Done plans across RedSalamanders projects.
---

# Specification & WIP Plan Workflow

One workflow for `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`. Read the target repository's `AGENTS.md` and `Specs/README.md` completely before changing specification authority or plan state, then read the owning domain spec completely before changing its behavior. The repository's `AGENTS.md` and `Specs/` win on any conflict. Cross-repository plans of `RedHome` itself live in [Specs/Plans/WIP/](../../../Specs/Plans/WIP/README.md): one indexed plan per initiative, while each repository's own work items stay in that repository's plans.

## Authority Model

- `Specs/<Domain>/*.md`: current normative behavior, ownership, compatibility constraints, and required validation. Use normative language only for observable requirements, ownership boundaries, compatibility constraints, and required validation; keep rationale concise.
- `AGENTS.md` and `Specs/README.md`: repository-wide engineering and reconciliation policy.
- Public ABI headers (`Common/PlugInterfaces/*.h`, `include/DxUi/*.h`) and machine contracts (`*.schema.json`, `*.lock.json`, `capabilities.json`, `Tools/tool-inventory.json`): authoritative shapes, versions and identities. Link to them instead of copying exact schemas, dependency versions, mutable counts or generated data into prose.
- `Specs/Plans/WIP/`: non-normative active sequencing and `DECISION` queues. A plan owns sequencing, decisions, acceptance scenarios and evidence links, never durable requirements. Index every direct plan in `Specs/Plans/WIP/README.md` exactly once.
- `Specs/Plans/Done/`: immutable history; never rewrite it to change current rules and never treat it as authority for current behavior.
- `docs/`: end-user guide. It must agree with the contracts and be updated when an end-user scenario changes. It is not an authority for product behavior and does not receive measurement receipts, checkpoints, generated reports or WIP notes.
- Implementation and tests are evidence and consumers. Reconcile disagreements with the owning contract; do not silently declare either side authoritative.

## Workflow

1. **Identify owners and sequence producer-first.**
   - Locate the owning `Specs/<Domain>/*.md` contract and its implementation and validation anchors.
   - For cross-repository work, sequence producer plans (`DxUi`, `RedMonitor`, `RedSalamanders/.github`) ahead of consumer plans (`RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`), keeping pin-bump and consumer-qualification gates explicit.
2. **Plan or apply.**
   - Small, settled changes update the domain spec, code and tests together.
   - Multi-step, risky or undecided work uses one indexed `Specs/Plans/WIP/` plan naming the domain specs expected to change. When the repository has a single current `RemainingWork_*.md` plan, add new in-scope work there instead of creating a parallel queue.
   - Keep requirements in the domain spec, not only in commentary, a WIP checklist, code or tests. When behavior changes, update every affected contract and consumer in the same change.
   - Keep `capabilities.json` truthful: separate supported, experimental and pending items, and keep upstream, IME, assistive-technology, native-platform, physical-input and release gates open until they are qualified. Do not promote an upstream preview to product qualification.
   - State implemented support separately from intended acceptance contracts. Separate implementation from consumer, platform, interactive and performance gates; library tests do not replace consumer product qualification.
   - Park separately deferred consumer or platform scope on `HOLD` rather than closing it.
3. **Closeout.**
   - Merge every durable discovery into the authoritative `Specs/<Domain>/*.md`, and update `docs/` when an end-user scenario changed.
   - Move a completed WIP plan to `Specs/Plans/Done/` and remove its active index row, only when every claimed in-scope implementation, test and documentation obligation is closed. Keep checklists and evidence honest.
   - Generate every spec, doc and UI-review screenshot through the application's deterministic, non-activating harness (`--screenshot` or capture scenarios), with scenario and build provenance; label proposal mockups separately. Never use Computer Use or a desktop screenshot tool.
   - Add one dated fragment under `Changes/<yyyy-mm-dd>-<topic>.md`; never hand-edit `CHANGELOG.md`.
   - Run the domain spec's validation, then the repository's spec, skill and changelog validators: `validate.ps1`, `validate-skills.ps1`, `validate-specs.ps1`, `Tools/Get-SpecInventory.ps1 -FailOnFindings` and `Tools/Test-Changelog.ps1`, whichever the repository provides (see Differences To Converge). For source or build work also run the affected `test.ps1` configurations.

## Repository Facts

Product-specific paths, commands, validators and ownership rules are in [references/repository-facts.md](references/repository-facts.md). Read the entries for the repository you work in.

## Differences To Converge

Each row lists a real difference between repositories and the single target that all repositories move to. Until a row is closed, follow the repository's own `AGENTS.md`.

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Spec, skill and changelog validators | `DxUi`: `validate.ps1`, `validate-skills.ps1`, `validate-specs.ps1`, `Tools/Test-Changelog.ps1`. `RedPrism`: `validate.ps1`, `validate-skills.ps1`, `Tools/Test-Changelog.ps1`. `RedXe`: `validate-skills.ps1`, `Tools/Test-Changelog.ps1`. `RedTilde` and `RedMonitor`: `validate.ps1`, `Tools/Test-Changelog.ps1`. `RedSalamander`: no root validator; `Tools/Get-SpecInventory.ps1 -FailOnFindings`, `Tools/Test-Changelog.ps1`. | Every repository has root `validate-specs.ps1`, `validate-skills.ps1` and an aggregate `validate.ps1`, plus `Tools/Test-Changelog.ps1`. `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor` change. |
| WIP and Done indexes | `Specs/Plans/Done/README.md` is missing in `RedSalamander`. WIP rows: `- **ACTIVE**:` prefix in `DxUi`, `RedTilde`, `RedSalamander`; `\| Plan \| Status \| ...` table with backticked status in `RedXe`, `RedPrism`; `— ACTIVE;` suffix in `RedMonitor`. Labels: `DxUi` adds `SPEC READY`; `RedSalamander` also defines `DRAFT`. | Both READMEs exist. Rows use the `- **STATUS**: [Title](File.md) — purpose` prefix with `ACTIVE`, `HOLD`, `DECISION`, `RETIRED`. `RedSalamander` adds Done README; `RedXe`, `RedPrism`, `RedMonitor` change format. |
| Active plans and naming | All require one indexed plan per multi-step work. `DxUi` and `RedTilde` name `RemainingWork_2026-11-04.md` the single current plan. Naming rule: `Title_YYYY-MM-DD.md` in `RedXe` and `RedPrism`; descriptive `_YYYY-MM-DD.md` in `RedSalamander`; none in `DxUi`, `RedTilde`, `RedMonitor`. | One indexed plan per initiative, named `Title_YYYY-MM-DD.md`; `RFC_Domain_Title.md` while undecided. `DxUi`, `RedTilde`, `RedMonitor` add the naming rule. |
| `capabilities.json` | Present in `DxUi`, `RedTilde`, `RedMonitor`; absent in `RedSalamander`, `RedXe`, `RedPrism`. | Every repository keeps a root `capabilities.json`. `RedSalamander`, `RedXe`, `RedPrism` add it. |
| Screenshot rule | `RedXe`: `RedXe.exe --screenshot` command. `RedSalamander`: harness plus invented fixture data, mockups labeled. `DxUi`, `RedTilde`, `RedMonitor`: harness with provenance. `RedPrism`: harness, no provenance rule. | Harness capture with provenance, synthetic fixture data and labeled mockups; each application documents its capture command in its `docs/`. `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`, `DxUi` change. |
| `docs/` role | `RedXe`, `RedPrism`: end-user guide, not authority. `RedSalamander`: must agree, does not silently override. `DxUi`: `docs/controls.md` and gallery reviewed on every code change. `RedTilde`: usage docs reviewed on every UI change. `RedMonitor`: linked from `Specs/README.md` only. | The `docs/` row of the Authority Model above in every `Specs/README.md`. `RedMonitor`, `RedTilde`, `DxUi`, `RedSalamander` add the no-receipts rule. |
