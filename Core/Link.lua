local _, ns = ...

-- classic1x is the confirmed Classic Era armory. It is UNCONFIRMED for 1.60: worldofwarcraft.blizzard.com has no WoW Forever route yet, so Forever links reuse it until launch shows the real one.
local ARMORY_URL = "https://worldofwarcraft.blizzard.com/%s/classic1x/%s/armory/character/%s/%s"

-- Armory realm slugs are lowercase and dash separated, with apostrophes dropped rather than replaced: Rhok'delar is rhokdelar, not rhok-delar.
local function realmSlug(realm)
    return (realm:gsub("'", ""):lower():gsub("[^%w]+", "-"):gsub("^%-+", ""):gsub("%-+$", ""))
end

-- Returns nil rather than a malformed URL, so the caller drops the menu entry instead of offering a dead link.
function ns.ArmoryUrl(realm, name)
    local slug = realmSlug(realm)
    if slug == "" then
        return nil
    end

    -- Armory locale slugs are the client locale lowercased and split: enUS is en-us.
    local locale = GetLocale()
    locale = locale:sub(1, 2):lower() .. "-" .. locale:sub(3, 4):lower()
    return ARMORY_URL:format(locale, GetCurrentRegionName():lower(), slug, name:lower())
end
