local colorHooks = {}

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

local function HookAndApply(object, method, apply)
    if not colorHooks[object] then
        local applying = false

        local function Update()
            if applying then
                return
            end

            applying = true
            apply()
            applying = false
        end

        colorHooks[object] = Update
        hooksecurefunc(object, method, Update)
    end

    colorHooks[object]()
end

local function ColorUnitFrame(frame, unit)
    local bar = frame and frame.healthbar
    local name = frame and frame.name

    if not bar or not name then
        return
    end

    HookAndApply(bar, "SetStatusBarColor", function()
        if not UnitExists(unit) then
            return
        end

        local r, g, b = GetUnitColor(unit)

        bar:SetStatusBarDesaturated(true)
        bar:SetStatusBarColor(r, g, b)
        name:SetText(UnitName(unit))
        name:SetTextColor(r, g, b)
    end)
end

local function ColorNameplate(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)

    if not plate then
        return
    end

    local frame = plate.UnitFrame

    if not frame then
        return
    end

    local bar = frame.healthBar
    local name = frame.name

    if not name then
        return
    end

    HookAndApply(name, "SetVertexColor", function()
        local currentUnit = frame.unit

        if not currentUnit
            or not UnitExists(currentUnit)
            or not UnitIsPlayer(currentUnit) then
            return
        end

        name:SetVertexColor(GetUnitColor(currentUnit))
    end)

    if bar and UnitIsPlayer(unit) then
        bar:SetStatusBarDesaturated(true)
        bar:SetStatusBarColor(GetUnitColor(unit))
    end
end

local function UpdatePlayer()
    ColorUnitFrame(PlayerFrame, "player")
end

local function UpdateTarget()
    ColorUnitFrame(TargetFrame, "target")
    ColorUnitFrame(TargetFrameToT, "targettarget")
end

local function UpdateFocus()
    ColorUnitFrame(FocusFrame, "focus")
    ColorUnitFrame(FocusFrameToT, "focustarget")
end

local function UpdateTargetTarget()
    ColorUnitFrame(TargetFrameToT, "targettarget")

end

local function UpdateFocusTarget()
    ColorUnitFrame(FocusFrameToT, "focustarget")
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_TARGET_CHANGED")
events:RegisterEvent("PLAYER_FOCUS_CHANGED")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterUnitEvent("UNIT_TARGET", "target", "focus")

events:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_LOGIN" then
        UpdatePlayer()
        UpdateTarget()
        UpdateFocus()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_TARGET_CHANGED" then
        UpdateTarget()

    elseif event == "PLAYER_FOCUS_CHANGED" then
        UpdateFocus()

    elseif event == "NAME_PLATE_UNIT_ADDED" then
        ColorNameplate(unit)

    elseif event == "UNIT_TARGET" then
        if unit == "target" then
            UpdateTargetTarget()
        elseif unit == "focus" then
            UpdateFocusTarget()
        end
    end
end)