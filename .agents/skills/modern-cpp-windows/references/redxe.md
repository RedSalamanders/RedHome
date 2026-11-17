# RedXe detail: `modern-cpp-windows`

> **Parity reference.** Body of `RedXe/.agents/skills/modern-cpp-windows/SKILL.md` as of `87735d578659`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedXe`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

- Compile as Unicode `stdcpplatest` with `/Wall`, `/permissive-`, SDL checks, /WX disabled, and zero-warning build validation.
- Prefer value types and deterministic RAII. Use `wil::com_ptr_nothrow<T>` for COM ownership in HRESULT-based code, WIL
  unique wrappers for Windows resources, and standard smart pointers for heap ownership. Apply the `wil-raii` skill.
- Delete copying for unique resource owners. Make cleanup idempotent so partial initialization remains safe.
- Use `HRESULT` for Windows and DirectX operations. Capture `GetLastError()` immediately after a failing Win32 call.
- Do not throw through `wWinMain`, `WndProc`, or other ABI callbacks.
- Use explicit casts at signed/unsigned and pointer-sized Win32 boundaries.
- Keep headers small, include what they use, and avoid global mutable state.
- Format C++ with `.\format.ps1`; do not hand-reformat unrelated files.
- Preserve UTF-8 source files while calling wide-character Win32 APIs.

Run `.\test.ps1` after code changes. Build Release too when touching warning-sensitive or optimization-sensitive code.
