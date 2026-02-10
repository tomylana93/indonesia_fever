Suggested developer commands (Windows / PowerShell)

- Open project in VS Code:
```
code "c:\Users\tomylana93\AppData\Roaming\Transport Fever 2\staging_area\indonesia_fever_1"
```

- List files / inspect folders (PowerShell):
```
cd "c:\Users\tomylana93\AppData\Roaming\Transport Fever 2\staging_area\indonesia_fever_1"
dir
Get-ChildItem -Recurse res\scripts |
```

- Run the provided VS Code `build` task (for other staging folders that include `msbuild` tasks):
```
msbuild /property:GenerateFullPaths=true /t:build /consoleloggerparameters:NoSummary
```
(Or use VS Code: `Terminal` → `Run Task...` → `build` for the appropriate workspace folder.)

- Quick Lua lint/format (recommended to install locally):
```
luacheck .
lua-format -i **/*.lua
```
(These are suggestions — the repo does not currently include a linter config.)

- Search for localization keys or references (PowerShell):
```
Select-String -Path "**\*.lua" -Pattern "_\(" -SimpleMatch -CaseSensitive
```

- Git basics (if repo tracked):
```
git status
git add -A
git commit -m "Describe change"
```

Notes:
- Transport Fever 2 mods are tested by launching the game with the mod installed. There is no in-repo automated run command; use the game client for runtime testing.
- `GEMINI.md` indicates Gemini CLI was used for scaffolding; follow any local Gemini workflows if present.