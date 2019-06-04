------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Modules/PFCH.lua - Convert pet items to their caged versions
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local PFCH = addon:NewModule("PFCH", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local private = {}
------------------------------------------------------------------------------

-- printing debug info
function PFCH:DebugPrintf(...)
	if (addon.isDebug) then
		PFCH:Printf(...)
	end
end

-- load current session data
function PFCH:Load()
	PFCH:DebugPrintf("OnEnable()")
end

-- newShortItemString = PfchItemID2Species(itemID)
function PFCH:PfchItemID2Species(itemID)
	if itemID and type(itemID) == "number" and addon.PfchData and addon.PfchData[itemID] then
		return addon.PfchData[itemID]
	end
end

-- EOF
