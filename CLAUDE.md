# PlayerArmoryLink

Adds an Armory Link entry to player menus with a copy dialog. Features and usage are in `README.md`.

## Target

- `main` holds the Forever version. `1.15.x-backup` keeps the Classic version.

## Rules

- Names come only from Blizzard's menu context, `context.name` and `context.surname`, never from `UnitName`. For unit menus `UnitPopupManager:OpenMenu` fills both from `UnitNameUnmodified`.
- A roster name without a surname is split on a space or a hyphen. Keep both: chat links join names with `CHARACTERNAME_LINK_SEPARATOR` (`-`).
- Call `RegionalUniqueNamesEnabled()`, never just test that it exists. When true, the second part is a surname and the display name comes from `NameUtil.GetFullNameWithoutRealm`. When false, the second part is the realm, as in Blizzard's menu, and no entry appears.
- Read the name inside `pcall`. `canaccessvalue` and `issecretvalue` are `SecretArguments = "AllowedWhenUntainted"`, so they can't guard tainted addon code.
- The copy dialog is `UI.CreateDialog` from LibNativeUI-1.0, 448 px wide and anchored at `CENTER` +140, with `UI.Font` roles and `UI.Space` tokens on the 4 px grid. No other layout constants and no 10 px fonts.
- No slash command, no addon menu entry and no SavedVariables: the dialog needs a player and opens only from a player menu.
- Only the platform's copy chord counts: Cmd+C on macOS, Ctrl+C elsewhere. The link stays fully selected.
- Left out on purpose: `MENU_UNIT_WORLD_STATE_SCORE`, which nothing on Forever opens. Also a name copy feature, because the game's own Copy Character Name entry covers it.

## Armory route

- `ARMORY_URL` in `Core/Link.lua` is `https://worldofwarcraft.blizzard.com/forever/<region>/armory/character/<name>-<surname>`. Forever names are unique per region, so the URL has no realm and the dialog shows none.
- Found on 2026-11-04 by probing the site: one hyphenated segment after `/character/` is routed (500 for an unknown character, like `classic1x`), two segments give 404. The name-surname order follows the game's `CHARACTERNAME_LINK_SEPARATOR` form and awaits a live check.
- The site matches names in any case, accented capitals included. Its own links are lowercase UTF-8.
- A link without a locale redirects (307) to the viewer's language, so the URL carries none.
- The armory lists a character only from level 10.

## Release

- `.pkgmeta` also leaves out `CLAUDE.md`.

## Checks

- The repo has no test harness, so `luac -p` is the only offline check.
