# Shared Engineering, Build, and Validation Policies

This page summarizes shared engineering policies and current repository exceptions. Each repository's `AGENTS.md`, domain specs, and build manifests own its active requirements.

## 1. Native Compiler & Warning Policy (`2026-10-28`)
- **Compiler**: Visual Studio 2026 (`v145`, default MSVC `14.52.x`), Windows 11 SDK `10.0.26100`, `/std:c++latest`, `/permissive-`, `/sdl`, `/utf-8`, Unicode Win32 APIs.
- **Warnings**: `RedSalamander`, `RedXe`, `RedPrism`, `RedTilde`, and `DxUi` use `/Wall` with `/WX` disabled; their build acceptance gates **reject any warning or error**. `RedMonitor` currently uses `/W4 /WX`, as declared in its [Directory.Build.props](../../RedMonitor/Directory.Build.props). Preserve that exception unless a separate RedMonitor change aligns and validates its profiles. Fix actionable diagnostics rather than adding blanket suppressions.
- **Symbols & ICF (the five `/Wall` repositories)**:
  - `Debug`: `/ZI` (Edit and Continue PDB), `/OPT:NOICF`, `/MDd`.
  - `ASan Debug`: `/Zi`, real AddressSanitizer instrumentation, `/OPT:NOICF`, `/MDd`.
  - `Release`: `/Gy /GL` + `/OPT:REF /OPT:ICF /LTCG`, `/MD`.
- **Private MSVC Metadata Endpoints**: Local `build.ps1` launchers invoke `.ci-engine/Tools/Modules/Ci.Policy.psm1` (`Invoke-CiNativeCommand` / `Set-CiNativeProcessEnvironment`) so each MSBuild child tree receives a private `_MSPDBSRV_ENDPOINT_` without mutating the parent shell.

## 2. Ownership, Exceptions & Failure Policy
- **WIL RAII Mandatory**: Own all Windows handles and COM pointers via `wil::unique_*` and `wil::com_ptr_nothrow<T>` / `wil::com_ptr<T>`. Never call manual `Release()`, `DestroyWindow()`, or `AddRef() + attach()`. Reset `wil::unique_hwnd` via `.reset()`.
- **No `catch (...)` and No Cross-Boundary Exceptions**: Never let C++ exceptions escape `wWinMain`, `WndProc`, or COM/plugin callbacks. The unexpected-exception policy follows the `DxUi` API revision a repository consumes: `DxUi` API 5 and its API 5 consumers (`RedTilde` today) treat expected refusal via checked `HRESULT`/status results and route unexpected C++ exceptions (including `std::bad_alloc` outside explicitly bounded job runners) to host-owned local minidump diagnostics + termination. API 4 consumers follow their own `AGENTS.md`; `RedPrism`, for example, translates `std::bad_alloc` to `E_OUTOFMEMORY` in its `JobScheduler` worker runner. The [modern-cpp-windows](../.agents/skills/modern-cpp-windows/SKILL.md) skill lists each repository's rule and the common target.
- **Crash Dumps Stay Local**: Minidumps (`%LOCALAPPDATA%\<App>\Crashes`) are never uploaded automatically; telemetry is absent.

## 3. Localization & Chrome Strings
- User-visible chrome strings live in `.rc` `STRINGTABLE` resources using positional `{0}`, `{1}` placeholders—never `sprintf_s` or unindexed `{}`—so translators can reorder arguments safely. Document content (default layer names, sample Markdown) is not chrome.

## 4. `Changes/` Fragment Workflow
- Every feature or fix adds one dated Markdown fragment under `Changes/` (`Specs/Core/Core_Changes.md`).
- **Never** hand-edit `CHANGELOG.md` or fold fragments inside a feature PR. `Tools/Test-Changelog.ps1 -Base` fails PR/PrePush validation if `CHANGELOG.md` is touched outside an exact post-merge fold (`Tools/Submit-ChangelogFold.ps1`).

## 5. Scoped Testing & Qualification (`Test-Changes.ps1`)
- While iterating: run `.\Test-Changes.ps1 -Explain` and `.\Test-Changes.ps1` (selects affected suites from the last successful baseline).
- Before pushing: run `.\Test-Changes.ps1 -Mode PrePush` (or `-Mode Full` / `test.ps1 -Full`). Pending CI (`CI_PENDING`) is an open obligation, never a passed gate.
- Full native qualification requires x64 `Debug`, `Release`, and `ASan Debug` test passes plus all three `ARM64` builds; `ARM64` runtime claims require execution on physical/native ARM64 Windows.
- **Interactive Desktop Lease**: Focus-taking suites (`DxUi -Interactive`, `RedTilde` interactive captures, `RedSalamander` `RequiresInteractiveDesktop`) require explicit agreement from the user at the desktop, display a non-activating warning banner, and restore foreground window, focus, and cursor on exit.
- **Screenshots**: Always use each app's deterministic hidden/non-activating harness capture—never Computer Use or manual desktop screenshots.

## 6. Drive-Root Output Policy
- Never create scratch, caches, evidence, copied checkouts, or sibling output folders at a drive root.
- Only `<Project>.Perf` (such as `D:\RedSalamander.Perf`) is permitted at a drive root, and only after explicit user authorization of the exact path. Never traverse junctions during cleanup.
- One more drive-root path is authorized by the owner (2026-11-18): `D:\Archive\RedSalamanders-20261117`, which holds verified `git bundle` archives of retired branches and backups. Add bundles there; create no other folder under `D:\Archive`.

Return to [Index.md](Index.md).
