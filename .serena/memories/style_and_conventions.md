# Style And Conventions

- Keep changes focused on the indonesia_fever workspace root. Do not edit the sibling base_game root unless explicitly requested.
- Handwritten Lua in this repo typically uses function data() entrypoints, table returns, and tabs for indentation.
- Preserve existing file style and naming patterns. Avoid opportunistic refactors.
- When adding or renaming a mod parameter or UI label, update mod.lua and strings.lua together.
- Keep localization keys stable. Missing \_() entries will break the mod UI at runtime.
- In res/scripts/personnameutil.lua, preserve the fallback metatable behavior unless the task is specifically about lookup behavior.
- In res/scripts/vehicle_filter.lua, keep path and filename matches exact. The filter is expected to restrict base-game assets while allowing other mods through.
- Treat .mdl, .msh, .ani, and .mtl files as asset data. Only edit them for tasks explicitly about models or materials.
- Prefer checking stock filenames and runtime paths against the base_game reference tree before changing addFileFilter or require paths.
