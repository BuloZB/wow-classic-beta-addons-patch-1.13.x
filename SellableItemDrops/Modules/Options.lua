------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/Options.lua - Addon Options
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local Options = addon:NewModule("Options", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
local private = {}
--------------------------------------------------------------------------------------------------------

--  Options
Options.defaults = {
	profile = {
	},
	global = {
		timeFormat = "ago",
		mvSource = "TSM:DBRegionMarketAvg",
		mvCustomSource = "TSM:DBRegionMarketAvg",
		minRarity = 2,
		minNoteworthy = "10000g",
		useVendorSellAsDefault = true,
		useVendorSellForGrays = true,
		useNotTheRealItemString = true,
		noGoldMessage = true,
		noItemMessage = false,
		noNoteWorthyMessage = false,
		noTransMogMessage = false,
		nwSound = "Simon Small Blue",
		useBVLists = false,
		useXBVLists = true,
		lpInstanceReset = true,
		shPlayer = false,
		shTime = true,
		shZone = true,
		discardCopper = true,
		discardSilver = false,
	},
}

-- printing debug info
function Options:DebugPrintf(...)
	if addon.isDebug then
		Options:Printf(...)
	end
end

function Options:Load()
	Options:DebugPrintf("OnEnable()")

	addon.db.realm.csvHis = addon.db.realm.csvHis or {}
	addon.db.realm.sesMV = abs(addon.db.realm.sesMV or 0) or 0
	addon.db.realm.sesGold = abs(addon.db.realm.sesGold or 0) or 0
	addon.db.realm.sesNumItems = addon.db.realm.sesNumItems or 0
	addon.db.realm.sesNumNW = addon.db.realm.sesNumNW or 0
	addon.db.realm.sesTime = addon.db.realm.sesTime or time()
	addon.db.realm.sesEnd = addon.db.realm.sesEnd or 0
	addon.db.realm.lapTime = addon.db.realm.lapTime or time()
	addon.db.realm.lapNum = addon.db.realm.lapNum or 1
	addon.sesItems = addon.sesItems or {}

	if LSM then
		LSM:Register("sound", "Default", [[Sound\interface\AuctionWindowOpen.ogg]])
		LSM:Register("sound", "Bell Toll Alliance", [[Sound\Doodad\BellTollAlliance.ogg1]])
		LSM:Register("sound", "Bell Toll Horde", [[Sound\Doodad\BellTollHorde.ogg]])
		LSM:Register("sound", "Auction Window Close", [[Sound\interface\AuctionWindowClose.ogg]])
		LSM:Register("sound", "Quest Failed", [[Sound\interface\igQuestFailed.ogg]])
		LSM:Register("sound", "Fel Nova", [[Sound\Spells\SeepingGaseous_Fel_Nova.ogg]])
		LSM:Register("sound", "Simon Large Blue", [[Sound\Doodad\SimonGame_LargeBlueTree.ogg]])
		LSM:Register("sound", "Simon Small Blue", [[Sound\Doodad\SimonGame_SmallBlueTree.ogg]])
		LSM:Register("sound", "Portcullis Close", [[Sound\Doodad\PortcullisActive_Closed.ogg]])
		LSM:Register("sound", "PvP Flag Taken", [[Sound\Spells\PVPFlagTaken.ogg]])
		LSM:Register("sound", "Cannon", [[Sound\Doodad\Cannon01_BlastA.ogg]])
		LSM:Register("sound", "Alarm 2", [[Sound\Interface\AlarmClockWarning2.ogg]])
	end

	if addon.db.global.mvSource == "DBRegionMarketAvg" then
		addon.db.global.mvSource = "TSM:DBRegionMarketAvg"
	end
end

function Options.PlaySound(key)
	if type(key) == "number" then
		PlaySound(key, "master")
	else
		if LSM and key and LSM:Fetch("sound", key) then
			if LSM:Fetch("sound", key) == "Interface\\Quiet.ogg" then
				-- PlaySound(5274, "master")
			else
				-- Options:Printf("Sound %s=%s", key, LSM:Fetch("sound", key))
				PlaySoundFile(LSM:Fetch("sound", key), "master")
			end
		else
			PlaySound(5274, "master")
		end
	end
end

function Options.GetOptions(uiType, uiName, appName)
	if appName == addonName then

		local soundValue = 1
		local soundList = {}

		local options = {
			type = "group",
			name = addon.METADATA.NAME .. " (" .. addon.METADATA.VERSION .. ")",
			get = function(info)
					return addon.db.global[info[#info]] or ""
				end,
			set = function(info, value)
					addon.db.global[info[#info]] = value
					addon.Data:UpdateSession()
					if addon.hisCTag and addon.hisCTag > 0 then
						addon.Data:UpdateDatabaseTag(addon.hisCTag)
					end
					if addon.GUI.display then
						addon.GUI.container:Reload()
					end
				end,
			args = {
				desc1a = {
					type = "description",
					order = 0,
					name = GetAddOnMetadata(addonName, "Notes"),
					fontSize = "medium",
				},
				desc1b = {
					type = "description",
					order = 0.05,
					name = "",
				},
				header01 = {
					type = "header",
					name = L["Item Options"],
					order = 1.01,
				},
				mvSource = {
					type = "select",
					style = "dropdown",
					name = L["Market Value Source"],
					desc = L["Select your TSM market value source."],
					order = 1.1,
					width = "full",
					values = addon.Item:GetPriceSources(),
					get = function(info)
						return addon.db.global[info[#info]] or ""
						end,
					set = function(info, value)
						addon.db.global[info[#info]] = value
						addon.Data:UpdateSession()
						if addon.GUI.display then
							addon.GUI.container:Reload()
						end
						end,
				},
				minRarity = {
					type = "select",
					style = "dropdown",
					name = L["Minimum Quality"],
					desc = L["Select the minimum item quality to display."],
					order = 2.1,
					width = "normal",
					values = addon.GUI.rarityList,
				},
				desc1c = {
					type = "description",
					order = 2.2,
					name = "",
					width = "normal",
				},
				timeFormat = {
					type = "select",
					style = "dropdown",
					name = L["Time Format"],
					desc = L["Select the format to display times."],
					order = 2.3,
					width = "normal",
					values = addon.GUI.timeFormat,
				},
				header1 = {
					type = "header",
					name = L["Misc. Options"],
					order = 4.01,
				},
				useVendorSellForGrays = {
					type = "toggle",
					name = L["Use VendorSell for Grays"],
					desc = L["If checked, the price source VendorSell is used for gray items instead of the market value, which is almost a really wrong value for grays."],
					order = 4.1,
					width = "double",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				useNotTheRealItemString = {
					type = "toggle",
					name = L["Discard Item Variants"],
					desc = L["Display the shorter base item and discard the variants and upgrades of an item. "],
					order = 4.2,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				useVendorSellAsDefault = {
					type = "toggle",
					name = L["Use VendorSell as default item value"],
					desc = L["If checked, the price source VendorSell is used for BOP items and if a price source returns 0."],
					order = 4.3,
					width = "double",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				useBVLists = {
					type = "toggle",
					name = L["LA/LAC values"],
					desc = L["Use a predefined blacklist and VendorSell list to be more compatible with LA/LAC."],
					order = 4.31,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
					set = function(info, value)
						addon.db.global[info[#info]] = value
						if value then
							addon.db.global.useXBVLists = false
						else
							addon.db.global.useXBVLists = true
						end
						addon.Data:UpdateSession()
						if addon.hisCTag and addon.hisCTag > 0 then
							addon.Data:UpdateDatabaseTag(addon.hisCTag)
						end
						if addon.GUI.display then
							addon.GUI.container:Reload()
						end
					end,
				},
				lpInstanceReset = {
					type = "toggle",
					name = L["Next Lap resets all instances too"],
					desc = L["When pressing Next Lap button or Rightclicking on minimap icon or LDB text an instance reset is done too."],
					order = 4.4,
					width = "double",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				useXBVLists = {
					type = "toggle",
					name = L["Extra VendorSells"],
					desc = L["Use VendorSell values for blacklisted/VendorSell items from LA/LAC and some additional items."],
					order = 4.41,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				shPlayer = {
					type = "toggle",
					name = L["Show Player in List"],
					desc = L["If checked, show the player in the item list."],
					order = 4.5,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				shZone = {
					type = "toggle",
					name = L["Show Zone in List"],
					desc = L["If checked, show the zone in the item list."],
					order = 4.6,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				shTime = {
					type = "toggle",
					name = L["Show Time in List"],
					desc = L["If checked, show the time in the item list."],
					order = 4.7,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				header3 = {
					type = "header",
					name = L["Noteworthy Item Options"],
					order = 5.01,
				},
				minNoteworthy = {
					type = "input",
					name = L["Noteworthy Item Value"],
					desc = L["Count items above this value and play an alarm sound."],
					order = 5.1,
					width = "normal",
					validate = function(info, value)
						if not addon.GUI:ToCopper(value) then
							return L["e.g. 1000g"]
						end
						return true
					end,
				},
				desc1d = {
					type = "description",
					order = 5.15,
					name = "",
					width = "normal",
				},
				nwSound = {
					type = "select",
					name = L["Noteworthy Sound"],
					desc = L["Select the sound file that is played if an item value is above the Noteworthy setting."],
					order = 5.2,
					width = "normal",
					dialogControl = "LSM30_Sound",
					values = WidgetLists.sound,
					set = function(_, value)
						-- value = "Default"
						addon.db.global.nwSound = value
					end,
				},
				header2 = {
					type = "header",
					name = L["SPAM Options"],
					order = 6.01,
				},
				discardSilver = {
					type = "toggle",
					name = L["Discard Silver"],
					desc = L["If checked, any values below 1g are not displayed."],
					order = 6.02,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				discardCopper = {
					type = "toggle",
					name = L["Discard Copper"],
					desc = L["If checked, any values below 1s are not displayed."],
					order = 6.03,
					width = "normal",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				noGoldMessage = {
					type = "toggle",
					name = L["Suppress messages about looted gold"],
					desc = L["If checked, no message is shown about looted gold."],
					order = 6.1,
					width = "full",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				noItemMessage = {
					type = "toggle",
					name = L["Suppress messages about looted items"],
					desc = L["If checked, no message is shown about looted items."],
					order = 6.2,
					width = "full",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				noNoteWorthyMessage = {
					type = "toggle",
					name = L["Suppress messages about looted noteworthy items"],
					desc = L["If checked, no message is shown about looted noteworthy items."],
					order = 6.3,
					width = "full",
					get = function(info) return addon.db.global[info[#info]] end,
				},
				noTransMogMessage = {
					type = "toggle",
					name = L["Suppress messages about new transmog items"],
					desc = L["If checked, no message is shown about looted new transmog items."],
					order = 6.4,
					width = "full",
					get = function(info) return addon.db.global[info[#info]] end,
				},
			},
		}
		return options
	end
end

-- EOF
