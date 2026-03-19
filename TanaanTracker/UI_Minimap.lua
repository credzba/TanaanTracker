-- TanaanTracker: Minimap Button
-- Angle-based positioning: button always stays on the minimap edge
TanaanTracker = TanaanTracker or {}

-------------------------------------------------
-- SAVED POSITION (angle in radians)
-------------------------------------------------
TanaanTrackerMiniDB = TanaanTrackerMiniDB or { angle = math.pi * 0.75 }

-------------------------------------------------
-- RADIUS: distance from minimap center to button center
-------------------------------------------------
local RADIUS = 80

-------------------------------------------------
-- BUTTON FRAME
-------------------------------------------------
local btn = CreateFrame("Button", "TanaanTrackerMinimapButton", Minimap)

-------------------------------------------------
-- POSITION UPDATE
-------------------------------------------------
local function UpdatePosition(angle)
    TanaanTrackerMiniDB.angle = angle
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * RADIUS,
        math.sin(angle) * RADIUS)
end
btn:SetWidth(33)
btn:SetHeight(33)
btn:SetFrameStrata("MEDIUM")
btn:SetFrameLevel(8)
btn:SetMovable(true)
btn:RegisterForDrag("LeftButton")

-------------------------------------------------
-- ICON TEXTURE
-------------------------------------------------
local icon = btn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\AddOns\\TanaanTracker\\Icon.tga")
icon:SetTexCoord(0, 1, 0, 1)
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

-------------------------------------------------
-- GRAY / SILVER BORDER
-------------------------------------------------
local border = btn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetWidth(56)
border:SetHeight(56)
border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
border:SetDesaturated(true)
border:SetVertexColor(0.8, 0.8, 0.8)

-------------------------------------------------
-- HIGHLIGHT EFFECT
-------------------------------------------------
btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
local hl = btn:GetHighlightTexture()
hl:ClearAllPoints()
hl:SetPoint("CENTER", btn, "CENTER", 0, 0)
hl:SetWidth(36)
hl:SetHeight(36)

-------------------------------------------------
-- DRAGGING: track mouse angle around minimap center
-------------------------------------------------
btn:SetScript("OnDragStart", function(self)
    self.dragging = true
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local scale  = UIParent:GetEffectiveScale()
        local cx, cy = GetCursorPosition()
        cx, cy = cx / scale, cy / scale
        UpdatePosition(math.atan2(cy - my, cx - mx))
    end)
end)

btn:SetScript("OnDragStop", function(self)
    self.dragging = false
    self:SetScript("OnUpdate", nil)
end)

-------------------------------------------------
-- TOOLTIP + CLICK
-------------------------------------------------
btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("|cff00ff00TanaanTracker|r")
    GameTooltip:AddLine("Drag to move around minimap", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("Left-click: Toggle main window", 1, 1, 1)
    GameTooltip:Show()
end)
btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

btn:SetScript("OnClick", function()
    if TanaanTracker.ToggleMainFrame and type(TanaanTracker.ToggleMainFrame) == "function" then
        TanaanTracker.ToggleMainFrame()
    elseif TanaanTracker.mainFrame then
        if TanaanTracker.mainFrame:IsShown() then
            TanaanTracker.mainFrame:Hide()
        else
            TanaanTracker.mainFrame:Show()
        end
    else
        print("|cff00ff00[TanaanTracker]|r UI toggle not found.")
    end
end)

-------------------------------------------------
-- PUBLIC CREATION CALL
-------------------------------------------------
function TanaanTracker.CreateMinimapButton()
    UpdatePosition(TanaanTrackerMiniDB.angle or math.pi * 0.75)
    btn:Show()
end
