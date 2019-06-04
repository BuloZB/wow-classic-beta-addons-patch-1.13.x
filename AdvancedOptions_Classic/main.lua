local PA_AO_currentVersion = 1.0

--Declare all functions used
local CreateFrame = CreateFrame

--PUI Dev Functions
local PUI_GenerateFrame = PUI_GenerateFrame        --PUI_GenerateFrame(name)
local PUI_RegisterPanel = PUI_RegisterPanel        --PUI_RegisterPanel(addonID, panelName, parentPanelName)
local PUI_RegisterSlider = PUI_RegisterSlider      --PUI_RegisterSlider(addonID, panelName, sliderID, description, toolTip, width, height, minValue, maxValue, stepValue, decimalPlaces, callback)
local PUI_RegisterCheckBox = PUI_RegisterCheckBox  --PUI_RegisterCheckBox(addonID, "My Addon", "checkboxidxyz", "Checkbox Label", "Stuff happens when you click this checkbox", 25, 25, nil)

local PUI_Round = PUI_Round                    --PUI_Round(num, numDecimalPlaces)
--Addon vars
local addonID = "advancedOptions" --This is required to use PUI Dev (addon ID can be anything, it just must be unique between addons)
local frame = PUI_GenerateFrame("advancedOptionsFrame")

local function AddonLoaded(name)
	if (name ~= "AdvancedOptions_Classic") then
		return
	end

	if (PA_AO_DB == nil) then
		PA_AO_DB = {}
		PA_AO_DB.version = PA_AO_currentVersion
		PA_AO_DB.cvars = {}
	end

	for k,v in pairs(PA_AO_DB.cvars) do
		SetCVar(k, v)
	end

	local panel = PUI_RegisterPanel(addonID, "Advanced Options")

	local function Slider_Callback(self, value)
		value = PUI_Round(value, self.decimalPlaces)
		self:SetText(self.description .. " [" .. value .. "]")
		self:SetValue(value)
		SetCVar(self.id, self:GetValue())
		PA_AO_DB.cvars[self.id] = self:GetValue()
	end

	PUI_RegisterSlider(addonID, "Advanced Options", "cameraDistanceMaxZoomFactor", "Camera Zoom Distance Factor", "Effects how far you can zoom out.", 200, 20, 1, 4, 0.1, 1, Slider_Callback)
	PUI_RegisterSlider(addonID, "Advanced Options", "nameplateMaxDistance", "Nameplate Distance", "Effects how far you can see name plates.", 200, 20, 20, 80, 1, 0, Slider_Callback)
	
	local function CheckBox_Callback(self)
		print("Checkbox: " .. self:GetName() .. " Value: " .. tostring(self:GetChecked()))
		SetCVar(self.id, self:GetChecked())
		PA_AO_DB.cvars[self.id] = self:GetChecked()
	end

	PUI_RegisterCheckBox(addonID, "Advanced Options", "ffxGlow", "Full Screen Glow Effect", "Enables/disables full screen glow effect", 20, 20, CheckBox_Callback)
	PUI_RegisterCheckBox(addonID, "Advanced Options", "rawMouseEnable", "Raw Mouse Input", "Enables/disables raw mouse input.", 20, 20, CheckBox_Callback)
	PUI_RegisterCheckBox(addonID, "Advanced Options", "rawMouseAccelerationEnable", "Raw Mouse Acceleration", "Enables/disables raw mouse acceleration.", 20, 20, CheckBox_Callback)
	PUI_RegisterCheckBox(addonID, "Advanced Options", "scriptErrors", "Show LUA Script Errors", "When disabled, you will no longer have script error popups.", 20, 20, CheckBox_Callback)
	PUI_RegisterCheckBox(addonID, "Advanced Options", "chatClassColorOverride", "Hide Chat Class Colors", "When disabled, player's names in chat will be colored based on their class.", 20, 20, CheckBox_Callback)
	PUI_RegisterCheckBox(addonID, "Advanced Options", "ShowClassColorInFriendlyNameplate", "Show Class Color in Friendly Nameplates [Requires /reload]", "When enabled, friendly nameplates will be filled in with the player's class color. Requires /reload for changes to take effect.", 20, 20, CheckBox_Callback)

	for k,v in pairs(panel.children) do
		if (PA_AO_DB.cvars[v.id] == nil) then
			PA_AO_DB.cvars[v.id] = GetCVar(v.id)
		end
	end

	for k,v in pairs(panel.children) do
		if (v.type == "CHECKBOX") then
			v:SetChecked(PA_AO_DB.cvars[v.id])
		end
		if (v.type == "SLIDER") then
			v:SetValue(PA_AO_DB.cvars[v.id])
			v:SetText(v.description .. " [" .. v:GetValue() .. "]")
		end
	end

	SLASH_AO1 = "/ao"
	SlashCmdList["AO"] = function(msg)
		InterfaceOptionsFrame_OpenToCategory("Advanced Options")
		InterfaceOptionsFrame_OpenToCategory("Advanced Options")
	end 

	print("Loaded |c0044DD88Advanced Options for Classic Version " .. PA_AO_currentVersion .. "|r by MinguasBeef. Type |c00CCCC55/ao|r to open up the options menu.")
end

frame:RegisterNewEvent("ADDON_LOADED", AddonLoaded)