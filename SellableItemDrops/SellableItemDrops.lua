------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- SellableItemDrops.lua
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local private = {}
------------------------------------------------------------------------------

addon.METADATA = {
	NAME = GetAddOnMetadata(..., "Title"),
	VERSION = GetAddOnMetadata(..., "Version")
}

-- called by AceAddon when Addon is fully loaded
function addon:OnInitialize()
	-- makes Module ABC accessable as addon.ABC
	for module in pairs(addon.modules) do
		addon[module] = addon.modules[module]
	end

	-- loads data and options
	addon.db = AceDB:New(addonName .. "DB", addon.Options.defaults, true)
	AceConfigRegistry:RegisterOptionsTable(addonName, addon.Options.GetOptions)
	local optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addon.METADATA.NAME)
	addon.Options.frame = optionsFrame

	-- addon state flags
	addon.isDebug = false
	addon.isDemo = false
	addon.isInfight = false

	addon.ExternalsInfo = ""
	local UJV = GetAddOnMetadata("TheUndermineJournal", "Version")
	if (UJV) then
		if TUJMarketInfo then
			addon.ExternalsInfo = addon.ExternalsInfo .. "The Undermine Journal " .. UJV .. "\n"
		end
	end
	local TSMV3 = GetAddOnMetadata("TradeSkillMaster", "Version")
	if (TSMV3) then
		if TSMAPI and TSMAPI.GetItemValue then
			addon.ExternalsInfo = addon.ExternalsInfo .. "Trade Skill Master 3 " .. TSMV3 .. "\n"
		end
	end
	local TSMV4 = GetAddOnMetadata("TradeSkillMaster", "Version")
	if (TSMV4) then
		if TSM_API and TSM_API.GetCustomPriceValue then
			addon.ExternalsInfo = addon.ExternalsInfo .. "Trade Skill Master 4 " .. TSMV4 .. "\n"
		end
	end
	local AUCV = GetAddOnMetadata("Auctionator", "Version")
	if (AUCV) then
		addon.ExternalsInfo = addon.ExternalsInfo .. "Auctionator " .. AUCV .. "\n"
	end
	if (CanIMogIt) then
		local CIMV = GetAddOnMetadata("CanIMogIt", "Version")
		addon:Printf(L["Found %s Version %s."], "Can I Mog It?", CIMV)
		addon.ExternalsInfo = addon.ExternalsInfo .. "Can I Mog It? " .. CIMV .. "\n"
	end

	-- initialize standard time format
	addon.timeFormat = "%Y-%m-%d %H:%M:%S";
	if (GetLocale() == "deDE") then
		addon.timeFormat = "%d.%m.%Y %H:%M:%S"
	end

	-- initialize chat command
	local chatfunc = function()
		if not addon.GUI.display then
			addon.GUI:Load()
		end
	end
	addon:RegisterChatCommand("sid", chatfunc)
	addon:RegisterChatCommand("siddebug", addon.ToggleDebug)

	-- initialize writing data on player logout
	addon:RegisterEvent("PLAYER_LOGOUT", function()
		addon:OnLogout()
		end)
end

-- called when Player logs out
function addon:OnLogout()
	addon.Data:SaveSession()
	addon.GUI:OnLogout()
end

-- called once a second to updated session summary data and the broker display
local function SecTimer()
	local oldDebug = addon.isDebug
	addon.isDebug = false
	addon.GUI:UpdateSessionData(false)
	-- update session info data some sec. after loading
	if addon.Data.secToUpdate and addon.Data.secToUpdate > 0 then
		addon.Data.secToUpdate = addon.Data.secToUpdate - 1
		if addon.Data.secToUpdate == 10 then
			addon:Printf("Session data updated.")
			addon.GUI:UpdateSessionData(true)
			addon.Data:UpdateSession()
		end
		if addon.Data.secToUpdate == 0 then
			addon:Printf("Item lists updated.")
			addon.GUI:UpdateSessionData(true)
			addon.Data:UpdateSession()
			if addon.GUI.display then
				addon.GUI.container:Reload()
			end
		end
	end
	addon.isDebug = oldDebug
end

-- called by AceAddon on PLAYER_LOGIN
function addon:OnEnable()
	print("|cFF33FF99" .. addonName .. " (" .. addon.METADATA.VERSION .. ")|r: ", L["enter /sid for interface"])

	-- give every module a chance to do things
	addon.PFCH:Load()
	-- Item: set up item cache etc.
	addon.Item:Load()
	-- Options: initialize global variables
	addon.Options:Load()
	-- LDB: create and initialize LDB broker
	addon.LDB:Load()
	-- Data: load current session data
	addon.Data:Load()
	-- initialize LDB data for loaded session data
	addon:UpdateBroker()
	addon.sectimer = C_Timer.NewTicker(1, SecTimer)

	-- check if the currently used price source is available and check for sanity of options
	addon:CheckSettings()
	-- print info on loaded session data
	addon.GUI:ShowInfo()

	-- this should not happen, but if there was an error on loading and
	-- initializing old session data, give user a hint to rescue himself
	if not addon.sesItemsLoaded then
		addon:Printf(L["|cffff0000IMPORTANT:|r"] ..
			L["There was an error loading the previous item data. "] ..
			L["Heads up, recover is possible:\n"] ..
			L[" 1. Logout (Character Screen is ok).\n"] ..
			L[" 2. Find your game data directory WTF\\<Account>>\\SaveVariables\n"] ..
			L[" 3. Delete the file "] .. addonName .. L[".lua and rename "] .. addonName .. L[".bak to"] .. addonName .. L[".lua\n"] ..
			L[" 4. Login. "])
	end

	-- enable processing of loot events
	addon.Data:RegisterLootEvents()
end

-- check if the currently used price source is available and check for sanity of options
function addon:CheckSettings()
	local psFallBack = ""
	local mvSourcesList = addon.Item:GetPriceSources() or {}
	if not mvSourcesList then
		addon:Printf(L["|cffff0000IMPORTANT:|r"])
		addon:Printf(L["No valid price sources. Please enable UJ or TSM and/or check your price source."])
	else
		found = false
		for k,v in pairs(mvSourcesList) do
			-- addon.Data:DebugPrintf("found UJ/TSM Price Source %s/%s", k, v)
			if strlower(k) == strlower(addon.db.global.mvSource) then
				addon.Data:DebugPrintf(" ... using it")
				found = true
				break
			end
		end
		if not found then
			addon:Printf(L["|cffff0000IMPORTANT:|r"])
			addon:Printf(L["Your price source '%s' is currently not usable."],
				mvSourcesList[addon.db.global.mvSource] or addon.db.global.mvSource)
			if addon.db.global.mvSource:match("^TSM:(.+)$") then
				addon:Printf(L["Please enable your TSM modules and/or check if your TSM desktop app is running."])
			elseif addon.db.global.mvSource:match("^UJ:(.+)$") then
				addon:Printf(L["Please enable your The Undermine Journal addon."])
			end
			-- if no explicit fallback price source given, TSM uses VendorSell if no AH data is present
			if (psFallBack ~= "") then
				addon:Printf(L["'%s' is used for now."], mvSourcesList[psFallBack] or psFallBack)
				addon.db.global.mvSource = psFallBack
			else
				if addon.db.global.useVendorSellAsDefault then
					addon:Printf(L["Until '%s' is available, 'VendorSell' is used instead."],
						mvSourcesList[addon.db.global.mvSource] or addon.db.global.mvSource)
				end
			end
		end
	end

	-- check for valid notewortyh value
	if not addon.GUI:ToCopper(addon.db.global.minNoteworthy) then
		addon:Printf(L["|cffff0000IMPORTANT:|r"] .. L["Your entry of '%s' for noteworthy items is not usable. It has been reset to 10000g."],
			addon.db.global.minNoteworthy)
		addon.db.global.minNoteworthy = "10000g"
	end
end

-- update LDB data for current session
function addon:UpdateBroker()
	if addon.LDB then
		addon.LDB:UpdateBroker()
	end
end

function addon:ToggleDebug()
	addon.isDebug = not addon.isDebug
	if (not addon.isDebug) then
		addon:Printf(L["Debug is off"])
		sid = nil
	else
		addon:Printf(L["Debug is on"])
		sid = addon
	end
end

local function sidloot(item, qty, rarity)
	addon.Data:InsertItem(item, qty, rarity)
end

function addon:sidtest()
	sidloot("|cff1eff00|Hitem:15676::::::::111:104::1:1:1705:::|h[Wunderbare Gamaschen der Aurora]|h|r", 1, 0)
	addon.Data:UpdateSession()
	addon.GUI:UpdateSessionData(true)
end


-- EOF
