local addonName, ns = ...

local TITLE = "Armory Link"
local COPIED_TEXT = "Armory link copied to clipboard."
local LINK_HELP = "Opens the player's armory page in your browser, with their gear, stats and professions."

-- macOS copies with Cmd only, so there Ctrl must not close the dialog. The key names are Blizzard's own,
-- localized as the keyboard labels them, such as STRG on a German client.
local IS_MAC = IsMacClient()
local isCopyModifierDown = IS_MAC and IsMetaKeyDown or IsControlKeyDown
local COPY_HINT = ("Press %s-C to copy the link, then paste it into your browser."):format(IS_MAC and CMD_KEY_TEXT or CTRL_KEY_TEXT)

-- The widest dialog, so as much of the link as possible shows.
local WIDTH = 480

-- Spacing roles: tight from the instruction to the link, gap from the name to the instruction.
local TIGHT = 4
local GAP = 8

-- InputBoxTemplate's art height and its left cap outside the box (InputBoxTemplates.xml:47-49).
local EDIT_BOX_HEIGHT = 20
local EDIT_BOX_CAP = 5

-- Long enough for the client to finish the copy before the edit box goes away.
local CLOSE_DELAY = 0.2

-- Text in a font role: GameFontNormal (heading, gold), GameFontHighlight (body, white), GameFontDisable (muted,
-- grey), GameFontNormalLarge (title, 16 px, a dialog's subject line only).
local function CreateText(parent, fontObject, layer)
    local text = parent:CreateFontString(nil, layer or "ARTWORK")
    text:SetFontObject(fontObject or GameFontHighlight)
    text:SetJustifyH("LEFT")
    return text
end

-- A GameTooltip owned by the hovered frame, filled with Blizzard's GameTooltip_* line helpers. A frame whose
-- template already sets OnEnter gets HookScript instead.
local function AttachTooltip(frame, fill, anchor)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, anchor or "ANCHOR_RIGHT")
        fill(GameTooltip, self)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", GameTooltip_Hide)
end

-- Rounds a length derived from text up to the 4 px grid.
local function Snap(length)
    return math.ceil(length / 4) * 4
end

-- InputBoxTemplate draws its left cap 5 px outside the box (InputBoxTemplates.xml:49), so the caller indents the
-- box by 5 to line the art up with the column.
local function CreateEditBox(parent, width)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width or 160, 20)
    box:SetAutoFocus(false)
    box:SetFontObject(GameFontHighlight)
    return box
end

-- Restores a saved position, or centres the frame.
local function RestorePosition(frame, position)
    frame:ClearAllPoints()
    if position and position.point then
        frame:SetPoint(position.point, UIParent, position.relPoint or position.point, position.x or 0, position.y or 0)
    else
        frame:SetPoint("CENTER")
    end
end

-- Windows and dialogs: toplevel, clamped, dragged with the left button, closed by Escape through UISpecialFrames,
-- never UIPanelWindows, so they never drive Blizzard's panel layout.
local function MakeMovable(frame, name, strata, position)
    frame:SetFrameStrata(strata)
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if position then
            local point, _, relPoint, x, y = self:GetPoint(1)
            position.point, position.relPoint, position.x, position.y = point, relPoint, x, y
        end
    end)
    RestorePosition(frame, position)
    frame:Hide()
    tinsert(UISpecialFrames, name)
end

-- A dialog in Blizzard's dialog chrome: DialogBorderTemplate, DialogHeaderTemplate with the title and
-- UIPanelCloseButton 2 px in from the corner (Blizzard_Channels/Mainline/CreateChannelPopup.xml:72). Width is a
-- multiple of 8 from 400 to 480. Add content top to bottom with AddText and AddField, then call Fit.
-- AddButton is left out: this dialog has no buttons.
local DIALOG_SIDE, DIALOG_TOP, SECTION_GAP = 20, 40, 24
local function CreateDialog(name, title, width, parent, position)
    local dialog = CreateFrame("Frame", name, parent or UIParent)
    dialog:SetSize(width, DIALOG_TOP + DIALOG_SIDE)
    dialog.contentWidth = width - 2 * DIALOG_SIDE
    dialog.contentHeight = 0
    dialog.buttons = {}
    dialog.Border = CreateFrame("Frame", nil, dialog, "DialogBorderTemplate")
    dialog.Header = CreateFrame("Frame", nil, dialog, "DialogHeaderTemplate")
    dialog.Header:Setup(title)
    -- UIPanelCloseButton_OnClick goes through HideUIPanel, which refuses insecure callers in combat.
    dialog.CloseButton = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    dialog.CloseButton:SetPoint("TOPRIGHT", -2, -2)
    dialog.CloseButton:SetScript("OnClick", function() dialog:Hide() end)

    -- Places a widget the caller sized in the content column below everything added so far; indent covers native
    -- art, 5 for an edit box, 8 for a dropdown. The gap defaults to 8; AddText passes a section break.
    function dialog:AddField(region, height, gap, indent)
        if self.hasContent then self.contentHeight = self.contentHeight + (gap or 8) end
        self.hasContent = true
        region:SetPoint("TOPLEFT", self, "TOPLEFT", DIALOG_SIDE + (indent or 0), -(DIALOG_TOP + self.contentHeight))
        self.contentHeight = self.contentHeight + height
    end

    -- Wrapped text across the column, never less than one line, so text filled in later keeps its line.
    function dialog:AddText(fontObject, text, gap)
        local line = CreateText(self, fontObject)
        line:SetWidth(self.contentWidth)
        line:SetWordWrap(true)
        line:SetText(text or "")
        local _, lineHeight = fontObject:GetFont()
        local height = math.ceil(math.max(line:GetStringHeight(), lineHeight))
        line:SetHeight(height)
        self:AddField(line, height, gap or SECTION_GAP)
        return line
    end

    -- 40 top, the content, a section break and the button row if there are buttons, 20 bottom, on the grid.
    function dialog:Fit()
        local height = DIALOG_TOP + self.contentHeight + DIALOG_SIDE
        if #self.buttons > 0 then height = height + SECTION_GAP + 24 end
        self:SetHeight(Snap(height))
    end

    MakeMovable(dialog, name, "DIALOG", position)
    return dialog
end

local dialog

local function createLinkBox(frame)
    local link = CreateEditBox(frame, frame.contentWidth - EDIT_BOX_CAP)
    link:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)

    -- A click places the cursor and drops the selection, so the whole link is selected again.
    link:SetScript("OnMouseUp", EditBox_HighlightText)

    -- InputBoxTemplate sets no OnEnter (InputBoxTemplates.xml:3-10), so the recipe's SetScript is safe here.
    AttachTooltip(link, function(tooltip)
        GameTooltip_SetTitle(tooltip, TITLE)
        GameTooltip_AddNormalLine(tooltip, LINK_HELP)
    end)

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
            ns.Print(COPIED_TEXT)
        end)
    end)
    return link
end

-- Whose link as the title, what to do in white body text, then the selected link. Above the centre so
-- the character stays visible.
local function createDialog()
    local frame = CreateDialog(addonName .. "Dialog", TITLE, WIDTH, nil, { point = "CENTER", y = 140 })
    frame.name = frame:AddText(GameFontNormalLarge, "")
    frame:AddText(GameFontHighlight, COPY_HINT, GAP)
    frame.link = createLinkBox(frame)
    frame:AddField(frame.link, EDIT_BOX_HEIGHT, TIGHT, EDIT_BOX_CAP)
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
