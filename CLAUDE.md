# PlayerArmoryLink

## Target

- WoW Forever 1.60.x only, `## Interface: 16001`. No client branches, no `WOW_PROJECT_*`, no compat layer.
- `main` holds the Forever version. `1.15.x-backup` stays untouched.
- Verify every API against Gethe `wow-ui-source` and Ketho `BlizzardInterfaceResources`, branch `forever`.

## Rules

- Names come only from Blizzard's menu context, `context.name` and `context.surname`, never from `UnitName`. For unit menus `UnitPopupManager:OpenMenu` fills both from `UnitNameUnmodified`.
- A roster name without a surname is split on a space or a hyphen. Keep both: chat links join names with `CHARACTERNAME_LINK_SEPARATOR` (`-`).
- Call `RegionalUniqueNamesEnabled()`, never just test that it exists. When true, the second part is a surname, the display name comes from `NameUtil.GetFullNameWithoutRealm` and the realm from `GetRealmName()`. When false, the second part is the realm, as in Blizzard's menu.
- Read the name inside `pcall`. `canaccessvalue` and `issecretvalue` are `SecretArguments = "AllowedWhenUntainted"`, so they can't guard tainted addon code.
- Parked: no CurseForge release until Blizzard publishes a Forever armory route. Then replace `ARMORY_URL`, put the surname in the URL, recheck the realm source and add the CurseForge clause back to the README installation.
- The copy dialog is `UI.CreateDialog` from LibNativeUI-1.0, 448 px wide and anchored at `CENTER` +140, with `UI.Font` roles and `UI.Space` tokens on the 4 px grid. No other layout constants, no 10 px fonts, no literal `|cff` codes.
- No slash command, no addon menu entry and no SavedVariables: the dialog needs a player and opens only from a player menu.
- Only the platform's copy chord counts: Cmd+C on macOS, Ctrl+C elsewhere. The link stays fully selected.
- Left out on purpose: `MENU_UNIT_WORLD_STATE_SCORE`, which nothing on Forever opens.
- The toc version stays 1.0.0 until the first CurseForge release.
- Licence: MIT (LICENSE).

## Libraries

- `Libs/` holds LibStub and LibNativeUI-1.0, tracked and unedited. ChatScan holds the reference copy and every copy is byte-identical. Change it only by raising `MINOR` there and copying it to all addons. `shasum */Libs/LibNativeUI-1.0/LibNativeUI-1.0.lua` must print one hash.

## Checks

- Run `luac -p` on every Lua file after a change. The repo has no test harness.
- Turn on `/console scriptErrors 1` before testing in game.
