-- Checks the first-run welcome line and the slash commands in UI/Onboarding.lua against stubs of the client.
-- Run from the repo root: lua Tests/Welcome.lua
C_AddOns = { GetAddOnMetadata = function() return "Player Armory Link" end }
NORMAL_FONT_COLOR = { WrapTextInColorCode = function(_, text) return "<gold>" .. text .. "</gold>" end }
strtrim = function(text) return (text:gsub("^%s+", ""):gsub("%s+$", "")) end
SlashCmdList = {}

local onLoaded, onLogin
EventUtil = {
    ContinueOnAddOnLoaded = function(_, callback) onLoaded = callback end,
    ContinueOnPlayerLogin = function(callback) onLogin = callback end,
}

local failures = 0
local function Check(label, condition)
    print((condition and "  pass  " or "  FAIL  ") .. label)
    if not condition then failures = failures + 1 end
end

-- Collects the chat lines a call prints.
local function Capture(call)
    local lines, realPrint = {}, print
    print = function(line) table.insert(lines, line) end
    call()
    print = realPrint
    return lines
end

-- Loads the addon on a fresh client with these saved variables, returning the lines of the load and the login.
local function Load(savedVariables)
    PlayerArmoryLinkDB = savedVariables
    local ns = {}
    assert(loadfile("Core/Addon.lua"))("PlayerArmoryLink", ns)
    assert(loadfile("UI/Onboarding.lua"))("PlayerArmoryLink", ns)
    return Capture(onLoaded), Capture(onLogin)
end

local function Has(line, text) return line ~= nil and line:find(text, 1, true) ~= nil end

local PREFIX = "<gold>[Player Armory Link]</gold>: "
local WELCOME_START = PREFIX .. "Copies any player's armory link"

local loaded, login = Load(nil)
Check("the first load prints nothing", #loaded == 0)
Check("the first load creates the saved table", type(PlayerArmoryLinkDB) == "table")
Check("the first login prints one line", #login == 1)
Check("it opens with the gold title and says what the addon does", Has(login[1], WELCOME_START))
Check("it says where to start, then where the commands are",
    Has(login[1], "pick Armory Link. Type /pal help for the commands."))

loaded, login = Load({})
Check("a later load and login print nothing", #loaded == 0 and #login == 0)

Check("/playerarmorylink and /pal are registered",
    SLASH_PLAYERARMORYLINK1 == "/playerarmorylink" and SLASH_PLAYERARMORYLINK2 == "/pal")
local function Slash(message)
    return Capture(function() SlashCmdList.PLAYERARMORYLINK(message) end)
end

local HELP = PREFIX .. "Right-click a player's portrait or chat name and pick Armory Link. "
    .. "Type /pal intro to see the welcome line again, or /pal help for this list."
for _, message in ipairs({ "help", "?", " HELP ", "" }) do
    local lines = Slash(message)
    Check(("/pal %q prints the help line"):format(message), #lines == 1 and lines[1] == HELP)
end

local lines = Slash("intro")
Check("/pal intro prints the welcome line again", #lines == 1 and Has(lines[1], WELCOME_START))

lines = Slash("minimap")
Check("an unknown word prints the hint", #lines == 1 and lines[1] == PREFIX .. "Unknown command. Type /pal help for the list.")

print(failures == 0 and "Welcome: all checks passed" or ("Welcome: " .. failures .. " failed"))
os.exit(failures == 0 and 0 or 1)
