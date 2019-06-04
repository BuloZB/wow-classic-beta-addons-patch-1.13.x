local _, NS = ...
NS.AddonPath = "Interface\\Addons\\MovePadPlus\\"

local MPFrameHeightOriginal, MPFrameHeightLarge
------------ Texts and Localisation ---------------------------------------------
NS.Texts = {
	Above = "Above",
	AboveTip = "Place above the turn buttons",
	Below = "Below",
	BelowTip = "Place below the turn buttons",
	C2MTip = "Toggle\nClick-To-Move.",
	RotateTip = "Toggle\nRotate.",
	HoldRotateTip = "Hold\nRotate.",
	HideC2M = "Hide Click-2-Move",
	HideRotate = "Hide Rotate",
	HideTooltips = "Hide Tooltips",
	HideHoldRotate = "Hide Hold Rotate",
	Position = "Position",
	PositionTip = "Position relative to the new\nturn left/turn right buttons",
	Replace = "Replace",
	ReplaceTip = "Replace (hide) the turn buttons",
	SetKeybinds = "Set key binds",
	SwapRotates = "Swap Rotates",
	Targeting = "Enable Ground Targeting",
	TargetingTip = "NOTE: Only for the Rotate button\nEnable ground targeting spells when rotate is on.",
}

local locale = GetLocale()
if locale == "ptBR" then
	NS.Texts = {
		C2MTip = "Ativar\\Desativar\nClicar-Para-Mover.",
		RotateTip = "Ativar\\Desativar\nRota\195\167\195\163o.",
		HoldRotateTip = "Travar\nRota\195\167\195\163o.",
		HideC2M = "Ocultar Clicar-Para-Mover",
		HideRotate = "Ocultar Rota\195\167\195\163o",
		HideTooltips = "Ocultar Dicas",
		HideHoldRotate = "Ocultar Travar Rota\195\167\195\163o",
		SetKeybinds = "Configurar Atalhos",
		SwapRotates = "Inverter Rota\195\167\195\163o",
		Targeting = "Enable Ground Targeting",
		TargetingTip = "NOTE: Only for the Rotate button\nEnable ground targeting spells when rotate is on.",
	}
elseif locale == "frFR" then
--	NS.Texts = {
--		C2MTip = "French for Toggle\nClick-To-Move.",
--		RotateTip = "French for Toggle\nRotate.",
--	}
elseif locale == "deDE" then	
--	NS.Texts = {
--		C2MTip = "German for Toggle\nClick-To-Move.",
--		RotateTip = "German for Toggle\nRotate.",
--	}
end

------------ Local Functions ----------------------------------------------------

NS.ButtonPos = { 
        {text=NS.Texts.Below, value=nil},
        {text=NS.Texts.Above, value=1},
        {text=NS.Texts.Replace, value=2},
} 

local function ButtonSetup(self)
	self:SetCheckedTexture("Interface\\Buttons\\CheckButtonGlow")
	local bm = self:GetCheckedTexture()
	bm:SetBlendMode("ADD")
	bm:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.icon:SetTexCoord(0, 1, 0, 1)
end

local function GetState(arg1)
	local state
	local uicheck = arg1 or GetCVar("autointeract")
	if not uicheck or uicheck == "0" then
		state = false
	else
		state = true
	end
	return state
end

local function MovePadAnyChecked()
	if MovePadForward:GetChecked() or MovePadBackward:GetChecked() or MovePadStrafeLeft:GetChecked() or MovePadStrafeRight:GetChecked() then
		return true
	else
		return false
	end
end

local function	WorldMouseUpScript(self, button, up)
	local rotatebutton, script
	if NS.holdRotateButton.RotateOffOnUp then
		rotatebutton = NS.holdRotateButton
		script = NS.holdRotateButton:GetScript("OnMouseUp")
--	elseif NS.rotateButton:GetChecked() then
	elseif NS.rotateButton.wasChecked then
		rotatebutton = NS.rotateButton
		script = NS.rotateButton:GetScript("OnClick")
	end
	if rotatebutton then
		rotatebutton:SetChecked(false)
		script(rotatebutton, button, up)
	end
end

local function SettoolTips()
	NS.c2mButton:SetScript("OnEnter", function(self)
			if MovePadPlus.HideTooltips then return end
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, self:GetHeight())
			GameTooltip:SetText(NS.Texts.C2MTip)
		end)
	NS.c2mButton:SetScript("OnLeave", function(self)
			if MovePadPlus.HideTooltips then return end
			GameTooltip:Hide()		
		end)
	NS.rotateButton:SetScript("OnEnter", function(self)
			if self.inTurn then
				self.inTurn = nil
			else
				if MovePadPlus.HideTooltips then return end
				GameTooltip:SetOwner(self, self.TTAnchor, 0, self:GetHeight())
				GameTooltip:SetText(NS.Texts.RotateTip)
			end
		end)
	NS.rotateButton:SetScript("OnLeave", function(self)
			if MovePadPlus.HideTooltips then return end
			GameTooltip:Hide()		
		end)
	NS.holdRotateButton:SetScript("OnEnter", function(self)
			if MovePadPlus.HideTooltips then return end
			GameTooltip:SetOwner(self, self.TTAnchor, 0, self:GetHeight())
			GameTooltip:SetText(NS.Texts.HoldRotateTip)
		end)
	NS.holdRotateButton:SetScript("OnLeave", function(self)
			if MovePadPlus.HideTooltips then return end
			GameTooltip:Hide()		
		end)
end

local function SetFrameSize()
	local fsize = MPFrameHeightLarge
	if MovePadPlus.Position == 2 or MovePadPlus.Buttons.HideClick2Move or (MovePadPlus.Buttons.HideRotate and MovePadPlus.Buttons.HideHoldRotate) then
		fsize = MPFrameHeightOriginal
	end
	MovePadFrame:SetHeight(fsize)
end

----------------------------------------------------------------------------------------- 
NS.c2mButton = CreateFrame("CheckButton", "MovePadPlusFrame", UIParent, "UIPanelSquareButton")
ButtonSetup(NS.c2mButton)
NS.c2mButton:Hide()
NS.c2mButton:RegisterEvent("ADDON_LOADED")
NS.c2mButton:RegisterEvent("CVAR_UPDATE")
NS.c2mButton:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			if ... ~= "Blizzard_MovePad" then return end
			self:UnregisterEvent("ADDON_LOADED")
			NS:InitialisEverything(self)
		end
	end)

----------------------------------------------------------------------------------------- 
function NS:SetShown(data, index, pressed)
	local button
	local hide = data[index]
	local size
	if index == "HideClick2Move" then
		button = NS.c2mButton
		size = true
	elseif index == "HideRotate" then
		button = NS.rotateButton
	elseif index == "HideHoldRotate" then
		button = NS.holdRotateButton
	end	
	if not button then return end
	if hide then
		button:Hide()
		local click = button:GetScript("OnClick") or button:GetScript("OnMouseUp")
		button:SetChecked(false)
		click(button, pressed)
	else
		button:Show()
	end
	SetFrameSize()
end

function NS:AnchorRotateButtons()
	NS.rotateButton:ClearAllPoints()
	NS.holdRotateButton:ClearAllPoints()
	MovePadRotateLeft:ClearAllPoints()
	MovePadRotateRight:ClearAllPoints()
	if MovePadPlus.SwapRotates then
--		NS.rotateButton:SetPoint("LEFT", MovePadJump, "RIGHT")
--		NS.holdRotateButton:SetPoint("RIGHT", MovePadJump, "LEFT")
		if not MovePadPlus.Position then -- Below new turn buttons
			MovePadRotateLeft:SetPoint("RIGHT", MovePadJump, "LEFT")
			MovePadRotateRight:SetPoint("LEFT", MovePadJump, "RIGHT")
			NS.rotateButton:SetPoint("LEFT", MovePadBackward, "RIGHT")
			NS.holdRotateButton:SetPoint("RIGHT", MovePadBackward, "LEFT")
			MovePadRotateLeft:Show()
			MovePadRotateRight:Show()
		elseif MovePadPlus.Position == 1 then -- Above new turn butons
			NS.rotateButton:SetPoint("BOTTOMRIGHT", MovePadBackward, "TOPLEFT")
			NS.holdRotateButton:SetPoint("BOTTOMLEFT", MovePadBackward, "TOPRIGHT")
			MovePadRotateLeft:SetPoint("TOP", NS.rotateButton, "BOTTOM")
			MovePadRotateRight:SetPoint("TOP", NS.holdRotateButton, "BOTTOM")
			MovePadRotateLeft:Show()
			MovePadRotateRight:Show()
		elseif MovePadPlus.Position == 2 then -- replace new turn buttons
			NS.rotateButton:SetPoint("BOTTOMRIGHT", MovePadBackward, "TOPLEFT")
			NS.holdRotateButton:SetPoint("BOTTOMLEFT", MovePadBackward, "TOPRIGHT")
			MovePadRotateLeft:Hide()
			MovePadRotateRight:Hide()
		end
		NS.rotateButton.TTAnchor = "ANCHOR_BOTTOMRIGHT"
		NS.holdRotateButton.TTAnchor = "ANCHOR_BOTTOMLEFT"
	else
--		NS.rotateButton:SetPoint("RIGHT", MovePadJump, "LEFT")
--		NS.holdRotateButton:SetPoint("LEFT", MovePadJump, "RIGHT")
		if not MovePadPlus.Position then -- Below new turn buttons
			MovePadRotateLeft:SetPoint("RIGHT", MovePadJump, "LEFT")
			MovePadRotateRight:SetPoint("LEFT", MovePadJump, "RIGHT")
			NS.rotateButton:SetPoint("RIGHT", MovePadBackward, "LEFT")
			NS.holdRotateButton:SetPoint("LEFT", MovePadBackward, "RIGHT")
			MovePadRotateLeft:Show()
			MovePadRotateRight:Show()
		elseif MovePadPlus.Position == 1 then -- Above new turn butons
			NS.rotateButton:SetPoint("BOTTOMLEFT", MovePadBackward, "TOPRIGHT")
			NS.holdRotateButton:SetPoint("BOTTOMRIGHT", MovePadBackward, "TOPLEFT")
			MovePadRotateLeft:SetPoint("TOP", NS.holdRotateButton, "BOTTOM")
			MovePadRotateRight:SetPoint("TOP", NS.rotateButton, "BOTTOM")
			MovePadRotateLeft:Show()
			MovePadRotateRight:Show()
		elseif MovePadPlus.Position == 2 then -- replace new turn buttons
			NS.rotateButton:SetPoint("BOTTOMLEFT", MovePadBackward, "TOPRIGHT")
			NS.holdRotateButton:SetPoint("BOTTOMRIGHT", MovePadBackward, "TOPLEFT")
			MovePadRotateLeft:Hide()
			MovePadRotateRight:Hide()
		end
		SetFrameSize()
		NS.rotateButton.TTAnchor = "ANCHOR_BOTTOMLEFT"
		NS.holdRotateButton.TTAnchor = "ANCHOR_BOTTOMRIGHT"
	end
end

function NS:InitialisEverything(c2mBtn)
	MPFrameHeightOriginal = MovePadFrame:GetHeight()
	MPFrameHeightLarge = MPFrameHeightOriginal + MovePadJump:GetHeight()
	if not MovePadPlus then MovePadPlus = {} end
	if not MovePadPlus.Buttons then
		MovePadPlus.HideTooltips = false
		MovePadPlus.Buttons = {
					HideClick2Move=false,
					HideRotate=false,
				}
	end
	if not MovePadPlus.Buttons.HideHoldRotate then
		MovePadPlus.Buttons.HideHoldRotate = false
	end
	MovePadFrame:HookScript("OnShow", function(self)
			NS:SetShown(MovePadPlus.Buttons, "HideClick2Move")
			NS:SetShown(MovePadPlus.Buttons, "HideRotate")
			NS:SetShown(MovePadPlus.Buttons, "HideHoldRotate")
			if NS.configFrame then
				NS.configFrame:Hide()
				NS.configButton:SetChecked(false)
			end
		end)
	WorldFrame:HookScript("OnMouseUp", WorldMouseUpScript)
	c2mBtn.icon:SetSize(21, 21)
	c2mBtn.icon:SetTexture(NS.AddonPath .. "GoldBoot")
	c2mBtn:RegisterForClicks("AnyUp")
	c2mBtn:SetParent(MovePadFrame)
	c2mBtn:SetSize(38, 38)
--	c2mBtn:SetPoint("RIGHT", MovePadBackward, "LEFT")
--	c2mBtn:SetPoint("TOPRIGHT", MovePadBackward, "BOTTOMLEFT")
	c2mBtn:SetPoint("BOTTOMLEFT", MovePadFrame, "BOTTOMLEFT", 5, 5)
	c2mBtn:SetChecked(GetState())
	c2mBtn:SetScript("OnEvent", function(self, event, ...)
			if ... ~= "CLICK_TO_MOVE" then return end
			local _, uicheck = ...
			self:SetChecked(GetState(uicheck))
		end)
	c2mBtn:SetScript("OnClick", function(self, button, up)
			local uicheck
			if self:GetChecked() then
				uicheck = "1"
			else
				uicheck = "0"
			end
			SetCVar("autointeract", uicheck)
			InterfaceOptionsMousePanelClickToMove:SetChecked(uicheck)
			PlaySound(PlaySoundKitID and "igMainMenuOptionCheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)
	NS:SetShown(MovePadPlus.Buttons, "HideClick2Move")

	NS.rotateButton = CreateFrame("CheckButton", "MovePadPlusRotate", MovePadFrame, "UIPanelSquareButton")
	NS:SetShown(MovePadPlus.Buttons, "HideRotate")
	ButtonSetup(NS.rotateButton)
	NS.rotateButton:RegisterEvent("PLAYER_STARTED_MOVING")
	NS.rotateButton:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	NS.rotateButton:RegisterEvent("CINEMATIC_START")
	NS.rotateButton:SetSize(c2mBtn:GetSize())
	NS.rotateButton:RegisterForClicks("AnyUp")
	NS.rotateButton.icon:SetSize(20, 20)
	NS.rotateButton.icon:SetTexture(NS.AddonPath.. "Rotate")
	NS.rotateButton.icon:SetVertexColor(.75, .75, 0)
	NS.rotateButton:SetScript("OnEvent", function(self, event, ...)
			if self:GetChecked() then
				if event == "CURRENT_SPELL_CAST_CHANGED" then -- CURRENT_SPELL_CAST_CHANGED check to see if they are using a ground targeting spell
					if not MovePadPlus.GroundTargeting then return end
					if SpellIsTargeting() then
						MouselookStop()
					else
						MouselookStart()
					end
				else -- PLAYER_STARTED_MOVING using keyboard or gamepad
					self:SetChecked(false)
					MouselookStop()
				end
			end
		end)
	NS.rotateButton:SetScript("OnClick", function(self, button, up)
			if not self:GetChecked() then
				MouselookStop()
				self.wasChecked = false
			else
				if not MovePadPlus.NotoolTip then self.inTurn = true end
				MouselookStart()
				self.wasChecked = true
			end
			PlaySound(PlaySoundKitID and "igMainMenuOptionCheckBoxOn" or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		end)

	NS.holdRotateButton = CreateFrame("CheckButton", "MovePadPlusHoldRotate", MovePadFrame, "UIPanelSquareButton")
	NS:SetShown(MovePadPlus.Buttons, "HideHoldRotate")
	ButtonSetup(NS.holdRotateButton)
	NS.holdRotateButton:SetSize(c2mBtn:GetSize())
	NS.holdRotateButton:RegisterEvent("CINEMATIC_START")
	NS.holdRotateButton:RegisterForClicks("AnyUp")
	NS.holdRotateButton:RegisterForClicks("AnyDown")
	NS.holdRotateButton.icon:SetSize(20, 20)
	NS.holdRotateButton.NTexture = NS.holdRotateButton:GetNormalTexture()
	NS.holdRotateButton.HTexture = NS.holdRotateButton:GetHighlightTexture()
	NS.holdRotateButton.icon:SetTexture(NS.AddonPath.. "HoldRotate")
	NS.holdRotateButton.icon:SetVertexColor(.75, .75, 0)
	NS.holdRotateButton:SetScript("OnEvent", function(self, event, ...)
			self:SetNormalTexture(self.NTexture)
			self.RotateOffOnUp = nil
			MouselookStop()
		end)
	NS.holdRotateButton:SetScript("OnMouseDown", function(self, button, up)
			self:SetNormalTexture(self.HTexture)
			MouselookStart()
			self.RotateOffOnUp = true
		end)
	NS.holdRotateButton:SetScript("OnMouseUp", function(self, button, up)
			if not self.RotateOffOnUp then return end
			self:SetNormalTexture(self.NTexture)
			self.RotateOffOnUp = nil
			MouselookStop()
		end)

	NS.configButton = CreateFrame("CheckButton", "MovePadPlusConfig", MovePadFrame, "UIPanelSquareButton")
	ButtonSetup(NS.configButton)
	NS.configButton:SetAlpha(.3)
	NS.configButton.icon:SetTexture(NS.AddonPath.. "Config")
	NS.configButton:SetSize(15, 15)
	NS.configButton.icon:SetSize(16, 16)
	NS.configButton:SetPoint("BOTTOMLEFT", MovePadFrame, "BOTTOMRIGHT")
--	MovePadLock:ClearAllPoints()
--	MovePadLock:SetPoint("BOTTOMLEFT", NS.configButton, "TOPLEFT", -5, 0)
--	MovePadLock:SetWidth(MovePadLock:GetWidth() - 3)
--	MovePadLock:SetHeight(MovePadLock:GetHeight() - 3)
	MovePadLock:Hide()
	NS.configButton:RegisterForClicks("AnyUp")
	NS.configButton:SetScript("OnEnter", function(self)
			self:SetAlpha(1)
		end)
	NS.configButton:SetScript("OnLeave", function(self)
			self:SetAlpha(.3)
		end)
	NS.configButton:SetScript("OnClick", function(self, button)
			if not NS.configFrame then
				NS:CreateConfig()
			end
			if self:GetChecked() then
				NS.configFrame:Show()
			else
				NS.configFrame:Hide()
			end
		end)
	NS:AnchorRotateButtons()
	SettoolTips()
end
