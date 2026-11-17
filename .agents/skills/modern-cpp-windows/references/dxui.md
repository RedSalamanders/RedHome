# DxUi detail: `modern-cpp-wil`

> **Parity reference.** Body of `DxUi/.agents/skills/modern-cpp-wil/SKILL.md` as of `c995c1a75c68`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../DxUi`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read [the owning contract](../../../../../DxUi/Specs/Core/Core_Architecture.md) and [AGENTS.md](../../../../../DxUi/AGENTS.md).

Use the source-coordinated public API only within one module. Cross consumer-plugin boundaries through their COM/POD contracts. WIL owns Windows/COM resources; never manually destroy an owned handle. Follow [failure handling and allocation](../../../../../DxUi/Specs/Core/Core_FailureHandling.md): use checked nonthrowing refusal results or host fatal diagnostics for unexpected exceptions, including bad_alloc. A noexcept annotation alone is not error handling. Run all required build configurations.

Validate changed guidance with `validate-skills.ps1` and `validate-specs.ps1`. For source/build work run the affected
`test.ps1` configurations and the additional validation named by the contract. Supported capabilities are recorded
in `capabilities.json`; library tests do not replace consumer product qualification or deferred native-platform/IME/AT coverage.
