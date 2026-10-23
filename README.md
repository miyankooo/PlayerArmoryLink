# Player Armory Link

Adds an Armory Link entry to player right-click menus with the player's armory link ready to copy, in the Classic Era format until WoW Forever has an armory.

## Features

- An Armory Link entry at the end of every player menu: your own portrait, target and focus frames, party and raid frames, chat names, the friends list, the guild and community rosters, recent allies and the battleground scoreboard.
- A small dialog in the game's own style with the name including the surname, the realm and the link already selected.
- One keypress copies the link and closes the dialog: Cmd+C on macOS, Ctrl+C on Windows.
- Nothing to set up and nothing saved. Realm, region and language come from the game.

## Installation

1. Copy the `PlayerArmoryLink` folder into `World of Warcraft/_classic_beta_/Interface/AddOns/`.
2. Restart the game or type `/reload`.
3. Enable Player Armory Link in the AddOns list.

## Usage

1. Right-click a player portrait, name or roster row.
2. Pick Armory Link.
3. Press Cmd+C or Ctrl+C. The dialog closes itself once the link is copied.

Escape or the close button closes the dialog without copying.

## Requirements

WoW Forever 1.60.x (Interface `16001`). No other addons needed.

## Restrictions

WoW Forever has no armory pages yet. Until Blizzard publishes Forever characters, links use the Classic Era armory format, so they do not open a Forever character.

No entry appears for NPCs. It also stays hidden for players whose name the game hides from addons in restricted content.

To copy only a name, use the game's own Copy Character Name entry in the same menu.

## License

MIT. See [LICENSE](LICENSE).
