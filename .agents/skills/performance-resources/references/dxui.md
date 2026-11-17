# DxUi detail: `performance-resources`

> **Parity reference.** Body of `DxUi/.agents/skills/performance-resources/SKILL.md` as of `c995c1a75c68`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../DxUi`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read [the owning contract](../../../../../DxUi/Specs/Core/Core_PerformanceAndResources.md) and [AGENTS.md](../../../../../DxUi/AGENTS.md).

Measure dirty preparation separately from composition. Share immutable resources per device generation. Bound queue/cache/surface growth and replacement peaks. Clean/hidden states add no periodic work. Use source/configuration/fixture receipts; do not substitute draw counts for total cost.

A pull request that changes what the benchmark measures also runs the hosted paired gate (the contract's Hosted paired
gate); its check fails for a confirmed degradation or an inconclusive run, so repeat it or measure on a quiet machine
before asking for advice, and never rebaseline.

Validate changed guidance with `validate-skills.ps1` and `validate-specs.ps1`. For source/build work run the affected
`test.ps1` configurations and the additional validation named by the contract. Supported capabilities are recorded
in `capabilities.json`; library tests do not replace consumer product qualification or deferred native-platform/IME/AT coverage.
