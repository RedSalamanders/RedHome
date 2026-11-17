---
name: performance-resources
description: Design and validate low-overhead CPU, memory, GPU-submission, bounded-queue, and event-blocked idle behavior across RedSalamanders projects.
---

# Performance & Resource Discipline

Read the target repository's `Specs/Core/Core_PerformanceAndResources.md` (or `Specs/Testing/Testing_Performance*.md`) before material architecture, rendering, layout, or worker changes.

## Core Design Rules

- **Correctness first, lowest steady-state cost second**: Never trade safety, visual accuracy, or required behavior for an unmeasured micro-optimization; among correct designs, choose the lowest steady-state CPU, memory, allocation, copy, synchronization, wake-up, and GPU-submission cost.
- **Zero steady-state hot-path heap allocation**: Render, composition (`DxUi::EmbeddedHost::Composite`, `RedPrism::CanvasRenderer`, `RedXe` widget `Render`), and real-time logging paths use bounded reusable storage and never allocate, decode assets, or block on I/O. Settled scenes cost zero composition passes.
- **Event-blocked idle & hidden states (no busy polling)**: Idle, hidden, minimized, zero-sized, occluded (`DXGI_STATUS_OCCLUDED`), and display-off (`GUID_SESSION_DISPLAY_STATUS`) states block on OS events, message queues, or frame-latency waitable handles—never spin loops or polling timers.
- **Bounded queues & caches**: Bound histories, worker queues, staging slots, surfaces, and caches; fail locally or evict deterministically on capacity limits. Share immutable GPU/DirectWrite resources per device/DPI generation and release or quiesce expensive resources when inactive.
- **Borrowed vs retained data**: Prefer borrowed views (`std::span`, `std::wstring_view`) for synchronous calls and explicit RAII ownership for retained state.

## Measurement & Non-Regression

- Capture a paired baseline on the same machine, configuration (`Release`), and deterministic fixture **before** optimizing or accepting a hot-path change (`test.ps1` complex-UI FPS/memory in `DxUi`, `performance-paired.ps1` in `RedTilde`, archived `Specs/TestRuns/` selftests in `RedSalamander`, WARP/counter gates in `RedXe`/`RedPrism`).
- Never silently rebaseline a budget or substitute draw-call counts for end-to-end frame/memory measurements. Confirmed regressions require developer review with measured optimization, scope-reduction, or deferral options recorded in the owning spec or WIP plan.

## Repository Detail

| Working in | Read |
| --- | --- |
| `RedSalamander` | Repository-local [perf-validation](../../../../RedSalamander/.github/skills/perf-validation/SKILL.md) skill (mandatory perf-first workflow) |
| `RedPrism` | [references/redprism.md](references/redprism.md) |
| `RedXe` | [references/redxe.md](references/redxe.md) |
| `DxUi` | [references/dxui.md](references/dxui.md): dirty preparation versus composition and the hosted paired gate |
| `RedTilde`, `RedMonitor` | No separate skill existed; read the owning performance spec named above. |
