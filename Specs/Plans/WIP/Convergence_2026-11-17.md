# RedSalamanders convergence: one common ground, step by step

## Metadata

- **Status**: ACTIVE. Phase 1 is delivered in the same change as this plan; Phases 0 and 2 to 7 are plan only.
- **Date**: 2026-11-17
- **Baseline**: `RedHome` `origin/main` at `707ca84`; sibling state as recorded under [Baseline](#baseline-2026-11-17).
- **Scope**: `RedHome`, `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`, `RedSalamanders/.github`.
- **Contracts to reconcile on closeout**: [AGENTS.md](../../../AGENTS.md), [wiki/Index.md](../../../wiki/Index.md) and the pages it lists, the shared skills under `.agents/skills/`, each sibling's `AGENTS.md` and `Specs/README.md`, and the engine's [Specs/CI.md](../../../../RedSalamanders/.github/Specs/CI.md).
- **Owner decisions**: listed under [Decisions](#decisions-for-the-owner). This plan recommends; it takes none of them.

---

## Context and motivation

On 2026-11-16 the shared agent skills of six repositories were consolidated into `RedHome`, following the Home Repo pattern: one repository that holds shared skills, a lean `AGENTS.md` with pointers to every sibling, and a small wiki. Each product repository kept its own skills and gained a pointer back to `../RedHome`.

A review on 2026-11-17 of all eight checkouts confirmed the structure is sound and found five gaps:

1. **Skill depth was lost.** The consolidation rewrote skills instead of moving them. 26 repository skills (about 1,480 lines) became seven shared skills of 21 to 47 lines.
2. **Scripts and tools were not factorised.** The same PowerShell modules and scripts exist in up to six repositories, some byte-identical and some as diverging forks, and `RedHome` added one more fork.
3. **Pins are split.** Four different shared-engine commits are in use, and Dependabot notices that bump one workflow caller at a time have already caused caller drift once.
4. **Branch and worktree debris.** Merged branches were not deleted, two repositories carry dozens of local-only experiment branches and worktrees, and one local checkout is ten days stale.
5. **Discovery depends on a sibling folder.** Shared skills are reachable only when `RedHome` is checked out beside the repository, and only through the `AGENTS.md` index in harnesses that do not read `.agents/skills/`.

## Goal

Working from `RedHome` is at least as good as working inside each repository is today, and everything that is common to several repositories exists exactly once, in the repository that should own it.

**Not goals**: merging the repositories into a monorepo, changing product behavior, moving normative product specs into `RedHome`, or making any build, test, or CI path depend on `RedHome`.

## Non-breaking invariants

1. **Authority stays where it is.** Product behavior, ABIs, numeric goldens, capabilities, and locks remain owned by each repository's `Specs/`, `AGENTS.md`, and `Dependencies/`. `RedHome` synthesizes and routes.
2. **Hermetic builds and CI.** Nothing that a build, test, or workflow executes may come from `RedHome`. Shared executable tooling ships only through producers that consumers already pin by commit: the shared engine (`.ci-engine`), `DxUi`, and `RedMonitor`.
3. **Producer before consumer, one repository per pull request.** Every pull request passes that repository's own gates and adds its own `Changes/` fragment.
4. **Parity gate.** No step removes guidance or tooling from a repository until the replacement is reachable from that repository, in every harness the owner uses, and that reachability has been checked.
5. **No behavior change when moving identical code.** Byte-identical files move first, behind shims that keep script names and parameters stable. Forks are reconciled only after tests pin the behavior of every variant.
6. **Read-only first.** Diagnostics never reset, clean, or check out a sibling. Destructive git operations run on the Windows host, with the owner's agreement, after unpushed work is archived.
7. **Truthful status.** A merged change is `CI_PENDING` until `ci-state` records `succeeded`; scoped or cross-compile-only results are reported as such.

---

## Baseline (2026-11-17)

Read from the local clones as fetched on 2026-11-17 (`RedSalamanders/.github` last fetched 2026-11-07). GitHub-side state (open pull requests, branch protection, run logs) was not available when this was written.

| Repository | `main` | Engine pin | `DxUi` | Last `ci-state` | Local / remote branches | Worktrees |
| --- | --- | --- | --- | --- | --- | --- |
| `RedHome` | `707ca84` | none | none | none | 2 / 2 | 0 |
| `DxUi` | `a845d375` | `766fd7e` (engine #70) | Producer, API 5 | succeeded | 46 / 88 (32 `changelog/fold-*`) | 44 |
| `RedSalamander` | `51574df7` | `a094b2e` (engine #86) | API 4 at `7fb2ab71` | **failed**, third consecutive admission (run `43985619531`) | 3 / 23 | 0 |
| `RedXe` | `58931a1` | `07bc6f1` (engine #83) | API 4 at `f2e328a0` | succeeded | 2 / 12 (5 engine notices) | 0 |
| `RedPrism` | `18eef4ff` | `07bc6f1` (engine #83) | API 4 at `f2e328a0` | succeeded | 3 / 11 (5 engine notices) | 0 |
| `RedTilde` | `9adf318` | `07bc6f1` (engine #83) | API 5 at `21fae0dc` | succeeded | 45 / 66 (28 `changelog/fold-*`, 5 engine notices) | 48 |
| `RedMonitor` | `2976072` | `d6a33c5` (engine #82) | API 4 at `f2e328a0` | succeeded | 2 / 27 (5 engine notices) | 0 |
| `RedSalamanders/.github` | local `570351e` (engine #16); newest known `main` is `a094b2e` (engine #86) | n/a | n/a | n/a | 2 / 16 | 11 |

Engine history is linear across the pins: `766fd7e` < `d6a33c5` < `07bc6f1` < `a094b2e`.

Facts behind the gaps:

- **Merged leftovers**: `chore/prune-shared-skills-to-redhome` exists locally and on the remote in all six code repositories; `ej/redhome-guidance-corrections-20261116` in `RedHome`; `ej/manual-x64-qualification-20261107` locally in the engine checkout.
- **Local-only experiment branches** (never pushed, not merged): 29 in `RedTilde` (2026-10-23 to 2026-10-29) and 6 in `DxUi` (2026-10-25 to 2026-10-27).
- **`RedSalamander` `master`** is not an ancestor of `main` and holds 3,102 commits that `main` does not.
- **Engine notices**: 20 Dependabot branches in `RedMonitor`, `RedPrism`, `RedTilde`, and `RedXe` each bump one workflow caller to `a094b2e`. `DxUi` merged four such bumps on 2026-11-16 (#257 to #260) and had to reconcile its callers with `.ci/project.json` the next day (#262). The `ignore` rule in `.github/dependabot.yml` names `RedSalamanders/.github`, which does not match the reusable-workflow dependency names (`RedSalamanders/.github/.github/workflows/<file>.yml`).
- **Stale references**: `RedSalamander` `Specs/Plans/WIP/Core_HResultStatusFormattingCleanup_2026-06-19.md` and `RedPrism` `Specs/Plans/WIP/AsyncDocumentSizing_2026-09-30.md` still cite skill paths that the consolidation deleted.

## What is common today

### Skills

| Shared skill in `RedHome` | Repository skills it replaced |
| --- | --- |
| `modern-cpp-windows` | `RedSalamander` `cpp-modern-style`, `error-handling`, `compiler-warnings`; `RedPrism` and `RedXe` `modern-cpp-windows`; `DxUi` `modern-cpp-wil` |
| `wil-raii` | `RedSalamander`, `RedPrism`, `RedXe` `wil-raii` |
| `yyjson` | `RedSalamander`, `RedPrism`, `RedXe` `yyjson` |
| `localization` | `RedSalamander`, `RedPrism` `localization` |
| `performance-resources` | `RedPrism`, `RedXe`, `DxUi` `performance-resources` |
| `d3d11-win32-host` | `RedPrism` and `RedXe` `direct3d11-rendering` and `win32-windowing` |
| `spec-workflow` | `RedPrism`, `RedXe`, `RedTilde`, `RedMonitor`, `DxUi` `spec-workflow` |
| `improve` | `RedSalamander` `improve` (moved unchanged) |
| `cross-repo-pins`, `grill-cross-repo`, `wiki-sync` | New in `RedHome` |

42 repository-local skills remain with their repositories; [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) lists them.

### Scripts and modules that exist more than once

"Same" means byte-identical after line-ending normalization.

| Asset | Where it lives today | State |
| --- | --- | --- |
| Changelog suite: `Tools/Fold-Changelog.ps1`, `Submit-ChangelogFold.ps1`, `Test-Changelog.ps1`, `Test-ChangelogWorkflow.ps1`, `Tools/Modules/Documentation/Changelog.psm1` (about 1,100 lines) | All six code repositories | Same in `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`; `RedSalamander` differs in two files; `DxUi` differs in all five |
| `Build/BuildConsole.psm1` | All six | Same in `RedSalamander`, `RedXe`, `RedPrism`, `RedMonitor`; `RedTilde` and `DxUi` differ |
| `Build/NativeBuildPolicy.targets` | Five (not `RedMonitor`) | Same in `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`; `DxUi` differs |
| `Build/PinnedDxUiPolicy.targets` | Five (not `RedMonitor`) | Same in `DxUi`, `RedXe`, `RedPrism`, `RedTilde`; `RedSalamander` differs |
| `Build/DxUiPaths.psm1` | `RedXe`, `RedPrism`, `RedTilde` | Same |
| `Tools/Get-CiNativeScope.ps1` | `RedPrism`, `RedTilde` | Same |
| `Test-Changes.ps1` | All six | Same in `RedPrism` and `RedTilde`; four other variants. All six accept `-Explain` and `-Mode Affected, Full, PrePush` |
| `ScopedTesting.psm1`, `TestRunEvidence.psm1` | `RedPrism`, `RedTilde`, `RedXe` (`Build/`), `DxUi` (`Tools/`) | Four diverging forks each |
| Skill validation: `SkillValidation.psm1`, `SkillPackageIntegrity.psm1` | `RedPrism`, `RedXe`, `RedTilde` (`Build/`); `RedHome` (`Tools/`); `DxUi` (`Tools/Validation.psm1`); `RedMonitor` (`Build/AgentGuidance.psm1`); `RedSalamander` (`Tools/Get-SpecInventory.ps1`) | Seven implementations of one grammar and one integrity policy |
| `restore-dxui.ps1`, `Build/DxUiRestore.psm1`, `Build/DxUiProvenance.psm1` | `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`; `RedSalamander` `Tools/Restore-DxUi.ps1` | Forks |
| `Update-RedMonitorClient.ps1`, `Verify-RedMonitorClient.ps1` | `RedPrism`, `RedTilde`, `RedXe` (root); `RedSalamander` (`Tools/`) | Same in `RedPrism` and `RedTilde`; two other variants |
| `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1` | Two to five repositories each | Forks; `DxUi` already exports the two modules to consumers |
| `.clang-format` | All six | Same 155-line style in `RedSalamander`, `RedMonitor`, `DxUi`; three short Microsoft-based variants in `RedXe`, `RedPrism`, `RedTilde` |
| `Specs/Core/Core_Changes.md` | All six | Same in `RedXe`, `RedTilde`, `RedMonitor`; three variants |
| `.github/dependabot.yml` | All six | Same in `DxUi`, `RedXe`, `RedPrism`, `RedMonitor`; two variants |
| Workflow callers (`ci.yml`, `format.yml`, `security.yml`, ...) | All six | Generated from engine templates; they differ only by the pinned engine SHA |

The workflow callers are the model to follow: one implementation in the engine, pinned by SHA, with a thin generated caller per repository.

---

## Phases

Order and dependencies: Phase 0 and Phase 1 first. Phases 2, 3, and 4 can then run in parallel. Phase 5 needs Phase 4, because engine-hosted tooling requires every repository on one engine. Phase 6 builds on 5. Phase 7 closes the plan.

Step identifiers are `CV-<phase>-<nn>`. Check a box only when its gate has passed.

### Phase 0: clean baseline (hygiene, no content change)

- [ ] **CV-0-01** Fetch and fast-forward `../RedSalamanders/.github` (about 70 engine pull requests behind), so engine docs read from `RedHome` are current. Gate: `git -C ../RedSalamanders/.github status -sb` shows `main` level with `origin/main`.
- [ ] **CV-0-02** Delete merged head branches, locally and on the remote: `chore/prune-shared-skills-to-redhome` in all six code repositories, `ej/redhome-guidance-corrections-20261116` in `RedHome`, `ej/manual-x64-qualification-20261107` in the engine checkout, and every merged `changelog/fold-*` branch (the remotes hold 32 in `DxUi`, 28 in `RedTilde`, and 1 to 2 elsewhere). Squash merges are invisible to `git branch --merged`; confirm with `gh pr list --state merged --json headRefName` before deleting.
- [ ] **CV-0-03** Turn on "Automatically delete head branches" in every repository (decision D10) so CV-0-02 does not recur.
- [ ] **CV-0-04** Archive, then remove, the local-only experiment branches (29 in `RedTilde`, 6 in `DxUi`). Per decision D10 either push each as `archive/<name>` or write one `git bundle` per repository into the repository's `.build/`, verify the bundle, then delete the branch.
- [ ] **CV-0-05** Remove finished worktrees from the Windows host (`RedTilde` 48 registrations, `DxUi` 44, engine checkout 11). Never prune from WSL or a sandbox: the Windows paths are invisible there and every worktree looks `prunable`.
- [ ] **CV-0-06** Decide the fate of `RedSalamander` `master` (decision D10): archive tag and delete, or keep with a note in that repository's `AGENTS.md`.
- [ ] **CV-0-07** Triage `RedSalamander` `main`: three consecutive native admissions have failed since 2026-11-13, the latest for the merge of the skill consolidation (run `43985619531`). Gate for every later step that merges into `RedSalamander`: `ci-state` is `succeeded`, or the failure is understood and recorded as unrelated.
- [ ] **CV-0-08** Repair the stale skill paths in the two active plans named in the baseline, pointing them at the `RedHome` skill and its parity reference. One small pull request per repository.
- [ ] **CV-0-09** `RedXe` `Tests/BuildProcessTests/ScopedTesting.Tests.ps1` still names `.agents/skills/yyjson/agents/openai.yaml`. Confirm it is only a path-classification sample; replace it with an existing path if the test reads the file.

### Phase 1: RedHome is a complete front door (delivered with this plan)

- [x] **CV-1-01** Restore the lost depth as 26 parity references under the seven shared skills (`references/<repository>.md`), generated from git history with only links retargeted. Each names its source commit and its convergence step.
- [x] **CV-1-02** Route to them from each `SKILL.md` (`Repository Detail` table) and correct the shared text: the unexpected-exception policy is scoped per repository instead of presenting the `DxUi` API 5 policy as universal; `RedMonitor` is in the `grill-cross-repo` owner map and the `wiki-sync` page list; `cross-repo-pins` names the real `DxUi` contract file for each consumer and treats engine notices as signals.
- [x] **CV-1-03** Wiki: new [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) and [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md); the dependency matrix lists pin owners and API revisions instead of commit SHAs; `RedMonitor` joins the ecosystem matrix; the `RedTilde` Winget identifier, the `RedSalamander.Perf` placeholder, engine-notice and stale-checkout notes, and three glossary terms are added.
- [x] **CV-1-04** Plans have a home (`Specs/Plans/WIP/` and `Done/`), `validate.ps1` checks links under `Specs/`, and the workflow pins `actions/checkout` by commit as the engine policy does.
- [ ] **CV-1-05** Run `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings` on the Windows host. PowerShell 7 was not available where this change was authored; a Python re-implementation of the same checks passed, which is not a substitute.
- [ ] **CV-1-06** Review, then merge through a pull request from a focused branch.
- [ ] **CV-1-07** Extend `Tools/Get-WorkspaceStatus.ps1` with hygiene columns: age of the last fetch, merged-but-undeleted branches, local-only branches, worktree registrations, and the last `ci-state` outcome. Phase 0 then stays visible instead of being rediscovered.
- [ ] **CV-1-08** Extend validation: every file under `Specs/Plans/WIP/` is indexed in its `README.md`; under `-CheckSiblings`, each sibling `AGENTS.md` still carries the shared-skill pointer sentence; every parity reference keeps its provenance header.

### Phase 2: fold the parity references (skills converge)

The parity references are a holding layer, not the end state. For each one, sort every rule into one of three places, then delete the reference or reduce it to a one-line pointer:

- **Common to every repository** goes into the shared `SKILL.md`.
- **Normative for one repository** goes into that repository's `Specs/` or `AGENTS.md` if it is not already there; the shared skill links to it.
- **How-to for one repository** returns to a repository-local skill, or stays as a reference with a recorded reason (decision D1).

Work one shared skill per pull request in `RedHome`, with a matching pull request in a repository only when a rule has to move there.

| Step | Shared skill | References to fold | Expected outcome |
| --- | --- | --- | --- |
| **CV-2-01** | `yyjson` | `redsalamander`, `redprism`, `redxe` | The three overlap almost entirely with the shared text. Keep the mutable-string table once. Move the JSON5 and BOM read defaults to `RedSalamander`'s settings contract, the Swift `Codable` shapes stay owned by `RedPrism` `Specs/IO/IO_ProjectFormat.md`, and the settings-document notes stay with `RedXe` `settings-store`. |
| **CV-2-02** | `wil-raii` | `redsalamander`, `redprism`, `redxe` | Promote the paint-context, GDI-selection, and menu patterns to the shared skill; they apply wherever GDI is used. Keep the cross-thread icon transfer with `RedSalamander`. |
| **CV-2-03** | `modern-cpp-windows` | `redsalamander-cpp-modern-style`, `redsalamander-error-handling`, `redsalamander-compiler-warnings`, `redprism`, `redxe`, `dxui` | Fold the common style rules. The suppression policy is already normative in `RedSalamander` `Specs/Core/Core_CompilerWarnings.md`, so that reference shrinks to a pointer plus whatever fix guidance the spec lacks. `Debug::` logging conventions are a `RedSalamander` API and return there as a local skill (decision D1). |
| **CV-2-04** | `localization` | `redsalamander`, `redprism` | Keep placeholder and parity rules shared. Resource-helper names, the `HostTests` string-table gate, and satellite layout are repository facts and return to each owner. |
| **CV-2-05** | `performance-resources` | `redprism`, `redxe`, `dxui` | Fold the shared design rules; the `DxUi` hosted paired gate stays in its performance contract. |
| **CV-2-06** | `d3d11-win32-host` | `redprism-*`, `redxe-*` (four files) | The shared skill already merges these. Diff each reference against it, keep only product-specific frame order and chrome rules, and link those to the owning UI spec. |
| **CV-2-07** | `spec-workflow` | `redprism`, `redxe`, `redtilde`, `redmonitor`, `dxui` | All five describe the same authority model. Fold it once; keep a per-repository line naming the validators to run. |

- [ ] **CV-2-08** When every consumer is on `DxUi` API 5 (tracked in each consumer's own plan), promote the API 5 failure policy from "per repository" to the shared rule in `modern-cpp-windows`.
- [ ] **CV-2-09** One skill folder convention (decision D4). `RedSalamander` keeps repository skills in `.github/skills/` plus one in `.agents/skills/`; every other repository uses `.agents/skills/`.
- [ ] **CV-2-10** Settle the provenance of `improve` (decision D5). It is locally customised while `skills-lock.json` still records the upstream hash.
- [ ] **CV-2-11** Decide whether shared skills carry Codex `agents/openai.yaml` metadata (decision D6). `RedXe` and `RedTilde` had it for their copies; the shared skills have none.

Exit: no parity reference remains unless it starts with a "kept because" line.

### Phase 3: discovery in every harness, and outside RedHome

- [ ] **CV-3-01** Native Claude Code discovery (decision D2). Claude Code loads skills from `.claude/skills/` or from plugins, not from `.agents/skills/`. Options:
  - **A. Stubs**: one `.claude/skills/<name>/SKILL.md` per shared skill with the same name and description and a body that points to the canonical file, plus a validator that fails on any difference.
  - **B. Plugin**: package `RedHome` as a Claude Code plugin whose skills are the canonical folder, publish it from this repository as a marketplace entry, and let each repository opt in through its own `.claude/settings.json`. This is the only option that also works in sessions started inside a product repository. Check the manifest fields against current Claude Code plugin documentation before building it.
  - **C. Stay** with the `AGENTS.md` index, which is how every repository has worked so far.
- [ ] **CV-3-02** Sessions that see one repository only (decision D3): a setup step that clones `RedHome` beside the repository for hosted agents, a pinned git-ignored `RedHome` checkout modelled on `.ci-engine`, or accept that only repository-owned guidance is available there.
- [ ] **CV-3-03** Keep the pointer sentence identical in all six sibling `AGENTS.md` files (it is today) and have CV-1-08 enforce it.
- [ ] **CV-3-04** Acceptance, recorded in this plan: in each harness the owner uses, from `RedHome` and from one product repository, ask the agent to list the skills it can use and to open `wil-raii` with its reference for that repository.

### Phase 4: pins (one engine, aligned producers)

- [ ] **CV-4-01** Stop engine-notice drift at the source (decision D12). Either widen the Dependabot `ignore` entry so it matches the reusable-workflow dependency names, or keep the notices and document that they are closed, never merged. The four identical `dependabot.yml` files show this belongs in an engine template.
- [ ] **CV-4-02** Choose the target engine commit and a cadence for future waves (decision D11). Today the newest `main` is `a094b2e`, which `RedSalamander` already runs.
- [ ] **CV-4-03** Run the wave, oldest pin first: `DxUi` (`766fd7e`), `RedMonitor` (`d6a33c5`), then `RedXe`, `RedPrism`, and `RedTilde` (`07bc6f1`). For each: `Update-ProjectPin.ps1` from a clean engine checkout at the target, sync `<repo>/.ci-engine`, add one `Changes/` fragment, pass the compiler-free checks, merge, and wait for `ci-state` to record `succeeded` before starting the next repository.
- [ ] **CV-4-04** Close the 20 notice branches once their repository is on the target.
- [ ] **CV-4-05** `DxUi` lock alignment inside API 4: `RedSalamander` pins `7fb2ab71` while `RedXe`, `RedPrism`, and `RedMonitor` pin `f2e328a0`. Owned by `RedSalamander`'s own plan; listed here so the difference is deliberate.
- [ ] **CV-4-06** API 5 adoption by the four API 4 consumers is product work owned by each repository's plan. This plan only records it as the condition for CV-2-08.

Gate for the phase: `Get-WorkspaceStatus.ps1` shows one engine SHA and `OK` for every `.ci-engine`.

### Phase 5: tooling (each shared script exists once)

Homes (decision D7):

| Kind of tooling | Home | Why |
| --- | --- | --- |
| Anything CI, build, scoped testing, changelog, or guidance validation runs | `RedSalamanders/.github`, consumed through the pinned `.ci-engine` | Already the single SHA-pinned implementation that local `build.ps1`, `test.ps1`, and `Test-Changes.ps1` load |
| `DxUi` restore, paths, provenance, pinned policy | `DxUi` consumer interface (`Tools/Consumer*.psm1`, `Build/DxUi.Consumer.*`) | Travels with the pin it serves; `DxUi` already owns `PinnedDxUiPolicy.targets` and the consumer modules |
| `RedMonitor` client update and verification | `RedMonitor`, delivered beside `Client.h` and hash-listed in `RedMonitor.lock.json` | Same hash-pinned channel as the header |
| Workspace status, wiki and plan validation | `RedHome/Tools/` | Only meaningful with every sibling present; never used by a build |

- [ ] **CV-5-01** Pilot the shim pattern in `RedMonitor` (smallest surface): the repository keeps a file with the same name and parameters that imports the engine implementation from `.ci-engine` and fails closed with one clear message when the engine is absent or at the wrong commit.
- [ ] **CV-5-02** Tier A, identical today, zero behavior change: the changelog suite. Reconcile the three variants (`DxUi`, `RedSalamander`, the other four) into the engine with the engine's tests, then replace the copies with shims, one repository per pull request.
- [ ] **CV-5-03** Tier A continued: `BuildConsole.psm1`, `NativeBuildPolicy.targets`, `Get-CiNativeScope.ps1`.
- [ ] **CV-5-04** Tier B, forks: `ScopedTesting.psm1`, `TestRunEvidence.psm1`, and `Test-Changes.ps1`. Write the design in the engine's own plan first (one planner, per-repository data for suites and paths), pin each fork's behavior with tests, then migrate.
- [ ] **CV-5-05** Tier C, guidance validation: one skill grammar and one package-integrity policy in the engine, replacing the seven implementations. `RedHome` keeps its copy until decision D13 says whether `RedHome` adopts the engine.
- [ ] **CV-5-06** Tier D, dependency tooling: move `DxUiPaths.psm1`, `restore-dxui.ps1`, `DxUiRestore.psm1`, and `DxUiProvenance.psm1` behind the `DxUi` consumer interface, and the two `RedMonitor` client scripts behind the `RedMonitor` lock.
- [ ] **CV-5-07** Tier E, toolchain: `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1`.

Gate for every step: the repository's `Test-Changes.ps1 -Mode PrePush` passes before and after with the same selected suites, and `main` reaches `ci-state` `succeeded`.

### Phase 6: one repository shape

- [ ] **CV-6-01** Common entry points (decision D8): every code repository answers the same root commands. Today `RedSalamander` has no `validate.ps1` and formats through `format-all.ps1`, `RedXe` validates through `validate-skills.ps1` only and its `format.ps1` has no `-Check`.
- [ ] **CV-6-02** One `.clang-format` or a recorded reason for two (decision D9).
- [ ] **CV-6-03** One `Core_Changes.md`: three repositories already share one text; make the engine own it and let each repository link to it, keeping only repository-specific notes locally.
- [ ] **CV-6-04** Identical `AGENTS.md` blocks (drive-root output policy, `Changes/` workflow, Unified CI paragraph) come from one engine template, as the workflow callers do, so they cannot drift apart.
- [ ] **CV-6-05** `RedHome` governance (decision D13): whether it adopts the engine as a documentation-kind project, requires pull requests for `main`, and records its own changes.

### Phase 7: sustain and close

- [ ] **CV-7-01** Run `wiki-sync` after each convergence pull request merges, and refresh [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) whenever a skill is added, moved, or removed.
- [ ] **CV-7-02** Review this plan's checkboxes at each pin wave; move finished phases' lasting rules into `AGENTS.md`, `wiki/`, or the owning repository.
- [ ] **CV-7-03** Close: move this file to `Specs/Plans/Done/` when every step is checked or explicitly dropped with a reason.

---

## Decisions for the owner

| Id | Question | Options | Recommendation |
| --- | --- | --- | --- |
| **D1** | Where does repository-specific how-to end up? | Stay in `RedHome` references; return to repository-local skills | Return it. `RedHome` keeps what is common; `Debug::` logging and resource-helper detail go back to `RedSalamander`, the string-table gate to `RedPrism`. |
| **D2** | Native Claude Code discovery | A stubs; B plugin; C stay with the index | B if sessions are also started inside product repositories, otherwise C. A adds eleven files and a validator for a modest gain. |
| **D3** | Sessions that see one repository | Setup-step clone; pinned checkout; accept | Setup-step clone for hosted agents. A pinned checkout adds a seventh pin to maintain for prose that does not need version locking. |
| **D4** | Skill folder convention | `.agents/skills/` everywhere; leave `RedSalamander` as is | `.agents/skills/` everywhere, moved in one `RedSalamander` pull request that also updates its guidance spec, tool inventory, and CI excludes. |
| **D5** | `improve` provenance | Declare a fork and drop the lock entry; re-vendor upstream and keep local rules elsewhere | Declare the fork; keep the licence and author metadata in the skill. |
| **D6** | Codex `agents/openai.yaml` for shared skills | Add; skip | Add only if the owner uses the Codex skill picker; it changes nothing else. |
| **D7** | Home for shared tooling | Engine, `DxUi`, and `RedMonitor` as in Phase 5; a new tooling repository | As in Phase 5. A new repository would add one more pin without removing any. |
| **D8** | Common root entry points | `validate.ps1`, `format.ps1 -Check`, `build.ps1`, `test.ps1`, `Test-Changes.ps1`, `package.ps1` everywhere; leave as is | Adopt the common set through thin wrappers, keeping existing names working. |
| **D9** | `.clang-format` | Adopt the 155-line style in the three short-style repositories; keep two styles | Decide per repository at a quiet point: adoption reformats the whole tree and must be its own pull request. |
| **D10** | Branch hygiene | Auto-delete head branches; archive policy for local-only branches; `RedSalamander` `master` | Auto-delete on. Archive experiment branches as `git bundle` files, then delete. Tag and delete `master` if nothing still targets it. |
| **D11** | Engine pin cadence | Wave on every engine merge; weekly; on demand | Weekly, or immediately when a repository needs a fix, always as a full wave. |
| **D12** | Dependabot engine notices | Widen the `ignore` rule; keep notices and close them | Widen the rule and let `Get-WorkspaceStatus.ps1` report pin lag instead. |
| **D13** | `RedHome` governance | Adopt the engine; stay lightweight | Stay lightweight until Phase 5 Tier C needs the shared validator, then adopt the engine as a documentation-kind project. |

## Validation

| Phase | Proof |
| --- | --- |
| 0 | `Get-WorkspaceStatus.ps1` clean; branch and worktree counts recorded here before and after |
| 1 | `validate.ps1 -CheckSiblings` passes on the Windows host and in the `Validate RedHome` workflow |
| 2 | For each folded reference, a line-by-line disposition table in the pull request; `validate.ps1 -CheckSiblings`; the receiving repository's guidance validator |
| 3 | The CV-3-04 acceptance record |
| 4 | One engine SHA in `Get-WorkspaceStatus.ps1`; `ci-state` `succeeded` in every repository after its bump |
| 5 | Same `Test-Changes.ps1 -Mode PrePush` selection and result before and after each move; engine tests cover the moved tool |
| 6 | The command map in [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md) collapses to one row |

## Risks

- **`RedHome` becomes a hidden dependency.** Invariant 2 and CV-1-08 guard against it: nothing executable is consumed from `RedHome`.
- **Parity references drift from their repositories.** They are dated copies. Phase 2 exists to remove them; do not edit them in place except to fold or delete.
- **Engine-hosted tooling breaks local work when `.ci-engine` is missing or stale.** Shims fail closed with one actionable message; `Get-CiPinnedEngineInputsIdentity` already enforces this for builds.
- **Branch cleanup loses unpushed work.** CV-0-04 archives before anything is deleted, and worktree maintenance runs only on the Windows host.
- **A pin wave lands on a red `main`.** CV-0-07 gates `RedSalamander`; every wave step waits for `ci-state`.

## Closeout criteria

The plan closes when a session started in `RedHome` reaches, for every repository, the same guidance depth that repository's own skills carried before 2026-11-16; when each shared script, module, and policy file has one owner and thin consumers; when every repository runs one engine commit; and when the lasting rules from this plan live in `AGENTS.md`, `wiki/`, the shared skills, or the owning repository's `Specs/`.
