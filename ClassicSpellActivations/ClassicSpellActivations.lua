local addonName, ns = ...

local f = CreateFrame("Frame", nil) --, UIParent)

f:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)

local UnitGUID = UnitGUID
local bit_band = bit.band
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local _, class = UnitClass("player")

local procCombatLog
local registeredFrames = {}
local activations = {}


local spellNamesByID = {
    [7384] = "Overpower",
    [7887] = "Overpower",
    [11584] = "Overpower",
    [11585] = "Overpower",

    [6572] = "Revenge",
    [6574] = "Revenge",
    [7379] = "Revenge",
    [11600] = "Revenge",
    [11601] = "Revenge",
    [25288] = "Revenge",

    [14251] = "Riposte",

    [19306] = "Counterattack",
    [20909] = "Counterattack",
    [20910] = "Counterattack",

    [20662] = "Execute",
    [20661] = "Execute",
    [20660] = "Execute",
    [20658] = "Execute",
    [5308] = "Execute",
}

f:RegisterEvent("PLAYER_LOGIN")
function f:PLAYER_LOGIN()
    
    if class == "WARRIOR" or class == "ROGUE" or class == "HUNTER" then
        self:RegisterEvent("SPELLS_CHANGED")
        self:SPELLS_CHANGED()

        local bars = {"ActionButton","MultiBarBottomLeftButton","MultiBarBottomRightButton","MultiBarLeftButton","MultiBarRightButton"}
        for _,bar in ipairs(bars) do
            for i = 1,12 do
                local btn = _G[bar..i]
                self:RegisterForActivations(btn)
            end
        end

        hooksecurefunc("ActionButton_UpdateOverlayGlow", function(self)
            ns.UpdateOverlayGlow(self)
        end)
    end
    -- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    

end

function f:SPELLS_CHANGED()
    if class == "WARRIOR" then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:SetScript("OnUpdate", self.timerOnUpdate)
        if ns.findHighestRank("Overpower") and ns.findHighestRank("Revenge") then
            local CheckOverpower = ns.CheckOverpower
            local CheckRevenge = ns.CheckRevenge
            procCombatLog = function(...)
                CheckOverpower(...)
                CheckRevenge(...)
            end
        elseif ns.findHighestRank("Overpower") then
            procCombatLog = ns.CheckOverpower
        elseif ns.findHighestRank("Revenge") then
            procCombatLog = ns.CheckRevenge
        else
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            self:SetScript("OnUpdate", nil)
        end

        if ns.findHighestRank("Execute") then
            self:RegisterEvent("PLAYER_TARGET_CHANGED")
            self:RegisterUnitEvent("UNIT_HEALTH", "target")
        else
            self:UnregisterEvent("PLAYER_TARGET_CHANGED")
            self:UnregisterEvent("UNIT_HEALTH")
        end
    elseif class == "ROGUE" then
        if ns.findHighestRank("Riposte") then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            procCombatLog = ns.CheckRiposte
            self:SetScript("OnUpdate", self.timerOnUpdate)
        end
    elseif class == "HUNTER" then
        if ns.findHighestRank("Counterattack") then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            procCombatLog = ns.CheckCounterattack
            self:SetScript("OnUpdate", self.timerOnUpdate)
        end
    end
end

function f:RegisterForActivations(frame)
    registeredFrames[frame] = true
    -- registeredFrames:GetScript("OnEvent")
end
local function IsSpellOverlayed(spellID)
    local spellName = spellNamesByID[spellID]
    if not spellName then return false end
    local state = activations[spellName]
    if state then return state.active end
end

local GetActionInfo = _G.GetActionInfo
local GetMacroSpell = _G.GetMacroSpell
local ActionButton_ShowOverlayGlow = _G.ActionButton_ShowOverlayGlow
local ActionButton_HideOverlayGlow = _G.ActionButton_HideOverlayGlow
function ns.UpdateOverlayGlow(self)
    local spellType, id, subType  = GetActionInfo(self.action);
	if ( spellType == "spell" and IsSpellOverlayed(id) ) then
		ActionButton_ShowOverlayGlow(self);
	elseif ( spellType == "macro" ) then
		local spellId = GetMacroSpell(id);
		if ( spellId and IsSpellOverlayed(spellId) ) then
			ActionButton_ShowOverlayGlow(self);
		else
			ActionButton_HideOverlayGlow(self);
		end
	else
		ActionButton_HideOverlayGlow(self);
	end
end

function f:FanoutEvent(event, ...)
    for frame, _ in pairs(registeredFrames) do
        local eventHandler = frame:GetScript("OnEvent")
        eventHandler(frame, event, ...)
    end
end

local reverseSpellRanks = {
    Overpower = { 11585, 11584, 7887, 7384 },
    Revenge = { 25288, 11601, 11600, 7379, 6574, 6572 },
    Riposte = { 14251 },
    Counterattack = { 20910, 20909, 19306 },
    Execute = { 20662, 20661, 20660, 20658, 5308 }
}
function ns.findHighestRank(spellName)
    for _, spellID in ipairs(reverseSpellRanks[spellName]) do
        if IsPlayerSpell(spellID) then return spellID end
    end
end
local findHighestRank = ns.findHighestRank

function f:Activate(spellName, duration)
    local state = activations[spellName]
    if not state then
        activations[spellName] = {}
        state = activations[spellName]
    end
    if not state.active then
        state.active = true
        state.expirationTime = duration and GetTime() + duration

        local highestRankSpellID = findHighestRank(spellName)
        self:FanoutEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", highestRankSpellID)
    else
        state.expirationTime = duration and GetTime() + duration
    end
end
function f:Deactivate(spellName)
    local state = activations[spellName]
    if state and state.active == true then
        state.active = false
        state.expirationTime = nil

        local highestRankSpellID = findHighestRank(spellName)
        self:FanoutEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", highestRankSpellID)
    end
end
function f.timerOnUpdate(self, elapsed)
    local now = GetTime()
    for spellName, state in pairs(activations) do
        if state.expirationTime and now >= state.expirationTime then
            f:Deactivate(spellName)
        end
    end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(self, event)
    local timestamp, eventType, hideCaster,
    srcGUID, srcName, srcFlags, srcFlags2,
    dstGUID, dstName, dstFlags, dstFlags2,
    arg1, arg2, arg3, arg4, arg5 = CombatLogGetCurrentEventInfo()

    local isSrcPlayer = bit_band(srcFlags, AFFILIATION_MINE) == AFFILIATION_MINE
    local isDstPlayer = dstGUID == UnitGUID("player")

    procCombatLog(eventType, isSrcPlayer, isDstPlayer, arg1, arg2, arg3, arg4, arg5)
end

-----------------
-- WARRIOR
-----------------

function f:UNIT_HEALTH(event, unit)
    if UnitExists("target") then
        local h = UnitHealth("target")
        local hm = UnitHealthMax("target")
        if h > 0 and h/hm <= 0.2 then
            f:Activate("Execute", 10)
        else
            f:Deactivate("Execute")
        end
    else
        f:Deactivate("Execute")
    end
end
f.PLAYER_TARGET_CHANGED = f.UNIT_HEALTH

function ns.CheckOverpower(eventType, isSrcPlayer, isDstPlayer, ...)
    if isSrcPlayer then
        if eventType == "SWING_MISSED" or eventType == "SPELL_MISSED" then
            local missedType
            if eventType == "SWING_MISSED" then
                missedType = select(1, ...)
            elseif eventType == "SPELL_MISSED" then
                missedType = select(4, ...)
            end
            if missedType == "DODGE" then
                f:Activate("Overpower", 5)
            end

        end

        if eventType == "SPELL_CAST_SUCCESS" then
            local spellID = select(1, ...)
            if spellNamesByID[spellID] == "Overpower" then
                f:Deactivate("Overpower")
            end
        end
    end
end

function ns.CheckRevenge(eventType, isSrcPlayer, isDstPlayer, ...)
    if isDstPlayer then
        if eventType == "SWING_MISSED" or eventType == "SPELL_MISSED" then
            local missedType
            if eventType == "SWING_MISSED" then
                missedType = select(1, ...)
            elseif eventType == "SPELL_MISSED" then
                missedType = select(4, ...)
            end
            if missedType == "BLOCK" or missedType == "DODGE" or missedType == "PARRY" then
                f:Activate("Revenge", 5)
            end
        end
        if eventType == "SWING_DAMAGE" then
            local blocked = select(5, ...)
            if blocked then
                f:Activate("Revenge", 5)
            end
        end
    end

    if isSrcPlayer and eventType == "SPELL_CAST_SUCCESS" then
        local spellID = select(1, ...)
        if spellNamesByID[spellID] == "Revenge" then
            f:Deactivate("Revenge")
        end
    end
end

-----------------
-- ROGUE
-----------------

function ns.CheckRiposte(eventType, isSrcPlayer, isDstPlayer, ...)
    if isDstPlayer then
        if eventType == "SWING_MISSED" or eventType == "SPELL_MISSED" then
            local missedType
            if eventType == "SWING_MISSED" then
                missedType = select(1, ...)
            elseif eventType == "SPELL_MISSED" then
                missedType = select(4, ...)
            end
            if missedType == "PARRY" then
                f:Activate("Riposte", 5)
            end
        end
    end

    if isSrcPlayer and eventType == "SPELL_CAST_SUCCESS" then
        local spellID = select(1, ...)
        if spellNamesByID[spellID] == "Riposte" then -- Riposte
            f:Deactivate("Riposte")
        end
    end
end

-----------------
-- HUNTER
-----------------

function ns.CheckCounterattack(eventType, isSrcPlayer, isDstPlayer, ...)
    if isDstPlayer then
        if eventType == "SWING_MISSED" or eventType == "SPELL_MISSED" then
            local missedType
            if eventType == "SWING_MISSED" then
                missedType = select(1, ...)
            elseif eventType == "SPELL_MISSED" then
                missedType = select(4, ...)
            end
            if missedType == "PARRY" then
                f:Activate("Counterattack", 5)
            end
        end
    end

    if isSrcPlayer and eventType == "SPELL_CAST_SUCCESS" then
        local spellID = select(1, ...)
        if spellNamesByID[spellID] == "Counterattack" then
            f:Deactivate("Counterattack", 5)
        end
    end
end
