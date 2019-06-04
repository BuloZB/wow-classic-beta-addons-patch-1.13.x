--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Tooltip.lua - Functions to handle the MRP tooltips
]]

local L = mrp.L

local strsub, format, ceil = strsub, format, math.ceil

local blankline = " "

local function emptynil( x ) return x ~= "" and x or nil end

local function mrp_MouseoverEvent( this, event, addon )
	if event == "UPDATE_MOUSEOVER_UNIT" then
		if not mrpSaved.Options.Enabled then
			return true
		end
		if UnitIsUnit( "player", "mouseover" ) then
			mrp:UpdateTooltip( UnitName("player"), "player" )
		elseif UnitIsPlayer("mouseover") then
			msp:Request( mrp:UnitNameWithRealm("mouseover"), {'TT', 'PE'} )
			mrp:UpdateTooltip( mrp:UnitNameWithRealm("mouseover"), "mouseover" )
		else
			mrp.TTShown = nil
		end
		return true
	end
end

local df = MyRolePlayDummyTooltipFrame or CreateFrame( "Frame", "MyRolePlayDummyTooltipFrame" )
df:SetScript( "OnEvent", mrp_MouseoverEvent )

-- Disable TT during combat.

local function mrp_EncounterStartEnd(this, event, encounterID, encounterName, difficultyID, groupSize, success)
	if(mrpSaved.Options.HideTTInEncounters and mrpSaved.Options.HideTTInEncounters == true) then
		if(event == "PLAYER_REGEN_DISABLED") then
			mrp:UnhookTooltip()
		elseif(event == "PLAYER_REGEN_ENABLED") then
			mrp:HookTooltip()
		end
	end
end

--

local encounterFrame = MyRolePlayDummyEncounterFrame or CreateFrame( "Frame", "MyRolePlayDummyEncounterFrame" )
encounterFrame:SetScript( "OnEvent", mrp_EncounterStartEnd )
encounterFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
encounterFrame:RegisterEvent("PLAYER_REGEN_DISABLED");

function mrp:HookTooltip()
	MyRolePlayDummyTooltipFrame:RegisterEvent( "UPDATE_MOUSEOVER_UNIT" )
	-- also hook GameTooltip:SetUnit()
end

function mrp:UnhookTooltip()
	MyRolePlayDummyTooltipFrame:UnregisterEvent( "UPDATE_MOUSEOVER_UNIT" )
	-- also unhook GameTooltip:SetUnit()
end

--[[
	EPIC KLUDGE!
	Special local functions to overwrite and add the current tooltip.
]]
-- Single string
local function gtal( n, r, g, b, wordWrap, fontSize)
	local l = GameTooltip.mrpLines + 1
	GameTooltip.mrpLines = l

	r, g, b = (r or 1.0), (g or 1.0), (b or 1.0)

	if _G["GameTooltipTextLeft"..tostring(l)] then
		if _G["GameTooltipTextLeft"..tostring(l)]:IsVisible() then
			if _G["GameTooltipTextRight"..tostring(l)] then
				_G["GameTooltipTextRight"..tostring(l)]:Hide()
			end
			_G["GameTooltipTextLeft"..tostring(l)]:SetText( n )
			_G["GameTooltipTextLeft"..tostring(l)]:SetTextColor( r, g, b )
		else
			GameTooltip:AddLine( n, r, g, b, true )
		end
	else
		GameTooltip:AddLine( n, r, g, b, true )
	end 
end
-- Double string
local function gtadl( n, t, r1, g1, b1, r2, g2, b2, fontSize )
	local l = GameTooltip.mrpLines + 1
	GameTooltip.mrpLines = l

	r1, g1, b1 = (r1 or 1.0), (g1 or 1.0), (b1 or 1.0)
	r2, g2, b2 = (r2 or 1.0), (g2 or 1.0), (b2 or 1.0)

	if _G["GameTooltipTextLeft"..tostring(l)] then
		if _G["GameTooltipTextLeft"..tostring(l)]:IsVisible() then
			if _G["GameTooltipTextRight"..tostring(l)] then
				_G["GameTooltipTextRight"..tostring(l)]:Show()
			end
			_G["GameTooltipTextLeft"..tostring(l)]:SetText( n )
			_G["GameTooltipTextLeft"..tostring(l)]:SetTextColor( r1, g1, b1 )
			_G["GameTooltipTextRight"..tostring(l)]:SetText( t )
			_G["GameTooltipTextRight"..tostring(l)]:SetTextColor( r2, g2, b2 )
		else
			GameTooltip:AddDoubleLine( n, t, r1, g1, b1, r2, g2, b2 )
		end
	else
		GameTooltip:AddDoubleLine( n, t, r1, g1, b1, r2, g2, b2 )
	end
end

-- Add a blank line to the tooltip (if this isn't a compact style)
local function gtabl( )
	if mrpSaved.Options.TooltipStyle ~= 3 then
		gtal( blankline )
	end
end
-- Alternate "Light" mode tooltip embedding. Well, lightER anyway.
-- Actually GameTooltip: AddLines, but with a secret sauce sentinel colour value (overridden in text) to hopefully uniquely identify OUR text line and replace if already present
-- Embed \n to use multiple lines, because this technique limits us to ONE (1) fontstring
local function gtcal( text )
	local t, r, g, b
	for t = 1, GameTooltip:NumLines() do
		local r, g, b = _G["GameTooltipTextLeft"..tostring( t )]:GetTextColor()
		--mrp:DebugSpam( "gtc%s[%s,%s,%s]", t, ceil(r*255), ceil(g*255), ceil(b*255) )
		if ceil(r*255) == 60 and ceil(g*255) == 109 and ceil(b*255) == 144 then
			-- This is ours! Don't add a new one, replace this one
			_G["GameTooltipTextLeft"..tostring( t )]:SetText( text )
			return
		end
	end
	GameTooltip:AddLine( text, 0.2353, 0.4274, 0.5647, false ) -- magic values, match the if statement above
end

local GetClassIconString = function(class, icon_size) -- Function to get the correct icon string for a race.
        local classLookupTable = {
                ["Warrior"]       = "WARRIOR",
                ["Paladin"]       = "PALADIN",
                ["Hunter"]        = "HUNTER",
                ["Rogue"]         = "ROGUE",
                ["Priest"]        = "PRIEST",
                ["Death Knight"]  = "DEATHKNIGHT",
                ["Shaman"]        = "SHAMAN",
                ["Mage"]          = "MAGE",
                ["Warlock"]       = "WARLOCK",
                ["Monk"]          = "MONK",
                ["Druid"]         = "DRUID",
                ["Demon Hunter"]  = "DEMONHUNTER",
        };
       
		local classIconStrings = {
			["WARRIOR"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:0:16:0:16|t",
			["MAGE"]    = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:0:16|t",
			["ROGUE"]   = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:0:16|t",
			["DRUID"]   = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:47:64:0:16|t",
			["HUNTER"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:0:16:16:32|t",
			["SHAMAN"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:16:32|t",
			["PRIEST"]  = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:16:32|t",
			["WARLOCK"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:48:64:16:32|t",
			["PALADIN"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-1.7:64:64:0:16:32:48|t",
			["DEATHKNIGHT"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:16:32:32:48|t",
			["MONK"]    = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:32:48:32:48|t",
			["DEMONHUNTER"] = "|TInterface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES:%i:%i:0:-2:64:64:48:64:32:48|t",
		};
       
        if((classLookupTable[class] == nil)) then
            return tostring(class);
        else
            return string.format(classIconStrings[classLookupTable[class]], icon_size or 17, icon_size or 17);
        end
end

-- Tooltip updating
function mrp:UpdateTooltip( player, unit )
	player = player or mrp.TTShown or nil
	local t, r, g, b, n, e, m
	if not player or player == "" or ( mrpSaved.Options.TooltipStyle == 0 ) then
		return false
	end
	if not unit and ( mrp:UnitNameWithRealm("mouseover") == player ) or ( UnitName("mouseover") == player ) then
		unit = "mouseover"
	elseif ( player == UnitName("player") ) then
		unit = "player"
	end
	if not unit then
		return false
	end

	mrp.TTShown = player

	if player == "Unknown" then
		return false
	end

	if not UnitIsPlayer( unit ) then
		return false
	end
	
	-- Reset the tooltip to fix some resize issues in Classic.
    local owner = GameTooltip:GetOwner();
    GameTooltip:ClearLines();
    GameTooltip_SetDefaultAnchor(GameTooltip, owner or UIParent);
	
	local name, otherrealm = UnitName( unit )
	local realm = otherrealm or GetRealmName()
	local nameWithRealm = (name .. "-" .. GetRealmName():gsub("[%s*%-*]", ""))
	local guid = UnitGUID( unit )
	local guild, guildrank, guildrankindex = GetGuildInfo( unit )
	local factionunloc, faction = UnitFactionGroup( unit )
	local namewithtitle = UnitPVPName( unit ) or UnitName( unit )
	local afk = UnitIsAFK( unit )
	local dnd = UnitIsDND( unit )
	local level = UnitLevel( unit )
	local class, classunloc = UnitClass( unit )
	local race = UnitRace( unit ) or ""
	local connected = UnitIsConnected( unit )
	local inphase = UnitInPhase( unit )
	local gm = (strsub(name,1,4)=="<GM>")
	local dev = (strsub(name,1,5)=="<DEV>")
	local mspsupported = msp.char[player].supported
	local f
	if mspsupported then
		f = msp.char[player].field
	end
	
	if(faction == "Alliance") then
		faction = "|TInterface\\WorldStateFrame\\AllianceIcon:16:16:0:-2|t"
	elseif(faction == "Horde") then
		faction = "|TInterface\\PVPFrame\\PVP-Currency-Horde:17:17:0:-2|t"
	end

	faction = faction or "Unknown"

	GameTooltip.mrpLines = 0
	GameTooltip.orgLines = 2 + ( guild and 1 or 0 ) + ( UnitIsPVP( unit ) and 1 or 0 ) -- *Should* be the number of lines in the default Blizz player tooltip...?

	-- OK, time to draw the tooltip. Which style to draw it in?
	if mrpSaved.Options.TooltipStyle == 1 then 
		-- Basic / flag-style
		t = ""
		if mspsupported then
			GameTooltipTextLeft1:SetText( emptynil( mrp.DisplayTooltip.NA( f.NA ) ) or namewithtitle )
			if emptynil( f.NT ) then
				t = format( "%s|cffcec185“|cfffef1b5%s|cffcec185”\n", t, mrp.DisplayTooltip.NT( f.NT ) )
			end
			if ( f.FR and f.FR ~= "" and f.FR ~= "0" ) and ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933, |cffddaa44%s|cffcc9933>\n", t, mrp.DisplayTooltip.FR( f.FR ), mrp.DisplayTooltip.FC( f.FC ))
			elseif ( f.FR and f.FR ~= "" and f.FR ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933>\n", t, mrp.DisplayTooltip.FR( f.FR ))
			elseif ( f.FC and f.FC ~= "" and f.FC ~= "0" ) then
				t = format( "%s|cffcc9933<|cffeebb55%s|cffcc9933>\n", t, mrp.DisplayTooltip.FC( f.FC ))
			else
				t = format( "%s|cff44aaaa[|cff66dddd%s|cff44aaaa]\n", t, mrp.DisplayTooltip.VA( f.VA ) )
			end
		end
		r, g, b = mrp:UnitColour( unit )
		GameTooltipTextLeft1:SetTextColor( r, g, b )
		if mrp.id[guid] then
			if mrp.id[guid][1] == realm..(GetLocale() =="enUS" and "-US" or "-EU") then
				t = format( "%s|cffffe680%s", t, mrp.id[guid][2] )
			end
		end
		t = strtrim( t )
		if emptynil( t ) then
			gtcal( strtrim(t) )
			GameTooltip:Show()
		end
	else 
		-- Enhanced or compact (either with or without guild ranks)
		if mspsupported then
			r, g, b = mrp:UnitColour( unit )
			if afk then
				m = L[" |cff99994d<AFK>|r"]
			elseif dnd then
				m = L[" |cff994d4d<DND>|r"]
			else
				m = ""
			end
			if(f.IC and f.IC ~= "" and mrpSaved.Options.ShowIconInTT == true) then
				gtal( "|TInterface\\ICONS\\" .. f.IC .. ":22:22:0:-2|t " .. (emptynil(mrp.DisplayTooltip.NA( f.NA )) or name) .. m, r, g, b )
			else
				gtal( (emptynil(mrp.DisplayTooltip.NA( f.NA )) or name) .. m, r, g, b )
			end
			if(f.TR == "1" or f.TR == "2") then
				gtal("<Trial Account>", 0.2, 1, 0.26 )
			end
			local line = false
			if f.NT and f.NT ~= "" then 
				gtal( mrp.DisplayTooltip.NT( f.NT ) , 0.6, 0.7, 0.9 )
				line = true
			end
			if f.NI and f.NI ~= "" then 
				gtal( format( "|cff6070a0" .. L["NI"] .. ":|r %s", mrp.DisplayTooltip.NI( f.NI ) ), 0.6, 0.7, 0.9 )
				line = true
			end
			if f.NH and f.NH ~= "" then 
				gtal( mrp.DisplayTooltip.NH( f.NH ), 0.4, 0.6, 0.7 )
				line = true
			end
		else
			r, g, b = mrp:UnitColour( unit )

			gtal( name, r, g, b )
		end

		if guild and guild ~= "" then
			if(mrpSaved.Options.ShowGuildNames and mrpSaved.Options.ShowGuildNames == true) then -- If guild rank checkbox is enabled
				if guildrankindex == 0 then
					m = format( "|cffffeeaa%s|r", guildrank )
				else
					m = guildrank
				end
				gtal( format( L["%s of <%s>"], m, guild ), 1, 1, 1 )
			else -- If guild rank checkbox is disabled
				-- Show Guild rank disabled (but colour it gold if they're guildmaster)
				gtal( format( "%s<%s>", ( guildrankindex == 0 ) and "|cffffeeaa" or "", guild ), 1, 1, 1 )
			end
		end

		if not factionunloc then
			r, g, b = 0.4, 0.9, 0.4
		elseif factionunloc == "Alliance" then
			r, g, b = 0.4, 0.5, 0.9
		elseif factionunloc == "Horde" then
			r, g, b = 0.8, 0.3, 0.3
		else
			r, g, b = 1.0, 1.0, 1.0
		end
		
		if namewithtitle and #namewithtitle > 30 then -- Reduce name with title string length if too long to avoid bloating our tooltip.
			namewithtitle = strsub( namewithtitle, 1, 30 ) .. "…"
		end

		if otherrealm and otherrealm ~= "" then
			if (UnitName("mouseovertarget") and mrpSaved.Options.ShowTarget and mrpSaved.Options.ShowTarget == true) then
				local classColourStr = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("mouseovertarget"))].colorStr
				gtadl( format(L["%s %s [%s]"], GetClassIconString(class), namewithtitle, otherrealm), format( "%s %s%s", "|TInterface\\ICONS\\Ability_Hunter_SniperShot:17:17:0:-2|t", classColourStr, UnitName("mouseovertarget")), r, g, b, 1, 0.82, 0.01)
			else
				gtal( format(L["%s %s [%s]"], GetClassIconString(class), namewithtitle, otherrealm), r, g, b, false)
			end
		else
			if (UnitName("mouseovertarget") and mrpSaved.Options.ShowTarget and mrpSaved.Options.ShowTarget == true) then
				local classColourStr = "|c" .. RAID_CLASS_COLORS[select(2, UnitClass("mouseovertarget"))].colorStr
				gtadl( format(L["%s %s"], GetClassIconString(class), namewithtitle), format( "%s %s%s", "|TInterface\\ICONS\\Ability_Hunter_SniperShot:17:17:0:-2|t", classColourStr, UnitName("mouseovertarget")), r, g, b, 1, 0.82, 0.01)
			else
				gtal( format(L["%s %s"], GetClassIconString(class), namewithtitle), r, g, b, false)
			end
		end

		r, g, b = RAID_CLASS_COLORS[ classunloc ].r, RAID_CLASS_COLORS[ classunloc ].g, RAID_CLASS_COLORS[ classunloc ].b
		if level ~= nil and level < 0 then
			e = L["|cffffffff(Boss)"]
		else 
			e = format( "|cffffffff" .. L["level"] .. " %d", level )
		end
		if mspsupported then
			if(mrpSaved.Options.ClassNames and mrpSaved.Options.ClassNames == true and msp.char[nameWithRealm]["field"]["RC"]) then
				if(mrpSaved.Options.AllowColours and mrpSaved.Options.AllowColours == true and mrpSaved.Options.TooltipClassColours and mrpSaved.Options.TooltipClassColours == true) then
					gtal( format( L["%s %s |r%s"], e, emptynil( mrp.DisplayTooltip.RA( f.RA ) ) or race, emptynil(msp.char[nameWithRealm]["field"]["RC"]) or class), r, g, b, true)
				else
					gtal( format( L["%s %s |r%s"], e, emptynil( mrp.DisplayTooltip.RA( f.RA ) ) or race, emptynil(msp.char[nameWithRealm]["field"]["RC"]:gsub("|cff%x%x%x%x%x%x", "")) or class), r, g, b, true)
				end
			else
				gtal( format( L["%s %s |r%s"], e, emptynil( mrp.DisplayTooltip.RA( f.RA ) ) or race, class), r, g, b, true)
			end
			r, g, b = 1.0, 1.0, 1.0
			n = nil
			t = nil
			if f.FR and f.FR ~= "" and f.FR ~= "0" then
				n = mrp.DisplayTooltip.FR( f.FR ) .. "  "
			end
			if f.FC and f.FC ~= "" and f.FC ~= "0" then
				t = mrp.DisplayTooltip.FC( f.FC )
				if f.FC == "0" then
					r, g, b = 0.5, 0.5, 0.5
				elseif f.FC == "1" then -- OOC
					r, g, b = 0.6, 0.1, 0.06
				elseif f.FC == "2" then -- IC
					r, g, b = 0.4, 0.7, 0.5
				elseif f.FC == "3" then -- LFC
					r, g, b = 0.6, 0.7, 0.8
				elseif f.FC == "4" then -- Storyteller
					r, g, b = 0.9, 0.8, 0.7
				end	
			end
			if f.CU and f.CU ~= "" then
				gtabl()
				gtal( format( "|cffFFD304" .. L["CU"] .. ":|r %s", mrp.DisplayTooltip.CU( f.CU ) ), 0.6, 0.7, 0.9, true )
				-- Unfortunately, word wrap seems to cause serious problems... (Possibly fixed 8.0, so we'll enable it now to support TRP3/XRP. -Katorie)
			end
			if (f.CO and f.CO ~= "" and mrpSaved.Options.ShowOOC and mrpSaved.Options.ShowOOC == true) then -- Add OOC line to MRP to support TRP profiles.
				gtabl()
				gtal( format( "|cffFFD304" .. L["COabb"] .. ":|r %s", mrp.DisplayTooltip.CO( f.CO ) ), 0.6, 0.7, 0.9, true )
			end
			if n or t then
				n = n or " "
				t = t or " "
				gtabl()
				gtadl( n, t, r, g, b, r, g, b )
			end
			
			if mspsupported then -- Add a new line to the tooltip to show version info.
				if (mrpSaved.Options.ShowVersion and mrpSaved.Options.ShowVersion == true) then -- Show version and target.
					gtabl()
					local iconStringTable = {};
					local iconString
					if(f.RS and (f.RS == "2" or f.RS == "3")) then
						table.insert(iconStringTable, "|TInterface\\ICONS\\INV_ValentinesBoxOfChocolates02:17:17:0:-2|t")
					end
					if(mrpNotes[realm:gsub(" ", ""):upper()] and mrpNotes[realm:gsub(" ", ""):upper()][name:upper()]) then
						table.insert(iconStringTable, "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:17:17:0:-2|t")
					end
					iconString = table.concat(iconStringTable, "");
					if((mrpNotes[realm:gsub(" ", ""):upper()] and mrpNotes[realm:gsub(" ", ""):upper()][name:upper()]) or (f.RS and (f.RS == "2" or f.RS == "3"))) then -- If they have a private note set show an icon in the tooltip.
						gtadl( format(L["%s"], iconString), format( "%s", mrp.DisplayTooltip.VA( f.VA ) ), r, g, b, 1, 0.82, 0.01 )
					else
						gtadl( format(L["%s"], " "), format( "%s", mrp.DisplayTooltip.VA( f.VA ) ), r, g, b, 1, 0.82, 0.01 )
					end
				end
			end
		else
			gtal( format( L["%s %s |r%s|cffffffff"], e, race, class), r, g, b, false )
		end

		if mrp.Debug or mrp.ShowGUID then
			gtabl()
			gtal( format( L["GUID: %s"], guid ), 0.4, 0.5, 0.6 )
		end

		if not inphase then
			gtabl()
			gtal( L["<Out of Phase>"], 0.5, 0.7, 0.7 )
		end

		if mrp.id[guid] then
			if mrp.id[guid][1] == (otherrealm and mrp.idrealm[otherrealm] or realm)..(GetLocale()=="enUS" and "-US" or "-EU") then
				gtabl()
				gtal( mrp.id[guid][2], 1.0, 0.7, 1.0 )
			end
		end

		if gm then -- a <GM>!
			gtabl()
			gtal( L["<Game Master>"], 0.0, 0.7, 1.0 )
		elseif dev then -- even rarer, a <DEV>!
			gtabl()
			gtal( L["<Blizzard Developer>"], 0.0, 0.7, 1.0 )
		end

		GameTooltip:Show()
	end

	return true
end

-- As found in GameTooltip.lua, but collapsed, and we want a bit more nuance.
function mrp:UnitColour(unit)
	if ( UnitPlayerControlled(unit) ) then
		if ( (strsub( UnitName(unit),1,4 )=="<GM>" ) ) then
			-- Woah, it's a <GM>!
			return 0.0, 0.7, 1.0
		elseif ( UnitCanAttack(unit, "player") ) then
			-- Hostile players are red
			if ( not UnitCanAttack("player", unit) ) then
				return 1.0, 1.0, 1.0
			else
				return FACTION_BAR_COLORS[2].r, FACTION_BAR_COLORS[2].g, FACTION_BAR_COLORS[2].b
			end
		elseif ( UnitCanAttack("player", unit) ) then
			-- Players we can attack but which are not hostile are yellow
			return FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b
		elseif ( IsReferAFriendLinked(unit) ) then
			return FACTION_BAR_COLORS[8].r, FACTION_BAR_COLORS[8].g, FACTION_BAR_COLORS[8].b
		elseif ( UnitIsInMyGuild(unit) ) then
			return FACTION_BAR_COLORS[7].r, FACTION_BAR_COLORS[7].g, FACTION_BAR_COLORS[7].b
		elseif ( UnitIsPVP(unit) ) then
			-- Players we can assist but are PvP flagged are green
			return FACTION_BAR_COLORS[6].r, FACTION_BAR_COLORS[6].g, FACTION_BAR_COLORS[6].b
		else
			-- All other players are blue (the usual state on the "blue" server)
			return 0.5, 0.5, 1.0
		end
	else
		local reaction = UnitReaction(unit, "player");
		if ( reaction ) then
			return FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b
		else
			return 1.0, 1.0, 1.0
		end
	end
end

function mrp_MSPTooltipCallback( player )
	if player == mrp.TTShown then
		mrp:UpdateTooltip( player )
	end
end