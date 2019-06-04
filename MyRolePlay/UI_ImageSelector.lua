--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Author of this module:
	Linxel-WyrmrestAccord / Linxyl-MoonGuard / Katorie-MoonGuard
	
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_ImageSelector.lua - Image selection frame, and support functions. Uses TRP's image database for compatibility with permission.


Usage:
	mrp_imageselector_show(callback_func, [current_image] or nil)
		callback_func: should be a function that accepts 1 argument,
			which is nil if "clear icon" is pressed, or the
			selected texture if okay is pressed.
		current_image:
			if the user already set an icon, pass this to the
			function to scroll the list to where the already
			selected icon is.
	mrp_imageselector_hide();
		will reset and hide the icon picker.


License:
	GNU General Public Licence version 2 or later.
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
local currentTexture = {}


-- Constants

local ICON_SIZE = 200;
local ICON_PADDING = 4;

local EMPTY_TEXTURE = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Bling"

local BTN_IDOKAY = 1;
local BTN_IDCANCEL = 2;

local TXT_OKAY = OKAY;
local TXT_CANCEL = CANCEL;


-- Variables
local frame = nil;
imageFilenames = { };
local filenames_count = 0;


local init_filenames = function(refresh)
	if(filenames_count > 0 and not refresh) then return; end;

	imageFilenames = { };

	-- Import icons from TRP
	for k,v in pairs(g_trp_image_list_data) do
		tinsert(imageFilenames, v);
	end

	-- Save icon count.
	filenames_count = #imageFilenames;
end

local scroll_update = function(this)
	local offset = FSF_GetOffset(this.scrollframe);
	local index = 0;
	local texture = nil;
	local button = nil;
	index = offset + 1;
	if(imageFilenames[index]) then
		texture = imageFilenames[index]["url"];
	else
		return
	end
	button = this.icon_buttons[1];

	if((index <= filenames_count) and texture) then
		button:SetNormalTexture(texture);
		button:Show();
	else
		button:SetNormalTexture(EMPTY_TEXTURE);
		button:Hide();
	end

	if((this.selected_icon == index) or (this.selected_icon_texture == texture)) then
		button:SetChecked(true);
	else
		button:SetChecked(false);
	end
	
	currentTexture["name"] = imageFilenames[index]["url"]
	currentTexture["width"] = imageFilenames[index]["width"]
	currentTexture["height"] = imageFilenames[index]["height"]
	
	FSF_Update(this.scrollframe, math.ceil(filenames_count) + 1, 1, ICON_SIZE);
end

local onscroll = function(this)
	scroll_update(this:GetParent());
end

local function search_update()

	if(mrp_image_search_box:HasFocus() == false) then
		return;
	end
	
	imageFilenames = { };
	
	local searchBoxContents = mrp_image_search_box:GetText():upper()

	-- Import icons from TRP
	for k,v in pairs(g_trp_image_list_data) do
		--if(v:upper():match(searchBoxContents)) then
		if(v["url"]:upper():find(searchBoxContents, 1, true)) then
			tinsert(imageFilenames, v);
		end
	end

	-- Save icon count.
	filenames_count = #imageFilenames;
	
	MRPImageSelect.search_count_label:SetText(#imageFilenames .. L["editor_matches"]);
	
	FSF_Update(MRPImageSelect.scrollframe, math.ceil(filenames_count), 1, ICON_SIZE);

	FSF_OnVerticalScroll(MRPImageSelect.scrollframe, 1, ICON_SIZE, onscroll);
	
end

local choice_onclick = function(this)
	local choice = this:GetID();
	local parent = this:GetParent();
	
	if(choice == BTN_IDOKAY) then
		MyRolePlayMultiEditFrame_EditBox:Insert("{img:" .. currentTexture["name"] .. ":" .. currentTexture["width"] .. ":" .. currentTexture["height"] .. "}")
	end
	
	parent:Hide();
end

local function Reset_Searchbox_Text()
	MRPImageSelect.search_box:SetText("")
end

local create = function()
	local f = CreateFrame("Frame", "MRPImageSelect", UIParent, nil);


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
	f:SetSize(400, 450);
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
	f:SetBackdropColor(0.0, 0.0, 0.0, 1);
	
	f.bg = CreateFrame("Frame", nil, f, "InsetFrameTemplate")
    f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 3)
    f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 3, -3)

	-- scroll frame
	f.scrollframe = CreateFrame("ScrollFrame", "MRPImageSelectScrollFrame", f, "FauxScrollFrameTemplate");
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
	
	-- Search box
	f.search_box = CreateFrame( "EditBox", "mrp_image_search_box", f )
	f.search_box:SetBackdrop(	{
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 12,
			insets = { left = 5, right = 3, top = 3, bottom = 3	},
	} )
	f.search_box:SetPoint( "RIGHT", f.cancel_button, "LEFT", -5, 0 )
	f.search_box:SetHeight( 25 )
	f.search_box:SetWidth( 128 )
	f.search_box:SetTextInsets( 7, 7, 0, 0 )
	f.search_box:EnableMouse(true)
	f.search_box:SetAutoFocus(false)
	f.search_box:SetMultiLine(false)
	f.search_box:SetFontObject( "GameFontHighlight" )
	f.search_box:SetScript("OnTextChanged", search_update)

	f.search_box:SetScript( "OnEscapePressed", EditBox_ClearFocus )
	
	f.search_box_label = f.search_box:CreateFontString();
	f.search_box_label:SetSize(96, 16);
	f.search_box_label:SetPoint("BOTTOMLEFT", f.search_box, "TOPLEFT", -10, 0);
	f.search_box_label:SetFontObject(GameFontNormal);
	f.search_box_label:SetText(L["editor_search"]);
	
	-- Search count label
	f.search_count_label = f.search_box:CreateFontString();
	f.search_count_label:SetSize(150, 16);
	f.search_count_label:SetPoint("TOPLEFT", f.search_box, "BOTTOMLEFT", -10, 2);
	f.search_count_label:SetFontObject(GameFontNormal);


	-- Setup script handlers
	f:SetScript("OnShow", function(this) scroll_update(this); end);
	f:SetScript("OnHide", function(this) Reset_Searchbox_Text(); end);



	-- Set up all the icon buttons.
	f.icon_buttons = { };

	local n_frame = CreateFrame("CheckButton", nil, f);
	n_frame:SetSize(350, 350);
	n_frame:SetPoint("CENTER", f.scrollframe, "CENTER", -5, 30);
	tinsert(f.icon_buttons, n_frame);

	return f;
end

local init = function()
	init_filenames();
	frame = create();
end

local show = function(callback, current_icon)
	init_filenames(true)
	
	MRPImageSelect.search_count_label:SetText(#imageFilenames .. L["editor_matches"]);
	frame:Show();
end

local hide = function()
	frame:Hide();
end


-- Finish by initializing everything.
init();


-- global API exports
_G["mrp_imageselector_show"] = show;
_G["mrp_imageselector_hide"] = hide;
