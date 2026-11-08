local addonName, ns = ...

local UI = LibStub("LibNativeUI-1.0")

local ADDON_TITLE = "Player Armory Link"
local TITLE = "Armory Link"
local COPIED_TEXT = "Armory link copied to clipboard."

-- macOS copies with Cmd only, so there Ctrl must not close the dialog. The key names are Blizzard's own,
-- localized as the keyboard labels them, such as STRG on a German client.
local IS_MAC = IsMacClient()
local isCopyModifierDown = IS_MAC and IsMetaKeyDown or IsControlKeyDown
local COPY_HINT = ("Press %s-C to copy the link, then paste it into your browser."):format(IS_MAC and CMD_KEY_TEXT or CTRL_KEY_TEXT)

-- The widest LibNativeUI dialog, so as much of the link as possible shows.
local WIDTH = 480

-- Long enough for the client to finish the copy before the edit box goes away.
local CLOSE_DELAY = 0.2

local dialog

local function createLinkBox(frame)
    local link = UI.CreateEditBox(frame, frame.contentWidth - UI.Native.inputArt)
    link:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)

    -- A click places the cursor and drops the selection, so the whole link is selected again.
    link:SetScript("OnMouseUp", EditBox_HighlightText)

    -- Reverts any edit, so the link stays intact and selected.
    link:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= frame.url then
            self:SetText(frame.url)
            self:HighlightText()
        end
    end)

    -- CopyToClipboard is restricted, so the copy is the player's own keypress. The link is selected again
    -- before the client copies, so the copy is never partial.
    link:SetScript("OnKeyDown", function(self, key)
        if key ~= "C" or not isCopyModifierDown() then
            return
        end
        self:HighlightText()
        C_Timer.After(CLOSE_DELAY, function()
            frame:Hide()
            UI.Print(ADDON_TITLE, COPIED_TEXT)
        end)
    end)
    return link
end

-- Whose link as the title, what to do in white body text, then the selected link. Above the centre so
-- the character stays visible.
local function createDialog()
    local frame = UI.CreateDialog({
        name = addonName .. "Dialog",
        title = TITLE,
        width = WIDTH,
        position = { point = "CENTER", y = 140 },
    })
    frame.name = frame:AddText("title", "")
    frame:AddText("body", COPY_HINT, UI.Space.gap)
    frame.link = frame:AddField(createLinkBox(frame), UI.Native.inputHeight, UI.Space.tight, UI.Native.inputArt)
    frame:Fit()
    return frame
end

function ns.ShowCopyDialog(displayName, url)
    dialog = dialog or createDialog()
    dialog.url = url
    dialog.name:SetText(displayName)
    dialog.link:SetText(url)
    dialog.link:SetCursorPosition(0)
    dialog:Show()
    dialog.link:SetFocus()
    dialog.link:HighlightText()
end
