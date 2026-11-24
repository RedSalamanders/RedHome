# Shared Engineering, Build, and Validation Policies

This page summarizes shared engineering policies and current repository exceptions. Each repository's `AGENTS.md`, domain specs, and build manifests own its active requirements.

## 1. Native Compiler & Warning Policy (`2026-10-28`)
The shared compiler, linker, CRT and PDB settings apply across all six native repositories. The profile records the reviewed toolchain and product exceptions. [Native build profiles](https://github.com/RedSalamanders/.github/blob/e513a50b3aea60d86f41054188537fb7b418bac6/Specs/NativeBuildProfiles.md)
- RedSalamander's `RedLauncher.exe` uses the static CRT for its portable WinGet bootstrap. Verify a clean extraction and alias startup on x64 and native ARM64. [WinGet integration](../../RedSalamander/Specs/Installer/WingetIntegration.md)
- **Private MSVC Metadata Endpoints**: Local `build.ps1` launchers invoke `.ci-engine/Tools/Modules/Ci.Policy.psm1` (`Invoke-CiNativeCommand` / `Set-CiNativeProcessEnvironment`) so each MSBuild child tree receives a private `_MSPDBSRV_ENDPOINT_` without mutating the parent shell.

## 2. Ownership, Exceptions & Failure Policy
- **WIL RAII Mandatory**: Own all Windows handles and COM pointers via `wil::unique_*` and `wil::com_ptr_nothrow<T>` / `wil::com_ptr<T>`. Never call manual `Release()`, `DestroyWindow()`, or `AddRef() + attach()`. Reset `wil::unique_hwnd` via `.reset()`.
- **No `catch (...)` and No Cross-Boundary Exceptions**: Never let C++ exceptions escape `wWinMain`, `WndProc`, or COM/plugin callbacks. The unexpected-exception policy follows the `DxUi` API revision a repository consumes: `DxUi` API 5 and its API 5 consumers (`RedTilde` today) treat expected refusal via checked `HRESULT`/status results and route unexpected C++ exceptions (including `std::bad_alloc` outside explicitly bounded job runners) to host-owned local minidump diagnostics + termination. API 4 consumers follow their own `AGENTS.md`; `RedPrism`, for example, translates `std::bad_alloc` to `E_OUTOFMEMORY` in its `JobScheduler` worker runner. The [modern-cpp-windows](../.agents/skills/modern-cpp-windows/SKILL.md) skill lists each repository's rule and the common target.
- Crash reports stay local. The convergence target is a dump and pending marker, a single prompt at the next interactive start, and the newest ten post-adoption dumps with their sidecars. Preserve legacy reports and product recovery actions. [Crash handling](../.agents/skills/crash-dumps/SKILL.md)

## 3. Localization & Chrome Strings
- User-visible chrome strings live in `.rc` `STRINGTABLE` resources using positional `{0}`, `{1}` placeholders—never `sprintf_s` or unindexed `{}`—so translators can reorder arguments safely. Document content (default layer names, sample Markdown) is not chrome.

## 4. `Changes/` Fragment Workflow
- Each native product feature or fix adds one dated Markdown fragment under `Changes/` (`Specs/Core/Core_Changes.md`).
- **Never** hand-edit `CHANGELOG.md` or fold fragments inside a feature PR. `Tools/Test-Changelog.ps1 -Base` fails PR/PrePush validation if `CHANGELOG.md` is touched outside an exact post-merge fold (`Tools/Submit-ChangelogFold.ps1`).

## 5. Scoped Testing & Qualification (`Test-Changes.ps1`)
- While iterating: run `.\Test-Changes.ps1 -Explain` and `.\Test-Changes.ps1` (selects affected suites from the last successful baseline).
- Before pushing: run `.\Test-Changes.ps1 -Mode PrePush` (or `-Mode Full` / `test.ps1 -Full`). Pending CI (`CI_PENDING`) is an open obligation, never a passed gate.
- Full native qualification requires x64 `Debug`, `Release`, and `ASan Debug` test passes plus all three `ARM64` builds; `ARM64` runtime claims require execution on physical/native ARM64 Windows.
- **Interactive Desktop Lease**: Focus-taking suites (`DxUi -Interactive`, `RedTilde` interactive captures, `RedSalamander` `RequiresInteractiveDesktop`) require explicit agreement from the user at the desktop, display a non-activating warning banner, and restore foreground window, focus, and cursor on exit.
- **Screenshots**: Always use each app's deterministic hidden/non-activating harness capture—never Computer Use or manual desktop screenshots.

For the convergence initiative, D21 permits recording deferred tests after the applicable warning-free compilation and PR checks. Bind every deferral to source, scope, owner and replay. [Convergence test ledger](../Specs/Plans/WIP/Convergence_2026-11-17/DeferredTests.md)

## 6. Critical Normative Rule: Allowed Write Locations Only (Fail Closed)
- **Critical Normative Rule**: Code, tools, tests, scripts, and AI agents **DO NOT HAVE THE RIGHT** to create, modify, or delete files outside explicitly authorized locations:
  1. The owning repository working tree and repository-local `.build/` (never committed);
  2. An explicitly owner-authorized `<Project>.Perf` drive-root workspace (such as `D:\RedSalamander.Perf`) carrying its verified runner ownership marker, or the explicitly authorized recovery folder `D:\Archive\RedSalamanders-20261117`;
  3. An explicitly declared dedicated `selftest` root in an authorized machine manifest (e.g., `X:\<Project>.Perf\config\machine-resources.json`), strictly inside a unique per-run subfolder (`...-run-<guid>`) with cleanup on exit and never traversing junctions or reparse points.
- **Explicitly prohibited destinations**: arbitrary drive roots, `%USERPROFILE%`, Desktop, Documents, undeclared personal/work OneDrive folders, media/user network shares (such as `\\rubygloom\Multimedia`), or sibling repositories outside task scope.
- **Fail closed**: Matching directory names, bare environment variables (`*TEST_ROOT`), or low disk space never grant authorization; every test runner, capture harness, and script MUST fail closed before creating or writing any file.
- Never create scratch, caches, evidence, copied checkouts, or sibling output folders at a drive root.
- Only `<Project>.Perf` (such as `D:\RedSalamander.Perf`) is permitted at a drive root, and only after explicit user authorization of the exact path. Never traverse junctions during cleanup or leave compatibility junctions at forbidden old drive-root paths.
- D14 authorizes the specific private recovery folder `D:\Archive\RedSalamanders-20261117`. Preserve its historical bundles under their original names. Any newly authorized archive uses a fresh name and verified exact refs. [Phase 0 recovery record](../Specs/Plans/WIP/Convergence_2026-11-17/CleanupRunbook.md)

## 7. `_camelCase` Private & Protected Member Naming + `.clang-tidy` Enforcement (`H-27`)
- **Mandatory member naming**: Private and protected non-static class/struct data members MUST use `_camelCase` (a leading `_` followed strictly by a lowercase ASCII letter `[a-z]`, pattern `_[a-z][A-Za-z0-9]*`). Trailing `name_` and unprefixed bare member names are forbidden for private/protected members.
- **Member-scope ONLY**: Strictly ban `_Uppercase`, `__double`, and leading `_` at file, namespace, or global scope (`bugprone-reserved-identifier` / ISO C++ `[lex.name]`). Public `struct`/DTO data members remain `camelCase`.
- **Mandatory enforcement**: Enforce via a repository-root `.clang-tidy` enabling `readability-identifier-naming` and `bugprone-reserved-identifier` (see [modern-cpp-windows](../.agents/skills/modern-cpp-windows/SKILL.md) and [cpp-style.md](../.agents/skills/modern-cpp-windows/references/cpp-style.md)). `RedTilde` adopts first (`H-27`); sibling repositories migrate in focused per-repo PRs. [Divergence register H-27](../Specs/Plans/WIP/Convergence_2026-11-17/DivergenceRegister.md#h-code-conventions)

Return to [Index.md](Index.md).
