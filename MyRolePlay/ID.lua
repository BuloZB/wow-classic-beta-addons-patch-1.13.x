--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	ID.lua - A list of users to specially identify i.e. debug/beta/dev users
]]

local L = mrp.L

-- ['guid'] = { "Realm-REGION", "identification" }
mrp.id = {
	-- Wyrmrest Accord vv
	['Player-1171-0696F1E8'] = { "Wyrmrest Accord-US", L["(( MyRolePlay Author ))"] }, -- Mackinzee (TheGildedFox)
	['Player-1171-069A4241'] = { "Wyrmrest Accord-US", L["(( MRP Alpha Tester ))"] }, -- Inte
	-- Moon Guard vv
	['Player-3675-06C390B1'] = { "Moon Guard-US", L["(( MyRolePlay Lead Developer ))"] }, -- Katorie
	['Player-3675-072C0877'] = { "Moon Guard-US", L["(( MyRolePlay Lead Developer ))"] }, -- Kisara (Katorie)
	['Player-3675-08185F8D'] = { "Moon Guard-US", L["(( MRP Development Team ))"] }, -- Mystra
	-- Inactive characters on armoury that were only testers removed - if necessary can re-add later if they become active again.
	-- I'd want to get Etarna back on this list if we can get her GUID. - Katorie
}
mrp.idrealm = setmetatable({}, {
	__index = function( table, key )
		return key
	end,
})
mrp.idrealm['WyrmrestAccord'] = "Wyrmrest Accord"