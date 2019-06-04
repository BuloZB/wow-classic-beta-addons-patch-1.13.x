------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/GUI.lua - Interface
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local GUI = addon:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

GUI.frScaleValue = 0.8
GUI.view = nil
GUI.isShrinked = false
GUI.lastWidth = 0
GUI.rarityList = {}
for i = 0, 8 do
	GUI.rarityList[i] = ITEM_QUALITY_COLORS[i].hex ..
		_G[format("ITEM_QUALITY%d_DESC", i)] ..
		FONT_COLOR_CODE_CLOSE
end

GUI.timeFormat = {}
GUI.timeFormat["ago"]  = L["_ Hr. _ Min. ago"]
GUI.timeFormat["%d.%m.%Y %H:%M:%S"] = "DD.MM.YYYY HH:MM"
GUI.timeFormat["%Y-%m-%d %H:%M:%S"] = "YYYY-MM-DD HH:MM"

GUI.guiTabs = {
	texts = {
		["session"] = {title=L["Session"], desc=L["Current Session"]},
		["history"] = {title=L["History"], desc=L["Database"]},
		["challenges"] = {title=[[Challenges]], desc=[[T.B.D.]]},
		["inventory"] = {title=L["Bags"], desc=L["Bags"]},
		-- ["tools"] = {title=L["Tools"], desc=L["T.B.D."]},
		["information"] = {title=L["Information"], desc=L["Information"]},
	},
	order = { "session", "history", "inventory", "information"},
}

GUI.guiTabsSelect = {}

private.TITLEWIDTH_ITEM = 0.31
private.TITLEWIDTH_VALUE = 0.17
private.TITLEWIDTH_QTY = 0.04
private.TITLEWIDTH_PLAYER = 0.10
private.TITLEWIDTH_ZONE = 0.20
private.TITLEWIDTH_TIME = 0.18
private.TITLEWIDTH_GAP = 0.01

private.adapt = private.adapt or {}

-- printing debug info
function GUI:DebugPrintf(...)
	if addon.isDebug then
		GUI:Printf(...)
	end
end

-- print info on loaded session data
function GUI:ShowInfo()
	if ((addon.db.realm.sesTime + 3 >= time()) and addon.db.realm.sesEnd == 0) then
		addon:Printf(L["Starting a new session."])
	elseif (addon.db.realm.sesEnd == 0) then
		addon:Printf(L["Continuing a previous session. Current Looted Item Value is %s"], GetCoinTextureString(addon.db.realm.sesMV))
	else
		addon:Printf(L["Session is stopped. A new session starts after saving or wiping the current session data."])
	end
	addon:Printf(L["  Quality filter is >=%s."], GUI.rarityList[addon.db.global.minRarity])
	addon:Printf(L["  Noteworthy items are worth >%s."], addon.db.global.minNoteworthy)
	mvSourcesList = addon.Item:GetPriceSources() or {}
	addon:Printf(L["  Price source is '%s'."],
		mvSourcesList[addon.db.global.mvSource] or addon.db.global.mvSource)
	addon:Print(L["Good luck farming items!"])
end

-- set main windows status line
function GUI:SetStatusLine(txt)
	if GUI.display then
		GUI.display:SetStatusText(txt)
	end
end

-- print info on ItemStrings
function GUI:PrintItemStrings(link)
	if not link then
		return
	end

	local q = addon.Item:GetItemQuality(link)
	if not q then
		q = 6
	end

	local l = ""
	if type(link) == "string" and link:match("^\124(.+)\124h") then
		l = gsub(link, "\124", "/")
		l = "L=" .. ITEM_QUALITY_COLORS[q].hex .. l .. FONT_COLOR_CODE_CLOSE .. " "
	end

	GUI:Printf("%sI=%s%s%s IB=%s%s%s ID=%s%s%s",
			l,
			ITEM_QUALITY_COLORS[q].hex,
			addon.Item:GetItemString(link) or "nil",
			FONT_COLOR_CODE_CLOSE,
			ITEM_QUALITY_COLORS[q].hex,
			addon.Item:GetBaseItemString(link) or "nil",
			FONT_COLOR_CODE_CLOSE,
			ITEM_QUALITY_COLORS[q].hex,
			tostring(addon.Item:GetItemID(link) or "nil"),
			FONT_COLOR_CODE_CLOSE
			)
end

-- return formatted time
function GUI:TimeToString(t)
	local res
	if addon.db.global.timeFormat == "ago" then
		local lTime = time() - t
		if (lTime == 0) then
			res = L["now"]
		else
			if GUI.display and private.adapt.width and private.adapt.width <= 600 then
				if (floor(lTime / 60) * 60) == 0 then
					res = L["now"]
				else
					res = format(L["%s ago"],  SecondsToTime(floor(lTime / 60) * 60) or "?")
				end
			else
				res = format(L["%s ago"],  SecondsToTime(lTime) or "?")
			end
		end
	elseif (addon.db.global.timeFormat) then
		if GUI.display and private.adapt.width and private.adapt.width <= 600 then
			if addon.db.global.timeFormat == "%Y-%m-%d %H:%M:%S" then
				res = date("%H:%M:%S", t)
			end
			if addon.db.global.timeFormat == "%d.%m.%Y %H:%M:%S" then
				res = date("%H:%M:%S", t)
			end
		else
			res = date(addon.db.global.timeFormat or addon.timeFormat, t)
		end
	end
	res = private.ShrinkTime(res)
	return res
end

-- parse money string to copper
function GUI:ToCopper(str)
	local c = tonumber(strmatch(str, "([0-9]+)c"))
	local s = tonumber(strmatch(str, "([0-9]+)s"))
	local g = tonumber(strmatch(str, "([0-9]+)g"))
	if not c and not s and not g then return end

	local copper = (c or 0)
	copper = copper + (s or 0) * COPPER_PER_SILVER
	copper = copper + (g or 0) * COPPER_PER_GOLD

	return copper
end

-- build money string from copper
function GUI:FromCopper(copper, isVS)
	if not tonumber(copper) then return end

	local g = floor(copper / COPPER_PER_GOLD)
	local s = floor((copper - (g * COPPER_PER_GOLD)) /  COPPER_PER_SILVER)
	local c = copper - (g * COPPER_PER_GOLD) - (s * COPPER_PER_SILVER)

	local result = ""
	
	local vsC = ""
	local vsR = ""
	if isVS then
		vsC = ITEM_QUALITY_COLORS[7].hex	
		vsR = FONT_COLOR_CODE_CLOSE
	end
	
	if not addon.db.global.discardSilver then
		if not addon.db.global.discardCopper then
			if (s > 0) or (g > 0) then
				result = vsC .. format("%02d", c) .. vsR .. "|cffeda55fc|r"
			else
				result = vsC .. format("%d", c) .. vsR .. "|cffeda55fc|r"
			end
		end
		if g > 0 then
			result = vsC .. format("%02d", s) .. vsR .. "|cffc7c7cfs|r " .. result
		else
			if s > 0 then
				result = vsC .. format("%d", s) .. vsR .. "|cffc7c7cfs|r " .. result
			end
		end
	end
	if g > 0 then
		local gs = tostring(g)
		gs = gsub(gs, "(%d)(%d%d%d)$", "%1" .. LARGE_NUMBER_SEPERATOR .. "%2")
		result = vsC .. gs .. vsR .. "|cffffd70ag|r " .. result
	end

	return result
end

------------------------------------------------------------------------------
-- Tabs

-- call selected tab
GUI.guiTabsOnSelected = function(container, event, group)
	GUI:DebugPrintf("guiTabsOnSelected: %s", group)
	if not container then
		GUI:DebugPrintf("guiTabsOnSelected: container is nil")
	end

	container:ReleaseChildren()
	GUI.guiTabs.lastSelected = group
	if GUI.guiTabsSelect[group] then
		GUI.view = group
		GUI.container = container
		GUI.guiTabsSelect[group](container, group)
	end
end

-- do things on logout
function GUI:OnLogout()
	if private.adapt then
		if private.adapt.shPlayer ~= nil then
			addon.db.global.shPlayer = private.adapt.shPlayer
		end
		if private.adapt.shZone ~= nil then
			addon.db.global.shZone = private.adapt.shZone
		end
	end
end

-- load GUI with last selected tab
function GUI:Load(optSelectTab)
	GUI:DebugPrintf("Load()")

	-- prepare blacklisted and vendorsell items
	addon.Data:IsBlacklisted("")
	addon.Data:IsVendorsell("")

	-- check if the currently used price source is available and check for sanity of options
	addon:CheckSettings()

	-- create main window
	if not GUI.display then
		GUI:DebugPrintf("Load(): create new frame")

		local display = AceGUI:Create("SIDFrame")
		addon.db.global.ui = addon.db.global.ui or {}
		display:SetStatusTable(addon.db.global.ui)

		local title = "|cFF33FF99" .. addon.METADATA.NAME .. " (" .. addon.METADATA.VERSION .. ")|r"
		display:SetTitle(title)
		display:SetLayout("Fill")
		display:SetStatusText("--")
		display:EnableResize(true)
		display:SetCallback("OnClose", function(_display)
			GUI:DebugPrintf("OnClose(%s)", tostring(_display.frame))
			AceGUI:Release(_display)
			GUI.display = nil
			-- collectgarbage()
		end)

		private.adapt.width = display.frame:GetWidth()
		-- GUI:Printf("GetWidth()=%s", private.adapt.width)
		if display and display.OnWidthSet then
			local ows = display.OnWidthSet
			display.OnWidthSet = function(_self, _width)
				ows(_self, _width)
				-- GUI:Printf("OnWidthSet=%s", _width)
				if private and private.adapt then
					private.adapt.width = _width
				end
			end
		end

		GUI.display = display
	end

	if #GUI.display.children > 0 then
		GUI.display:ReleaseChildren()
	end

	local fmtstr = #GUI.guiTabs.order > 6 and " %s s" or "   %s   "
	for i, name in ipairs(GUI.guiTabs.order) do
		GUI.guiTabs[i] = {
			value = name,
			text = fmtstr:format(GUI.guiTabs.texts[name].title),
			disabled = GUI.guiTabs.texts[name].disabled,
		}
	end

	local tabs = AceGUI:Create("SIDTabGroup")
	tabs:SetLayout("Flow")
	tabs:SetTabs(GUI.guiTabs)
	tabs:SetCallback("OnGroupSelected", GUI.guiTabsOnSelected)
	tabs:SetCallback("OnTabEnter", function(_tabs,event,value,tab)
		GUI:SetStatusLine(GUI.guiTabs.texts[value].desc)
	end)
	tabs:SetCallback("OnTabLeave", function() GUI:SetStatusLine("") end)

	GUI.display:AddChildren(tabs)

	if optSelectTab and optSelectTab ~= "" then
		tabs:SelectTab(optSelectTab)
	else
		GUI.guiTabs.lastSelected = GUI.guiTabs.lastSelected or GUI.guiTabs.order[1]
		tabs:SelectTab(GUI.guiTabs.lastSelected)
	end

	GUI.display:Show()

	-- GUI:Printf("GUI.isShrinked=%s", tostring(GUI.isShrinked))
	if GUI.isShrinked then
		if GUI.view == "session" then
			GUI.isShrinked = false
			GUI:Shrink(true)
			GUI.lastWidth = 0
		end
	else
		GUI.isShrinked = false
	end

	return GUI.display
end

function GUI:Shrink(flag)
	-- GUI:Printf("Shrink(%s)", tostring(flag))
	if flag and not GUI.isShrinked then
		-- GUI:Printf("  shrink it!")
		-- FIXME: release children
		GUI.isShrinked = true
		GUI.container:SelectTab("session")
		GUI.container.tablist[5] = nil
		GUI.container.tablist[4] = nil
		GUI.container.tablist[3] = nil
		GUI.container.tablist[2] = nil
		GUI.container.tablist[1] = nil
		GUI.container:BuildTabs()
		GUI.container.border:SetPoint("TOPLEFT", 1, - 8)
		GUI.lastWidth = GUI.container.frame:GetWidth()
		return
	end
	if not flag and GUI.isShrinked then
		-- GUI:Printf("  unshrink it!")
		GUI.isShrinked = false
		GUI:Load()
		return
	end
end

------------------------------------------------------------------------------
-- Session Tab

-- create session tab
GUI.guiTabsSelect["session"] = function(container, group)
	GUI:DebugPrintf("Select Tab %s: %s", group, tostring(container))
	if not container then
		GUI:DebugPrintf("Select Tab: container is nil")
	end

	-- min. Size
	GUI.display.frame:SetMinResize(390, 240)

	-- Filter: default filter is empty
	GUI.sesFilters = {}

	-- variants
	local flNotTheRealItemString = ""
	if (addon.db.global.useNotTheRealItemString) then
		flNotTheRealItemString = ITEM_QUALITY_COLORS[5].hex .. L[" (! = variant)"] .. FONT_COLOR_CODE_CLOSE
	end

	if (CanIMogIt) then
		flNotTheRealItemString = flNotTheRealItemString .. " " .. ITEM_QUALITY_COLORS[5].hex .. L[" (TM = New Transmog)"] .. FONT_COLOR_CODE_CLOSE
	end

	local nextLapPopupText = L["Click to start a new lap."]
	if (addon.db.global.lpInstanceReset) then
		nextLapPopupText = L["Click to start a new lap and reset all instances."]
	end

	-- session control group
	local grp1
	if not GUI.isShrinked then
		grp1 = AceGUI:Create("SIDInlineGroup")
		grp1:SetLayout("Flow")
		if grp1.SetTitle then
			grp1:SetTitle(L["Session Control"])
		end
		grp1:SetFullWidth(true)
	else
		grp1 = AceGUI:Create("SimpleGroup")
		grp1:SetLayout("Flow")
		grp1:SetFullWidth(true)
	end

	local grpWidth = 1
	local grpColNum = 5.01
	local grpRelWidth = grpWidth / grpColNum

	-- session control group - line 1
	GUI.lblSes = {}
	GUI.lblSes.startTime = private.AddButton("Label", L["Session Start"], "-")
	GUI.lblSes.startTime:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.lblSes.startTime)

	GUI.lblSes.durationLap = private.AddButton("Label", L["Duration / Lap #"], "-")
	GUI.lblSes.durationLap:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.lblSes.durationLap)

	GUI.lblSes.livGold = private.AddButton("Label", L["LIV / Gold"], "-")
	GUI.lblSes.livGold:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.lblSes.livGold)

	GUI.lblSes.source = private.AddButton("Label", L["Price Source"], "-")
	GUI.lblSes.source:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.lblSes.source)

	GUI.lblSes.itemsNw = private.AddButton("Label", "-", "-")
	GUI.lblSes.itemsNw:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.lblSes.itemsNw)

	-- session control group - line 2
	GUI.infoSes = {}
	GUI.infoSes.startTime = private.AddButton("Label", "-", "-")
	GUI.infoSes.startTime:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.infoSes.startTime)

	GUI.infoSes.durationLap = private.AddButton("Label", "-", "-")
	GUI.infoSes.durationLap:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.infoSes.durationLap)

	GUI.infoSes.liv = private.AddButton("Label", "-", "-")
	GUI.infoSes.liv:SetRelativeWidth(grpRelWidth)

	GUI.infoSes.liv.label:SetJustifyH("RIGHT")
	GUI.labelFont, GUI.labelFontSize = GUI.infoSes.liv.label:GetFont()
	if not GUI.isShrinked then
		GUI.infoSes.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
	end
	grp1:AddChild(GUI.infoSes.liv)

	GUI.infoSes.source = private.AddButton("Label", "-", "-")
	GUI.infoSes.source:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.infoSes.source)

	GUI.infoSes.itemsNw = private.AddButton("Label", "-", "-")
	GUI.infoSes.itemsNw:SetRelativeWidth(grpRelWidth)
	grp1:AddChild(GUI.infoSes.itemsNw)

	-- session control group - line 3
	GUI.btnSes = {}
	GUI.btnSes.stop = private.AddButton(L["Stop"], L["Stop the current session."])
	if GUI.isShrinked then
		GUI.btnSes.stop:SetText(L["STOP"])
	end

	GUI.btnSes.stop:SetRelativeWidth(grpRelWidth)
	GUI.btnSes.stop:SetCallback("OnClick",
		function()
			if (addon.db.realm.sesEnd == 0) then
				-- Stop Session
				addon.db.realm.sesEnd = time()
				addon:Printf(L["Stopping the session after %s. Click 'Save' or 'Wipe' to start a new one."],
					SecondsToTime(addon.db.realm.sesEnd - addon.db.realm.sesTime))
			else
				addon:Printf(L["Session has been stopped %s ago. Click 'Save' or 'Wipe' to start a new one."], SecondsToTime(time() - addon.db.realm.sesEnd))
			end
		end
	)
	grp1:AddChild(GUI.btnSes.stop)

	GUI.btnSes.lap = private.AddButton(L["Next"], nextLapPopupText)
	if GUI.isShrinked then
		GUI.btnSes.lap:SetText(L["NEXT"])
	end
	GUI.btnSes.lap:SetRelativeWidth(grpRelWidth)
	GUI.btnSes.lap:SetCallback("OnClick",
		function()
			if (addon.db.realm.sesEnd == 0) then
				addon.db.realm.lapTime = time()
				addon.db.realm.lapNum = addon.db.realm.lapNum + 1
				GUI.sesFilters = {}
				if (addon.db.global.nwSound ~= "") then
					addon.Options.PlaySound()
				end
				if (addon.db.global.lpInstanceReset) then
					ResetInstances()
					addon:Printf(L["Resetting the instance."])
				end
				addon:Printf(L["Finishing lap #%s with Looted Item Value %s."],
					addon.db.realm.lapNum - 1, GetCoinTextureString(addon.db.realm.sesMV))
				container:Reload()
			else
				addon:Printf(L["Can't start lap of a stopped session."])
			end
		end
	)
	grp1:AddChild(GUI.btnSes.lap)

	GUI.btnSes.gold = private.AddButton("Label", "-", "-")
	GUI.btnSes.gold:SetRelativeWidth(grpRelWidth)
	GUI.btnSes.gold.label:SetJustifyH("RIGHT")
	if not GUI.isShrinked then
		GUI.btnSes.gold.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
	end
	grp1:AddChild(GUI.btnSes.gold)

	GUI.btnSes.save = private.AddButton(L["Save"], L["Save the current session and start a new one."])
	if GUI.isShrinked then
		GUI.btnSes.save:SetText(L["SAVE"])
	end
	GUI.btnSes.save:SetRelativeWidth(grpRelWidth)
	GUI.btnSes.save:SetCallback("OnClick",
		function()
			if (addon.db.global.nwSound ~= "") then
				addon.Options.PlaySound()
				GUI:DebugPrintf("Play %s", addon.db.global.nwSound)
			end
			addon.Data:SessionToDatabase()
			GUI.sesFilters = {}
			addon.Data:WipeSession()
			GUI:ShowInfo()
			addon:UpdateBroker()
			addon.Data:ResetCurrentTag(true)
			container:Reload()
		end
	)
	grp1:AddChild(GUI.btnSes.save)

	GUI.btnSes.wipe = private.AddButton(L["Wipe"], L["Wipe the current session data and start a new session."])
	if GUI.isShrinked then
		GUI.btnSes.wipe:SetText(L["WIPE"])
	end
	GUI.btnSes.wipe:SetRelativeWidth(grpRelWidth)
	GUI.btnSes.wipe:SetCallback("OnClick",
		function()
			if (addon.db.global.nwSound ~= "") then
				addon.Options.PlaySound()
			end
			GUI.sesFilters = {}
			addon.Data:WipeSession()
			GUI:ShowInfo()
			addon:UpdateBroker()
			container:Reload()
		end
	)
	grp1:AddChild(GUI.btnSes.wipe)

	container:AddChild(grp1)

	-- session data group
	local grp2

	if not GUI.isShrinked then
		grp2 = AceGUI:Create("SIDInlineGroup")
		grp2:SetLayout("Flow")
		if grp2.SetTitle then
			grp2:SetTitle(L["Session Data"])
		end
		grp2:SetFullWidth(true)
		grp2:SetFullHeight(true)
	else
		grp2 = AceGUI:Create("SimpleGroup")
		grp2:SetLayout("Flow")
		grp2:SetFullWidth(true)
		grp2:SetFullHeight(true)
	end

	if not GUI.isShrinked then
		local grp3 = AceGUI:Create("SimpleGroup")
		grp3:SetLayout("Flow")
		grp3:SetFullWidth(true)

		grpWidth = 1
		grpColNum = 4.01
		if not addon.db.global.shPlayer then
			grpColNum = grpColNum - 1
		end

		if not addon.db.global.shZone then
			grpColNum = grpColNum - 1
		end

		grpRelWidth = grpWidth / grpColNum

		-- session data group - line 1
		local i = private.AddButton("Label", L["Search"], "-")
		i:SetRelativeWidth(grpRelWidth)
		grp3:AddChild(i)

		i = private.AddButton("Label", L["Rarity"], "-")
		i:SetRelativeWidth(grpRelWidth)
		grp3:AddChild(i)

		if addon.db.global.shPlayer then
			i = private.AddButton("Label", L["Player"], "-")
			i:SetRelativeWidth(grpRelWidth)
			grp3:AddChild(i)
		end

		if addon.db.global.shZone then
			i = private.AddButton("Label", L["Zone"], "-")
			i:SetRelativeWidth(grpRelWidth)
			grp3:AddChild(i)
		end
		grp2:AddChild(grp3)

		grp3 = AceGUI:Create("SimpleGroup")
		grp3:SetLayout("Flow")
		grp3:SetFullWidth(true)

		-- session data group - line 2
		i = private.AddButton("SIDEditBox", "", "-")
		i:SetRelativeWidth(grpRelWidth)
		i.button:SetScript("OnClick", function(f) 
			local editbox = f.obj.editbox
			editbox:SetText("")
			editbox:SetCursorPosition(0)
			editbox:ClearFocus()
			f.obj:DisableButton(true)
			f.obj:Fire("OnTextChanged", "")
		end)
		i.button:SetText(L["CLR"])
		i:SetCallback("OnTextChanged",
			function(f, _, value)
				value = value:trim()
				if value == "" then
					GUI.sesFilters.name = nil
				else
					GUI.sesFilters.name = value
					f:DisableButton(false)
				end
				GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
				private.GetSessionInfoData(GUI.sesFilters)
			end
		)
		grp3:AddChild(i)

		i = private.AddButton("Dropdown", L["Rarity"], "-")
		i:SetRelativeWidth(grpRelWidth)
		i:SetList(GUI.rarityList)
		i:SetCallback("OnValueChanged",
			function(_, _, key)
				if key > 0 then
					GUI.sesFilters.rarity = key
				else
					GUI.sesFilters.rarity = nil
				end
				GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
				private.GetSessionInfoData(GUI.sesFilters)
			end
		)
		grp3:AddChild(i)

		if addon.db.global.shPlayer then
			i = private.AddButton("Dropdown", L["Player"], "-")
			i:SetRelativeWidth(grpRelWidth)
			i:SetList(private.playerListFromItems(addon.sesItems))
			local value = "all"
			i:SetText(i.list[value])
			i.value = value
			i:SetCallback("OnValueChanged",
				function(_, _, value)
					if value == "all" then
						GUI.sesFilters.player = nil
					else
						GUI.sesFilters.player = value
					end
					GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
					private.GetSessionInfoData(GUI.sesFilters)
				end
			)
			grp3:AddChild(i)
		end

		if addon.db.global.shZone then
			i = private.AddButton("Dropdown", L["Zone"], "-")
			i:SetRelativeWidth(grpRelWidth)
			i:SetList(private.zoneListFromItems(addon.sesItems))
			local value = "all"
			i:SetText(i.list[value])
			i.value = value
			i:SetCallback("OnValueChanged",
				function(_, _, value)
					if value == "all" then
						GUI.sesFilters.zone = nil
					else
						GUI.sesFilters.zone = value
					end
					GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
					private.GetSessionInfoData(GUI.sesFilters)
				end
			)
			grp3:AddChild(i)
		end
		grp2:AddChild(grp3)
	end

	-- session data group - item list
	local grp4 = AceGUI:Create("SimpleGroup")
	grp4:SetLayout("Fill")
	grp4:SetFullWidth(true)
	grp4:SetFullHeight(true)

	local titles = {}
	titles = {
		{text=L["Item"] .. flNotTheRealItemString, relWidth=private.TITLEWIDTH_ITEM},
		{text=L["Item Value"], relWidth=-private.TITLEWIDTH_VALUE},
		{text=L["Qty"], relWidth=-private.TITLEWIDTH_QTY},
		{text=L["Player"], relWidth=private.TITLEWIDTH_PLAYER},
		{text=L["Zone"], relWidth=private.TITLEWIDTH_ZONE},
		{text=L["Time"], relWidth=private.TITLEWIDTH_TIME},
	}
	local colSpan = 0
	local colSpan2 = 6
	if (not addon.db.global.shPlayer) then
		colSpan = colSpan + private.TITLEWIDTH_PLAYER - private.TITLEWIDTH_GAP
		titles[4] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	if (not addon.db.global.shZone) then
		colSpan = colSpan + private.TITLEWIDTH_ZONE - private.TITLEWIDTH_GAP
		titles[5] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	if (not addon.db.global.shTime) then
		colSpan = colSpan + private.TITLEWIDTH_TIME - private.TITLEWIDTH_GAP
		titles[6] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	titles[1].relWidth = private.TITLEWIDTH_ITEM  + colSpan / colSpan2
	titles[2].relWidth = - private.TITLEWIDTH_VALUE - colSpan / colSpan2
	titles[3].relWidth = - private.TITLEWIDTH_QTY - colSpan / colSpan2
	if titles[4].text ~= "" then
		titles[4].relWidth = private.TITLEWIDTH_PLAYER + colSpan / colSpan2
	end
	if titles[5].text ~= "" then
		titles[5].relWidth = private.TITLEWIDTH_ZONE + colSpan / colSpan2
	end
	if titles[6].text ~= "" then
		titles[6].relWidth = private.TITLEWIDTH_TIME + colSpan / colSpan2
	end

	container.titleStatusText = {
		L["Leftclick to sort this column / Rightclick to show all columns"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort and Rightclick to hide Player column"],
		L["Leftclick to sort and RightClick to hide Zone column"],
		L["Leftclick to sort and RightClick to hide Time column"],
		}

	local eventHandlers = {
		OnEnter = private.DataFrame_OnEnter,
		OnLeave = private.DataFrame_OnLeave,
		OnClick = function(btn, data, button)
			if not data then return end
			if button == "LeftButton" then
				GUI:PrintItemStrings(data.link)
			end
			if button == "RightButton" and not IsAltKeyDown() then
				if type(data) == "number" then
					if data == 4 then
						addon.db.global.shPlayer = false
						container:Reload()
					end
					if data == 1 then
						addon.db.global.shPlayer = true
						addon.db.global.shZone = true
						addon.db.global.shTime = true
						container:Reload()
					end
					if data == 5 then
						addon.db.global.shZone = false
						container:Reload()
					end
					if data == 6 then
						addon.db.global.shTime = false
						GUI.dataSes:SetSortTitle(1)
						container:Reload()
					end
				end
			end
			-- purge the line/item
			if button == "RightButton" and IsAltKeyDown() then
				local qty = addon.Data:PurgeItem(data, addon.sesItems)
				if (qty > 0) then
					addon.Data:UpdateSession()
					GUI:UpdateSessionData(true)
					addon:Printf(L["%sx %s purged."], qty, data.link)
				end
			end
		end,
	}

	GUI.dataSes = AceGUI:Create("SIDData")
	GUI.dataSes:DoRedraw(false)
	-- GUI.dataSes:SetTextSize(11)
	GUI.dataSes:SetEventHandlers(eventHandlers)
	GUI.dataSes:SetTitles(titles)
	if addon.db.global.shTime then
		GUI.dataSes:SetSortTitle(-6)
	else
		GUI.dataSes:SetSortTitle(1)
	end
	grp4:AddChild(GUI.dataSes)

	grp2:AddChild(grp4)
	container:AddChild(grp2)

	GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
	GUI.dataSes:DoRedraw(true)

	private.GetSessionInfoData(GUI.sesFilters)
	addon:UpdateBroker()

	return container
end

-- prepare/update session item data
function private.GetSessionItemData(lfilters)
	GUI:DebugPrintf("GetSessionItemData()")
	if GUI.view ~= "session" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	return private.GetItemData(addon.sesItems, lfilters)
end

-- prepare/update session info data
function private.GetSessionInfoData(filters)
	GUI:DebugPrintf("GetSessionInfoData()")
	if GUI.view ~= "session" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	local mvFilter = 0
	local nwFilter = 0
	local itsSum = 0
	local itsFilter = 0
	local itSum = 0
	local itFilter = 0
	local isFiltered = false

	if (not filters.name and not filters.rarity and not filters.player and not filters.time and not filters.zone) then
		GUI:DebugPrintf("... with no filters")
	else
		GUI:DebugPrintf("... with filters")
		isFiltered = true
		for link, data in pairs(addon.sesItems) do
			if #data.drops > 0 then
				itsSum = itsSum + 1
			end
			if #data.drops > 0 and not private:IsItemFiltered(link, data, filters) then
				itsFilter = itsFilter + 1
				for _, record in ipairs(data.drops) do
					itSum = itSum + record.quantity
					if not private:IsRecordFiltered(record, filters) then
						itFilter = itFilter + record.quantity
						local marketValue = addon.Data:GetItemValue(record.link) or 0
						mvFilter = mvFilter + (marketValue * record.quantity)
						if GUI:ToCopper(addon.db.global.minNoteworthy) then
							if (marketValue > GUI:ToCopper(addon.db.global.minNoteworthy)) then
								nwFilter = nwFilter + record.quantity
							end
						end
					end
				end
			end
		end
	end

	if (isFiltered or (itsSum ~= itsFilter) or (itSum ~= itFilter)) then
		if ((GUI.infoSes) and (GUI.btnSes)) then
			-- Session Start Time
			GUI.lblSes.startTime:SetText(L["Data Source"])
			GUI.infoSes.startTime:SetText(ITEM_QUALITY_COLORS[5].hex ..
				L["Selection"]
				.. FONT_COLOR_CODE_CLOSE)
			-- Duration / Lap #
			GUI.lblSes.durationLap:SetText("")
			GUI.infoSes.durationLap:SetText("")
			-- LIV / Gold
			GUI.lblSes.livGold:SetText(L["LIV"])
			GUI.infoSes.liv:SetText(GUI:FromCopper(mvFilter))
			GUI.infoSes.liv.label:SetAllPoints()
			GUI.btnSes.gold:SetText("")
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoSes.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
			else
				GUI.infoSes.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
			-- Items / Noteworthy
			GUI.lblSes.itemsNw:SetText(ITEM_QUALITY_COLORS[addon.db.global.minRarity].hex .. L["Items"] .. FONT_COLOR_CODE_CLOSE ..
									" / " .. ">" .. addon.db.global.minNoteworthy)
			if GUI.isShrinked then
				GUI.lblSes.itemsNw:SetText(ITEM_QUALITY_COLORS[addon.db.global.minRarity].hex .. L["Items"] .. FONT_COLOR_CODE_CLOSE)
			end
			GUI.infoSes.itemsNw:SetText(ITEM_QUALITY_COLORS[6].hex ..
				itFilter .. " / " .. nwFilter
				..  FONT_COLOR_CODE_CLOSE)
		end
	else
		if ((GUI.infoSes) and (GUI.btnSes)) then
			-- Session Start Time
			GUI.lblSes.startTime:SetText(L["Session Start"])
			if GUI.isShrinked then
				GUI.lblSes.startTime:SetText(L["Start"])
			end

			GUI.infoSes.startTime:SetText(ITEM_QUALITY_COLORS[6].hex ..
				GUI:TimeToString(addon.db.realm.sesTime)
				.. FONT_COLOR_CODE_CLOSE)
			-- Duration / Lap #
			if (addon.db.realm.sesEnd == 0) then
				GUI.lblSes.durationLap:SetText(L["Duration / Lap #"])
				GUI.infoSes.durationLap:SetText(ITEM_QUALITY_COLORS[6].hex ..
					SecondsToTime(time() - addon.db.realm.sesTime) .. " / " .. addon.db.realm.lapNum
						.. FONT_COLOR_CODE_CLOSE)
				if GUI.isShrinked then
					GUI.lblSes.durationLap:SetText(L["Dur/Lap #"])
					local z = time() - addon.db.realm.sesTime
					if (z > 60) then
						z = floor(z / 60) * 60
					end
					GUI.infoSes.durationLap:SetText(ITEM_QUALITY_COLORS[6].hex ..
						private.ShrinkTime(SecondsToTime(z)) .. "/" .. addon.db.realm.lapNum
						.. FONT_COLOR_CODE_CLOSE)
				end
			else
				GUI.lblSes.durationLap:SetText(L["Duration"])
				GUI.infoSes.durationLap:SetText(ITEM_QUALITY_COLORS[6].hex ..
				SecondsToTime(addon.db.realm.sesEnd - addon.db.realm.sesTime)
				.. FONT_COLOR_CODE_CLOSE)
			end
			-- Looted Item Value / Gold
			GUI.lblSes.livGold:SetText(L["LIV / Gold"])
			GUI.infoSes.liv:SetText(GUI:FromCopper(addon.db.realm.sesMV))
			GUI.infoSes.liv.label:SetAllPoints()
			GUI.btnSes.gold:SetText(GUI:FromCopper(addon.db.realm.sesGold))
			GUI.btnSes.gold.label:SetAllPoints()
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoSes.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
				if GUI.isShrinked then
					local s = addon.db.global.mvSource
					s = gsub(s, "TSM:", "")
					s = gsub(s, "UJ:", "")
					s = gsub(s, "^UJ:", "")
					if s:match("^(..........)") then
						s = s:match("^(..........)")
					end
					GUI.infoSes.source:SetText(ITEM_QUALITY_COLORS[6].hex .. s .. FONT_COLOR_CODE_CLOSE)
				end
			else
				GUI.infoSes.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
			-- Items / Noteworthy
			GUI.lblSes.itemsNw:SetText(ITEM_QUALITY_COLORS[addon.db.global.minRarity].hex .. L["Items"] .. FONT_COLOR_CODE_CLOSE ..
									" / " .. ">" .. addon.db.global.minNoteworthy)
			if GUI.isShrinked then
				GUI.lblSes.itemsNw:SetText(ITEM_QUALITY_COLORS[addon.db.global.minRarity].hex .. L["Items"] .. FONT_COLOR_CODE_CLOSE)
			end
			GUI.infoSes.itemsNw:SetText(ITEM_QUALITY_COLORS[6].hex ..
				addon.db.realm.sesNumItems .. " / " .. addon.db.realm.sesNumNW
				..  FONT_COLOR_CODE_CLOSE)
		end
	end
end

-- prepare/update session data
function GUI:UpdateSessionData(sesItemsUpdated)
	GUI:DebugPrintf("UpdateSessionData(" .. tostring(sesItemsUpdated) .. ")")
	if GUI.view == "session" and GUI.display then
		if (sesItemsUpdated) then
			GUI.dataSes:SetContent(private.GetSessionItemData(GUI.sesFilters))
		end
		private.GetSessionInfoData(GUI.sesFilters)
	end
	addon:UpdateBroker()

	-- auto adapt data + info view
	if GUI.display then
		if GUI.view == "session" then
			GUI:DebugPrintf("Adapt Session")
			if GUI.labelFont and GUI.labelFontSize and GUI.container then
				if private.adapt.width and private.adapt.width >= 600 then
					GUI.infoSes.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
					GUI.btnSes.gold.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
					if private.TITLEWIDTH_ITEM ~= 0.31 then
						if private.adapt.shPlayer ~= nil then
							addon.db.global.shPlayer = private.adapt.shPlayer
							private.adapt.shPlayer = nil
						end
						if private.adapt.shZone ~= nil then
							addon.db.global.shZone = private.adapt.shZone
							private.adapt.shZone = nil
						end
						private.TITLEWIDTH_ITEM = 0.31
						private.TITLEWIDTH_VALUE = 0.17
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.20
						private.TITLEWIDTH_TIME = 0.18
						GUI:Shrink(false)
						-- GUI:Printf("Session Reload >= 600")
						GUI.container:Reload()
					end
				elseif private.adapt.width and private.adapt.width >= 500 then
					GUI.infoSes.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 2)
					GUI.btnSes.gold.label:SetFont(GUI.labelFont, GUI.labelFontSize + 2)
					if private.TITLEWIDTH_ITEM ~= 0.35 then
						if private.adapt.shPlayer == nil then
							private.adapt.shPlayer = addon.db.global.shPlayer
							addon.db.global.shPlayer = false
						end
						if private.adapt.shZone ~= nil then
							addon.db.global.shZone = private.adapt.shZone
							private.adapt.shZone = nil
						end
						private.TITLEWIDTH_ITEM = 0.35
						private.TITLEWIDTH_VALUE = 0.21
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.17
						private.TITLEWIDTH_TIME = 0.13
						-- GUI:Printf("Session Reload >= 500")
						GUI:Shrink(false)
						GUI.container:Reload()
					end
				else
					GUI.infoSes.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize)
					GUI.btnSes.gold.label:SetFont(GUI.labelFont, GUI.labelFontSize)
					if private.TITLEWIDTH_ITEM ~= 0.40 then
						if private.adapt.shPlayer == nil then
							private.adapt.shPlayer = addon.db.global.shPlayer
							addon.db.global.shPlayer = false
						end
						if private.adapt.shZone == nil then
							private.adapt.shZone = addon.db.global.shZone
							addon.db.global.shZone = false
						end
						private.TITLEWIDTH_ITEM = 0.40
						private.TITLEWIDTH_VALUE = 0.22
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.13
						private.TITLEWIDTH_TIME = 0.11
						-- GUI:Printf("Session Reload")
						GUI:Shrink(true)
						GUI.container:Reload()
					end
				end
			end
		end

		if GUI.view == "history" then
			GUI:DebugPrintf("Adapt History")
			if GUI.labelFont and GUI.labelFontSize and GUI.container then
				if private.adapt.width and private.adapt.width >= 600 then
					GUI.infoHis.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
					if private.TITLEWIDTH_ITEM ~= 0.31 then
						if private.adapt.shPlayer ~= nil then
							addon.db.global.shPlayer = private.adapt.shPlayer
							private.adapt.shPlayer = nil
						end
						if private.adapt.shZone ~= nil then
							addon.db.global.shZone = private.adapt.shZone
							private.adapt.shZone = nil
						end
						private.TITLEWIDTH_ITEM = 0.31
						private.TITLEWIDTH_VALUE = 0.17
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.20
						private.TITLEWIDTH_TIME = 0.18
						-- GUI:Printf("History Reload >= 600")
						GUI.container:Reload()
					end
				elseif private.adapt.width and private.adapt.width >= 500 then
					GUI.infoHis.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 2)
					if private.TITLEWIDTH_ITEM ~= 0.35 then
						if private.adapt.shPlayer == nil then
							private.adapt.shPlayer = addon.db.global.shPlayer
							addon.db.global.shPlayer = false
						end
						if private.adapt.shZone ~= nil then
							addon.db.global.shZone = private.adapt.shZone
							private.adapt.shZone = nil
						end
						private.TITLEWIDTH_ITEM = 0.35
						private.TITLEWIDTH_VALUE = 0.21
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.17
						private.TITLEWIDTH_TIME = 0.13
						-- GUI:Printf("History Reload >= 500")
						GUI.container:Reload()
					end
				else
					GUI.infoHis.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize)
					if private.TITLEWIDTH_ITEM ~= 0.40 then
						if private.adapt.shPlayer == nil then
							private.adapt.shPlayer = addon.db.global.shPlayer
							addon.db.global.shPlayer = false
						end
						if private.adapt.shZone == nil then
							private.adapt.shZone = addon.db.global.shZone
							addon.db.global.shZone = false
						end
						private.TITLEWIDTH_ITEM = 0.40
						private.TITLEWIDTH_VALUE = 0.22
						private.TITLEWIDTH_QTY = 0.04
						private.TITLEWIDTH_PLAYER = 0.10
						private.TITLEWIDTH_ZONE = 0.13
						private.TITLEWIDTH_TIME = 0.11
						-- GUI:Printf("History Reload")
						GUI.container:Reload()
					end
				end
			end
		end
	end

	-- auto shrink frame
	if GUI.display then
		if GUI.view == "session" then
			if GUI.isShrinked then
				if not (GUI.lastWidth and GUI.container.frame:GetWidth() == GUI.lastWidth) then
					-- GUI:Printf("Shrink/SetPoints")
					GUI.container.border:SetPoint("TOPLEFT", 1, - 8)
					GUI.lastWidth = GUI.container.frame:GetWidth()
				end
			end
		end
	end
end

------------------------------------------------------------------------------
-- History Tab

-- create history tab
GUI.guiTabsSelect["history"] = function(container, group)
	GUI:DebugPrintf("Select Tab %s: %s", group, tostring(container))
	if not container then
		GUI:DebugPrintf("Select Tab: container is nil")
	end

	-- min. Size
	GUI.display.frame:SetMinResize(400, 400)

	-- Load History Data
	addon.Data:LoadDatabase()

	local tagList = {}
	for tag in pairs(addon.hisItems) do
		tagList[tag] = date(addon.timeFormat, tag)
		if (addon.hisInfo[tag].hisZone) then
			tagList[tag] = tagList[tag] .. " / " .. addon.hisInfo[tag].hisZone
		end
	end

	-- Filter: default filter is empty
	GUI.hisFilters = {}

	-- variants
	local flNotTheRealItemString = ""
	if (addon.db.global.useNotTheRealItemString) then
		flNotTheRealItemString = ITEM_QUALITY_COLORS[5].hex .. L[" (! = variant)"] .. FONT_COLOR_CODE_CLOSE
	end

	if (CanIMogIt) then
		flNotTheRealItemString = flNotTheRealItemString .. " " .. ITEM_QUALITY_COLORS[5].hex .. L[" (TM = New Transmog)"] .. FONT_COLOR_CODE_CLOSE
	end

	-- session selection group
	local grp1 = AceGUI:Create("SIDInlineGroup")
	grp1:SetLayout("Flow")
	if grp1.SetTitle then
		grp1:SetTitle(L["Session History Selection"])
	end
	grp1:SetFullWidth(true)

	local grpWidth = 1
	local grpColNum = 5.01
	local grpRelWidth = grpWidth / grpColNum

	-- session selection group - line 1
	GUI.lblHis = {}
	GUI.lblHis.startTime = private.AddButton("Label", L["Session"], "-")
	GUI.lblHis.startTime:SetRelativeWidth(0.45)
	grp1:AddChild(GUI.lblHis.startTime)

	GUI.lblHis.duration = private.AddButton("Label", L["Duration"], "-")
	GUI.lblHis.duration:SetRelativeWidth(0.14)
	grp1:AddChild(GUI.lblHis.duration)

	GUI.lblHis.liv = private.AddButton("Label", L["LIV"], "-")
	GUI.lblHis.liv:SetRelativeWidth(0.20)
	grp1:AddChild(GUI.lblHis.liv)

	GUI.lblHis.source = private.AddButton("Label", L["Price Source"], "-")
	GUI.lblHis.source:SetRelativeWidth(0.18)
	grp1:AddChild(GUI.lblHis.source)

	-- session selection group - line 2
	GUI.infoHis = {}
	GUI.infoHis.selection = private.AddButton("Dropdown", tagList[addon.hisCTag] or L["no sessions saved"], "-")
	GUI.infoHis.selection:SetRelativeWidth(0.45)
	GUI.infoHis.selection:SetList(tagList)
	GUI.infoHis.selection:SetCallback("OnValueChanged",
		function(_, _, value)
			GUI:DebugPrintf("History Selection, value=%s", value)
			addon.hisCTag = value
			addon.Data:UpdateDatabaseTag(addon.hisCTag)
			GUI.gotNIL = nil
			container:Reload()
		end
	)
	grp1:AddChild(GUI.infoHis.selection)

	GUI.infoHis.duration = private.AddButton("Label", "-", "-")
	GUI.infoHis.duration:SetRelativeWidth(0.14)
	grp1:AddChild(GUI.infoHis.duration)

	GUI.infoHis.liv = private.AddButton("Label", "-", "-")
	GUI.infoHis.liv:SetRelativeWidth(0.20)
	GUI.labelFont, GUI.labelFontSize = GUI.infoHis.liv.label:GetFont()
	GUI.infoHis.liv.label:SetFont(GUI.labelFont, GUI.labelFontSize + 4)
	grp1:AddChild(GUI.infoHis.liv)

	GUI.infoHis.source = private.AddButton("Label", "-", "-")
	GUI.infoHis.source:SetRelativeWidth(0.18)
	grp1:AddChild(GUI.infoHis.source)

	container:AddChild(grp1)

	-- session history data group
	local grp2 = AceGUI:Create("SIDInlineGroup")
	grp2:SetLayout("Flow")
	if grp2.SetTitle then
		grp2:SetTitle(L["Session History Data"])
	end
	grp2:SetFullWidth(true)
	grp2:SetFullHeight(true)

	local grp3 = AceGUI:Create("SimpleGroup")
	grp3:SetLayout("Flow")
	grp3:SetFullWidth(true)

	grpWidth = 1
	grpColNum = 5.01
	if not addon.db.global.shPlayer then
		grpColNum = grpColNum - 1
	end
	if not addon.db.global.shZone then
		grpColNum = grpColNum - 1
	end

	grpRelWidth = grpWidth / grpColNum

	-- session history data group - line 1
	local i = private.AddButton("Label", L["Search"], "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)

	i = private.AddButton("Label", L["Rarity"], "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)

	if addon.db.global.shPlayer then
		i = private.AddButton("Label", L["Player"], "-")
		i:SetRelativeWidth(grpRelWidth)
		grp3:AddChild(i)
	end

	if addon.db.global.shZone then
		i = private.AddButton("Label", L["Zone"], "-")
		i:SetRelativeWidth(grpRelWidth)
		grp3:AddChild(i)
	end

	i = private.AddButton("Label", "", "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)
	grp2:AddChild(grp3)

	grp3 = AceGUI:Create("SimpleGroup")
	grp3:SetLayout("Flow")
	grp3:SetFullWidth(true)

	-- session history data group - line 2
	i = private.AddButton("SIDEditBox", "", "-")
	i:SetRelativeWidth(grpRelWidth)
	i.button:SetScript("OnClick", function(f) 
			local editbox = f.obj.editbox
			editbox:SetText("")
			editbox:SetCursorPosition(0)
			editbox:ClearFocus()
			f.obj:DisableButton(true)
			f.obj:Fire("OnTextChanged", "")
		end)
	i.button:SetText(L["CLR"])
	i:SetCallback("OnTextChanged",
		function(f, _, value)
			value = value:trim()
			if value == "" then
				GUI.hisFilters.name = nil
			else
				GUI.hisFilters.name = value
				f:DisableButton(false)
			end
			GUI.dataHis:SetContent(private.GetHistoryItemData(GUI.hisFilters))
			private.GetHistoryInfoData(GUI.hisFilters)
		end
	)
	grp3:AddChild(i)

	i = private.AddButton("Dropdown", L["Rarity"], "-")
	i:SetRelativeWidth(grpRelWidth)
	i:SetList(GUI.rarityList)
	i:SetCallback("OnValueChanged",
		function(_, _, key)
			if key > 0 then
				GUI.hisFilters.rarity = key
			else
				GUI.hisFilters.rarity = nil
			end
			GUI.dataHis:SetContent(private.GetHistoryItemData(GUI.hisFilters))
			private.GetHistoryInfoData(GUI.hisFilters)
		end
	)
	grp3:AddChild(i)

	if addon.db.global.shPlayer then
		i = private.AddButton("Dropdown", L["Player"], "-")
		i:SetRelativeWidth(grpRelWidth)
		i:SetList(private.playerListFromItems(addon.hisItems[addon.hisCTag]))
		local value = "all"
		i:SetText(i.list[value])
		i.value = value
		i:SetCallback("OnValueChanged",
			function(_, _, value)
				if value == "all" then
					GUI.hisFilters.player = nil
				else
					GUI.hisFilters.player = value
				end
				GUI.dataHis:SetContent(private.GetHistoryItemData(GUI.hisFilters))
				private.GetHistoryInfoData(GUI.hisFilters)
			end
		)
		grp3:AddChild(i)
	end

	if addon.db.global.shZone then
		i = private.AddButton("Dropdown", L["Zone"], "-")
		i:SetRelativeWidth(grpRelWidth)
		i:SetList(private.zoneListFromItems(addon.hisItems[addon.hisCTag]))
		local value = "all"
		i:SetText(i.list[value])
		i.value = value
		i:SetCallback("OnValueChanged",
			function(_, _, value)
				if value == "all" then
					GUI.hisFilters.zone = nil
				else
					GUI.hisFilters.zone = value
				end
				GUI.dataHis:SetContent(private.GetHistoryItemData(GUI.hisFilters))
				private.GetHistoryInfoData(GUI.hisFilters)
			end
		)
		grp3:AddChild(i)
	end

	i = private.AddButton(L["Delete"], L["Delete the displayed history session data."])
	i:SetRelativeWidth(grpRelWidth)
	i:SetCallback("OnClick",
		function()
			if (addon.db.global.nwSound ~= "") then
				addon.Options.PlaySound()
				GUI:DebugPrintf()
			end
			addon.Data:WipeHistoryTag(addon.hisCTag)
			addon.hisCTag = 0
			addon.Data:ResetCurrentTag(true)
			addon.Data:UpdateDatabaseTag(addon.hisCTag)
			container:Reload()
		end
	)
	grp3:AddChild(i)

	grp2:AddChild(grp3)

	-- session history data items
	local grp4 = AceGUI:Create("SimpleGroup")
	grp4:SetLayout("Fill")
	grp4:SetFullWidth(true)
	grp4:SetFullHeight(true)

	local titles = {}
	titles = {
		{text=L["Item"] .. flNotTheRealItemString, relWidth=private.TITLEWIDTH_ITEM},
		{text=L["Item Value"], relWidth=-private.TITLEWIDTH_VALUE},
		{text=L["Qty"], relWidth=-private.TITLEWIDTH_QTY},
		{text=L["Player"], relWidth=private.TITLEWIDTH_PLAYER},
		{text=L["Zone"], relWidth=private.TITLEWIDTH_ZONE},
		{text=L["Time"], relWidth=private.TITLEWIDTH_TIME},
	}
	local colSpan = 0
	local colSpan2 = 6
	if (not addon.db.global.shPlayer) then
		colSpan = colSpan + private.TITLEWIDTH_PLAYER - private.TITLEWIDTH_GAP
		titles[4] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	if (not addon.db.global.shZone) then
		colSpan = colSpan + private.TITLEWIDTH_ZONE - private.TITLEWIDTH_GAP
		titles[5] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	titles[1].relWidth = private.TITLEWIDTH_ITEM  + colSpan / colSpan2
	titles[2].relWidth = -private.TITLEWIDTH_VALUE - colSpan / colSpan2
	titles[3].relWidth = -private.TITLEWIDTH_QTY - colSpan / colSpan2
	if titles[4].text ~= "" then
		titles[4].relWidth = private.TITLEWIDTH_PLAYER + colSpan / colSpan2
	end
	if titles[5].text ~= "" then
		titles[5].relWidth = private.TITLEWIDTH_ZONE + colSpan / colSpan2
	end
	titles[6].relWidth = private.TITLEWIDTH_TIME + colSpan / colSpan2

	container.titleStatusText = {
		L["Leftclick to sort this column / Rightclick to show all columns"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort and Rightclick to hide Player column"],
		L["Leftclick to sort and RightClick to hide Zone column"],
		L["Leftclick to sort this column"],
		}

	local eventHandlers = {
		OnEnter = private.DataFrame_OnEnter,
		OnLeave = private.DataFrame_OnLeave,
		OnClick = function(btn, data, button)
			if not data then return end
			-- purge the line/item
			if button == "LeftButton" then
				GUI:PrintItemStrings(data.link)
			end
			if button == "RightButton" and not IsAltKeyDown() then
				if type(data) == "number" then
					if data == 1 then
						addon.db.global.shPlayer = true
						addon.db.global.shZone = true
						container:Reload()
					end
					if data == 4 then
						addon.db.global.shPlayer = false
						container:Reload()
					end
					if data == 5 then
						addon.db.global.shZone = false
						container:Reload()
					end
				end
			end
			if button == "RightButton" and IsAltKeyDown() then
				if (addon.hisCTag > 0) then
					local qty = addon.Data:PurgeItem(data, addon.hisItems[addon.hisCTag])
					if (qty > 0) then
						addon.Data:SaveDatabaseTag(addon.hisCTag)
						addon.Data:LoadDatabaseTag(addon.hisCTag)
						container:Reload()
						addon:Printf(L["%sx %s purged."], qty, data.link)
					end
				end
			end
		end,
	}

	GUI.dataHis = AceGUI:Create("SIDData")
	GUI.dataHis:DoRedraw(false)
	GUI.dataHis:SetEventHandlers(eventHandlers)
	GUI.dataHis:SetTitles(titles)
	GUI.dataHis:SetSortTitle(-6)
	grp4:AddChild(GUI.dataHis)

	grp2:AddChild(grp4)
	container:AddChild(grp2)

	addon.Item:GotNILReset()
	GUI.dataHis:SetContent(private.GetHistoryItemData(GUI.hisFilters))
	GUI.dataHis:DoRedraw(true)

	private.GetHistoryInfoData(GUI.hisFilters)

	if addon.Item:GotNIL() then
		GUI.gotNIL = GUI.gotNIL or 5
		if GUI.gotNIL > 0 then
			GUI.gotNIL = GUI.gotNIL - 1
			addon.Data.secToUpdate = 1
			GUI:DebugPrintf("Got nil for GetItemInfo(), try reload #%s in %s sec.", tostring(GUI.gotNIL), tostring(addon.Data.secToUpdate))
		end
	else
		GUI.gotNIL = nil
	end
	
	return container
end

-- prepare/update history item data
function private.GetHistoryItemData(lfilters)
	GUI:DebugPrintf("GetHistoryItemData()")
	if GUI.view ~= "history" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	if (addon.hisCTag > 0) then
		GUI:DebugPrintf("tag = %s", addon.hisCTag)
		return private.GetItemData(addon.hisItems[addon.hisCTag], lfilters)
	else
		GUI:DebugPrintf("no tag active!")
		return private.GetItemData({}, lfilters)
	end
end

-- prepare/update history info data
function private.GetHistoryInfoData(filters)
	GUI:DebugPrintf("GetHistoryInfoData()")
	if GUI.view ~= "history" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	if (addon.hisCTag > 0) then
		if (addon.hisInfo[addon.hisCTag].hisMVSource ~= addon.db.global.mvSource) then
			GUI:DebugPrintf("mvSource changed, update data...")
			addon.Data:UpdateDatabaseTag(addon.hisCTag)
		end
	end

	local mvFilter = 0
	local nwFilter = 0
	local itsSum = 0
	local itsFilter = 0
	local itSum = 0
	local itFilter = 0
	local isFiltered = false

	if (not filters.name and not filters.rarity and not filters.player and not filters.time and not filters.zone) then
		GUI:DebugPrintf("... with no filters")
	else
		if (addon.hisCTag > 0) then
		GUI:DebugPrintf("... with filters")
		isFiltered = true
		itStart = 0
		itEnd = 0
		for link, data in pairs(addon.hisItems[addon.hisCTag]) do
			if #data.drops > 0 then
				itsSum = itsSum + 1
			end
			if #data.drops > 0 and not private:IsItemFiltered(link, data, filters) then
				itsFilter = itsFilter + 1
				for _, record in ipairs(data.drops) do
					itSum = itSum + record.quantity
					if not private:IsRecordFiltered(record, filters) then
						if (itStart == 0) then
							itStart = record.time
						end
						if (record.time < itStart) then
							itStart = record.time
						end
						if (record.time > itEnd) then
							itEnd = record.time
						end
						itFilter = itFilter + record.quantity
						local marketValue = addon.Data:GetItemValue(record.link) or 0
						mvFilter = mvFilter + (marketValue * record.quantity)
					end
				end
			end
		end
		end
	end

	if (isFiltered or (itsSum ~= itsFilter) or (itSum ~= itFilter)) then
		if (GUI.infoHis) then
			-- Duration
			GUI.lblHis.duration:SetText(L["Duration"])
			GUI.infoHis.duration:SetText(" " .. ITEM_QUALITY_COLORS[6].hex ..
				SecondsToTime(itEnd - itStart)
				.. FONT_COLOR_CODE_CLOSE)
			-- LIV / Gold
			GUI.lblHis.liv:SetText(L["LIV"])
			GUI.infoHis.liv:SetText(GUI:FromCopper(mvFilter))
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoHis.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
			else
				GUI.infoHis.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
		end
	else
		if (GUI.infoHis) then
			-- Duration
			GUI.lblHis.duration:SetText(L["Duration"])
			if (addon.hisCTag > 0) then
				GUI.infoHis.duration:SetText(" " .. ITEM_QUALITY_COLORS[6].hex ..
					SecondsToTime(addon.hisInfo[addon.hisCTag].hisEnd - addon.hisInfo[addon.hisCTag].hisTime)
					.. FONT_COLOR_CODE_CLOSE)
			end
			-- Looted Item Value / Gold
			GUI.lblHis.liv:SetText(L["LIV"])
			if (addon.hisCTag > 0) then
				GUI.infoHis.liv:SetText(GUI:FromCopper(addon.hisInfo[addon.hisCTag].hisMV))
			end
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoHis.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
			else
				GUI.infoHis.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
		end
	end
end

------------------------------------------------------------------------------
-- Inventory Tab

-- create inventory tab
GUI.guiTabsSelect["inventory"] = function(container, group)
	GUI:DebugPrintf("Select Tab %s: %s", group, tostring(container))
	if not container then
		GUI:DebugPrintf("Select Tab: container is nil")
	end

	-- min. Size
	GUI.display.frame:SetMinResize(400, 400)

	-- load items from bags
	addon.invInfo = {}
	addon.invItems = addon.Data:LoadFromBags({})

	-- Filter: default filter is empty
	GUI.invFilters = {}

	-- variants
	local flNotTheRealItemString = ""
	if (addon.db.global.useNotTheRealItemString) then
		flNotTheRealItemString = ITEM_QUALITY_COLORS[5].hex .. L[" (! = variant)"] .. FONT_COLOR_CODE_CLOSE
	end

	if (CanIMogIt) then
		flNotTheRealItemString = flNotTheRealItemString .. " " .. ITEM_QUALITY_COLORS[5].hex .. L[" (TM = New Transmog)"] .. FONT_COLOR_CODE_CLOSE
	end

	-- bag summary group
	local grp1 = AceGUI:Create("SIDInlineGroup")
	grp1:SetLayout("Flow")
	if grp1.SetTitle then
		grp1:SetTitle(L["Bag Summary"])
	end
	grp1:SetFullWidth(true)

	local grpWidth = 1
	local grpColNum = 2.01
	local grpRelWidth = grpWidth / grpColNum

	-- bag summary group - line 1
	GUI.lblInv = {}
	GUI.lblInv.liv = private.AddButton("Label", L["LIV"], "-")
	GUI.lblInv.liv:SetRelativeWidth(0.50)
	grp1:AddChild(GUI.lblInv.liv)

	GUI.lblInv.source = private.AddButton("Label", L["Price Source"], "-")
	GUI.lblInv.source:SetRelativeWidth(0.50)
	grp1:AddChild(GUI.lblInv.source)

	-- bag summary group - line 2
	GUI.infoInv = {}
	GUI.infoInv.liv = private.AddButton("Label", "-", "-")
	GUI.infoInv.liv:SetRelativeWidth(0.50)
	grp1:AddChild(GUI.infoInv.liv)

	GUI.infoInv.source = private.AddButton("Label", "-", "-")
	GUI.infoInv.source:SetRelativeWidth(0.50)
	grp1:AddChild(GUI.infoInv.source)

	container:AddChild(grp1)

	-- bag data group
	local grp2 = AceGUI:Create("SIDInlineGroup")
	grp2:SetLayout("Flow")
	if grp2.SetTitle then
		grp2:SetTitle(L["Bag Data"])
	end
	grp2:SetFullWidth(true)
	grp2:SetFullHeight(true)

	local grp3 = AceGUI:Create("SimpleGroup")
	grp3:SetLayout("Flow")
	grp3:SetFullWidth(true)

	grpWidth = 1
	grpColNum = 3.01

	grpRelWidth = grpWidth / grpColNum

	-- bag data group - line 1
	local i = private.AddButton("Label", L["Search"], "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)

	i = private.AddButton("Label", L["Rarity"], "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)

	i = private.AddButton("Label", L["Bag"], "-")
	i:SetRelativeWidth(grpRelWidth)
	grp3:AddChild(i)

	grp2:AddChild(grp3)

	grp3 = AceGUI:Create("SimpleGroup")
	grp3:SetLayout("Flow")
	grp3:SetFullWidth(true)

	-- bag data group - line 2
	i = private.AddButton("SIDEditBox", "", "-")
	i:SetRelativeWidth(grpRelWidth)
	i.button:SetScript("OnClick", function(f) 
			local editbox = f.obj.editbox
			editbox:SetText("")
			editbox:SetCursorPosition(0)
			editbox:ClearFocus()
			f.obj:DisableButton(true)
			f.obj:Fire("OnTextChanged", "")
		end)
	i.button:SetText(L["CLR"])
	i:SetCallback("OnTextChanged",
		function(f, _, value)
			value = value:trim()
			if value == "" then
				GUI.invFilters.name = nil
			else
				GUI.invFilters.name = value
				f:DisableButton(false)
			end
			GUI.dataInv:SetContent(private.GetInventoryItemData(GUI.invFilters))
			private.GetInventoryInfoData(GUI.invFilters)
		end
	)
	grp3:AddChild(i)

	i = private.AddButton("Dropdown", L["Rarity"], "-")
	i:SetRelativeWidth(grpRelWidth)
	i:SetList(GUI.rarityList)
	i:SetCallback("OnValueChanged",
		function(_, _, key)
			if key > 0 then
				GUI.invFilters.rarity = key
			else
				GUI.invFilters.rarity = nil
			end
			GUI.dataInv:SetContent(private.GetInventoryItemData(GUI.invFilters))
			private.GetInventoryInfoData(GUI.invFilters)
		end
	)
	grp3:AddChild(i)

	i = private.AddButton("Dropdown", L["Bag"], "-")
	i:SetRelativeWidth(grpRelWidth)
	i:SetList(private.zoneListFromItems(addon.invItems))
	local value = "all"
	i:SetText(i.list[value])
	i.value = value
	i:SetCallback("OnValueChanged",
		function(_, _, value)
			if value == "all" then
				GUI.invFilters.zone = nil
			else
				GUI.invFilters.zone = value
			end
			GUI.dataInv:SetContent(private.GetInventoryItemData(GUI.invFilters))
			private.GetInventoryInfoData(GUI.invFilters)
		end
	)
	grp3:AddChild(i)

	grp2:AddChild(grp3)

	-- bag item data
	local grp4 = AceGUI:Create("SimpleGroup")
	grp4:SetLayout("Fill")
	grp4:SetFullWidth(true)
	grp4:SetFullHeight(true)

	local titles = {}
	titles = {
		{text=L["Item"] .. flNotTheRealItemString, relWidth=private.TITLEWIDTH_ITEM + 0.1},
		{text=L["Item Value"], relWidth=-private.TITLEWIDTH_VALUE},
		{text=L["Qty"], relWidth=-private.TITLEWIDTH_QTY},
		{text=L["Player"], relWidth=private.TITLEWIDTH_PLAYER},
		{text=L["Bag"], relWidth=private.TITLEWIDTH_ZONE - 0.1},
		{text="", relWidth=private.TITLEWIDTH_TIME},
	}

	local colSpan = 0
	local colSpan2 = 6
	if (not addon.db.global.shPlayer) then
		colSpan = colSpan + private.TITLEWIDTH_PLAYER - private.TITLEWIDTH_GAP
		titles[4] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	if (true) then
		colSpan = colSpan + private.TITLEWIDTH_TIME - private.TITLEWIDTH_GAP
		titles[6] = {text="", relWidth=private.TITLEWIDTH_GAP}
		colSpan2 = colSpan2 - 1
	end
	titles[1].relWidth = private.TITLEWIDTH_ITEM + 0.1 + colSpan / colSpan2
	titles[2].relWidth = -private.TITLEWIDTH_VALUE - colSpan / colSpan2
	titles[3].relWidth = -private.TITLEWIDTH_QTY - colSpan / colSpan2
	if titles[4].text ~= "" then
		titles[4].relWidth = private.TITLEWIDTH_PLAYER + colSpan / colSpan2
	end
	titles[5].relWidth = private.TITLEWIDTH_ZONE - 0.1 + colSpan / colSpan2
	if titles[6].text ~= "" then
		titles[6].relWidth = private.TITLEWIDTH_TIME + colSpan / colSpan2
	end

	container.titleStatusText = {
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		L["Leftclick to sort this column"],
		}

	local eventHandlers = {
		OnEnter = private.DataFrame_OnEnter,
		OnLeave = private.DataFrame_OnLeave,
		OnClick = function(btn, data, button)
			if not data then return end
			-- purge the line/item
			if button == "LeftButton" then
				GUI:PrintItemStrings(data.link)
			end
		end,
	}

	GUI.dataInv = AceGUI:Create("SIDData")
	GUI.dataInv:DoRedraw(false)
	GUI.dataInv:SetEventHandlers(eventHandlers)
	GUI.dataInv:SetTitles(titles)
	GUI.dataInv:SetSortTitle(5)
	grp4:AddChild(GUI.dataInv)

	grp2:AddChild(grp4)
	container:AddChild(grp2)

	GUI.dataInv:SetContent(private.GetInventoryItemData(GUI.invFilters))
	GUI.dataInv:DoRedraw(true)

	private.GetInventoryInfoData(GUI.invFilters)

	return container
end

-- prepare/update inventory item data
function private.GetInventoryItemData(lfilters)
	GUI:DebugPrintf("GetInventoryItemData()")
	if GUI.view ~= "inventory" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	return private.GetItemData(addon.invItems, lfilters, true)
end

-- prepare/update inventory info data
function private.GetInventoryInfoData(filters)
	GUI:DebugPrintf("GetInventoryInfoData()")
	if GUI.view ~= "inventory" or not GUI.display then
		GUI:DebugPrintf("... nothing done.")
		return
	end

	if (addon.invInfo.invMVSource ~= addon.db.global.mvSource) then
		GUI:DebugPrintf("mvSource changed, update Data...")
		addon.Data:UpdateInventory()
	end

	local mvFilter = 0
	local itsSum = 0
	local itsFilter = 0
	local itSum = 0
	local itFilter = 0
	local itStart = 0
	local itEnd = 0
	local isFiltered = false

	if (not filters.name and not filters.rarity and not filters.player and not filters.time and not filters.zone) then
		GUI:DebugPrintf("... with no filters")
		-- done
	else
		GUI:DebugPrintf("... with filters")
		isFiltered = true
		itStart = 0
		itEnd = 0
		for link, data in pairs(addon.invItems) do
			if #data.drops > 0 then
				itsSum = itsSum + 1
			end
			if #data.drops > 0 and not private:IsItemFiltered(link, data, filters) then
				itsFilter = itsFilter + 1
				for _, record in ipairs(data.drops) do
					itSum = itSum + record.quantity
					if not private:IsRecordFiltered(record, filters) then
						if (itStart == 0) then
							itStart = record.time
						end
						if (record.time < itStart) then
							itStart = record.time
						end
						if (record.time > itEnd ) then
							itEnd = record.time
						end
						itFilter = itFilter + record.quantity
						local marketValue = addon.Data:GetItemValue(record.link) or 0
						mvFilter = mvFilter + (marketValue * record.quantity)
					end
				end
			end
		end
	end

	if (isFiltered or (itsSum ~= itsFilter) or (itSum ~= itFilter)) then
		if (GUI.infoInv) then
			-- LIV / Gold
			GUI.infoInv.liv:SetText(GUI:FromCopper(mvFilter))
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoInv.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
			else
				GUI.infoInv.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
		end
	else
		if (GUI.infoInv) then
			-- Looted Item Value / Gold
			GUI.infoInv.liv:SetText(GUI:FromCopper(addon.invInfo.invMV))
			-- Price Source
			local mvSourcesList = addon.Item:GetPriceSources() or {}
			if mvSourcesList[addon.db.global.mvSource] then
				GUI.infoInv.source:SetText(ITEM_QUALITY_COLORS[6].hex ..
					addon.db.global.mvSource
					.. FONT_COLOR_CODE_CLOSE)
			else
				GUI.infoInv.source:SetText(ITEM_QUALITY_COLORS[0].hex ..
					"(" .. addon.db.global.mvSource .. ")"
					.. FONT_COLOR_CODE_CLOSE)
			end
		end
	end
end

------------------------------------------------------------------------------
-- Information Tab

-- create info tab
GUI.guiTabsSelect["information"] = function(container, group)
	GUI:DebugPrintf("Select Tab %s: %s", group, tostring(container))
	if not container then
		GUI:DebugPrintf("Select Tab: container is nil")
	end

	-- min. Size
	GUI.display.frame:SetMinResize(500, 600)

	local grp1 = AceGUI:Create("SIDInlineGroup")
	grp1:SetFullWidth(true)
	grp1:SetFullHeight(true)
	grp1:SetLayout("Fill")
	if grp1.SetTitle then
		grp1:SetTitle(addon.METADATA.NAME .. " " .. addon.METADATA.VERSION)
	end

	local sf1 = AceGUI:Create("ScrollFrame")
	sf1:SetLayout("Fill")

	local text1 = addon.Changelog.infotext

	if (GetLocale() == "deDE") then
		text1 = addon.Changelog.infotextdeDE
	end

	text1 = text1 ..
		"\n\n## Detected Externals ##\n\n" ..
		addon.ExternalsInfo

	text1 = text1 .. addon.Changelog.Changelog .. addon.Changelog.ToDo

	local i1 = private.AddButton("Label", text1, "-")
	local btnFont, btnFontSize = i1.label:GetFont()
	i1:SetFont(btnFont, btnFontSize + 2)

	i1:SetFullWidth(true)
	sf1:AddChild(i1)

	grp1:AddChild(sf1)
	container:AddChild(grp1)

	return container
end

------------------------------------------------------------------------------
-- Tools Tab

-- create tools tab
GUI.guiTabsSelect["tools"] = function(container, group)
	GUI:DebugPrintf("Select Tab %s: %s", group, tostring(container))
	if not container then
		GUI:DebugPrintf("Select Tab: container is nil")
	end

	-- min. Size
	GUI.display.frame:SetMinResize(500, 600)

	local grp1 = AceGUI:Create("SIDInlineGroup")
	grp1:SetLayout("Flow")
	if grp1.SetTitle then
		grp1:SetTitle(L["Tools"])
	end
	grp1:SetFullWidth(true)

	local text = L["T.B.D."]

	local i = private.AddButton("Label", text, "-")
	i:SetFullWidth(true)
	grp1:AddChild(i)
	container:AddChild(grp1)

	return container
end

------------------------------------------------------------------------------
-- Private Functions

function private.DataFrame_OnEnter(btn, data)
	if btn.btnCnt then
		GUI:SetStatusLine(GUI.container.titleStatusText[btn.btnCnt])
	end

	if type(data) == "table" and data.link and type(data.link) == "string" then
		-- GUI:DebugPrintf("Tooltip for %s", data.link)
		if data.link:match("battlepet") then
			local _, speciesID, level, breedQuality, maxHealth, power, speed, _ = strsplit(":", data.link)
			-- FrameXML/BattlePetTooltip.lua
			local a, b = pcall(BattlePetToolTip_Show,
				tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
			if not a then
				GUI:Printf(b)
			end
		else
			GameTooltip:SetOwner(btn, "ANCHOR_TOPLEFT")
			local a, b = pcall(GameTooltip.SetHyperlink, GameTooltip, data.link)
			if not a then
				GUI:Printf(b .. " " .. tostring(data.link))
			end
		end
	end
end

function private.DataFrame_OnLeave(btn, data)
	if btn.btnCnt then
		GUI:SetStatusLine()
	end
	if type(data) == "table" then
		GameTooltip:Hide()
	end
end

-- prepare item data
function private.GetItemData(items, lfilters, showBOP)
	GUI:DebugPrintf("GetItemData()")
	local content = {}
	local filters = lfilters or {}

	for link, data in pairs(items) do
		if #data.drops > 0 and not private:IsItemFiltered(link, data, filters) then
			for _, record in ipairs(data.drops) do
				if not private:IsRecordFiltered(record, filters) then
					local isVariant = data.iString ~= data.iBaseString
					local lItem = ""
					local marketValue = 0
					local vs = false
					if (addon.db.global.useNotTheRealItemString) then
						lItem = addon.Item:GetItemLink(data.iBaseString)
						if not lItem then
							lItem = link
							-- GUI:DebugPrintf("GetItemData: GetLink for %s is nil", data.iBaseString)
						end
						if (isVariant) then
							lItem = lItem .. ITEM_QUALITY_COLORS[5].hex .. " !" .. FONT_COLOR_CODE_CLOSE
						end
						marketValue, vs = addon.Data:GetItemValue(link)
					else
						lItem = link
						marketValue, vs = addon.Data:GetItemValue(link)
					end

					local name = addon.Item:GetItemName(lItem, link)
					if not name then
						name = L["Unknown"]
						GUI:DebugPrintf("GetItemData: GetName for %s is nil",link)
					end

					if (addon.Item:GetItemIsBOP(link)) then
						lItem = lItem .. ITEM_QUALITY_COLORS[8].hex .. " BOP" .. FONT_COLOR_CODE_CLOSE
					end

					if (CanIMogIt) then
						if not (addon.isInfight) then
							if (CanIMogIt:PlayerKnowsTransmog(link)) then
								-- lItem = lItem .. ITEM_QUALITY_COLORS[2].hex .. " TM" .. FONT_COLOR_CODE_CLOSE
							else
								if (CanIMogIt:CharacterCanLearnTransmog(link)) then
									lItem = lItem .. ITEM_QUALITY_COLORS[5].hex .. " TM" .. FONT_COLOR_CODE_CLOSE
								end
							end
						end
					end

					local data = {}
					data.link = link
					data.time = record.time
					data.data = {}
					data.data[1] = {lItem, name}

					local fc = (GUI:FromCopper(marketValue, vs) or "|cff999999---|r") .. "  "
					-- GUI:Printf("%s: value=%s, string=%s", link, tostring(marketValue), fc)
	
					data.data[2] = {fc, marketValue or 0}
					data.data[3] = {record.quantity .. " ", record.quantity}
					if (not addon.db.global.shPlayer) then
						data.data[4] = nil
					else
						data.data[4] = {record.player, record.player}
					end
					if (GUI.view ~= "inventory") then
						if (not addon.db.global.shZone) then
							data.data[5] = nil
						else
							data.data[5] = {record.zone, record.zone}
						end
					else
						data.data[5] = {record.zone, record.zone}
					end
					data.data[6] = {GUI:TimeToString(record.time), record.time}
					if (GUI.view == "session") and (not addon.db.global.shTime) then
						data.data[6] = nil
					else
						if (GUI.view == "inventory") then
							data.data[6] = nil
						end
					end
					tinsert(content, data)
				end
			end
		end
	end
	return content
end

-- create and return button/other widget
function private.AddButton(widgetType, label, status)
	-- GUI:DebugPrintf("AddButton %s, %s", widgetType, label)
	if not status then
		widgetType, label, status = "Button", widgetType, label
	end
	local button = assert(AceGUI:Create(widgetType))
	if button.SetText then
		button:SetText(tostring(label))
	end
	button:SetCallback("OnEnter", function() GUI:SetStatusLine(status) end)
	button:SetCallback("OnLeave", function() GUI:SetStatusLine("") end)
	return button
end


-- prepate list of players from item data
function private.playerListFromItems(items)
	local playerList = {}
	if items then
		for _, data in pairs(items) do
			if data.drops then
				for _, record in ipairs(data.drops) do
					playerList[record.player] = record.player
				end
			end
		end
	end
	playerList["all"] = L["All"]
	sort(playerList, function(a, b) return (a.player or 0) < (b.player or 0) end)
	return playerList
end

-- prepate list of zones from item data
function private.zoneListFromItems(items)
	local zoneList = {}
	if items then
		for _, data in pairs(items) do
			if data.drops then
				for _, record in ipairs(data.drops) do
					zoneList[record.zone] = record.zone
				end
			end
		end
	end
	zoneList["all"] = L["All"]
	sort(zoneList, function(a, b) return (a.zone or 0) < (b.zone or 0) end)
	return zoneList
end

-- check if item is filtered
function private:IsItemFiltered(link, data, filters)
	local lItemString = link

	if (addon.db.global.useNotTheRealItemString) then
		lItemString = addon.Item:GetBaseItemString(lItemString)
	end

	local rarity = addon.Item:GetItemQuality(lItemString, link)
	if (rarity) then
		if filters.rarity and rarity < filters.rarity then
			return true
		end
	else
		-- GUI:DebugPrintf("Rarity for %s/%s is nil.", lItemString, link)
	end

	local name = addon.Item:GetItemName(lItemString, link)
	if not name then
		return false
	end

	if filters.name and not strfind(strlower(name), strlower(filters.name)) then
		return true
	end

end

-- check if record is filtered
function private:IsRecordFiltered(record, filters)
	local SECONDS_PER_DAY = 24 * 60 * 60

	if filters.player and record.player ~= filters.player then
		return true
	end

	if filters.zone and record.zone ~= filters.zone then
		return true
	end

	if filters.time and floor(record.time/SECONDS_PER_DAY) < (floor(time()/SECONDS_PER_DAY) - filters.time) then
		return true
	end
end

function private.ShrinkTime(t)
	local res = t
	if GUI.isShrinked and res then
		res = gsub(res, "Std.", "::")
		res = gsub(res, "Min.", "Min")
		res = gsub(res, "vor", "v.")
	end
	return res
end

-- EOF

