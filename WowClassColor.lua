local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")

events:SetScript("OnEvent", function(self)
    local healthBar = PlayerFrame and PlayerFrame.healthbar
    
    if not healthBar then
        print("WowClassColor: Could not find player healthbar")
        return
    end
    
    healthBar:SetStatusBarDesaturated(true)
    local applyingColor = false
    local unit = PlayerFrame.unit
    local className, classToken = UnitClass(unit)
    local color = RAID_CLASS_COLORS[classToken]

    local function ApplyColor(bar)
        if applyingColor then
            return
        end
        applyingColor = true
        bar:SetStatusBarColor(color.r, color.g, color.b )
        applyingColor = false
    end
    
    hooksecurefunc(healthBar, "SetStatusBarColor", ApplyColor)
    ApplyColor(healthBar)
    self:UnregisterEvent("PLAYER_LOGIN")
end)
