------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/Data.lua - Data gathering, loadling, saving
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local Data = addon:NewModule("Data", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LibParse = LibStub("LibParse")
local private = {}
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Premade Blacklist
-- To be more compatible with the Looted Item Value of Loot Appraiser/Loot Appraiser Challenge a
-- special item list for blacklisted is used if 'LA/LAC values' compatibility option is enabled.
-- The items will be ignored at drop time.
-- If the 'LA/LAC values' option was not set at drop time, items from the blacklist will show up 
-- in the list with their market value, but if the 'Extra VendorSells' (see below) option is enabled
-- their value will be VendorSell.

-- AQ20
Data.BLACKLISTED_ITEMS = "i:18640,i:19183,i:20858,i:20859,i:20860,i:20861,i:20862,i:20863,i:20864,i:20865,i:20866," ..
		"i:20867,i:20868,i:20869,i:20870,i:20871,i:20872,i:20873,i:20874,i:20875,i:20876,i:20877,i:20878,i:20879," ..
		"i:20881,i:20882,"
-- Zul Aman
Data.BLACKLISTED_ITEMS = Data.BLACKLISTED_ITEMS .. "i:33865,"
-- Zul Farrak
Data.BLACKLISTED_ITEMS = Data.BLACKLISTED_ITEMS .. "i:8623,i:9243,"
-- Dreanor
Data.BLACKLISTED_ITEMS = Data.BLACKLISTED_ITEMS .. "i:120945,i:118897,i:118903,"
-- Silithus
Data.BLACKLISTED_ITEMS = Data.BLACKLISTED_ITEMS .. "i:20406,i:20407,i:20408,"

------------------------------------------------------------------------------
-- Premade VendorSell Lists
-- To be more compatible with the Looted Item Value of Loot Appraiser/Loot Appraiser Challenge a
-- special item list for vendorsell items can be used. The items will have VendorSell values, 
-- regardless of the choosen price source. 
-- Mostly their market values through TSM/UJ are "troll" AH values and you will vendor them anyway.

-- We have one LA/LAC-compatible list which is enabled with the 'LA/LAC values' compatibility option
-- and add an additional list of items, which is enabled with the 'Extra VendorSells' option.
-- When enabled and the blacklist options was not active at loot time, they will also be added here.

-- LA/LAC list 
Data.VENDORSELL_ITEMS = "i:1205, i:3770, i:104314, i:11444, i:104314, i:11444, i:117437, i:117439, i:117442, i:117453, i:117568, " ..
	"i:1179, i:117, i:159, i:1645, i:1707, i:1708, i:17344, i:17404, i:17406, i:17407, i:19221, i:19222, i:19223, i:19224, i:19225, " ..
	"i:19299, i:19300, i:19304, i:19305, i:19306, i:2070, i:20857, i:21151, i:21215, i:2287, i:2593, i:2594, i:2595, i:2596, i:2723, " ..
	"i:27854, i:27855, i:27856, i:27857, i:27858, i:27859, i:27860, i:28284, i:28399, i:29453, i:29454, i:33443, i:33444, i:33445, " ..
	"i:33449, i:33451, i:33452, i:33454, i:35947, i:35948, i:35951, i:3703, i:37252, i:3771, i:3927, i:40042, i:414, i:41731, i:422, " ..
	"i:44570, i:44940, i:44941, i:4536, i:4537, i:4538, i:4539, i:4540, i:4541, i:4542, i:4544, i:4592, i:4593, i:4594, i:4595, i:4599, " ..
	"i:4600, i:4601, i:4602, i:4604, i:4605, i:4606, i:4607, i:4608, i:58256, i:58257, i:58258, i:58259, i:58260, i:58261, i:58262, " ..
	"i:58263, i:58264, i:58265, i:58266, i:58268, i:58269, i:59029, i:59230, i:61982, i:61985, i:61986, i:73260, i:74822, i:787, i:81400, " ..
	"i:81401, i:81402, i:81403, i:81404, i:81405, i:81406, i:81407, i:81408, i:81409, i:81410, i:81411, i:81412, i:81413, i:81414, i:81415, " ..
	"i:8766, i:8932, i:8948, i:8950, i:8952, i:8953, i:9260, i:20404,"

-- extra VendorSell list
Data.VENDORSELL_ITEMS_EXTRA = Data.BLACKLISTED_ITEMS .. Data.VENDORSELL_ITEMS .. "i:8766, i:8952, i:13446, i:13444,  "
------------------------------------------------------------------------------

private.sesGoldUpdated = false
private.sesItemsUpdated = false

-- printing debug info
function Data:DebugPrintf(...)
	if addon.isDebug then
		Data:Printf(...)
	end
end

------------------------------------------------------------------------------
-- Session

-- load current session data
function Data:Load()
	Data:DebugPrintf("OnEnable()")
	Data:LoadSession()
	Data:UpdateSession()
	Data.secToUpdate = 15
end

-- clear session data
function Data:WipeSession()
	addon.db.realm.sesMV = 0
	addon.db.realm.sesGold = 0
	addon.db.realm.sesNumItems = 0
	addon.db.realm.sesNumNW = 0
	addon.db.realm.sesTime = time()
	addon.db.realm.sesEnd = 0
	addon.db.realm.lapTime = time()
	addon.db.realm.lapNum = 1
	addon.sesItems = {}
end

-- unpack and prepare saved session data
function Data:LoadSession()
	addon.sesItemsLoaded = false
	addon.sesItems = Data:LoadFromCSV(addon.db.realm.csvDrops)
	addon.sesItemsLoaded = true

	addon.db.realm.lapNum = addon.db.realm.lapNum or 1
	addon.db.realm.lapTime = addon.db.realm.lapTime or time()
	addon.db.realm.sesTime = addon.db.realm.sesTime or time()
end

-- pack session item data to a csv string
function Data:SaveSession()
	Data:Printf("SaveSession()")
	-- example:
	-- |cff0070dd|Hitem:127665:0:0:0:0:0:0:0:100:66:0:0:1:41|h[Wickelschuppenbänder]|h|r,<char>,1,1449105939,Tanaandschungel
	if addon.sesItemsLoaded then
		addon.db.realm.csvDrops = Data:SaveToCSV(addon.sesItems)
	end
end

-- prepare and update session related data
function Data:UpdateSession()
	Data:DebugPrintf("UpdateSession()")

	addon.sesItems = addon.sesItems or {}

	local mv = 0
	local ni = 0
	local nw = 0
	local c = 0
	for _, data in pairs(addon.sesItems) do
		for _, record in ipairs(data.drops) do
			c = c + 1
			local marketValue = Data:GetItemValue(record.link) or 0
			mv = mv + (marketValue * record.quantity)
			ni = ni + record.quantity
			if addon.GUI:ToCopper(addon.db.global.minNoteworthy) then
				if (marketValue > addon.GUI:ToCopper(addon.db.global.minNoteworthy)) then
					nw = nw + record.quantity
				end
			end
		end
	end

	if (mv >= 0) or (c == 0) then
		addon.db.realm.sesMV = mv
	end

	if (ni >= 0) or (c == 0) then
		addon.db.realm.sesNumItems = ni
	end
	addon.db.realm.sesNumNW = nw

	-- Data:DebugPrintf("UpdateSession: %s items (%s, %s, %s)", c, mv, ni, nw)
end

-- move session data to database
function Data:SessionToDatabase()
	-- session data becomes history data
	addon.hisItems = addon.hisItems or {}
	local tag = addon.db.realm.sesTime

	-- overwriting previous tag entry
	if (addon.hisItems[tag]) then
		addon.hisItems[tag] = nil
	end
	addon.hisItems[tag] = addon.sesItems

	-- history data becomes csv data
	addon.db.realm.csvHis = addon.db.realm.csvHis or {}
	addon.db.realm.csvHis[tag] = Data:SaveToCSV(addon.hisItems[tag])
	addon:Printf(L["Saving session %s."], date(addon.timeFormat, tag))

	Data:UpdateDatabaseTag(tag)
end

------------------------------------------------------------------------------
-- History/Database

-- unpack and prepare all history data
function Data:LoadDatabase()
	if not addon.hisItems then
		addon:Printf(L["Loading History Data..."])
		addon.hisItems = {}
	end

	for tag in pairs(addon.db.realm.csvHis) do
		if (addon.hisItems[tag]) then
			-- Data:DebugPrintf(L["Session %s already loaded."], date(addon.timeFormat, tag))
		else
			Data:DebugPrintf(L["Loading session %s."], date(addon.timeFormat, tag))
			Data:LoadDatabaseTag(tag)
		end
	end

	-- switch to latest saved session
	Data:ResetCurrentTag()
end

-- unpack a session from a csv string
function Data:LoadDatabaseTag(tag)
	addon.hisItems = addon.hisItems or {}
	addon.hisItems[tag] = Data:LoadFromCSV(addon.db.realm.csvHis[tag])
	Data:UpdateDatabaseTag(tag)
end

-- pack a session to a csv string
function Data:SaveDatabaseTag(tag)
	addon.db.realm.csvHis = addon.db.realm.csvHis or {}
	addon.db.realm.csvHis[tag] = Data:SaveToCSV(addon.hisItems[tag])
end

-- prepare and update displayed database session related data
function Data:UpdateDatabaseTag(tag)
	addon.hisInfo = addon.hisInfo or {}

	if (tag == 0) then
		return
	end

	addon.hisInfo[tag] = addon.hisInfo[tag] or {}

	Data:DebugPrintf("UpdateDatabaseTag() for %s", tag)

	addon.hisInfo[tag].hisTime = 0
	addon.hisInfo[tag].hisZone = nil
	addon.hisInfo[tag].hisEnd = 0
	addon.hisInfo[tag].hisMV = 0
	addon.hisInfo[tag].hisMVSource = addon.db.global.mvSource

	local c = 0
	for _, data in pairs(addon.hisItems[tag]) do
		for _, record in ipairs(data.drops) do
			c = c + 1
			if record.time > addon.hisInfo[tag].hisEnd then
				addon.hisInfo[tag].hisEnd = record.time
			end
			if (addon.hisInfo[tag].hisTime == 0) then
				addon.hisInfo[tag].hisTime = record.time
			end
			if record.time < addon.hisInfo[tag].hisTime then
				addon.hisInfo[tag].hisTime = record.time
			end
			addon.hisInfo[tag].hisZone = addon.hisInfo[tag].hisZone or record.zone
			local marketValue = Data:GetItemValue(record.link) or 0
			addon.hisInfo[tag].hisMV = addon.hisInfo[tag].hisMV + (marketValue * record.quantity)
		end
	end
	Data:DebugPrintf("UpdateDatabaseTag: %s items", c)
end

-- delete a history session
function Data:WipeHistoryTag(tag)
	addon.hisItems = addon.hisItems or {}
	addon.db.realm.csvHis = addon.db.realm.csvHis or {}
	if (tag > 0) then
		addon.hisItems[tag] = nil
		addon.db.realm.csvHis[tag] = nil
		addon:Printf(L["Deleting session %s."], date(addon.timeFormat, tag))
	end
end

-- switch to latest saved session
function Data:ResetCurrentTag(flCurrent)
	flCurrent = flCurrent or false
	local newTag = 0
	for tag in pairs(addon.hisItems) do
		if (tag > newTag) then
			newTag = tag
		end
	end
	addon.hisCTag = addon.hisCTag or 0
	if (addon.hisCTag == 0) or (flCurrent) then
		addon.hisCTag = newTag
	end

	-- Data:DebugPrintf("ResetCurrentTag() addon.hisCTag=%s", addon.hisCTag)
end

------------------------------------------------------------------------------
-- Inventory

-- return item data from a bag
function Data:LoadFromBag(id, items)
	Data:DebugPrintf("LoadFromBag(): Bag #%s.", id)

	items = items or {}
	local cnt = 0

	for j = 1, GetContainerNumSlots(id) do
		-- Data:DebugPrintf("Bag #%s - %s.", id, j)
		local _, quantity, locked, quality, readable, lootable, link, isFiltered, noValue, itemID = GetContainerItemInfo(id,j);

		if (link) then
			-- to trigger item info cache
			addon.Item:GetItemInfo(link)

			-- set "drop" related data
			local record = {}
			record.link = link
			record.quantity = quantity or 1
			record.zone = L["Bag "] .. id
			record.player = UnitName("player")
			record.time = 0

			-- fake an nice invalid player name for demo mode
			if (addon.isDemo) then
				record.player = "R2-D2"
			end

			-- add an item entry, if not already present
			if not items[record.link] then
				items[record.link] = {drops={}}
				items[record.link].iString = addon.Item:GetItemString(record.link)
				items[record.link].iBaseString = addon.Item:GetBaseItemString(record.link)
			end

			tinsert(items[record.link].drops, record)
			cnt = cnt + 1
		end
	end

	-- Data:DebugPrintf("Loading %s items from bag %s.", cnt, id)
	return items
end

-- return item data from all bags
function Data:LoadFromBags(items)
	items = items or {}
	for i = 0, NUM_BAG_SLOTS do
		items = Data:LoadFromBag(i, items)
	end
	return items
end


-- prepare and update inventory related data
function Data:UpdateInventory()
	Data:DebugPrintf("UpdateInventory()")

	addon.invInfo = addon.invInfo or {}
	addon.invInfo.invTime = 0
	addon.invInfo.invZone = nil
	addon.invInfo.invEnd = 0
	addon.invInfo.invMV = 0
	addon.invInfo.invMVSource = addon.db.global.mvSource
	addon.invItems = addon.invItems or {}

	local c = 0
	for _, data in pairs(addon.invItems) do
		for _, record in ipairs(data.drops) do
			c = c + 1
			if record.time > addon.invInfo.invEnd then
				addon.invInfo.invEnd = record.time
			end
			addon.invInfo.invZone = addon.invInfo.invZone or record.zone
			local marketValue = Data:GetItemValue(record.link) or 0
			addon.invInfo.invMV = addon.invInfo.invMV + (marketValue * record.quantity)
		end
	end
	Data:DebugPrintf("UpdateInventory: %s items", c)
end

------------------------------------------------------------------------------
-- Utility Functions

-- insert dropped item into session data
function Data:InsertItem(link, quantity, rarity)
	if not (link and quantity) then return end

	-- to trigger the item info cache
	addon.Item:GetItemInfo(link)

	-- set drop related data
	local record = {}
	record.link = link
	record.quantity = quantity
	record.time = time()
	record.player = UnitName("player")
	record.zone = GetZoneText()

	-- fake an nice invalid player name for demo mode
	if (addon.isDemo) then
		record.player = "R2-D2"
	end

	-- add an item entry, if not already present
	if not addon.sesItems[link] then
		addon.sesItems[link] = { drops={} }
		addon.sesItems[link].iString = addon.Item:GetItemString(link)
		addon.sesItems[link].iBaseString = addon.Item:GetBaseItemString(link)
	end

	-- insert drop into item data
	tinsert(addon.sesItems[link].drops, record)
	sort(addon.sesItems[link].drops, function(a, b) return (a.time or 0) < (b.time or 0) end)
end

-- remove drop data from item data (items could be session, history, inventory...)
function Data:PurgeItem(data, items)
	local qty = 0
	if (data) then
		if (data.link) and (data.time) then
			Data:DebugPrintf("Purging %s, dropped at %s.", data.link, data.time)
			if (items[data.link]) and (items[data.link].drops) then
				local p
				for i, record in ipairs(items[data.link].drops) do
					Data:DebugPrintf("%s: Drop at %s", i, record.time)
					if (data.time == record.time) then
						p = i
						qty = record.quantity
					end
				end
				if (p) then
					Data:DebugPrintf("Purged %sx %s at %s.", qty, data.link, data.time)
					tremove(items[data.link].drops,p)
				end
			end
		end
	end
	return qty
end

-- return unpacked item data from csv string
function Data:LoadFromCSV(csv)
	local items = {}

	if not csv then
		return items
	end

	local cnt = 0
	for _, record in ipairs(select(2, LibParse:CSVDecode(csv)) or {}) do
		if record.link and type(record.time) == "number" then

			--Data:DebugPrintf("Loading data for %s: itemString %s baseItemString %s", record.link, addon.Item:GetItemString(record.link), addon.Item:GetBaseItemString(record.link))

			-- to trigger item info cache
			addon.Item:GetItemInfo(record.link)

			-- add an item entry, if not already present
			if not items[record.link] then
				items[record.link] = { drops={} }
				items[record.link].iString = addon.Item:GetItemString(record.link)
				items[record.link].iBaseString = addon.Item:GetBaseItemString(record.link)
			end

			-- set drop related data
			record.zone = record.zone or L["Unknown"]
			record.quantity = record.quantity or 1
			record.player = record.player or L["Unknown"]
			record.time = record.time or 0

			-- fake an nice invalid player name for demo mode
			if (addon.isDemo) then
				record.player = "R2-D2"
			end

			tinsert(items[record.link].drops, record)
			cnt = cnt + 1
		end
	end

	for link in ipairs(items) do
		sort(items[link].drops, function(a, b) return (a.time or 0) < (b.time or 0) end)
	end

	Data:DebugPrintf("Loading data for %s item drops.", cnt)
	return items
end

-- pack item data to a csv string and return it
function Data:SaveToCSV(items)
	local DROP_KEYS = { "link", "player", "quantity", "time", "zone"}
	local drops = {}

	for itemString, data in pairs(items) do
		for _, record in ipairs(data.drops) do
			-- FIXME: find a better way to handle special char ','
			local link = gsub(record.link, ",", ";")
			if (link ~= record.link) then
				addon:Printf(L["Uuups, saving Item %s without ','."], record.link)
				record.link = link
			end
			tinsert(drops, record)
		end
	end

	return LibParse:CSVEncode(DROP_KEYS, drops)
end

-- central GetItemValue function
function Data:GetItemValue(link)
	if Data:IsVendorsell(link) then
		local mvC = addon.Item:GetItemValue(link, "VendorSell") or 0
		return mvC, true
	end

	local mvCopper = addon.Item:GetItemValue(link, addon.db.global.mvSource) or 0
	local mvCopperVS = mvCopper
	local vs = false

	-- fix for BOP pet items
	if mvCopper == 0 then
		if addon.PFCH then
			-- Data:Printf("GetItemvalue(%s) für Pet Item", link)
			if addon.db.global.mvSource and type(addon.db.global.mvSource) == "string" then
				if addon.db.global.mvSource:match("^TSM:") then
					local fixedItemString = addon.PFCH:PfchItemID2Species(addon.Item:GetItemID(link))
					if fixedItemString then
						-- Data:Printf(" ... fixed ItemString=%s", fixedItemString)
						mvCopper = addon.Item:GetItemValue(fixedItemString, addon.db.global.mvSource) or 0
						mvCopperVS = mvCopper
						-- Data:Printf("GetItemvalue(%s) caged %s für Pet Item = %s", link, fixedItemString, tostring(mvCopper))
					end
				end
				if addon.db.global.mvSource:match("^UJ:") then
					local fixedItemString = addon.PFCH:PfchItemID2Species(addon.Item:GetItemID(link))
					if fixedItemString and type(fixedItemString) == "string" then
						-- Data:Printf(" ... fixed ItemString=%s", fixedItemString:gsub("^p:","battlepet:"))
						mvCopper = addon.Item:GetItemValue(fixedItemString:gsub("^p:","battlepet:"), addon.db.global.mvSource) or 0
						mvCopperVS = mvCopper
						-- Data:Printf("GetItemvalue(%s) caged %s für Pet Item = %s", link, fixedItemString:gsub("^p:","battlepet:"), tostring(mvCopper))
					end
				end
			end
		end
	end

	-- Grays
	local itemRarity = addon.Item:GetItemQuality(link, link)
	if itemRarity ~= nil then
		if (itemRarity == 0) then
			if addon.db.global.useVendorSellForGrays then
				mvCopperVS = addon.Item:GetItemValue(link, "VendorSell") or 0
				vs = true
			end
		end
	end

	if mvCopper == 0 and addon.db.global.useVendorSellAsDefault then
		mvCopperVS = addon.Item:GetItemValue(link, "VendorSell") or 0
		vs = true
	end

	if (mvCopper == mvCopperVS) then
--		Data:Printf(L["GetItemValue (%s) for %s is %s"], addon.db.global.mvSource, link, GetCoinTextureString(mvCopper))
		return mvCopper, vs
	else
--		Data:Printf(L["GetItemValue (%s) for %s is %s, but using VendorSell value %s instead"],
--			addon.db.global.mvSource,
--			link,
--			GetCoinTextureString(mvCopper),
--			GetCoinTextureString(mvCopperVS)
--		)
		return mvCopperVS, vs
	end
end

-- check for bag type
do
	local bagTypes = {
		-- 1048576: Tackle Box
		[0x100000] = true,
		-- 65536: Cooking Bag
		[0x10000] = true,
		-- 1024: Mining Bag
		[0x0400] = true,
		-- 512: Gem Bag
		[0x0200] = true,
		-- 128: Engineering Bag
		[0x0080] = true,
		-- 64: Enchanting Bag
		[0x0040] = true,
		-- 32: Herb Bag
		[0x0020] = true,
		-- 16: Inscription Bag
		[0x0010] = true,
		-- 8: Leatherworking Bag
		[0x0008] = true,
	}
	private.isProfessionBag = function(bagType)
		return bagTypes[bagType] or false
	end
end

-- return free bag space
function Data:GetFreeBagSlots()
	local freeSlots = 0
	local totalSlots = 0
	local takenSlots = 0
	for i = 0, NUM_BAG_SLOTS do
		local usable = true
		local freeSlots, bagType = GetContainerNumFreeSlots(i)
		if i >= 1 then
			if private.isProfessionBag(bagType) then
				usable = false
			end
		end
		if usable then
			local bagSize = GetContainerNumSlots(i)
			if bagSize and bagSize > 0 then
				totalSlots = totalSlots + bagSize
				takenSlots = takenSlots + (bagSize - freeSlots)
			end
		end
	end
	freeSlots = totalSlots - takenSlots
	return freeSlots
end

-- process loot events
-- current implementation is based on event LOOT_OPENED
-- update of item lists is done only out-of-combat to avoid script-ran-too-long errors
local function ProcessEvent(event, ...)
	Data:DebugPrintf(L["Event %s"], event)
	if event == "LOOT_OPENED" then
		if (addon.db.realm.sesEnd == 0) then
			for i = 1, GetNumLootItems() do
				local slotType = GetLootSlotType(i);
				if slotType == 1 then
					-- items
					local itemLink = GetLootSlotLink(i)
					local itemQty, _, itemLRarity = select(3, GetLootSlotInfo(i))
					if (itemLink) then
						if (Data.GetFreeBagSlots() < 1) then
							addon:Printf(L["Probably no free bag space for %s."], itemLink)
						else
							if itemLink then
								local mvCopper = Data:GetItemValue(itemLink)
								local isNoteWorthy = false
								local isNewTransmog = false
								if (itemLRarity >= addon.db.global.minRarity) then
									if (Data:IsBlacklisted(addon.Item:GetBaseItemString(itemLink))) then
										if not addon.db.global.noItemMessage then
											if (itemQty > 1) then
												addon:Printf(L["#%s. %sx%s: %s (blacklisted)"], i, itemLink, itemQty, GetCoinTextureString(mvCopper * itemQty))
											else
												addon:Printf(L["#%s. %s: %s (blacklisted)"], i, itemLink, GetCoinTextureString(mvCopper * itemQty))
											end
										end
									else
										addon.db.realm.sesMV = addon.db.realm.sesMV + (mvCopper * itemQty)
										addon.db.realm.sesNumItems = addon.db.realm.sesNumItems + itemQty
										if addon.GUI:ToCopper(addon.db.global.minNoteworthy) then
											if (mvCopper > addon.GUI:ToCopper(addon.db.global.minNoteworthy)) then
												addon.db.realm.sesNumNW = addon.db.realm.sesNumNW + itemQty
												if (addon.db.global.nwSound ~= "") then
													addon.Options.PlaySound(addon.db.global.nwSound)
												end
												isNoteWorthy = true
											end
										end

										local newTrans = ""
										if (CanIMogIt) then
											if (CanIMogIt:PlayerKnowsTransmog(itemLink)) then
												newTrans = L[">>> Known Transmog <<<"]
											else
												if (CanIMogIt:CharacterCanLearnTransmog(itemLink)) then
													newTrans = L[">>> New Transmog <<<"]
													addon.Options.PlaySound(8960)
													isNewTransmog = true
												end
											end
										end

										local showIt = isNoteWorthy and not addon.db.global.noNoteWorthyMessage
										showIt = showIt or (isNewTransmog and not addon.db.global.noTransMogMessage)

										if isNoteWorthy and not addon.db.global.noNoteWorthyMessage then
											Data:DebugPrintf("isNoteWorthy and not addon.db.global.noNoteWorthyMessage = 1")
										end
										if 	isNewTransmog and not addon.db.global.noTransMogMessage then
											Data:DebugPrintf("isNewTransmog and not addon.db.global.noTransMogMessage = 1")
										end

										if not addon.db.global.noItemMessage or showIt then
											if (itemQty > 1) then
												addon:Printf("#%s. %sx%s: %s %s", i, itemLink, itemQty, GetCoinTextureString(mvCopper * itemQty), newTrans)
											else
												addon:Printf("#%s. %s: %s %s", i, itemLink, GetCoinTextureString(mvCopper * itemQty), newTrans)
											end
										end
										Data:InsertItem(itemLink, itemQty, itemLRarity)
										private.sesItemsUpdated = true
									end
								else
									if not addon.db.global.noItemMessage then
										if (itemQty > 1) then
											Data:DebugPrintf("#%s. %sx%s: %s", i, itemLink, itemQty, GetCoinTextureString(mvCopper * itemQty))
										else
											Data:DebugPrintf("#%s. %s: %s", i, itemLink, GetCoinTextureString(mvCopper * itemQty))
										end
									end
								end
							end
						end
					end
				elseif slotType == 2 then
					-- money
					local cuString = select(2, GetLootSlotInfo(i))
					local cuVal = {}
					local cuCnt = 0;
					cuString:gsub("%d+",
						function(i)
							table.insert(cuVal, i)
							cuCnt = cuCnt + 1
						end
					)
					local cuSum = 0
					if (cuCnt == 1) then
						-- raid boss gold detection
						cuString:gsub("(%d+) Gold",
							function(i)
								cuVal[1] = i * 10000
							end
						)
					end
					if cuCnt == 3 then
						cuSum = (cuVal[1] * 10000) + (cuVal[2] * 100) + cuVal[3]
					elseif cuCnt == 2 then
						cuSum = (cuVal[1] * 100) + cuVal[2]
					else
						cuSum = cuVal[1]
					end
					if not addon.db.global.noGoldMessage then
						addon:Printf(L["#%s. %s"], i, GetCoinTextureString(cuSum))
					end
					Data:DebugPrintf("cuString=%s", cuString)
					addon.db.realm.sesGold = addon.db.realm.sesGold + cuSum
					private.sesGoldUpdated = true
				end
			end
			if not (addon.isInfight) then
				if (private.sesGoldUpdated or private.sesItemsUpdated) then
					Data:DebugPrintf("ProcessEvent: UpdateSessionData")
					addon.GUI:UpdateSessionData(private.sesItemsUpdated)
					private.sesGoldUpdated = false
					private.sesItemsUpdated = false
				end
			end
		else
			Data:DebugPrintf(L["Session is not running, so there's no reason to look at the loot."])
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		-- updating GUI is done only out of fight for performance reasons and to avoid script-run-too-long errors
		addon.isInfight = true
		Data:DebugPrintf("ProcessEvent: Player enters combat")
		addon.GUI:SetStatusLine(L["infight"])
	elseif event == "PLAYER_REGEN_ENABLED" then
		addon.isInfight = false
		addon.GUI:SetStatusLine("")
		Data:DebugPrintf("ProcessEvent: Player leaves combat")
		if (private.sesGoldUpdated or private.sesItemsUpdated) then
			Data:DebugPrintf("ProcessEvent: UpdateSessionData (deferred)")
			addon.GUI:UpdateSessionData(private.sesItemsUpdated)
			private.sesGoldUpdated = false
			private.sesItemsUpdated = false
		end
	end
end

-- register all loot events
function Data:RegisterLootEvents()
	self:RegisterEvent("LOOT_OPENED", ProcessEvent)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", ProcessEvent)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", ProcessEvent)
	self:RegisterEvent("LOOT_SLOT_CLEARED", ProcessEvent) -- only for monitoring
	self:RegisterEvent("LOOT_READY", ProcessEvent) -- only for monitoring
end

-- check for black listed items
function Data:IsBlacklisted(itemString)
	if not addon.db.global.useBVLists then
		return false
	end

	if not private.blItems then
		local remString = ""
		private.blItems = {}
		local i = 0
		Data.BLACKLISTED_ITEMS:gsub("(i:[^,]+)",
			function(id)
				local lItemString = addon.Item:GetBaseItemString(id)
				if lItemString then
					private.blItems[lItemString] = true
					i = i + 1
					local name = addon.Item:GetItemName(lItemString, lItemString)
					local link = addon.Item:GetItemLink(id)
					if name and link then
						remString = remString .. " " .. link
					else
						remString = remString .. " " .. id
					end
				end
			end
		)
		if addon.isDebug then
			addon:Printf(L["Imported %s blacklisted items: %s"], i, remString)
		else
			addon:Printf(L["Imported %s blacklisted items."], i)
		end
	end

	if (itemString ~= "") then
		local lItemString = addon.Item:GetBaseItemString(itemString)
		if (lItemString) then
			if addon.db.global.useBVLists then
				if (private.blItems[lItemString]) then
					-- Data:DebugPrintf("Item %s (%s) is blacklisted.", lItemString, itemString)
					return true
				end
			end
		end
		-- Data:DebugPrintf("Item %s (%s) is not blacklisted.", lItemString, itemString)
	end

	return false
end

-- check for vendorsell item
function Data:IsVendorsell(itemString)
	if not addon.db.global.useBVLists and not addon.db.global.useXBVLists then
		return false
	end

	if addon.db.global.useBVLists then
		-- build item cache
		if not private.vsItems then
			local remString = ""
			private.vsItems = {}
			local i = 0
			Data.VENDORSELL_ITEMS:gsub("(i:[^,]+)",
				function(id)
					local lItemString = addon.Item:GetBaseItemString(id)
					if (lItemString) then
						private.vsItems[lItemString] = true
						i = i + 1
						--[[
						local name = addon.Item:GetItemName(lItemString, lItemString)
						local link = addon.Item:GetItemLink(id)
						if name and link then
							remString = remString .. " " .. link
						else
							remString = remString .. " " .. id
						end
						]]
					end
				end
			)

			addon:Printf(L["Imported %s vendorsell items."], i)
			-- Data:DebugPrintf(L["Items: %s"], remString)
		end
	end

	if addon.db.global.useXBVLists then
		if not private.xvsItems then
			local remString = ""
			private.xvsItems = {}
			local i = 0
			Data.VENDORSELL_ITEMS_EXTRA:gsub("(i:[^,]+)",
				function(id)
					local lItemString = addon.Item:GetBaseItemString(id)
					if (lItemString) then
						private.xvsItems[lItemString] = true
						i = i + 1
						--[[
						local name = addon.Item:GetItemName(lItemString, lItemString)
						local link = addon.Item:GetItemLink(id)
						if name and link then
							remString = remString .. " " .. link
						else
							remString = remString .. " " .. id
						end
						]]
					end
				end
			)

			addon:Printf(L["Imported %s extra vendorsell items."], i)
			-- Data:DebugPrintf(L["Items: %s"], remString)
		end
	end

	if (itemString ~= "") then
		local lItemString = addon.Item:GetBaseItemString(itemString)
		if (lItemString) then
			if addon.db.global.useBVLists then
				if (private.vsItems[lItemString]) then
					-- Data:DebugPrintf(L["Item %s (%s) is vendorsell."], lItemString, itemString)
					return true
				end
			end
			if addon.db.global.useXBVLists then
				if (private.xvsItems[lItemString]) then
					-- Data:DebugPrintf(L["Item %s (%s) is extra vendorsell."], lItemString, itemString)
					return true
				end
			end
		end
		-- Data:DebugPrintf(L["Item %s (%s) is not vendorsell."], lItemString, itemString)
	end
	return false
end

-- EOF
