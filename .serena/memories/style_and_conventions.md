Style & conventions (observed / recommended)

Observed conventions:
- Lua-based code with top-level `data()` functions returning tables (typical Transport Fever mod pattern).
- Localization keys accessed via `_()` in `mod.lua` and `strings.lua`.
- Mod metadata and UI params set in `mod.lua` under `info` and `options` tables.
- Use of `game.config` to change runtime behavior and feature availability.
- File/folder layout follows Transport Fever 2 mod conventions: `res/models`, `res/textures`, `res/scripts`, `res/config`.
- UTF-8 encoding for strings.

Recommended conventions:
- Keep `data()` function pure: return a table; avoid side effects outside `runFn` / `postRunFn`.
- Use clear localization keys defined in `strings.lua`; maintain English and add other locales under `res/config/name2/indonesia/en` when adding translations.
- Naming: use descriptive keys for `params` (snake_case is used in `mod.lua`), and descriptive Lua function names in scripts.
- Formatting: consistent indentation (spaces), no tabs. Keep short functions, split larger logic into `res/scripts/` modules and `require` them.
- Linting/formatting: adopt `luacheck` and `lua-format` for automated checks/formatting; add config files if desired.

Testing & validation:
- Manual test by enabling the mod in Transport Fever 2 and verifying UI params, vehicle filters, name generation, and terrain generators.
- Use `Select-String` / `grep` to locate usage of keys when refactoring localization.

Documentation:
- Update `GEMINI.md` or add `README.md` for contributor-facing instructions (how to test in-game, where to place assets, packaging notes).