# Working From RedHome

How to run a session from `RedHome` so that work in any sibling repository is as well guided as a session started inside that repository. `RedHome` routes and synthesizes; each repository's `AGENTS.md`, `Specs/`, and lock files stay authoritative.

## Session Start

1. Run `pwsh -NoProfile -File ./Tools/Get-WorkspaceStatus.ps1` for the local checkout, pin and lock inventory. Add `-Hygiene` for local refs and worktrees, or `-Harness` for committed file hashes, formatter sources and root command parameters. Record each source SHA. If the checkout lags or has unpublished edits, compare the published main or PR head directly. For a pin wave check the reusable-workflow callers, manifest and clean detached engine checkout. For a behavior or discovery change, run the acceptance check in the owning plan.
2. For each repository you will change, read its `AGENTS.md` and `Specs/README.md` completely, then the owning domain spec. The dossier in [Index.md](Index.md) tells you where those are.
3. Choose skills from [Skill-Catalog.md](Skill-Catalog.md) in this order: the shared skill (its rules, its `references/` patterns, and the `repository-facts.md` rows for the target repository), then the repository-local skill. Check the skill's `Differences To Converge` table before assuming a rule already holds in that repository.
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
| `RedSalamander` | `.\Tools\Get-SpecInventory.ps1 -FailOnFindings`, `.\Tools\Get-ToolInventory.ps1 -Validate` | `.\format.ps1 -Check` | [RedSalamander.md](RedSalamander.md) |
| `RedXe` | `.\validate-skills.ps1` | `.\format.ps1 -Check` | [RedXe.md](RedXe.md) |
| `RedPrism` | `.\validate.ps1` (runs `validate-skills.ps1`, the native test-name inventory, a PowerShell syntax check, and the tooling tests) | `.\format.ps1 -Check` | [RedPrism.md](RedPrism.md) |
| `RedTilde` | `.\validate.ps1` | `.\format.ps1 -Check` | [RedTilde.md](RedTilde.md) |
| `RedMonitor` | `.\validate.ps1` | `.\format.ps1 -Check` | [RedMonitor.md](RedMonitor.md) |
| `DxUi` | `.\validate.ps1` (also `validate-skills.ps1`, `validate-specs.ps1`) | `.\format.ps1 -Check` | [DxUi.md](DxUi.md) |
| `RedSalamanders/.github` | `./Tests/Test-Engine.ps1 -TestRoot <marked root>` | n/a | [Shared-CI-Engine.md](Shared-CI-Engine.md) |
| `RedHome` | `pwsh -NoProfile -File .\validate.ps1 -CheckSiblings` | n/a | [README.md](../README.md) |

Aligning these entry points is a step of the convergence plan; until it lands, use the table rather than assuming one repository's command exists in another.

## Branches, Pull Requests, And Changelog Folds

- The default branch is `main` everywhere, and it is the only long-lived development branch. A supported older line may keep one protected `maintenance/<line>` branch, named in that repository's `AGENTS.md`; fixes land on `main` first. `DxUi` keeps its API 4 line this way as `maintenance/api4`, which a ruleset protects against deletion and force-push; `RedSalamander`'s `DxUi` lock pins a commit that only that branch holds. RedSalamander's public `main` includes the source snapshot. Its retired local `master` history is preserved privately in `D:\Archive\RedSalamanders-20261117\RedSalamander-local-branches.bundle`.
- One focused branch per change. The prevailing name is `ej/<topic>-<yyyymmdd>`; `RedMonitor` requires the `ej/` prefix.
- Each native product change adds one dated fragment under `Changes/` and never edits `CHANGELOG.md`. After the merge, `Tools/Submit-ChangelogFold.ps1` opens its own `changelog/fold-*` pull request.
- The shared product PR checks are compiler-free. Main native qualification starts after five continuous quiet minutes. Read the admitted source and result from `ci-state`. A later documentation or changelog fold can advance main without a new native run.
- GitHub retires merged PR heads automatically. Before retiring a local branch, including a changelog fold, verify its exact tip, upstream merge, owning worktree and unpublished commits or evidence. Record any private material in an approved recovery location. [Phase 0 recovery record](../Specs/Plans/WIP/Convergence_2026-11-17/CleanupRunbook.md)
- `RedHome` itself has no `Changes/` workflow; its gate is `validate.ps1` locally and the `Validate RedHome` workflow, which also checks out every sibling and runs `validate.ps1 -CheckSiblings` on pull requests, on `main`, and weekly.

## Worktrees

- Keep one clone per repository beside `RedHome`. Give each feature its own worktree inside that clone so several agents can work in one repository at once.
- Place worktrees below the owning repository's git-ignored `.build/` folder. The drive-root output policy forbids sibling or drive-root copies of a checkout.
- Retire a finished worktree from Windows after checking ownership, local changes, ignored build or recovery evidence and references from other work. A merged PR alone does not establish that a worktree is finished.
- Run `git worktree prune` and `git worktree remove` only from the Windows host. From WSL, a container, or any sandbox that mounts the repository at a different path, the `C:\` and `D:\` worktree paths are invisible and git reports every worktree as `prunable`; pruning there would unregister all of them.

## How Each Harness Finds Guidance And Skills

| Harness | Loads at session start in `RedHome` | Shared skills |
| --- | --- | --- |
| Codex | `AGENTS.md` | Discovered natively from `.agents/skills/`, which Codex reads in every folder from the working directory up to the repository root, and from `~/.agents/skills/` |
| Claude Code | `CLAUDE.md`, which points to `AGENTS.md` | Loaded natively as `redhome:<skill>` after installing the plugin enabled in `.claude/settings.json`. The `AGENTS.md` skill index remains the fallback |
| GitHub Copilot | `.github/copilot-instructions.md`, which points to `AGENTS.md` | Discovered natively from `.agents/skills/` (Copilot also reads `.github/skills/` and `.claude/skills/`) and from `~/.agents/skills/` or `~/.copilot/skills/` |
| Antigravity | `AGENTS.md` (Antigravity also reads `GEMINI.md`), from the workspace folder and each parent folder up to the repository root | Discovered natively from `.agents/skills/` at the workspace root, and from `~/.gemini/config/skills/` (the IDE also reads the legacy `~/.gemini/antigravity/skills/`) |

In a product repository, Codex, Copilot, and Antigravity find the shared skills only in their machine-wide folders, because the shared ones live in `RedHome`. Link them there once per machine with `Tools/Install-SharedSkills.ps1`, run from `RedHome`:

```powershell
pwsh -NoProfile -File .\Tools\Install-SharedSkills.ps1                 # report only: what it would link, and name collisions
pwsh -NoProfile -File .\Tools\Install-SharedSkills.ps1 -Apply          # create the links
pwsh -NoProfile -File .\Tools\Install-SharedSkills.ps1 -Remove -Apply  # take this script's links out again
```

- It links each `.agents/skills/<name>` folder of the main `RedHome` checkout into `~/.agents/skills/` (Codex and Copilot) and `~/.gemini/config/skills/` (Antigravity), for the harnesses it finds. Nothing is copied, so a pull of `RedHome` updates every harness at once. Run `-Apply` again after a skill is added or removed, and start a new session to load the new list.
- The installer creates Windows directory junctions. Codex, Copilot and the Antigravity App have opened skills through these links. `-LinkType SymbolicLink` creates symbolic links instead and needs Developer Mode or an elevated shell.
- It replaces only its own links. A real folder, a file, another link, or a machine-wide folder that is itself a link is reported and left alone.
- It reports every shared skill whose name a skill in a sibling repository or in a machine-wide folder also uses. Codex does not merge two skills with the same name, so rename one of the pair.
- Links inside a skill resolve from the linked folder, so a sibling link (`../../../../<Repo>/...`) does not reach the workspace from there. Read the same path inside the repository at hand, as with the plugin.

For a change to discovery, open fresh sessions in both RedHome and a consumer. In Claude Code, Codex, GitHub Copilot and Antigravity, list the shared skills, open the expected skill and read one of its product facts. Record the skill, source/version, product-specific answer and any discovery failure. The convergence plan gives the [full parity matrix](../Specs/Plans/WIP/Convergence_2026-11-17.md#phase-3-discovery-in-every-harness-and-outside-redhome).

Without the install, open the session in `RedHome`, or clone `RedHome` beside the repository and point the agent at `../RedHome/AGENTS.md`.

`RedHome` provides the `redsalamanders` marketplace and the `redhome` plugin. Each repository enables the plugin in `.claude/settings.json`. In a local Claude Code installation, register the marketplace with `claude plugin marketplace add RedSalamanders/RedHome` if needed. Run `claude plugin install redhome@redsalamanders --scope project` once per checkout or install it once at user scope with `--scope user`. Open a fresh session after setup. To test an edit to the plugin itself, start Claude Code from RedHome with `--plugin-dir .`. [Claude Code install scopes](https://code.claude.com/docs/en/discover-plugins#choose-an-install-scope)

## When RedHome Is Not Beside The Repository

A hosted coding agent, a fresh checkout or a CI job can start with only the product repository.

- Each repository's `AGENTS.md` names `../RedHome/AGENTS.md`, the skill package directory, and the clone URL. Clone `RedHome` beside the repository when the environment allows it.
- An installed Claude Code plugin supplies shared skills in a local single-repository session. Claude Code cloud sessions use plugins provisioned through managed settings. Use the repository's RedHome pointer when the plugin is unavailable and the host supports a sibling checkout. In a product checkout, resolve skill links to that product's files from its own repository root. [Claude Code plugin availability](https://code.claude.com/docs/en/discover-plugins)
- In any other harness, the shared skills are there only on a machine where `Install-SharedSkills.ps1` linked them. Without them, the repository's own `AGENTS.md`, `Specs/`, and local skills still fully define product behavior and validation. Only the shared how-to detail is missing; do not guess it, and say so in the handoff.
- Nothing in any build, test, or CI path may depend on `RedHome`. It is unpinned and absent from CI by design.

## Keeping RedHome Current

- After sibling architecture, skills, commands, or policies change, run the `wiki-sync` skill and `validate.ps1 -CheckSiblings`.
- Record cross-repository initiatives as one indexed plan under [Specs/Plans/WIP/](../Specs/Plans/WIP/README.md). Work items that belong to one repository stay in that repository's plans.
- Keep commit SHAs, branch inventories, and other dated facts out of `wiki/`; they belong in a dated plan or come live from `Get-WorkspaceStatus.ps1`.

Return to [Index.md](Index.md).
