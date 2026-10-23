local addonName, ns = ...

local UI = LibStub("LibNativeUI-1.0")

local TITLE = "Player Armory Link"
local COPIED_TEXT = "Armory link copied to clipboard."
local WIDTH = 448

-- Long enough for the client to finish the copy before the edit box goes away.
local CLOSE_DELAY = 0.2

-- macOS copies only with Cmd, so Ctrl there must not close the dialog or report a copy.
local copyModifier = IsMacClient() and IsMetaKeyDown or IsControlKeyDown

local dialog

local function copyHint()
    local key = IsMacClient() and "Cmd" or "Ctrl"
    return "Press " .. key .. "+C to copy."
end

local function isCopyChord(key)
    return key == "C" and copyModifier()
end

local function createLinkBox(frame)
    local link = UI.CreateEditBox(frame, frame.contentWidth - UI.Native.inputArt)

    link:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)
    link:SetScript("OnEnterPressed", EditBox_HighlightText)

    -- A click places the cursor and drops the selection, so the whole link is selected again.
    link:SetScript("OnMouseUp", EditBox_HighlightText)

    -- Reverts any edit so the link stays intact and fully selected.
    link:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self:GetText() ~= frame.url then
            self:SetText(frame.url)
            self:HighlightText()
        end
    end)

    link:SetScript("OnKeyDown", function(self, key)
        if not isCopyChord(key) then
            return
        end

        -- Selects the whole link before the client copies, so the copy is never empty.
        self:HighlightText()
        C_Timer.After(CLOSE_DELAY, function()
            frame:Hide()
            UIErrorsFrame:AddMessage(COPIED_TEXT, GREEN_FONT_COLOR:GetRGB())
        end)
    end)

    return link
end

-- The name as the 16 px title, the realm, the selected link and a grey hint, above the centre so the character stays visible.
local function createDialog()
    local frame = UI.CreateDialog({
        name = addonName .. "Dialog",
        title = TITLE,
        width = WIDTH,
        position = { point = "CENTER", y = 140 },
    })
    frame.name = frame:AddText("title", "")
    frame.realm = frame:AddText("body", "", UI.Space.tight)
    frame.link = createLinkBox(frame)
    frame:AddField(frame.link, UI.Native.inputHeight, UI.Space.gap, UI.Native.inputArt)
    frame:AddText("muted", copyHint(), UI.Space.tight)
    frame:Fit()
    return frame
end

function ns.ShowCopyDialog(displayName, realm, url)
    dialog = dialog or createDialog()
    dialog.url = url
    dialog.name:SetText(displayName)
    dialog.realm:SetText(realm)
    dialog.link:SetText(url)
    dialog.link:SetCursorPosition(0)
    dialog:Show()
    dialog.link:SetFocus()
    dialog.link:HighlightText()
end
