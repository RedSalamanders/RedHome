# Working From RedHome

How to run a session from `RedHome` so that work in any sibling repository is as well guided as a session started inside that repository. `RedHome` routes and synthesizes; each repository's `AGENTS.md`, `Specs/`, and lock files stay authoritative.

## Session Start

1. Run `pwsh -NoProfile -File ./Tools/Get-WorkspaceStatus.ps1` (read-only). It reports branch, dirty state, `.ci-engine` against its pin, and the `DxUi` and `RedMonitor` locks for every sibling.
2. For each repository you will change, read its `AGENTS.md` and `Specs/README.md` completely, then the owning domain spec. The dossier in [Index.md](Index.md) tells you where those are.
3. Choose skills from [Skill-Catalog.md](Skill-Catalog.md) in this order: the shared skill, its `references/` file for the target repository, then the repository-local skill.
4. For work that spans repositories, use `grill-cross-repo` before writing specs, `spec-workflow` to record the agreed work, and sequence producers (`DxUi`, `RedMonitor`, `RedSalamanders/.github`) before consumers.
5. Check [the active plans](../Specs/Plans/WIP/README.md) so the change does not collide with a convergence step in progress.

## Command Map

Run every command from the target repository's root, not from `RedHome`. All six code repositories share the scoped-testing entry point:

```powershell
.\Test-Changes.ps1 -Explain        # which suites the current diff selects, and why
.\Test-Changes.ps1                 # run the affected suites while iterating
.\Test-Changes.ps1 -Mode PrePush   # before pushing; -Mode Full for complete local qualification
```

The entry points that still differ between repositories:

| Repository | Guidance and spec validation | Formatting | Full commands |
| --- | --- | --- | --- |
| `RedSalamander` | `.\Tools\Get-SpecInventory.ps1 -FailOnFindings`, `.\Tools\Get-ToolInventory.ps1 -Validate` | `.\format-all.ps1` (formats in place; `-WhatIf` previews) | [RedSalamander.md](RedSalamander.md) |
| `RedXe` | `.\validate-skills.ps1` | `.\format.ps1` (formats in place) | [RedXe.md](RedXe.md) |
| `RedPrism` | `.\validate-skills.ps1` | `.\format.ps1 -Check` | [RedPrism.md](RedPrism.md) |
| `RedTilde` | `.\validate.ps1` | `.\format.ps1 -Check` | [RedTilde.md](RedTilde.md) |
| `RedMonitor` | `.\validate.ps1` | `.\format.ps1 -Check` | [RedMonitor.md](RedMonitor.md) |
| `DxUi` | `.\validate.ps1` (also `validate-skills.ps1`, `validate-specs.ps1`) | `.\format.ps1 -Check` | [DxUi.md](DxUi.md) |
| `RedSalamanders/.github` | `./Tests/Test-Engine.ps1 -TestRoot <marked root>` | n/a | [Shared-CI-Engine.md](Shared-CI-Engine.md) |
| `RedHome` | `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings` | n/a | [README.md](../README.md) |

Aligning these entry points is a step of the convergence plan; until it lands, use the table rather than assuming one repository's command exists in another.

## Branches, Pull Requests, And Changelog Folds

- The default branch is `main` everywhere. `RedSalamander` also has a `master` branch that is not an ancestor of `main`; do not base or target work on it unless the owner asks.
- One focused branch per change. The prevailing name is `ej/<topic>-<yyyymmdd>`; `RedMonitor` requires the `ej/` prefix.
- Every change adds one dated fragment under `Changes/` and never edits `CHANGELOG.md`. After the merge, `Tools/Submit-ChangelogFold.ps1` opens its own `changelog/fold-*` pull request.
- Pull requests run compiler-free checks only. Native qualification starts on `main` after five continuous quiet minutes, so a merged change is `CI_PENDING` until the repository's `ci-state` branch records `succeeded`.
- When a pull request merges, delete its head branch locally and on the remote, including `changelog/fold-*` branches.
- `RedHome` itself has no `Changes/` workflow; its gate is `validate.ps1` locally and the `Validate RedHome` workflow on pull requests.

## Worktrees

- Keep one clone per repository beside `RedHome`. Give each feature its own worktree inside that clone so several agents can work in one repository at once.
- Place worktrees below the owning repository's git-ignored `.build/` folder. The drive-root output policy forbids sibling or drive-root copies of a checkout.
- Remove the worktree and delete its branch when the pull request merges.
- Run `git worktree prune` and `git worktree remove` only from the Windows host. From WSL, a container, or any sandbox that mounts the repository at a different path, the `C:\` and `D:\` worktree paths are invisible and git reports every worktree as `prunable`; pruning there would unregister all of them.

## How Each Harness Finds Guidance And Skills

| Harness | Loads at session start in `RedHome` | Shared skills |
| --- | --- | --- |
| Codex | `AGENTS.md` | Discovered natively from `.agents/skills/` |
| Claude Code | `CLAUDE.md`, which points to `AGENTS.md` | Reached through the `AGENTS.md` skill index. Claude Code auto-discovers skills only under `.claude/skills/` or from plugins, which no RedSalamanders repository has used so far |
| GitHub Copilot | `.github/copilot-instructions.md`, which points to `AGENTS.md` | Reached through the `AGENTS.md` skill index |

Native Claude Code discovery and discovery outside `RedHome` are decisions in the convergence plan, not gaps to patch ad hoc.

## When RedHome Is Not Beside The Repository

A session started inside one repository (a hosted coding agent, a fresh machine, CI) sees only that repository.

- Each repository's `AGENTS.md` names `../RedHome/AGENTS.md`, the skill package directory, and the clone URL. Clone `RedHome` beside the repository when the environment allows it.
- When it does not, the repository's own `AGENTS.md`, `Specs/`, and local skills still fully define product behavior and validation. Only the shared how-to detail is missing; do not guess it, and say so in the handoff.
- Nothing in any build, test, or CI path may depend on `RedHome`. It is unpinned and absent from CI by design.

## Keeping RedHome Current

- After sibling architecture, skills, commands, or policies change, run the `wiki-sync` skill and `validate.ps1 -CheckSiblings`.
- Record cross-repository initiatives as one indexed plan under [Specs/Plans/WIP/](../Specs/Plans/WIP/README.md). Work items that belong to one repository stay in that repository's plans.
- Keep commit SHAs, branch inventories, and other dated facts out of `wiki/`; they belong in a dated plan or come live from `Get-WorkspaceStatus.ps1`.

Return to [Index.md](Index.md).
