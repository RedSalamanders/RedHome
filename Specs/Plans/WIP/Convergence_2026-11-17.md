# RedSalamanders convergence: one common ground, step by step

## Metadata

- **Status**: ACTIVE. Phases 1 and 2 and the `RedHome` side of Phase 3 are delivered in `RedHome` pull request #2. Step 1 of every product repository is open as one pull request each (listed under [Pull requests](#pull-requests)). Everything else is plan only.
- **Date**: 2026-11-17
- **Baseline**: `RedHome` `origin/main` at `707ca84`; sibling state as recorded under [Baseline](#baseline-2026-11-17).
- **Scope**: `RedHome`, `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`, `RedSalamanders/.github`.
- **Governing rule**: at the end, all projects are as close as possible for every option and every decision. See [Governing rule](#governing-rule).
- **Companions**: [DivergenceRegister.md](Convergence_2026-11-17/DivergenceRegister.md) lists every known difference with its single target. [CleanupRunbook.md](Convergence_2026-11-17/CleanupRunbook.md) holds the destructive hygiene steps, which only the owner runs.
- **Contracts to reconcile on closeout**: [AGENTS.md](../../../AGENTS.md), [wiki/Index.md](../../../wiki/Index.md) and the pages it lists, the shared skills under `.agents/skills/`, each sibling's `AGENTS.md` and `Specs/README.md`, and the engine's [Specs/CI.md](../../../../RedSalamanders/.github/Specs/CI.md).
- **Owner's part**: merging pull requests, running the cleanup runbook, and the few [owner choices](#owner-choices) where two common end states are possible.

---

## Context and motivation

On 2026-11-16 the shared agent skills of six repositories were consolidated into `RedHome`, following the Home Repo pattern: one repository that holds shared skills, a lean `AGENTS.md` with pointers to every sibling, and a small wiki. Each product repository kept its own skills and gained a pointer back to `../RedHome`.

A review on 2026-11-17 of all eight checkouts confirmed the structure is sound and found six gaps:

1. **Skill depth was lost.** The consolidation rewrote skills instead of moving them. 26 repository skills (about 1,480 lines) became seven shared skills of 21 to 47 lines.
2. **The repositories are not the same.** The same option is set differently from one repository to the next: compiler switches, formatter style, script names and parameters, guidance files, specification layout, CI configuration. About 90 such differences are now listed.
3. **Scripts and tools were not factorised.** The same PowerShell modules and scripts exist in up to six repositories, some byte-identical and some as diverging forks, and `RedHome` added one more fork.
4. **Pins are split.** Four different shared-engine commits are in use, and Dependabot notices that bump one workflow caller at a time have already caused caller drift once.
5. **Local branch and worktree debris.** Two local clones carry dozens of local-only experiment branches and worktrees, every clone keeps stale remote-tracking refs, and one local checkout is ten days stale. The GitHub side is clean.
6. **Discovery depended on a sibling folder.** Shared skills were reachable only when `RedHome` was checked out beside the repository, and only through the `AGENTS.md` index in harnesses that do not read `.agents/skills/`.

## Goal

Every repository looks and works the same wherever the product does not force a difference, and working from `RedHome` is at least as good as working inside each repository is today. Everything that is common exists exactly once, in the repository that should own it.

**Not goals**: merging the repositories into a monorepo, changing product behavior, moving normative product specs into `RedHome`, or making any build, test, or CI path depend on `RedHome`.

## Governing rule

The owner's rule, stated on 2026-11-17: **at the end, all projects are as close as possible for all options and decisions.** This plan applies it as follows.

1. **Every difference gets one target.** [DivergenceRegister.md](Convergence_2026-11-17/DivergenceRegister.md) lists each option, rule, or file that is not the same everywhere, the single end state, the repositories that must move, and the phase that moves them.
2. **A difference survives only when the product requires it.** Those cases are listed with their reason at the end of the register. "It has always been like this" is not a reason.
3. **No decision is taken per repository.** A question is answered once and the answer applies to all. Where two common end states are possible, the plan names a default and the owner may pick the other; either way every repository lands on the same one.
4. **Defaults are picked in this order**: what a producer contract already requires (`DxUi` API 5, the engine templates); then the stricter option; then what most repositories already do; then the option with fewer files.
5. **Shared skills state one rule set.** Product-specific paths, helpers, and gates are listed as repository facts, and every rule that is not yet the same everywhere is a row in the skill's `Differences To Converge` table and in the register.
6. **No new divergence.** A pull request that introduces a per-repository variant adds a register row with its target in the same change, or it is not merged.

## Non-breaking invariants

1. **Authority stays where it is.** Product behavior, ABIs, numeric goldens, capabilities, and locks remain owned by each repository's `Specs/`, `AGENTS.md`, and `Dependencies/`. `RedHome` synthesizes and routes.
2. **Hermetic builds and CI.** Nothing that a build, test, or workflow executes may come from `RedHome`. Shared executable tooling ships only through producers that consumers already pin by commit: the shared engine (`.ci-engine`), `DxUi`, and `RedMonitor`.
3. **Producer before consumer, one repository per pull request.** Every pull request passes that repository's own gates and adds its own `Changes/` fragment.
4. **Parity gate.** No step removes guidance or tooling from a repository until the replacement is reachable from that repository, in every harness the owner uses, and that reachability has been checked.
5. **No behavior change when moving identical code.** Byte-identical files move first, behind shims that keep script names and parameters stable. Forks are reconciled only after tests pin the behavior of every variant.
6. **Read-only first.** Diagnostics never reset, clean, or check out a sibling. Destructive git operations run on the Windows host, by the owner, after unpushed work is archived.
7. **Truthful status.** A merged change is `CI_PENDING` until `ci-state` records `succeeded`; scoped or cross-compile-only results are reported as such.
8. **Convergence moves one way.** A step may only reduce the number of register rows or move a row closer to its target.

---

## Baseline (2026-11-17)

Commits and pins were read from clones fetched on 2026-11-17. Branch and pull request state on GitHub was read through the GitHub API the same day. Local branch and worktree counts come from the owner's Windows clones.

| Repository | `main` | Engine pin | `DxUi` | Last `ci-state` | Branches on GitHub | Local branches / worktrees |
| --- | --- | --- | --- | --- | --- | --- |
| `RedHome` | `707ca84` | none | none | none | 2 | 2 / 0 |
| `DxUi` | `a845d375` | `766fd7e` (engine #70) | Producer, API 5 | succeeded | 4 (`main`, `ci-state`, 2 unmerged work branches) | 46 / 44 |
| `RedSalamander` | `51574df7` | `a094b2e` (engine #86) | API 4 at `7fb2ab71` | **failed** (run `43985619531`, see CV-0-07) | 2 | 3 / 0 |
| `RedXe` | `58931a1` | `07bc6f1` (engine #83) | API 4 at `f2e328a0` | succeeded | 7 (5 engine notices) | 2 / 0 |
| `RedPrism` | `18eef4ff` | `07bc6f1` (engine #83) | API 4 at `f2e328a0` | succeeded | 7 (5 engine notices) | 3 / 0 |
| `RedTilde` | `9adf318` | `07bc6f1` (engine #83) | API 5 at `21fae0dc` | succeeded | 7 (5 engine notices) | 45 / 48 |
| `RedMonitor` | `2976072` | `d6a33c5` (engine #82) | API 4 at `f2e328a0` | succeeded | 7 (5 engine notices) | 2 / 0 |
| `RedSalamanders/.github` | `a094b2e` (engine #86); the owner's local clone is at `570351e` (engine #16) | n/a | n/a | n/a | 3 | 2 / 11 |

Engine history is linear across the pins: `766fd7e` < `d6a33c5` < `07bc6f1` < `a094b2e`.

Facts behind the gaps:

- **GitHub is clean.** No merged pull request head branch still exists in any repository. "Automatically delete head branches" is on in `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, and `RedTilde`, and off in `RedHome` and `RedMonitor`.
- **The local clones are not.** They keep remote-tracking refs for branches GitHub deleted long ago (88 in `DxUi`, 66 in `RedTilde`, 27 in `RedMonitor`, 23 in `RedSalamander`), merged local branches such as `chore/prune-shared-skills-to-redhome`, and the worktree registrations in the table.
- **Local-only experiment branches** (never pushed, not merged): 29 in `RedTilde` (2026-10-23 to 2026-10-29) and 6 in `DxUi` (2026-10-25 to 2026-10-27).
- **`RedSalamander` `master`** exists only in the local clone. It is not an ancestor of `main` and holds 3,102 commits that `main` does not.
- **Engine notices**: 20 open Dependabot pull requests in `RedMonitor`, `RedPrism`, `RedTilde`, and `RedXe` each bump one workflow caller to `a094b2e`. `DxUi` merged four such bumps on 2026-11-16 (#257 to #260) and had to reconcile its callers with `.ci/project.json` the next day (#262). The `ignore` rule in `.github/dependabot.yml` names `RedSalamanders/.github`, which does not match the reusable-workflow dependency names (`RedSalamanders/.github/.github/workflows/<file>.yml`).
- **Stale references**: `RedSalamander` `Specs/Plans/WIP/Core_HResultStatusFormattingCleanup_2026-06-19.md` and `RedPrism` `Specs/Plans/WIP/AsyncDocumentSizing_2026-09-30.md` cite skill paths that the consolidation deleted.

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

Step identifiers are `CV-<phase>-<nn>`. A box is checked only when its gate has passed. "Delivered" means the change is in the named pull request; it takes effect when the owner merges it.

### Phase 0: clean baseline (hygiene, no content change)

Nothing in this phase has been deleted. Every destructive step is written out in [CleanupRunbook.md](Convergence_2026-11-17/CleanupRunbook.md) for the owner to run on the Windows host.

- [ ] **CV-0-01** Fast-forward the local `RedSalamanders/.github` clone (about 70 engine pull requests behind), so engine docs read from `RedHome` are current. Runbook step 1.
- [ ] **CV-0-02** Prune stale remote-tracking refs and delete merged local branches in every clone. GitHub needs no cleanup: no merged head branch remains there. Runbook steps 2 and 6.
- [ ] **CV-0-03** Turn on "Automatically delete head branches" in `RedHome` and `RedMonitor`, the two repositories where it is off. Runbook step 3.
- [ ] **CV-0-04** Archive, then remove, the local-only experiment branches (29 in `RedTilde`, 6 in `DxUi`): one verified `git bundle` per repository, then delete. Runbook steps 4 and 6.
- [ ] **CV-0-05** Remove finished worktrees on the Windows host (`RedTilde` 48 registrations, `DxUi` 44, engine clone 11). Never prune from WSL or a sandbox: the Windows paths are invisible there and every worktree looks `prunable`. Runbook step 5.
- [ ] **CV-0-06** `RedSalamander` local `master`: bundle it, then delete it, so the clone has the same single long-lived branch as every other repository. Runbook steps 4 and 6.
- [x] **CV-0-07** Triage `RedSalamander` `main`. Result: the failure is not caused by the skill consolidation. In run `43985619531` (commit `91d5319b`) the x64 regression job passed and the ARM64 job failed in "Run actual regression tests and Release assertion probe": `Tools/Run-AllTests.ps1` exited 1, and the hosted desktop boundary reported "A foreign foreground change must not be replaced by the hosted fixture" while Windows Terminal owned the foreground. Seven of the eight `Qualify main Release` runs since 2026-11-11 failed, on different commits, in the regression jobs. The fix belongs to `RedSalamander`'s own test plan. Until `ci-state` records `succeeded`, pull requests into `RedSalamander` from this plan stay limited to paths that its CI treats as prose.
- [x] **CV-0-08** Repair the stale skill paths in the two active plans named in the baseline. Delivered in the step 1 pull requests for `RedSalamander` (#228) and `RedPrism` (#32).
- [x] **CV-0-09** `RedXe` `Tests/BuildProcessTests/ScopedTesting.Tests.ps1` names `.agents/skills/yyjson/agents/openai.yaml`. Checked: the test passes the string to the scope planner as a path-classification sample and never opens the file. No change.

### Phase 1: RedHome is a complete front door

Delivered in `RedHome` pull request #2.

- [x] **CV-1-01** Restore the depth that the consolidation lost, from git history, under the seven shared skills.
- [x] **CV-1-02** Correct the shared text: `RedMonitor` is in the `grill-cross-repo` owner map and the `wiki-sync` page list; `cross-repo-pins` names the real `DxUi` contract file for each consumer and treats engine notices as signals.
- [x] **CV-1-03** Wiki: new [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) and [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md); the dependency matrix lists pin owners and API revisions instead of commit SHAs; `RedMonitor` joins the ecosystem matrix; the `RedTilde` Winget identifier, the `RedSalamander.Perf` placeholder, engine-notice and stale-checkout notes, and glossary terms are added. The `RedTilde` settings format is corrected: line-based `key=value` text, not JSON.
- [x] **CV-1-04** Plans have a home (`Specs/Plans/WIP/` and `Done/`), `validate.ps1` checks links under `Specs/`, and the workflow pins `actions/checkout` by commit as the engine policy does.
- [x] **CV-1-05** `validate.ps1 -CheckSiblings` runs for real. The `Validate RedHome` workflow now has a second job that checks out the seven sibling repositories beside `RedHome` and runs it on every pull request, on every push to `main`, and weekly. PowerShell 7 could not be installed where this change was authored, so GitHub Actions is the place where these scripts were executed.
- [x] **CV-1-07** `Tools/Get-WorkspaceStatus.ps1 -Hygiene` adds, from local git data only: days since the last fetch, local branches without an upstream, local branches merged into `origin/main`, local branches whose upstream was deleted, remote-tracking refs, and extra worktree registrations. Phase 0 stays visible instead of being rediscovered.
- [x] **CV-1-08** Validation is extended: every plan under `Specs/Plans/WIP/` is indexed in its `README.md`; every shared skill that has a `references/` folder ends with the same closing sections; under `-CheckSiblings`, each sibling `AGENTS.md` still carries the identical shared-skill pointer sentence.
- [ ] **CV-1-06** The owner reviews and merges `RedHome` pull request #2.

### Phase 2: one rule set per shared skill

Delivered in `RedHome` pull request #2. The first version of this plan kept one reference file per repository. Under the governing rule that was the wrong shape: it preserved six ways of doing the same thing. Each shared skill is now folded into one rule set.

All seven folds (CV-2-01 to CV-2-07) are done. Shape of every folded skill:

- `SKILL.md` states the rules once, for every repository.
- `references/<topic>.md` holds the detailed patterns and code, again once.
- `references/repository-facts.md` lists what is true of one product only: file paths, helper names, validators, gates. Facts, not rules.
- `SKILL.md` ends with `Differences To Converge`: every rule that repositories still apply differently, with its target. Each row is also in the register (section H, plus A and E where it is tooling).

| Step | Shared skill | Folded from | Result |
| --- | --- | --- | --- |
| **CV-2-01** | `yyjson` | 3 references | `patterns.md`, `repository-facts.md`; 2 differences |
| **CV-2-02** | `wil-raii` | 3 references | `patterns.md`, `repository-facts.md` |
| **CV-2-03** | `modern-cpp-windows` | 6 references | `cpp-style.md`, `error-handling.md`, `compiler-warnings.md`, `repository-facts.md` |
| **CV-2-04** | `localization` | 2 references | `patterns.md`, `repository-facts.md` |
| **CV-2-05** | `performance-resources` | 3 references | `repository-facts.md` |
| **CV-2-06** | `d3d11-win32-host` | 4 references | `repository-facts.md` |
| **CV-2-07** | `spec-workflow` | 5 references | `repository-facts.md` |

Gate that was applied to each fold: every code line and every inline identifier, flag, and path of the 26 source files is still present in the folded skill (checked by script; the only exceptions are two pragma lines that were merged into one block, and the names of skills that no longer exist), and every "where it is defined" claim in the repository facts was checked against the sibling sources.

Remaining steps:

- [ ] **CV-2-08** Remove rows from `Differences To Converge` as repositories converge. A skill is finished when its table is empty.
- [ ] **CV-2-09** One skill folder (register A-09, A-10): `RedSalamander` moves its 11 skills from `.github/skills/` to `.agents/skills/` and drops the extra front-matter keys, in one pull request that also updates its guidance spec, tool inventory, and CI excludes.
- [ ] **CV-2-10** `improve` provenance: the skill is locally customised while `skills-lock.json` still records the upstream hash. Declare the fork (drop the lock entry, keep licence and author in the skill) so the lock states only what is true.
- [ ] **CV-2-11** Codex `agents/openai.yaml` (register A-11): all skills or none. Default: none.
- [ ] **CV-2-12** Repository-local skills that cover the same subject in several repositories (for example testing and build skills in [Skill-Catalog.md](../../../wiki/Skill-Catalog.md)) are folded the same way, one subject per pull request, once their tooling converges in Phase 5.

### Phase 3: discovery in every harness, and outside RedHome

- [x] **CV-3-01** Native Claude Code discovery. `RedHome` is a Claude Code plugin (`.claude-plugin/plugin.json`, plugin `redhome`) whose skills are the canonical `.agents/skills/` folder, and a marketplace (`.claude-plugin/marketplace.json`, marketplace `redsalamanders`). Nothing is copied. Delivered in `RedHome` pull request #2.
- [x] **CV-3-02** Every repository opts in the same way: an identical `.claude/settings.json` that registers the marketplace from GitHub and enables the plugin, and an identical `CLAUDE.md`. Because the marketplace source is the GitHub repository, this works in sessions that see one repository only, with no sibling checkout. Delivered in the step 1 pull requests; `RedHome` carries the same settings file.
- [x] **CV-3-03** The pointer sentence is identical in all six sibling `AGENTS.md` files and `validate.ps1 -CheckSiblings` now enforces it.
- [ ] **CV-3-04** Other harnesses that see one repository only (Codex, Copilot, hosted agents): one identical setup step everywhere, `git clone https://github.com/RedSalamanders/RedHome ../RedHome`, documented in [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md). Add it to each hosted-agent setup the owner uses.
- [ ] **CV-3-05** Acceptance by the owner, in each harness in use, from `RedHome` and from one product repository: ask the agent to list its skills and to open `wil-raii` with the facts for that repository. Recorded so far: Claude Code CLI 2.1.326 validates the plugin and marketplace manifests, and a project-scope install of `redhome@redsalamanders`, with the marketplace read from GitHub at this branch, lists all 11 skills. The step 1 settings take effect after `RedHome` pull request #2 is merged, because the marketplace is read from `main`.

### Phase 4: pins (one engine, aligned producers)

- [x] **CV-4-01** Stop engine-notice drift at the source: add `RedSalamanders/.github/*` to the Dependabot `ignore` list (register G-02). Delivered in the step 1 pull requests of `DxUi`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`, identical in all five.
- [ ] **CV-4-02** The same line in `RedSalamander`. Its `Tools/Tests/HistoricalTerminalProfile.Tests.ps1` asserts that the list has exactly one entry, so the rule and the test change together. That touches a native input and starts the ARM64 qualification job, which fails today for the unrelated reason in CV-0-07, so this waits for a green `main`. `RedSalamander` is on the newest engine commit and has no open notice.
- [ ] **CV-4-03** Close the 20 open notice pull requests once CV-4-01 is merged in their repository (runbook step 7). They must not be merged: each bumps one caller only.
- [ ] **CV-4-04** One engine commit. Target: engine `main` at the time of the wave (`a094b2e` today, which `RedSalamander` already runs). Cadence: one wave a week, or immediately when a repository needs a fix, always all repositories.
- [ ] **CV-4-05** Run the wave, oldest pin first: `DxUi` (`766fd7e`), `RedMonitor` (`d6a33c5`), then `RedXe`, `RedPrism`, and `RedTilde` (`07bc6f1`). For each: `Update-ProjectPin.ps1` from a clean engine checkout at the target, sync `<repo>/.ci-engine`, add one `Changes/` fragment, pass the compiler-free checks, merge, and wait for `ci-state` to record `succeeded` before starting the next repository. This needs PowerShell and a Windows runner and was not attempted from the authoring environment.
- [ ] **CV-4-06** One `DxUi` revision and commit in every consumer (register H-01, H-02): `RedSalamander`, `RedXe`, `RedPrism`, and `RedMonitor` move to API 5, where `RedTilde` already is. Product work, owned by each repository's plan; this plan tracks it because it removes the largest block of code-convention differences.
- [ ] **CV-4-07** One vcpkg baseline, tool pin, and triplet set (register C-06, C-07).

Gate for the phase: `Get-WorkspaceStatus.ps1` shows one engine SHA and `OK` for every `.ci-engine`, and one `DxUi` commit in every lock.

### Phase 5: tooling (each shared script exists once)

Homes, the same for every repository:

| Kind of tooling | Home | Why |
| --- | --- | --- |
| Anything CI, build, scoped testing, changelog, or guidance validation runs | `RedSalamanders/.github`, consumed through the pinned `.ci-engine` | Already the single SHA-pinned implementation that local `build.ps1`, `test.ps1`, and `Test-Changes.ps1` load |
| `DxUi` restore, paths, provenance, pinned policy | `DxUi` consumer interface (`Tools/Consumer*.psm1`, `Build/DxUi.Consumer.*`) | Travels with the pin it serves; `DxUi` already owns `PinnedDxUiPolicy.targets` and the consumer modules |
| `RedMonitor` client update and verification | `RedMonitor`, delivered beside `Client.h` and hash-listed in `RedMonitor.lock.json` | Same hash-pinned channel as the header |
| Workspace status, wiki and plan validation | `RedHome/Tools/` | Only meaningful with every sibling present; never used by a build |

- [ ] **CV-5-01** Pilot the shim pattern in `RedMonitor` (smallest surface): the repository keeps a file with the same name and parameters that imports the engine implementation from `.ci-engine` and fails closed with one clear message when the engine is absent or at the wrong commit.
- [ ] **CV-5-02** Tier A: the changelog suite (register F-01). Reconcile the three variants into the engine with the engine's tests, then replace the copies with shims, one repository per pull request.
- [ ] **CV-5-03** Tier A continued: `BuildConsole.psm1`, `NativeBuildPolicy.targets`, `Get-CiNativeScope.ps1`, the `setup-msvc` action (F-02, F-08, C-02), and the formatter pin (D-02).
- [ ] **CV-5-04** Tier B, forks: `ScopedTesting.psm1`, `TestRunEvidence.psm1`, and `Test-Changes.ps1` with one parameter set (F-03, E-04). Write the design in the engine's own plan first (one planner, per-repository data for suites and paths), pin each fork's behavior with tests, then migrate.
- [ ] **CV-5-05** Tier C, guidance validation: one skill grammar and one package-integrity policy in the engine, replacing the seven implementations (F-04). `RedHome` then runs the engine as a documentation-kind project (G-10) and drops its own copy.
- [ ] **CV-5-06** Tier D, dependency tooling: `DxUiPaths.psm1`, `restore-dxui.ps1`, `DxUiRestore.psm1`, and `DxUiProvenance.psm1` behind the `DxUi` consumer interface, and the two `RedMonitor` client scripts behind the `RedMonitor` lock, with the same root script names everywhere (F-05, F-06, E-07, E-08, C-08).
- [ ] **CV-5-07** Tier E, toolchain: `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1` (F-07, E-09).

Gate for every step: the repository's `Test-Changes.ps1 -Mode PrePush` passes before and after with the same selected suites, and `main` reaches `ci-state` `succeeded`.

### Phase 6: one repository shape

Each step takes one section of the register to zero rows. One option per pull request per repository; identical text comes from one engine template, as the workflow callers do, so it cannot drift again.

- [ ] **CV-6-01** Prerequisite in the engine: add `.github/copilot-instructions.md` to the prose `exclude` template (A-04). Until then, adding that file to a repository changes its native inputs, which is why step 1 did not touch it.
- [ ] **CV-6-02** Guidance files (A-03, A-05 to A-08, A-12, A-13): identical `.github/copilot-instructions.md`, `AGENTS.md` title, headings, and shared sections, and `capabilities.json` everywhere.
- [ ] **CV-6-03** Specifications and documents (B-01 to B-12): one `Specs/README.md` structure, one WIP index format, the same top-level folders, one performance contract file name, one `Core_Changes.md`, one `Build_UnifiedCI.md` skeleton, the same root files.
- [ ] **CV-6-04** Build (C-01, C-03 to C-05, C-09): one warning profile, one switch set, one intermediate directory, one ASan property set, one minimum Windows version.
- [ ] **CV-6-05** Formatting (D-01, D-03, D-04): the 155-line `.clang-format` everywhere. Each adopter (`RedXe`, `RedPrism`, `RedTilde`) reformats in one dedicated pull request with no other change, at a moment with no open feature branch.
- [ ] **CV-6-06** Entry points (E-01 to E-03, E-05, E-06, E-10): every repository answers the same root commands with the same parameters. Existing names keep working as thin wrappers for one release.
- [ ] **CV-6-07** CI and project configuration (G-03 to G-09).
- [ ] **CV-6-08** Code conventions (H-03 to H-13), each in the owning repository's own plan, with the shared skill's `Differences To Converge` row removed in the same change.
- [ ] **CV-6-09** `RedHome` itself follows the same rules as every other repository: pull requests for `main`, auto-delete of head branches, a licence (B-11), and engine-run validation (G-10).

### Phase 7: sustain and close

- [ ] **CV-7-01** Run `wiki-sync` after each convergence pull request merges, and refresh [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) whenever a skill is added, moved, or removed.
- [ ] **CV-7-02** At each pin wave, review this plan's boxes and the register: delete converged rows, and move finished phases' lasting rules into `AGENTS.md`, `wiki/`, or the owning repository.
- [ ] **CV-7-03** Close: move this file and its companions to `Specs/Plans/Done/` when the register holds only rows that stay different by design.

---

## Pull requests

Step 1 is the same change in every product repository, limited to paths that the repository's CI treats as prose, so no native build is triggered. The one exception is the Dependabot line in `RedSalamander` (CV-4-02).

| Repository | Pull request | Content |
| --- | --- | --- |
| `RedHome` | [#2](https://github.com/RedSalamanders/RedHome/pull/2) | Phases 1 and 2, the plugin, this plan, validation and workspace-status extensions |
| `DxUi` | [#264](https://github.com/RedSalamanders/DxUi/pull/264) | Dependabot `ignore`, `CLAUDE.md`, `.claude/settings.json`, `Changes/` fragment |
| `RedSalamander` | [#228](https://github.com/RedSalamanders/RedSalamander/pull/228) | `CLAUDE.md`, `.claude/settings.json`, the stale skill paths in one plan, `Changes/` fragment |
| `RedXe` | [#98](https://github.com/RedSalamanders/RedXe/pull/98) | The same |
| `RedPrism` | [#32](https://github.com/RedSalamanders/RedPrism/pull/32) | The same, plus the stale skill paths in one plan |
| `RedTilde` | [#118](https://github.com/RedSalamanders/RedTilde/pull/118) | The same |
| `RedMonitor` | [#63](https://github.com/RedSalamanders/RedMonitor/pull/63) | The same |

Merge order: `RedHome` #2 first, then the six in any order.

## Decisions

### Resolved by the governing rule

The first version of this plan listed thirteen decisions and recommended an answer per case. Under the governing rule each has one answer.

| Id | Question | Answer |
| --- | --- | --- |
| **D1** | Where does repository-specific how-to end up? | Nowhere: there is no repository-specific how-to. The shared skill states one rule set; product paths are repository facts; every remaining difference is a register row with a target. |
| **D2** | Native Claude Code discovery | The plugin, enabled by the same `.claude/settings.json` in every repository. Delivered. |
| **D3** | Sessions that see one repository | Claude Code: the plugin, read from GitHub. Other harnesses: the same one-line clone of `RedHome` beside the repository. |
| **D4** | Skill folder | `.agents/skills/` everywhere (CV-2-09). |
| **D5** | `improve` provenance | Declare the fork (CV-2-10). |
| **D7** | Home for shared tooling | The engine, `DxUi`, and `RedMonitor`, as in Phase 5. No new repository. |
| **D8** | Root entry points | The same commands and parameters everywhere (CV-6-06). |
| **D9** | `.clang-format` | The 155-line file everywhere (CV-6-05). |
| **D10** | Branch hygiene | The same settings everywhere: auto-delete on, one long-lived branch, experiment branches archived as bundles. Deletions are run by the owner from the runbook. |
| **D11** | Engine pin cadence | One commit for all, moved in one weekly wave (CV-4-04). |
| **D12** | Dependabot engine notices | Ignored at the source, identically (CV-4-01, CV-4-02). Pin lag is reported by `Get-WorkspaceStatus.ps1`. |
| **D13** | `RedHome` governance | The same rules as every other repository (CV-6-09). |

### Owner choices

These are the register rows marked *Choice*: two common end states are possible, and the default below follows the order in the governing rule. Whichever is picked, every repository moves to it.

| Register row | Default | Alternative |
| --- | --- | --- |
| A-11 Codex `agents/openai.yaml` (was D6) | None: four of seven repositories have none | Add to every skill, if the Codex skill picker is used |
| A-12 Tool folders that exist in one repository | Promote to a template for all when a second repository needs it, otherwise remove | Keep, with the reason recorded as "different by design" |
| B-11 Licence file name, holder spelling, and third-party text | No default: legal text is the owner's to state | |
| B-12 `CODEOWNERS`, `CONTRIBUTING.md`, pull request template, `.editorconfig`, `.vsconfig` | Present everywhere, from one template | Absent everywhere |
| C-09 Minimum Windows version | Windows 11 22000.2600, declared by three repositories | Windows 10 `10.0.19041.0` everywhere, as `RedXe` supports today |
| G-08 Tests layout | `<Suite>Tests/<Suite>Tests.vcxproj`, used by three repositories | Flat `Tooling.Tests.*.ps1` |
| H-05 Logging helpers | `DxUi::Debug`, because every consumer already depends on the producer | The `Debug::` family from `RedSalamander` and `RedMonitor` |
| H-07 Satellite layout and loader | `Lang\<Module>-<culture>.dll`, used by two repositories | `Languages\<tag>\<Product>.resources.dll` |
| H-10 Settings format | JSON through `yyjson`, used by four repositories | Line-based text everywhere |

## Validation

| Phase | Proof |
| --- | --- |
| 0 | `Get-WorkspaceStatus.ps1 -Hygiene` shows zero stale refs, merged branches, local-only branches, and extra worktrees |
| 1 | Both jobs of the `Validate RedHome` workflow pass |
| 2 | The fold gate described under Phase 2; `validate.ps1 -CheckSiblings` |
| 3 | The CV-3-05 acceptance record |
| 4 | One engine SHA and one `DxUi` commit in `Get-WorkspaceStatus.ps1`; `ci-state` `succeeded` in every repository after its bump |
| 5 | Same `Test-Changes.ps1 -Mode PrePush` selection and result before and after each move; engine tests cover the moved tool |
| 6 | The register section for the step has no rows left; the command map in [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md) collapses to one row |

## Risks

- **`RedHome` becomes a hidden dependency.** Invariant 2 guards against it: nothing executable is consumed from `RedHome`. The plugin carries prose only.
- **The plugin follows `RedHome` `main` without a version.** That is deliberate, so skills never lag their source, and it means a bad merge to `RedHome` reaches every repository at the next plugin refresh. The `Validate RedHome` workflow is the gate.
- **Converging by majority copies a mistake.** The default order puts producer contracts and the stricter option before the majority, and every Phase 6 step passes the receiving repository's own gates.
- **A tree-wide reformat collides with open work.** CV-6-05 runs alone, per repository, with no open feature branch.
- **Engine-hosted tooling breaks local work when `.ci-engine` is missing or stale.** Shims fail closed with one actionable message; `Get-CiPinnedEngineInputsIdentity` already enforces this for builds.
- **Branch cleanup loses unpushed work.** The runbook archives and verifies before anything is deleted, and only the owner runs it.
- **A pin wave lands on a red `main`.** CV-0-07 records the state of `RedSalamander`; every wave step waits for `ci-state`.

## Closeout criteria

The plan closes when the register holds only rows that stay different by design; when a session started in `RedHome` or in any product repository reaches the same shared skills; when each shared script, module, and policy file has one owner and thin consumers; when every repository runs one engine commit and one `DxUi` revision; and when the lasting rules from this plan live in `AGENTS.md`, `wiki/`, the shared skills, or the owning repository's `Specs/`.
