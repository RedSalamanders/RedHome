# `yyjson` repository facts

Product-specific facts only. Common rules are in [SKILL.md](../SKILL.md) and [patterns.md](patterns.md).

| Repository | Fact | Where it is defined | Kept because |
| --- | --- | --- | --- |
| RedPrism | Swift `Codable` shapes in `.prism` files: non-optional properties are always present, optional ones are omitted when nil, and a dictionary keyed by an enum that is not `CodingKeyRepresentable` is an alternating key/value array (`["Reds", {…}, "Master", {…}]`) in unspecified order. Read both array and object forms; write the array form in a fixed order. | [Specs/IO/IO_ProjectFormat.md](../../../../../RedPrism/Specs/IO/IO_ProjectFormat.md) | The `.prism` format exists only in RedPrism. |
| RedPrism | Project manifests (C5) and settings (C14) must follow the yyjson ownership rules. | [Specs/Testing/Testing_Validation.md](../../../../../RedPrism/Specs/Testing/Testing_Validation.md) (C14 is "Settings, crash, localization, UIA") | The C5/C14 identifiers exist only in RedPrism. |
| RedXe | For settings documents, also read and apply `Specs/Core/Core_Settings.md` and the `settings-store` skill. | [Specs/Core/Core_Settings.md](../../../../../RedXe/Specs/Core/Core_Settings.md), [settings-store skill](../../../../../RedXe/.agents/skills/settings-store/SKILL.md) | The settings documents exist only in RedXe. |
| RedXe | Run `.\test.ps1` after JSON changes. `SettingsTests` must cover templates, strict rejection, and schema alignment; the hidden smoke path must parse its deployed build-specific template before initializing Direct3D without touching user settings. | RedXe `test.ps1`, `Tests/SettingsTests` | The test gate and hidden smoke path exist only in RedXe. |
