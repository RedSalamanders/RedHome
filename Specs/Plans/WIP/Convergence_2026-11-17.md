# RedSalamanders convergence: one common ground, step by step

## Metadata

- **Status**: ACTIVE. Phases 1 and 2 and the `RedHome` side of Phase 3 are delivered in `RedHome` pull request #2, merged on 2026-11-17 as `16a2098`. Step 1 was merged in all six product repositories the same day (listed under [Pull requests](#pull-requests)), so the plugin they enable now resolves from `RedHome` `main`. Everything else is plan only.
- **Date**: 2026-11-17. Reviewed the same evening on the Windows host against the live clones and GitHub; see [Harness review](#harness-review-2026-11-17).
- **Baseline**: `RedHome` `origin/main` at `707ca84`; sibling state as recorded under [Baseline](#baseline-2026-11-17).
- **Scope**: `RedHome`, `DxUi`, `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`, `RedSalamanders/.github`.
- **Governing rule**: at the end, all projects are as close as possible for every option and every decision. See [Governing rule](#governing-rule).
- **Companions**: [DivergenceRegister.md](Convergence_2026-11-17/DivergenceRegister.md) lists every known difference with its single target. [CleanupRunbook.md](Convergence_2026-11-17/CleanupRunbook.md) holds the destructive hygiene steps, which only the owner runs.
- **Contracts to reconcile on closeout**: [AGENTS.md](../../../AGENTS.md), [wiki/Index.md](../../../wiki/Index.md) and the pages it lists, the shared skills under `.agents/skills/`, each sibling's `AGENTS.md` and `Specs/README.md`, and the engine's [Specs/CI.md](../../../../RedSalamanders/.github/Specs/CI.md).
- **Owner decisions**: D1 to D5 and D7 to D13 accepted on 2026-11-18, D2 and D10 with amendments. D14 to D19 and every owner choice were decided the same day: the plan's default where it had one, and the owner's own answer for B-11 and H-15 (D18, D19). No owner question is open. See [Decisions](#decisions).
- **Owner's part**: merging pull requests and the [owner choices](#owner-choices) where two common end states are possible.

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
9. **A style or flag change travels alone.** A tree-wide reformat or a compiler or linker setting never shares a pull request with a functional change, and a behavioral setting changes one at a time, so a regression has one possible cause and a small revert.
10. **Same is checked, not asserted.** A row leaves the register when a command shows the repositories agree (a file hash, a tool version, a parameter list), not when a pull request says so. CV-1-09 provides that command.

## Harness review (2026-11-17)

The owner restated the target as one harness for every project and named three parts of it. A review the same evening read all eight Windows clones and GitHub against those three parts. Its evidence is in the register rows it added or corrected.

| Part of the harness | Register | Steps | State after the review |
| --- | --- | --- | --- |
| Same settings and compilation | C, E, F | CV-6-04, CV-6-06, Phase 5 | Toolset, SDK, language mode, conformance, and the six build profiles already agree. Rows C-01 to C-19 remain; C-10 to C-19 are new. The rows that change no compiler or linker command line can start now |
| Same code formatting | D | CV-6-05 | Three styles. CI formats with one pinned formatter; three repositories format locally with an unpinned one, and no local command covers the same files as CI. Nothing here depends on Phase 4 or Phase 5 |
| Same skills for common code | A, H | Phases 2 and 3 | The shared skills are folded. Of the 42 local skills, eight subjects are covered by more than one repository; five of them can be folded now (CV-2-12) |

What the review changed in this plan:

- **Order.** The owner's first two points were the last steps of the plan (CV-6-04 and CV-6-05, behind Phases 4 and 5). Formatting, and the half of the compile profile that changes no command line, do not need one engine commit or engine-owned tooling. They are now free to start; see [Phase 6](#phase-6-one-repository-shape).
- **Proof.** Invariant 10 and CV-1-09: one read-only report that shows, per repository, whether the files and tools that must be the same are the same.
- **Skills.** CV-2-12 names the eight subjects, what their local skills already share, and what blocks each fold. CV-2-13 to CV-2-15 are new; CV-2-15, a correction to `wil-raii`, is delivered with the review.
- **Register.** 26 rows added (A-14 to A-18, B-13, C-10 to C-19, D-05, D-06, E-11 to E-13, G-11, G-12, H-14 to H-16) and ten corrected (A-01, A-02, A-10, A-12, C-02, C-03, D-01, D-02, F-04, G-02).
- **Facts.** Phase 0 is mostly done in the local clones, step 1 is merged, and the engine notices are closed; see [State at review](#state-at-review-2026-11-17-2145-cet).

How it was verified: PowerShell 7 and git on the Windows host, `gh` for GitHub, SHA-256 for files claimed identical, and the pinned WIL headers for the WIL claims. `validate.ps1` passes on this branch on the host for internal links; the sibling-link job passed in CI. Not verified: nothing was built, no MSBuild evaluation was run (property rows come from reading the files), the values that the short `.clang-format` styles inherit were not dumped from the formatter, and `ci-state` was not re-read after the step 1 merges.

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

### State at review (2026-11-17, 21:45 CET)

Read from the Windows clones and GitHub. The table above stays as the starting point.

| Repository | `main` on GitHub | Local clone | Branches on GitHub | Local branches / worktrees |
| --- | --- | --- | --- | --- |
| `RedHome` | `707ca84` | On `main` with the first commit of #2 as uncommitted changes; #2 itself is at `ae7efbe` | 2 (`main`, the #2 branch) | 1 / 0 |
| `DxUi` | `688631b7` | Level | 4 (`main`, `ci-state`, 2 unmerged work branches) | 1 / 0 |
| `RedSalamander` | `3eb4925e` | Level | 2 | 2 (`main`, `master`) / 0 |
| `RedXe` | `29c8c90a` | Level | 2 | 1 / 0 |
| `RedPrism` | `0540c60d` | Level | 2 | 1 / 0 |
| `RedTilde` | `73c6ac33` | Level | 2 | 1 / 0 |
| `RedMonitor` | `5e630789` | One merge behind (`2976072b`) | 3 (the merged step 1 branch was not deleted) | 1 / 0 |
| `RedSalamanders/.github` | `a094b2e` | Level | 3 | 1 / 0 |

- **Engine pins and `DxUi` locks are unchanged** from the baseline table; step 1 touched neither.
- **The local clones are clean.** Every clone has one local branch (`RedSalamander` also `master`), no extra worktree, and pruned remote-tracking refs. The experiment branches, the merged local branches, and the worktrees are gone.
- **No archive was found.** The folder the runbook writes its bundles to, `D:\Archive\RedSalamanders-20261117`, does not exist, and `D:\Archive` does not either. If the experiment branches were bundled somewhere else, record where. If they were not, their commits are still in the object stores for now: `git fsck --no-reflogs` reports 23 dangling branch tips in `RedTilde`, 22 of them committed between 2026-10-24 and 2026-10-29, and 24 in `DxUi`. They are lost when git next prunes; the runbook says how to keep them.
- **`RedSalamander` `master`** is still the only copy of its 3,102 commits. Its code is not: the tree of its tip `582d644b` is identical to `main` commit `397e15ad` ("Publish the validated RedSalamander source snapshot", 2026-10-26), which imported the private repository's source without its history. Only the history is unique to `master`.
- **Engine notices**: all 20 are closed and their branches deleted. No repository has an open pull request except `RedHome` #2.
- **"Automatically delete head branches"** is off in `RedHome`, `RedMonitor`, and the engine repository. The baseline counted two; the engine is the third.
- **Step 1 is identical where it should be**: `CLAUDE.md` and `.claude/settings.json` have the same blob in all six repositories. `.github/dependabot.yml` is one blob in `DxUi`, `RedXe`, `RedPrism`, `RedMonitor` and differs in `RedSalamander` and `RedTilde` (register G-03).
- **The plugin did not resolve yet.** The six settings files register the marketplace from `RedSalamanders/RedHome`, and `main` there had no `.claude-plugin/` until #2 was merged. It has since `16a2098` (2026-11-17).
- **More stale references** than the baseline lists: `RedSalamander` `Specs/Plans/WIP/Win32_Inventory.md` cites the deleted `.github/skills/wil-raii/SKILL.md`, and `DxUi` `Tools/tests/Test-BenchmarkGate.ps1` uses `.agents/skills/performance-resources/SKILL.md` as a sample path.

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
| `Build/NativeBuildPolicy.targets` | Five (not `RedMonitor`) | Same in `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde` (one SHA-256); `DxUi` is one include path ahead (`Samples\Shared`) |
| Release whole-program optimization block and the MSVC 14.52 check in `Directory.Build.targets` | Five (not `RedMonitor`) | The same block copied into each repository's own file |
| `Build/PinnedDxUiPolicy.targets` | Five (not `RedMonitor`) | Same in `DxUi`, `RedXe`, `RedPrism`, `RedTilde`; `RedSalamander` differs |
| `Build/DxUiPaths.psm1` | `RedXe`, `RedPrism`, `RedTilde` | Same |
| `Tools/Get-CiNativeScope.ps1` | `RedPrism`, `RedTilde` | Same |
| `Test-Changes.ps1` | All six | Same in `RedPrism` and `RedTilde`; four other variants. All six accept `-Explain` and `-Mode Affected, Full, PrePush` |
| `ScopedTesting.psm1`, `TestRunEvidence.psm1` | `RedPrism`, `RedTilde`, `RedXe` (`Build/`), `DxUi` (`Tools/`) | Four diverging forks each |
| Skill validation | `Tools/SkillValidation.psm1` (`RedHome`); `Build/SkillValidation.psm1` and `Build/SkillPackageIntegrity.psm1` (`RedXe`, `RedPrism`); `Build/SkillPackageIntegrity.psm1` alone (`RedTilde`); `Tools/Validation.psm1` (`DxUi`); `Build/AgentGuidance.psm1` (`RedMonitor`) | Six implementations of four grammar dialects (register A-16). `RedSalamander` has none: `Tools/Get-SpecInventory.ps1` checks `Specs/` only |
| Formatter pin and install | Engine `Policy/clang-format.json`; `Build/clang-format.json` in `RedSalamander` and `RedMonitor`; hard-coded twice in `DxUi` | One version (22.1.3) recorded in four places; no pin in `RedXe`, `RedPrism`, `RedTilde` |
| `restore-dxui.ps1`, `Build/DxUiRestore.psm1`, `Build/DxUiProvenance.psm1` | `RedXe`, `RedPrism`, `RedTilde`, `RedMonitor`; `RedSalamander` `Tools/Restore-DxUi.ps1` | Forks |
| `Update-RedMonitorClient.ps1`, `Verify-RedMonitorClient.ps1` | `RedPrism`, `RedTilde`, `RedXe` (root); `RedSalamander` (`Tools/`) | Same in `RedPrism` and `RedTilde`; two other variants |
| `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1` | Two to five repositories each | Forks; `DxUi` already exports the two modules to consumers |
| `.clang-format` | All six | One 155-line file in `RedSalamander`, `RedMonitor`, `DxUi` (one SHA-256); one 13-key style in `RedXe` and `RedPrism` (the files differ by a trailing blank line); a 7-key style in `RedTilde` |
| `Specs/Core/Core_Changes.md` | All six | Same in `RedXe`, `RedTilde`, `RedMonitor`; three variants |
| `.github/dependabot.yml` | All six | Same in `DxUi`, `RedXe`, `RedPrism`, `RedMonitor`; two variants |
| Workflow callers (`ci.yml`, `format.yml`, `security.yml`, ...) | All six | Generated from engine templates; they differ only by the pinned engine SHA |

The workflow callers are the model to follow: one implementation in the engine, pinned by SHA, with a thin generated caller per repository.

---

## Phases

Order and dependencies: Phase 0 and Phase 1 first. Phases 2, 3, and 4 can then run in parallel, together with the two parts of Phase 6 that need neither one engine commit nor engine-owned tooling: formatting (CV-6-05) and the build rows that change no compiler or linker command line (CV-6-04, first part). Phase 5 needs Phase 4, because engine-hosted tooling requires every repository on one engine. The rest of Phase 6 builds on 5. Phase 7 closes the plan.

Step identifiers are `CV-<phase>-<nn>`. A box is checked only when its gate has passed. "Delivered" means the change is in the named pull request; it takes effect when the owner merges it.

### Phase 0: clean baseline (hygiene, no content change)

Every destructive step is written out in [CleanupRunbook.md](Convergence_2026-11-17/CleanupRunbook.md) for the owner to run on the Windows host. The review found most of this phase already done in the local clones; the boxes below record what it observed there, not who ran it.

- [x] **CV-0-01** Fast-forward the local `RedSalamanders/.github` clone, so engine docs read from `RedHome` are current. Runbook step 1. Observed at the review: `main` is level with `origin/main` at `a094b2e`.
- [x] **CV-0-02** Prune stale remote-tracking refs and delete merged local branches in every clone. Runbook steps 2 and 6. Done on 2026-11-18: `git fetch --prune origin` in all eight clones, after which each lists exactly the branches GitHub has. The merged head branches still on GitHub were deleted: `RedHome` `ej/redhome-convergence-20261117` (#2) and `ej/redhome-convergence-followup-20261118` (#3), `RedMonitor` `ej/convergence-step1-20261117` (#63). Each was checked to be contained in `main` first, and GitHub can restore each from its pull request page. The two merged local branches in `RedHome` are deleted, and the `RedMonitor` clone is fast-forwarded.
- [x] **CV-0-03** Turn on "Automatically delete head branches" in `RedHome`, `RedMonitor`, and the engine repository, the three where it was off. Runbook step 3. Done on 2026-11-18; it is now on in all eight repositories.
- [x] **CV-0-04** Archive, then remove, the local-only experiment branches (29 in `RedTilde`, 6 in `DxUi`): one verified `git bundle` per repository, then delete. Runbook steps 4 and 6. The branches were already gone at the review; their commits were found unreferenced in the object stores and pinned on 2026-11-18. Done the same day, in the archive folder the owner approved (D14): `RedTilde-unreferenced-and-backups-20261118.bundle` (41 MB: 28 unreferenced commits and 3 backups) and `DxUi-unreferenced-and-backups-20261118.bundle` (162 MB: 24 and 7), both in `D:\Archive\RedSalamanders-20261117`. For each, `git bundle verify` reports a complete history, the heads equal the refs one for one, and a fetch into an empty repository has no missing object. The pinned refs and the backups (CV-0-11) were then deleted from the clones. Restore with `git -C <clone> fetch <bundle> "refs/*:refs/*"`.
- [x] **CV-0-05** Remove finished worktrees on the Windows host. Never prune from WSL or a sandbox: the Windows paths are invisible there and every worktree looks `prunable`. Runbook step 5. Observed at the review: no extra worktree in any clone. The review's own worktree in `RedHome` was removed on 2026-11-18.
- [x] **CV-0-06** `RedSalamander` local `master`: bundle it, then delete it, so the clone has the same single long-lived branch as every other repository. Runbook steps 4 and 6. Done on 2026-11-17 after the review: `D:\Archive\RedSalamanders-20261117\RedSalamander-local-branches.bundle` (338 MB) holds `refs/heads/master` at `582d644b`; `git bundle verify` reports a complete history, and a clone of the bundle has the same 3,103 commits as the branch. The local branch is deleted and the clone now has only `main`. GitHub had no `master` already (`git ls-remote` lists only `main`), and no archive tag was pushed. Restore with `git -C D:\RedSalamander fetch <bundle> master:master`. Copy the archive folder to a second disk, as runbook step 4 asks.
- [x] **CV-0-07** Triage `RedSalamander` `main`. Result: the failure is not caused by the skill consolidation. In run `43985619531` (commit `91d5319b`) the x64 regression job passed and the ARM64 job failed in "Run actual regression tests and Release assertion probe": `Tools/Run-AllTests.ps1` exited 1, and the hosted desktop boundary reported "A foreign foreground change must not be replaced by the hosted fixture" while Windows Terminal owned the foreground. Seven of the eight `Qualify main Release` runs since 2026-11-11 failed, on different commits, in the regression jobs. The fix belongs to `RedSalamander`'s own test plan. Until `ci-state` records `succeeded`, pull requests into `RedSalamander` from this plan stay limited to paths that its CI treats as prose.
- [x] **CV-0-08** Repair the stale skill paths in the two active plans named in the baseline. Delivered in the step 1 pull requests for `RedSalamander` (#228) and `RedPrism` (#32).
- [x] **CV-0-09** `RedXe` `Tests/BuildProcessTests/ScopedTesting.Tests.ps1` names `.agents/skills/yyjson/agents/openai.yaml`. Checked: the test passes the string to the scope planner as a path-classification sample and never opens the file. No change.
- [x] **CV-0-10** Maintenance branches (D10 as amended). `main` is the only long-lived development branch in every repository. A supported older line may have one maintenance branch, named `maintenance/<line>`, protected against deletion and force-push, and named in that repository's `AGENTS.md`. Fixes land on `main` first and are cherry-picked, unless they apply only to the old line. A maintenance branch is never the head of a pull request into `main`, so automatic deletion never removes it. Today `DxUi` has one, which was named `ej/api4-maintenance-4cdf1ce5`: forked from `main` at `4cdf1ce5`, 12 commits ahead. It holds `7fb2ab71`, which `RedSalamander`'s `Dependencies/DxUi.lock.json` pins and no other branch contains, so deleting it would leave that lock pointing at a commit only reachable from the lock. Done on 2026-11-18 (D15): renamed to `maintenance/api4` on GitHub, and a `DxUi` ruleset named "maintenance branches" forbids deleting or force-pushing any `refs/heads/maintenance/*`. Consumers clone the whole repository and check out the locked commit, so the rename changes nothing for them. The same ruleset was added to the other seven repositories the same day, so the rule exists before their first maintenance line, and `DxUi` pull request #265 names the branch in its `AGENTS.md`.
- [x] **CV-0-11** Refs that tools write into the clones. Decided on 2026-11-18 (D17): the 2026-11-06 backups (`refs/backup/codex-20261106/*`, 3 in `RedTilde`, 7 in `DxUi`) were bundled with CV-0-04 and deleted. The tools' own refs stay, because they back the undo and checkpoint features of the tools that wrote them: `refs/codex/*` in `RedSalamander`, `RedTilde`, and `DxUi`, and `refs/agents/*/checkpoints/*` in `RedSalamander`. The stash entry in `DxUi` also stays.

### Phase 1: RedHome is a complete front door

Delivered in `RedHome` pull request #2, and CV-1-09 in #6.

- [x] **CV-1-01** Restore the depth that the consolidation lost, from git history, under the seven shared skills.
- [x] **CV-1-02** Correct the shared text: `RedMonitor` is in the `grill-cross-repo` owner map and the `wiki-sync` page list; `cross-repo-pins` names the real `DxUi` contract file for each consumer and treats engine notices as signals.
- [x] **CV-1-03** Wiki: new [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) and [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md); the dependency matrix lists pin owners and API revisions instead of commit SHAs; `RedMonitor` joins the ecosystem matrix; the `RedTilde` Winget identifier, the `RedSalamander.Perf` placeholder, engine-notice and stale-checkout notes, and glossary terms are added. The `RedTilde` settings format is corrected: line-based `key=value` text, not JSON.
- [x] **CV-1-04** Plans have a home (`Specs/Plans/WIP/` and `Done/`), `validate.ps1` checks links under `Specs/`, and the workflow pins `actions/checkout` by commit as the engine policy does.
- [x] **CV-1-05** `validate.ps1 -CheckSiblings` runs for real. The `Validate RedHome` workflow now has a second job that checks out the seven sibling repositories beside `RedHome` and runs it on every pull request, on every push to `main`, and weekly. PowerShell 7 could not be installed where this change was authored, so GitHub Actions is the place where these scripts were executed.
- [x] **CV-1-07** `Tools/Get-WorkspaceStatus.ps1 -Hygiene` adds, from local git data only: days since the last fetch, local branches without an upstream, local branches merged into `origin/main`, local branches whose upstream was deleted, remote-tracking refs, and extra worktree registrations. Phase 0 stays visible instead of being rediscovered.
- [x] **CV-1-08** Validation is extended: every plan under `Specs/Plans/WIP/` is indexed in its `README.md`; every shared skill that has a `references/` folder ends with the same closing sections; under `-CheckSiblings`, each sibling `AGENTS.md` still carries the identical shared-skill pointer sentence.
- [x] **CV-1-06** The owner reviews and merges `RedHome` pull request #2. Merged on 2026-11-17 as `16a2098`, with both `Validate RedHome` jobs green on its head `1467ade`. One commit pushed to the same branch a minute after the merge (`ac3cdf4`, CV-0-06) reached `main` through a follow-up pull request.
- [x] **CV-1-09** A harness report beside `-Hygiene`: `Tools/Get-WorkspaceStatus.ps1 -Harness` prints, for every repository, the SHA-256 of each file that must be the same (`.clang-format`, `.editorconfig`, `.gitattributes`, `Build/NativeBuildPolicy.targets`, `Build/PinnedDxUiPolicy.targets`, `CLAUDE.md`, `.claude/settings.json`, `.github/copilot-instructions.md`, `.github/dependabot.yml`), the formatter version its format script would use, and which root commands exist with which parameters. Read-only, local data only. It is the command invariant 10 asks for, the gate for CV-6-04 to CV-6-06, and later the body of a compiler-free conformance check in the engine. Delivered in `RedHome` pull request #6 on 2026-11-18. It reads each clone's checked-out commit through one `git cat-file --batch` per repository, so a CRLF checkout or an uncommitted edit never counts as a difference. It parses the format script, the modules that script imports, and every root script, and runs none of them, because running a repository's formatter lookup could install a formatter. It adds about 3 seconds to the plain report, and the `Validate RedHome` workflow prints it on every run. Its first run agrees with every register row it covers: A-01, A-03, B-12, C-02, C-08, D-01 to D-03, E-01 to E-06, E-10, E-12, and G-03. The script now also finds the siblings when it runs from a `RedHome` worktree.

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
- [ ] **CV-2-12** Repository-local skills that cover the same subject in several repositories ([Skill-Catalog.md](../../../wiki/Skill-Catalog.md)) are folded the same way, one subject per pull request. The review read each family in full. Five subjects can be folded now: their rules are already the same, and what differs fits in repository facts. The other three wait for the register rows named in the last column.

  | Subject | Local skills today | What they already share | Fold |
  | --- | --- | --- | --- |
  | Tests and evidence | `test-harness` in `RedPrism`, `RedTilde`, `RedMonitor`; the generic steps of `RedSalamander` `perf-validation` | Hidden non-activating captures; no foreground, clipboard, or cursor use without agreement; preserve failures; a focused pass is not qualification; source-bound receipts; paired same-machine baselines; expected values independent of the code under test | Now. Capture, crash-probe, and interactive switch names stay repository facts until E-13 |
  | Crash dumps | `crash-handling` in `RedPrism`; the crash half of `RedTilde` `settings-crashes`. `RedXe` and `RedSalamander` have the handler code and no skill for writing it | Install before UI and workers; no allocation in the fault path; local only; pending marker and next-start prompt; probes in an isolated child process; a separate ASan check | Now. The artifact shape waits for H-16 |
  | File safety | `file-safety` in `RedTilde` and `RedMonitor`; the same temporary-file-then-replace code in `RedXe` and `RedPrism` | Validate before publishing; failure or cancel preserves the target; completion keyed by request identity; fault tests in isolated directories | Now |
  | Settings | `settings-store` in `RedXe` and `RedPrism`; the settings half of `RedTilde` `settings-crashes` | The spec owns the fields; a live reload never writes the watched file; an invalid cold start backs up and installs the template; coalesced change notification applied on the UI thread; harness runs never touch the user's file | Now, with the reload policy of D19 (H-15). `RedTilde`'s store moves to JSON with H-10 |
  | Build, restore, package | `cpp-build`, `build-redxe`, `build-redprism`, `build-redtilde`, `build-redmonitor`, `build-dxui` | Root entry points only; the six-profile matrix; never kill a running executable; discover Visual Studio; pinned vcpkg under `.build`; ARM64 is a cross-build; a real ASan probe; Release-only package with a clean-extraction smoke | Rules now, with the command table as repository facts. The table empties with E-01 to E-12 |
  | UI thread and workers | `async-threading` in `RedSalamander`; the same rule in the `AGENTS.md` of `RedTilde`, `RedMonitor`, `RedPrism` | Publish on the UI owner, cancel by identity, reject stale completion | After H-14 (one posted-payload helper) |
  | Win32 window and Direct2D | `win32-wndproc` and `direct2d-rendering` in `RedSalamander`; `win32-host` in `DxUi` | Small handlers, instance binding in `WM_NCCREATE`, DPI handling, `BeginDraw` with scoped `EndDraw` | With CV-2-14 |
  | Consuming `DxUi` and `RedMonitor` | `consumer-integration` in `DxUi`; `consumer-dxui` in `RedPrism` and `RedTilde`; `consumer-adoption` in `RedMonitor` | Exact commit lock; public headers only; matching toolchain; consumer qualification not replaced by producer tests | With H-01. The consumer contract text is B-13 |

  The fold gate of this phase applies to each subject: every rule and code line of the source skills is still present afterwards, and nothing is removed from a repository until the folded skill has been read from that repository. Skills that only one repository has (`theming`, `icon-cache`, `plugin-callbacks`, `hlsl-composition`, `markdown-editing`, and the like) stay where they are. Code that several repositories have and no skill covers (ETW and TraceLogging instrumentation, UI Automation providers, HLSL build rules, dark mode) gets a shared skill when a second repository needs guidance that exists nowhere.
- [ ] **CV-2-13** Every skill description says what the skill does and then when to use it ("Use when ..."), because a harness picks a skill from its description alone (register A-14). 10 of the 11 shared skills and 23 of the 42 local ones do not. Shared skills first; the common validator then requires the clause (CV-5-05).
- [ ] **CV-2-14** `d3d11-win32-host` states window rules for every host and Direct3D rules for Direct3D hosts separately. Today "validate `WM_PAINT` without rendering" reads as a rule for every window, which `RedSalamander`'s GDI and Direct2D windows correctly do not follow, and the skill has no facts for `RedMonitor`, which owns a Direct3D 11 host, or for `RedTilde`, which presents through `DxUi`'s `WindowHost`.
- [x] **CV-2-15** `wil-raii` corrected at the review: it named `HMENU` as a handle without a WIL wrapper and spelled out `wil::unique_any<...>` for fonts, brushes, and pens. The pinned WIL (0.260126.7) defines `wil::unique_hmenu`, `wil::unique_hfont`, `wil::unique_hbrush`, and `wil::unique_hpen`, and the product code uses them.

### Phase 3: discovery in every harness, and outside RedHome

- [x] **CV-3-01** Native Claude Code discovery. `RedHome` is a Claude Code plugin (`.claude-plugin/plugin.json`, plugin `redhome`) whose skills are the canonical `.agents/skills/` folder, and a marketplace (`.claude-plugin/marketplace.json`, marketplace `redsalamanders`). Nothing is copied. Delivered in `RedHome` pull request #2.
- [x] **CV-3-02** Every repository opts in the same way: an identical `.claude/settings.json` that registers the marketplace from GitHub and enables the plugin, and an identical `CLAUDE.md`. Because the marketplace source is the GitHub repository, this works in sessions that see one repository only, with no sibling checkout. Merged in all six product repositories with step 1 (one blob each for `CLAUDE.md` and `.claude/settings.json`); `RedHome` carries the same settings file. It took effect when #2 was merged on 2026-11-17.
- [x] **CV-3-03** The pointer sentence is identical in all six sibling `AGENTS.md` files and `validate.ps1 -CheckSiblings` now enforces it.
- [ ] **CV-3-04** Every harness, not only Claude Code (D2 as amended: Codex, Antigravity, and others). Where each one looks, from the vendors' documentation on 2026-11-18:

  | Harness | Skills inside a repository | Skills for every repository on the machine | Instructions |
  | --- | --- | --- | --- |
  | Claude Code | `.claude/skills/`, or a plugin | `~/.claude/skills/`, or a plugin | `CLAUDE.md` |
  | Codex | `.agents/skills/` in every folder from the working directory up to the repository root | `~/.agents/skills/` | `AGENTS.md` |
  | Antigravity | `.agents/skills/` at the workspace root | `~/.gemini/config/skills/` per Google's codelab; other guides give `~/.gemini/antigravity/skills/` | Not stated in the codelab; to check |
  | GitHub Copilot | `.github/skills/`, `.claude/skills/`, or `.agents/skills/` | `~/.copilot/skills/` or `~/.agents/skills/` | `.github/copilot-instructions.md`, `AGENTS.md` |

  So inside `RedHome`, Codex, Antigravity, and Copilot find the shared skills natively in `.agents/skills/`, and Claude Code finds them through the plugin. In a product repository only Claude Code does today: the shared skills are not in that repository. Hosted agents that see one repository use the same one-line setup step everywhere, `git clone https://github.com/RedSalamanders/RedHome ../RedHome` (D3), documented in [Working-From-RedHome.md](../../../wiki/Working-From-RedHome.md).
- [ ] **CV-3-05** Acceptance by the owner in Claude Code, Codex, Antigravity, and Copilot, each from `RedHome` and from one product repository: ask the agent to list its skills and to open `wil-raii` with the facts for that repository. Recorded so far: Claude Code CLI 2.1.326 validates the plugin and marketplace manifests, and a project-scope install of `redhome@redsalamanders`, with the marketplace read from GitHub at this branch, lists all 11 skills. `RedHome` pull request #2 is merged, so the step 1 settings now read the marketplace from `main`. The other three harnesses wait for CV-3-06.
- [ ] **CV-3-06** One install for the other harnesses. `Tools/Install-SharedSkills.ps1` in `RedHome` links each shared skill folder into the machine-wide skill folders of the harnesses found on the machine: `~/.agents/skills/<name>` for Codex and Copilot, and Antigravity's global folder. It reports by default and writes only with `-Apply`; it links and never copies, so every skill still exists once, in `RedHome`. Codex documents that it follows symlinked skill folders; on Windows a symlink needs Developer Mode or elevation and a directory junction does not, so the script checks which link each harness accepts. Because Codex does not merge two skills with the same name, every shared and local skill name must be unique (register A-15).
- [ ] **CV-3-07** An instruction pointer for every harness that does not read `AGENTS.md`. If Antigravity does not, add its pointer file to every repository with the same text and the same validation as `CLAUDE.md` (at most six lines, one link to `AGENTS.md`).

### Phase 4: pins (one engine, aligned producers)

- [x] **CV-4-01** Stop engine-notice drift at the source: add `RedSalamanders/.github/*` to the Dependabot `ignore` list (register G-02). Merged with step 1 in `DxUi`, `RedXe`, `RedPrism`, `RedTilde`, and `RedMonitor`, the same line in all five.
- [ ] **CV-4-02** The same line in `RedSalamander`. Its `Tools/Tests/HistoricalTerminalProfile.Tests.ps1` asserts that the list has exactly one entry, so the rule and the test change together. That touches a native input and starts the ARM64 qualification job, which fails today for the unrelated reason in CV-0-07, so this waits for a green `main`. `RedSalamander` is on the newest engine commit and has no open notice.
- [x] **CV-4-03** Close the 20 open notice pull requests once CV-4-01 is merged in their repository (runbook step 7). They must not be merged: each bumps one caller only. Observed at the review: none is open and their branches are deleted.
- [ ] **CV-4-04** One engine commit. Target: engine `main` at the time of the wave (`a094b2e` today, which `RedSalamander` already runs). Cadence: one wave a week, or immediately when a repository needs a fix, always all repositories.
- [ ] **CV-4-05** Run the wave, oldest pin first: `DxUi` (`766fd7e`), `RedMonitor` (`d6a33c5`), then `RedXe`, `RedPrism`, and `RedTilde` (`07bc6f1`). For each: `Update-ProjectPin.ps1` from a clean engine checkout at the target, sync `<repo>/.ci-engine`, add one `Changes/` fragment, pass the compiler-free checks, merge, and wait for `ci-state` to record `succeeded` before starting the next repository. This needs PowerShell and a Windows runner and was not attempted from the authoring environment.
- [ ] **CV-4-06** One `DxUi` revision and commit in every consumer (register H-01, H-02): `RedSalamander`, `RedXe`, `RedPrism`, and `RedMonitor` move to API 5, where `RedTilde` already is. Product work, owned by each repository's plan; this plan tracks it because it removes the largest block of code-convention differences.
- [ ] **CV-4-07** One vcpkg baseline, tool pin, triplet set, and restore model (register C-06, C-07, C-14), moved together like the engine pin.

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
- [ ] **CV-5-03** Tier A continued: `BuildConsole.psm1`, `NativeBuildPolicy.targets` together with the Release optimization block and the toolset check that five repositories copy beside it (C-02, C-10, C-12), `Get-CiNativeScope.ps1`, and the `setup-msvc` action (F-02, F-08). Files that a tool must find at a fixed path (`.clang-format`, `.editorconfig`, the common `.gitattributes` and `.gitignore` blocks, the policy targets) are written into each repository by `Update-ProjectPin.ps1` from an engine template, as the workflow callers are, and a compiler-free check fails when a copy differs from the pinned engine's. The formatter pin (D-02) no longer waits for this step; see CV-6-05.
- [ ] **CV-5-04** Tier B, forks: `ScopedTesting.psm1`, `TestRunEvidence.psm1`, and `Test-Changes.ps1` with one parameter set (F-03, E-04). Write the design in the engine's own plan first (one planner, per-repository data for suites and paths), pin each fork's behavior with tests, then migrate.
- [ ] **CV-5-05** Tier C, guidance validation: one skill grammar and one package-integrity policy in the engine, replacing the six implementations and giving `RedSalamander` its first (F-04, A-16). The grammar is the one `RedHome`, `RedXe`, and `RedPrism` already share, because it accepts every skill that exists today; it gains `RedTilde`'s package-integrity checks, `RedHome`'s `AGENTS.md` index and pointer-file checks, and the "Use when" clause (CV-2-13). `RedHome` then runs the engine as a documentation-kind project (G-10) and drops its own copy.
- [ ] **CV-5-06** Tier D, dependency tooling: `DxUiPaths.psm1`, `restore-dxui.ps1`, `DxUiRestore.psm1`, and `DxUiProvenance.psm1` behind the `DxUi` consumer interface, and the two `RedMonitor` client scripts behind the `RedMonitor` lock, with the same root script names everywhere (F-05, F-06, E-07, E-08, C-08).
- [ ] **CV-5-07** Tier E, toolchain: `vcpkg-install.ps1`, `VcpkgTriplet.psm1`, `VisualStudio.psm1`, `Install-ClangFormat.ps1` (F-07, E-09).

Gate for every step: the repository's `Test-Changes.ps1 -Mode PrePush` passes before and after with the same selected suites, and `main` reaches `ci-state` `succeeded`.

### Phase 6: one repository shape

Each step takes one section of the register to zero rows. One option per pull request per repository; identical text comes from one engine template, as the workflow callers do, so it cannot drift again.

- [ ] **CV-6-01** Prerequisite in the engine: add `.github/copilot-instructions.md` to the prose `exclude` template (A-04), together with the other harness paths the template misses (G-12). Until then, adding that file to a repository changes its native inputs, which is why step 1 did not touch it.
- [ ] **CV-6-02** Guidance files (A-03, A-05 to A-08, A-12, A-13, A-17, A-18): identical `.github/copilot-instructions.md`, `AGENTS.md` title, headings, and shared sections, `capabilities.json` everywhere, personal harness files ignored everywhere, and the contradictions inside the guidance resolved.
- [ ] **CV-6-03** Specifications and documents (B-01 to B-13): one `Specs/README.md` structure, one WIP index format, the same top-level folders, one performance contract file name, one `Core_Changes.md`, one `Build_UnifiedCI.md` skeleton, the same root files, one `RedMonitor` consumer contract.
- [ ] **CV-6-04** Build: one compile profile (C-01, C-03 to C-05, C-09 to C-19). The profile is written once as a table in the engine's `Specs/`; the "Shared native build policy" section of each `AGENTS.md`, the shared policy page, and `modern-cpp-windows` link to it instead of restating it. Two parts:
  - **Part 1 changes no compiler or linker command line and can start now.** One pull request per repository: bring the four trailing copies of `NativeBuildPolicy.targets` up to `DxUi`'s text (C-02); move toolset, SDK, character set, runtime library, optimization, `/utf-8`, and `/MP` from project files into `Directory.Build.props` (C-11); add the 14.52 check and a root `.sln` to `RedMonitor` (C-12, C-17); replace the three consumer-named triplet properties in the policy file with one neutral property (C-19). Proof: a preprocessed project or binary log before and after shows the same `ClCompile` and `Link` settings, and the six profiles build with zero warnings.
  - **Part 2 is behavioral: one setting per pull request per repository**, each fully qualified (x64 tests in three configurations, ARM64 builds, `ci-state` `succeeded`) before the next. `RedMonitor` to `/Wall` (C-01), then its Release optimization and Debug `/ZI` (C-10); `/Zc:preprocessor` and the common defines in `RedSalamander` and `RedMonitor` (C-03); the ASan property set and strategy (C-05, C-13); compiler host selection (C-15); the test-hook macro (C-16); static analysis (C-18); the intermediate directory (C-04); the minimum Windows version (C-09).
- [ ] **CV-6-05** Formatting: one style, one formatter, one command, one scope (D-01 to D-06). Needs neither Phase 4 nor Phase 5.
  - **Formatter (D-02).** Every `format.ps1` takes its binary from `Install-CiFormatter` in the repository's own `.ci-engine`. That function is exported at every engine commit pinned today and installs the 22.1.3 build that CI uses. Remove the other pins and the Visual Studio and `PATH` lookups. The 155-line style uses keys that need `clang-format` 21 or newer, so in `RedXe`, `RedPrism`, and `RedTilde` this lands in the reformat pull request.
  - **Command and scope (D-05, E-02).** `format.ps1` formats and `format.ps1 -Check` verifies without writing, both over the `formatRoots` and `formatExclude` of `.ci/project.json` and the eight extensions CI formats.
  - **Reformat (D-01)**, in the order `RedTilde` (about 60 files), `RedXe` (about 260), `RedPrism` (about 1,360). One pull request per repository holding the canonical `.clang-format`, the reformat produced by the pinned formatter, and nothing else. The engine checks the whole tree when the style file changes, so the two cannot be split. No open feature branch at that moment. `RedTilde` also flips pointer alignment. `RedPrism` regenerates `Common/BoundedClipper` and its `generation-manifest.json` as that folder's README describes instead of formatting generated files. Proof: the CI format job green, six profiles with zero warnings, tests and goldens unchanged. A follow-up adds the merge commit to `.git-blame-ignore-revs`.
  - **Line endings and editor (D-03, D-04, B-12).** One `.gitattributes` block and one `.editorconfig`. Renormalizing a tree is its own pull request and leaves hash-locked vendored files untouched.
  - **Specs (D-06).** The four specs that describe formatting differently from what the engine does are corrected in their repositories.
- [ ] **CV-6-06** Entry points (E-01 to E-03, E-05, E-06, E-10 to E-13): every repository answers the same root commands with the same parameters and the same meaning, and the application harness switches have one vocabulary. Existing names keep working as thin wrappers for one release.
- [ ] **CV-6-07** CI and project configuration (G-03 to G-09).
- [ ] **CV-6-08** Code conventions (H-03 to H-13), each in the owning repository's own plan, with the shared skill's `Differences To Converge` row removed in the same change.
- [ ] **CV-6-09** `RedHome` itself follows the same rules as every other repository: pull requests for `main`, auto-delete of head branches, the same MIT `LICENSE.txt` as the products (B-11, D18), and engine-run validation (G-10).

### Phase 7: sustain and close

- [ ] **CV-7-01** Run `wiki-sync` after each convergence pull request merges, and refresh [Skill-Catalog.md](../../../wiki/Skill-Catalog.md) whenever a skill is added, moved, or removed.
- [ ] **CV-7-02** At each pin wave, review this plan's boxes and the register: delete converged rows, and move finished phases' lasting rules into `AGENTS.md`, `wiki/`, or the owning repository.
- [ ] **CV-7-03** Close: move this file and its companions to `Specs/Plans/Done/` when the register holds only rows that stay different by design.

---

## Pull requests

Step 1 is the same change in every product repository, limited to paths that the repository's CI treats as prose, so no native build is triggered. The one exception is the Dependabot line in `RedSalamander` (CV-4-02).

| Repository | Pull request | Content | State |
| --- | --- | --- | --- |
| `RedHome` | [#2](https://github.com/RedSalamanders/RedHome/pull/2) | Phases 1 and 2, the plugin, this plan, validation and workspace-status extensions | Merged 2026-11-17 (`16a2098`) |
| `DxUi` | [#264](https://github.com/RedSalamanders/DxUi/pull/264) | Dependabot `ignore`, `CLAUDE.md`, `.claude/settings.json`, `Changes/` fragment | Merged 2026-11-17 |
| `RedSalamander` | [#228](https://github.com/RedSalamanders/RedSalamander/pull/228) | `CLAUDE.md`, `.claude/settings.json`, the stale skill paths in one plan, `Changes/` fragment | Merged 2026-11-17 |
| `RedXe` | [#98](https://github.com/RedSalamanders/RedXe/pull/98) | The same | Merged 2026-11-17 |
| `RedPrism` | [#32](https://github.com/RedSalamanders/RedPrism/pull/32) | The same, plus the stale skill paths in one plan | Merged 2026-11-17 |
| `RedTilde` | [#118](https://github.com/RedSalamanders/RedTilde/pull/118) | The same | Merged 2026-11-17 |
| `RedMonitor` | [#63](https://github.com/RedSalamanders/RedMonitor/pull/63) | The same | Merged 2026-11-17; its head branch remains |

The intended order was `RedHome` #2 first. The six were merged first, a few hours earlier; their plugin setting has worked since #2 was merged.

## Decisions

### Decided

The first version of this plan listed thirteen decisions. The governing rule gave each one answer, and the owner accepted D1 to D5 and D7 to D13 on 2026-11-18, amending D2 and D10. D6 became register row A-11 and is an owner choice below.

| Id | Question | Answer |
| --- | --- | --- |
| **D1** | Where does repository-specific how-to end up? | Nowhere: there is no repository-specific how-to. The shared skill states one rule set; product paths are repository facts; every remaining difference is a register row with a target. |
| **D2** | Skill discovery in every harness | Amended by the owner: it must work in Codex, Antigravity, and other harnesses, not only Claude Code. One folder, `RedHome/.agents/skills/`. Claude Code reads it through the plugin, enabled by the same `.claude/settings.json` in every repository (delivered). Codex, Antigravity, and Copilot read it natively inside `RedHome`, and everywhere else through one per-machine install (CV-3-04 to CV-3-07). |
| **D3** | Sessions that see one repository | Claude Code: the plugin, read from GitHub. Other harnesses: the same one-line clone of `RedHome` beside the repository. |
| **D4** | Skill folder | `.agents/skills/` everywhere (CV-2-09). |
| **D5** | `improve` provenance | Declare the fork (CV-2-10). |
| **D7** | Home for shared tooling | The engine, `DxUi`, and `RedMonitor`, as in Phase 5. No new repository. |
| **D8** | Root entry points | The same commands and parameters everywhere (CV-6-06). |
| **D9** | `.clang-format` | The 155-line file everywhere (CV-6-05). |
| **D10** | Branch hygiene | Amended by the owner: the same settings everywhere, automatic deletion of merged head branches on, `main` as the one long-lived development branch, a protected `maintenance/<line>` branch allowed for a supported older line, as `DxUi` keeps for API 4 (CV-0-10), and experiment branches archived as bundles. Settings and merged-branch cleanup done on 2026-11-18 (CV-0-02, CV-0-03). |
| **D11** | Engine pin cadence | One commit for all, moved in one weekly wave (CV-4-04). |
| **D12** | Dependabot engine notices | Ignored at the source, identically (CV-4-01, CV-4-02). Pin lag is reported by `Get-WorkspaceStatus.ps1`. |
| **D13** | `RedHome` governance | The same rules as every other repository (CV-6-09). |
| **D14** | Where archive bundles live | `D:\Archive\RedSalamanders-20261117`, authorized by the owner on 2026-11-18 as the one archive folder. It is at a drive root, so the drive-root output policy now names it as its only exception besides `<Project>.Perf`. Copy it to a second disk. History is never pushed to GitHub as tags: `RedSalamander`'s old history was kept private on purpose. |
| **D15** | `DxUi`'s API 4 line | Rename it to `maintenance/api4` and protect it against deletion and force-push (CV-0-10). Done. |
| **D16** | `DxUi` `ej/dxui-performance-motion-impl-wip` (104 unmerged commits, no pull request) | Keep it: it is unfinished work. |
| **D17** | Refs that tools write into the clones | Bundle and delete the 2026-11-06 backups; keep the tools' own refs (CV-0-11). Done. |
| **D18** | Licence files (register B-11) | `LICENSE.txt` in every repository, `RedHome` included, is the same MIT text naming "RedSalamander" as the holder. The six product repositories already have that text byte for byte apart from the holder line, so only `RedPrism`'s holder changes. Each repository lists the third-party components it ships in its own `THIRD-PARTY-NOTICES.md`, as `DxUi` does: `RedSalamander`, `RedXe`, and `RedMonitor` move their lists out of `LICENSE.txt`, `RedMonitor`'s list, a copy of `RedSalamander`'s, is rewritten for what it ships, and `RedPrism` and `RedTilde` add one. `RedXe` removes `LICENSE`, which repeats its MIT text (CV-6-03, CV-6-09). |
| **D19** | Settings reload (register H-15), with H-10's JSON through `yyjson` | One behavior in every settings store. A worker thread waits on the directory change and a stop event, coalesces, and posts one notification; parsing and applying stay on the UI thread, as in `RedXe`. A value of the wrong type or out of range takes that field's default or is clamped, and the rest applies, as in `RedPrism` and `RedTilde`. Only a file that cannot be parsed is invalid: at start it is backed up and the template installed; on a live reload the last good settings stay. Unknown members are ignored on read and kept across a save, as in `RedPrism`. `RedPrism` changes its watcher, `RedXe` its validation and unknown-member handling, and `RedTilde` moves to JSON first (CV-2-12, CV-6-08). |

### Owner choices

These are the register rows marked *Choice*: two common end states are possible, and the default below follows the order in the governing rule. Whichever is picked, every repository moves to it. On 2026-11-18 the owner took every default, and answered B-11 and H-15, which have none, as D18 and D19.

| Register row | Default | Alternative | Decision |
| --- | --- | --- | --- |
| A-11 Codex `agents/openai.yaml` (was D6) | None: four of seven repositories have none | Add to every skill, if the Codex skill picker is used | Default, 2026-11-18 |
| A-12 Tool folders that exist in one repository | Promote to a template for all when a second repository needs it, otherwise remove | Keep, with the reason recorded as "different by design" | Default, 2026-11-18 |
| B-11 Licence file name, holder spelling, and third-party text | No default: legal text is the owner's to state | | Owner, 2026-11-18 (D18) |
| B-12 `CODEOWNERS`, `CONTRIBUTING.md`, pull request template, `.editorconfig`, `.vsconfig` | Present everywhere, from one template | Absent everywhere | Default, 2026-11-18 |
| C-09 Minimum Windows version | Windows 11 22000.2600, declared by three repositories | Windows 10 `10.0.19041.0` everywhere, as `RedXe` supports today | Default, 2026-11-18 |
| C-13 ASan strategy | Sanitized dependency trees with STL annotations left on, as `RedPrism` does: it instruments the dependencies and matches `DxUi`'s default. Confirm it first in `RedXe`, which has three dependencies | STL annotations disabled in the application and in the `DxUi` it builds, as `RedSalamander` does | Default, 2026-11-18 |
| C-14 vcpkg restore model and linkage | Scripted restore under `.build` with the standard dynamic triplets, used by four repositories | MSBuild manifest mode (`RedSalamander`) or static `*-static-md` triplets (`RedMonitor`) everywhere | Default, 2026-11-18 |
| C-16 Test-hook macro | `ENABLE_TESTS`, off in Release, as in `RedSalamander` and `RedMonitor` | A product-named macro that is on in Release, as in `RedPrism` and `RedTilde` | Default, 2026-11-18 |
| E-11 Meaning of a bare `test.ps1` | The suites affected by the current change, as `Test-Changes.ps1` and the scoped-testing policy already say; `-Full` runs everything | Everything | Default, 2026-11-18 |
| G-08 Tests layout | `<Suite>Tests/<Suite>Tests.vcxproj`, used by three repositories | Flat `Tooling.Tests.*.ps1` | Default, 2026-11-18 |
| H-05 Logging helpers | `DxUi::Debug`, because every consumer already depends on the producer | The `Debug::` family from `RedSalamander` and `RedMonitor` | Default, 2026-11-18 |
| H-07 Satellite layout and loader | `Lang\<Module>-<culture>.dll`, used by two repositories | `Languages\<tag>\<Product>.resources.dll` | Default, 2026-11-18 |
| H-10 Settings format | JSON through `yyjson`, used by four repositories | Line-based text everywhere | Default, 2026-11-18 |
| H-14 Posted-payload helper | `DxUi`'s `PostedPayload.h`, for the reason given for H-05 | The helper `RedSalamander` and `RedMonitor` share | Default, 2026-11-18 |
| H-15 Settings reload behavior | No default: the three stores disagree in different directions. Decide together with H-10 | | Owner, 2026-11-18 (D19) |

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
| 6, build | Part 1: identical compiler and linker settings before and after. Part 2: six profiles with zero warnings, x64 tests in three configurations, `ci-state` `succeeded`. Then one profile in the CV-1-09 report |
| 6, formatting | The CI format job green on each whole-tree reformat; tests and goldens unchanged; one style hash and one formatter version in the CV-1-09 report; `format.ps1 -Check` clean on every `main` |

## Risks

- **`RedHome` becomes a hidden dependency.** Invariant 2 guards against it: nothing executable is consumed from `RedHome`. The plugin carries prose only.
- **The plugin follows `RedHome` `main` without a version.** That is deliberate, so skills never lag their source, and it means a bad merge to `RedHome` reaches every repository at the next plugin refresh. The `Validate RedHome` workflow is the gate.
- **Converging by majority copies a mistake.** The default order puts producer contracts and the stricter option before the majority, and every Phase 6 step passes the receiving repository's own gates.
- **A tree-wide reformat collides with open work.** CV-6-05 runs alone, per repository, with no open feature branch.
- **A flag change exposes a latent defect.** Link-time code generation, identical-code folding, and the conforming preprocessor can each change behavior. Invariant 9 keeps the cause obvious and the revert small.
- **Folding local skills loses depth again.** That was the first gap. The fold gate of Phase 2 applies to every subject in CV-2-12, and a local skill is not shortened until the folded one has been read from that repository.
- **One wrong template reaches six repositories.** Engine tests cover each template, `RedMonitor` takes each new one first (CV-5-01), and a wave waits for `ci-state` between repositories.- **Engine-hosted tooling breaks local work when `.ci-engine` is missing or stale.** Shims fail closed with one actionable message; `Get-CiPinnedEngineInputsIdentity` already enforces this for builds.
- **Branch cleanup loses unpushed work.** The runbook archives and verifies before anything is deleted, and only the owner runs it.
- **A pin wave lands on a red `main`.** CV-0-07 records the state of `RedSalamander`; every wave step waits for `ci-state`.

## Closeout criteria

The plan closes when the register holds only rows that stay different by design; when a session started in `RedHome` or in any product repository reaches the same shared skills; when each shared script, module, and policy file has one owner and thin consumers; when every repository runs one engine commit and one `DxUi` revision; and when the lasting rules from this plan live in `AGENTS.md`, `wiki/`, the shared skills, or the owning repository's `Specs/`.
