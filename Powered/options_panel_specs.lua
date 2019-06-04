function PWRAddSpecOptions(parent, specID)
	parent.SpecsInfo[specID] = CreateFrame("FRAME", PWRAddonTitle.."Options"..specID, parent)
	local specInfo = parent.SpecsInfo[specID]
	local specSettings = PerSettings.SpecsInfo[specID]
	local id, name, description, icon, background, role -- retail only
	local englishClass -- classic only
	
	if (not IsClassic()) then
		id, name, description, icon, background, role = GetSpecializationInfo(specID)
	else
		name, englishClass = UnitClass("player");
	end
	
	specInfo.name = name
	specInfo.parent = PWRAddonTitle
	
	specInfo.NameLabel = specInfo:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	specInfo.NameLabel:SetText(name)
	specInfo.NameLabel:SetPoint("TOPLEFT", 45, -15)
	
	specInfo.Icon = specInfo:CreateTexture(nil, "BACKGROUND")
	specInfo.Icon:SetTexture(icon)
	specInfo.Icon:SetSize(24, 24)
	specInfo.Icon:SetPoint("LEFT", specInfo.NameLabel, "LEFT", -32, 0)
	
	specInfo.IsCurrentSpecIcon = specInfo:CreateTexture(nil, "BACKGROUND")
	specInfo.IsCurrentSpecIcon:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Criteria-Check")
	specInfo.IsCurrentSpecIcon:SetSize(36, 24)
	specInfo.IsCurrentSpecIcon:SetPoint("LEFT", specInfo.NameLabel, "RIGHT", 15, 0)
	
	specInfo.IsCurrentSpec = specInfo:CreateFontString(nil, "ARTWORK", "GameFontGreen")
	specInfo.IsCurrentSpec:SetText("This is your current specialization.")
	specInfo.IsCurrentSpec:SetPoint("LEFT", specInfo.IsCurrentSpecIcon, "RIGHT", -15, 2)
	if (IsClassic() or not IsThisSpec(specID)) then
		specInfo.IsCurrentSpec:Hide()
		specInfo.IsCurrentSpecIcon:Hide()
	end
	
	specInfo.DescLabel = specInfo:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	specInfo.DescLabel:SetText(description)
	specInfo.DescLabel:SetWordWrap(true)
	specInfo.DescLabel:SetWidth(550)
	specInfo.DescLabel:SetPoint("TOP", 0, -38)
	
	specInfo.ShowSpec = CreateFrame("CheckButton", "ShowSpec" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.ShowSpec:SetPoint("BOTTOMLEFT", specInfo.NameLabel, "BOTTOMLEFT", -10, -95)
	_G[specInfo.ShowSpec:GetName() .. "Text"]:SetText("Enabled")
	specInfo.ShowSpec:SetScript("OnClick", function(self, button, down)
		specSettings.ShowSpec = specInfo.ShowSpec:GetChecked()
		if (IsThisSpec(specID)) then
			if (specSettings.ShowSpec and not specSettings.IsOnlyInCombat) then
				PWRSetVisible(PWRMainFrame, true)
			else
				PWRMainFrame:Hide()
			end
		end
	end)
	specInfo.ShowSpec:SetChecked(specSettings.ShowSpec)
	
	specInfo.IsOnlyInCombat = CreateFrame("CheckButton", "IsOnlyInCombat" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.IsOnlyInCombat:SetPoint("BOTTOMLEFT", specInfo.ShowSpec, "BOTTOMLEFT", 0, -30)
	_G[specInfo.IsOnlyInCombat:GetName() .. "Text"]:SetText("Only In Combat")
	specInfo.IsOnlyInCombat:SetScript("OnClick", function(self, button, down)
		specSettings.IsOnlyInCombat = specInfo.IsOnlyInCombat:GetChecked()
		if (IsThisSpec(specID)) then
			if (specSettings.IsOnlyInCombat) then
				PWRMainFrame:Hide()
			elseif (specSettings.ShowSpec) then
				PWRSetVisible(PWRMainFrame, true)
			end
		end
	end)
	specInfo.IsOnlyInCombat:SetChecked(specSettings.IsOnlyInCombat)

	specInfo.ShowCurrent = CreateFrame("CheckButton", "ShowCurrent" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.ShowCurrent:SetPoint("LEFT", specInfo.ShowSpec, "RIGHT", 170, 0)
	_G[specInfo.ShowCurrent:GetName() .. "Text"]:SetText("Show Current Power")
	specInfo.ShowCurrent:SetScript("OnClick", function(self, button, down)
		specSettings.ShowCurrent = specInfo.ShowCurrent:GetChecked()
		PWRSetVisible(specInfo.CurrentAlign, specSettings.ShowCurrent)
		if (IsThisSpec(specID)) then
			if (specSettings.ShowCurrent) then
				PWRMainFrame.Current:Show()
			else
				PWRMainFrame.Current:Hide()
			end
		end
	end)
	specInfo.ShowCurrent:SetChecked(specSettings.ShowCurrent)
	
	specInfo.ShowPercent = CreateFrame("CheckButton", "ShowPercent" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.ShowPercent:SetPoint("BOTTOMLEFT", specInfo.ShowCurrent, "BOTTOMLEFT", 0, -30)
	_G[specInfo.ShowPercent:GetName() .. "Text"]:SetText("Show Percentage")
	specInfo.ShowPercent:SetScript("OnClick", function(self, button, down)
		specSettings.ShowPercent = specInfo.ShowPercent:GetChecked()
		PWRSetVisible(specInfo.PercentAlign, specSettings.ShowPercent)
		if (IsThisSpec(specID)) then
			if (specSettings.ShowPercent) then
				PWRMainFrame.Percent:Show()
			else
				PWRMainFrame.Percent:Hide()
			end
		end
	end)
	specInfo.ShowPercent:SetChecked(specSettings.ShowPercent)
	
	specInfo.ShowMax = CreateFrame("CheckButton", "ShowMax" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.ShowMax:SetPoint("BOTTOMLEFT", specInfo.ShowPercent, "BOTTOMLEFT", 0, -30)
	_G[specInfo.ShowMax:GetName() .. "Text"]:SetText("Show Maximum Power")
	specInfo.ShowMax:SetScript("OnClick", function(self, button, down)
		specSettings.ShowMax = specInfo.ShowMax:GetChecked()
		PWRSetVisible(specInfo.MaxAlign, specSettings.ShowMax)
		if (IsThisSpec(specID)) then
			if (specSettings.ShowMax) then
				PWRMainFrame.Max:Show()
			else
				PWRMainFrame.Max:Hide()
			end
		end
	end)
	specInfo.ShowMax:SetChecked(specSettings.ShowMax)
	
	specInfo.CurrentAlign = PWRCreateDropdownMenu("CurrentAlign", specInfo, specID, PWRAlignments, 60, false, function(menuIndex, value)
		specSettings.CurrentAlign = value
		if (IsThisSpec(specID)) then
			PWRAlignLabel(PWRMainFrame.Current, value, specID)
		end
	end)
	specInfo.CurrentAlign:SetPoint("LEFT", specInfo.ShowCurrent, "RIGHT", 105, 0)
	UIDropDownMenu_SetSelectedValue(specInfo.CurrentAlign, specSettings.CurrentAlign)
	PWRSetVisible(specInfo.CurrentAlign, specSettings.ShowCurrent)
	
	specInfo.PercentAlign = PWRCreateDropdownMenu("PercentAlign", specInfo, specID, PWRAlignments, 60, false, function(menuIndex, value)
		specSettings.PercentAlign = value
		if (IsThisSpec(specID)) then
			PWRAlignLabel(PWRMainFrame.Percent, value, specID)
		end
	end)
	specInfo.PercentAlign:SetPoint("LEFT", specInfo.ShowPercent, "RIGHT", 105, 0)
	UIDropDownMenu_SetSelectedValue(specInfo.PercentAlign, specSettings.PercentAlign)
	PWRSetVisible(specInfo.PercentAlign, specSettings.ShowPercent)
	
	specInfo.MaxAlign = PWRCreateDropdownMenu("MaxAlign", specInfo, specID, PWRAlignments, 60, false, function(menuIndex, value)
		specSettings.MaxAlign = value
		if (IsThisSpec(specID)) then
			PWRAlignLabel(PWRMainFrame.Max, value, specID)
		end
	end)
	specInfo.MaxAlign:SetPoint("LEFT", specInfo.ShowMax, "RIGHT", 105, 0)
	UIDropDownMenu_SetSelectedValue(specInfo.MaxAlign, specSettings.MaxAlign)
	PWRSetVisible(specInfo.MaxAlign, specSettings.ShowMax)
	
	specInfo.BorderSkinLabel = specInfo:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	specInfo.BorderSkinLabel:SetText("Border Skin")
	specInfo.BorderSkinLabel:SetPoint("TOPLEFT", 25, -175)
	
	specInfo.BorderChoice = PWRCreateDropdownMenu("BorderChoice", specInfo, specID, PWRBorderChoices, 150, true, function(menuIndex, value)
		specSettings.BorderChoice = value
		if (specSettings.BorderChoice == "nil") then
			specInfo.UseCustomBorderColor:Show()
			specInfo.CustomBorderColor:Show()
			if (specInfo.UseCustomBorderColor:GetChecked()) then
				specInfo.Outline:Show()
				specInfo.OutlineEditBox:Show()
			end
		else
			specInfo.UseCustomBorderColor:Hide()
			specInfo.CustomBorderColor:Hide()
			specInfo.Outline:Hide()
			specInfo.OutlineEditBox:Hide()
		end
		if (IsThisSpec(specID)) then
			PWRSetVisible(PWRMainFrame.Border, specSettings.BorderChoice)
			PWRMainFrame.Border:SetTexture(specSettings.BorderChoice)
			PWRRefreshOutlineSize(specID)
			if (specSettings.BorderChoice == "nil") then
				PWRRefreshPowerColor(specID)
			end
		end
	end)
	specInfo.BorderChoice:SetPoint("LEFT", specInfo.BorderSkinLabel, "BOTTOMLEFT", -25, -20)
	UIDropDownMenu_SetSelectedValue(specInfo.BorderChoice, specSettings.BorderChoice)
	
	specInfo.BarSkinLabel = specInfo:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	specInfo.BarSkinLabel:SetText("Bar Skin")
	specInfo.BarSkinLabel:SetPoint("BOTTOMLEFT", specInfo.BorderChoice, "BOTTOMLEFT", 25, -25)
	
	specInfo.BarSkin = PWRCreateDropdownMenu("BarSkin", specInfo, specID, PWRBarSkins, 150, true, function(menuIndex, value)
		specSettings.BarSkin = value
		if (IsThisSpec(specID)) then
			PWRMainFrame:SetStatusBarTexture(specSettings.BarSkin)
			PWRMainFrame.BG:SetTexture(specSettings.BarSkin)
		end
	end)
	specInfo.BarSkin:SetPoint("BOTTOMLEFT", specInfo.BarSkinLabel, "BOTTOMLEFT", -25, -35)
	UIDropDownMenu_SetSelectedValue(specInfo.BarSkin, specSettings.BarSkin)

	specInfo.UseCustomColor = CreateFrame("CheckButton", "UseCustomColor" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.UseCustomColor:SetPoint("LEFT", specInfo.BarSkin, "LEFT", 25, -45) 
	_G[specInfo.UseCustomColor:GetName() .. "Text"]:SetText("Custom Bar Color")
	specInfo.UseCustomColor:SetScript("OnClick", function(self, button, down)
		specSettings.UseCustomColor = specInfo.UseCustomColor:GetChecked()
		specInfo.CustomColor.Texture:SetColorTexture(specSettings.CustomColor.r, specSettings.CustomColor.g, specSettings.CustomColor.b, specSettings.UseCustomColor and 1 or 0.1)
		if (IsThisSpec(specID)) then
			PWRRefreshPowerColor(specID)
		end
	end)
	specInfo.UseCustomColor:SetChecked(specSettings.UseCustomColor)
	
	specInfo.CustomColor = CreateFrame("Frame", nil, specInfo)
	specInfo.CustomColor:SetSize(14, 14)
	specInfo.CustomColor:SetPoint("LEFT", _G[specInfo.UseCustomColor:GetName() .. "Text"], "RIGHT", 15, 0) 
	specInfo.CustomColor.Texture = specInfo.CustomColor:CreateTexture(nil, "BACKGROUND")
	specInfo.CustomColor.Texture:SetAllPoints(true)
	specInfo.CustomColor.Texture:SetColorTexture(specSettings.CustomColor.r, specSettings.CustomColor.g, specSettings.CustomColor.b, specSettings.UseCustomColor and 1 or 0.1)
	specInfo.CustomColor:SetBackdrop({
		--bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1},
	})
	specInfo.CustomColor:SetScript("OnMouseDown", function(self, button)
		if (button == "LeftButton" and specInfo.UseCustomColor:GetChecked()) then
			local r, g, b
			PWRShowColorPicker(specSettings.CustomColor, function(restore)
				if (not restore) then
					r, g, b = ColorPickerFrame:GetColorRGB()
				else
					r, g, b = unpack(restore)
				end
				specSettings.CustomColor.r, specSettings.CustomColor.g, specSettings.CustomColor.b = r, g, b
				self.Texture:SetColorTexture(r, g, b, 1)
				PWRRefreshPowerColor(specID)
			end)
		end
	end)
	
	specInfo.UseCustomBorderColor = CreateFrame("CheckButton", "UseCustomBorderColor" .. specID, specInfo, "UICheckButtonTemplate")
	specInfo.UseCustomBorderColor:SetPoint("LEFT", specInfo.UseCustomColor, "LEFT", 0, -45) 
	_G[specInfo.UseCustomBorderColor:GetName() .. "Text"]:SetText("Set an outline Color")
	specInfo.UseCustomBorderColor:SetScript("OnClick", function(self, button, down)
		specSettings.UseCustomBorderColor = specInfo.UseCustomBorderColor:GetChecked()
		specInfo.CustomBorderColor.Texture:SetColorTexture(specSettings.CustomBorderColor.r, specSettings.CustomBorderColor.g, specSettings.CustomBorderColor.b, specSettings.UseCustomBorderColor and 1 or 0.1)
		if (specInfo.UseCustomBorderColor:GetChecked()) then
			specInfo.Outline:Show()
			specInfo.OutlineEditBox:Show()
		else
			specInfo.Outline:Hide()
			specInfo.OutlineEditBox:Hide()
		end
		if (IsThisSpec(specID)) then
			PWRRefreshPowerColor(specID)
		end
	end)
	specInfo.UseCustomBorderColor:SetChecked(specSettings.UseCustomBorderColor)
	if (specSettings.BorderChoice ~= "nil") then
		specInfo.UseCustomBorderColor:Hide()
	end
	
	specInfo.CustomBorderColor = CreateFrame("Frame", nil, specInfo)
	specInfo.CustomBorderColor:SetSize(14, 14)
	specInfo.CustomBorderColor:SetPoint("LEFT", _G[specInfo.UseCustomBorderColor:GetName() .. "Text"], "RIGHT", 15, 0) 
	specInfo.CustomBorderColor.Texture = specInfo.CustomBorderColor:CreateTexture(nil, "BACKGROUND")
	specInfo.CustomBorderColor.Texture:SetAllPoints(true)
	specInfo.CustomBorderColor.Texture:SetColorTexture(specSettings.CustomBorderColor.r, specSettings.CustomBorderColor.g, specSettings.CustomBorderColor.b, specSettings.UseCustomBorderColor and 1 or 0.1)
	specInfo.CustomBorderColor:SetBackdrop({
		--bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = { left = -1, right = -1, top = -1, bottom = -1},
	})
	specInfo.CustomBorderColor:SetScript("OnMouseDown", function(self, button)
		if (button == "LeftButton" and specInfo.UseCustomBorderColor:GetChecked()) then
			local r, g, b
			PWRShowColorPicker(specSettings.CustomBorderColor, function(restore)
				if (not restore) then
					r, g, b = ColorPickerFrame:GetColorRGB()
				else
					r, g, b = unpack(restore)
				end
				specSettings.CustomBorderColor.r, specSettings.CustomBorderColor.g, specSettings.CustomBorderColor.b = r, g, b
				self.Texture:SetColorTexture(r, g, b, 1)
				PWRRefreshPowerColor(specID)
			end)
		end
	end)
	if (specSettings.BorderChoice ~= "nil") then
		specInfo.CustomBorderColor:Hide()
	end
	
	specInfo.Outline = CreateFrame("Slider", "OutlineSize" .. specID, specInfo, "OptionsSliderTemplate")
	specInfo.Outline:SetOrientation("HORIZONTAL")
	specInfo.Outline:SetPoint("LEFT", specInfo.UseCustomBorderColor, "LEFT", 15, -38)
	specInfo.Outline:SetSize(170, 16)
	specInfo.Outline:SetMinMaxValues(1, 9)
	specInfo.Outline:SetValueStep(1)
	specInfo.Outline:SetObeyStepOnDrag(true)
	specInfo.Outline:SetValue(specSettings.OutlineSize)
	_G[specInfo.Outline:GetName() .. "Low"]:SetText("1")
	_G[specInfo.Outline:GetName() .. "High"]:SetText("9")
	_G[specInfo.Outline:GetName() .. "Text"]:SetText("Outline Thickness: " .. specInfo.Outline:GetValue())
	specInfo.Outline:SetScript("OnValueChanged", function (self, value) 
		value = PWRFloorIfNotWhole(value)
		specSettings.OutlineSize = value
		_G[specInfo.Outline:GetName() .. "Text"]:SetText("Outline Thickness: " .. value)
		specInfo.OutlineEditBox:SetNumber(value)
		if (IsThisSpec(specID)) then
			PWRRefreshOutlineSize(specID)
		end
	end)
	
	specInfo.OutlineEditBox = CreateFrame("EditBox", "OutlineEditBox" .. specID, specInfo.Outline, "InputBoxTemplate")
	specInfo.OutlineEditBox:SetPoint("CENTER", 0, -15)
	specInfo.OutlineEditBox:SetNumeric(true)
	specInfo.OutlineEditBox:SetAutoFocus(false)
	specInfo.OutlineEditBox:SetMaxLetters(1)
	specInfo.OutlineEditBox:SetSize(40, 15)
	specInfo.OutlineEditBox:SetJustifyH("CENTER")
	specInfo.OutlineEditBox:SetJustifyV("CENTER")
	specInfo.OutlineEditBox:SetNumber(specSettings.OutlineSize)
	specInfo.OutlineEditBox:SetCursorPosition(0)
	specInfo.OutlineEditBox:ClearFocus()
	specInfo.OutlineEditBox:SetScript("OnEnterPressed", function(self, userInput)
		specInfo.OutlineEditBox:ClearFocus()
	end)
	specInfo.OutlineEditBox:SetScript("OnEscapePressed", function(self, userInput)
		specInfo.OutlineEditBox:ClearFocus()
	end)
	specInfo.OutlineEditBox:SetScript("OnEditFocusLost", function(self, userInput)
		local value = specInfo.OutlineEditBox:GetNumber() or 0
		local minval, maxval = specInfo.Outline:GetMinMaxValues()
		if (value > maxval) then
			value = maxval
			specInfo.OutlineEditBox:SetNumber(value)
			specInfo.Outline:SetValue(value)
		elseif (value < minval) then
			value = minval
			specInfo.OutlineEditBox:SetNumber(value)
			specInfo.Outline:SetValue(value)
		else
			specInfo.Outline:SetValue(value)
		end
	end)
	if (not specInfo.UseCustomBorderColor:GetChecked() or specSettings.BorderChoice ~= "nil") then
		specInfo.Outline:Hide()
		specInfo.OutlineEditBox:Hide()
	end
	
	specInfo.Length = CreateFrame("Slider", "Length" .. specID, specInfo, "OptionsSliderTemplate")
	specInfo.Length:SetOrientation("HORIZONTAL")
	specInfo.Length:SetPoint("TOPLEFT", 250, -208) 
	specInfo.Length:SetSize(260, 16)
	specInfo.Length:SetMinMaxValues(100, 300)
	specInfo.Length:SetValueStep(1)
	specInfo.Length:SetObeyStepOnDrag(true)
	specInfo.Length:SetValue(specSettings.Length)
	_G[specInfo.Length:GetName() .. "Low"]:SetText("100")
	_G[specInfo.Length:GetName() .. "High"]:SetText("300")
	_G[specInfo.Length:GetName() .. "Text"]:SetText("Length: " .. specInfo.Length:GetValue())
	specInfo.Length:SetScript("OnValueChanged", function (self, value) 
		value = PWRFloorIfNotWhole(value)
		specSettings.Length = value
		_G[specInfo.Length:GetName() .. "Text"]:SetText("Length: " .. value)
		specInfo.LengthEditBox:SetNumber(value)
		if (IsThisSpec(specID)) then
			PWRRefreshLength(specID)
		end
	end)
	
	specInfo.LengthEditBox = CreateFrame("EditBox", "LengthEditBox" .. specID, specInfo.Length, "InputBoxTemplate")
	specInfo.LengthEditBox:SetPoint("CENTER", 0, -15)
	specInfo.LengthEditBox:SetNumeric(true)
	specInfo.LengthEditBox:SetAutoFocus(false)
	specInfo.LengthEditBox:SetMaxLetters(3)
	specInfo.LengthEditBox:SetSize(40, 15)
	specInfo.LengthEditBox:SetJustifyH("CENTER")
	specInfo.LengthEditBox:SetJustifyV("CENTER")
	specInfo.LengthEditBox:SetNumber(specSettings.Length)
	specInfo.LengthEditBox:SetCursorPosition(0)
	specInfo.LengthEditBox:ClearFocus()
	specInfo.LengthEditBox:SetScript("OnEnterPressed", function(self, userInput)
		specInfo.LengthEditBox:ClearFocus()
	end)
	specInfo.LengthEditBox:SetScript("OnEscapePressed", function(self, userInput)
		specInfo.LengthEditBox:ClearFocus()
	end)
	specInfo.LengthEditBox:SetScript("OnEditFocusLost", function(self, userInput)
		local value = specInfo.LengthEditBox:GetNumber() or 0
		local minval, maxval = specInfo.Length:GetMinMaxValues()
		if (value > maxval) then
			value = maxval
			specInfo.LengthEditBox:SetNumber(value)
			specInfo.Length:SetValue(value)
		elseif (value < minval) then
			value = minval
			specInfo.LengthEditBox:SetNumber(value)
			specInfo.Length:SetValue(value)
		else
			specInfo.Length:SetValue(value)
		end
	end)
	
	specInfo.Scale = CreateFrame("Slider", "Scale" .. specID, specInfo, "OptionsSliderTemplate")
	specInfo.Scale:SetOrientation("HORIZONTAL")
	specInfo.Scale:SetPoint("TOPLEFT", 250, -273) 
	specInfo.Scale:SetSize(260, 16) 
	specInfo.Scale:SetMinMaxValues(50, 150)
	specInfo.Scale:SetValueStep(1)
	specInfo.Scale:SetObeyStepOnDrag(true)
	specInfo.Scale:SetValue(specSettings.Scale * 100.0)
	_G[specInfo.Scale:GetName() .. "Low"]:SetText("50%")
	_G[specInfo.Scale:GetName() .. "High"]:SetText("150%")
	_G[specInfo.Scale:GetName() .. "Text"]:SetText("Scale: " .. specInfo.Scale:GetValue() .. "%")
	specInfo.Scale:SetScript("OnValueChanged", function (self, value) 
		specSettings.XPos = specSettings.XPos * specSettings.Scale
		specSettings.YPos = specSettings.YPos * specSettings.Scale
		specSettings.Scale = value / 100.0
		specSettings.XPos = specSettings.XPos / specSettings.Scale
		specSettings.YPos = specSettings.YPos / specSettings.Scale
		_G[specInfo.Scale:GetName() .. "Text"]:SetText("Scale: " .. value .. "%")
		specInfo.ScaleEditBox:SetNumber(value)
		if (IsThisSpec(specID)) then
			PWRMainFrame:SetScale(specSettings.Scale)
			PWRMainFrame:ClearAllPoints()
			PWRMainFrame:SetPoint("BOTTOMLEFT", specSettings.XPos, specSettings.YPos)
		end
	end)
	
	specInfo.ScaleEditBox = CreateFrame("EditBox", "ScaleEditBox" .. specID, specInfo.Scale, "InputBoxTemplate")
	specInfo.ScaleEditBox:SetPoint("CENTER", 0, -15)
	specInfo.ScaleEditBox:SetNumeric(true)
	specInfo.ScaleEditBox:SetAutoFocus(false)
	specInfo.ScaleEditBox:SetMaxLetters(3)
	specInfo.ScaleEditBox:SetSize(40, 15)
	specInfo.ScaleEditBox:SetJustifyH("CENTER")
	specInfo.ScaleEditBox:SetJustifyV("CENTER")
	specInfo.ScaleEditBox:SetNumber(specSettings.Scale * 100.0)
	specInfo.ScaleEditBox:SetCursorPosition(0)
	specInfo.ScaleEditBox:ClearFocus()
	specInfo.ScaleEditBox:SetScript("OnEnterPressed", function(self, userInput)
		specInfo.ScaleEditBox:ClearFocus()
	end)
	specInfo.ScaleEditBox:SetScript("OnEscapePressed", function(self, userInput)
		specInfo.ScaleEditBox:ClearFocus()
	end)
	specInfo.ScaleEditBox:SetScript("OnEditFocusLost", function(self, userInput)
		local value = specInfo.ScaleEditBox:GetNumber() or 0
		local minval, maxval = specInfo.Scale:GetMinMaxValues()
		if (value > maxval) then
			value = maxval
			specInfo.ScaleEditBox:SetNumber(value)
			specInfo.Scale:SetValue(value)
		elseif (value < minval) then
			value = minval
			specInfo.ScaleEditBox:SetNumber(value)
			specInfo.Scale:SetValue(value)
		else
			specInfo.Scale:SetValue(value)
		end
	end)
	
	InterfaceOptions_AddCategory(specInfo)
end
