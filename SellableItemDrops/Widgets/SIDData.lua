------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Widgets/SIDData - an Ace3 Data Widget
--
-- Author: Caraxe/Expelliarmuuuuus
-- based von AceGUI-3.0/AceGUIContainer-ScrollFrame.lua
--
-- Version 0.4.9
------------------------------------------------------------------------------
local Type, Version = "SIDData", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
------------------------------------------------------------------------------

-- Lua APIs
local pairs, assert, type = pairs, assert, type
local min, max, floor = math.min, math.max, math.floor

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function pr(msg)
	-- DEFAULT_CHAT_FRAME:AddMessage(msg)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		pr("OnAcquire")
		self.content = nil
		self.titles = nil
		self.doRedraw = true
		self.lastDataLines = 0
		self.lastWidth = 0
	end,

	["OnRelease"] = function(self)
		pr("OnRelease")
		wipe(self.titles)
		wipe(self.content)
		wipe(self.eventHandlers)
		self.doRedraw = false
	end,

	["OnWidthSet"] = function(self, width)
		if self.doRedraw then
			self:Redraw()
		end
	end,

	["OnHeightSet"] = function(self, height)
		if self.doRedraw then
			self:Redraw()
		end
	end,

	["DoRedraw"] = function(self, flag)
		self.doRedraw = flag or false
		if flag then
			self:Redraw()
		end
	end,

	["SetTitles"] = function(self, titles)
		self.titles = titles or {}
		if self.doRedraw then
			self:Redraw()
		end
	end,

	["SetContent"] = function(self, content)
		self.content = content or {}
		self.sortIt = true
		if self.doRedraw then
			self:RefreshContent()
		end
	end,

	["SetTextSize"] = function(self, size)
		self.textSize = size
		self.frameHeight = self.textSize + 1
		if self.doRedraw then
			self:Redraw()
		end
	end,

	["SetSortTitle"] = function(self, title)
		self.sortTitle = abs(title or 1)
		self.sortDir = not title or title > 0
		self.sortIt = true
	end,

	["RefreshContent"] = function(self)
		-- pr("RefreshContent")
		if not self.content or not self.dataLines or not self.dataFrames then return end

		FauxScrollFrame_Update(self.scrollFrame, #self.content, self.dataLines, self.textSize + 2)
		local offset = FauxScrollFrame_GetOffset(self.scrollFrame)

		if self.sortIt and self.content and self.sortTitle then
			sort(self.content,
				function (a, b)
					if self.sortDir then
						return a.data[self.sortTitle][2] < b.data[self.sortTitle][2]
					else
						return a.data[self.sortTitle][2] > b.data[self.sortTitle][2]
					end
				end)
			self.sortIt = nil
		end

		for i=1, self.dataLines do
			self.dataFrames[i].data = nil
			if i > #self.content then
				self.dataFrames[i]:Hide()
			else
				self.dataFrames[i]:Show()
				local data = self.content[i+offset]
				if not data then break end
				self.dataFrames[i].data = data

				for j, dataButton in ipairs(self.dataFrames[i].dataButtons) do
					if self.titles[j] then
						if data.data[j] then
							dataButton:SetText(data.data[j][1])
						else
							dataButton:SetText("")
						end
					end
				end
			end
		end
	end,

	["Redraw"] = function(self)
		if not self.titles then return end

		self.redrawCnt = (self.redrawCnt + 1) or 1

		local width = self.frame:GetWidth() - 14
		local height = self.frame:GetHeight()
		self.dataLines = floor((self.frame:GetHeight() - (self.textSize + 3))/ self.frameHeight) or 0
		-- pr("Redraw(" .. tostring(self.redrawCnt) .. ",f=" .. tostring(self.frame) .. "): GetHeight=" .. tostring(self.frame:GetHeight()) .. " textSize=" .. tostring(self.textSize))

		if (self.dataLines == self.lastDataLines) then
			if (self.lastWidth > (width - 10)) and (self.lastWidth < (width + 10))then
				-- pr("Redraw(" .. tostring(self.redrawCnt) .. " no change of dataLines=" .. tostring(self.dataLines))
				self:RefreshContent()
				return
			end
		end
		self.lastDataLines = self.dataLines
		self.lastWidth = width

		-- pr("Redraw(" .. tostring(self.redrawCnt) .. "): #buttons=" .. tostring(#self.titleButtons) .. " #titles=" .. tostring(#self.titles))
		self.titleButtons = self.titleButtons or {}
		while #self.titleButtons < #self.titles do
			self:NewTitleButton()
		end
		for i, titleButton in ipairs(self.titleButtons) do
			if self.titles[i] then
				titleButton:Show()
				titleButton:SetHeight(self.frameHeight)
				titleButton:SetWidth(abs(self.titles[i].relWidth) * width)
				titleButton:SetText(self.titles[i].text or "")
			else
				titleButton:Hide()
			end
		end

		-- pr("Redraw(" .. tostring(self.redrawCnt) .. "): #frames=" .. tostring(#self.dataFrames) .. " cnt=" .. tostring(self.dataLines))
		self.dataFrames = self.dataFrames or {}
		while #self.dataFrames < self.dataLines do
			self:NewDataFrame()
		end
		for i, dataFrame in ipairs(self.dataFrames) do
			if i > self.dataLines then
				dataFrame.data = nil
				dataFrame:Hide()
			else
				dataFrame:Show()

				dataFrame.dataButtons = dataFrame.dataButtons or {}
				while #dataFrame.dataButtons < #self.titles do
					self:NewDataButton(i)
				end
				for j, dataButton in ipairs(dataFrame.dataButtons) do
					if self.titleButtons[j] and self.titles[j] then
						dataButton:Show()
						dataButton:SetWidth(abs(self.titles[j].relWidth) * width)
						if self.titles[j].relWidth < 0 then
							dataButton.text:SetJustifyH("RIGHT")
						end
					else
						dataButton:Hide()
					end
				end
			end
		end

		self:RefreshContent()
	end,

	["NewDataButton"] = function(self, i)
		local dataFrame = self.dataFrames[i]
		local btnCnt = #dataFrame.dataButtons + 1
		local button = CreateFrame("Button", nil, dataFrame)

		if btnCnt == 1 then
			button:SetPoint("TOPLEFT")
		else
			button:SetPoint("TOPLEFT", dataFrame.dataButtons[btnCnt-1], "TOPRIGHT")
		end

		button.text = button:CreateFontString()
		button.text:SetFont(GameFontNormal:GetFont(), self.textSize)
		button.text:SetJustifyV("CENTER")
		button.text:SetJustifyH("LEFT")
		button.text:SetPoint("TOPLEFT", 1, -1)
		button.text:SetPoint("BOTTOMRIGHT", -1, 1)
		button:SetFontString(button.text)
		button:SetHeight(self.frameHeight)

		button:SetScript("OnEnter",
			function(btn, ...)
				if not dataFrame.data then return end
				dataFrame.glow:Show()
				if self.eventHandlers.OnEnter then
					self.eventHandlers.OnEnter(btn, dataFrame.data, ...)
				end
			end)
		button:SetScript("OnLeave" ,
			function(btn, ...)
				if not dataFrame.data then return end
				dataFrame.glow:Hide()
				if self.eventHandlers.OnLeave then
					self.eventHandlers.OnLeave(btn, dataFrame.data, ...)
				end
			end)
		button:RegisterForClicks("AnyUp")
		button:SetScript("OnClick",
			function(btn, ...)
				if not dataFrame.data then return end
				dataFrame.glow:Show()
				if self.eventHandlers.OnClick then
					self.eventHandlers.OnClick(btn, dataFrame.data, ...)
				end
			end)

		tinsert(dataFrame.dataButtons, button)
	end,

	["NewTitleButton"] = function(self)
		local btnCnt = #self.titleButtons + 1
		local button = CreateFrame("Button", nil, self.contentFrame)

		if btnCnt == 1 then
			button:SetPoint("TOPLEFT")
		else
			button:SetPoint("TOPLEFT", self.titleButtons[btnCnt-1], "TOPRIGHT")
		end

		button.text = button:CreateFontString()
		button.text:SetFont(GameFontNormal:GetFont(), self.textSize)
		button.text:SetJustifyV("CENTER")
		button.text:SetJustifyH("LEFT")
		button.text:SetAllPoints()
		button:SetFontString(button.text)

		local glow = button:CreateTexture()
		glow:SetAllPoints()
		glow:SetColorTexture(1, 0.3, 0.3, 0.5)
		button:SetHighlightTexture(glow);

		button:RegisterForClicks("AnyUp")
		button:SetScript("OnClick",
			function (btnself, button, ...)
				if button == "LeftButton" then
					if self.sortTitle == btnself.btnCnt then
						self.sortDir = not self.sortDir
					else
						self.sortTitle = btnself.btnCnt
						self.sortDir = true
					end
					self.sortIt = true
					self:RefreshContent()
				else
					if self.eventHandlers.OnClick then
						self.eventHandlers.OnClick(btnself, btnCnt, button, ...)
					end
				end
			end)
		button:SetScript("OnEnter",
			function(btn, ...)
				if self.eventHandlers.OnEnter then
					self.eventHandlers.OnEnter(btn, ...)
				end
			end)
		button:SetScript("OnLeave" ,
			function(btn, ...)
				if self.eventHandlers.OnLeave then
					self.eventHandlers.OnLeave(btn, ...)
				end
			end)

		button.btnCnt = btnCnt
		tinsert(self.titleButtons, button)
	end,

	["NewDataFrame"] = function(self)
		local frmCnt = #self.dataFrames + 1
		local dataFrame = CreateFrame("Frame", nil, self.contentFrame)

		dataFrame:SetHeight(self.frameHeight)
		if frmCnt == 1 then
			dataFrame:SetPoint("TOPLEFT", 0, - (self.textSize + 4))
			dataFrame:SetPoint("TOPRIGHT", 0, - (self.textSize + 4))
		else
			dataFrame:SetPoint("TOPLEFT", self.dataFrames[frmCnt-1], "BOTTOMLEFT")
			dataFrame:SetPoint("TOPRIGHT", self.dataFrames[frmCnt-1], "BOTTOMRIGHT")
		end

		local glow = dataFrame:CreateTexture()
		glow:SetAllPoints()
		glow:SetColorTexture(1, 0, 0.1, 0.1)
		glow:Hide()
		dataFrame.glow = glow

		if (frmCnt % 2) == 1 then
			local ntex = dataFrame:CreateTexture()
			ntex:SetAllPoints()
			ntex:SetColorTexture(0, 0, 0, 0.3)
		else
			local ntex = dataFrame:CreateTexture()
			ntex:SetAllPoints()
			ntex:SetColorTexture(0, 0, 0, 0.1)
		end

		tinsert(self.dataFrames, dataFrame)
	end,

	["SetEventHandlers"] = function(self, ...)
		local eventHandlers = ...
		self.eventHandlers = self.eventHandlers or {}
		for event, handler in pairs(eventHandlers) do
			self.eventHandlers[event] = handler
		end
	end,

}
--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", Type .. num, UIParent)
	frame:SetAllPoints()

	pr("Constructor: Type " .. Type .. " #" .. tostring(num))

	local widget = {
		frame = frame,
		type = Type,

		textSize = 11,
		frameHeight = 11 + 1,
		titles = nil,
		content = nil,
		eventHandlers = nil,
		titleButtons = nil,
		dataFrames = nil,
		dataLines = nil,
		contentFrame = nil,
		scrollFrame = nil,
		sortTitle = nil,
		sortDir = nil,
		sortIt = nil,
		redrawCnt = 0,
	}

	for method, func in pairs(methods) do
		widget[method] = func
	end

	local contentFrame = CreateFrame("Frame", Type .. num .. "Content", frame)
	contentFrame:SetPoint("TOPLEFT", 0, -1)
	contentFrame:SetPoint("BOTTOMRIGHT", 0, 0)
	widget.contentFrame = contentFrame

	local scrollFrame = CreateFrame("ScrollFrame", Type .. num .. "ScrollFrame", frame, "FauxScrollFrameTemplate")
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, widget.textSize + 2, function() widget.RefreshContent(widget) end)
	end)
	scrollFrame:SetAllPoints(contentFrame)
	widget.scrollFrame = scrollFrame

	local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
	scrollBar:ClearAllPoints()
 	scrollBar:SetPoint("TOPRIGHT", frame, -2, - _G[scrollBar:GetName().."ScrollUpButton"]:GetHeight() - (widget.textSize + 6))
	scrollBar:SetPoint("BOTTOMRIGHT", frame, -2, _G[scrollBar:GetName().."ScrollDownButton"]:GetHeight())

	local line = frame:CreateTexture()
	line:ClearAllPoints()
	line:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, - (widget.textSize + 3))
	line:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, - (widget.textSize + 3))
	line:SetHeight(1)
	line:SetColorTexture(1, 0.5, 0.5, 0.4)

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

-- EOF
