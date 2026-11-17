---
name: performance-resources
description: Design and validate low-overhead CPU, memory, GPU-submission, bounded-queue, and event-blocked idle behavior across RedSalamanders projects.
---

# Performance & Resource Discipline

Read the target repository's performance contract (`Specs/Core/Core_PerformanceAndResources.md`, or `Specs/Testing/Testing_Performance*.md`) before material architecture, rendering, layout, plugin, data-acquisition, or background-worker changes. Its requirements are mandatory across the repository. This skill applies in every repository; the repository's `AGENTS.md` and `Specs/` win on any conflict.

## Core Design Rules

- **Correctness first, lowest steady-state cost second**: Never trade safety, security, visual accuracy, or required behavior for an unmeasured micro-optimization; among correct designs, choose the lowest steady-state CPU, memory, allocation, copy, synchronization, wake-up, and GPU-submission cost.
- **Zero steady-state hot-path heap allocation**: Render, composition (`DxUi::EmbeddedHost::Composite`, `RedPrism::CanvasRenderer`, `RedXe` widget `Render`), and real-time logging paths use bounded reusable storage and never allocate, decode assets, or block on I/O. Settled scenes cost zero composition passes.
- **Cache and batch**: Cache derived state until an input changes. Batch compatible copies, uploads, state changes, and draw calls.
- **Event-blocked idle & hidden states (no busy polling)**: Idle, hidden, minimized, suspended, zero-sized, occluded (`DXGI_STATUS_OCCLUDED`), and display-off (`GUID_SESSION_DISPLAY_STATUS`) states block on OS events, message queues, timers, presentation pacing, or frame-latency waitable handles, never spin loops or polling timers. Hidden, minimized, suspended, occluded, and display-off execution must not Present or keep a canvas/UI surface. Clean and hidden states add no periodic work.
- **Bounded queues & caches**: Bound histories, worker queues, staging slots, surfaces, caches, device resources, plugin output, and replacement peaks; fail locally or evict deterministically on capacity limits. Share immutable GPU/DirectWrite resources per device/DPI generation.
- **Lazy and releasable**: Create expensive resources lazily and release or quiesce them when inactive, unless a normative lifetime rule says otherwise.
- **Borrowed vs retained data**: Prefer borrowed views (`std::span`, `std::wstring_view`) for synchronous calls and explicit RAII ownership for retained state.

## Measurement & Non-Regression

- Capture a paired baseline on the same machine, configuration (`Release`), and deterministic fixture **before** optimizing or accepting a hot-path change. Record source, configuration, and fixture receipts. Unpaired results are diagnostic only and do not establish non-regression.
- Never silently rebaseline a budget or substitute draw-call counts for end-to-end frame/memory measurements.
- Measure before accepting a regression or a complexity-increasing micro-optimization. Confirmed regressions require developer review with measured optimization, scope-reduction, or deferral options; record justified regressions in the owning normative spec or active WIP plan.
- Run the affected Debug/Release and x64/ARM64 configurations named by the owning spec, plus any additional validation the contract names.

## Repository Facts

Product-specific paths, scripts, gates, and measurement rules (hosted paired gate, WARP self-test, log writer, repository-local skill) live in [references/repository-facts.md](references/repository-facts.md), including the sibling [perf-validation](../../../../RedSalamander/.github/skills/perf-validation/SKILL.md) skill that is mandatory in `RedSalamander`.

## Differences To Converge

All repositories converge on one rule set. Each difference below has one common target.

| Topic | Today (per repository) | Common target |
| --- | --- | --- |
| Performance contract | `Specs/Core/Core_PerformanceAndResources.md` in DxUi, RedXe, RedPrism. RedTilde: `Specs/Testing/Testing_Performance.md` only. RedSalamander: `Specs/Testing/Testing_PerformanceValidation.md` only. RedMonitor: no performance spec (`Specs/Testing/Testing_Validation.md`, "Native and performance evidence"). | `Specs/Core/Core_PerformanceAndResources.md` in every repository, testing procedure stays in `Specs/Testing/`. RedTilde, RedSalamander, RedMonitor add the Core file. |
| Paired-measurement entry point | DxUi and RedTilde: `performance-paired.ps1` (DxUi also `performance.ps1`, `performance-forms.ps1`, `performance-profile.ps1`; RedTilde also `performance-observed.ps1`). RedXe: `measure-runtime.ps1`, `measure-av-views.ps1`. RedPrism, RedMonitor, RedSalamander: none at the root (`test.ps1`, selftests, `Specs/TestRuns/`). | Root `performance-paired.ps1` in every repository. RedXe renames or wraps `measure-runtime.ps1`; RedPrism, RedMonitor, RedSalamander add it. |
| Hosted paired gate | DxUi only: manual `.github/workflows/benchmark.yml` (`paired-benchmark` job). No paired job in the other five `.github/workflows/` folders. | Each repository with `performance-paired.ps1` has a manual `.github/workflows/benchmark.yml` following DxUi. RedTilde, RedXe, RedPrism, RedMonitor, RedSalamander add it. |
| Per-phase measurement | DxUi: dirty preparation separate from composition. RedTilde: source transaction, preparation/submission, and GPU completion recorded separately (`Testing_Performance.md`). Others: not stated. | One rule in the contract: record each phase separately. Name the phases per repository in its contract. |
| Rendering gate name | RedPrism: WARP `--self-test`. RedXe: WARP smoke test and hidden production `--self-test`. DxUi, RedTilde, RedMonitor, RedSalamander: not stated. | `--self-test` on a hidden WARP host for every repository with a D3D11 renderer. RedXe aligns its wording. |
| Repository-local skill | RedSalamander only: `.github/skills/perf-validation/SKILL.md`. | Fold the perf-validation workflow into this skill. RedSalamander retires its local copy. |
