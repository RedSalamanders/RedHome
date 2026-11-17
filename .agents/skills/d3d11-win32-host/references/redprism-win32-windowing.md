# RedPrism detail: `win32-windowing`

> **Parity reference.** Body of `RedPrism/.agents/skills/win32-windowing/SKILL.md` as of `8c27267f76c5`, the commit before the 2026-11-16 consolidation, unchanged apart from Markdown links retargeted to the sibling checkout. Read it when working in `../RedPrism`. Unlinked paths are relative to that repository's root. That repository's `AGENTS.md` and `Specs/` win on any conflict, and the shared rules in [SKILL.md](../SKILL.md) apply everywhere. Folding this file into the shared skill or back into its owning repository is tracked in [Convergence_2026-11-17.md](../../../../Specs/Plans/WIP/Convergence_2026-11-17.md) (Phase 2).

Read `Specs/UI/UI_Windowing.md` before changing startup, sizing, or DPI behavior.

Work in `RedPrism/Application.*` and keep the callback boundary narrow.

- Bind `Application*` from `CREATESTRUCTW::lpCreateParams` during `WM_NCCREATE`, store it in `GWLP_USERDATA`, and
  clear it during `WM_NCDESTROY`.
- Route messages to small handlers when logic exceeds a few lines.
- No exception may cross `WindowProcedure`.
- Forward `WM_SIZE` dimensions to `Renderer::Resize`. A minimized zero-sized client is normal.
- For `WM_DPICHANGED`, use the suggested destination rectangle and recompute the titled window frame for the new DPI.
- Suppress background erase and validate `WM_PAINT`; the idle path owns presentation.
- Do not use `CS_HREDRAW` or `CS_VREDRAW`. Subscribe to `GUID_SESSION_DISPLAY_STATUS` and block rendering while the
  session display is powered off.
- Own the top-level window with `wil::unique_hwnd`. Destroy it through `.reset()`. During `WM_NCDESTROY`,
  `.release()` the wrapper when the HWND is already being destroyed.
- Create the window with `WS_EX_NOREDIRECTIONBITMAP`. Nothing paints the client with GDI.
- Keep hidden-window creation working because `--self-test` depends on it.
