# Suggested Commands

Project navigation and search:

- cd /home/tomylana93/mods/indonesia_fever
- ls
- find res -maxdepth 3 -type f | sort
- rg "pattern" /home/tomylana93/mods/indonesia_fever /home/tomylana93/mods/base_game
- rg --files /home/tomylana93/mods/indonesia_fever

Git inspection:

- git -C /home/tomylana93/mods/indonesia_fever status --short
- git -C /home/tomylana93/mods/indonesia_fever diff --stat
- git -C /home/tomylana93/mods/indonesia_fever diff

Validation notes:

- There is no repo-local build, test, lint, or formatter command.
- There is no repo-provided CLI entrypoint to run the mod directly.
- Validate changes by launching Transport Fever 2 using the normal installed game workflow and enabling/reloading the mod in-game.
