--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Author of this module:
	Linxel-WyrmrestAccord / Linxyl-MoonGuard
	
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_IconSelector.lua - Icon selection frame, and support functions. Uses TRP's icon database for compatibility with permission.


Usage:
	mrp_iconselector_show(callback_func, [current_icon] or nil)
		callback_func: should be a function that accepts 1 argument,
			which is nil if "clear icon" is pressed, or the
			selected texture if okay is pressed.
		current_icon:
			if the user already set an icon, pass this to the
			function to scroll the list to where the already
			selected icon is.
	mrp_iconselector_hide();
		will reset and hide the icon picker.


License:
	GNU General Public Licence version 2 or later.


TODO:
	Add localization for Clear/Cancel/Okay buttons.
	Figure out what is happening with pcall and SetPortraitToTexture
	Stop using fauxscrollframe stuff, replace it with a Slider.
	Add a search feature.
]]

local L = mrp.L

-- Imports
local tinsert = table.insert;
local pcall = pcall;
local type = type;
local pairs = pairs;
local CreateFrame = CreateFrame;
local FSF_GetOffset = FauxScrollFrame_GetOffset;
local FSF_Update = FauxScrollFrame_Update;
local FSF_OnVerticalScroll = FauxScrollFrame_OnVerticalScroll;


-- Constants
local NUM_COLUMNS = 10;
local NUM_ROWS = 9;
local NUM_ICONS = (NUM_COLUMNS * NUM_ROWS);

local ICON_SIZE = 36;
local ICON_PADDING = 4;

local TEXTURE_PATH = "INTERFACE\\ICONS\\";
local EMPTY_TEXTURE = TEXTURE_PATH .. "INV_MISC_QUESTIONMARK";

local BTN_IDOKAY = 1;
local BTN_IDCANCEL = 2;
local BTN_IDCLEAR = 3;

local TXT_OKAY = OKAY;
local TXT_CANCEL = CANCEL;
local TXT_CLEAR = L["editor_clearicon"];


-- Variables
local frame = nil;
filenames = { };
local filenames_count = 0;
local savedMaxSliderSize = 9432
local tooltipTable = {};


local init_filenames = function(refresh)
	if(filenames_count > 0 and not refresh) then return; end;

	filenames = { "INV_MISC_QUESTIONMARK" };

	-- TRP does not support fileid type icons, so we can't use blizzard's import functions yet.
	--[[
	GetLooseMacroIcons(filenames);
	GetLooseMacroItemIcons(filenames);
	GetMacroIcons(filenames);
	GetMacroItemIcons(filenames);
	]]

	-- Fix up the list, fileid will be "number" type
	for k,v in pairs(filenames) do
		local num = tonumber(v);
		if(num) then
			filenames[k] = num;
		else
			filenames[k] = TEXTURE_PATH .. v;
		end
	end

	-- Import icons from TRP
	for k,v in pairs(g_trp_icon_list_data) do
		tinsert(filenames, TEXTURE_PATH .. v);
	end

	-- Free the import list.
	--g_trp_icon_list_data = nil;

	-- Save icon count.
	filenames_count = #filenames;
end


local scroll_update = function(this)
	local offset = FSF_GetOffset(this.scrollframe);
	local index = 0;
	local texture = nil;
	local button = nil;
	
	table.wipe(tooltipTable)

	for i = 1, NUM_ICONS, 1 do
		index = (offset * NUM_COLUMNS) + i;
		texture = filenames[index];
		button = this.icon_buttons[i];

		if((index <= filenames_count) and texture) then
			button:SetNormalTexture(texture);
			button:Show();
			button:SetScript( "OnEnter", function(self) 
				GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
				GameTooltip:SetText( tooltipTable[i], 0.97, 0.80, 0.05 )
				GameTooltip:Show()
			end )
			button:SetScript( "OnLeave", GameTooltip_Hide )
		else
			button:SetNormalTexture(EMPTY_TEXTURE);
			button:Hide();
		end
		
		if(texture ~= nil) then
			table.insert(tooltipTable, texture:match("INTERFACE\\ICONS\\(.+)"))
		end

		if((this.selected_icon == index) or (this.selected_icon_texture == texture)) then
			button:SetChecked(true);
		else
			button:SetChecked(false);
		end
	end


	FSF_Update(this.scrollframe, math.ceil(filenames_count / NUM_COLUMNS) + 1, NUM_ROWS, ICON_SIZE);
end

local onscroll = function(this)
	scroll_update(this:GetParent());
end

local setchoice = function(this, index)
	local texture = filenames[index];

	this.texture_show_selected:SetTexture(texture);
	pcall(SetPortraitToTexture, this.texture_show_selected_portrait, texture);

	this.selected_icon = index;
	this.selected_icon_texture = texture;

	scroll_update(this);
end

local iconbutton_onclick = function(this)
	local parent = this:GetParent();
	local scrollframe = parent.scrollframe;
	local icon_index = this:GetID() + (FSF_GetOffset(scrollframe) * NUM_COLUMNS);

	setchoice(parent, icon_index);
end

local function search_update()

	if(MRPIconSelect.search_box:HasFocus() == false) then
		return;
	end
	
	filenames = { "INV_MISC_QUESTIONMARK" };
	
	local searchBoxContents = search_box:GetText():upper()

	-- Fix up the list, fileid will be "number" type
	for k,v in pairs(filenames) do
		local num = tonumber(v);
		if(num) then
			filenames[k] = num;
		else
			filenames[k] = TEXTURE_PATH .. v;
		end
	end

	-- Import icons from TRP
	for k,v in pairs(g_trp_icon_list_data) do
		--if(v:upper():match(searchBoxContents)) then
		if(v:upper():find(searchBoxContents, 1, true)) then
			tinsert(filenames, TEXTURE_PATH .. v);
		end
	end

	-- Save icon count.
	filenames_count = #filenames;
	
	MRPIconSelect.search_count_label:SetText(#filenames .. L["editor_matches"]);
	
	FSF_Update(MRPIconSelect.scrollframe, math.ceil(filenames_count / NUM_COLUMNS) + 1, NUM_ROWS, ICON_SIZE);

	FSF_OnVerticalScroll(MRPIconSelect.scrollframe, 1, ICON_SIZE, onscroll);
	
end

local choice_onclick = function(this)
	local choice = this:GetID();
	local parent = this:GetParent();
	
	if(choice == BTN_IDOKAY) then
		if(type(parent.callback) == "function") then
			if(type(parent.selected_icon_texture) == "string") then
				-- strip the path from the filename
				pcall(parent.callback, string.match(parent.selected_icon_texture, TEXTURE_PATH .. "(.-)$"));
			else
				-- not a string, should be a numerical fileid
				pcall(parent.callback, parent.selected_icon_texture);
			end
		end
	elseif(choice == BTN_IDCLEAR) then
		if(type(parent.callback) == "function") then
			pcall(parent.callback, nil);
		end
	end
	
	parent:Hide();
end

local function Reset_Searchbox_Text()
	MRPIconSelect.search_box:SetText("")
end

local create = function()
	local f = CreateFrame("Frame", "MRPIconSelect", UIParent, nil);


	-- Set inital member variables
	f.selected_icon = 1;
	f.selected_icon_texture = EMPTY_TEXTURE;
	f.callback = nil;


	-- Setup the frame.
	f:SetToplevel(true);
	f:SetFrameStrata("DIALOG");
	f:SetMovable(true);
	f:EnableMouse(true);
	f:Hide();
	f:ClearAllPoints();
	f:SetSize(((ICON_SIZE + ICON_PADDING) * NUM_COLUMNS) + 48, ((ICON_SIZE + ICON_PADDING) * NUM_ROWS) + 128 + 16);
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

	
	
	-- texture to show selected icon
	f.texture_show_selected = f:CreateTexture();
	f.texture_show_selected:ClearAllPoints();
	f.texture_show_selected:SetSize(96, 96);
	f.texture_show_selected:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 8);
	f.texture_show_selected:SetTexture(EMPTY_TEXTURE);

	-- with a label
	f.texture_show_selected_label = f:CreateFontString();
	f.texture_show_selected_label:ClearAllPoints();
	f.texture_show_selected_label:SetSize(96, 16);
	f.texture_show_selected_label:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 8, 108);
	f.texture_show_selected_label:SetFontObject(GameFontNormal);
	f.texture_show_selected_label:SetText("Tooltip:");


	-- texture to show selected icon... as a portrait!
	f.texture_show_selected_portrait = f:CreateTexture();
	f.texture_show_selected_portrait:ClearAllPoints();
	f.texture_show_selected_portrait:SetSize(74, 74);
	f.texture_show_selected_portrait:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 122, 26);
	f.texture_show_selected_portrait:SetTexture(EMPTY_TEXTURE);

	-- with the portrait overlay
	f.texture_show_selected_portrait_overlay = f:CreateTexture(nil, "OVERLAY");
	f.texture_show_selected_portrait_overlay:ClearAllPoints();
	f.texture_show_selected_portrait_overlay:SetSize(96, 96);
	f.texture_show_selected_portrait_overlay:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 112, 8);
	f.texture_show_selected_portrait_overlay:SetAtlas("UI-Frame-Portrait");

	-- and a label
	f.texture_show_selected_portrait_label = f:CreateFontString();
	f.texture_show_selected_portrait_label:ClearAllPoints();
	f.texture_show_selected_portrait_label:SetSize(96, 16);
	f.texture_show_selected_portrait_label:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 112, 108);
	f.texture_show_selected_portrait_label:SetFontObject(GameFontNormal);
	f.texture_show_selected_portrait_label:SetText("Portrait:");


	-- scroll frame
	f.scrollframe = CreateFrame("ScrollFrame", nil, f, "FauxScrollFrameTemplate");
	f.scrollframe:ClearAllPoints();
	f.scrollframe:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8);
	f.scrollframe:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 8);
	f.scrollframe:SetScript("OnVerticalScroll", function(this, offset) FSF_OnVerticalScroll(this, offset, ICON_SIZE, onscroll); end);


	-- Ok button
	f.okay_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
	f.okay_button:SetID(BTN_IDOKAY);
	f.okay_button:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 8);
	f.okay_button:SetSize(128, 29);
	f.okay_button:SetText(TXT_OKAY);
	f.okay_button:SetScript("OnClick", choice_onclick);

	-- Cancel Button
	f.cancel_button = CreateFrame("Button", nil, f, "UIPanelButtonTemplate");
	f.cancel_button:SetID(BTN_IDCANCEL);
	f.cancel_button:SetPoint("BOTTOM", f.okay_button, "TOP", 0, -2);
	f.cancel_button:SetSize(128, 29);
	f.cancel_button:SetText(TXT_CANCEL);
	f.cancel_button:SetScript("OnClick", choice_onclick);

	-- Clear Button
	f.clear_button = CreateFrame("Button", "MRPIconSelect_ClearIconButton", f, "UIPanelButtonTemplate");
	f.clear_button:SetID(BTN_IDCLEAR);
	f.clear_button:SetPoint("BOTTOM", f.cancel_button, "TOP", 0, -2);
	f.clear_button:SetSize(128, 29);
	f.clear_button:SetText(TXT_CLEAR);
	f.clear_button:SetScript("OnClick", choice_onclick);
	
	-- Search box
	f.search_box = CreateFrame( "EditBox", "search_box", f )
	f.search_box:SetBackdrop(	{
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 12,
			insets = { left = 5, right = 3, top = 3, bottom = 3	},
	} )
	f.search_box_label = f:CreateFontString();
	f.search_box_label:ClearAllPoints();
	f.search_box_label:SetSize(96, 16);
	f.search_box_label:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 210, 107);
	f.search_box_label:SetFontObject(GameFontNormal);
	f.search_box_label:SetText(L["editor_search"]);
	f.search_box:SetPoint( "LEFT", f.search_box_label, "RIGHT", -16, 0 )
	f.search_box:SetHeight( 25 )
	f.search_box:SetWidth( 128 )
	f.search_box:SetTextInsets( 7, 7, 0, 0 )
	f.search_box:EnableMouse(true)
	f.search_box:SetAutoFocus(false)
	f.search_box:SetMultiLine(false)
	f.search_box:SetFontObject( "GameFontHighlight" )
	f.search_box:SetScript("OnTextChanged", search_update)

	f.search_box:SetScript( "OnEscapePressed", EditBox_ClearFocus )
	
	-- Search count label
	f.search_count_label = f:CreateFontString();
	f.search_count_label:ClearAllPoints();
	f.search_count_label:SetSize(150, 16);
	f.search_count_label:SetPoint("TOPLEFT", f.search_box, "BOTTOMLEFT", -10, 2);
	f.search_count_label:SetFontObject(GameFontNormal);


	-- Setup script handlers
	f:SetScript("OnShow", function(this) scroll_update(this); end);
	f:SetScript("OnHide", function(this) this.callback = nil; Reset_Searchbox_Text(); MRPIconSelect_ClearIconButton:Show(); end);



	-- Set up all the icon buttons.
	f.icon_buttons = { };

	local n_frame = nil;
	local x = 0;
	local y = 0;

	for i = 1, NUM_ICONS, 1 do
		x = (16 + (((i - 1) % NUM_COLUMNS) * (ICON_SIZE + ICON_PADDING)));
		y = (16 + ((math.floor((i - 1) / NUM_COLUMNS)) * (ICON_SIZE + ICON_PADDING))) * -1;
		n_frame = CreateFrame("CheckButton", nil, f, "SimplePopupButtonTemplate");
		n_frame:SetSize(ICON_SIZE, ICON_SIZE);
		n_frame:SetScript("OnClick", iconbutton_onclick);
		n_frame:SetNormalTexture(EMPTY_TEXTURE);
		n_frame:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD");
		n_frame:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD");
		n_frame:SetID(i);
		n_frame:SetPoint("TOPLEFT", f, "TOPLEFT", x, y);
		tinsert(f.icon_buttons, n_frame);
	end


	-- Select the first button on creation.
	iconbutton_onclick(f.icon_buttons[1]);

	return f;
end

local init = function()
	init_filenames();
	frame = create();
end

local show = function(callback, current_icon)
	init_filenames(true)
	MRPIconSelect.search_count_label:SetText(#filenames .. L["editor_matches"]);
	if(current_icon) then
		current_icon = current_icon:gsub("Interface\\Icons", "INTERFACE\\ICONS")
	end
	if(type(callback) ~= "function") then
		error("mrp_iconselector_show: Usage: mrp_iconselector_show(callback_function, [current_icon]);");
		return;
	end

	local icon_found = false;

	if(type(current_icon) ~= "nil") then
		-- check that it is not a fileid
		if(type(current_icon) == "string") then
			-- if there is not a path attached, add it.
			if(not string.match(current_icon, TEXTURE_PATH)) then
				current_icon = TEXTURE_PATH .. current_icon;
			end
		end
		
		
		for k,v in pairs(filenames) do
			if(current_icon == v) then
				--local sel_icon_offset = (k / filenames_count);
				local sel_icon_offset = math.floor(k / 10) / math.ceil(filenames_count / 10);
				local slider_min, slider_max = frame.scrollframe.ScrollBar:GetMinMaxValues();
				if(slider_max > savedMaxSliderSize) then
					savedMaxSliderSize = slider_max
				end
				local slider_offset = sel_icon_offset * savedMaxSliderSize;

				FSF_OnVerticalScroll(frame.scrollframe, slider_offset, ICON_SIZE, onscroll);
				setchoice(frame, k);
				icon_found = true;
				break;
			end
		end
	end

	if(icon_found == false) then
		setchoice(frame, 1);
		FSF_OnVerticalScroll(frame.scrollframe, 0, ICON_SIZE, onscroll);
	end
	
	frame.callback = callback;
	frame:Show();
end

local hide = function()
	frame:Hide();
end


-- Finish by initializing everything.
init();


-- global API exports
_G["mrp_iconselector_show"] = show;
_G["mrp_iconselector_hide"] = hide;
