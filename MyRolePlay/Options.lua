--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Options.lua - Functions for handling base options, and version conversion
]]

local L = mrp.L
local strtrim = strtrim

local function emptynil( x ) return x ~= "" and x or nil end

mrp.DefaultOptions = {
	Enabled = true,
	ShowButton = true,
	ShowBiographyInBrowser = true,
	ShowTraitsInBrowser = true,
	HeightUnit = L["option_HeightUnit"],
	WeightUnit = L["option_WeightUnit"],
	FormAutoChange = true,
	AllowColours = true,
	TooltipClassColours = true,
	ClassNames = true,
	ShowOOC = true,
	ShowTarget = true,
	ShowVersion = true,
	HideTTInEncounters = false,
	ShowIconInTT = true,
	ShowGuildNames = true,
	ShowGlancePreview = true,
	MaxLinesSlider = 1,
	EquipSetAutoChange = true,
	GlancePosition = 0,
	TooltipStyle = 2,
	DEFontSize = 2,
	RPChatSay = true,
	RPChatWhisper = true,
	RPChatEmote = true,
	RPChatYell = true,
	RPChatParty = false,
	RPChatRaid = false,
	ShowIconsInChat = false,
	AutoplayMusic = false,
}



function mrp:UpgradeSaved( build )
	build = build or 0
	if build < 2 then
		mrpSaved.Options.ShowIconsInChat = false;
	end
end