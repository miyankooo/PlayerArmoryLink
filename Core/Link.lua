local _, ns = ...

-- Forever names are unique per region, so the armory keys a character on region, name and surname, with no realm. Checked on worldofwarcraft.blizzard.com on 2026-11-04: one "name-surname" segment after /character/ is routed, two segments are not. Without a locale the site opens in the viewer's own language, as Blizzard's own links do.
local ARMORY_URL = "https://worldofwarcraft.blizzard.com/forever/%s/armory/character/%s-%s"

-- Returns nil rather than a malformed URL, so the caller drops the menu entry instead of offering a dead link.
function ns.ArmoryUrl(name, surname)
    if not surname or surname == "" then
        return nil
    end

    -- The armory matches names in any case, accented capitals included, so lower() only has to fold ASCII to match Blizzard's links.
    return ARMORY_URL:format(GetCurrentRegionName():lower(), name:lower(), surname:lower())
end
