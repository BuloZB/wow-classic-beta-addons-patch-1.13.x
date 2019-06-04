local T, C, L = select(2, ...):unpack()

local TukuiActionBars = CreateFrame("Frame")
local _G = _G
local format = format
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS
local MainMenuBar, MainMenuBarArtFrame = MainMenuBar, MainMenuBarArtFrame
local OverrideActionBar = OverrideActionBar
local PossessBarFrame = PossessBarFrame
local ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight = ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight
local Panels = T["Panels"]

local Frames = {
	MainMenuBar, MainMenuBarArtFrame, OverrideActionBar,
	PossessBarFrame, ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	TalentMicroButtonAlert, CollectionsMicroButtonAlert, EJMicroButtonAlert, CharacterMicroButtonAlert
}

function TukuiActionBars:DisableBlizzard()
	local Hider = Panels.Hider

	SetCVar("alwaysShowActionBars", 1)

	if (not C.ActionBars.AddNewSpells) then
		tinsert(Frames, IconIntroTracker)
	end

	for _, frame in pairs(Frames) do
		frame:UnregisterAllEvents()
		frame.ignoreFramePositionManager = true
		frame:SetParent(Hider)
	end

	for i = 1, 6 do
		local Button = _G["OverrideActionBarButton"..i]

		Button:UnregisterAllEvents()
		Button:SetAttribute("statehidden", true)
		Button:SetAttribute("showgrid", 1)
	end

	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)

	hooksecurefunc("ActionButton_OnEvent", function(self, event)
		if (event == "PLAYER_ENTERING_WORLD") then
			self:UnregisterEvent("ACTIONBAR_SHOWGRID")
			self:UnregisterEvent("ACTIONBAR_HIDEGRID")
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	end)

	if T.WoWBuild < 28724 then
		-- Avoid Hiding Buttons on open/close spellbook
		MultiActionBar_HideAllGrids = function() end
		MultiActionBar_ShowAllGrids = function() end
	end

	ActionBarButtonEventsFrame:UnregisterEvent("ACTIONBAR_HIDEGRID")
end

function TukuiActionBars:ShowGrid()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local Button
		local Reason = nil

		if T.WoWBuild >= 28724 then
			Reason = ACTION_BUTTON_SHOW_GRID_REASON_EVENT
		end

		Button = _G[format("ActionButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		ActionButton_ShowGrid(Button, Reason)

		Button = _G[format("MultiBarRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		ActionButton_ShowGrid(Button, Reason)

		Button = _G[format("MultiBarBottomRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		ActionButton_ShowGrid(Button, Reason)

		Button = _G[format("MultiBarLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		ActionButton_ShowGrid(Button, Reason)

		Button = _G[format("MultiBarBottomLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button:Show()
		ActionButton_ShowGrid(Button, Reason)
	end
end

function TukuiActionBars:ChangeBlizzardOptionsDescription()
	InterfaceOptionsActionBarsPanelRight.Text:SetText(L.ActionBars.CenterBar)
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetText(SHOW_MULTIBAR3_TEXT)
end

function TukuiActionBars:MovePetBar()
	local PetBar = TukuiPetActionBar
	local RightBar = TukuiActionBar5
	local Data = TukuiData[GetRealmName()][UnitName("Player")].Move.TukuiActionBar5

	-- Don't run if player moved bar 5
	if Data then
		return
	end

	if RightBar:IsShown() then
		PetBar:SetPoint("RIGHT", RightBar, "LEFT", -6, 0)
	else
		PetBar:SetPoint("RIGHT", UIParent, "RIGHT", -28, 8)
	end
end

function TukuiActionBars:AddPanels()
	local Size = C.ActionBars.NormalButtonSize
	local PetSize = C.ActionBars.PetButtonSize
	local Spacing = C.ActionBars.ButtonSpacing

	-- Bar #1
	local A1 = CreateFrame("Frame", "TukuiActionBar1", UIParent, "SecureHandlerStateTemplate")
	A1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 14)
	A1:SetFrameStrata("LOW")
	A1:SetFrameLevel(10)
	A1.Backdrop = CreateFrame("Frame", nil, A1)
	A1.Backdrop:SetAllPoints()

	-- Bar #2
	local A2 = CreateFrame("Frame", "TukuiActionBar2", UIParent, "SecureHandlerStateTemplate")
	A2:Point("BOTTOMRIGHT", A1, "BOTTOMLEFT", -6, 0)
	A2:SetFrameStrata("LOW")
	A2:SetFrameLevel(10)
	A2.Backdrop = CreateFrame("Frame", nil, A2)
	A2.Backdrop:SetAllPoints()
	A2.Backdrop:Hide()

	-- Bar #3
	local A3 = CreateFrame("Frame", "TukuiActionBar3", UIParent, "SecureHandlerStateTemplate")
	A3:Point("BOTTOMLEFT", A1, "BOTTOMRIGHT", 6, 0)
	A3:SetFrameStrata("LOW")
	A3:SetFrameLevel(10)
	A3.Backdrop = CreateFrame("Frame", nil, A3)
	A3.Backdrop:SetAllPoints()
	A3.Backdrop:Hide()

	-- Bar #4
	local A4 = CreateFrame("Frame", "TukuiActionBar4", UIParent, "SecureHandlerStateTemplate")
	A4:Point("BOTTOM", UIParent, "BOTTOM", 0, 14)
	A4:SetFrameStrata("LOW")
	A4:SetFrameLevel(10)
	A4.Backdrop = CreateFrame("Frame", nil, A4)
	A4.Backdrop:SetAllPoints()
	A4.Backdrop:Hide()

	-- Bar #5
	local A5 = CreateFrame("Frame", "TukuiActionBar5", UIParent, "SecureHandlerStateTemplate")
	A5:SetPoint("RIGHT", UIParent, "RIGHT", -28, 8)
	A5:SetFrameStrata("LOW")
	A5:SetFrameLevel(10)
	A5.Backdrop = CreateFrame("Frame", nil, A5)
	A5.Backdrop:SetAllPoints()
	A5.Backdrop:Hide()

	-- Pet Bar
	local A6 = CreateFrame("Frame", "TukuiPetActionBar", UIParent, "SecureHandlerStateTemplate")
	A6:SetPoint("RIGHT", A5, "LEFT", -6, 0)
	A6:SetFrameStrata("LOW")
	A6:SetFrameLevel(10)
	A6.Backdrop = CreateFrame("Frame", nil, A6)
	A6.Backdrop:SetAllPoints()

	-- Move Pet Bar if Bar 5 hidden
	A5:SetScript("OnShow", self.MovePetBar)
	A5:SetScript("OnHide", self.MovePetBar)

	-- Stance Bar
	local A7 = CreateFrame("Frame", "TukuiStanceBar", UIParent, "SecureHandlerStateTemplate")
	A7:SetSize((PetSize * 10) + (Spacing * 11), PetSize + (Spacing * 2))
	A7:SetPoint("TOPLEFT", 30, -30)
	A7:SetFrameStrata("LOW")
	A7:SetFrameLevel(10)
	A7.Backdrop = CreateFrame("Frame", nil, A7)

	if (not C.ActionBars.HideBackdrop) then
		A1.Backdrop:SetTemplate()
		A2.Backdrop:SetTemplate()
		A3.Backdrop:SetTemplate()
		A4.Backdrop:SetTemplate()
		A5.Backdrop:SetTemplate()
		A6.Backdrop:SetTemplate()
		A7.Backdrop:SetTemplate()

		A1.Backdrop:SetFrameLevel(A4:GetFrameLevel())

		if not C.General.HideShadows then
			A1.Backdrop:CreateShadow()
			A2.Backdrop:CreateShadow()
			A3.Backdrop:CreateShadow()
			A4.Backdrop:CreateShadow()
			A5.Backdrop:CreateShadow()
			A6.Backdrop:CreateShadow()
			A7.Backdrop:CreateShadow()

			A1.Backdrop.Shadow:Hide()

			A4:SetScript("OnShow", function() A1.Backdrop.Shadow:Hide() end)
			A4:SetScript("OnHide", function() A1.Backdrop.Shadow:Show() end)
		end
	end

	InterfaceOptionsFrame:HookScript("OnShow", TukuiActionBars.ChangeBlizzardOptionsDescription)

	Panels.ActionBar1 = A1
	Panels.ActionBar2 = A2
	Panels.ActionBar3 = A3
	Panels.ActionBar4 = A4
	Panels.ActionBar5 = A5
	Panels.PetActionBar = A6
	Panels.StanceBar = A7
end

function TukuiActionBars:UpdatePetBar(...)
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local ButtonName = "PetActionButton" .. i
		local PetActionButton = _G[ButtonName]

		PetActionButton:SetNormalTexture("")
	end
end

function TukuiActionBars:UpdateStanceBar(...)
	if InCombatLockdown() then return end
	local NumForms = GetNumShapeshiftForms()
	local Texture, Name, IsActive, IsCastable, Button, Icon, Cooldown, Start, Duration, Enable
	local PetSize = C.ActionBars.PetButtonSize
	local Spacing = C.ActionBars.ButtonSpacing

	if NumForms == 0 then
		Panels.StanceBar:SetAlpha(0)
	else
		Panels.StanceBar:SetAlpha(1)
		Panels.StanceBar.Backdrop:SetSize((PetSize * NumForms) + (Spacing * (NumForms + 1)), PetSize + (Spacing * 2))
		Panels.StanceBar.Backdrop:SetPoint("TOPLEFT", 0, 0)

		for i = 1, NUM_STANCE_SLOTS do
			local ButtonName = "StanceButton"..i

			Button = _G[ButtonName]
			Icon = _G[ButtonName.."Icon"]

			Button:SetNormalTexture("")

			if i <= NumForms then
				Texture, IsActive, IsCastable = GetShapeshiftFormInfo(i)

				if not Icon then
					return
				end

				Icon:SetTexture(Texture)
				Cooldown = _G[ButtonName.."Cooldown"]

				if Texture then
					Cooldown:SetAlpha(1)
				else
					Cooldown:SetAlpha(0)
				end

				Start, Duration, Enable = GetShapeshiftFormCooldown(i)
				CooldownFrame_Set(Cooldown, Start, Duration, Enable)

				if IsActive then
					StanceBarFrame.lastSelected = Button:GetID()
					Button:SetChecked(true)

					if Button.Backdrop then
						Button.Backdrop:SetBackdropBorderColor(0, 1, 0)
					end
				else
					Button:SetChecked(false)

					if Button.Backdrop then
						Button.Backdrop:SetBackdropBorderColor(unpack(C.General.BorderColor))
					end
				end

				if IsCastable then
					Icon:SetVertexColor(1.0, 1.0, 1.0)
				else
					Icon:SetVertexColor(0.4, 0.4, 0.4)
				end
			end
		end
	end
end

function TukuiActionBars:AddHooks()
	hooksecurefunc("ActionButton_Update", self.SkinButton)
	hooksecurefunc("ActionButton_UpdateFlyout", self.StyleFlyout)
	hooksecurefunc("SpellButton_OnClick", self.StyleFlyout)
	hooksecurefunc("ActionButton_UpdateHotkeys", self.UpdateHotKey)
	hooksecurefunc(ExtraActionButton1.style, "SetTexture", self.DisableExtraButtonTexture)
	hooksecurefunc(ZoneAbilityFrame.SpellButton.Style, "SetTexture", self.DisableExtraButtonTexture)
	hooksecurefunc("PetActionButton_SetHotkeys", self.UpdateHotKey)
end

function TukuiActionBars:Enable()
	self:DisableBlizzard()
	self:AddPanels()
	self:CreateBar1()
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreatePetBar()
	self:CreateStanceBar()
	self:ShowGrid()
	self:CreateToggleButtons()
	self:CreateVehicleButtons()
	self:Bindings()
	self:SetUpExtraActionButton()
	self:AddHooks()
	self:LoadVariables()
end

T["ActionBars"] = TukuiActionBars
