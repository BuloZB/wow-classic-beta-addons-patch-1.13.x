------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/LDB.lua - LDB
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local LDB = addon:NewModule("LDB", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local private = {}
------------------------------------------------------------------------------

-- printing debug info
function LDB:DebugPrintf(...)
	if addon.isDebug then
		LDB:Printf(...)
	end
end

function LDB:Load()
	LDB:DebugPrintf("OnEnable()")

	private.LDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "data source", -- data source
	label = addonName,
	text = L["Loading"],
	icon = "Interface\\Icons\\INV_Misc_Summonable_Boss_Token",
	OnClick = function(self, button, down)
		if button == "LeftButton" then
			if addon.GUI.display then
				addon.GUI.display:Fire("OnClose")
			else
				addon.GUI:Load()
			end
		elseif button == "RightButton" then
			if (addon.db.realm.sesEnd == 0) then
				-- start next lap
				addon.db.realm.lapTime = time()
				addon.db.realm.lapNum = addon.db.realm.lapNum + 1
				if (addon.db.global.nwSound ~= "") then
					addon.Options.PlaySound()
				end
				if (addon.db.global.lpInstanceReset) then
					ResetInstances()
					addon:Printf(L["Resetting the instance."])
				end
				addon:Printf(L["Finishing Lap #%s with Looted Item Value %s."],
				addon.db.realm.lapNum - 1, GetCoinTextureString(addon.db.realm.sesMV))
			end
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine(addonName .. " " .. addon.METADATA.VERSION)
		tt:AddLine(" ")
		tt:AddLine(L["Current Session"])
		tt:AddDoubleLine(
			format(L["%sStarted at:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
				date(addon.timeFormat, addon.db.realm.sesTime))
		if (addon.db.realm.sesEnd == 0) then
			tt:AddDoubleLine(
				format(L["%sDuration:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
				SecondsToTime(time() - addon.db.realm.sesTime))
		else
			tt:AddDoubleLine(
				format(L["%sDuration:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
				SecondsToTime(addon.db.realm.sesEnd - addon.db.realm.sesTime))
		end
		tt:AddDoubleLine(
			format(L["%sLooted Item Value:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
			GetCoinTextureString(addon.db.realm.sesMV))
		tt:AddDoubleLine(
			format(L["%sLooted Gold:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
			GetCoinTextureString(addon.db.realm.sesGold))
		local gPerHour = (3600 / (time() - addon.db.realm.sesTime + 1)) *
			(addon.db.realm.sesMV + addon.db.realm.sesGold)
		tt:AddDoubleLine(
			format(L["%sGold per Hour:%s"], ITEM_QUALITY_COLORS[6].hex, FONT_COLOR_CODE_CLOSE),
			GetCoinTextureString(gPerHour))
		tt:AddLine(" ")
		tt:AddLine(format(L["%sLeft-Click%s opens the item database"], ITEM_QUALITY_COLORS[5].hex, FONT_COLOR_CODE_CLOSE))
		if (addon.db.global.lpInstanceReset) then
			tt:AddLine(format(L["%sRight-Click%s starts the next lap and resets the instances"], ITEM_QUALITY_COLORS[5].hex, FONT_COLOR_CODE_CLOSE))
		else
			tt:AddLine(format(L["%sRight-Click%s starts the next lap"], ITEM_QUALITY_COLORS[5].hex, FONT_COLOR_CODE_CLOSE))
		end
	end,
	})
end

function LDB:UpdateBroker()
	if not private.LDB then return end
	local m = addon.db.realm.sesMV or 0
	if m < 0 then
		m = 0
	end
	local gPerHour = (3600 / (time() - addon.db.realm.sesTime + 1)) *
			(addon.db.realm.sesMV + addon.db.realm.sesGold)
	if (addon.db.realm.sesEnd == 0) then
		if (addon.db.realm.lapNum <= 1) then
			private.LDB.text = L["Running: "] .. SecondsToTime(time() - addon.db.realm.sesTime) ..  " / " ..
				"LIV:" .. GetCoinTextureString(m)
		else
			private.LDB.text = L["Running (Lap #"] .. addon.db.realm.lapNum .. "): ".. SecondsToTime(time() - addon.db.realm.sesTime) ..  " / " ..
				"LIV:" .. GetCoinTextureString(m)
		end
	else
		private.LDB.text = L["Stopped: "] .. SecondsToTime(addon.db.realm.sesEnd - addon.db.realm.sesTime) ..  " / " ..
			"LIV:" .. GetCoinTextureString(m)
	end
end

-- EOF
