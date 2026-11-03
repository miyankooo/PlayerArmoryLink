# PlayerArmoryLink

Adds an Armory Link entry to player menus with a copy dialog. Features and usage are in `README.md`.

## Target

- `main` holds the Forever version. `1.15.x-backup` keeps the Classic version.

## Rules

- Names come only from Blizzard's menu context, `context.name` and `context.surname`, never from `UnitName`. For unit menus `UnitPopupManager:OpenMenu` fills both from `UnitNameUnmodified`.
- A roster name without a surname is split on a space or a hyphen. Keep both: chat links join names with `CHARACTERNAME_LINK_SEPARATOR` (`-`).
- Call `RegionalUniqueNamesEnabled()`, never just test that it exists. When true, the second part is a surname, the display name comes from `NameUtil.GetFullNameWithoutRealm` and the realm from `GetRealmName()`. When false, the second part is the realm, as in Blizzard's menu.
- Read the name inside `pcall`. `canaccessvalue` and `issecretvalue` are `SecretArguments = "AllowedWhenUntainted"`, so they can't guard tainted addon code.
- The copy dialog is `UI.CreateDialog` from LibNativeUI-1.0, 448 px wide and anchored at `CENTER` +140, with `UI.Font` roles and `UI.Space` tokens on the 4 px grid. No other layout constants and no 10 px fonts.
- No slash command, no addon menu entry and no SavedVariables: the dialog needs a player and opens only from a player menu.
- Only the platform's copy chord counts: Cmd+C on macOS, Ctrl+C elsewhere. The link stays fully selected.
- Left out on purpose: `MENU_UNIT_WORLD_STATE_SCORE`, which nothing on Forever opens. Also a name copy feature, because the game's own Copy Character Name entry covers it.

## Release

- No CurseForge release until Blizzard publishes a Forever armory route. Until then `ARMORY_URL` in `Core/Link.lua` uses the Classic Era `classic1x` route, which cannot open a Forever character.
- Once a route exists, replace `ARMORY_URL`, put the surname in the URL, recheck the realm source and the non-ASCII realm slugs, then add the CurseForge clause back to the README installation.
- `.pkgmeta` also leaves out `CLAUDE.md`.

## Checks

- The repo has no test harness, so `luac -p` is the only offline check.
