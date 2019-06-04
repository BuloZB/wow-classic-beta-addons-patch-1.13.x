------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/Item.lua - Item prices and conversions
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local Item = addon:NewModule("Item", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local private = {}
------------------------------------------------------------------------------

private.SOURCES = {}
private.SOURCES["DBMarket"] = 1
private.SOURCES["DBMinBuyout"] = 1
private.SOURCES["DBHistorical"] = 1
private.SOURCES["DBRegionMarketAvg"] = 1
private.SOURCES["DBRegionHistorical"] = 1
private.SOURCES["DBRegionMinBuyoutAvg"] = 1
-- private.SOURCES["DBRegionSaleAvg"] = 1

-- printing debug info
function Item:DebugPrintf(...)
	if (addon.isDebug) then
		Item:Printf(...)
	end
end

-- load current session data
function Item:Load()
	Item:DebugPrintf("OnEnable()")
	Item.cache = {}
	Item:GotNILReset()
end

function Item:GotNILReset()
	Item.gotNIL = false
end

function Item:GotNIL()
	return Item.gotNIL
end

-- return a list of price sources
-- used by: Options.GetOptions
function Item:GetPriceSources()
	local ps = {}
	ps.VendorSell = L["VendorSell"]

	local tsm = {}
	if TSMAPI and TSMAPI.GetPriceSources then
		tsm = TSMAPI:GetPriceSources()
	end
	for k, name in pairs(tsm) do
		-- Item:Printf("%s = %s", k, name)
		if private.SOURCES[k] then
			ps["TSM:" .. k] = "TSM: " .. name
		else
			-- ps["TSM:" .. k] = "TSMX: " .. k .. "/" .. name
		end
	end

	local tsm4 = {}
	if TSM_API and TSM_API.GetPriceSourceKeys and TSM_API.GetPriceSourceDescription then
		local status, res = pcall(TSM_API.GetPriceSourceKeys, tsm4)
		if not status then
			Item:Printf("Broken TSM4 API: pcall of TSM_API.GetPriceSourceKeys=%s", res)
		end
	end

	for i, k in ipairs(tsm4) do
		-- Item:Printf("k = %s", k)
		if private.SOURCES[k] then
			-- The TSM4 API is broken, we have to strlower() the keys from TSM_API.GetPriceSourceKeys() to
			-- access the description, because the keys from TSM_API.GetPriceSourceKeys() are not the
			-- real keys of private.priceSourceInfo (in Core/Lib/CustomPrice.lua): what a CRAP of an API design!
			-- TSM4 API it's even more broken: we have to pcall() TSM_API.GetPriceSourceDescription to have it not break
			-- this addon if something went wrong _inside_ TSM4s TSM.CustomPrice.GetDescription we have no influence of!
			local status, res = pcall(TSM_API.GetPriceSourceDescription, strlower(k))
			if status then
				ps["TSM:" .. k] = "TSM: " .. tostring(res) .. " (" .. k .. ")"
			else
				Item:Printf("Broken TSM4 API: pcall of TSM_API.GetPriceSourceDescription=%s", res)
				break
			end
		else
			-- unused price sources
			--[[
			local status, res = pcall(TSM_API.GetPriceSourceDescription, strlower(k))
			if status then
				ps["TSM:" .. k] = "Unused TSM: " .. k .. "/" .. tostring(res)
			else
				Item:Printf("Broken TSM4 API: pcall of TSM_API.GetPriceSourceDescription=%s", res)
				break
			end
			]]
		end
	end

	local uj = {}
	if TUJMarketInfo then
		uj["globalMean"] = L["Region Market Average (globalMean)"]
		uj["globalMedian"] = L["Region Market Median (globalMedian)"]
		uj["market"] = L["14-Days Market Average (market)"]
		uj["recent"] = L["3-Days Market Average (recent)"]
	end
	for k, name in pairs(uj) do
		-- Item:Printf("%s = %s", k, name)
		ps["UJ:" .. k] = "UJ: " .. name
	end

	return ps
end

-- get item value of ItemID/ItemLink/BaseItemString or nil
function Item:GetItemValue(val, source)
	addon.Item:GetItemInfo(val)

	if source == "VendorSell" then
		if addon.Item.cache[val] and addon.Item.cache[val].ok then
--			Item:Printf("GetItemValue(%s, %s) = %s", val, source, tostring(addon.Item.cache[val].vendorSell))
			return addon.Item.cache[val].vendorSell
		end
		return
	end

	if source:match("^TSM:(.+)$") then
		if TSMAPI and TSMAPI.GetItemValue then
			local s = TSMAPI:GetItemValue(val, source:match("^TSM:(.+)$"))
--			Item:Printf("GetItemValue(%s, %s, %s) = %s", val, source, source:match("^TSM:(.+)$"), tostring(s))
			return TSMAPI:GetItemValue(val, source:match("^TSM:(.+)$"))
		end
		if TSM_API and TSM_API.GetCustomPriceValue then
			-- again we have to pcall() TSM_API.GetCustomPriceValue to have it not break
			-- this addon if something went wrong _inside_ TSM4s TSMAPI_FOUR.CustomPrice.GetValue we have no influence of!
			local status, res = pcall(TSM_API.GetCustomPriceValue, strlower(source:match("^TSM:(.+)$")), val)
			if status then
				return res
			else
				Item:Printf("Broken TSM4 API: pcall of TSM_API.GetCustomPriceValue=%s", res)
			end
		end
		return
	end

	if source:match("^UJ:(.+)$") then
		if TUJMarketInfo then
			local s = TUJMarketInfo(val)
			local ujsource = source:match("^UJ:(.+)$")
			if s and type(s[ujsource]) == "number" then
				-- Item:Printf("TUJMarketInfo(%s, %s) = %s", val, ujsource, tostring(s[ujsource]))
				return s[ujsource]
			end
		end
		return
	end
end

-- trigger online item info cache for ItemID/ItemString/ItemLink
function Item:GetItemInfo(val)
	local req
	local key = val

	if type(val) == "number" then
		req = "item:" .. val
		key = Item:GetBaseItemString(val)
	elseif type(val) == "string" then
		if val:match("item:([0-9]+)") then
			req = val
			key = val
		elseif val:match("^i:([0-9]+)") then
			req = "item:" .. Item:GetItemID(val)
			key = Item:GetBaseItemString(val)
		end
	end
	if req and key then
--		Item:DebugPrintf("GetItemInfo(%s) req=%s key=%s", tostring(val), req, key)
	else
--		Item:DebugPrintf("GetItemInfo(%s) type=%s ?!", tostring(val), type(val))
		return
	end

	if Item.cache[key] and Item.cache[key].ok then
--		Item:DebugPrintf("GetItemInfo(%s) cached n=%s, l=%s, q=%s, v=%s, bop=%s",
--			val, Item.cache[key].name, Item.cache[key].link, tostring(Item.cache[key].quality),
--			tostring(Item.cache[key].vendorSell), tostring(Item.cache[key].bop))
		return true
	end

	if type(req) == "string" then
		local name, link, quality, itemLevel, minLevel, _, _, maxStack, _, _, vendorSell, _, _, bindType = GetItemInfo(req)
		if name and link then
			local item = {}
			item.ok = true
			item.name = name
			item.link = link
			item.quality = quality
			item.vendorSell = vendorSell
			item.bop = (bindType == LE_ITEM_BIND_ON_ACQUIRE or bindType == LE_ITEM_BIND_QUEST) and 1
			Item.cache[key] = item
--			Item:DebugPrintf("GetItemInfo(%s) n=%s, l=%s, q=%s, v=%s, bop=%s",
--				val, Item.cache[key].name, Item.cache[key].link, tostring(Item.cache[key].quality),
--				tostring(Item.cache[key].vendorSell), tostring(Item.cache[key].bop))
			return true
		else
			Item.gotNIL = true
--			Item:DebugPrintf("GetItemInfo(%s) req=%s key=%s is nil ?!", tostring(val), req, key)
		end
	end
end

-- get offline ItemID/ItemString/ItemLink/PetString/PetLink to a TSM ItemString/PetString or nil
function Item:GetItemString(val)
	-- Item:DebugPrintf("GetItemString(%s)", tostring(val))
	if not val then
		return
	end

	-- ItemID
	if type(val) == "number" then
		-- Item:DebugPrintf("  is ID >> i:%s" .. tostring(val))
		return "i:" .. tostring(val)
	end

	local itemString
	if type(val) == "string" then
		-- Link
		local itemString = val:match("item:([0-9:%-]+)\124")
		if itemString then
			local s = itemString:match("^([0-9]+)::::::::[0-9]+:[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1a >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+):::::::[0-9]+:[0-9]+:[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1b >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+)::::::::[0-9]+:[0-9]+::[0-9]+[:]+$")
			if s then
				-- Item:DebugPrintf("  is Link/1c >> i:%s", s)
				return "i:" .. s
			end
			s = itemString:match("^([0-9]+::::::::[0-9]+:[0-9]+:::1:[0-9]+:::)$")
			if s then
				-- Item:DebugPrintf("  is Link/1d >> i:%s", s)
				return "i:" .. s
			end
			-- Item:DebugPrintf("  is Link/1 >> i:%s", itemString)
			return "i:" .. itemString

		end

		itemString = val:match("^item:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is Link/2 >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- ItemString
		itemString = val:match("^i:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is ItemString >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- ItemString
		itemString = val:match("^i:([0-9:%-]+)[% ]+$")
		if itemString then
			-- Item:DebugPrintf("  is ItemString >> i:%s", itemString)
			return "i:" .. itemString
		end

		-- battle pet link
		itemString = val:match("battlepet:([0-9]+:[0-9]+:[0-9]+)")
		if itemString then
			-- Item:DebugPrintf("  is PetLink >> p:%s", itemString)
			return "p:" .. itemString
		end

		-- PetString
		itemString = val:match("^p:([0-9:%-]+)$")
		if itemString then
			-- Item:DebugPrintf("  is PetString >> p:%s", itemString)
			return "p:" .. itemString
		end
	end

	Item:Printf("  GetItemString(%s) = nil ?!", tostring(val))
end

-- get offline ItemID/ItemString/ItemLink/PetString/PetLink to a TSM BaseItemString/BasePetString or nil
function Item:GetBaseItemString(val)
--	Item:DebugPrintf("GetBaseItemString(%s)", tostring(val))
	if not val then
		return
	end

	local itemString = Item:GetItemString(val)
--	Item:Printf("  GetItemString(%s)=%s", tostring(val), tostring(itemString))

	if itemString and type(itemString) == "string" and itemString ~= "" then
		local baseItemString = itemString:match("^([pi]:%d+)")
		if baseItemString then
--			Item:DebugPrintf("  is Item/PetString >> %s", itemString)
			return baseItemString
		end
	end

	Item:Printf("  GetBaseItemString(%s) = nil ?!", tostring(val))
end

-- get online quality of ItemID/ItemString/ItemLink/PetString/PetLink or nil
-- get offline quality of ItemLink or nil
function Item:GetItemQuality(val, link)
--	Item:DebugPrintf("GetItemQuality(%s, %s)", tostring(val), tostring(link))

	-- try online
	Item:GetItemInfo(val)
	if Item.cache[val] and Item.cache[val].ok then
--			Item:DebugPrintf("  is/online %s", Item.cache[val].quality)
		return Item.cache[val].quality
	end

	-- offline
	if link and type(link) == "string" then
		for i = 0, 8 do
			if link:match(ITEM_QUALITY_COLORS[i].hex) then
--				Item:DebugPrintf("  is/offline/1 %s", i)
				return i
			end
		end
		if link:match("cffa335ee") then
--			Item:DebugPrintf("  is/offline/2 %s", 4)
			return 4
		end
	end
end

-- get online name of ItemID/ItemString/ItemLink/PetString/PetLink or nil
-- get offline name of ItemLink or nil
function Item:GetItemName(val, link)
--	Item:DebugPrintf("GetItemName(%s, %s)", tostring(val), tostring(link))

	-- try online
	Item:GetItemInfo(val)
	if Item.cache[val] and Item.cache[val].ok then
--		Item:DebugPrintf("  is/online %s", Item.cache[val].name)
		return Item.cache[val].name
	end

	-- offline
	if link and type(link) == "string" then
		local name = link:match("\124h%[(.+)%]\124h")
		if name then
--			Item:DebugPrintf("  is/offline %s", i)
			return name
		end
	end
end

-- get offline ItemID of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemID(val)
--	Item:DebugPrintf("GetItemID(%s)", tostring(val))

	if type(val) == "number" then
--		Item:DebugPrintf("  is number %s", tostring(val))
		return val
	end

	val = Item:GetBaseItemString(val)
	if type(val) == "string" then
		local id = val:match("^i:([0-9]+)")
		if id and tonumber(id) then
--			Item:DebugPrintf("  is ItemString %s", tostring(id))
			return tonumber(id)
		end
	end
end

-- get online ItemLink of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemLink(val)
--	Item:DebugPrintf("GetItemLink(%s)", tostring(val))

	-- try online
	Item:GetItemInfo(val)
	if Item.cache[val] and Item.cache[val].ok then
--		Item:DebugPrintf("  is %s", tostring(Item.cache[val].link))
		return Item.cache[val].link
	end

--	Item:Printf("  GetItemLink(%s) = nil ?!", tostring(val))
end

-- get online soulbound status of ItemID/ItemString/ItemLink/PetString/PetLink or nil
function Item:GetItemIsBOP(val)
--	Item:DebugPrintf("GetItemIsBOP(%s)", tostring(val))

	-- try online
	Item:GetItemInfo(val)
	if Item.cache[val] and Item.cache[val].ok then
--		Item:DebugPrintf("  is %s", tostring(Item.cache[val].bop))
		return Item.cache[val].bop
	end
end

-- EOF
