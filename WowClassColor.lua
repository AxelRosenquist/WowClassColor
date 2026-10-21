
local hookedBars = {}


local function GetUnitColor(unit)
    local r, g, b

    if UnitIsPlayer(unit) then
        local _, classToken = UnitClass(unit)
        local color = classToken and RAID_CLASS_COLORS[classToken]

        if not color then
            return
        end

        r, g, b = color.r, color.g, color.b
    else
        r, g, b = UnitSelectionColor(unit)
    end
    return r, g, b
end


local function SetupClassColor(frame, unit)
    local healthBar = frame and frame.healthbar
    local nameText = frame and frame.name

    if not healthBar or not nameText then
        return
    end
    
    if not hookedBars[healthBar] then 
        local applyingColor = false

        local function ApplyColor(bar)
            if applyingColor or not UnitExists(unit) then
                return
            end

            local r, g, b = GetUnitColor(unit)            

            applyingColor = true
            bar:SetStatusBarDesaturated(true)
            bar:SetStatusBarColor(r, g, b)
            nameText:SetText(UnitName(unit))
            nameText:SetTextColor(r, g, b)
            applyingColor = false
        end

        hookedBars[healthBar] = ApplyColor
        hooksecurefunc(healthBar, "SetStatusBarColor", ApplyColor)
    end
        hookedBars[healthBar](healthBar)
end


local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_TARGET_CHANGED")

events:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        SetupClassColor(PlayerFrame, "player")
        self:UnregisterEvent("PLAYER_LOGIN")
    end
    
    SetupClassColor(TargetFrame, "target")
end)