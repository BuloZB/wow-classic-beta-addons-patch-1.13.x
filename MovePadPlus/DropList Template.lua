local _, NS = ...

local function CreateTooltipBackdrop(name, parent, ftype)
	local backdrop = {
		bgFile = NS.AddonPath.."PlainBackdrop",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		edgeSize = 16,
		tileSize = 16,
		insets = {
			left = 5,
			right = 5,
			top = 5,
			bottom = 5,
		},
	}
	local f = CreateFrame(ftype, name, parent)
	f:SetFrameStrata("BACKGROUND") 
	f:SetBackdrop(backdrop)
	return f
end

local function CreateText(frame, name, font, text, layer, frompoint, topoint, xoffset, yoffset, justifyH, SetJustifyV, size, red, green, blue, alpha)
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

local function DropMenu_Init(self, override)
	local text
	local initval = self.data[self.index]
	for _, value in pairs(self.table) do
		if value.value == initval then
			text = value.text
			break
		end
	end
	if (not text) and self.addoptions then
		for _, value in pairs(self.addoptions) do
			if value.value == initval then
				text = value.text
				break
			end
		end
	end
	if not text then
		if override then
			text = initval
			if not text then
				text = ""
			end
		else
			text = ""
		end
	end
	self.setting:SetText(text)
end

local function DropList_Show(self, toggle)
	local  parentcontrol = self
	if (toggle) then
		parentcontrol = self:GetParent()
	end
	local menu = parentcontrol.menu
	if menu:IsVisible() then
		menu:Hide()
		if menu.addedoptions then
			for i in pairs(menu.addedoptions) do
				parentcontrol.menu.table[i] = nil
			end
		end
		return
	end
	if parentcontrol.addoptions then
		menu.addedoptions = {}
		for i,v in pairs(parentcontrol.addoptions) do
			tinsert(parentcontrol.table, v)
			menu.addedoptions[#parentcontrol.table] = 1
		end
	else
		menu.addedoptions = nil
	end
	menu:ClearAllPoints()
	menu:SetPoint("TOPLEFT", parentcontrol, "BOTTOMLEFT", 0, 0)
	if menu:GetBottom() < UIParent:GetBottom() then
		local yoffset = UIParent:GetBottom() - menu:GetBottom()
		menu:ClearAllPoints()
		menu:SetPoint("TOPLEFT", parentcontrol.setting, "BOTTOMLEFT", 0, yoffset)
	end
	menu:Show()
	menu.table = parentcontrol.table
	menu.index = parentcontrol.index
	menu.subindex = parentcontrol.subindex
	menu.subindex2 = parentcontrol.subindex2
	menu.miscindex = parentcontrol.miscindex
	menu.controlbox = parentcontrol.setting
	if menu.scrollMenu then
		local numButtons = #menu.Buttons
		for i=1, numButtons do
			menu.Buttons[i]:SetChecked(0)
		end
		parentcontrol = menu.ScrollFrame
		local scroll = _G[parentcontrol:GetName().."ScrollBar"]
		scroll:SetValue(0)
		parentcontrol.offset = 0
		menu.updatefunc(parentcontrol)
	end
	if not menu.scrollMenu then
		local count = 0
		local widest = 0
		for _, value in pairs(parentcontrol.table) do
			count = count + 1
			parentcontrol.menu.drop[count]:Show()
			parentcontrol.menu.drop[count].text:SetText(value.text)
			parentcontrol.menu.drop[count].value = value.value
			parentcontrol.menu.drop[count].desc = value.desc
			local width = parentcontrol.menu.drop[count].text:GetWidth()
			if (width > widest) then
				widest = width
			end
		end
		for i=1, menu.count do
			if (i <= count) then
				parentcontrol.menu.drop[i]:SetWidth(widest)
			else
				parentcontrol.menu.drop[i]:Hide()			
			end
		end
		menu:SetWidth(widest + 20)
		menu:SetHeight(count * 15 + 20)
	end
end

local function CreateDropMenu(name, parent, label, table, maxdrops, data, index, width, height, enabled, labelright, override, strata)
	local f = CreateTooltipBackdrop(name, parent, "Button")
	f:SetBackdropColor(0.2, 0.2, 0.2)
	f:SetSize(width, height)
	local s = strata or "HIGH"
	f:SetFrameStrata(s)
	f.button = CreateFrame("Button", name .. "_Button", f)
	f.button:SetSize(32, 32)
	f.button:ClearAllPoints()
	f.button:SetPoint("RIGHT", f, "RIGHT", 3, -1)
	f.button:SetHitRectInsets(6, 6, 7, 7)
	f.button:SetNormalTexture("Interface/MainMenuBar/UI-MainMenu-ScrollDownButton-Up")
	f.button:SetPushedTexture("Interface/MainMenuBar/UI-MainMenu-ScrollDownButton-Down")
	f.button:SetDisabledTexture("Interface/Buttons/UI-ScrollBar-ScrollDownButton-Disabled")
	f.button:SetHighlightTexture("Interface/MainMenuBar/UI-MainMenu-ScrollDownButton-Highlight", "ADD")
	f.table = table
	f.data = data
	f.index = index
	f.button:SetScript("OnClick", function(self)
			DropList_Show(self, true)
		end)
	local left, right, xoffset = "RIGHT", "LEFT", -5
	if labelright then
		left, right, xoffset = "LEFT", "RIGHT", 5
	end
	f.label = CreateText(f, name .. "Label", "Fonts/ARIALN.ttf", label, "ARTWORK", left, right, xoffset, 0, "RIGHT", "CENTER", 12, 1, 1, 1)
	f.setting = CreateText(f, name .. "Setting", "Fonts/ARIALN.ttf", "", "ARTWORK", "LEFT", "LEFT", 3, 0, "LEFT", "CENTER", 12, 1, 1, 1)
	f.setting:ClearAllPoints()
	f.setting:SetPoint("LEFT", f, "LEFT", 5, 0)
	f:SetScript("OnClick", function(self)
			DropList_Show(self)
		end)
	f.initfunc = DropMenu_Init
	f.initfunc(f)
	f.alpha = f:GetAlpha()
	f.SetEnabled=SetEnabled
	f:SetEnabled(enabled)
	return f
end

local function ButtonOnLeave(self)	
	if not self:GetParent():IsMouseOver(0, 0, 0, 0) then
		self:GetParent():Hide()
	end
end

local function DropButton_Update(self)
	local text = self.text:GetText()
	local parent = self:GetParent():GetParent()
	parent.setting:SetText(text)
	for i,t in pairs(self.table) do
		if t.text == text then
			self.data[self.index] = t.value
--			if self.updatefunc then -- Yes, this is needed
--				self.updatefunc(self, data, index)
--			end
			if parent.updatefunc then -- Yes, this is needed
				parent.updatefunc(parent, data, index)
			end
		end
	end
	self:GetParent():Hide()
end

local function CreateDropButton(name, parent, table, data, index)
	local f = CreateFrame("Button", name, parent)
	f:SetSize(170, 15)
	f.table = table
	f.data = data
	f.index = index
	f:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
	f.text = CreateText(f, name .. "_Text", "Fonts/ARIALN.ttf", "", "ARTWORK", "LEFT", "LEFT", 0, 0, "LEFT", "CENTER", 12)
	f:SetScript("OnEnter", function(self)
			if (self.desc) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(self.desc, 1, 1, 1, 1, 1)
			end
			self:GetParent().timer = nil
		end)
	f:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
			ButtonOnLeave(self)
		end)
	f:SetScript("OnClick", function(self)
			DropButton_Update(self)
		end)
	return f
end

local function MenuOnEnter(self)
	if self.timer then
		self.timer:Cancel()
		self.timer = nil
	end
end

local function MenuOnLeave(self)
	if not self:IsMouseOver(0, 0, 0, 0) then
		self.timer = C_Timer.NewTimer(0.7, function()
			self:Hide()
		end)
	end
end

local function CreateDropListHandler(name, parent, maxdrops, table, data, index, strata)
	local f = CreateTooltipBackdrop(name, parent, "Button")
	local s = strata or "HIGH"
	f:SetFrameStrata(s)
	f:SetSize(10, 10)
	f:Hide()
	f:SetBackdropColor(0.2, 0.2, 0.2)
	f.count = maxdrops
	f.drop = {}
	for i = 1,f.count do
		f.drop[i] = CreateDropButton(name, f, table, data, index)
		f.drop[i]:ClearAllPoints()
		if i == 1 then
			f.drop[i]:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -10)
		else
			f.drop[i]:SetPoint("TOPLEFT", f.drop[i-1], "BOTTOMLEFT")
		end
	end

	f:SetScript("OnEnter", function(self)
			MenuOnEnter(self)
		end)

	f:SetScript("OnLeave", function(self)
			MenuOnLeave(self)
		end)
	return f
end

function NS:CreateDropList(name, parent, label, table, maxdrops, data, index, width, height, enabled, labelright, override, strata)
	local f = CreateDropMenu(name, parent, label, table, maxdrops, data, index, width, height, enabled, labelright, override, strata)
	f.menu = CreateDropListHandler(name .. "_Drop_Handler", f, maxdrops, f.table, f.data, f.index)
	return f
end
