-- TanaanTracker: UI_Main.lua
local TanaanTracker = TanaanTracker
local rares, raresOrder = TanaanTracker.rares, TanaanTracker.raresOrder

-------------------------------------------------------------
-- BACKDROP
-------------------------------------------------------------
local function CreateBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.06, 0.06, 0.07, 0.9)
    frame:SetBackdropBorderColor(0, 0, 0, 0.9)
end

-------------------------------------------------------------
-- MAIN FRAME CREATION
-------------------------------------------------------------
function TanaanTracker.CreateMainFrame()
    if TanaanTracker.mainFrame and TanaanTracker.mainFrame:IsShown() then return end
    if TanaanTracker.mainFrame then
        TanaanTracker.mainFrame:Show()
        return
    end

    local f = CreateFrame("Frame", "TanaanTracker_MainFrame", UIParent)
    f:SetSize(490, 260)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    CreateBackdrop(f)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -10)
    local realmName = GetRealmName() or "Unknown Realm"
    -- title:SetText(string.format("|cff66c0f4Tanaan Tracker|r  |cffffff00[%s]|r", realmName))
    title:SetText("|cff66c0f4Tanaan Tracker|r")

    -- Subtitle
    local subtitle = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -24)
    subtitle:SetText("|cff00ff00Trust in the Process.|r")

        -------------------------------------------------------------
    -- Realm dropdown (view-only)
    -------------------------------------------------------------
    -- Taint-free realm selector (replaces UIDropDownMenuTemplate which caused
    -- JoinBattlefield() taint via the shared UIDropDownMenuInfo global)
    local realmBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    realmBtn:SetSize(170, 22)
    realmBtn:SetPoint("TOP", f, "TOP", -17, -12)
    realmBtn:SetText(TanaanTracker.currentRealmView or GetRealmName() or "Unknown")
    f.realmBtn = realmBtn
    f._titleFS = title

    -- Custom dropdown list (no UIDropDownMenuTemplate, no shared globals)
    local realmList = CreateFrame("Frame", nil, f)
    realmList:SetSize(170, 10)
    realmList:SetFrameLevel(f:GetFrameLevel() + 10)
    realmList:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    realmList:SetBackdropColor(0.06, 0.06, 0.09, 0.97)
    realmList:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    realmList:Hide()
    f.realmList = realmList

    local function RefreshRealmList()
        for _, child in ipairs({realmList:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end

        local realms = {}
        if TanaanTrackerDB and TanaanTrackerDB.realms then
            for k in pairs(TanaanTrackerDB.realms) do
                realms[#realms + 1] = k
            end
        end
        table.sort(realms)

        local btnH = 20
        local pad  = 6
        realmList:SetSize(170, #realms * btnH + pad * 2)

        for i, realmName in ipairs(realms) do
            local rb = CreateFrame("Button", nil, realmList)
            rb:SetSize(158, btnH)
            rb:SetPoint("TOPLEFT", realmList, "TOPLEFT", pad, -(pad + (i - 1) * btnH))
            rb:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

            local txt = rb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            txt:SetAllPoints()
            txt:SetJustifyH("LEFT")
            local current = TanaanTracker.currentRealmView or GetRealmName() or "Unknown"
            if realmName == current then
                txt:SetText("|cffffff00" .. realmName .. "|r")
            else
                txt:SetText(realmName)
            end

            rb:SetScript("OnClick", function()
                TanaanTracker.currentRealmView = realmName
                realmBtn:SetText(realmName)
                realmList:Hide()
                C_Timer.After(0.05, function()
                    if TanaanTracker.UpdateUI then TanaanTracker.UpdateUI() end
                end)
            end)
        end
    end

    realmBtn:SetScript("OnClick", function()
        if realmList:IsShown() then
            realmList:Hide()
        else
            RefreshRealmList()
            realmList:SetPoint("TOPLEFT", realmBtn, "BOTTOMLEFT", 0, -2)
            realmList:Show()
        end
    end)

    f:HookScript("OnHide", function()
        realmList:Hide()
    end)

    f:HookScript("OnShow", function()
        local current = TanaanTracker.currentRealmView or GetRealmName() or "Unknown"
        realmBtn:SetText(current)
        C_Timer.After(0.05, function()
            if TanaanTracker.UpdateUI then TanaanTracker.UpdateUI() end
        end)
    end)


    -- Close button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    if ElvUI and ElvUI[1] and ElvUI[1].GetModule then
        local E = ElvUI[1]
        local S = E:GetModule("Skins", true)
        if S and S.HandleCloseButton then
            S:HandleCloseButton(close)
        end
    end
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    close:SetSize(40, 40)
    close:SetScript("OnClick", function()
        -- Reset realm view back to the player's current realm
        local currentRealm = GetRealmName() or "Unknown Realm"
        if TanaanTracker.currentRealmView ~= currentRealm then
            TanaanTracker.currentRealmView = currentRealm
        end
        f:Hide()
    end)
    f:HookScript("OnHide", function()
        local currentRealm = GetRealmName() or "Unknown Realm"
        if TanaanTracker.currentRealmView ~= currentRealm then
            TanaanTracker.currentRealmView = currentRealm
            if TanaanTracker.UpdateUI then
                TanaanTracker.UpdateUI()
            end
        end
    end)
    close:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")

    -- Auto announce checkbox
    local auto = CreateFrame("CheckButton", nil, f, "ChatConfigCheckButtonTemplate")
    auto:SetSize(20, 20)                              
    auto:SetPoint("TOPRIGHT", f, "TOPRIGHT", -42, -10)    
-- auto:SetFrameLevel(close:GetFrameLevel() - 1)         -- ensure it's *below* the X button  -- patched by TanaanTrackerFix
    auto:SetHitRectInsets(0, 0, 0, 0)                     
    auto.tooltip = "Auto announce kills to Guild"
    auto:SetChecked(TanaanTrackerDB.autoAnnounce or false)
    auto:SetScript("OnClick", function(self)
        TanaanTrackerDB.autoAnnounce = self:GetChecked() or false
    end)

    -- Label
    local autoLbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    autoLbl:SetPoint("RIGHT", auto, "LEFT", -4, 0)
    autoLbl:SetText("Auto announce")
    autoLbl:SetJustifyH("RIGHT")


    ---------------------------
    -- START OF ALERT TOGGLE
    ---------------------------

    -- alerts toggle checkbox
    local alerts = CreateFrame("CheckButton", nil, f, "ChatConfigCheckButtonTemplate")
    alerts:SetSize(20, 20)
    alerts:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 5)
    alerts:SetHitRectInsets(0, 0, 0, 0)
    alerts.tooltip = "Show 5m/1m respawn alerts"

    -- default ON unless explicitly false
    if TanaanTrackerDB.alertsEnabled == nil then
        TanaanTrackerDB.alertsEnabled = true
    end
    alerts:SetChecked(TanaanTrackerDB.alertsEnabled)

    alerts:SetScript("OnClick", function(self)
        TanaanTrackerDB.alertsEnabled = self:GetChecked() and true or false
    end)

    -- label for alerts
    local alertsLbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    alertsLbl:SetPoint("RIGHT", alerts, "LEFT", -4, 0)
    alertsLbl:SetText("Alerts")
    alertsLbl:SetJustifyH("RIGHT")

    -- elvui skin (if available)
    if ElvUI and ElvUI[1] and ElvUI[1].GetModule then
        local E = ElvUI[1]
        local S = E:GetModule("Skins", true)
        if S and S.HandleCheckBox then
            S:HandleCheckBox(alerts)
        end
    end

    ---------------------------------
    -- END OF ALERT TOGGLE
    ----------------------------------

    -- ElvUI skin support
    if ElvUI and ElvUI[1] and ElvUI[1].GetModule then
        local E = ElvUI[1]
        local S = E:GetModule("Skins", true)
        if S and S.HandleCheckBox then
            S:HandleCheckBox(auto)
        end
    end


    -- Headers
    local headerName = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerName:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -36)
    headerName:SetText("Name")

    local headerKilled = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerKilled:SetPoint("TOPLEFT", f, "TOPLEFT", 150, -36)
    headerKilled:SetText("Killed (server)")

    local headerSince = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerSince:SetPoint("TOPLEFT", f, "TOPLEFT", 270, -36)
    headerSince:SetText("Since")

    local headerRemaining = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerRemaining:SetPoint("TOPLEFT", f, "TOPLEFT", 340, -36)
    headerRemaining:SetText("Remaining")

    -------------------------------------------------------------
    -- RARE ROWS
    -------------------------------------------------------------
    TanaanTracker.rareWidgets = {}
    local y = -56
    local showBars = TanaanTracker.SHOW_BARS

    for _, name in ipairs(raresOrder) do
        local data = rares[name]
        local row = CreateFrame("Frame", nil, f)
        row:SetSize(380, 36)
        row:SetPoint("TOPLEFT", f, "TOPLEFT", 12, y)

        local nameBtn = CreateFrame("Button", nil, row)
        nameBtn:SetPoint("LEFT", row, "LEFT", 0, 0)
        nameBtn:SetSize(120, 20)
        nameBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        nameBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        nameBtn:GetHighlightTexture():SetAlpha(0.25)

        local nameTxt = nameBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameTxt:SetAllPoints()
        nameTxt:SetJustifyH("LEFT")

        local strike = nameBtn:CreateTexture(nil, "OVERLAY")
        strike:SetTexture(1, 1, 1, 0.7)
        strike:SetHeight(1)
        strike:SetPoint("LEFT", nameTxt, "LEFT", 0, 0)
        strike:SetWidth(120)
        strike:Hide()

        if TanaanTracker.CharKilledToday(name) then
            nameTxt:SetText("|cff888888" .. name .. "|r")
            strike:Show()
        else
            nameTxt:SetText("|cffffd100" .. name .. "|r")
        end

        -- Button click: announce timers
        nameBtn:SetScript("OnClick", function(_, btn)
            local db = TanaanTracker:ViewedRealmDB()
            local t = db[name]
            local msgOut

            if t and type(t) == "number" then
                local remaining = (t + data.respawn) - GetServerTime()
                if remaining < 0 then remaining = 0 end
                msgOut = string.format("%s: in ~%s (killed %s)",
                    name, TanaanTracker.formatCountdown(remaining), TanaanTracker.safeFormatTime(t))
            else
                msgOut = name .. ": no data yet"
            end

            -------------------------------------------------------
            -- SHIFT-MODIFIER LOGIC
            -------------------------------------------------------
            if IsShiftKeyDown() then
                -- SHIFT + LMB = global channel announce
                if btn == "LeftButton" then
                    local chanId = GetChannelName("global")
                    if chanId and chanId > 0 then
                        SendChatMessage(msgOut, "CHANNEL", nil, chanId)
                    else
                        print("|cffff0000[TanaanTracker]|r You are not in channel 'global'.")
                    end
                    return
                end

                -- SHIFT + RMB = YELL
                if btn == "RightButton" then
                    SendChatMessage(msgOut, "YELL")
                    return
                end
            end

            -------------------------------------------------------
            -- NORMAL (NON-SHIFT) BEHAVIOR
            -------------------------------------------------------
            if btn == "LeftButton" then
                if IsInGuild() then
                    SendChatMessage(msgOut, "GUILD")
                else
                    print("Not in a guild.")
                end
            elseif btn == "RightButton" then
                SendChatMessage(msgOut, "SAY")
            end
        end)


        -- Tooltip
        nameBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(nameBtn, "ANCHOR_RIGHT")
            GameTooltip:AddLine(name)
            if data.coords then
                GameTooltip:AddLine(string.format("Coords: %.1f, %.1f", data.coords[1], data.coords[2]), 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        nameBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        local killedTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        killedTxt:SetPoint("LEFT", row, "LEFT", 130, 0)
        killedTxt:SetWidth(110)

        local sinceTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        sinceTxt:SetPoint("LEFT", row, "LEFT", 240, 0)
        sinceTxt:SetWidth(80)

        local remainTxt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        remainTxt:SetPoint("LEFT", row, "LEFT", 320, 0)
        remainTxt:SetWidth(90)

        local bar
        if showBars then
            bar = CreateFrame("StatusBar", nil, row)
            bar:SetSize(400, 6)
            bar:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 2)
            bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
            bar:GetStatusBarTexture():SetHorizTile(false)
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(0)
            local bg = bar:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints(bar)
            bg:SetTexture(1, 1, 1)
            bg:SetVertexColor(0.533, 0.306, 0.533, 1)
        end

        if TanaanTracker.AttachTomTomButtons then
            TanaanTracker.AttachTomTomButtons(row, name, remainTxt)
        end

        TanaanTracker.rareWidgets[name] = {
            row = row, nameBtn = nameBtn, nameTxt = nameTxt,
            killedTxt = killedTxt, sinceTxt = sinceTxt, remainTxt = remainTxt, bar = bar, strike = strike
        }

        y = y - 44
    end

    TanaanTracker.mainFrame = f
    TanaanTracker.mainFrame:Hide()
end


-------------------------------------------------------------
-- UPDATE FUNCTION (optimized)
-------------------------------------------------------------
function TanaanTracker.UpdateUI()
    if not TanaanTracker.mainFrame then return end

    local db = TanaanTracker:ViewedRealmDB()
    local widgets = TanaanTracker.rareWidgets
    local showBars = TanaanTracker.SHOW_BARS

    local remainingTimes = {}

    for _, name in ipairs(raresOrder) do
        local w = widgets[name]
        if w then
            local data = rares[name]
            local t = db[name]
            if type(t) == "number" then
                local killedStr = TanaanTracker.safeFormatTime(t)
                local sinceStr  = TanaanTracker.safeTimeAgo(t)
                local remaining = (t + data.respawn) - GetServerTime()
                if remaining < 0 then remaining = 0 end
                local remainStr = TanaanTracker.formatCountdown(remaining)
                remainingTimes[name] = remaining

                if w._lastKilledStr ~= killedStr then
                    w.killedTxt:SetText(killedStr)
                    w._lastKilledStr = killedStr
                end
                if w._lastSinceStr ~= sinceStr then
                    w.sinceTxt:SetText(sinceStr)
                    w._lastSinceStr = sinceStr
                end
                if w._lastRemainStr ~= remainStr then
                    w.remainTxt:SetText(remainStr)
                    w._lastRemainStr = remainStr
                end

                -- fire alerts only if enabled
                if TanaanTracker._MaybeAlert and (not TanaanTrackerDB or TanaanTrackerDB.alertsEnabled ~= false) then
                    TanaanTracker._MaybeAlert(name, remaining)
                end

                if showBars and w.bar then
                    local pct = 1 - (remaining / data.respawn)
                    pct = max(0, min(1, pct))
                    if w._lastBar ~= pct then
                        w.bar:SetValue(pct)
                        w._lastBar = pct
                    end
                end
                w._empty = nil
            else
                -- No timer data
                if not w._empty then
                    w.killedTxt:SetText("—")
                    w.sinceTxt:SetText("—")
                    w.remainTxt:SetText("—")
                    if showBars and w.bar then w.bar:SetValue(0) end
                    w._lastKilledStr, w._lastSinceStr, w._lastRemainStr, w._lastBar = nil, nil, nil, nil
                    w._empty = true
                end
            end

            local killedToday = TanaanTracker.CharKilledToday and TanaanTracker.CharKilledToday(name)
            if w._lastKilledToday ~= killedToday then
                if killedToday then
                    w.nameTxt:SetText("|cff888888" .. name .. "|r")
                    w.strike:Show()
                else
                    w.nameTxt:SetText("|cffffd100" .. name .. "|r")
                    w.strike:Hide()
                end
                w._lastKilledToday = killedToday
            end
        end
    end

    -- Sort rows by remaining time ascending; unknowns go to the bottom
    local sorted = {}
    for _, name in ipairs(raresOrder) do
        sorted[#sorted + 1] = name
    end
    table.sort(sorted, function(a, b)
        local ra = remainingTimes[a]
        local rb = remainingTimes[b]
        if ra and rb then return ra < rb end
        if ra then return true end
        return false
    end)

    local f = TanaanTracker.mainFrame
    for i, name in ipairs(sorted) do
        local w = widgets[name]
        if w then
            w.row:ClearAllPoints()
            w.row:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -56 - (i - 1) * 44)
        end
    end
end
