-- Called once in main.lua, when the event PLAYER_LOGIN happens
function PWRLoadAddon()
	if (not PWRLoaded) then
		PWRLoaded = true
		
		PerSettings = PerSettings or {}
		-- SET DEFAULT VALUES IF THERE IS NONE
		if (PerSettings.IsLocked == nil) then PerSettings.IsLocked = false end
		
		PerSettings.SpecsInfo = PerSettings.SpecsInfo or {}
		for i = 1, GetNumSpecializations() do
			PerSettings.SpecsInfo[i] = PerSettings.SpecsInfo[i] or {}
			local specSettings = PerSettings.SpecsInfo[i]
			if (specSettings.XPos == nil) then
				specSettings.XPos = PWRMainFrame:GetLeft()
				specSettings.YPos = PWRMainFrame:GetBottom()
			end
			if (specSettings.ShowSpec == nil) then specSettings.ShowSpec = true end
			if (specSettings.IsOnlyInCombat == nil) then specSettings.IsOnlyInCombat = false end
			
			if (specSettings.ShowPercent == nil) then specSettings.ShowPercent = true end
			if (specSettings.ShowCurrent == nil) then specSettings.ShowCurrent = true end
			if (specSettings.ShowMax == nil) then specSettings.ShowMax = true end
			
			if (specSettings.BorderChoice == nil) then specSettings.BorderChoice = PWRBorderChoices[1].Value end
			if (specSettings.BarSkin == nil) then specSettings.BarSkin = PWRBarSkins[1].Value end
			
			if (specSettings.CurrentAlign == nil) then specSettings.CurrentAlign = PWRAlignments[1].Value end
			if (specSettings.PercentAlign == nil) then specSettings.PercentAlign = PWRAlignments[2].Value end
			if (specSettings.MaxAlign == nil) then specSettings.MaxAlign = PWRAlignments[3].Value end
			
			if (specSettings.UseCustomColor == nil) then specSettings.UseCustomColor = false end
			if (specSettings.CustomColor == nil) then specSettings.CustomColor = { r = 0.5, g = 0.5, b = 0.5 } end
			
			if (specSettings.UseCustomBorderColor == nil) then specSettings.UseCustomBorderColor = false end
			if (specSettings.CustomBorderColor == nil) then specSettings.CustomBorderColor = { r = 0.5, g = 0.5, b = 0.5 } end
			
			if (specSettings.Length == nil) then specSettings.Length = PWRDefaultBarWidth end
			if (specSettings.OutlineSize == nil) then specSettings.OutlineSize = PWRDefaultOutlineSize end
			
			if (specSettings.Scale == nil) then specSettings.Scale = 1 end
		end
		-- END SET DEFAULT
		
		-- Patch for 1.0 to 1.1 (So as to not discard player's settings) BEGIN
		if (PerSettings.ShowSpec) then
			for i = 1, GetNumSpecializations() do
				PerSettings.SpecsInfo[i].ShowSpec = PerSettings.ShowSpec
				PerSettings.SpecsInfo[i].IsOnlyInCombat = PerSettings.IsOnlyInCombat
				PerSettings.SpecsInfo[i].ShowPercent = PerSettings.ShowPercent
				PerSettings.SpecsInfo[i].ShowCurrent = PerSettings.ShowCurrent
				PerSettings.SpecsInfo[i].ShowMax = PerSettings.ShowMax
				PerSettings.SpecsInfo[i].XPos = PerSettings.XPos
				PerSettings.SpecsInfo[i].YPos = PerSettings.YPos
				PerSettings.SpecsInfo[i].BorderChoice = PerSettings.BorderChoice[i]
			end
			PerSettings.ShowSpec = nil
			PerSettings.IsOnlyInCombat = nil
			PerSettings.ShowPercent = nil
			PerSettings.ShowCurrent = nil
			PerSettings.ShowMax = nil
			PerSettings.BorderChoiceID = nil
			PerSettings.BorderChoice = nil
			PerSettings.XPos = nil
			PerSettings.YPos = nil
		end
		-- Patch for 1.0 to 1.1 END
		
		if (PerSettings.IsLocked) then
			PWRMainFrame:SetMovable(false)
			PWRMainFrame:EnableMouse(false)
		end
		
		local currentSpecID = GetSpecialization()
		local specSettings = PerSettings.SpecsInfo[currentSpecID]
		
		PWRMainFrame:SetScale(specSettings.Scale)
		if (specSettings.XPos) then
			PWRMainFrame:ClearAllPoints()
			PWRMainFrame:SetPoint("BOTTOMLEFT", specSettings.XPos, specSettings.YPos)
		end
		if (specSettings.IsOnlyInCombat) then
			PWRMainFrame:Hide()
		end
		if (not specSettings.ShowCurrent) then
			PWRMainFrame.Current:Hide()
		end
		if (not specSettings.ShowPercent) then
			PWRMainFrame.Percent:Hide()
		end
		if (not specSettings.ShowMax) then
			PWRMainFrame.Max:Hide()
		end
		if (not specSettings.ShowSpec) then
			PWRMainFrame:Hide()
		end
		
		PWRMainFrame:SetStatusBarTexture(specSettings.BarSkin)
		PWRMainFrame.BG:SetTexture(specSettings.BarSkin)
		
		PWRSetVisible(PWRMainFrame.Border, specSettings.BorderChoice)
		PWRMainFrame.Border:SetTexture(specSettings.BorderChoice)
		
		PWRRefreshLength(currentSpecID)
		PWRRefreshOutlineSize(currentSpecID)
		
		PWRLoadOptionsPanel()
		PWRRefreshPowerColor(currentSpecID)
		
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ffff[Powered]|c00ff00ff Addon loaded!")
	end
end
