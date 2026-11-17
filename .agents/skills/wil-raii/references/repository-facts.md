# WIL RAII repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md).

| Repository | Fact | Where it is defined | Kept because |
| --- | --- | --- | --- |
| `RedXe` | Run `.\test.ps1` after ownership changes; build ARM64 too when changing declarations shared across platforms. | [RedXe test entrypoint](../../../../../RedXe/test.ps1) | The entrypoint exists in that repository; the ARM64 step is listed in Differences To Converge. |
| `RedPrism` | The build gate is zero warnings with `/WX` disabled, so scoped WIL include annotations keep external diagnostics out of that gate. | [RedPrism AGENTS.md](../../../../../RedPrism/AGENTS.md) | The `/WX` setting is that repository's build profile. |
| `DxUi` | Its WIL rules previously lived in its `modern-cpp-wil` skill, now folded into `modern-cpp-windows`. | [modern-cpp-windows repository facts](../../modern-cpp-windows/references/repository-facts.md) | Those facts are owned by another skill. |
| `RedTilde`, `RedMonitor` | No separate WIL skill existed; follow [SKILL.md](../SKILL.md) and that repository's `AGENTS.md`. | [RedTilde AGENTS.md](../../../../../RedTilde/AGENTS.md), [RedMonitor AGENTS.md](../../../../../RedMonitor/AGENTS.md) | Records where their own guidance lives. |
