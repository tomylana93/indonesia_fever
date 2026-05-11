# Project Overview

- Project: Indonesia Fever, an editable Transport Fever 2 mod.
- Purpose: add Indonesian-themed gameplay content, including Indonesian town/street/person names, custom terrain generators, tropical river behavior, vehicle filtering for a historical Indonesian context, historical infrastructure year settings, and signal assets.
- Tech stack: Lua scripts and config files for the Transport Fever 2 mod runtime, plus game asset data such as .mdl, .msh, .ani, .mtl, and textures.
- Primary runtime entrypoints:
  - mod.lua defines metadata, settings UI, and runtime hooks.
  - strings.lua defines localization strings used via \_().
  - res/config/name2/indonesia/en contains name datasets.
  - res/config/terrain_generators contains custom map generators.
  - res/scripts contains handwritten helpers such as vehicle_filter.lua and personnameutil.lua.
  - res/models contains signal model/material/mesh assets.
- Workspace note: the sibling base_game folder is a read-only reference copy of base assets and scripts. Use it to confirm stock runtime paths, require paths, and file names, but do not edit it unless explicitly asked.
