PWRAddonName, PWRAddonTitle, PWRAddonNotes = GetAddOnInfo("Powered")
PWRTexturesPath = "Interface\\AddOns\\" .. PWRAddonName .. "\\skins\\"
PWRBordersPath = "Interface\\UNITPOWERBARALT\\"
PWRDebug = false

PWRBorderChoices = {
	{ Label = "Default", Value = 				PWRBordersPath .. "WowUI_Horizontal_Frame" },
	{ Label = "Air", Value = 					PWRBordersPath .. "Air_Horizontal_Frame" },
	{ Label = "Fire", Value = 					PWRBordersPath .. "Fire_Horizontal_Frame" },
	{ Label = "Ice", Value = 					PWRBordersPath .. "Ice_Horizontal_Frame" },
	{ Label = "Water", Value = 					PWRBordersPath .. "Water_Horizontal_Frame" },
	{ Label = "Alliance", Value = 				PWRBordersPath .. "Alliance_Horizontal_Frame" },
	{ Label = "Horde", Value = 					PWRBordersPath .. "Horde_Horizontal_Frame" },
	{ Label = "Meat", Value = 					PWRBordersPath .. "Meat_Horizontal_Frame" },
	{ Label = "Meat (Undead)", Value = 			PWRBordersPath .. "UndeadMeat_Horizontal_Frame" },
	{ Label = "Stone (Diamond)", Value = 		PWRBordersPath .. "StoneDiamond_Horizontal_Frame" },
	{ Label = "Stone (Tan)", Value = 			PWRBordersPath .. "StoneTan_Horizontal_Frame" },
	{ Label = "Stone (Design)", Value = 		PWRBordersPath .. "StoneDesign_Horizontal_Frame" },
	{ Label = "Rock", Value = 					PWRBordersPath .. "Rock_Horizontal_Frame" },
	{ Label = "Rock (Molten)", Value = 			PWRBordersPath .. "MoltenRock_Horizontal_Frame" },
	{ Label = "Onyxia", Value = 				PWRBordersPath .. "Onyxia_Horizontal_Frame" },
	{ Label = "Chogall", Value = 				PWRBordersPath .. "Chogall_Horizontal_Frame" },
	{ Label = "Mechanical", Value = 			PWRBordersPath .. "Mechanical_Horizontal_Frame" },
	{ Label = "Metal", Value = 					PWRBordersPath .. "MetalPlain_Horizontal_Frame" },
	{ Label = "Metal (Bronze)", Value = 		PWRBordersPath .. "MetalBronze_Horizontal_Frame" },
	{ Label = "Metal (Eternium)", Value = 		PWRBordersPath .. "MetalEternium_Horizontal_Frame" },
	{ Label = "Metal (Gold)", Value = 			PWRBordersPath .. "MetalGold_Horizontal_Frame" },
	{ Label = "Metal (Rusted)", Value = 		PWRBordersPath .. "MetalRusted_Horizontal_Frame" },
	{ Label = "Wood Boards", Value = 			PWRBordersPath .. "WoodBoards_Horizontal_Frame" },
	{ Label = "Wood Plank", Value = 			PWRBordersPath .. "WoodPlank_Horizontal_Frame" },
	{ Label = "Wood Vertical", Value = 			PWRBordersPath .. "WoodVerticalPlanks_Horizontal_Frame" },
	{ Label = "Wood With Metal", Value = 		PWRBordersPath .. "WoodWithMetal_Horizontal_Frame" },
	{ Label = "Inquisition", Value = 			PWRBordersPath .. "InquisitionTorment_Horizontal_Frame" },
	
	-- THOSE BORDERS WON'T WORK WELL FOR NOW
	--{ Label = "Azerite", Value = 				PWRBordersPath .. "Azerite_Horizontal_Bgnd" },
	--{ Label = "Xavius", Value = 				PWRBordersPath .. "Xavius_Horizontal_Bgnd" },
	--{ Label = "Fel Corruption (Red)", Value = 	PWRBordersPath .. "FelCorruptionRed_Horizontal_Bgnd" },
	--{ Label = "Twin Ogron", Value = 			PWRBordersPath .. "TwinOgronDistance_Horizontal_Bgnd" },
	--{ Label = "Naaru Charge", Value = 			PWRBordersPath .. "NaaruCharge_Horizontal_Bgnd" },
	--{ Label = "Fel Breaker", Value = 			PWRBordersPath .. "FelBreakerCaptainShield_Horizontal_Bgnd" },
	--{ Label = "Kargath", Value = 				PWRBordersPath .. "KargathRoarCrowd_Horizontal_Bgnd" },
	--{ Label = "Pride", Value = 					PWRBordersPath .. "Pride_Horizontal_Bgnd" },
	--{ Label = "Garrosh", Value = 				PWRBordersPath .. "GarroshEnergy_Horizontal_Bgnd" },
	--{ Label = "Sha Water", Value = 				PWRBordersPath .. "ShaWater_Horizontal_Bgnd" },
	--{ Label = "Deathwing's Blood", Value = 		PWRBordersPath .. "DeathwingBlood_Horizontal_Bgnd" },
	--{ Label = "Lightning Charges", Value = 		PWRBordersPath .. "LightningCharges_Horizontal_Bgnd" },
	--{ Label = "Arsenal", Value = 				PWRBordersPath .. "Arsenal_Horizontal_Bgnd" },
	--{ Label = "Conduit (static)", Value = 		PWRBordersPath .. "ConduitStatic_Horizontal_Bgnd" },
	--{ Label = "Conduit (overcharge)", Value = 	PWRBordersPath .. "ConduitOvercharge_Horizontal_Bgnd" },
	--{ Label = "Conduit (diffusion)", Value = 	PWRBordersPath .. "ConduitDiffusion_Horizontal_Bgnd" },
	--{ Label = "Conduit (bolt)", Value = 		PWRBordersPath .. "ConduitBolt_Horizontal_Bgnd" },
	
	{ Label = "No Skin", Value = 				"nil" },
}
PWRBorderChoicesCount = 0
for _ in pairs(PWRBorderChoices) do PWRBorderChoicesCount = PWRBorderChoicesCount + 1 end

PWRBarSkins = {
	{ Label = "Default", Value =			"Interface\\TargetingFrame\\UI-StatusBar" },
	{ Label = "Perl", Value =				PWRTexturesPath .."perl" },
	{ Label = "Ace", Value =				PWRTexturesPath .."AceBarFrames" },
	{ Label = "Aluminium", Value =			PWRTexturesPath .."Aluminium" },
	{ Label = "Banto", Value =				PWRTexturesPath .."banto" },
	{ Label = "Charcoal", Value =			PWRTexturesPath .."Charcoal" },
	{ Label = "Glaze", Value =				PWRTexturesPath .."glaze" },
	{ Label = "LiteStep", Value =			PWRTexturesPath .."LiteStep" },
	{ Label = "Minimalist", Value =			PWRTexturesPath .."Minimalist" },
	{ Label = "Otravi", Value =				PWRTexturesPath .."otravi" },
	{ Label = "Smooth", Value =				PWRTexturesPath .."smooth" },
	{ Label = "XPerl 1", Value =			PWRTexturesPath .."XPerl_StatusBar" },
	{ Label = "XPerl 2", Value =			PWRTexturesPath .."XPerl_StatusBar2" },
	{ Label = "XPerl 3", Value =			PWRTexturesPath .."XPerl_StatusBar3" },
	{ Label = "XPerl 4", Value =			PWRTexturesPath .."XPerl_StatusBar5" },
	{ Label = "XPerl 5", Value =			PWRTexturesPath .."XPerl_StatusBar6" },
	{ Label = "XPerl 6", Value =			PWRTexturesPath .."XPerl_StatusBar7" },
	{ Label = "XPerl 7", Value =			PWRTexturesPath .."XPerl_StatusBar8" },
}
PWRBarSkinsCount = 0
for _ in pairs(PWRBarSkins) do PWRBarSkinsCount = PWRBarSkinsCount + 1 end

PWRAlignments = {
	{ Label = "Left", Value = "LEFT" },
	{ Label = "Center", Value = "CENTER" },
	{ Label = "Right", Value = "RIGHT" },
}

PWRDefaultBarWidth = 200
PWRDefaultOutlineSize = 1
PWRIsInCombat = false

SLASH_POWERED1, SLASH_POWERED2 = "/powered", "/pwr"

function SlashCmdList.POWERED(msg, editbox)
	InterfaceOptionsFrame_OpenToCategory(PWROptionsPanel.SpecsInfo[GetSpecialization()])
	InterfaceOptionsFrame_OpenToCategory(PWROptionsPanel.SpecsInfo[GetSpecialization()])
end

-- BEGIN CLASSIC MODIFICATIONS
PWRBlizz_GetNumSpecializations = GetNumSpecializations
PWRBlizz_GetSpecialization = GetSpecialization
function IsClassic()
	local version, build, date, tocversion = GetBuildInfo()
	return tocversion == 11302
end
function GetNumSpecializations()
	if (IsClassic()) then
		return 1
	else
		return PWRBlizz_GetNumSpecializations()
	end
end
function GetSpecialization()
	if (IsClassic()) then
		return 1
	else
		return PWRBlizz_GetSpecialization()
	end
end
function IsThisSpec(specID)
	if (IsClassic()) then
		return true
	else
		return PWRBlizz_GetSpecialization() == specID
	end
end
-- END CLASSIC MODIFICATIONS

function PWRLog(msg)
	if (PWRDebug) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[".. PWRAddonName .. "]|c00ff00ff " .. msg)
	end
end

function PWRShowColorPicker(rgb, changedCallback)
	ColorPickerFrame.previousValues = { rgb.r, rgb.g, rgb.b }
	ColorPickerFrame.hasOpacity = false
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback
	ColorPickerFrame:SetColorRGB(rgb.r, rgb.g, rgb.b)
	ColorPickerFrame:Show()
end

function PWRSetVisible(var, state)
	if (state == "nil") then
		var:Hide()
	elseif (state) then
		var:Show()
		if (var == PWRMainFrame) then
			PWRMainFrame:SetScript("OnUpdate", nil)
			var:SetAlpha(255)
		end
	else
		var:Hide()
	end
end

function PWRFloorIfNotWhole(v)
	if (floor(v) == not v) then
		return floor(v)
	else
		return v
	end
end

function PWRAlignLabel(label, align, specID)
	local widthFactor = PerSettings.SpecsInfo[specID].Length / PWRDefaultBarWidth
	if (align == PWRAlignments[1].Value) then
		label:ClearAllPoints()
		label:SetPoint("LEFT", 8 * widthFactor, 0)
	elseif (align == PWRAlignments[2].Value) then
		label:ClearAllPoints()
		label:SetPoint("CENTER", 0, -1)
	elseif (align == PWRAlignments[3].Value) then
		label:ClearAllPoints()
		label:SetPoint("RIGHT", -8 * widthFactor, 0)
	end
end

function PWRCreateDropdownMenu(name, parent, index, source, width, useValueAsIcon, onChange)
	local menu = CreateFrame("Frame", name .. index, parent, "UIDropDownMenuTemplate")
	menu.PWROnChange = onChange
	menu.PWRSource = source
	menu.PWRUseValueAsIcon = useValueAsIcon
	UIDropDownMenu_Initialize(menu, PWRDropMenu_Init)
	UIDropDownMenu_SetWidth(menu, width);
	UIDropDownMenu_SetButtonWidth(menu, 124)
	UIDropDownMenu_JustifyText(menu, "LEFT")
	return menu
end

function PWRCreateDropdownColorMenu(name, parent, index, source, width, onChange)
	local menu = CreateFrame("Frame", name .. index, parent, "UIDropDownMenuTemplate")
	menu.PWROnChange = onChange
	menu.PWRSource = source
	UIDropDownMenu_Initialize(menu, PWRDropMenu_Init)
	UIDropDownMenu_SetWidth(menu, width);
	UIDropDownMenu_SetButtonWidth(menu, 124)
	UIDropDownMenu_JustifyText(menu, "LEFT")
	return menu
end

function PWRDropMenu_Init(menu)
	local info = UIDropDownMenu_CreateInfo()
	for j,v in ipairs(menu.PWRSource) do
		info = UIDropDownMenu_CreateInfo()
		info.text = v.Label
		info.value = v.Value
		if (menu.PWRUseValueAsIcon and v.Value ~= "nil") then
			info.icon = v.Value
		end
		info.func = function(self)
			UIDropDownMenu_SetSelectedID(menu, j)
			menu.PWROnChange(j, v.Value)
		end
		UIDropDownMenu_AddButton(info, 1)
	end
end

function PWRRefreshLength(specID)
	PWRMainFrame:SetWidth(PerSettings.SpecsInfo[specID].Length)
	local widthFactor = (PerSettings.SpecsInfo[specID].Length) / PWRDefaultBarWidth
	
	PWRMainFrame.Border:ClearAllPoints()
	PWRMainFrame.Border:SetPoint("TOPLEFT", -38 * widthFactor, 12)
	PWRMainFrame.Border:SetPoint("BOTTOMRIGHT", 38 * widthFactor, -12)
	
	PWRAlignLabel(PWRMainFrame.Current, PerSettings.SpecsInfo[specID].CurrentAlign, specID)
	PWRAlignLabel(PWRMainFrame.Percent, PerSettings.SpecsInfo[specID].PercentAlign, specID)
	PWRAlignLabel(PWRMainFrame.Max, PerSettings.SpecsInfo[specID].MaxAlign, specID)
end

function PWRRefreshOutlineSize(specID)
	local size = PerSettings.SpecsInfo[specID].OutlineSize
	if (size > 0 and PerSettings.SpecsInfo[specID].BorderChoice == "nil") then
		PWRMainFrame.MiniBorder:SetPoint("TOPLEFT", PWRMainFrame, "TOPLEFT", -size, size)
		PWRMainFrame.MiniBorder:SetPoint("BOTTOMRIGHT", PWRMainFrame, "BOTTOMRIGHT", size, -size)
		PWRMainFrame.MiniBorder:SetBackdrop({
			--bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
			tile = false,
			tileSize = 0,
			edgeSize = size,
			insets = { left = -size, right = -size, top = -size, bottom = -size},
		})
	else
		PWRMainFrame.MiniBorder:SetBackdrop(nil)
	end
	PWRRefreshPowerColor(specID)
end

function PWRPowerUpdate(...)
	local arg1 = ...
	if (arg1 == "player") then
		local power = UnitPower("player")
		PWRMainFrame:SetValue(power)
		
		PWRRefreshValues(power)
	end
end

function PWRGetBorderChoiceByValue(value)
	for i = 1, PWRBorderChoicesCount do
		if PWRBorderChoices[i].Value == value then
			return PWRBorderChoices[i]
		end
	end
end

function PWRGetPowerColor()
	local powerType, powerToken, altR, altG, altB = UnitPowerType("player");
	local info = PowerBarColor[powerToken];
	if (info) then
		r, g, b = info.r, info.g, info.b;
	elseif ( not altR) then
		info = PowerBarColor[powerType] or PowerBarColor["MANA"];
		r, g, b = info.r, info.g, info.b;
	else
		r, g, b = altR, altG, altB;
	end
	return r, g, b
end

function PWRGetCustomColor(specID)
	return PerSettings.SpecsInfo[specID].CustomColor.r, PerSettings.SpecsInfo[specID].CustomColor.g, PerSettings.SpecsInfo[specID].CustomColor.b
end

function PWRGetCustomBorderColor(specID)
	return PerSettings.SpecsInfo[specID].CustomBorderColor.r, PerSettings.SpecsInfo[specID].CustomBorderColor.g, PerSettings.SpecsInfo[specID].CustomBorderColor.b
end

function PWRRefreshPowerColor(specID)
	local r, g, b = 0,0,0
	local br, bg, bb = 0,0,0
	if (PerSettings.SpecsInfo[specID].UseCustomColor) then
		r, g, b = PWRGetCustomColor(specID)
	else
		r, g, b = PWRGetPowerColor()
	end
	if (PerSettings.SpecsInfo[specID].UseCustomBorderColor) then
		br, bg, bb = PWRGetCustomBorderColor(specID)
		PWRMainFrame.MiniBorder:SetBackdropBorderColor(br,bg,bb,1)
		PWRMainFrame.MiniBorder:Show()
	else
		PWRMainFrame.MiniBorder:Hide()
	end
	PWRMainFrame:SetStatusBarColor(r, g, b)
	PWRMainFrame.BG:SetVertexColor(r * 0.25, g * 0.25, b * 0.25, 0.7)
	PWRRefreshPowerRange()
end

function PWRRefreshPowerRange()
	local power = UnitPower("player")
	PWRCurrentMaxPower = UnitPowerMax("player")
	PWRMainFrame:SetMinMaxValues(0, PWRCurrentMaxPower)
	PWRMainFrame.Max:SetText(PWRReadableNumber(PWRCurrentMaxPower))
	PWRMainFrame:SetValue(power)
	PWRRefreshValues(power)
end

function PWRRefreshValues(power)
	PWRMainFrame.Current:SetText(PWRReadableNumber(power))
	if (PWRCurrentMaxPower == 0) then
		PWRMainFrame.Percent:SetText("N/A%")
	else
		local percent = floor((power / PWRCurrentMaxPower) * 100)
		PWRMainFrame.Percent:SetText(percent .. "%")
	end
end

function PWRFadeOut()
	local alpha = PWRMainFrame:GetAlpha()
	if (alpha <= 0) then
		PWRMainFrame:SetScript("OnUpdate", nil)
		PWRMainFrame:Hide()
	else
		PWRMainFrame:SetAlpha(alpha - .05)
	end
end

function PWRReadableNumber(num, places)
    local ret
    local placeValue = ("%%.%df"):format(places or 0)
    if not num then
        return 0
    elseif num >= 1000000000000 then
        ret = placeValue:format(num / 1000000000000) .. "t" -- trillion
    elseif num >= 1000000000 then
        ret = placeValue:format(num / 1000000000) .. "b" -- billion
    elseif num >= 1000000 then
        ret = placeValue:format(num / 1000000) .. "m" -- million
    elseif num >= 1000 then
        ret = placeValue:format(num / 1000) .. "k" -- thousand
    else
        ret = num -- hundreds
    end
    return ret
end
