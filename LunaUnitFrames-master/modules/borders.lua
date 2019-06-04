local Borders = {}
local goldColor, mouseColor = {r = 0.75, g = 0.75, b = 0.35}, {r = 0.75, g = 0.75, b = 0.50}
local rareColor, eliteColor = {r = 0, g = 0.63, b = 1}, {r = 1, g = 0.81, b = 0}

local canCure = LunaUF.Units.canCure
LunaUF:RegisterModule(Borders, "borders", LunaUF.L["Borders"])

local vex = LibStub("LibVexation-1.0", true)

local function BordersCallback(aggro, GUID, ...)
	for _,frame in pairs(LunaUF.Units.unitFrames) do
		if frame.unitGUID and frame.unitGUID == GUID then
			Borders:UpdateThreat(frame)
		end
	end
end
vex:RegisterCallback(BordersCallback)

local function OnEnter(frame)
	if( LunaUF.db.profile.units[frame.unitType].borders.mouseover ) then
		frame.borders.hasMouseover = true
		Borders:Update(frame)
	end
		
	frame.borders.OnEnter(frame)
end

local function OnLeave(frame)
	if( LunaUF.db.profile.units[frame.unitType].borders.mouseover ) then
		frame.borders.hasMouseover = nil
		Borders:Update(frame)
	end
		
	frame.borders.OnLeave(frame)
end

function Borders:OnEnable(frame)
	if( not frame.borders ) then
		frame.borders = CreateFrame("Frame", nil, frame)
		frame.borders:SetFrameLevel(frame.topFrameLevel)
		frame.borders:SetAllPoints(frame)
		frame.borders:SetSize(1, 1)
		
		frame.borders.top = frame.borders:CreateTexture(nil, "OVERLAY")
		frame.borders.top:SetBlendMode("ADD")
		frame.borders.top:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border")
		frame.borders.top:SetPoint("TOPLEFT", frame, 3, -3)
		frame.borders.top:SetPoint("TOPRIGHT", frame, -3, 3)
		frame.borders.top:SetHeight(30)
		frame.borders.top:SetTexCoord(0.3125, 0.625, 0, 0.3125)
		frame.borders.top:SetHorizTile(false)
		
		frame.borders.left = frame.borders:CreateTexture(nil, "OVERLAY")
		frame.borders.left:SetBlendMode("ADD")
		frame.borders.left:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border")
		frame.borders.left:SetPoint("TOPLEFT", frame, 3, -3)
		frame.borders.left:SetPoint("BOTTOMLEFT", frame, -3, 3)
		frame.borders.left:SetWidth(30)
		frame.borders.left:SetTexCoord(0, 0.3125, 0.3125, 0.625)
		frame.borders.left:SetHorizTile(false)

		frame.borders.right = frame.borders:CreateTexture(nil, "OVERLAY")
		frame.borders.right:SetBlendMode("ADD")
		frame.borders.right:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border")
		frame.borders.right:SetPoint("TOPRIGHT", frame, -3, -3)
		frame.borders.right:SetPoint("BOTTOMRIGHT", frame, 0, 3)
		frame.borders.right:SetWidth(30)
		frame.borders.right:SetTexCoord(0.625, 0.93, 0.3125, 0.625)
		frame.borders.right:SetHorizTile(false)

		frame.borders.bottom = frame.borders:CreateTexture(nil, "OVERLAY")
		frame.borders.bottom:SetBlendMode("ADD")
		frame.borders.bottom:SetTexture("Interface\\AddOns\\LunaUnitFrames\\media\\textures\\borders\\border")
		frame.borders.bottom:SetPoint("BOTTOMLEFT", frame, 3, 3)
		frame.borders.bottom:SetPoint("BOTTOMRIGHT", frame, -3, 3)
		frame.borders.bottom:SetHeight(30)
		frame.borders.bottom:SetTexCoord(0.3125, 0.625, 0.625, 0.93)
		frame.borders.bottom:SetHorizTile(false)
		frame.borders:Hide()
	end
	
	frame.borders.top:SetHeight(10)
	frame.borders.bottom:SetHeight(10)
	frame.borders.left:SetWidth(10)
	frame.borders.right:SetWidth(10)
	
	
	if( LunaUF.db.profile.units[frame.unitType].borders.aggro ) then
		frame:RegisterUpdateFunc(self, "UpdateThreat")
	end
	
	if( LunaUF.db.profile.units[frame.unitType].borders.target and frame.unitType ~= "target" ) then
		frame:RegisterNormalEvent("PLAYER_TARGET_CHANGED", self, "UpdateAttention")
		frame:RegisterUpdateFunc(self, "UpdateAttention")
	end

	if( LunaUF.db.profile.units[frame.unitType].borders.debuff ~= false ) then
		frame:RegisterUnitEvent("UNIT_AURA", self, "UpdateAura")
		frame:RegisterUpdateFunc(self, "UpdateAura")
	end

	if( LunaUF.db.profile.units[frame.unitType].borders.mouseover and not frame.borders.OnEnter ) then
		frame.borders.OnEnter = frame.OnEnter
		frame.borders.OnLeave = frame.OnLeave
		
		frame.OnEnter = OnEnter
		frame.OnLeave = OnLeave
	end

	if( LunaUF.db.profile.units[frame.unitType].borders.rareMob or LunaUF.db.profile.units[frame.unitType].borders.eliteMob ) then
		frame:RegisterUnitEvent("UNIT_CLASSIFICATION_CHANGED", self, "UpdateClassification")
		frame:RegisterUpdateFunc(self, "UpdateClassification")
	end
end

function Borders:OnLayoutApplied(frame)
	if( frame.visibility.borders ) then
		self:OnDisable(frame)
		self:OnEnable(frame)
	end
end

function Borders:OnDisable(frame)
	frame:UnregisterAll(self)
	
	frame.borders.hasDebuff = nil
	frame.borders.hasThreat = nil
	frame.borders.hasAttention = nil
	frame.borders.hasMouseover = nil

	frame.borders:Hide()

	if( frame.borders.OnEnter ) then
		frame.OnEnter = frame.borders.OnEnter
		frame.OnLeave = frame.borders.OnLeave

		frame.borders.OnEnter = nil
		frame.borders.OnLeave = nil
	end
end

function Borders:Update(frame)
	local color
	if( frame.borders.hasDebuff ) then
		color = DebuffTypeColor[frame.borders.hasDebuff] or DebuffTypeColor[""]
	elseif( frame.borders.hasThreat ) then
		color = LunaUF.db.profile.colors.hostile
	elseif( frame.borders.hasAttention ) then
		color = goldColor
	elseif( frame.borders.hasMouseover ) then
		color = mouseColor
	elseif( LunaUF.db.profile.units[frame.unitType].borders.rareMob and ( frame.borders.hasClassification == "rareelite" or frame.borders.hasClassification == "rare" ) ) then
		color = rareColor
	elseif( LunaUF.db.profile.units[frame.unitType].borders.eliteMob and frame.borders.hasClassification == "elite" ) then
		color = eliteColor
	end

	if( color ) then
		frame.borders.top:SetVertexColor(color.r, color.g, color.b, 0.6)
		frame.borders.left:SetVertexColor(color.r, color.g, color.b, 0.6)
		frame.borders.bottom:SetVertexColor(color.r, color.g, color.b, 0.6)
		frame.borders.right:SetVertexColor(color.r, color.g, color.b, 0.6)
		frame.borders:Show()
	else
		frame.borders:Hide()
	end
end

function Borders:UpdateThreat(frame)
	frame.borders.hasThreat = LunaUF.db.profile.units[frame.unitType].borders.aggro and vex:GetUnitAggroByUnitGUID(frame.unitGUID)
	self:Update(frame)
end

function Borders:UpdateAttention(frame)
	frame.borders.hasAttention = UnitIsUnit(frame.unit, "target") or nil
	self:Update(frame)
end

function Borders:UpdateClassification(frame)
	frame.borders.hasClassification = UnitClassification(frame.unit)
	self:Update(frame)
end

function Borders:UpdateAura(frame)
	frame.borders.hasDebuff = nil
	local showAll = LunaUF.db.profile.units[frame.unitType].borders.debuff == true
	if( UnitIsFriend(frame.unit, "player") ) then
		local id = 0
		while( true ) do
			id = id + 1
			local name, _, _, auraType = UnitDebuff(frame.unit, id)
			if( not name ) then break end
			
			if( canCure[auraType] or (showAll and auraType) ) then
				frame.borders.hasDebuff = auraType
				break
			end
		end
	end

	self:Update(frame)
end
