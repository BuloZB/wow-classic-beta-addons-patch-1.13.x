local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local Unknown = UNKNOWN

local ZoneColors = {
	["friendly"] = {0.1, 1.0, 0.1},
	["sanctuary"] = {0.41, 0.8, 0.94},
	["arena"] = {1.0, 0.1, 0.1},
	["hostile"] = {1.0, 0.1, 0.1},
	["contested"] = {1.0, 0.7, 0},
	["combat"] = {1.0, 0.1, 0.1},
	["else"] = {1.0, 0.9294, 0.7607}
}

local Update = function(self)
	local Text = GetMinimapZoneText()
	local PVPType = GetZonePVPInfo()
	local Color

	if ZoneColors[PVPType] then
		Color = ZoneColors[PVPType]
	else
		Color = ZoneColors["else"]
	end

	if (Text:len() > 18) then
		Text = strsub(Text, 1, 12) .. "..."
	end

	self.Text:SetText(Text)
	self.Text:SetTextColor(Color[1], Color[2], Color[3])
end

local OnEnter = function(self)
	if InCombatLockdown() then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()

	local Text = GetRealZoneText()
	local PVPType, IsSubZonePvP, FactionName = GetZonePVPInfo()
	local X, Y = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
	local XText, YText, Label, Location, Color

	if (not X) and (not Y) then
		X = 0
		Y = 0
	end

	if ZoneColors[PVPType] then
		Color = ZoneColors[PVPType]
	else
		Color = ZoneColors["else"]
	end

	X = floor(100 * X)
	Y = floor(100 * Y)

	if (X == 0 and Y == 0) then
		GameTooltip:AddLine("0, 0")
	else
		if (X < 10) then
			XText = "0"..X
		else
			XText = X
		end

		if (Y < 10) then
			YText = "0"..Y
		else
			YText = Y
		end
	end

	Location = format("%s |cffFFFFFF(%s, %s)|r", Text or Unknown, XText or 0, YText or 0)

	GameTooltip:AddLine(LOCATION_COLON)

	if (PVPType == "sanctuary") then
		Label = SANCTUARY_TERRITORY
	elseif (PVPType == "arena") then
		Label = FREE_FOR_ALL_TERRITORY
	elseif (PVPType == "friendly") then
		Label = format(FACTION_CONTROLLED_TERRITORY, FactionName)
	elseif (PVPType == "hostile") then
		Label = format(FACTION_CONTROLLED_TERRITORY, FactionName)
	elseif (PVPType == "contested") then
		Label = CONTESTED_TERRITORY
	elseif (PVPType == "combat") then
		Label = COMBAT_ZONE
	end

	GameTooltip:AddDoubleLine(Location, Label, Color[1], Color[2], Color[3], Color[1], Color[2], Color[3])

	GameTooltip:Show()
end

local OnLeave = function()
	GameTooltip:Hide()
end

local Enable = function(self)
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_INDOORS")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register(L.DataText.Zone, Enable, Disable, Update)
