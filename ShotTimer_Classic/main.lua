local currentVersion = 0.2

print("Loaded |c0044DD88Shot Timer for Classic Version " .. currentVersion .. "|r by MinguasBeef. Type |c00CCCC55/st|r for more options.")

--Declare all functions used
local CreateFrame = CreateFrame
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetHaste = GetHaste

--Addon vars
local PA_SHT_frame = CreateFrame("Frame", nil, UIParent)
local PA_SHT_events = {}
local PA_SHT_playerGUID = UnitGUID("player")
local PA_SHT_aimShotBar = CreateFrame("StatusBar", nil, PA_SHT_frame)

local PA_SHT_cooldownBar = CreateFrame("StatusBar", nil, PA_SHT_frame)
local PA_SHT_autoShotCastBar = CreateFrame("StatusBar", nil, PA_SHT_frame)
local PA_SHT_backgroundBar = CreateFrame("StatusBar", nil, PA_SHT_frame)
local PA_SHT_initialized = false

local PA_SHT_reloadPercentRemaining = 100
local PA_SHT_shootPercentRemaining = 100
local PA_SHT_aimShotPercentRemaining = 100
local PA_SHT_isShooting = false
local PA_SHT_isAimShotting = false

SLASH_SHT1 = "/st"
SlashCmdList["SHT"] = function(msg)
	InterfaceOptionsFrame_OpenToCategory("Shot Timer")
	InterfaceOptionsFrame_OpenToCategory("Shot Timer")
end 


local PA_SHT_dt = 0
function PA_SHT_OnUpdate(elapsed)
	PA_SHT_dt = PA_SHT_dt + elapsed
	if (PA_SHT_dt > 0.02) then
		
		local rangedAttackSpeed = UnitRangedDamage("player")
		local reloadSpeed = rangedAttackSpeed - 0.5
		
		if (PA_SHT_reloadPercentRemaining > 0) then
			local subtractionPercent = (PA_SHT_dt * 100) / reloadSpeed
			PA_SHT_reloadPercentRemaining = PA_SHT_reloadPercentRemaining - subtractionPercent
			if (PA_SHT_reloadPercentRemaining < 0) then
				PA_SHT_reloadPercentRemaining = 0
			end
			PA_SHT_cooldownBar:SetValue(100 - PA_SHT_reloadPercentRemaining)
		end
		
		if (PA_SHT_shootPercentRemaining > 0) then
			if (PA_SHT_isShooting == true) then
				local subtractionPercent = (PA_SHT_dt * 100) / 0.5
				PA_SHT_shootPercentRemaining = PA_SHT_shootPercentRemaining - subtractionPercent
				if (PA_SHT_shootPercentRemaining < 0) then
					PA_SHT_shootPercentRemaining = 0
				end
			end
			PA_SHT_autoShotCastBar:SetValue(100 - PA_SHT_shootPercentRemaining)
		end
		
		if (PA_SHT_aimShotPercentRemaining > 0) then
			if (PA_SHT_isAimShotting == true) then
				local aimShotCastTime = select(4,GetSpellInfo("Aimed Shot")) / 1000 + 0.5
				local subtractionPercent = (PA_SHT_dt * 100) / aimShotCastTime
				PA_SHT_aimShotPercentRemaining = PA_SHT_aimShotPercentRemaining - subtractionPercent
				if (PA_SHT_aimShotPercentRemaining < 0) then
					PA_SHT_aimShotPercentRemaining = 0
				end
			end
			PA_SHT_aimShotBar:SetValue(100 - PA_SHT_aimShotPercentRemaining)
		end
		
		PA_SHT_dt = 0
	end
	
end


local timeFromLastShot = GetTime()
local timeFromStartShoot = GetTime()
function PA_SHT_COMBAT_LOG_EVENT_UNFILTERED(...)
	--eventInfo = {CombatLogGetCurrentEventInfo() }
	timeStamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, x3, x4, x5 = CombatLogGetCurrentEventInfo()
	if (sourceName == nil) then
		return
	end
	
	if (sourceGUID == PA_SHT_playerGUID) then
		if (event == "SPELL_CAST_START") then
			if (spellID == 75) then --autoshot
				PA_SHT_shootPercentRemaining = 100
				PA_SHT_isShooting = true
				return
			end
			if (spellName == "Aimed Shot") then
				PA_SHT_aimShotActualTime = GetTime()
				PA_SHT_aimShotPercentRemaining = 100
				PA_SHT_isAimShotting = true
				return
			end
		end
		
		if (event == "SPELL_CAST_FAILED") then
			if (spellID == 75) then
				PA_SHT_shootPercentRemaining = 100
				PA_SHT_isShooting = false
				return
			end
			if (spellName == "Aimed Shot") then
				PA_SHT_aimShotPercentRemaining = 100
				PA_SHT_isAimShotting = false
				return
			end
		end
		
		if (event == "SPELL_CAST_SUCCESS") then
			if (spellID == 75) then --Auto Shot
				PA_SHT_isShooting = false
				PA_SHT_shootPercentRemaining = 100
				PA_SHT_reloadPercentRemaining = 100
				
				return
			end
			if (spellName == "Aimed Shot") then
				PA_SHT_aimShotPercentRemaining = 100
				PA_SHT_isAimShotting = false
				return
			end
			--print(sourceName .. " - " .. event .. " - ")
		end
	end
end

local function InitializeDefaultDBValues()
	print("A new version of |c0044DD88Shot Timer for Classic|r was found and the variables had to be reset.")
	PA_SHT_DB = {}
	PA_SHT_DB.version = currentVersion
end	

function PA_UI_RegisterPanel(panelName, parentPanelName)
	if (parentPanelName == nil) then
		_G["PA_UI_PANEL_" .. panelName] = CreateFrame( "Frame", panelName, UIParent );
	else
		_G["PA_UI_PANEL_" .. panelName] = CreateFrame( "Frame", panelName, _G["PA_UI_PANEL_" .. parentPanelName] );
		_G["PA_UI_PANEL_" .. panelName].parent = _G["PA_UI_PANEL_" .. parentPanelName].name
	end
	_G["PA_UI_PANEL_" .. panelName].name = panelName
	InterfaceOptions_AddCategory(_G["PA_UI_PANEL_" .. panelName]);
	_G["PA_UI_PANEL_" .. panelName].lastWidget = nil
end

local function UpdateCheckButton(checkbutton)
	_G[checkbutton:GetName() .. 'Text']:SetText(checkbutton.Description .. " [" .. tostring(checkbutton:GetChecked()) .. "]");
	local identifier = checkbutton.var
	if (identifier == "EnableMouse") then
		PA_SHT_frame:EnableMouse(checkbutton:GetChecked())
	end
	
	PA_SHT_DB.vars[checkbutton.var] = checkbutton:GetChecked()
end

local function PA_UI_RegisterCheckButton(panelName, identifier, description, toolTip, width, height)
	if (PA_SHT_DB.vars ~= nil) then
		if (PA_SHT_DB.vars[identifier] ~= nil) then
			defaultValue = PA_SHT_DB.vars[identifier]
		end
	end
	
	_G["PA_UI_CHECKBOX_" .. identifier] = CreateFrame("CheckButton", "PA_UI_CHECKBOXID_" .. identifier, _G["PA_UI_PANEL_" .. panelName], "ChatConfigCheckButtonTemplate")
	_G["PA_UI_CHECKBOX_" .. identifier]:SetWidth(width)
	_G["PA_UI_CHECKBOX_" .. identifier]:SetHeight(height)
	_G["PA_UI_CHECKBOX_" .. identifier].tooltipText = toolTip --Creates a tooltip on mouseover.
	_G["PA_UI_CHECKBOX_" .. identifier]:SetChecked(defaultValue)
	_G["PA_UI_CHECKBOX_" .. identifier]:Show()
	_G["PA_UI_CHECKBOX_" .. identifier]:SetPoint("CENTER")
	_G["PA_UI_CHECKBOX_" .. identifier].Description = description
	_G["PA_UI_CHECKBOX_" .. identifier].var = identifier
	
	_G[_G["PA_UI_CHECKBOX_" .. identifier]:GetName() .. 'Text']:SetText(description);
	
	
	if (_G["PA_UI_PANEL_" .. panelName].lastWidget == nil) then
		_G["PA_UI_CHECKBOX_" .. identifier]:SetPoint("TOPLEFT", _G["PA_UI_PANEL_" .. panelName], "TOPLEFT", 25, -20)
	else
		_G["PA_UI_CHECKBOX_" .. identifier]:SetPoint("BOTTOMLEFT", _G["PA_UI_PANEL_" .. panelName].lastWidget, "BOTTOMLEFT", 0, -35)
	end
	_G["PA_UI_PANEL_" .. panelName].lastWidget = _G["PA_UI_CHECKBOX_" .. identifier]
	
	_G["PA_UI_CHECKBOX_" .. identifier]:SetScript("OnClick", function(self) UpdateCheckButton(self) end)
end


local function PA_SHT_ReloadSavedVars()
	PA_SHT_frame:EnableMouse(_G["PA_UI_CHECKBOX_" .. "EnableMouse"]:GetChecked())
end

function PA_SHT_PLAYER_ENTERING_WORLD()
	if (PA_SHT_initialized == false) then
		PA_SHT_initialized = true
		
		if (PA_SHT_DB == nil) then
			InitializeDefaultDBValues()
		else
			if (PA_SHT_DB.version ~= currentVersion) then
				InitializeDefaultDBValues()
			end
		end
		
		if (PA_SHT_DB.vars == nil) then
			PA_SHT_DB.vars = {}
		end
		
		PA_UI_RegisterPanel("Shot Timer", nil)
		PA_UI_RegisterCheckButton("Shot Timer", "EnableMouse", "Enable shot bar dragging.", "Allows user to drag shot bar with mouse.", 20, 20)

		
		PA_SHT_ReloadSavedVars()
		
		PA_SHT_frame:SetMovable(true)
		PA_SHT_frame:RegisterForDrag("LeftButton")
		
		
		PA_SHT_frame:SetScript("OnDragStart", function(self)
			if not self.isMoving then
				self:StartMoving();
				self.isMoving = true;
			end
		end)
		PA_SHT_frame:SetScript("OnDragStop", function(self)
			if self.isMoving then
				self:StopMovingOrSizing();
				self.isMoving = false;
				PA_SHT_DB.frameXOffset = PA_SHT_frame:GetLeft()
				PA_SHT_DB.frameYOffset = PA_SHT_frame:GetBottom()
			end
		end)
		
		if (PA_SHT_DB.frameXOffset ~= nil and PA_SHT_DB.frameYOffset ~= nil) then
			PA_SHT_frame:SetPoint("BOTTOMLEFT", PA_SHT_DB.frameXOffset, PA_SHT_DB.frameYOffset)
		else
			PA_SHT_frame:SetPoint("CENTER")
		end
		PA_SHT_frame:SetWidth(200)
		PA_SHT_frame:SetHeight(20)		
		
		local autoShotCastTime = 0.5
		local weaponSpeed = UnitRangedDamage("player")
		local weaponReloadTime = weaponSpeed - autoShotCastTime
		
		local reloadRatio = (weaponReloadTime) / (weaponReloadTime + autoShotCastTime)
		local autoShotCastRatio = (autoShotCastTime) / (weaponReloadTime + autoShotCastTime)
		
		PA_SHT_aimShotBar:SetPoint("TOPLEFT", PA_SHT_frame, "TOPLEFT", 0, 0)
		PA_SHT_aimShotBar:SetWidth(200)
		PA_SHT_aimShotBar:SetHeight(20)
		PA_SHT_aimShotBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		PA_SHT_aimShotBar:GetStatusBarTexture():SetHorizTile(false)
		PA_SHT_aimShotBar:GetStatusBarTexture():SetVertTile(false)
		PA_SHT_aimShotBar:SetMinMaxValues(0, 100)
		PA_SHT_aimShotBar:SetValue(0)
		PA_SHT_aimShotBar:SetStatusBarColor(0.7, 0.7, 0.1, 0.75)
		
		PA_SHT_cooldownBar:SetPoint("TOPLEFT", PA_SHT_frame, "TOPLEFT", 0, 0)
		PA_SHT_cooldownBar:SetWidth(200 * reloadRatio)
		PA_SHT_cooldownBar:SetHeight(20)
		PA_SHT_cooldownBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		PA_SHT_cooldownBar:GetStatusBarTexture():SetHorizTile(false)
		PA_SHT_cooldownBar:GetStatusBarTexture():SetVertTile(false)
		PA_SHT_cooldownBar:SetMinMaxValues(0, 100)
		PA_SHT_cooldownBar:SetValue(0)
		PA_SHT_cooldownBar:SetStatusBarColor(0, 0.55, 0)
		
		PA_SHT_autoShotCastBar:SetPoint("TOPLEFT", PA_SHT_cooldownBar, "TOPRIGHT", 0, 0)
		PA_SHT_autoShotCastBar:SetWidth(200 * autoShotCastRatio)
		PA_SHT_autoShotCastBar:SetHeight(20)
		PA_SHT_autoShotCastBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		PA_SHT_autoShotCastBar:GetStatusBarTexture():SetHorizTile(false)
		PA_SHT_autoShotCastBar:GetStatusBarTexture():SetVertTile(false)
		PA_SHT_autoShotCastBar:SetMinMaxValues(0, 100)
		PA_SHT_autoShotCastBar:SetValue(0)
		PA_SHT_autoShotCastBar:SetStatusBarColor(0.15, 0.85, 0.15)
		
		PA_SHT_backgroundBar:SetPoint("TOPLEFT", PA_SHT_frame, "TOPLEFT", 0, 0)
		PA_SHT_backgroundBar:SetWidth(200)
		PA_SHT_backgroundBar:SetHeight(20)
		PA_SHT_backgroundBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
		PA_SHT_backgroundBar:SetMinMaxValues(0, 100)
		PA_SHT_backgroundBar:SetValue(100)
		PA_SHT_backgroundBar:SetStatusBarColor(0.2, 0.2, 0.2, 0.5)
		
	end
end

function PA_SHT_frame:RegisterNewEvent(eventname, eventfunction)
	PA_SHT_events[eventname] = eventfunction
	PA_SHT_frame:RegisterEvent(eventname)
end

PA_SHT_frame:RegisterNewEvent("COMBAT_LOG_EVENT_UNFILTERED", PA_SHT_COMBAT_LOG_EVENT_UNFILTERED)
PA_SHT_frame:RegisterNewEvent("PLAYER_ENTERING_WORLD", PA_SHT_PLAYER_ENTERING_WORLD)

PA_SHT_frame:SetScript("OnEvent", function(self, event, ...)
	if not PA_SHT_events[event] then
		return
	end
	
	PA_SHT_events[event](...)
end)

PA_SHT_frame:SetScript("OnUpdate", function(self, elapsed) PA_SHT_OnUpdate(elapsed) end)
