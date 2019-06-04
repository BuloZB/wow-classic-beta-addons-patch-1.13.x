------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Widgets/SIDnil - an Ace3 Testing Widget
--
-- Author: Caraxe/Expelliarmuuuuus
--
-- Version 0.4.9
------------------------------------------------------------------------------
local Type, Version = "SIDnil", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
------------------------------------------------------------------------------

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

local methods = {
	["OnAcquire"] = function(self)
	end,

	["OnRelease"] = function(self)
	end,

	["OnWidthSet"] = function(self, width)
	end,

	["OnHeightSet"] = function(self, height)
	end,
}

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetAllPoints()

	local widget = {
		frame = frame,
		type = Type,
	}

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

-- EOF
