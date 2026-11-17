# RedPrism detail: `performance-resources`

> **Parity reference.** Body of `RedPrism/.agents/skills/performance-resources/SKILL.md` as of `8c27267f76c5`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedPrism`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read `Specs/Core/Core_PerformanceAndResources.md` before material architecture or rendering changes.

- Preserve correctness, security, visual quality, and required behavior first. Among correct designs choose the
  lowest steady-state resource cost.
- Make steady-state hot paths allocation-free with bounded reusable storage.
- Cache derived state until an input changes. Batch compatible copies, uploads, state changes, and draws.
- Block on messages, events, or presentation pacing when work is unavailable. Never add a busy loop.
- Hidden, minimized, suspended, occluded, and display-off execution must not Present or keep a canvas/UI surface.
- Keep histories, queues, caches, and device resources bounded. Fail locally on capacity exhaustion.
- Create expensive resources lazily and release them when inactive unless a normative lifetime rule says otherwise.
- Measure before accepting a regression. Record justified regressions in the owning spec or active plan.

Rendering changes keep the WARP `--self-test` path green.
