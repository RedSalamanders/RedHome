# RedSalamanders Glossary

| Term | Meaning across RedSalamanders |
| --- | --- |
| **ACP (`TextStoreACP`)** | Application Character Position model used by Windows Text Services Framework (TSF/IME) in `DxUi` and `RedTilde` to keep source selection and composition exact. |
| **`Changes/` Fragment** | Per-PR Markdown release note under `Changes/`; folded into `CHANGELOG.md` only on `main` by `Tools/Submit-ChangelogFold.ps1`. |
| **`.ci-engine`** | Git-ignored independent checkout of `RedSalamanders/.github` inside each repo root (`<repo>/.ci-engine`), required locally at the exact `.ci/project.json` `engine.ref` commit. |
| **`ci-state` Branch** | Orphan metadata branch on each GitHub repo recording admitted cumulative input digests, engine pins, and native run verdicts outside product source. |
| **Desktop Lease** | Coordinated session-wide lock + non-activating warning overlay used by focus-taking interactive tests (`Ci.DesktopLease.psm1`), guaranteeing focus/cursor restoration. |
| **`EmbeddedHost`** | `DxUi` supplied-device UI host (`RedPrism`, `RedXe` `AVControl`) that borrows the app's `ID3D11Device` and composites into the app's render target without owning an HWND or swap chain. |
| **Engine Notice** | Dependabot pull request that bumps one `RedSalamanders/.github` workflow caller; a signal that the engine moved, adopted only through a pin wave. |
| **Failure Host (API 5)** | Application-owned fatal reporter registered with `DxUi` before control creation; writes local diagnostics/minidump and terminates on unexpected C++ exceptions. |
| **16-Hex Fingerprint** | Short folder name (`.build/dependencies/DxUi/<sha256-prefix16>`) paired with a full JSON identity marker to keep Windows/vcpkg paths below 260-char limits without hash-prefix ambiguity. |
| **Numeric Golden** | Independent mathematical or state-machine expectation + documented tolerance in `RedPrism` tests; never derived from or rebaselined to buggy output. |
| **Parity Reference** | `references/<repository>.md` file under a shared `RedHome` skill holding that repository's pre-consolidation skill body until its rules are folded into the shared skill or returned to the owning repository. |
| **Pin Wave** | Producer-first sequence that moves every repository to one engine, `DxUi`, or `RedMonitor` pin through `Update-ProjectPin.ps1` or the consumer update helpers, one qualified repository at a time. |
| **`QualifiedAbiV2`** | Portable `DxUi` Release SDK input contract binding exact MSVC toolset, headers, `/MD` LTCG archive/PDB bytes, and native SDK smoke receipt for optional cross-job/local consumer reuse. |
| **`RedMonitor` Client** | Single-header diagnostics adapter (`ThirdParty/RedMonitor/include/RedMonitor/Client.h`) hash-pinned via `Dependencies/RedMonitor.lock.json`. |
| **Scoped Testing** | `Test-Changes.ps1` planner mapping Git diffs to affected test suites (`Affected`, `PrePush`, `Full`), binding `.ci-engine` raw bytes into local evidence receipts. |

Return to [Index.md](Index.md).
