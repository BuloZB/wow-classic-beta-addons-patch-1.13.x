local function SetDistance()
    if InCombatLockdown() then
        return C_Timer.After(5, SetDistance)
    end

    print("Distance set to:", NameplateDistanceDB.value)
    SetCVar("nameplateMaxDistance", NameplateDistanceDB.value)
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", function(self, event)
    NameplateDistanceDB = NameplateDistanceDB or { value = "80" }

    if GetCVar("nameplateMaxDistance") ~= NameplateDistanceDB.value then
        SetDistance()
    end

    self:UnregisterEvent("PLAYER_LOGIN")
end)

SLASH_NPDISTANCE1 = "/npdistance"
SlashCmdList["NPDISTANCE"] = function(msg)
    if not tonumber(msg) then
        return print("not a number.")
    end

    NameplateDistanceDB.value = msg
    SetDistance(msg)
 end
