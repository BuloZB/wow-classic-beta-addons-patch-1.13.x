--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_ChangeLog.lua - Display patch notes after an update.
]]

local L = mrp.L

function mrp_FormatChangeLog()
	local changeLogText = {
		[1] = {
			["version"] = "1.12.0.1 (29 May 2019)",
			[1] = {
				["title"] =   "Thanks for testing MyRolePlay Classic! Enjoy!",
				["text"] =    "All features from live should be present, minus a couple that do not function in Vanilla, such as profile switching with gear change. (There is no gear swapper!)"
			},
		},
	}
	local changeLogConversionTable = {};
	local changeLogOutput = ""
	for i = 1, #changeLogText, 1 do
		changeLogConversionTable[i] = {};
		changeLogConversionTable[i]["version"] = "{h3:c}|cffFF7700v" .. changeLogText[i]["version"] .. "|r{/h3}\n"
		for l = 1, #changeLogText[i], 1 do
			changeLogConversionTable[i][l] = {}
			if(changeLogText[i][l]["title"] ~= "") then
				changeLogConversionTable[i][l]["title"] = "{h3}" .. changeLogText[i][l]["title"] .. "{/h3}\n"
			else
				changeLogConversionTable[i][l]["title"] = ""
			end
			if(changeLogText[i][l]["text"] ~= "") then
				changeLogConversionTable[i][l]["text"] = changeLogText[i][l]["text"] .. "\n\n"
			else
				changeLogConversionTable[i][l]["text"] = ""
			end
		end
	end
	for i = 1, #changeLogConversionTable, 1 do
		changeLogOutput = changeLogOutput .. changeLogConversionTable[i]["version"]
		for l = 1, #changeLogConversionTable[i], 1 do
			changeLogOutput = changeLogOutput .. changeLogConversionTable[i][l]["title"]
			changeLogOutput = changeLogOutput .. changeLogConversionTable[i][l]["text"]
		end
	end
	
	changeLogOutput = mrp:CreateURLLink(changeLogOutput);
	changeLogOutput = mrp:ConvertStringToHTML(changeLogOutput);
	MyRolePlayChangeLogHTMLFrame:SetText(changeLogOutput)
end
		

local f = CreateFrame("Frame", "MyRolePlayChangeLogFrame", UIParent, nil);

-- Setup the frame.
f:SetToplevel(true);
f:SetFrameStrata("MEDIUM");
f:SetMovable(true);
f:EnableMouse(true);
f:Hide();
f:ClearAllPoints();
f:SetSize(600, 400);
f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);


-- Set backdrop for the picker frame
f:SetBackdrop(
	{
		bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = {
			left = 4,
			right = 4,
			top = 4,
			bottom = 4
		}
	}
);
f:SetBackdropColor(0.0, 0.0, 0.0, 0.80);

-- Title text
f.title_label = f:CreateFontString();
f.title_label:ClearAllPoints();
f.title_label:SetSize(f:GetWidth(), 40);
f.title_label:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -5);
f.title_label:SetFontObject(GameFontNormalHuge3);
f.title_label:SetText("|cff9955DDMyRolePlay Patch Notes|r");
	
f.sf = CreateFrame( "ScrollFrame", "MyRolePlayChangeLogScrollFrame", f, "UIPanelScrollFrameTemplate" )
f.sf:SetPoint( "TOPLEFT", f.title_label, "BOTTOMLEFT", 12, -5 )
f.sf:SetPoint( "BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 7 )

f.sf:EnableMouse(true)
f.sf.scrollbarHideable = false

ScrollBar_AdjustAnchors( MyRolePlayChangeLogScrollFrameScrollBar, -1, -1, 1)
		
f.sf.html = CreateFrame("SimpleHTML", "MyRolePlayChangeLogHTMLFrame", f.sf)
f.sf.html:SetSize(f.sf:GetWidth()-4, f.sf:GetHeight())
f.sf.html:SetFrameStrata("HIGH")
f.sf.html:SetBackdropColor(0, 0, 0, 1)
f.sf.html:SetFontObject( "GameFontHighlight" )
f.sf.html:SetFontObject("p", GameFontHighlight); -- GameFontNormal is gold.
f.sf.html:SetFontObject("h1", GameFontNormalHuge3);
f.sf.html:SetFontObject("h2", GameFontNormalHuge);
f.sf.html:SetFontObject("h3", GameFontNormalLarge);
f.sf.html:SetTextColor("h1", 1, 1, 1);
f.sf.html:SetTextColor("h2", 1, 1, 1);
--f.sf.html:SetTextColor("h3", 1, 1, 1);
f.sf.html:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
	if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
		local linkName = link:match("^mrpweblink:(.+)");
		if(linkName) then 
			Show_Hyperlink_Box(linkName, linkName); 
		end
		return;
	end  	
end)
f.sf.html:SetScript("OnHyperlinkEnter", function(f, link, text, button, ...) 
	if(link:match("mrpweblink")) then
		local linkName = link:match("^mrpweblink:(.+)");
		if(linkName) then 
			GameTooltip:SetOwner( f, "ANCHOR_CURSOR" )
			GameTooltip:SetText( text:match("%[.-%]"), 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( linkName, 1.0, 0.8, 0.06)
			GameTooltip:Show()
		end
		return;
	end 
end)
f.sf.html:SetScript( "OnHyperlinkLeave", GameTooltip_Hide )
f.sf.html:SetHyperlinksEnabled(1)
		
f.sf:SetScrollChild( f.sf.html )

f.sf.html:SetScript( "OnUpdate", function(self, elapsed)
	ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
end	)

ScrollFrame_OnScrollRangeChanged(MyRolePlayChangeLogScrollFrame)

-- Close button
f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
f.close:SetScript("OnClick", function (self)
	MyRolePlayChangeLogFrame:Hide();
end )
