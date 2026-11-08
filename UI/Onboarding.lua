local addonName, ns = ...

-- The addon has no window or settings page: its one surface is Armory Link on player menus. So the welcome
-- line has no link; it says what the addon does and where to find it.
local WELCOME = "Copies any player's armory link, so you can see their gear in your browser. "
    .. "Right-click a player's portrait or chat name and pick Armory Link."
local HELP = "Type /pal intro to see the welcome line again, or /pal help for this list."
local UNKNOWN = "Unknown command. Type /pal help for the list."

-- No saved table yet means the account's first login with the addon. The table stays empty, since the
-- addon has no settings and no help tip whose flag it would hold.
local firstRun = false

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    firstRun = PlayerArmoryLinkDB == nil
    PlayerArmoryLinkDB = PlayerArmoryLinkDB or {}
end)

-- At login the client's own load lines are already in chat.
EventUtil.ContinueOnPlayerLogin(function()
    if firstRun then
        ns.Print(WELCOME)
    end
end)

-- With nothing to open, the bare command prints the help line. intro replays the welcome line; there is no
-- tip flag to clear.
SLASH_PLAYERARMORYLINK1, SLASH_PLAYERARMORYLINK2 = "/playerarmorylink", "/pal"
SlashCmdList.PLAYERARMORYLINK = function(message)
    local command = strtrim(message or ""):lower()
    if command == "" or command == "help" or command == "?" then
        ns.Print(HELP)
    elseif command == "intro" then
        ns.Print(WELCOME)
    else
        ns.Print(UNKNOWN)
    end
end
