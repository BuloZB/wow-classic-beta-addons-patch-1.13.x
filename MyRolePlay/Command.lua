--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Command.lua - The chat command line interface (/mrp)
]]

local L = mrp.L
local strsplit, strtrim, strlower = strsplit, strtrim, strlower

mrp.Commands = {
	["version"] = function( )
		mrp:Print( L["%s by Etarna Moonshyne and |cffffc1fbKatorie (Moon Guard-NA)|r."], mrp.VerInfo )
	end,
	["help"] = function ( )
		mrp:Print( L["commandusage"] )
	end,
	["edit"] = function( )
		ToggleCharacter("MyRolePlayCharacterFrame")
		PlaySound(841)
	end,
	["options"] = function ( )
		InterfaceOptionsFrame_OpenToCategory( "MyRolePlay" )
	end,
	["option"] = "options",
	["opts"] = "options",
	["opt"] = "options",
	["enable"] = function( )
		mrp:Print( L["Enabling %s"], mrp.VersionString )
		mrp:Enable()
	end,
	["disable"] = function( )
		mrp:Print( L["Disabling %s"], mrp.VersionString )
		mrp:Disable()
	end,
	["button"] = {
		["toggle"] = function( )
			if mrpSaved.Options.ShowButton then
				mrp.Commands["button"]["off"]()
			else
				mrp.Commands["button"]["on"]()
			end
		end,
		["on"] = function( )
			mrpSaved.Options.ShowButton = true
			mrp:TargetChanged() -- will display button if appropriate
			mrp:Print( L["MRP will show a button near the target frame for players with an RP profile."] )
		end,
		["off"] = function( )
			mrpSaved.Options.ShowButton = false
			MyRolePlayButton:Hide()
			mrp:Print( L["MRP will no longer show a button near the target frame for players with an RP profile."] )
		end,
		["reset"] = function( )
			mrp:ResetMRPButtonPosition()
			mrp:Print( L["MRP button position reset to default."] )
		end,
		["show"] = "on",
		["hide"] = "off",
		["default"] = function( )
			mrp:Print( L["Usage: /mrp button toggle/on/off/reset"] )
		end,
	},
	["tooltip"] = {
		["toggle"] = function( )
			if mrpSaved.Options.TooltipStyle == 0 then
				mrp.Commands["tooltip"]["on"]()
			else
				mrp.Commands["tooltip"]["off"]()
			end
		end,
		["on"] = function( )
			mrpSaved.Options.TooltipStyle = mrp.OldTooltipStyle or 2
			mrp:Print( L["MRP will enhance player tooltips."] )
		end,
		["off"] = function( )
			if mrpSaved.Options.TooltipStyle == 0 then
				mrp.OldTooltipStyle = nil
			else
				mrp.OldTooltipStyle = mrpSaved.Options.TooltipStyle
			end
			mrpSaved.Options.TooltipStyle = 0
			mrp:Print( L["MRP will no longer handle player tooltips."] )
		end,
		["show"] = "on",
		["hide"] = "off",
		["default"] = function( para )
			if (tonumber( para or "" ) or -1) > -1 and (tonumber( para or "" ) or 9999) < 7 then
				mrpSaved.Options.TooltipStyle = tonumber( para )
				mrp:Print( L["Tooltip style changed to %s."], para )
			else
				mrp:Print( L["Usage: /mrp tooltip toggle/on/off"] )
			end
		end,
	},
	["profile"] = function( para, paras, input )
		local cmd, profilename = strsplit(" ", strtrim(input), 2)
		profilename = strtrim(profilename)
		if profilename and profilename ~= "" then
			if type(mrpSaved.Profiles[profilename]) == "table" then
				mrp:Print( L["Switching profile to: %s"], profilename )
				mrp:SetCurrentProfile( profilename )
			else
				mrp:Print( L["There’s no profile called %s."], profilename )
			end
		else
			mrp:Print( L["Usage: /mrp profile <profilename>"] )
			mrp:Print( L["Current profile is: %s"], (mrpSaved.SelectedProfile or "<not defined>") )
		end	
	end,
	["browse"] = "show",
	["browser"] = "show",
	["show"] = function( para, paras, input )
		local name, realm, cmd
		if para == "reset" then
			mrp:BrowseFrameReset()
			mrp:Print( L["MRP browser reset to default size & position."] )
		elseif para ~= "" then
			cmd, name = strsplit(" ", strtrim(input), 2)
			name = strtrim( name )
			if(name:match("%-")) then
				realm = name:match("%-(.+)")
				name = name:match("^(.-)%-")
			end
			name = name:lower()
			name = name:gsub("^[%z\1-\127\194-\244][\128-\191]*", string.upper) -- Capitalise first letter (thanks Tammya-MoonGuard for utf-8 friendly pattern match)
			if not(realm) then
				name = (name .. "-" .. GetRealmName():gsub("[%s*%-*]", ""))
				mrp:Show( name )
			else
				mrp:Show( name .. "-" .. realm)
			end
			mrp:Print( L["Requesting details from %s."], name )
		else
			if UnitExists("target") and UnitIsPlayer("target") then
				if UnitIsUnit("player", "target") then
					name = UnitName("player")
				else
					name = mrp:UnitNameWithRealm("target")
				end
				mrp:Show( name )
			else
				mrp:Print( L["Usage: /mrp show (<charactername>)"] )
			end
		end
	end,
	["c"] = "currently",
	["cu"] = "currently",
	["cur"] = "currently",
	["currently"] = function( para, paras, input )
		local cmd, currently = strsplit(" ", strtrim(input), 2)
		local profile = mrpSaved.SelectedProfile or "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			mrpSaved.SelectedProfile = "Default"
			profile = mrpSaved.SelectedProfile
		end
		mrpSaved.Profiles[profile].CU = currently or ""
		mrp:HideEditFrames()
		mrp:SetCurrentProfile()
		if currently then
			mrp:Print( L["%s: %s"], L["CU"], currently )
		else
			mrp:Print( L["%s field cleared."], L["CU"] )
		end
	end,
	["ooc"] = function( )
		local profile = mrpSaved.SelectedProfile or "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			mrpSaved.SelectedProfile = "Default"
			profile = mrpSaved.SelectedProfile
		end
		mrpSaved.Profiles[profile].FC = "1"
		mrp:HideEditFrames()
		mrp:SetCurrentProfile()
		mrp:Print( L["%s: Flagged as %s."], L["FC"], L["FC1t"] )
	end,
	["ic"] = function( )
		local profile = mrpSaved.SelectedProfile or "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			mrpSaved.SelectedProfile = "Default"
			profile = mrpSaved.SelectedProfile
		end
		mrpSaved.Profiles[profile].FC = "2"
		mrp:HideEditFrames()
		mrp:SetCurrentProfile()
		mrp:Print( L["%s: Flagged as %s."], L["FC"], L["FC2t"] )
	end,
	["contact"] = "lfc",
	["lfc"] = function( )
		local profile = mrpSaved.SelectedProfile or "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			mrpSaved.SelectedProfile = "Default"
			profile = mrpSaved.SelectedProfile
		end
		mrpSaved.Profiles[profile].FC = "3"
		mrp:HideEditFrames()
		mrp:SetCurrentProfile()
		mrp:Print( L["%s: Flagged as %s."], L["FC"], L["FC3t"] )
	end,
	["storyteller"] = "st",
	["st"] = function( )
		local profile = mrpSaved.SelectedProfile or "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			mrpSaved.SelectedProfile = "Default"
			profile = mrpSaved.SelectedProfile
		end
		mrpSaved.Profiles[profile].FC = "4"
		mrp:HideEditFrames()
		mrp:SetCurrentProfile()
		mrp:Print( L["%s: Flagged as a %s."], L["FC"], L["FC4t"] )
	end,
	["default"] = function( )
		mrp:Print( L["I’m sorry, I haven’t a clue what you mean. Try |cff90ffff/mrp help|r for valid commands."] )
	end,
}

local function mrp_OnChatCommand( input )
	-- What do we do if someone just types /mrp?
	if not input or strtrim(input) == "" then
		input = "edit"
	end
	local cmd, para, paras = strsplit(" ", strtrim(input), 3)
	cmd = strlower(cmd or "")
	para = strlower(para or "")
	if type(mrp.Commands[ cmd ]) == "function" then
		mrp.Commands[ cmd ]( para, paras, input )
	elseif type(mrp.Commands[ cmd ]) == "table" then
		if type(mrp.Commands[ cmd ][ para ]) == "function" then
			mrp.Commands[ cmd ][ para ] ( paras, input )
		elseif type(mrp.Commands[ cmd ][ para ]) == "string" then
			mrp.Commands[ cmd ][ mrp.Commands[ cmd ][ para ] ] ( para, paras, input )
		else
			mrp.Commands[ cmd ][ "default" ] ( para, paras, input )
		end
	elseif type(mrp.Commands[ cmd ]) == "string" then
		mrp.Commands[ mrp.Commands[ cmd ] ] ( para, paras, input )
	else
		mrp.Commands[ "default" ] ( cmd, para, paras, input )
	end
end

function mrp:RegisterChatCommand()
	SlashCmdList[ "MRP" ] = mrp_OnChatCommand
	SLASH_MRP1 = "/mrp"
	SlashCmdList[ "MYROLEPLAY" ] = mrp_OnChatCommand
	SLASH_MRP2 = "/myroleplay"
end

function mrp:UnregisterChatCommand()
	SlashCmdList[ "MRP" ] = nil
	SlashCmdList[ "MYROLEPLAY" ] = nil
end