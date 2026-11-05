# PlayerArmoryLink

Adds an Armory Link entry to player menus with a copy dialog. Features and usage are in `README.md`.

## Target

- `main` holds the Forever version. `1.15.x-backup` keeps the Classic version.

## Rules

- Names come only from Blizzard's menu context, `context.name` and `context.surname`, never from `UnitName`. For unit menus `UnitPopupManager:OpenMenu` fills both from `UnitNameUnmodified`.
- A joined name is split into first name and surname on a space or a hyphen. Keep both: chat links join names with `CHARACTERNAME_LINK_SEPARATOR` (`-`). Names hold neither, so only the first two parts count and a realm suffix is dropped.
- Call `RegionalUniqueNamesEnabled()`, never just test that it exists. When true, the second part is a surname and the display name comes from `NameUtil.GetFullNameWithoutRealm`. When false, the second part is the realm, as in Blizzard's menu, and no entry appears.
- Read the name inside `pcall`. `canaccessvalue` and `issecretvalue` are `SecretArguments = "AllowedWhenUntainted"`, so they can't guard tainted addon code.
- The copy dialog is `UI.CreateDialog` from LibNativeUI-1.0, 480 px wide (the library's maximum, so most of the link shows) and anchored at `CENTER` +140, with `UI.Font` roles and `UI.Space` tokens on the 4 px grid. No other layout constants and no 10 px fonts.
- Its order follows Blizzard's housing share-code export: the name as the 16 px title, a white `body` instruction, then the link field one `tight` step below. The instruction is not `muted`, because grey 12 px text is hard to read on the dialog art.
- `CopyToClipboard` has `HasRestrictions = true`, so the copy stays the player's own keypress.
- No slash command, no addon menu entry and no SavedVariables: the dialog needs a player and opens only from a player menu.
- Only the platform's copy chord counts: Cmd+C on macOS, Ctrl+C elsewhere. The link stays fully selected.
- Left out on purpose: `MENU_UNIT_WORLD_STATE_SCORE`, which nothing on Forever opens. Also a name copy feature, because the game's own Copy Character Name entry covers it.

## Armory route

Checked on 2026-11-04, before launch, in the owner's Chrome through playwright-cli and the site's own GraphQL.

- `ARMORY_URL` in `Core/Link.lua` is `https://worldofwarcraft.blizzard.com/forever/<region>/armory/character/<name>-<surname>`. It holds no realm, ruleset or faction. The client's `CHARACTER_CREATE_SURNAME_TOOLTIP` says name and surname form the identity "across the region".
- One hyphenated segment after `/character/` is routed in all 15 site languages and all regions. Two segments give 404. An unknown character gives 500, like `classic1x`.
- The router accepts any region code, so a 500 proves nothing about a region. The site's region list (`GetInitialRealmStatusData`) has only `us`, `eu`, `kr` and `tw`, and `forever-cn` returns an error. `ARMORY_REGIONS` holds those four.
- Forever realms are rulesets (`isRuleset: true`), not language realms. US and EU have Normal, PvP, Roleplay and Roleplay PvP. KR and TW have Normal and PvP.
- The site matches Latin, accented and Cyrillic names in any case. Hangul and Hanzi have no case. `slug()` lowercases ASCII and percent-encodes every other byte. Those exact forms opened real Classic characters in EU, KR and TW.
- A link without a locale redirects (307) to the browser's language. Requests to a locale path such as `/zh-tw/` set the site's `locale` cookie, so reset it by opening an `/en-us/` page after tests.
- The armory lists a character only from level 10.
- Live check on 2026-11-05, after launch, in EU and US: the armory search's own links are `/forever/<region>/armory/character/<name>-<surname>`, with non-ASCII letters lowercased and percent-encoded (`%C3%A9ric-cantona`). The addon lowercases only ASCII (`%C3%89ric-cantona`). Both forms returned 200 for all 28 live names checked, Latin, accented and Cyrillic, and opened the character page. An unknown name returned 500. KR and TW were not checked live.
- The official Battle.net API needs an OAuth client. A forum report from 2026-11-02 says `profile-forever-{region}` works and the name-surname character path was not routed yet.

## Release

- `.pkgmeta` also leaves out `CLAUDE.md`.

## Checks

- The repo has no test harness, so `luac -p` is the only offline check.
