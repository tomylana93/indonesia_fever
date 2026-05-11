# AGENTS

## Scope

- This root contains the editable Transport Fever 2 mod.
- The sibling workspace folder [base_game](../base_game/AGENTS.md) is reference-only unless the user explicitly asks to modify it.

## Project Map

- [mod.lua](mod.lua) defines mod metadata, settings UI, and runtime hooks.
- [strings.lua](strings.lua) stores the localization keys referenced through `_()`.
- [res/config/name2/indonesia/en](res/config/name2/indonesia/en/towns.lua) contains Indonesian town, street, and person name data.
- [res/config/terrain_generators](res/config/terrain_generators/tropical.gen.lua) contains custom map generator definitions.
- [res/scripts](res/scripts/vehicle_filter.lua) contains handwritten Lua helpers such as vehicle filtering and person-name utilities.
- [res/models](res/models/model/railroad/signal_path_c.mdl) contains signal assets and generated-looking model data.

## Working Rules

- Keep changes focused on this root. Do not edit `base_game` to implement mod features.
- Preserve the existing style in each Lua file. Handwritten files here typically use `function data()` entrypoints, table returns, and tabs for indentation.
- When adding or renaming a mod parameter or UI label, update [mod.lua](mod.lua) and [strings.lua](strings.lua) together.
- Keep localization keys stable. Missing `_()` entries will break the mod UI at runtime.
- In [res/scripts/personnameutil.lua](res/scripts/personnameutil.lua), keep the fallback metatable behavior unless the task is explicitly about changing lookup behavior.
- In [res/scripts/vehicle_filter.lua](res/scripts/vehicle_filter.lua), keep path and filename matches exact. The filter should restrict base-game assets while allowing other mods through.
- Treat `.mdl`, `.msh`, `.ani`, and `.mtl` files as asset data. Only edit them for tasks that are explicitly about models or materials.

## Validation

- There is no local build, test, lint, or formatter configuration in this repo.
- Validate changes by loading the mod in Transport Fever 2 and smoke-testing the affected feature.
- For settings and localization work, verify that labels and tooltips load in the mod options UI.
- For name data, verify the Indonesian name set appears in map setup and person generation.
- For vehicle filters or terrain generators, verify behavior in-game after a reload.
- Use `rg` to search both workspace roots when checking base-game paths or stock asset names.
