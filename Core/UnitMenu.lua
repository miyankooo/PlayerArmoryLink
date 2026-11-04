local _, ns = ...

local ENTRY_TEXT = "Armory Link"

-- Every unit menu that can open on a player. Each tag is "MENU_UNIT_" plus the menu name UnitPopupManager:OpenMenu receives.
local MENU_TAGS = {
    "MENU_UNIT_SELF",
    "MENU_UNIT_PLAYER",
    "MENU_UNIT_PARTY",
    "MENU_UNIT_RAID_PLAYER",
    "MENU_UNIT_ENEMY_PLAYER",
    "MENU_UNIT_RAID",
    "MENU_UNIT_FOCUS",
    "MENU_UNIT_FRIEND",
    "MENU_UNIT_FRIEND_OFFLINE",
    "MENU_UNIT_CHAT_ROSTER",
    "MENU_UNIT_PVP_SCOREBOARD",
    "MENU_UNIT_COMMUNITIES_GUILD_MEMBER",
    "MENU_UNIT_COMMUNITIES_WOW_MEMBER",
    "MENU_UNIT_RECENT_ALLY",
    "MENU_UNIT_RECENT_ALLY_OFFLINE",
}

-- UnitPopupManager:OpenMenu fills name and surname from UnitNameUnmodified for unit menus. Chat, rosters, recent allies and the scoreboard pass one joined name instead: "First Surname", or the link form "First-Surname". Names hold no spaces or hyphens, so the first two parts are always first name and surname, and anything after them, such as a realm, is dropped.
local function readName(context)
    local unit = context.unit
    if unit and UnitExists(unit) and not UnitIsPlayer(unit) then
        return nil
    end
    local name = context.name
    if not name then
        return nil
    end
    local first, surname = name:match("^([^%s%-]+)[%s%-]+([^%s%-]+)")
    if first then
        return first, surname
    end
    return name, context.surname
end

-- The armory needs a surname. Without regional unique names the second part is the player's realm, as Blizzard's own menu treats it, so there is no page to link.
local function readPlayer(context)
    if not RegionalUniqueNamesEnabled() then
        return nil
    end
    local name, surname = readName(context)
    if type(name) ~= "string" or name == "" or name == UNKNOWN then
        return nil
    end
    local url = ns.ArmoryUrl(name, surname)
    if not url then
        return nil
    end
    return NameUtil.GetFullNameWithoutRealm(name, surname), url
end

-- A name under identity restriction arrives as a secret value and any string operation on it throws, so the whole read runs in pcall. canaccessvalue cannot guard it: it rejects secrets from tainted callers.
local function appendEntry(_, root, context)
    local ok, displayName, url = pcall(readPlayer, context)
    if not ok or not url then
        return
    end

    root:CreateDivider()

    -- Deferred so the menu tears down before the dialog takes keyboard focus.
    root:CreateButton(ENTRY_TEXT, function()
        C_Timer.After(0, function()
            ns.ShowCopyDialog(displayName, url)
        end)
    end)
end

for _, tag in ipairs(MENU_TAGS) do
    Menu.ModifyMenu(tag, appendEntry)
end
