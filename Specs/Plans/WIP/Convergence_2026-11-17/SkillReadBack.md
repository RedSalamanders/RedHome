# Shared skill read-back and root guidance

20 November 2026. The shared source was RedHome `2de4bc922ea5183c40b5528637e5114776bcd241`, which includes the RedSalamander fold from [RedHome #37](https://github.com/RedSalamanders/RedHome/pull/37).

| Starting repository | Starting commit | Shared packages requested | Committed `AGENTS.md` bytes |
| --- | --- | --- | ---: |
| RedHome | `2de4bc922ea5183c40b5528637e5114776bcd241` | `wil-raii` | 7,072 |
| RedPrism | `55f1064feb2428e609e90545c160aacc02328eaf` | `wil-raii`, `app-settings`, `crash-dumps`, `native-build`, `test-evidence` | 16,144 |
| RedSalamander | `7ff4e90d95e71fb09c41fca5095ea0e867c57828` | `native-build`, `test-evidence` | 22,276 |
| RedXe | `550cc8ed25fd7d5ccd9f20d770231f72b98517b5` | `app-settings`, `native-build` | 21,613 |
| RedTilde | `7524a6ee8d413d7f25126ebe5cb5e4165e5961d0` | `app-settings`, `crash-dumps`, `file-io-safety`, `native-build`, `test-evidence` | 13,046 |
| RedMonitor | `22fbd476c0d5f72ae7cc7bafb0ae14b0102a1210` | `file-io-safety`, `native-build`, `test-evidence` | 8,008 |
| DxUi | `61f0bc1ed442514e2503d0c69f60cc1f57e71d7c` | `native-build` | 13,606 |

## Harness results

| Harness | Native inventory | Content read-back | Remaining acceptance |
| --- | --- | --- | --- |
| Copilot CLI 1.0.108 | All 16 shared skills in all seven starting repositories. | Activated and opened all 19 requested packages and their repository references, with read access limited to the requested package directories. | Complete for these probes. |
| Claude Code 2.1.221 | All 16 appeared through the project plugin in RedPrism. In the other six fresh sessions the existing project-scope installation exposed zero shared skills until the verified plugin cache at `2de4bc922ea5` was loaded through `--plugin-dir`. | The native `Skill` and `Read` tools opened all 19 requested packages and references with the plugin loaded. | Recheck automatic plugin activation in the other six starting repositories. |
| Codex CLI 0.169.1 | The inventories in RedHome and RedPrism included the profile skill `redhome:wil-raii`. The official standalone distribution with the matching code-mode host reproduced discovery. | Both standalone read-only sessions failed on the first file open with `registered Core launch requires an installed app`. The packaged CLI also failed to start the read-only file access. | Open `wil-raii` from both starting repositories and open the five replacement families from their products using a working registered runtime. |
| Antigravity App 2.32.1.0 | Both fresh local projects displayed the 16 shared names. The RedSalamander workspace resolved them to RedHome through the machine-wide junctions. | RedHome opened `wil-raii` and its repository reference. RedSalamander opened `native-build` and `test-evidence` and their repository references. | The desktop became unavailable during RedPrism setup. Complete RedPrism and the other four products when the local app session is available. |

The successful `wil-raii` probes from RedHome and RedPrism opened `SKILL.md` and `references/repository-facts.md` in the canonical RedHome package, through either the installed profile junction or the commit-specific Claude plugin cache. The [RedPrism entry](../../../../.agents/skills/wil-raii/references/repository-facts.md) says, “The build gate is zero warnings with `/WX` disabled, so scoped WIL include annotations keep external diagnostics out of that gate.” Antigravity returned the same fact from RedHome. Its RedSalamander probe read, “`Run-AllTests.ps1 -SkipBuild` is receipt-gated,” in [native-build](../../../../.agents/skills/native-build/references/repository-facts.md) and identified `--commands-selftest` as the deterministic command probe in [test-evidence](../../../../.agents/skills/test-evidence/references/repository-facts.md).

The read-back is open under [CV-3-05](../Convergence_2026-11-17.md#phase-3-discovery-in-every-harness-and-outside-redhome). Retiring RedSalamander's two local packages still requires the missing results.

## Guidance validation

All six published product root guidance files fit the 24,000-byte limit. These sizes are Git blob sizes. Exercise the common product guidance validator after adoption in CV-5-05 to finish CV-3-08. The pinned engine's G4 rule was exercised directly on all 16 shared skills and all 28 product skills in the table. The only baseline failures were RedPrism's `consumer-dxui` and `hlsl-composition` descriptions. [Pinned engine](https://github.com/RedSalamanders/.github/blob/3b19eade3b1228d0d5f05bcfce89f4b7c66ef1da/Tools/Modules/Ci.AgentGuidance.psm1)
