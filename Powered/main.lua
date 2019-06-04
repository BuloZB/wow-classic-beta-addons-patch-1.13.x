-- THE MAIN FRAME, AKA THE POWER BAR
PWRMainFrame = CreateFrame("StatusBar", PWRAddonName .. "Frame", UIParent)
PWRMainFrame:RegisterEvent("PLAYER_LOGIN")
PWRMainFrame:RegisterEvent("UNIT_POWER_FREQUENT") -- when power quantity change
PWRMainFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enter combat
PWRMainFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Exit combat
PWRMainFrame:RegisterEvent("UNIT_DISPLAYPOWER") -- when power type change
PWRMainFrame:RegisterEvent("UNIT_MAXPOWER") -- when max power change
if (not IsClassic()) then
	PWRMainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
end
-- SETUP THE POWER BAR
PWRMainFrame:SetStatusBarTexture(PWRBarSkins[1].Value)
PWRMainFrame:GetStatusBarTexture():SetHorizTile(false)
PWRMainFrame:RegisterForDrag("LeftButton")
PWRMainFrame:SetSize(PWRDefaultBarWidth, 20)
PWRMainFrame:SetPoint("CENTER", 0, -150)
PWRMainFrame:SetMovable(true)
PWRMainFrame:EnableMouse(true)
PWRMainFrame:SetClampedToScreen(true)
PWRMainFrame:SetScript("OnDragStart", PWRMainFrame.StartMoving)
PWRMainFrame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local currentSpecID = GetSpecialization()
	PerSettings.SpecsInfo[currentSpecID].XPos = self:GetLeft()
	PerSettings.SpecsInfo[currentSpecID].YPos = self:GetBottom()
end)
-- SETUP THE BORDER
PWRMainFrame.Border = PWRMainFrame:CreateTexture(nil, "OVERLAY")
-- SETUP THE MINIMALIST BORDER
PWRMainFrame.MiniBorder = CreateFrame("Frame", nil, PWRMainFrame)
PWRMainFrame.MiniBorder:SetPoint("TOPLEFT", PWRMainFrame, "TOPLEFT", -1, 1)
PWRMainFrame.MiniBorder:SetPoint("BOTTOMRIGHT", PWRMainFrame, "BOTTOMRIGHT", 1, -1)
PWRMainFrame.MiniBorder:SetFrameLevel(PWRMainFrame:GetFrameLevel())
-- SETUP THE BACKGROUND, UNDER THE BAR
PWRMainFrame.BG = PWRMainFrame:CreateTexture(nil, "BACKGROUND")
PWRMainFrame.BG:SetAllPoints(PWRMainFrame)
-- SETUP THE 'CURRENT POWER' LABEL
PWRMainFrame.Current = PWRMainFrame:CreateFontString(nil, "OVERLAY")
PWRMainFrame.Current:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
PWRMainFrame.Current:SetText("0")
PWRMainFrame.Current:SetPoint("LEFT", 8, -1)
-- SETUP THE 'PERCENTAGE OF AVAILABLE POWER' LABEL
PWRMainFrame.Percent = PWRMainFrame:CreateFontString(nil, "OVERLAY")
PWRMainFrame.Percent:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
PWRMainFrame.Percent:SetText("100%")
PWRMainFrame.Percent:SetPoint("CENTER", 0, -1)
-- SETUP THE 'MAX POWER' LABEL
PWRMainFrame.Max = PWRMainFrame:CreateFontString(nil, "OVERLAY")
PWRMainFrame.Max:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
PWRMainFrame.Max:SetText("100")
PWRMainFrame.Max:SetPoint("RIGHT", -8, -1)
-- SET A SCRIPT TO LISTEN TO EVENTS
PWRMainFrame:SetScript("OnEvent", function(self, event, ...)
	if (event == "UNIT_POWER_FREQUENT") then
		PWRPowerUpdate(...)
	-- ENTERED COMBAT
	elseif (event == "PLAYER_REGEN_DISABLED") then
		if (PWRLoaded) then
			local currentSpecID = GetSpecialization()
			-- ONLY SHOW THE BAR IF THE SETTINGS AUTHORIZE IT
			if (PerSettings.SpecsInfo[currentSpecID].IsOnlyInCombat and PerSettings.SpecsInfo[currentSpecID].ShowSpec) then
				PWRMainFrame:SetScript("OnUpdate", nil)
				PWRSetVisible(PWRMainFrame, true)
				PWRPowerUpdate("player")
			end
		end
	-- LEAVE COMBAT
	elseif (event == "PLAYER_REGEN_ENABLED") then
		if (PWRLoaded) then
			local currentSpecID = GetSpecialization()
			-- ONLY FADE THE BAR IF THE SETTINGS AUTHORIZE IT
			if (PerSettings.SpecsInfo[currentSpecID].IsOnlyInCombat and PerSettings.SpecsInfo[currentSpecID].ShowSpec) then
				PWRPowerUpdate("player")
				PWRMainFrame:SetScript("OnUpdate", PWRFadeOut)
			end
		end
	-- POWER TYPE CHANGED
	elseif (event == "UNIT_DISPLAYPOWER") then
		PWRRefreshPowerColor(GetSpecialization())
		PWRPowerUpdate("player")
	-- POWER MAX CHANGED
	elseif (event == "UNIT_MAXPOWER") then
		PWRRefreshPowerRange()
		PWRPowerUpdate("player")
	elseif (event == "ACTIVE_TALENT_GROUP_CHANGED") then
		if (PWRLoaded) then
			local currentSpecID = GetSpecialization()
			local specSettings = PerSettings.SpecsInfo[currentSpecID]
			PWRMainFrame:SetStatusBarTexture(specSettings.BarSkin)
			PWRMainFrame.BG:SetTexture(specSettings.BarSkin)
			
			PWRSetVisible(PWRMainFrame.Border, specSettings.BorderChoice)
			PWRMainFrame.Border:SetTexture(specSettings.BorderChoice)
			
			PWRSetVisible(PWRMainFrame.Current, specSettings.ShowCurrent)
			PWRSetVisible(PWRMainFrame.Percent, specSettings.ShowPercent)
			PWRSetVisible(PWRMainFrame.Max, specSettings.ShowMax)
			
			for specID = 1, GetNumSpecializations() do
				PWRSetVisible(PWROptionsPanel.SpecsInfo[specID].IsCurrentSpecIcon, currentSpecID == specID)
				PWRSetVisible(PWROptionsPanel.SpecsInfo[specID].IsCurrentSpec, currentSpecID == specID)
			end
			
			PWRMainFrame:SetScale(specSettings.Scale)
			
			if (specSettings.XPos) then
				PWRMainFrame:ClearAllPoints()
				PWRMainFrame:SetPoint("BOTTOMLEFT", specSettings.XPos, specSettings.YPos)
			else
				PWRMainFrame:ClearAllPoints()
				PWRMainFrame:SetPoint("CENTER", 0, -150)
			end
			PWRRefreshOutlineSize(currentSpecID)
			PWRRefreshLength(currentSpecID)
			if (not PerSettings.SpecsInfo[currentSpecID].ShowSpec) then
				PWRMainFrame:Hide()
			elseif (not PerSettings.SpecsInfo[currentSpecID].IsOnlyInCombat) then
				PWRSetVisible(PWRMainFrame, true)
			end
			
			PWRPowerUpdate("player")
		end
	elseif (event == "PLAYER_LOGIN") then
		PWRLoadAddon()
	end
end)
