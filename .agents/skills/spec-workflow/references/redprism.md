# RedPrism detail: `spec-workflow`

> **Parity reference.** Body of `RedPrism/.agents/skills/spec-workflow/SKILL.md` as of `8c27267f76c5`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedPrism`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read `Specs/README.md` completely before changing specification authority or plan state. Then read the owning domain
spec completely before changing its behavior.

## Authority

- `Specs/<Domain>/*.md` states current normative behavior.
- `AGENTS.md` and `Specs/README.md` state repository-wide policy.
- `Specs/Plans/WIP/` contains non-normative active work; index every direct plan in its `README.md`.
- `Specs/Plans/Done/` is historical and does not override a current domain spec.
- `docs/` is the user guide, not authority.
- Domain specs and independent numeric golden cases own behavior.

## Workflow

1. Identify the owning domain contract and its implementation and validation anchors.
2. Use a direct spec-plus-code change for small, settled work. Create one indexed WIP plan for multi-step work.
3. Keep requirements in the domain spec, not only in commentary, a WIP checklist, code, or tests.
4. Update all affected contracts and consumers in the same change when behavior changes.
5. Run the validation required by the owning spec and `.\validate-skills.ps1` for skill or policy edits.
6. Before closeout, merge lasting discoveries into the authoritative spec. Screenshots come from the application
   harness, never Computer Use or a desktop screenshot tool. Move a completed WIP plan to Done and remove its
   index row.

Use normative language only for observable requirements, ownership, compatibility, and required validation.
