# RedXe detail: `win32-windowing`

> **Parity reference.** Body of `RedXe/.agents/skills/win32-windowing/SKILL.md` as of `87735d578659`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedXe`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Before changing startup window mode, display selection, sizing, or DPI behavior, read
`Specs/UI/UI_XeneonDisplayWindowing.md`. It is the normative contract; update it in the same change when intended
behavior changes. UI-thread `OleInitialize`, top-level `IDropTarget`, and forwarding pointer/drop to GPU widgets
are owned by `Specs/UI/UI_Dashboard.md`.

Work in `RedXe/Application.*` and keep the callback boundary narrow.

- Bind `Application*` from `CREATESTRUCTW::lpCreateParams` during `WM_NCCREATE`, store it in `GWLP_USERDATA`, and
  clear it during `WM_NCDESTROY`.
- Route messages to small handlers when logic exceeds a few lines.
- A child created under the cursor may not receive `WM_SETCURSOR` until the mouse moves. When the parent owns a
  hover-created chrome HWND, apply the intended cursor from the parent's `WM_SETCURSOR` as well.
- No exception may cross `WindowProcedure`; use `HRESULT` or explicit state for fallible work.
- Forward `WM_SIZE` dimensions to `Renderer::Resize`. A minimized zero-sized client area is normal.
- For `WM_DPICHANGED`, follow the domain spec: use the suggested destination, recompute a titled window's outer frame
  for the target DPI and logical client canvas, and leave fullscreen popup bounds monitor-controlled.
- Suppress background erase and validate `WM_PAINT`; the message-loop idle path owns continuous rendering.
- Do not use `CS_HREDRAW` or `CS_VREDRAW` for the real-time render window. Subscribe to
  `GUID_SESSION_DISPLAY_STATUS` and block rendering while the session display is powered off.
- Own the top-level window with `wil::unique_hwnd`. Destroy it through `.reset()`, release stale ownership during
  `WM_NCDESTROY` when needed, and unregister the class after the window is gone. Apply the `wil-raii` skill for other
  handles.
- Keep hidden-window creation working because `.\test.ps1` depends on it. Message dispatch must never make a hidden,
  minimized, suspended, or display-off window render one extra frame.

After lifetime, DPI, or message-loop changes, use affected coverage for iteration and the domain's required profiles
for qualification. With the person's agreement to the time, manually launch `.\build.ps1 -Run` when interactive
behavior changed. DPI changes also require an agreed live cross-monitor move test
with a Per-Monitor-V2 probe so diagnostic virtualization cannot hide a sizing defect.

If the work closes a WIP plan, merge lasting requirements into the domain spec before moving the plan to
`Specs/Plans/Done/`. Apply the `spec-workflow` skill for that closeout.
