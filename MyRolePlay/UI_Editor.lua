--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Editor.lua - MyRolePlayCharacterFrame (the profile editor)
]]

local L = mrp.L

local wipe = wipe

local function emptynil( x ) return x ~= "" and x or nil end

local uipbt = "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

local origCharacterNameTitle = UnitName("player")

local function getBestFieldValue(profile, field)
    return (mrpSaved.Profiles[profile][field] and strtrim(mrpSaved.Profiles[profile][field])) or (mrpSaved.Profiles["Default"][field] and strtrim(mrpSaved.Profiles["Default"][field]))
end

-- COLOURS

function mrp:UpdateColour(field) -- Called by mrp_EyeColourChangedCallback and in profile.lua when mrp:SetCurrentProfile runs.
    local profile = mrpSaved.SelectedProfile or "Default"
    local colourField
    if(field == "NA") then
        colourField = "nameColour"
    elseif(field == "AE") then
        colourField = "eyeColour"
    end
    local colourFieldArray = mrpSaved.Profiles[profile][colourField] or mrpSaved.Profiles["Default"][colourField]
    if colourFieldArray and (field == "NA" or getBestFieldValue(profile, field)) then
        local rgbColour = CreateColor(colourFieldArray["r"], colourFieldArray["g"], colourFieldArray["b"], 1)
        local hexcode = rgbColour:GenerateHexColorMarkup()
        if(MyRolePlayEditFrame and field ~= "DE" and field ~= "HI") then
            local currentText = MyRolePlayEditFrame.editbox:GetText()
            currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
            MyRolePlayEditFrame.editbox:SetText(hexcode .. currentText)
        end
		if(MyRolePlayMultiEditFrame and MyRolePlayMultiEditFrameScrollFrame and (field == "DE" or field == "HI")) then
            local currentText = MyRolePlayMultiEditFrameScrollFrame.editbox:GetText()
            currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
            MyRolePlayMultiEditFrameScrollFrame.editbox:SetText(hexcode .. currentText)
        end
        if(field == "NA") then
            msp.my[field] = hexcode .. (emptynil(getBestFieldValue(profile, field)) or UnitName("player"))
            if(msp.my["RC"] and emptynil(getBestFieldValue(profile, "RC"))) then
                msp.my["RC"] = hexcode .. getBestFieldValue(profile, "RC")
            end
        elseif(field == "AE") then
			msp.my[field] = hexcode .. getBestFieldValue(profile, field)
        end
    end
    
    mrp:UpdateCharacterFrame()
end

local r,g,b,a

function mrp_NameColourChangedCallback(previousValues)
	local newR, newG, newB, newA;
	if previousValues then
		-- The user bailed, we extract the old colour from the table created by mrp_ShowColorPicker.
		newR, newG, newB, newA = unpack(previousValues);
		if(newR == 0.9924675 and newG == 0.9924675 and newB == 0.9924675) then -- Magic values, wipe the tables, they bailed with no previous colours.
			mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"] = nil
			if(MyRolePlayEditFrame) then
				local currentText = MyRolePlayEditFrame.editbox:GetText()
				currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
				MyRolePlayEditFrame.editbox:SetText(currentText)
			end
			if(msp.my["NA"]) then
				msp.my["NA"] = string.gsub(msp.my["NA"], "|cff%x%x%x%x%x%x", "")
			end
			mrp:UpdateCharacterFrame()
			return
		end
	else
		-- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	-- Update our internal storage.
	r, g, b = newR or 1, newG or 1, newB or 1 -- r, g, b, a should be whatever we wanna set in saved variables.
	if(type(mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]) ~= "table") then -- If the current profile doesn't have an rgb table in the saved profile, make it.
		mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"] = {}
	end
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["r"] = r -- We're always using 1 as the alpha so no need to save opacity.
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["g"] = g
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["b"] = b
	-- And update any UI elements that use this colour...
	mrp:UpdateCharacterFrame()
	mrp:UpdateColour("NA") -- Refresh profile in editor and update msp.my so new colours show up.
end

function mrp_EyeColourChangedCallback(previousValues)
	local newR, newG, newB, newA;
	if previousValues then
		-- The user bailed, we extract the old colour from the table created by mrp_ShowColorPicker.
		newR, newG, newB, newA = unpack(previousValues);
		if(newR == 0.9924675 and newG == 0.9924675 and newB == 0.9924675) then -- Magic values, wipe the tables, they bailed with no previous colours.
			mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"] = nil
			if(MyRolePlayEditFrame) then
				local currentText = MyRolePlayEditFrame.editbox:GetText()
				currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
				MyRolePlayEditFrame.editbox:SetText(currentText)
			end
			if(msp.my["AE"]) then
				msp.my["AE"] = string.gsub(msp.my["AE"], "|cff%x%x%x%x%x%x", "")
			end
			mrp:UpdateCharacterFrame()
			return
		end
	else
		-- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	-- Update our internal storage.
	r, g, b = newR or 1, newG or 1, newB or 1 -- r, g, b, a should be whatever we wanna set in saved variables.
	if(type(mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]) ~= "table") then -- If the current profile doesn't have an rgb table in the saved profile, make it.
		mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"] = {}
	end
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["r"] = r -- We're always using 1 as the alpha so no need to save opacity.
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["g"] = g
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["b"] = b
	-- And update any UI elements that use this colour...
	mrp:UpdateCharacterFrame()
	mrp:UpdateColour("AE") -- Refresh profile in editor and update msp.my so new colours show up.
end

function mrp_DescripInsertColourChangedCallback(previousValues)
	local newR, newG, newB, newA;
	if previousValues then -- Bail, they hit cancel.
		return;
	else
		-- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	-- Insert the colour code into the description box.
	
	local rgbColour = CreateColor(newR, newG, newB, 1)
    local hexcode = rgbColour:GenerateHexColorMarkup()
	mrpColourInsert = hexcode:match("|cff(.+)")
end

function mrp_ShowColourPicker(r, g, b, a, callbackFunc) -- Called from MyRolePlayCharacterFrame_ColourButton in UI_EditFrames.lua.
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = false, a;
	ColorPickerFrame.previousValues = {r,g,b,a};
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callbackFunc, callbackFunc, callbackFunc;
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end

function mrp_HeaderColourChangedCallback(previousValues)
	local newR, newG, newB, newA;
	if previousValues then
		-- The user bailed, we extract the old colour from the table created by mrp_ShowColorPicker.
		newR, newG, newB, newA = unpack(previousValues);
		mrpSaved.Options["headerColour"]["r"] = newR
		mrpSaved.Options["headerColour"]["g"] = newG
		mrpSaved.Options["headerColour"]["b"] = newB
		MyRolePlayOptionsPanel_HeaderColourTexture:SetVertexColor(newR, newG, newB);
		return
	else
		-- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	-- Update our internal storage.
	r, g, b = newR or 1, newG or 1, newB or 1 -- r, g, b, a should be whatever we wanna set in saved variables.
	if(type(mrpSaved.Options["headerColour"]) ~= "table") then -- If the current profile doesn't have an rgb table in the saved profile, make it.
		mrpSaved.Options["headerColour"] = {}
	end
	mrpSaved.Options["headerColour"]["r"] = r -- We're always using 1 as the alpha so no need to save opacity.
	mrpSaved.Options["headerColour"]["g"] = g
	mrpSaved.Options["headerColour"]["b"] = b
	-- And update any UI elements that use this colour...
	MyRolePlayOptionsPanel_HeaderColourTexture:SetVertexColor(r, g, b);
end

-- Music callback

function mrp_MusicCallback(selectedMusic)
	local profile = mrpSaved.SelectedProfile
	local fullName = select(1, UnitFullName("player")) .. "-" .. select(2, UnitFullName("player")) -- Doing this way seems less risky than running mrp:SetCurrentProfile(), even if it'd be easier.
	if(selectedMusic) then
		mrp:SaveField( "MU", selectedMusic )
	else
		mrpSaved.Profiles[profile]["MU"] = nil
		msp.char[fullName]["field"]["MU"] = nil
		msp.my["MU"] = nil
	end
end

-- Icon callbacks

function mrp_IconCallback(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	local fullName = select(1, UnitFullName("player")) .. "-" .. select(2, UnitFullName("player")) -- Doing this way seems less risky than running mrp:SetCurrentProfile(), even if it'd be easier.
	if(selectedTexture) then
		mrp:SaveField( "IC", selectedTexture )
		SetPortraitToTexture( MyRolePlayCharacterFramePortrait, "Interface\\ICONS\\" .. mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] )
	else
		mrpSaved.Profiles[profile]["IC"] = nil
		msp.char[fullName]["field"]["IC"] = nil
		msp.my["IC"] = nil
		SetPortraitTexture( MyRolePlayCharacterFramePortrait, "player" )
	end
end

function mrp_IconCallbackGlance1Icon(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	if(selectedTexture) then
		Glance1IconTexture:SetTexture("Interface\\Icons\\" .. selectedTexture)
		mrpSaved.Profiles[profile]["glances"][1]["Icon"] = ("Interface\\Icons\\" .. selectedTexture)
	end
end

function mrp_IconCallbackGlance2Icon(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	if(selectedTexture) then
		Glance2IconTexture:SetTexture("Interface\\Icons\\" .. selectedTexture)
		mrpSaved.Profiles[profile]["glances"][2]["Icon"] = ("Interface\\Icons\\" .. selectedTexture)
	end
end

function mrp_IconCallbackGlance3Icon(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	if(selectedTexture) then
		Glance3IconTexture:SetTexture("Interface\\Icons\\" .. selectedTexture)
		mrpSaved.Profiles[profile]["glances"][3]["Icon"] = ("Interface\\Icons\\" .. selectedTexture)
	end
end

function mrp_IconCallbackGlance4Icon(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	if(selectedTexture) then
		Glance4IconTexture:SetTexture("Interface\\Icons\\" .. selectedTexture)
		mrpSaved.Profiles[profile]["glances"][4]["Icon"] = ("Interface\\Icons\\" .. selectedTexture)
	end
end

function mrp_IconCallbackGlance5Icon(selectedTexture)
	local profile = mrpSaved.SelectedProfile
	if(selectedTexture) then
		Glance5IconTexture:SetTexture("Interface\\Icons\\" .. selectedTexture)
		mrpSaved.Profiles[profile]["glances"][5]["Icon"] = ("Interface\\Icons\\" .. selectedTexture)
	end
end
--

function mrp:CreateCharacterFrame()
	if not MyRolePlayCharacterFrame then

		local cf = CreateFrame( "Frame", "MyRolePlayCharacterFrame", CharacterFrame, "PortraitFrameTemplate", 5)
		MyRolePlayCharacterFrameCloseButton:Hide();
		cf:SetScript("OnShow", function(self)
			--CharacterStatsPane:Hide() CLASSIC REMOVED
			--CharacterFrameInsetRight:Hide() CLASSIC REMOVED
			CharacterFramePortrait:Hide()
			if mrp.CharacterPanelExpanded then
				CharacterFrame:SetWidth( 700 )
				CharacterFrame.Expanded = true
			else
				CharacterFrame:SetWidth( 384 ) -- We can't trust PANEL_DEFAULT_WIDTH in Classic because the CharacterFrame doesn't match the size of its graphical elements like in BFA. Classic uses old files without texture coords and the CharacterFrame size is much larger than it visually appears, including blank space..
				CharacterFrame.Expanded = false
			end
			UpdateUIPanelPositions( CharacterFrame )
			CharacterFramePortrait:SetTexCoord( 0, 1, 0, 1 )
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] ~= "") then
				SetPortraitToTexture( MyRolePlayCharacterFramePortrait, "Interface\\ICONS\\" .. mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] )
			else
				--SetPortraitToTexture( MyRolePlayCharacterFramePortrait, "Interface\\ICONS\\INV_Scroll_04" )
				SetPortraitTexture( MyRolePlayCharacterFramePortrait, "player" )
			end
			origCharacterNameTitle = CharacterNameText:GetText();
			CharacterNameText:SetText( msp.my.NA or UnitName("player") )
		end	)
		cf:SetScript("OnHide", function(self)
			CharacterFramePortrait:Show()
			HideDropDownMenu( 1 )
			MyRolePlayCharacterFrame.pdd:Hide()
			MyRolePlayMultiEditFrame:Hide()
			MyRolePlayComboEditFrame:Hide()
			MyRolePlayEditFrame:Hide()
			MyRolePlayGlanceEditFrame:Hide()
			if PaperDollFrame:IsVisible() then
				if GetCVar( "characterFrameCollapsed" ) == "1" then
					CharacterFrame_Collapse()
				else
					CharacterFrame_Expand()
				end
			end
			CharacterFrame:SetWidth( 384 ) -- Workaround for resize issue.
			CharacterNameText:SetText(origCharacterNameTitle) -- Below function doesnt work in classic, gotta do it this way.
			--CharacterFrame_UpdatePortrait() CLASSIC REMOVED
		end	)
		cf:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 15, -14) -- We also moved this over, in reference to the PANEL_DEFAULT_WIDTH comment above.
        cf:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -32, 75)
		cf:SetFrameStrata("BACKGROUND")
		cf:SetFrameLevel( CharacterFrame:GetFrameLevel()+2 )
		-- Create inset (Gotta make our own because the vanilla character frame doesn't come with one)
		cf.inset = CreateFrame("Frame", "MyRolePlayCharacterFrameInset", MyRolePlayCharacterFrame, "InsetFrameTemplate")
		cf.inset:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 2, -60 )
		cf.inset:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -420 )
		
		-- Version
		cf.ver = cf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		cf.ver:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 120, -27 )
		cf.ver:SetText( mrp.VerText )

		-- Profile Combo Box
		cf.pcb = CreateFrame( "Frame", "MyRolePlayCharacterFrame_ProfileComboBox", cf )
		cf.pcb:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 125, -43 )
		cf.pcb:SetSize( 210, 32 )

		cf.pcb.tl = cf.pcb:CreateTexture( ) -- Left
		cf.pcb.tl:SetPoint( "TOPLEFT", cf.pcb, "TOPLEFT", 0, 17 )
		cf.pcb.tl:SetSize( 25, 50 )
		cf.pcb.tl:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tl:SetTexCoord( 0, 0.1953125, 0, 1 )
		cf.pcb.tm = cf.pcb:CreateTexture( ) -- Middle
		cf.pcb.tm:SetPoint( "LEFT", cf.pcb.tl, "RIGHT" )
		cf.pcb.tm:SetSize( 100, 50 )
		cf.pcb.tm:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tm:SetTexCoord( 0.1953125, 0.8046875, 0, 1 )
		cf.pcb.tr = cf.pcb:CreateTexture( ) -- Right
		cf.pcb.tr:SetPoint( "LEFT", cf.pcb.tm, "RIGHT" )
		cf.pcb.tr:SetSize( 25, 50 )
		cf.pcb.tr:SetTexture( "Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame" )
		cf.pcb.tr:SetTexCoord( 0.8046875, 1, 0, 1 )
		cf.pcb.button = CreateFrame( "Button", "MyRolePlayCharacterFrame_ProfileComboBox_Button", cf.pcb )
		cf.pcb.button:SetPoint( "TOPRIGHT", cf.pcb.tr, "TOPRIGHT", -16, -12 )
		cf.pcb.button:SetSize( 24, 24 )
		cf.pcb.button:SetScript("OnClick", function() 
			ToggleDropDownMenu( 1, nil, MyRolePlayCharacterFrame.pdd, MyRolePlayCharacterFrame.pcb )
		end )
		cf.pcb.button:SetNormalTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up" )
		cf.pcb.button:SetPushedTexture( "Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down" )
		cf.pcb.button:SetHighlightTexture( "Interface\\Buttons\\UI-Common-MouseHilight", "ADD" )

		cf.pcb.text = cf.pcb:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		cf.pcb.text:SetPoint( "LEFT", cf.pcb, "LEFT", 27, 10 )
		cf.pcb.text:SetSize( 140, 10 )
		cf.pcb.text:SetJustifyH( "LEFT" )
		cf.pcb.text:SetText( mrpSaved.SelectedProfile or "" )

		cf.pdd = CreateFrame( "Frame", "MyRolePlayCharacterFrame_Profile_Dropdown", cf, "UIDropDownMenuTemplate" )
		cf.pdd.initialize = MyRolePlayCharacterFrame_Profile_Dropdown_Init
		
		-- [I]
		cf.icb = CreateFrame( "Button", "MyRolePlayCharacterFrame_IconButton", cf, uipbt )
		cf.icb:SetPoint( "LEFT", cf.pcb, "LEFT", -74, 9 )
		cf.icb:SetText( L["editor_icon_button"] )
		cf.icb:SetWidth( 40 )
		cf.icb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] ~= "") then
				GameTooltip:SetText( L["editor_icon_button_tt_active"], 1.0, 1.0, 1.0 )
				GameTooltip:AddLine( mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"], 1.0, 0.8, 0.06)
				GameTooltip:Show()
			else
				GameTooltip:SetText( L["editor_icon_button_tt_inactive"], 1.0, 1.0, 1.0 )
			end
		end )
		cf.icb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.icb:SetScript("OnClick", function (self)
			mrp_iconselector_show(mrp_IconCallback, mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] or nil)
		end )
		
		-- [Settings button]
		cf.cfg = CreateFrame( "Button", "MyRolePlayCharacterFrame_SettingsButton", cf, uipbt )
		cf.cfg:SetPoint( "BOTTOM", cf.icb, "TOP", -2, -1 )
		cf.cfg:SetText( L["|TInterface\\Buttons\\UI-OptionsButton:10:10:0:-2|t"] )
		cf.cfg:SetWidth( 20 )
		cf.cfg:SetHeight( 16 )
		cf.cfg:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_settings_button"], 1.0, 1.0, 1.0 )
		end )
		cf.cfg:SetScript( "OnLeave", GameTooltip_Hide )
		cf.cfg:SetScript("OnClick", function (self)
			InterfaceOptionsFrame_OpenToCategory( "MyRolePlay" );
			InterfaceOptionsFrame_OpenToCategory( "MyRolePlay" );
		end )
		
		-- [M]
		cf.msb = CreateFrame( "Button", "MyRolePlayCharacterFrame_IconButton", cf, uipbt )
		cf.msb:SetPoint( "LEFT", cf.icb, "RIGHT", 1, 0 )
		cf.msb:SetText( L["editor_music_button"] )
		cf.msb:SetWidth( 50 )
		cf.msb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["MU"] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["MU"] ~= "") then
				GameTooltip:SetText( L["editor_music_button_tt_active"], 1.0, 1.0, 1.0 )
				GameTooltip:AddLine( mrpSaved.Profiles[mrpSaved.SelectedProfile]["MU"], 1.0, 0.8, 0.06)
				GameTooltip:Show()
			else
				GameTooltip:SetText( L["editor_music_button_tt_inactive"], 1.0, 1.0, 1.0 )
			end
		end )
		cf.msb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.msb:SetScript("OnClick", function (self)
			mrp_musicselector_show(mrp_MusicCallback, mrpSaved.Profiles[mrpSaved.SelectedProfile]["MU"] or nil)
		end )
		
		-- [+]
		cf.npb = CreateFrame( "Button", "MyRolePlayCharacterFrame_NewProfileButton", cf, uipbt )
		cf.npb:SetPoint( "LEFT", cf.pcb.button, "RIGHT", 1, 0 )
		cf.npb:SetText( L["+"] )
		cf.npb:SetWidth( 24 )
		cf.npb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_newprofile_button"], 1.0, 1.0, 1.0 )
		end )
		cf.npb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.npb:SetScript("OnClick", function (self)
			StaticPopup_Show("MRP_NEW_PROFILE")
		end )

		-- [R]
		cf.rpb = CreateFrame( "Button", "MyRolePlayCharacterFrame_RenProfileButton", cf, uipbt )
		cf.rpb:SetPoint( "LEFT", cf.npb, "RIGHT", 1, 0 )
		cf.rpb:SetText( L["R"] )
		cf.rpb:SetWidth( 24 )
		cf.rpb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if mrpSaved.SelectedProfile == "Default" then
				GameTooltip:SetText( L["Change the name of this profile. (The default profile can't be renamed.)"], 1.0, 1.0, 1.0 )
			else
				GameTooltip:SetText( L["editor_renameprofile_button"], 1.0, 1.0, 1.0 )
			end
		end )
		cf.rpb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.rpb:SetScript("OnClick", function (self)
			if mrpSaved.SelectedProfile == "Default" then
				mrp:Print( L["Can’t rename the default profile."] )
			else
				StaticPopup_Show("MRP_RENAME_PROFILE")
			end
		end )

		-- [-]
		cf.dpb = CreateFrame( "Button", "MyRolePlayCharacterFrame_DelProfileButton", cf, uipbt )
		cf.dpb:SetPoint( "LEFT", cf.rpb, "RIGHT", 1, 0 )
		cf.dpb:SetText( L["-"] )
		cf.dpb:SetWidth( 24 )
		cf.dpb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			if mrpSaved.SelectedProfile == "Default" then
				GameTooltip:SetText( L["editor_deleteprofile_button_default"], 1.0, 1.0, 1.0 )
			else
				GameTooltip:SetText( L["editor_deleteprofile_button"], 1.0, 1.0, 1.0 )
			end
		end )
		cf.dpb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.dpb:SetScript("OnClick", function (self)
			if mrpSaved.SelectedProfile == "Default" then
				StaticPopup_Show("MRP_CLEAR_PROFILE")
			else
				StaticPopup_Show("MRP_DELETE_PROFILE")
			end
		end )
		
		-- [Import]
		cf.ipb = CreateFrame( "Button", "MyRolePlayCharacterFrame_ImportProfileButton", cf, uipbt )
		cf.ipb:SetPoint( "BOTTOM", cf.rpb, "TOP", 1, 0 )
		cf.ipb:SetText( L["editor_import_button"] )
		cf.ipb:SetWidth( 75 )
		cf.ipb:SetHeight( 15 )
		if(IsAddOnLoaded("totalRP3") or IsAddOnLoaded("XRP")) then
			cf.ipb:SetScript( "OnEnter", function(self) 
				GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
				GameTooltip:SetText( L["editor_import_tt_title"], 1.0, 1.0, 1.0 )
				GameTooltip:AddLine( L["editor_import_tt_1_active"], 0.97, 0.80, 0.05, true )
				GameTooltip:AddLine( L["editor_import_tt_2_active"], 1, 0, 0, true )
				GameTooltip:Show()
			end )
		else
			cf.ipb:Disable();
			cf.ipb:SetMotionScriptsWhileDisabled(true)
			cf.ipb:SetScript( "OnEnter", function(self) 
				GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
				GameTooltip:SetText( L["editor_import_tt_title"], 1.0, 1.0, 1.0 )
				GameTooltip:AddLine( L["editor_import_tt_1_inactive"], 0.97, 0.80, 0.05, true )
				GameTooltip:Show()
			end )
		end
		cf.ipb:SetScript( "OnLeave", GameTooltip_Hide )
		cf.ipb:SetScript("OnClick", function (self)
			if(IsAddOnLoaded("totalRP3") or IsAddOnLoaded("XRP")) then
				if(IsAddOnLoaded("totalRP3")) then
					StaticPopupDialogs["MRP_IMPORT_PROFILE"].text = "|cff9944DDMyRolePlay|r\n\nWould you like to copy your |cff00FF44TotalRP3|r profile for |cff00FF44" .. UnitName("player") .. "|r to MyRolePlay?"
				elseif(IsAddOnLoaded("XRP")) then
					StaticPopupDialogs["MRP_IMPORT_PROFILE"].text = "|cff9944DDMyRolePlay|r\n\nWould you like to copy your |cff00FF44XRP|r profiles for |cff00FF44" .. UnitName("player") .. "|r to MyRolePlay?"
				end
				StaticPopup_Show("MRP_IMPORT_PROFILE")
			end
		end )

		local mrplfont = CreateFont("MyRolePlayLittleFont")
		mrplfont:SetFont( "Fonts\\FRIZQT__.TTF", 9, "" )
		mrplfont:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
		mrplfont:SetShadowColor( 0, 0, 0, 0 )
		mrplfont:SetJustifyH( "LEFT" )
		mrplfont:SetJustifyV( "TOP" )
		
		local mrpmfont = CreateFont("MyRolePlayMediumFont")
		mrpmfont:SetFont( "Fonts\\FRIZQT__.TTF", 10, "" )
		mrpmfont:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
		mrpmfont:SetShadowColor( 0, 0, 0, 0 )
		mrpmfont:SetJustifyH( "LEFT" )
		mrpmfont:SetJustifyV( "TOP" )

		-- A subframe to contain the fields in the profile.
		cf.f = CreateFrame( "Frame", "MyRolePlayCharacterFrame_Fields", cf )
		cf.f:SetPoint( "TOPLEFT", MyRolePlayCharacterFrameInset, "TOPLEFT", 6, -3 )
		cf.f:SetPoint( "TOPRIGHT", MyRolePlayCharacterFrameInset, "TOPRIGHT", -5, -3 )
		cf.f:SetPoint( "BOTTOMLEFT", MyRolePlayCharacterFrameInset, "BOTTOMLEFT", 6, 6 )
		cf.f:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrameInset, "BOTTOMRIGHT", -5, 6 )
		cf.f:EnableDrawLayer( "BORDER" )
		cf.f.fields={}

		mrp:CreateCFpfield( cf.f, 'NA', L["NA"], 13, 165, nil, mrp.CFEditField, L["efNA"] )
		mrp:CreateCFpfield( cf.f, 'NI', L["NI"], 13, 96, cf.f.fields['NA'], mrp.CFEditField, L["efNI"] )
		mrp:CreateCFpfield( cf.f, 'NT', L["NT"], 13, -105, cf.f.fields['NA'], mrp.CFEditField, L["efNT"] )
		mrp:CreateCFpfield( cf.f, 'NH', L["NH"], 13, 90, cf.f.fields['NT'], mrp.CFEditField, L["efNH"] )
		mrp:CreateCFpfield( cf.f, 'RS', L["RS"], 13, 115, cf.f.fields['NH'], mrp.CFEditField, L["efRS"] ) -- New RS field.
		mrp:CreateCFpfield( cf.f, 'PE', L["PE"], 15, -80, cf.f.fields['NT'], mrp.CFEditField, L["efPE"] ) -- New PE field.
		mrp:CreateCFpfield( cf.f, 'RA', L["RA"], 15, 115, cf.f.fields['PE'], mrp.CFEditField, L["efRA"] )
		mrp:CreateCFpfield( cf.f, 'RC', L["RC"], 15, 117, cf.f.fields['RA'], mrp.CFEditField, L["efRC"] ) -- New RC field
		mrp:CreateCFpfield( cf.f, 'AE', L["AE"], 13, -103, cf.f.fields['PE'], mrp.CFEditField, L["efAE"] )
		mrp:CreateCFpfield( cf.f, 'AH', L["AH"], 13, 103, cf.f.fields['AE'], mrp.CFEditField, L["efAH"] )
		mrp:CreateCFpfield( cf.f, 'AW', L["AW"], 13, 104, cf.f.fields['AH'], mrp.CFEditField, L["efAW"] )
		mrp:CreateCFpfield( cf.f, 'AG', L["AG"], 13, 50, cf.f.fields['NI'], mrp.CFEditField, L["efAG"] )
		mrp:CreateCFpfield( cf.f, 'CU', L["CU"], 13, -318, cf.f.fields['AE'], mrp.CFEditField, L["efCU"] )
		mrp:CreateCFpfield( cf.f, 'CO', L["CO"], 13, -318, cf.f.fields['CU'], mrp.CFEditField, L["efCO"] ) -- New OOC field.
		mrp:CreateCFpfield( cf.f, 'DE', L["DE"], 55, -318, cf.f.fields['CO'], mrp.CFEditField, L["efDE"] )
		mrp:CreateCFpfield( cf.f, 'PS', L["PS"], 13, -318, cf.f.fields['DE'], mrp.CFEditField, L["efPS"] )
		mrp:CreateCFpfield( cf.f, 'HH', L["HH"], 13, -103, cf.f.fields['PS'], mrp.CFEditField, L["efHH"] )
		mrp:CreateCFpfield( cf.f, 'HB', L["HB"], 13, 103, cf.f.fields['HH'], mrp.CFEditField, L["efHB"] )
		mrp:CreateCFpfield( cf.f, 'MO', L["MO"], 13, 104, cf.f.fields['HB'], mrp.CFEditField, L["efMO"] )
		mrp:CreateCFpfield( cf.f, 'HI', L["HI"], 50, -318, cf.f.fields['HH'], mrp.CFEditField, L["efHI"] )
		mrp:CreateCFpfield( cf.f, 'FR', L["FR"], 13, -157, cf.f.fields['HI'], mrp.CFEditField, L["efFR"] )
		mrp:CreateCFpfield( cf.f, 'FC', L["FC"], 13, 157, cf.f.fields['FR'], mrp.CFEditField, L["efFC"] )

		mrp:CreateEditFrames()

		mrp:UpdateCharacterFrame()

		-- Garbage-collect functions we only need once
		mrp.CreateCharacterFrame = mrp_dummyfunction
		mrp.CreateCFpfield = mrp_dummyfunction
	end
end

function mrp:CreateCFpfield( c, field, name, height, width, anchor, onclick, desc )
	local yoffs = 0
	local xoffs = 0
	local anchorpointl = "TOPLEFT"
	local anchorpointr = "TOPRIGHT"
	local sep
	if not anchor then 
		anchor = c
	elseif width then
		if width < 0 then
			width = -width
			yoffs = 12
			anchorpointl = "BOTTOMLEFT"
		else
			sep = true
			yoffs = 0
			xoffs = 4
			anchorpointl = "TOPRIGHT"
		end
	else
		xoffs = 0
		yoffs = 12
		anchorpointl = "BOTTOMLEFT"
		anchorpointr = "BOTTOMRIGHT"
	end
	c.fields[field] = CreateFrame( "Frame", nil, c )
	local f = c.fields[field]
	f:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	if width then
		f:SetWidth( width )
	else
		f:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	f:SetHeight( height )
	f.h = CreateFrame( "Frame", nil, f )
	f.h:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	f.h:SetHeight( 12 )
	if width then
		f.h:SetWidth( width )
	else
		f.h:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	if sep then
		f.sep = CreateFrame( "Frame", nil, f )
		f.sep:SetSize( 4, 12 )
		f.sep:SetPoint( "TOPRIGHT", f.h, "TOPLEFT", -1 )
		f.sep:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\FieldSep.blp]],
			tile = false,
		} )
	end
	f.h.fs = f.h:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" )
	f.h.fs:SetJustifyH( "LEFT" )
	f.h.fs:SetText( "   "..name )
	f.h.fs:SetParent( f.h )
	f.h.fs:SetShadowColor( 0, 0, 0, 0.1 )
	f.h.fs:SetAllPoints()
	f.h.fs:SetPoint("TOPLEFT", f.h, "TOPLEFT", 0, 3 )

	f.h:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
			tile = false,
	} )
	local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
	f.h:SetBackdropColor(r, g, b);
	f.t = f:CreateFontString( nil, "ARTWORK", "MyRolePlayLittleFont" )
	f.t:SetWordWrap(true)
	f.t:SetNonSpaceWrap(false)
	f.t:SetParent( f )
	f.t:SetPoint( "TOPLEFT", f.h, "BOTTOMLEFT", 0, -1 )
	f.t:SetPoint( "TOPRIGHT", f.h, "BOTTOMRIGHT", 0, -1 )
	f.t:SetHeight( height ) -- Was height - 12
	if onclick then 
		f.field = field
		f.fieldname = name
		f.desc = desc
		f.click = onclick
		f:EnableMouse(true)
		f:SetScript( "OnEnter", function(self)
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( name, 0.9, 0.65, 0.35 )
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( desc, 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( L["editor_clicktoedit"] )
			GameTooltip:Show()
			if self.lowlight then
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.6 )
				self.h.fs:SetTextColor( 0.8, 0.62, 0.3, 1.0 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Highlight-Disabled.blp]],
						tile = false,
				} )
				local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
				self.h:SetBackdropColor(r, g, b);
			else
				self.t:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
				self.h.fs:SetTextColor( 1.0, 0.92, 0.4, 1 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Highlight.blp]],
						tile = false,
				} )
				local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
				self.h:SetBackdropColor(r, g, b);
			end
		end )
		f:SetScript( "OnLeave", function(self)
			if self.lowlight then
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
				self.h.fs:SetTextColor( 0.7, 0.52, 0.2, 0.85 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Disabled.blp]],
						tile = false,
				} )
				local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
				self.h:SetBackdropColor(r, g, b);
			else
				self.t:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
				self.h.fs:SetTextColor( 1.0, 0.82, 0, 1 )
				self.h:SetBackdrop( {
						bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
						tile = false,
				} )
				local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
				self.h:SetBackdropColor(r, g, b);
			end
			GameTooltip:Hide()
		end )
		f:SetScript( "OnMouseUp", function(self)
            if((self.field) == "NA" and mrpSaved.Options.AllowColours and mrpSaved.Options.AllowColours == true) then -- Show or Hide the Colour Change button on the edit frame.
                MyRolePlayCharacterFrame_ColourButton:Show()
                MyRolePlayCharacterFrame_RestoreDefaultColourButtonName:Show()
            else
                if ColorPickerFrame:IsShown() and MyRolePlayCharacterFrame_ColourButton:IsShown() then
                    mrp_NameColourChangedCallback(ColorPickerFrame.previousValues)
                    ColorPickerFrame:Hide()
                end
                MyRolePlayCharacterFrame_ColourButton:Hide()
                MyRolePlayCharacterFrame_RestoreDefaultColourButtonName:Hide()
            end
            if((self.field) == "AE" and mrpSaved.Options.AllowColours and mrpSaved.Options.AllowColours == true) then -- Show or Hide the Colour Change button on the edit frame.
                MyRolePlayCharacterFrame_EyeColourButton:Show()
                MyRolePlayCharacterFrame_RestoreDefaultColourButtonEyes:Show()
            else
                if ColorPickerFrame:IsShown() and MyRolePlayCharacterFrame_EyeColourButton:IsShown() then
                    mrp_EyeColourChangedCallback(ColorPickerFrame.previousValues)
                    ColorPickerFrame:Hide()
                end
                MyRolePlayCharacterFrame_EyeColourButton:Hide()
                MyRolePlayCharacterFrame_RestoreDefaultColourButtonEyes:Hide()
            end
			if((self.field) == "DE" or (self.field) == "HI") then -- Show or Hide the Colour Change button on the edit frame.
                if(mrpSaved.Options.AllowColours and mrpSaved.Options.AllowColours == true) then
					MyRolePlayMultiEditFrame_DescripInsertColourButton:Show()
				end
				MyRolePlayMultiEditFrame_InsertIconButton:Show()
				MyRolePlayMultiEditFrame_LinkInsertButton:Show()
				MyRolePlayMultiEditFrame_DescripInsertHeader1Button:Show()
				MyRolePlayMultiEditFrame_DescripInsertParagraphButton:Show()
				MyRolePlayMultiEditFrame_InsertImageButton:Show()
				MyRolePlayMultiEditFrame_FormattingToolsSubtitle:Show()
				MyRolePlayMultiEditFrame_PreviewProfileButton:Show()
				
            else
                if ColorPickerFrame:IsShown() and MyRolePlayMultiEditFrame_DescripInsertColourButton:IsShown() then
                    ColorPickerFrame:Hide()
                end
                MyRolePlayMultiEditFrame_DescripInsertColourButton:Hide()
				MyRolePlayMultiEditFrame_InsertIconButton:Hide()
				MyRolePlayMultiEditFrame_LinkInsertButton:Hide()
				MyRolePlayMultiEditFrame_DescripInsertHeader1Button:Hide()
				MyRolePlayMultiEditFrame_DescripInsertParagraphButton:Hide()
				MyRolePlayMultiEditFrame_InsertImageButton:Hide()
				MyRolePlayMultiEditFrame_FormattingToolsSubtitle:Hide()
				MyRolePlayMultiEditFrame_PreviewProfileButton:Hide()
            end
            self.click( self.field, self.fieldname, self.desc )
        end )
	end
end

-- Update the text in the editor
function mrp:UpdateCharacterFrame()
	local cf = MyRolePlayCharacterFrame
	if not cf then
		return
	end
	cf.pcb.text:SetText( mrpSaved.SelectedProfile or "" )
	
	if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] ~= "") then
		SetPortraitToTexture( MyRolePlayCharacterFramePortrait, "Interface\\ICONS\\" .. mrpSaved.Profiles[mrpSaved.SelectedProfile]["IC"] )
	else
		SetPortraitTexture( MyRolePlayCharacterFramePortrait, "player" )
	end
	
	-- Can't rename the default profile, so if this is it, disable that button
	-- We can 'delete' the default profile however, it clears it to defaults
	if mrpSaved.SelectedProfile == "Default" then
		cf.rpb:Disable()
	else
		cf.rpb:Enable()
	end
	if cf:IsShown() then 
		CharacterNameText:SetText( emptynil( msp.my['NA'] ) or UnitName("player") )
	end

	for index, field in pairs( cf.f.fields ) do
		if(index ~= "PE" and index ~= "PS") then -- We need to handle glances and traits differently.
			if(index == "DE" or index == "HI") then
				field.t:SetText( mrp.Display[ index ]( msp.my[ index ] ):gsub("{.-}", "") )
			else
				field.t:SetText( mrp.Display[ index ]( msp.my[ index ] ) )
			end
		elseif(index == "PE") then
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"]) then
				local glanceIconRow = ""
				for i = 1, 5, 1 do
					if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][i]["Icon"] and mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][i]["Icon"] ~= "Interface\\Icons\\INV_Misc_QuestionMark") then
						glanceIconRow = glanceIconRow .. "|T" .. mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][i]["Icon"] .. ":20:20|t"
					end
				end
				field.t:SetText( glanceIconRow )
			end
		elseif(index == "PS") then
			field.t:SetText( L["PSsubheader"] )
		end
        -- Adding the colour code if necessary
        local defaultField = mrpSaved.Profiles.Default[index]
        local colourFieldArray
        if (index == "NA" or index == "RC") then
            colourFieldArray = mrpSaved.Profiles.Default["nameColour"]
        elseif index == "AE" then
            colourFieldArray = mrpSaved.Profiles.Default["eyeColour"]
        end
        if defaultField and colourFieldArray then
            local rgbColour = CreateColor(colourFieldArray["r"], colourFieldArray["g"], colourFieldArray["b"], 1)
            local hexcode = rgbColour:GenerateHexColorMarkup()
            defaultField = hexcode .. defaultField
        end
        -- visually lowlight the field if it's templated from the default
        if msp.my[index] == defaultField and mrpSaved.SelectedProfile ~= "Default" then
			field.lowlight = true
			field.t:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			field.h.fs:SetTextColor( 0.7, 0.52, 0.2, 0.85 )
			field.h:SetBackdrop( {
					bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground-Disabled.blp]],
					tile = false,
			} )
			local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
			field.h:SetBackdropColor(r, g, b);
		else
			field.lowlight = false
			field.t:SetTextColor( 1.0, 1.0, 1.0, 0.85 )
			field.h.fs:SetTextColor( 1.0, 0.82, 0, 1 )
			field.h:SetBackdrop( {
					bgFile = [[Interface\AddOns\MyRolePlay\Artwork\HeaderBackground.blp]],
					tile = false,
			} )	
			local r, g, b = mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]
			field.h:SetBackdropColor(r, g, b);
		end
	end
end


function mrp:UpdateCFProfileScrollFrame()
	HideDropDownMenu( 1 )
end

function MyRolePlayCharacterFrame_Profile_Dropdown_Click( self, profile )
	mrp:SetCurrentProfile( profile )
	MyRolePlayCharacterFrame.pdd:Hide()
	MyRolePlayComboEditFrame:Hide()
	MyRolePlayMultiEditFrame:Hide()
	MyRolePlayEditFrame:Hide()
	MyRolePlayGlanceEditFrame:Hide()
	mrp:UpdateCharacterFrame()
end

local profiletitles = { }

function MyRolePlayCharacterFrame_Profile_Dropdown_Init( self )
	for k, v in pairs( mrpSaved.Profiles ) do
		if k ~= "Default" then
			tinsert( profiletitles, k )
		end
	end
	table.sort( profiletitles )
	tinsert( profiletitles, 1, "Default" )
	for i = 1, #profiletitles do
		local info = UIDropDownMenu_CreateInfo()
		info.text = profiletitles[ i ]
		info.arg1 = profiletitles[ i ]
		if profiletitles[ i ] == "Default" then 
			info.colorCode = "|cff80f0a0"
		end
		info.func = MyRolePlayCharacterFrame_Profile_Dropdown_Click
		info.owner = MyRolePlayCharacterFrame.pcb.button
		UIDropDownMenu_AddButton( info )
	end
	wipe( profiletitles )
	UIDropDownMenu_SetSelectedValue( MyRolePlayCharacterFrame_Profile_Dropdown, mrpSaved.SelectedProfile or "Default" )
end


StaticPopupDialogs[ "MRP_DELETE_PROFILE" ] = { 
	text = L["editor_deleteprofile_popup"],
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
		mrp:SetCurrentProfile( "Default" )
		mrp:UpdateCFProfileScrollFrame()
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}
StaticPopupDialogs[ "MRP_CLEAR_PROFILE" ] = { 
	text = L["editor_deleteallprofiles_popup"],
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		mrpSaved.Profiles = nil
		mrp:HardResetProfiles()
		mrp:SetCurrentProfile( "Default" )
		mrp:UpdateCFProfileScrollFrame()
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}
StaticPopupDialogs["MRP_NEW_PROFILE"] = {
	text = L["editor_newprofile_popup"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 40,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		if text and text ~= "" then
			if type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = { }
				mrpSaved.Profiles[ text ]["AE"] = mrpSaved.Profiles["Default"]["AE"] or "" -- Copy over the eye values to "inherit" from Default when making a new profile. This is a temp solution but still learning where everything is.
				if(mrpSaved.Profiles["Default"] ~= nil) then -- Transfer over complex fields as a one shot thing when making a new profile.
					if(mrpSaved.Profiles["Default"]["glances"] ~= nil) then -- 
						mrpSaved.Profiles[ text ]["glances"] = mrpSaved.Profiles["Default"]["glances"] -- Transfer glances over from default when making a new profile. This is a complex field so needs to be done this way.
					end
					if(mrpSaved.Profiles["Default"]["PS"] ~= nil and mrpSaved.Profiles["Default"]["PS"] ~= "") then
						mrpSaved.Profiles[ text ]["PS"] = mrpSaved.Profiles["Default"]["PS"] -- Transfer personality traits over to new profiles as a one shot thing when making a new profile. It's another complex field so no inheritance.
					end
				end
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		if text and text ~= "" then
			if type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = { }
				mrpSaved.Profiles[ text ]["AE"] = mrpSaved.Profiles["Default"]["AE"] or "" -- Copy over the eye values to "inherit" from Default when making a new profile. This is a temp solution but still learning where everything is.
				if(mrpSaved.Profiles["Default"] ~= nil) then -- Transfer over complex fields as a one shot thing when making a new profile.
					if(mrpSaved.Profiles["Default"]["glances"] ~= nil) then
						mrpSaved.Profiles[ text ]["glances"] = mrpSaved.Profiles["Default"]["glances"] -- Transfer glances over from default when making a new profile. This is a complex field so needs to be done this way.
					end
					if(mrpSaved.Profiles["Default"]["PS"] ~= nil and mrpSaved.Profiles["Default"]["PS"] ~= "") then
						mrpSaved.Profiles[ text ]["PS"] = mrpSaved.Profiles["Default"]["PS"] -- Transfer personality traits over to new profiles as a one shot thing when making a new profile. It's another complex field so no inheritance.
					end
				end
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
		self:GetParent():Hide()
	end,
	OnShow = function(self)
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
}
StaticPopupDialogs["MRP_RENAME_PROFILE"] = {
	text = L["editor_renameprofile_popup"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 40,
	OnAccept = function(self)
		local text = self.editBox:GetText()
		if text and text ~= "" then
			if text ~= mrpSaved.SelectedProfile and type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = mrpSaved.Profiles[ mrpSaved.SelectedProfile ]
				mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		if text and text ~= "" then
			if text ~= mrpSaved.SelectedProfile and type(mrpSaved.Profiles[text]) ~= "table" then
				mrpSaved.Profiles[ text ] = mrpSaved.Profiles[ mrpSaved.SelectedProfile ]
				mrpSaved.Profiles[ mrpSaved.SelectedProfile ] = nil
			end
			mrp:SetCurrentProfile( text )
			mrp:UpdateCFProfileScrollFrame()
		end
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetText( mrpSaved.SelectedProfile or "" )
		self.editBox:SetFocus()
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["MRP_IMPORT_PROFILE"] = {
	text = "Another RP addon is loaded. Would you like to copy this character's profile from there to a new profile in MRP?",
	button1 = "Yes",
	button2 = "No",
	OnAccept = function()
		if(IsAddOnLoaded("totalRP3")) then
			mrp:ImportTRP3Profile()
		elseif(IsAddOnLoaded("XRP")) then
			mrp:ImportXRPProfile()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
}

StaticPopupDialogs["MRP_IMPORT_RELOAD"] = {
	text = "|cff9944DDMyRolePlay|r\n\nImport complete. It is recommended that you |cff00ffb3reload|r. Reloading will also disable any other RP addons, allowing you to use MyRolePlay normally again.",
	button1 = "Reload",
	OnAccept = function()
		if(IsAddOnLoaded("totalRP3")) then
			DisableAddOn("totalRP3")
		elseif(IsAddOnLoaded("XRP")) then
			DisableAddOn("XRP")
		end
		C_UI.Reload();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = false,
}