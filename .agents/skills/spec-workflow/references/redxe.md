# RedXe detail: `spec-workflow`

> **Parity reference.** Body of `RedXe/.agents/skills/spec-workflow/SKILL.md` as of `87735d578659`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedXe`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read `Specs/README.md` completely before changing specification authority or plan state. Then read the owning domain
spec completely before changing its behavior. For display, window, fullscreen, fallback, or DPI work, the owner is
`Specs/UI/UI_XeneonDisplayWindowing.md`.

## Authority

- `Specs/<Domain>/*.md` states current normative behavior.
- `AGENTS.md` and `Specs/README.md` state repository-wide policy.
- `Specs/Plans/WIP/` contains non-normative active work; index every direct plan in its `README.md`.
- `Specs/Plans/Done/` is historical and does not override a current domain spec.
- `docs/` is the end-user guide. It is not an authority for product behavior.
- Implementation and tests are evidence and consumers. Reconcile disagreements; do not silently declare either side
  authoritative.

## Workflow

1. Identify the owning domain contract and its implementation and validation anchors.
2. Use a direct spec-plus-code change for small, settled work. Create an indexed WIP plan for multi-step, risky, or
   undecided work.
3. Keep requirements in the domain spec, not only in commentary, a WIP checklist, code, or tests.
4. Update all affected contracts and consumers in the same change when behavior changes.
5. Run the domain spec's validation plus the relevant repo skill's checks.
6. Before closeout, move every lasting discovery into the authoritative spec. If the finished change impacts an
   end-user scenario, update `docs/` in the same closeout: global usage and/or the affected plugin page, including the
   screenshot when appearance or interaction changed. Screenshots come from the application itself:
   `RedXe.exe --screenshot <png> --page <id> --widget <ordinal> [--after <ms>]` on a Debug build with a portable
   `--settings` scene (see `docs/usage.md`), never from a desktop screenshot tool or Computer Use. `docs/` MUST NOT
   receive measurement receipts, checkpoints, or generated reports. Move a completed WIP plan to Done and remove its active index row.

Use normative language only for observable requirements, ownership boundaries, compatibility constraints, and
required validation. Keep rationale concise and avoid copying exact schemas, dependency versions, or generated data
when a machine-owned artifact can be linked instead.

For specification-only or skill-only changes, run `.\validate-skills.ps1`, the repository-owned skill validation
entrypoint. Follow the [skill package contract](../../../../../RedXe/Specs/Build/Build_SkillPackages.md) for its structural and
local-reference checks and their limits. Code changes still require the build/runtime checks owned by their domain
spec; ordinary iteration uses affected coverage, with PrePush/Full accounting for qualification.
