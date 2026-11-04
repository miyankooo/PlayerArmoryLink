local _, ns = ...

-- Forever names are unique per region, so the armory keys a character on region, name and surname, with no realm, ruleset or faction. Checked on worldofwarcraft.blizzard.com on 2026-11-04: one "name-surname" segment after /character/ is routed in every site language, two segments are not. Without a locale the site opens in the viewer's own language, as Blizzard's own links do.
local ARMORY_URL = "https://worldofwarcraft.blizzard.com/forever/%s/armory/character/%s-%s"

-- The regions the Forever armory offers. Its realm data has no CN entry, so a CN client gets no entry instead of a dead link.
local ARMORY_REGIONS = {
    US = "us",
    EU = "eu",
    KR = "kr",
    TW = "tw",
}

-- The armory matches names in any case, accented and Cyrillic capitals included, so lower() only has to fold ASCII. Every other byte is percent-encoded, so Cyrillic, Hangul and Hanzi names give a valid URL in any app.
local function slug(namePart)
    return (namePart:lower():gsub("[^%w]", function(char)
        return ("%%%02X"):format(char:byte())
    end))
end

-- Returns nil rather than a malformed URL, so the caller drops the menu entry instead of offering a dead link.
function ns.ArmoryUrl(name, surname)
    local region = ARMORY_REGIONS[GetCurrentRegionName()]
    if not region or not surname or surname == "" then
        return nil
    end
    return ARMORY_URL:format(region, slug(name), slug(surname))
end
