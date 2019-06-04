--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Utilities.lua - Basic utility functions used throughout the addon. Will be shifting commonly used ones to this over time.
]]

function mrp:WrapIconFilename(filename, width, height) -- Wrap the filename of an icon with the correct texture path.
	width = width or 16;
    height = height or 16;
	if(filename) then
		return string.format("|TInterface\\Icons\\%s:%i:%i|t", filename, width, height)
	end
	return ""
end

function mrp:ImportTRP3Profile() -- Import profiles and convert fields back to MSP from TRP3.
	local characterName = mrp:UnitNameWithRealm("player")
	local mrpConversionTable = {};
	if(TRP3_Characters[characterName]) then
		local profileID = TRP3_Characters[characterName]["profileID"]
		trpCharacter = TRP3_Profiles[profileID]["player"]
		-- Name
		mrpConversionTable["NA"] = string.format("%s %s %s", trpCharacter["characteristics"]["TI"] or "", trpCharacter["characteristics"]["FN"] or "", trpCharacter["characteristics"]["LN"] or "")
		-- Eyes
		mrpConversionTable["AE"] = trpCharacter["characteristics"]["EC"] or ""
		-- Relationship Status
		mrpConversionTable["RS"] = trpCharacter["characteristics"]["RS"] or 0
		-- Age
		mrpConversionTable["AG"] = trpCharacter["characteristics"]["AG"] or ""
		-- Full Title
		mrpConversionTable["NT"] = trpCharacter["characteristics"]["FT"] or ""
		-- Race
		mrpConversionTable["RA"] = trpCharacter["characteristics"]["RA"] or UnitRace("player")
		-- Class
		mrpConversionTable["RC"] = trpCharacter["characteristics"]["CL"] or UnitClass("player")
		-- Height
		mrpConversionTable["AH"] = trpCharacter["characteristics"]["HE"] or ""
		-- Weight
		mrpConversionTable["AW"] = trpCharacter["characteristics"]["WE"] or ""
		-- Icon
		mrpConversionTable["IC"] = trpCharacter["characteristics"]["IC"] or ""
		-- Currently
		mrpConversionTable["CU"] = trpCharacter["character"]["CU"] or ""
		-- OOC
		mrpConversionTable["CO"] = trpCharacter["character"]["CO"] or ""
		-- Description / History
		if(trpCharacter["about"]["TE"] == 1) then -- Template 1, dump everything into description tab.
			mrpConversionTable["DE"] = trpCharacter["about"]["T1"]["TX"] or ""
		elseif(trpCharacter["about"]["TE"] == 2) then -- Template 2, combine all the fields and dump them into Description
			local descripConcat = {}
			for i = 1, #trpCharacter["about"]["T2"], 1 do
				table.insert(descripConcat, trpCharacter["about"]["T2"][i]["TX"])
			end
			mrpConversionTable["DE"] = table.concat(descripConcat, "\n\n")
		elseif(trpCharacter["about"]["TE"] == 3) then -- Template 3, put separate histories into different sections.
			mrpConversionTable["DE"] = trpCharacter["about"]["T3"]["PH"]["TX"] or "" .. "\n\n" .. trpCharacter["about"]["T3"]["PS"]["TX"] or "" -- Combine Physical and Personality into Description since we only have one box.
			mrpConversionTable["HI"] = trpCharacter["about"]["T3"]["HI"]["TX"] or ""
		end
		-- Music
		mrpConversionTable["MU"] = trpCharacter["about"]["MU"] or ""
		-- Home
		mrpConversionTable["HH"] = trpCharacter["characteristics"]["RE"] or ""
		-- Birthplace
		mrpConversionTable["HB"] = trpCharacter["characteristics"]["BP"] or ""
		-- Character status
		mrpConversionTable["FC"] = trpCharacter["character"]["RP"] or 1
		-- Roleplaying Style
		mrpConversionTable["FR"] = trpCharacter["character"]["XP"] or 1
		-- Nickname / Motto / House (These are fields that must be added to TRP)
		for i = 1, #trpCharacter["characteristics"]["MI"], 1 do
			if(trpCharacter["characteristics"]["MI"][i]["NA"] == "Motto") then
				mrpConversionTable["MO"] = trpCharacter["characteristics"]["MI"][i]["VA"] or ""
			elseif(trpCharacter["characteristics"]["MI"][i]["NA"] == "Nickname") then
				mrpConversionTable["NI"] = trpCharacter["characteristics"]["MI"][i]["VA"] or ""
			elseif(trpCharacter["characteristics"]["MI"][i]["NA"] == "House name") then
				mrpConversionTable["NH"] = trpCharacter["characteristics"]["MI"][i]["VA"] or ""
			end
		end
		
		-- Traits
		local traitsConversionTable = {};
		for i = 1, #trpCharacter["characteristics"]["PS"], 1 do
			local traitString = ""
			if(trpCharacter["characteristics"]["PS"][i]["ID"] ~= nil) then -- Trait with ID (default)
				traitString = string.format("[trait value=\"%.2f\" id=\"%i\"]", ((trpCharacter["characteristics"]["PS"][i]["V2"] * 5) / 100), trpCharacter["characteristics"]["PS"][i]["ID"])
			else -- Custom trait
				local lc = trpCharacter["characteristics"]["PS"][i]["LC"]
				local rc = trpCharacter["characteristics"]["PS"][i]["RC"]
				local rgbColourL = CreateColor(lc.r, lc.g, lc.b, 1)
				local rgbColourR = CreateColor(rc.r, rc.g, rc.b, 1)
				hexcodeL = rgbColourL:GenerateHexColorMarkup()
				hexcodeR = rgbColourR:GenerateHexColorMarkup()
				hexcodeL = hexcodeL:match("|cff(%x%x%x%x%x%x)")
				hexcodeR = hexcodeR:match("|cff(%x%x%x%x%x%x)")
				traitString = string.format("[trait value=\"%.2f\" left-name=\"%s\" left-icon=\"%s\" left-color=\"%s\" right-name=\"%s\" right-icon=\"%s\" right-color=\"%s\"]", ((trpCharacter["characteristics"]["PS"][i]["V2"] * 5) / 100), trpCharacter["characteristics"]["PS"][i]["LT"], trpCharacter["characteristics"]["PS"][i]["LI"], hexcodeL, trpCharacter["characteristics"]["PS"][i]["RT"], trpCharacter["characteristics"]["PS"][i]["RI"], hexcodeR)
			end
			table.insert(traitsConversionTable, traitString)
		end
		mrpConversionTable["PS"] = table.concat(traitsConversionTable, "\n")
		
		-- Glances
		mrpConversionTable["glances"] = {};
		local iteration = 1
		for k, v in pairs(trpCharacter["misc"]["PE"]) do
			if(v["TI"] ~= nil and v["TI"] ~= "") then
				mrpConversionTable["glances"][iteration] = {}
				mrpConversionTable["glances"][iteration]["Icon"] = "Interface\\Icons\\" .. v["IC"]
				mrpConversionTable["glances"][iteration]["Title"] = v["TI"]
				mrpConversionTable["glances"][iteration]["Description"] = v["TX"]
				iteration = (iteration + 1)
			end
		end
		
		if type(mrpSaved.Profiles["TRP3_Copy"]) ~= "table" then
			mrpSaved.Profiles["TRP3_Copy"] = { }
		end
		
		mrp:SetCurrentProfile("TRP3_Copy")
		mrp:UpdateCFProfileScrollFrame()
		
		for k, v in pairs(mrpConversionTable) do
			if(k ~= "glances") then
				mrp:SaveField(k, v)
			end
		end
		mrpSaved.Profiles["TRP3_Copy"]["glances"] = mrpConversionTable["glances"]
		
		-- Setup MSP readable glances
		local profile = mrpSaved.SelectedProfile
		local glanceMSP = ""
		local checkTitle
		local first = true
		for i = 1, #mrpSaved.Profiles[profile]["glances"], 1 do
			checkTitle = string.trim(mrpSaved.Profiles[profile]["glances"][i]["Title"])
			if(checkTitle ~= "" and checkTitle ~= nil) then
				if(first == true) then
					glanceMSP = "|T" .. mrpSaved.Profiles[profile]["glances"][i]["Icon"] .. ":32:32|t\n#" .. mrpSaved.Profiles[profile]["glances"][i]["Title"] .. "\n\n" .. mrpSaved.Profiles[profile]["glances"][i]["Description"]
					first = false
				else
					glanceMSP = glanceMSP .. "\n\n---\n\n" .. "|T" .. mrpSaved.Profiles[profile]["glances"][i]["Icon"] .. ":32:32|t\n#" .. mrpSaved.Profiles[profile]["glances"][i]["Title"] .. "\n\n" .. mrpSaved.Profiles[profile]["glances"][i]["Description"]
				end
			end
		end
		glanceMSP = glanceMSP:gsub("|TINTERFACE\\ICONS\\", "|TInterface\\Icons\\")
		mrp:SaveField('PE', glanceMSP)
		
		mrp:UpdateCharacterFrame()
		
		StaticPopupDialogs["MRP_IMPORT_RELOAD"].text = "|cff9944DDMyRolePlay|r\n\nImport complete. It is recommended that you |cff00ffb3reload|r. Reloading will also disable |cff00ffb3TotalRP3|r, allowing you to use MyRolePlay normally again."
		C_Timer.After(0.25, function() StaticPopup_Show("MRP_IMPORT_RELOAD") end) -- Timer on second popup since the import completes so fast the first one can't disappear in time, pushing down the second.
	end
end

function mrp:ImportXRPProfile() -- Import profiles from XRP. (There probably won't be XRP in classic, but we'll leave the function anyway)
	local mspFields = { "AE", "AH", "AG", "AW", "CU", "CO", "DE", "HB", "HH", "HI", "IC", "MO", "NA", "NI", "NH", "NT", "RA", "RC", "PE", "RS", "MU", "PS", "glances"}
	local numProfiles = 0
	for k, v in pairs(xrpSaved["profiles"]) do -- Loop through every saved xrp profile for this character.
		if type(mrpSaved.Profiles["XRP-" .. k]) ~= "table" and not k:match("MRP") then -- Safety net, don't overwrite profiles we already grabbed. We avoid profiles with MRP in the name because XRP tries to do the same thing and we get stuck in a loop.
			numProfiles = numProfiles + 1
			mrpSaved.Profiles["XRP-" .. k] = {}
			mrp:SetCurrentProfile("XRP-" .. k)
			mrp:UpdateCFProfileScrollFrame()
			for j, l in pairs(xrpSaved["profiles"][k]["fields"]) do -- Loop through the XRP fields and save as MRP fields.
				mrp:SaveField(j, l)
			end
			if(xrpSaved["profiles"][k]["fields"]["PE"]) then -- Deal with glances.
				local data = xrpSaved["profiles"][k]["fields"]["PE"] .. "\n\n---\n\n";
				local icon, title, text;
	
				local glances = {};
	
				for icon, title, text in string.gmatch(data, "|T[^\n]+\\([^|:]+).-[\n]*#([^\n]+)[\n]*(.-)[\n]*%-%-%-[\n]*") do
					table.insert(glances, {icon, title, text});
				end
				mrpSaved.Profiles["XRP-" .. k]["glances"] = {};
				for i = 1, #glances, 1 do
					mrpSaved.Profiles["XRP-" .. k]["glances"][i] = {}
					mrpSaved.Profiles["XRP-" .. k]["glances"][i]["Icon"] = "Interface\\Icons\\" .. glances[i][1]
					mrpSaved.Profiles["XRP-" .. k]["glances"][i]["Title"] = glances[i][2]
					mrpSaved.Profiles["XRP-" .. k]["glances"][i]["Description"] = glances[i][3]
				end
			end
			for i = 1, #mspFields, 1 do
				if not(mrpSaved.Profiles["XRP-" .. k][mspFields[i]]) then -- Set any field that didn't copy over to blank because we don't want to inherit for imported profiles.
					mrp:SaveField(mspFields[i], "")
				end
			end
		end
	end
	-- Copy over notes.
	local notesName, notesRealm
	local numNotes = 0
	for k, v in pairs(xrpAccountSaved["notes"]) do
		notesName, notesRealm = string.match(k, "^([^-]+)%-?([%S]*)$");
		notesName = string.upper(notesName)
		notesRealm = string.upper(notesRealm)
		if not(mrpNotes[notesRealm]) then
			mrpNotes[notesRealm] = {}
		end
		if(mrpNotes[notesRealm][notesName] == nil or mrpNotes[notesRealm][notesName] == "") then
			mrpNotes[notesRealm][notesName] = v
			numNotes = numNotes + 1
		end
	end
	mrp:UpdateCharacterFrame()
	StaticPopupDialogs["MRP_IMPORT_RELOAD"].text = "|cff9944DDMyRolePlay|r\n\nImport complete. It is recommended that you |cff00ffb3reload|r. Reloading will also disable |cff00ffb3XRP|r, allowing you to use MyRolePlay normally again.\n\n|cff00ffb3" .. numProfiles .. "|r profiles and |cff00ffb3" .. numNotes .. " |rprivate notes were copied."
	C_Timer.After(0.25, function() StaticPopup_Show("MRP_IMPORT_RELOAD") end) -- Timer on second popup since the import completes so fast the first one can't disappear in time, pushing down the second.
end

-- Return an texture text tag based on the given icon url and size. Nil safe.
function mrp:ReturnTextureTag(iconPath, iconSize)
	iconPath = iconPath or "INV_MISC_QUESTIONMARK";
	iconSize = iconSize or 15;
	return "|T" .. iconPath .. ":" .. iconSize .. ":" .. iconSize .. "|t"
end



--- IMAGE_PATTERN is the string pattern used for performing image replacements
--  in strings that should be rendered as HTML.
---
--- The accepted form this is "{img:<src>:<width>:<height>[:align]}".
---
--- Each individual segment matches up to the next present colon. The third
--- match (height) and everything thereafter needs to check up-to the next
--- colon -or- ending bracket since they could be the final segment.
---
--- Optional segments should of course have the "?" modifer attached to
--- their preceeding colon, and should use * for the content match rather
--- than +.
local IMAGE_PATTERN = [[{img%:([^:]+)%:([^:]+)%:([^:}]+)%:?([^:}]*)%}]];

--- Note that the image tag has to be outside a <P> tag.
local IMAGE_TAG = [[</P><img src="%s" width="%s" height="%s" align="%s"/><P>]];


-- This pattern matches all individual characters to replace. Each character
-- with a key in HTML_ESCAPE_REPLACEMENTS should be present here.
local HTML_ESCAPE_PATTERN = "[&<>\"]"

-- Table of replacements for characters to their HTML escaped equivalents.
local HTML_ESCAPE_REPLACEMENTS = {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["\""] = "&quot;",
}

-- Convert alignment in tags to HTML friendly variant.
local alignmentTagConversion = {
	["c"] = "center",
	["l"] = "left",
	["r"] = "right",
};

-- Extract header # and alignment from tag and convert to HTML friendly format.
local tagToHTML = {
	-- Headers
	["{h(%d)}"] = "<h%1>",
	["{h(%d):c}"] = "<h%1 align=\"center\">",
	["{h(%d):r}"] = "<h%1 align=\"right\">",
	["{/h(%d)}"] = "</h%1>",
	-- Paragraphs
	["{p}"] = "<P>",
	["{p:c}"] = "<P align=\"center\">",
	["{p:r}"] = "<P align=\"right\">",
	["{/p}"] = "</P>",
};

function mrp:ConvertStringToHTML(text) -- Somewhat based on Ellypse's design, with help from Meorawr, with some modifications. Thanks guys. The verbose comments are for me to look back on later.
	-- First, escape naughty characters thats players may input into the box.
	text = string.gsub(text, HTML_ESCAPE_PATTERN, HTML_ESCAPE_REPLACEMENTS);
	
	-- Replace tags with HTML throughout the entire text. {h1:c} to <h1 align="center"> for example.
	for pattern, replacement in pairs(tagToHTML) do
		text = text:gsub(pattern, replacement);
	end

	local chunks = {}; -- Contains broken up segments of the profile, each key is a pair of tags and the text within them. It also contains areas between tags that aren't wrapped in tags, that we'll need to place tags around later.
	
	local i = 1;
	
	while text:find("<") and i < 500 do -- Loop through entire text up to 500 times and find each "<".
		local textBeforeFirstTag;
		textBeforeFirstTag = text:sub(1, text:find("<") - 1); -- textBeforeFirstTag will always be everything before the first "<" found, after bits are cut off of the beginning with each pass.
		if(#textBeforeFirstTag > 0) then
			table.insert(chunks, textBeforeFirstTag) -- Drop everything before the first "<" on this pass into the chunks table.
		end
		
		local fullTagString; -- This will contain entire lines wrapped in tags, including the tags themselves.
		
		local endTag = text:match("</(.-)>"); -- Look for next end tag and set this variable to it.
		
		if(endTag) then -- If there is an end tag..
			fullTagString = text:sub( text:find("<"), text:find("</") + #endTag + 2); -- Set fullTagString to text wrapped in tags, including tags themselves. 2 accounts for the / and the >.
			if(fullTagString == #endTag + 3) then -- If number of the full string is equal to the entire end tag, bail. I guess something went wrong.
				return
			end
			tinsert(chunks, fullTagString) -- Insert the text wrapped in tags into the chunks table.
		else
			return -- If no more end tags, return?
		end
		
		local remainingText; -- Remaining text will be what's left after we chop off what was before the tagged text, and the tagged text itself.
		remainingText = text:sub(#textBeforeFirstTag + #fullTagString + 1) -- Take only what's left after what we've already dealt with.
		text = remainingText;
		
		i = (i + 1);
	end
	
	if(#text > 0) then
		table.insert(chunks, text); -- Whatevers left must not be in any tags, near the end of the text. Stuff it into the chunks table.
	end
	
	local finalText = "";
	for _, chunk in pairs(chunks) do -- For every chunk we saved above do..
		if not chunk:find("<") then -- If a line doesn't have tags around it, it's invalid in the HTML frame. We put <P> tags around it so it's readable.
			chunk = "<P>" .. chunk .. "</P>";
		end
		chunk = chunk:gsub("\n", "<br/>"); -- Replace newlines with proper HTML line breaks.
		-- TRP IMAGE SUPPORT --
		-- Since we're using TRP's tag style here, we'll work with what they've got setup as a standard for now, unless we come up with something better later as a team.
		chunk = chunk:gsub(IMAGE_PATTERN, function(image, width, height, alignment) -- It looks like we're testing this pattern on the chunk to see if it's an image.
			-- If no alignment is provided or invalid, "center" will be returned.
			alignment = alignmentTagConversion[alignment] or "center";
			
			-- Prevent catastrophic meltdown by assigning 128 as width and height if these values come in non-numeric.
			width = tonumber(width) or 128;
			height = tonumber(height) or 128;
			
			-- Apparently negative inputs here cause issues, so we math.abs them to prevent that.
			return string.format(IMAGE_TAG, image, math.abs(width), math.abs(height), alignment);
		end);
		
		chunk = chunk:gsub("%!%[(.-)%]%((.-)%)", function(icon, size)
			if(icon:find("\\")) then -- "\\ means we found an icon path."
				local width, height;
				if size:find("%,") then
					width, height = strsplit(",", size);
				else
					width = tonumber(size) or 128;
					height = width;
				end
				-- Again, width and height must be absolute to prevent catastrophic meltdown.
				return string.format(IMAGE_TAG, icon, math.abs(width), math.abs(height), "center");
			end
			return mrp:ReturnTextureTag(icon, tonumber(size) or 25);
		end);
		
		chunk = chunk:gsub("%[(.-)%]%((.-)%)",
			"<a href=\"%2\">[%1]|r</a>");
		
		chunk = chunk:gsub("{link%*(.-)%*(.-)}",
			"<a href=\"%1\">[%2]|r</a>");

		finalText = finalText .. chunk; -- Finished text, add chunk to end of it.
	end
	
	return "<HTML><BODY>" .. finalText .. "</BODY></HTML>"; -- Wrap the entire text in <HTML> and <BODY> tags so the whole bloody thing works.
end