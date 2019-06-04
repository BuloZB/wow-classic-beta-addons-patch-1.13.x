local _, NS = ...

------------ Local Functions ----------------------------------------------------

local function CheckBox_Init(self)
	self:SetChecked(self.data[self.index])
end

local function SetToolTip(self, tip, anchor)
	local setAnchor = anchor or "ANCHOR_LEFT"
	if self and tip then
		GameTooltip:SetOwner(self, setAnchor)
		GameTooltip:SetText(tip)			
	else
		GameTooltip:Hide()
	end
end

function CreateFontString(frame, name, font, text, layer, frompoint, topoint, xoffset, yoffset, justifyH, SetJustifyV, size, red, green, blue, alpha)
	local x = xoffset or 0
	local y = yoffset or 0
	local s = size or 12
	local r = red or 1
	local g = green or 1
	local b = blue or 1
	local a = alpha or 1
	local f = frame:CreateFontString(name, layer)
	if type(font) == "string" then
		f:SetFont(font, s)
	else
		f:SetFontObject(font)
	end
	f:SetTextColor(r, g, b, a)
	f:SetText(text)
	f:SetJustifyH(justifyH or "LEFT")
	f:SetJustifyV(justifyY or "CENTER")
	f:ClearAllPoints()
	f:SetPoint(frompoint, frame, topoint, x, y)
	return f
end

local function CreateCheckBox(name, parent, label, data, index, tip, width, height)
 	local w = width or 24 
 	local h = heigh or 24
	local f = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
	f.data = data
	f.index = index
	f.tip = tip
	f:SetSize(w, h)	
	f.initfunc = CheckBox_Init
	f.initfunc(f)
	local FromPoint, ToPoint, xoffset = "LEFT", "RIGHT", 5
	f:SetScript("OnClick", function(self, button)
			local checked = self:GetChecked()
			self.data[index] = checked
			if self.updatefunc then -- Yes, this is needed
				self.updatefunc(self, data, index, button)
			end
			if self.clickextra then
				self.clickextra(self, checked)
			end
		end)
	f:SetScript("OnEnter", function(self)
			SetToolTip(self, self.tip)
		end)
	f:SetScript("OnLeave", function(self)
			SetToolTip()
		end)
	f.label = CreateFontString(f, name .. "Label", "Fonts\\ARIALN.ttf", label, "ARTWORK", FromPoint, ToPoint, xoffset, 1, "LEFT", "CENTER", 12, 1, 1, 1)
	return f
end

local function GetWidth(frame, currentwidth)
	local width = frame.label:GetWidth()
	if width > currentwidth then
		return width
	else
		return currentwidth
	end
end

---------------------------------------------------------------------------------

function NS:CreateConfig()
	local width = 0
	NS.configFrame = CreateFrame("Frame", "MovePadPlus_Config", MovePadFrame)
	NS.configFrame:Hide()
	NS.configFrame:SetWidth(165)
	NS.configFrame:SetHeight(205)
	local bg = { bgFile="Interface\\toolTips\\UI-toolTip-Background", edgeFile="Interface\\toolTips\\UI-toolTip-Border", tile="true", tileSize=16, edgeSize=16, insets={ left=5, right=5, top=5, bottom=5 } }
	NS.configFrame:SetBackdrop(bg)
	NS.configFrame:SetBackdropColor(.09, .09, .19, .5)
	NS.configFrame:SetBackdropBorderColor(1, 1, 1)
	NS.configFrame:SetPoint("TOP", MovePadFrame, "BOTTOM")
	NS.configFrame.C2M = CreateCheckBox("MovePadPlus_Config_C2M", NS.configFrame, NS.Texts.HideC2M, MovePadPlus.Buttons, "HideClick2Move", "", 30, 15)
	NS.configFrame.C2M.updatefunc = NS.SetShown
	NS.configFrame.C2M:SetPoint("TOPLEFT", NS.configFrame, "TOPLEFT", 5, -5)
	width = GetWidth(NS.configFrame.C2M, width)
	NS.configFrame.Rotate = CreateCheckBox("MovePadClick2Move_Config_Rotate", NS.configFrame, NS.Texts.HideRotate, MovePadPlus.Buttons, "HideRotate", "", 30, 15)
	NS.configFrame.Rotate.updatefunc = NS.SetShown
	NS.configFrame.Rotate:SetPoint("TOPLEFT", NS.configFrame.C2M, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Rotate, width)
	NS.configFrame.HoldRotate = CreateCheckBox("MovePadPluse_Config_HoldRotate", NS.configFrame, NS.Texts.HideHoldRotate, MovePadPlus.Buttons, "HideHoldRotate", "", 30, 15)
	NS.configFrame.HoldRotate.updatefunc = NS.SetShown
	NS.configFrame.HoldRotate:SetPoint("TOPLEFT", NS.configFrame.Rotate, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.HoldRotate, width)
	NS.configFrame.SwapRotates = CreateCheckBox("MovePadPlus_Config_SwapRotates", NS.configFrame, NS.Texts.SwapRotates, MovePadPlus, "SwapRotates", "", 30, 15)
	NS.configFrame.SwapRotates.updatefunc = NS.AnchorRotateButtons
	NS.configFrame.SwapRotates:SetPoint("TOPLEFT", NS.configFrame.HoldRotate, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.SwapRotates, width)
	NS.configFrame.Tooltips = CreateCheckBox("MovePadPlus_Config_Tooltip", NS.configFrame, NS.Texts.HideTooltips, MovePadPlus, "HideTooltips", "", 30, 15)
	NS.configFrame.Tooltips:SetPoint("TOPLEFT", NS.configFrame.SwapRotates, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Tooltips, width)
	NS.configFrame.Targeting = CreateCheckBox("MovePadPlus_Config_Targeting", NS.configFrame, NS.Texts.Targeting, MovePadPlus, "GroundTargeting", NS.Texts.TargetingTip, 30, 15)
	NS.configFrame.Targeting:SetPoint("TOPLEFT", NS.configFrame.Tooltips, "BOTTOMLEFT", 0, -5)
	width = GetWidth(NS.configFrame.Targeting, width)
	NS.configFrame.PositionList = NS:CreateDropList("MovePadPlus_Config_Position", NS.configFrame, NS.Texts.Position, NS.ButtonPos, #NS.ButtonPos, MovePadPlus, "Position", 80, 24, true, true) --, labelright, override, strata)
	NS.configFrame.PositionList:SetPoint("TOPLEFT", NS.configFrame.Targeting, "BOTTOMLEFT", 1, 0)
	NS.configFrame.PositionList.updatefunc = NS.AnchorRotateButtons
	NS.configFrame.PositionList:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, setAnchor)
			GameTooltip:SetText(NS.Texts.PositionTip)
		end)
	NS.configFrame.PositionList:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
	local _, _, _, x = NS.configFrame.C2M:GetPoint(1)
	local _, _, _, x2 = NS.configFrame.C2M.label:GetPoint(1)
	NS.configFrame:SetWidth(51 + width)
	MovePadLock:Show()
	MovePadLock:SetParent(NS.configFrame)
	MovePadLock:ClearAllPoints()
	MovePadLock:SetPoint("TOPRIGHT", NS.configFrame, "TOPRIGHT")
end

