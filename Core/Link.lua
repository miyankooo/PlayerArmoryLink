local _, ns = ...

-- Forever names are unique per region, so the armory keys a character on region, name and surname. One
-- "name-surname" segment routes in every site language, and without a locale the site opens in the
-- viewer's own (checked on worldofwarcraft.blizzard.com, 2026-11-04).
local ARMORY_URL = "https://worldofwarcraft.blizzard.com/forever/%s/armory/character/%s-%s"

-- The regions the Forever armory serves. A CN client gets no entry instead of a dead link.
local ARMORY_REGIONS = {
    US = "us",
    EU = "eu",
    KR = "kr",
    TW = "tw",
}

-- The armory matches names in any case, so lower() only folds ASCII. Every other byte is percent-encoded,
-- so Cyrillic, Hangul and Hanzi names give a valid URL.
local function slug(namePart)
    return (namePart:lower():gsub("[^%w]", function(char)
        return ("%%%02X"):format(char:byte())
    end))
end

-- nil without a known region or a surname, so the caller drops the entry instead of offering a dead link.
function ns.ArmoryUrl(name, surname)
    local region = ARMORY_REGIONS[GetCurrentRegionName()]
    if not region or not surname or surname == "" then
        return nil
    end
    return ARMORY_URL:format(region, slug(name), slug(surname))
end
