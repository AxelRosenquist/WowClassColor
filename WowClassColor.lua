local hookedBars = {}

local function GetUnitColor(unit)
    if UnitIsPlayer(unit) then
        local _, classToken = UnitClass(unit)
        local color = classToken and RAID_CLASS_COLORS[classToken]

        if color then
            return color.r, color.g, color.b
        end
    end

    return UnitSelectionColor(unit)
end

local function SetupClassColor(frame, unit)
    local bar = frame and frame.healthbar
    local name = frame and frame.name

    if not bar or not name then
        return
    end

    if hookedBars[bar] then
        hookedBars[bar]()
        return
    end

    local applyingColor = false

    local function ApplyColor()
        if applyingColor or not UnitExists(unit) then
            return
        end

        local r, g, b = GetUnitColor(unit)

        applyingColor = true
        bar:SetStatusBarDesaturated(true)
        bar:SetStatusBarColor(r, g, b)
        name:SetText(UnitName(unit))
        name:SetTextColor(r, g, b)
        applyingColor = false
    end

    hookedBars[bar] = ApplyColor
    hooksecurefunc(bar, "SetStatusBarColor", ApplyColor)
    ApplyColor()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_FOCUS_CHANGED")
events:RegisterUnitEvent("UNIT_TARGET", "target", "focus")

events:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        SetupClassColor(PlayerFrame, "player")
        SetupClassColor(TargetFrame, "target")
        SetupClassColor(FocusFrame, "focus")
        SetupClassColor(TargetFrameToT, "targettarget")
        SetupClassColor(FocusFrameToT, "focustarget")

        self:UnregisterEvent(event)

    elseif event == "PLAYER_TARGET_CHANGED" then
        SetupClassColor(TargetFrame, "target")
        SetupClassColor(TargetFrameToT, "targettarget")

    elseif event == "PLAYER_FOCUS_CHANGED" then
        SetupClassColor(FocusFrame, "focus")
        SetupClassColor(FocusFrameToT, "focustarget")

    elseif event == "UNIT_TARGET" then
        if unit == "target" then
            SetupClassColor(TargetFrameToT, "targettarget")
        elseif unit == "focus" then
            SetupClassColor(FocusFrameToT, "focustarget")
        end
    end
end)