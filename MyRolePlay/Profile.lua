--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Profile.lua - Profile management functions
]]

local wipe, format, strtrim = wipe, format, strtrim

local mspValidFields = { "AE", "AH", "AG", "AW", "CU", "CO", "DE", "FC", "FR", "GC", "GF", "GR", "GS", "GU", "HB", "HH", "HI", "IC", "MO", "NA", "NI", "NH", "NT", "RA", "RC", "TT", "VA", "VP", "PE", "RS", "TR", "MU", "PS"}

function mrp:AddToVAString( addon )
	if not select( 4, GetAddOnInfo( addon ) ) then return end
	msp.my['VA'] = strtrim( format( "%s;%s/%s%s", (msp.my['VA'] or ""), addon, 
		( GetAddOnMetadata( addon, "Version" ) or "" ), 
		(	(GetAddOnMetadata( addon, "X-Test" )=="Alpha" and "alpha") or 
			(GetAddOnMetadata( addon, "X-Test" )=="Beta" and "beta") or "" ) ), "; " )
end

-- Set the current profile, and update everything as necessary
function mrp:SetCurrentProfile( profile, isauto )
	profile = profile or mrpSaved.SelectedProfile or "Default"
	local playername = UnitName("player")

	-- Safety net in case the current profile no longer exists
	if type(mrpSaved.Profiles[profile]) ~= "table" then
		mrpSaved.SelectedProfile = "Default"
		if type(mrpSaved.Profiles[profile]) ~= "table" then
			return false
		end
	else
		mrpSaved.SelectedProfile = profile
	end

	wipe( msp.my )
	wipe( msp.char[ playername ].field )

	for field, value in pairs( mrpSaved.Profiles.Default ) do
		if tContains(mspValidFields, field) then
			msp.my[ field ] = value
		end
	end

	if profile ~= "Default" then
		for field, value in pairs( mrpSaved.Profiles[ profile ] ) do
			if tContains(mspValidFields, field) then
				msp.my[ field ] = value
			end
		end
	end

	-- Fields not set by the user
	msp.my['VP'] = tostring( msp.protocolversion )
	msp.my['VA'] = ""
	mrp:AddToVAString( "MyRolePlay" )
	mrp:AddToVAString( "Vernacular" )
	mrp:AddToVAString( "GHI" )
	mrp:AddToVAString( "Tongues" )

	msp.my['GU'] = UnitGUID("player")
	msp.my['GS'] = tostring( UnitSex("player") )
	msp.my['GC'] = select( 2, UnitClass("player") )
	msp.my['GR'] = select( 2, UnitRace("player") )
	-- Check if trial, set flag if so.
	if(IsTrialAccount() == true) then
		msp.my['TR'] = "1"
	elseif(IsVeteranTrialAccount() == true) then
		msp.my['TR'] = "2"
	else
		msp.my['TR'] = "0"
	end
	
	mrp:UpdateColour("NA") -- Colour
	mrp:UpdateColour("AE")
	mrp:UpdateColour("DE")
	mrp:UpdateColour("HI")

	msp:Update()

	for field, ver in pairs( msp.myver ) do
		mrpSaved.Versions[ field ] = ver
		msp.char[ playername ].ver[ field ] = ver
		msp.char[ playername ].field[ field ] = msp.my[ field ]
		msp.char[ playername ].time[ field ] = 999999999
	end

	msp.char[ playername ].supported = true

	mrp:UpdateCharacterFrame()
	
	if mrp.TTShown == playername then
		mrp:UpdateTooltip( playername )
	end

	if mrp.BFShown == playername then
		mrp:UpdateBrowseFrame( playername )
	end

	if not isauto then
		mrpSaved.PreviousProfileManual = profile
	end

	return true
end

-- Save a (possibly, but not NECESSARILY changed) field back to the current profile, and update stuff accordingly
function mrp:SaveField( field, newtext )
	-- Just in case we get stuck somehow
	local profile = mrpSaved.SelectedProfile
	if type(mrpSaved.Profiles[profile]) ~= "table" then
		return false
	end
	if newtext then 
		newtext = strtrim( newtext )
		if(field == "PE") then
			newtext = newtext:gsub("|n", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"):gsub("|K.-|k.-|k", ""):trim()
		else
			newtext = newtext:gsub("||", "|"):gsub("|n", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|H.-|h(.-)|h", "%1"):gsub("|T.-|t", ""):gsub("|K.-|k.-|k", ""):gsub("|", "||"):trim()
		end
		if(field == "DE" or field == "HI") then
			-- Swap tags to colour codes when saving.
			newtext = newtext:gsub("{col:(%x%x%x%x%x%x)}", "|cff%1")
			newtext = newtext:gsub("{/col}", "|r")
			newtext = newtext:gsub("{icon:(.-):(%d+)}", "|TInterface\\Icons\\%1:%2|t")
			-- Swap tags to links when saving.
			newtext = newtext:gsub("{link%*(.-)%*(.-)}", "[%2]( %1 )")
			-- Swap tags to headers for proper HTML when saving.
			--newtext = newtext:gsub("{h1}", "<h1>")
			--newtext = newtext:gsub("{/h1}", "</h1>")
		end
	end

	if mrpSaved.Profiles.Default[ field ] and mrpSaved.Profiles.Default[ field ] == newtext and field ~= "AE" then -- We need to always save AE now since we have possible colour differences.
		if mrpSaved.SelectedProfile ~= "Default" then
			mrpSaved.Profiles[ profile ][ field ] = nil -- if identical to what's in Default, then fall through to it
		end
	else
		mrpSaved.Profiles[ profile ][ field ] = newtext
	end

	mrp:SetCurrentProfile( )
end