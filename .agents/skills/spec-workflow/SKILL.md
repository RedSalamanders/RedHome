---
name: spec-workflow
description: Create, update, or reconcile normative domain specifications and sequence single-repo or cross-repo WIP-to-Done plans across RedSalamanders projects. Use when behavior, ownership, or required validation changes, when code and a spec disagree, or when starting, updating, or closing a Specs/Plans/WIP plan.
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
| WIP and Done indexes | DxUi, RedXe, RedPrism, RedTilde and RedMonitor use status-prefixed WIP bullets and indexed Done records. RedSalamander's inventory still reads its WIP table and lacks a Done README. | Change the RedSalamander inventory reader, its tests and the protected-history allowance alongside the indexes (B-02 and B-03). |
| Active plans and naming | Five products use dated active plan names, including RFCs. RedSalamander still has two undated direct WIP plans. DxUi and RedTilde route related work into an existing RemainingWork plan. | Date active plan and RFC filenames. Update callers and links together and keep completed history in place (B-04). |
| `capabilities.json` | Present in DxUi, RedXe, RedTilde and RedMonitor. RedPrism and RedSalamander still need a root capability record. | Use the common supported and pending vocabulary with product-owned evidence (A-13). |
| Screenshot rule | `RedXe`: `RedXe.exe --screenshot` command. `RedSalamander`: harness plus invented fixture data, mockups labeled. `DxUi`, `RedTilde`, `RedMonitor`: harness with provenance. `RedPrism`: harness, no provenance rule. | Harness capture with provenance, synthetic fixture data and labeled mockups; each application documents its capture command in its `docs/`. `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`, `DxUi` change. |
| `docs/` role | Five products share the spec authority and reconciliation structure. RedSalamander keeps its own catalog until the Done index and inventory reader land. | Keep user guidance aligned with the owning contract and put receipts in the evidence archive. Reconcile the remaining RedSalamander catalog under B-01. |
