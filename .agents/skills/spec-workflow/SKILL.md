---
name: spec-workflow
description: Create, update, or reconcile normative domain specifications and sequence single-repo or cross-repo WIP-to-Done plans across RedSalamanders projects.
---

# Specification & WIP Plan Workflow

Consolidated specification governance across `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`. Read the target repository's `AGENTS.md` and `Specs/README.md` completely before editing specifications or plans.

## Authority Hierarchy

- `Specs/<Domain>/*.md`: Current normative behavior, ownership, compatibility constraints, and required validation.
- `AGENTS.md` and `Specs/README.md`: Repository-wide engineering and reconciliation policy.
- Public ABI headers (`Common/PlugInterfaces/*.h`, `include/DxUi/*.h`) and machine contracts (`*.schema.json`, `*.lock.json`, `capabilities.json`, `Tools/tool-inventory.json`): Authoritative shapes and versions; link to them instead of duplicating mutable counts or structs in prose.
- `Specs/Plans/WIP/`: Non-normative active sequencing and `DECISION` queues, indexed once in `Specs/Plans/WIP/README.md` (`DxUi` and `RedTilde` consolidate new work into `RemainingWork_*.md` rather than creating parallel queues; in `RedSalamander`, never reuse an archived plan ID and never read or touch `Specs/Plans/WIP/Notes_Scratch.md` unless explicitly named by the user).
- `Specs/Plans/Done/`: Immutable historical records; never rewrite `Done/` to change current rules (`RedSalamander` enforces `Test-RSProtectedDoneHistory`).
- `docs/`: End-user guide; must agree with contracts and update when user scenarios change, without overriding `Specs/` or receiving raw measurement receipts.

## Workflow

1. **Identify Owners & Sequence Producer-First**:
   - Locate the owning `Specs/<Domain>/*.md` contract and all implementation/test anchors.
   - For cross-repository work, sequence producer plans (`DxUi`, `RedMonitor`, `RedSalamanders/.github`) ahead of consumer plans (`RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`), keeping pin-bump and consumer-qualification gates explicit.
2. **Plan or Apply**:
   - Small, settled single-repo changes may update the domain spec, code, and tests together.
   - Multi-step, risky, or undecided work uses one indexed `Specs/Plans/WIP/` plan naming the domain specs expected to change.
   - Keep `capabilities.json` (`DxUi`, `RedTilde`) truthful: separate `supported`, `experimental`, and pending upstream/IME/AT/platform gates.
3. **Closeout**:
   - Merge all durable requirements discovered during implementation into `Specs/<Domain>/*.md` before moving a completed WIP plan to `Specs/Plans/Done/` and removing its active index row.
   - Generate any spec/doc screenshots strictly through the application's deterministic non-activating harness (`--screenshot` / capture scenarios)—never Computer Use or manual desktop screenshots.
   - Add one dated fragment under `Changes/<yyyy-mm-dd>-<topic>.md` (never hand-edit `CHANGELOG.md`).
   - Run the repository's spec/skill/changelog validators (`validate.ps1` / `validate-skills.ps1` / `validate-specs.ps1`, `Tools/Get-SpecInventory.ps1 -FailOnFindings` in `RedSalamander`, and `Tools/Test-Changelog.ps1`).
