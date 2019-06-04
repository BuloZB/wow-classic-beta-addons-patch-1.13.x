local T, C, L = select(2, ...):unpack()

local Miscellaneous = T["Miscellaneous"]
local Movers = T["Movers"]
local VehicleIndicator = CreateFrame("Frame")

function VehicleIndicator:Enable()
	local Indicator = VehicleSeatIndicator

	Indicator:ClearAllPoints()
	Indicator:SetParent(UIParent)
	Indicator:SetPoint("BOTTOM", 0, T.ScreenHeight / 4)

	-- This will block UIParent_ManageFramePositions() to be executed
	Indicator.IsShown = function() return false end

	Movers:RegisterFrame(Indicator)
end

Miscellaneous.VehicleIndicator = VehicleIndicator
