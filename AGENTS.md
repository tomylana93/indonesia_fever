# AGENTS

## Scope

- This root contains the editable Transport Fever 2 mod.
- The former `indonesia_fever_1.code-workspace` has been removed. Do not assume a sibling `base_game` checkout exists.
- Use the installed game and Workshop reference paths below as read-only sources unless the user explicitly asks to modify them.

## Paths on This Host

Verified on 31 October 2026. This host uses the Steam snap installation, not `~/.local/share/Steam`.

- Editable mod / Git root: `/home/tomylana93/snap/steam/common/.local/share/Steam/userdata/107500610/1066780/local/staging_area/indonesia_fever`
- Game installation: `/home/tomylana93/snap/steam/common/.local/share/Steam/steamapps/common/Transport Fever 2`
- Base-game resources: `/home/tomylana93/snap/steam/common/.local/share/Steam/steamapps/common/Transport Fever 2/res`
- Installed Yeol 2.21a reference: `/home/tomylana93/snap/steam/common/.local/share/Steam/steamapps/workshop/content/1066780/2799634962`
- Game log: `/home/tomylana93/snap/steam/common/.local/share/Steam/userdata/107500610/1066780/local/crash_dump/stdout.txt`

Verify paths before using them after a Steam move or reinstall. The similarly named sibling `indonesia_industries_fever_1` and `/home/tomylana93/projects/staging/indonesia-industries-fever` are separate directories, not this Git root. Confirm the working directory and origin `https://github.com/tomylana93/indonesia_fever.git` before edits.

Stock models, meshes, materials, and some construction/texture resources are packaged in ZIP archives under the game's `res` directory, including `models/model.zip`, `models/mesh.zip`, `models/material.zip`, and `construction/construction.zip`. A missing loose file does not mean an asset is missing. Inspect archives read-only with Python `zipfile` or `unzip -l`; do not extract over the installation.

## Project Map

- [mod.lua](mod.lua) defines mod metadata, settings UI, and runtime hooks.
- [strings.lua](strings.lua) stores the localization keys referenced through `_()`.
- [res/config/name2/indonesia/en](res/config/name2/indonesia/en/towns.lua) contains Indonesian town, street, and person name data.
- [res/config/terrain_generators](res/config/terrain_generators/tropical.gen.lua) contains custom map generator definitions.
- [res/scripts](res/scripts/vehicle_filter.lua) contains handwritten Lua helpers such as vehicle filtering and person-name utilities.
- [res/models](res/models/model/railroad/signal_path_c.mdl) contains signal assets and generated-looking model data.
- [res/construction/industry](res/construction/industry/palm_plantation.con) and [res/config/cargo_types](res/config/cargo_types/cpo.cargo.lua) define industry layouts, recipes, availability, and cargo.
- [res/scripts/iif_callbacks.lua](res/scripts/iif_callbacks.lua), [res/scripts/iif_industries.lua](res/scripts/iif_industries.lua), and [res/scripts/iif_towns.lua](res/scripts/iif_towns.lua) handle cargo compatibility, industry ownership, and town demand.
- [res/config/game_script/iif_industry.lua](res/config/game_script/iif_industry.lua) handles persistent runtime state.
- [INDUSTRIES.md](INDUSTRIES.md) records historical approximations, balance choices, compatibility limits, and open playtest gates.

## Working Rules

- Keep changes focused on this Git root. Do not edit the installed game, official mods, or Workshop reference to implement mod features.
- Preserve the existing style in each Lua file. Handwritten files here typically use `function data()` entrypoints, table returns, and tabs for indentation.
- When adding or renaming a mod parameter or UI label, update [mod.lua](mod.lua) and [strings.lua](strings.lua) together.
- Keep localization keys stable. Missing `_()` entries will break the mod UI at runtime.
- In [res/scripts/personnameutil.lua](res/scripts/personnameutil.lua), keep the fallback metatable behavior unless the task is explicitly about changing lookup behavior.
- In [res/scripts/vehicle_filter.lua](res/scripts/vehicle_filter.lua), keep path and filename matches exact. The filter should restrict base-game assets while allowing other mods through.
- Treat `.mdl`, `.msh`, `.ani`, and `.mtl` files as asset data. Only edit them for tasks that are explicitly about models or materials.

## Validation

- Run `python3 tools/check_industries.py` for industry, cargo, asset, recipe, localization, vehicle, and script-state checks. It uses the verified Steam snap game-resource path by default.
- For another installation, pass `--game-res '/absolute/path/Transport Fever 2/res'`. The runner needs Python 3 and a Lua 5.3/5.4 shared library.
- These are offline checks against installed game resources, not native-engine acceptance. No separate build, lint, or formatter is configured.
- Validate changes by loading the mod in Transport Fever 2 and smoke-testing the affected feature.
- For settings and localization work, verify that labels and tooltips load in the mod options UI.
- For name data, verify the Indonesian name set appears in map setup and person generation.
- For vehicle filters or terrain generators, verify behavior in-game after a reload.
- Use `rg` for loose mod/game scripts and inspect the stock ZIP archives for packaged assets. Search the installed Yeol reference only when comparing inherited behavior.
- Check the actual build in the game log or main menu. The last verified local build is 35924; do not infer future compatibility from this note.
- Native playtest and long-run economic balance remain open until evidence is recorded; preserve the checklist in [INDUSTRIES.md](INDUSTRIES.md).
