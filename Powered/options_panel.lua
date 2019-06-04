function PWRLoadOptionsPanel()
	--local scrollmax = 155
	
	PWROptionsPanel = CreateFrame("ScrollFrame", "PWROptionsPanel", UIParent);
	PWROptionsPanel.name = PWRAddonTitle
	-- PWROptionsPanel:EnableMouseWheel(true)
	-- PWROptionsPanel:SetScript("OnMouseWheel", function (self, delta) 
		-- local current = PWROptionsPanel.Scrollbar:GetValue()
		-- if IsShiftKeyDown() and (delta > 0) then
			-- PWROptionsPanel.Scrollbar:SetValue(0)
		-- elseif IsShiftKeyDown() and (delta < 0) then
			-- PWROptionsPanel.Scrollbar:SetValue(scrollmax)
		-- elseif (delta < 0) and (current < scrollmax) then
			-- PWROptionsPanel.Scrollbar:SetValue(current + 20)
		-- elseif (delta > 0) and (current > 1) then
			-- PWROptionsPanel.Scrollbar:SetValue(current - 20)
		-- end
	-- end)
	
	-- PWROptionsPanel.Scrollbar = CreateFrame("Slider", nil, PWROptionsPanel, "UIPanelScrollBarTemplate") 
	-- PWROptionsPanel.Scrollbar:SetPoint("TOPLEFT", PWROptionsPanel, "TOPRIGHT", -20, -20) 
	-- PWROptionsPanel.Scrollbar:SetPoint("BOTTOMLEFT", PWROptionsPanel, "BOTTOMRIGHT", -20, 20)
	-- PWROptionsPanel.Scrollbar:SetMinMaxValues(1, scrollmax)
	-- PWROptionsPanel.Scrollbar:EnableMouseWheel(true)
	-- PWROptionsPanel.Scrollbar:SetValueStep(1) 
	-- PWROptionsPanel.Scrollbar.scrollStep = 1
	-- PWROptionsPanel.Scrollbar:SetValue(0) 
	-- PWROptionsPanel.Scrollbar:SetWidth(16) 
	-- PWROptionsPanel.Scrollbar:SetScript("OnValueChanged", function (self, value) 
		-- self:GetParent():SetVerticalScroll(value) 
	-- end)
	
	--content frame 
	-- PWROptionsPanel = CreateFrame("Frame", nil, PWROptionsPanel) 
	-- PWROptionsPanel:SetScrollChild(PWROptionsPanel)
	-- DONE adding scrollable frame.
	
	PWROptionsPanel.NameLabel = PWROptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	PWROptionsPanel.NameLabel:SetText(PWRAddonTitle)
	PWROptionsPanel.NameLabel:SetPoint("TOPLEFT", 15, -15)

	PWROptionsPanel.DescLabel = PWROptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	PWROptionsPanel.DescLabel:SetText(PWRAddonNotes)
	PWROptionsPanel.DescLabel:SetPoint("TOPLEFT", PWROptionsPanel.NameLabel, "BOTTOMLEFT", 5, -8)

	PWROptionsPanel.IsLocked = CreateFrame("CheckButton", "IsLocked", PWROptionsPanel, "UICheckButtonTemplate")
	PWROptionsPanel.IsLocked:SetPoint("TOPLEFT", 18, -55)
	IsLockedText:SetText("Locked In Place")
	PWROptionsPanel.IsLocked:SetScript("OnClick", function(self, button, down)
		PerSettings.IsLocked = PWROptionsPanel.IsLocked:GetChecked()
		PWRMainFrame:SetMovable(not PerSettings.IsLocked)
		PWRMainFrame:EnableMouse(not PerSettings.IsLocked)
	end)
	PWROptionsPanel.IsLocked:SetChecked(PerSettings.IsLocked)
	
	PWROptionsPanel.TipLabel = PWROptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
	PWROptionsPanel.TipLabel:SetText("To customize your power bar, click the '+' next to ".. PWRAddonTitle .."'s category and select a specialization.")
	PWROptionsPanel.TipLabel:SetPoint("TOPLEFT", 40, -120)
	PWROptionsPanel.TipLabel:SetWidth(500)
	PWROptionsPanel.TipLabel:SetWordWrap(true)
	
	PWROptionsPanel.LeftIcon = PWROptionsPanel:CreateTexture(nil, "BACKGROUND")
	PWROptionsPanel.LeftIcon:SetTexture("Interface\\GossipFrame\\DailyQuestIcon")
	PWROptionsPanel.LeftIcon:SetSize(24, 24)
	PWROptionsPanel.LeftIcon:SetPoint("LEFT", PWROptionsPanel.TipLabel, "LEFT", -15, 0)
	
	PWROptionsPanel.RightIcon = PWROptionsPanel:CreateTexture(nil, "BACKGROUND")
	PWROptionsPanel.RightIcon:SetTexture("Interface\\GossipFrame\\DailyQuestIcon")
	PWROptionsPanel.RightIcon:SetSize(24, 24)
	PWROptionsPanel.RightIcon:SetPoint("RIGHT", PWROptionsPanel.TipLabel, "RIGHT", 15, 0)
	
	InterfaceOptions_AddCategory(PWROptionsPanel)
	
	PWROptionsPanel.SpecsInfo = {}
	for specID = 1, GetNumSpecializations() do
		PWRAddSpecOptions(PWROptionsPanel, specID)
	end
end
