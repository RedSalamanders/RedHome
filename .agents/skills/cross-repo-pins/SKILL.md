---
name: cross-repo-pins
description: Plan, audit, or execute safe dependency pin updates for DxUi, RedMonitor, and the shared .ci-engine across producer and consumer repositories.
---

# Cross-Repo Pins

Use this skill when coordinating a `DxUi` pin bump, a `RedMonitor` client header update, a `RedSalamanders/.github` shared-engine rollout, or local `.ci-engine` synchronization.

## Iron Laws

1. Producer qualification precedes consumer adoption: never bump a consumer's `DxUi.lock.json` or `.ci/project.json` to an unqualified or dirty producer commit.
2. Never mutate a developer's sibling producer checkout (`../DxUi` or `../RedSalamanders/.github`) while restoring or testing a consumer.
3. Even within the same numeric `DxUi` `apiRevision`, C++ layout changes require a full consumer rebuild (`build.ps1 -Rebuild`) across configurations. Crossing an API revision (for example API 4 to API 5) requires reading `../DxUi/CHANGELOG.md`, `../DxUi/Changes/`, and `../DxUi/docs/upgrade.md`, adapting the consumer host (such as installing the API-5 failure host), and updating `apiRevision` in `Dependencies/DxUi.lock.json`.

## Workflow

1. Read [wiki/Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md) and run `./Tools/Get-WorkspaceStatus.ps1`.
2. Identify the pin surface:
   - **DxUi (`Dependencies/DxUi.lock.json`)**: Verify `../DxUi` commit is green across required configurations. In each target consumer, read its `consumer-dxui` skill and `Specs/Core/Core_DxUiIntegration.md`, update `Dependencies/DxUi.lock.json` on a feature branch, add a `Changes/` fragment, rebuild and run x64 `Debug`, `Release`, and `ASan Debug` tests plus ARM64 builds.
   - **Shared CI Engine (`.ci/project.json` + `.github/workflows/*.yml`)**: From a clean `../RedSalamanders/.github` checkout at the reviewed commit, run `./Tools/Update-ProjectPin.ps1 -Root ../<Project> -EngineRef <40-hex-sha>` so `.ci/project.json` and workflow `@SHA` pins move together. Then sync `../<Project>/.ci-engine` (`git -C .ci-engine fetch` + `checkout --detach <sha>` after verifying `git status --porcelain` is clean) and run compiler-free static adapter checks.
   - **RedMonitor (`Dependencies/RedMonitor.lock.json`)**: Use the consumer's `Verify-RedMonitorClient.ps1` / `Update-RedMonitorClient.ps1` helper so `ThirdParty/RedMonitor/include/RedMonitor/Client.h`, `LICENSE.txt`, and SHA-256 hashes stay aligned.
3. Refresh [wiki/Dependency-And-CI-Matrix.md](../../../wiki/Dependency-And-CI-Matrix.md) once consumer branches merge.
