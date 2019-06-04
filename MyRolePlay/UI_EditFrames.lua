--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_EditFrames.lua - Supporting EditFrames for the MyRolePlayCharacterFrame
]]

local L = mrp.L

local function emptynil( x ) return x ~= "" and x or nil end

local uipbt = "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

local previousGlanceIcons = {} -- Save previous icons here temporarily until the editor is closed so we can restore them if they cancel.

local maxRecommendedCharacters = { -- The most "recommended" characters per field. Show the "!" icon in the editor when this threshold is reached.
	["DE"] = 7000,
	["HI"] = 7000,
	["CU"] = 150,
	["CO"] = 150
}

function mrp:ClearGlance(glance) -- Wipe a glance's data using the clear button.
	_G["Glance" .. glance .. "Title"]:SetText("")
	_G["Glance" .. glance .. "Descrip"].editbox:SetText("")
	_G["Glance" .. glance .. "IconTexture"]:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
	mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][glance]["Icon"] = "Interface\\Icons\\INV_Misc_QuestionMark"
end

function mrp:ConvertPreview( newtext ) -- Used in the profile preview option to convert tags to normal appearance.
	if newtext then 
		newtext = strtrim( newtext )
		newtext = newtext:gsub("|n", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|K.-|k.-|k", ""):trim()
		-- Swap tags to colour codes when saving.
		newtext = newtext:gsub("{col:(%x%x%x%x%x%x)}", "|cff%1")
		newtext = newtext:gsub("{/col}", "|r")
		-- Swap tags to icons when saving.
		newtext = newtext:gsub("{icon:(.-):(%d+)}", "|TInterface\\Icons\\%1:%2|t")
		-- Swap tags to links when saving.
		newtext = newtext:gsub("{link%*(.-)%*(.-)}", "[%2]( %1 )")
		newtext = mrp:CreateURLLink(newtext)
		newtext = mrp:ConvertStringToHTML(newtext)
		return newtext
	end
end

---------------------------------
-- Personality trait functions
---------------------------------

-- Format string used for denoting a builtin trait.
local PS_BUILTIN_FORMAT = "[trait value=\"%.2f\" id=\"%d\"]";

-- Format string for denoting a custom trait.
local PS_CUSTOM_FORMAT = "[trait value=\"%.2f\""
	.. " left-name=%q left-icon=%q left-color=%q"
	.. " right-name=%q right-icon=%q right-color=%q"
	.. "]";

local function mrp_ConvertTraits(traits) -- Convert traits from our temporary table containing trait data (personalityTraitsEditor) to appropriate PS field for MSP.
    -- We'll use a temporary table and fill it with strings when making
    -- the resulting string.
    local out = {};

    -- Run over the table of traits.
    for i, trait in ipairs(traits) do
        -- If there's an ID it's a built-in trait, otherwise it's custom
        -- and thus needs the name/icon/color stuff.
        if trait["id"] then
            table.insert(out, PS_BUILTIN_FORMAT:format(
                trait["value"],
                trait["id"]
            ));
        elseif trait["left-name"] and trait["right-name"] then
            -- We'll strip " and ] from the names for simplicity if present.
            table.insert(out, PS_CUSTOM_FORMAT:format(
                trait["value"],
                trait["left-name"]:gsub("[%]=]", ""),
                trait["left-icon"] or "TEMP",
                trait["left-color"] or "ffffff",
                trait["right-name"]:gsub("[%]=]", ""),
                trait["right-icon"] or "TEMP",
                trait["right-color"] or "ffffff"
            ));
        end
    end

    -- Join all the resulting traits into a single string. Add a newline
    -- delimiter; not required but it's nice for debugging.
    return table.concat(out, "\n");
end

local function mrp_SetTraitIcon(selectedTexture, traitIndex, leftRight)
	if(leftRight == "left") then
		personalityTraitsEditor[traitIndex]["left-icon"] = selectedTexture;
	elseif(leftRight == "right") then
		personalityTraitsEditor[traitIndex]["right-icon"] = selectedTexture;
	end
	mrp:ShowTraitEditorBars(personalityTraitsEditor)
end

local function mrp_TraitColourCallback(previousValues, traitIndex, leftRight)
	local rgbColour
	local hexcode
	local newR, newG, newB, newA;
	if previousValues then -- Bail, they hit cancel, restore to previous.
		newR, newG, newB, newA = unpack(previousValues)
		rgbColour = CreateColor(newR, newG, newB, 1)
		hexcode = rgbColour:GenerateHexColorMarkup()
		hexcode = hexcode:match("|cff(%x%x%x%x%x%x)")
		if(leftRight == "left") then
			personalityTraitsEditor[traitIndex]["left-color"] = hexcode
		end
		if(leftRight == "right") then
			personalityTraitsEditor[traitIndex]["right-color"] = hexcode
		end
		mrp:ShowTraitEditorBars(personalityTraitsEditor)
		return;
	else
		-- Something changed
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	-- Insert the colour code into the description box.
	
	local rgbColour = CreateColor(newR, newG, newB, 1)
    local hexcode = rgbColour:GenerateHexColorMarkup()
	hexcode = hexcode:match("|cff(%x%x%x%x%x%x)")
	if(leftRight == "left") then
		personalityTraitsEditor[traitIndex]["left-color"] = hexcode
	end
	if(leftRight == "right") then
		personalityTraitsEditor[traitIndex]["right-color"] = hexcode
	end
	mrp:ShowTraitEditorBars(personalityTraitsEditor)
end

local existingBars = {};

local function hexToRGB(hex)
    return tonumber(hex:sub(1, 2), 16) / 255,
          tonumber(hex:sub(3, 4), 16) / 255,
          tonumber(hex:sub(5, 6), 16) / 255
end

local function mrp_SetTraitName(text, traitIndex, side)
    personalityTraitsEditor[traitIndex][side .. "-name"] = text
end

local function mrp_SubmitTraitName(editbox, traitIndex, side)
  	-- Update the model and clear the OnUpdate script.
    mrp_SetTraitName(editbox:GetText(), traitIndex, side)
  
    editbox:SetScript("OnUpdate", nil)
  	editbox.startTime = nil
  
  	-- Refresh the view.
    mrp:ShowTraitEditorBars(personalityTraitsEditor)
end

local function mrp_DebounceTraitNameUpdates(editbox, traitIndex, side)
    -- Check if enough time hasn't yet passed since we started editing.
    if (GetTime() - editbox.startTime) < 0.2 then -- 200ms
        return
    end

  	-- Enough time passed, submit.
  	return mrp_SubmitTraitName(editbox, traitIndex, side)
end

local function mrp_OnTraitNameChanged(editbox, traitIndex, side)
    -- Don't do anything if the script handler exists, because it means
    -- a submission is still pending.
    if editbox:GetScript("OnUpdate") then
        return
    end

    -- Don't bother doing anything if the name in the table exactly matches
    -- the currently entered name.
      local oldName = personalityTraitsEditor[traitIndex][side .. "-name"]
      local newName = editbox:GetText()
    if oldName == newName then
        return
    end

    -- Record the current time that the text was changed and install the
    -- OnUpdate script handler.
    editbox.startTime = GetTime()
    editbox:SetScript("OnUpdate", function(self)
          mrp_DebounceTraitNameUpdates(self, traitIndex, side)
    end)
end

local function mrp_SubmitPendingEdits()
  	-- Run through each known editor bar and ensure that anything potentially outstanding
  	-- has been submitted.
  	for traitIndex, traitFrame in ipairs(existingBars) do
  		local trait = personalityTraitsEditor[traitIndex]
		if(trait == nil) then
			return;
		end
  		local isCustom = (trait["id"] == nil)
  	
  		if isCustom then
    		-- Submit trait names.
    		mrp_SetTraitName(traitFrame.LeftEditText:GetText(), traitIndex, "left")
    		mrp_SetTraitName(traitFrame.RightEditText:GetText(), traitIndex, "right")
  		end
  	end
end

function mrp:CreateTraitEditorBars(traitIndex) -- Create personality trait editor bars.
    -- Use an outer frame that will contain the icons, font strings, and
    -- the status bar as children. This lets you then resize and anchor
    -- everything in a predictable manner.
    local frame = CreateFrame("Frame")
    frame:SetSize(300, 36)
 
   	-- Left and right icons.
    frame.LeftIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.LeftIcon:SetTexture([[Interface\Buttons\WHITE8X8]])
    frame.LeftIcon:SetSize(frame:GetHeight(), frame:GetHeight())
    frame.LeftIcon:SetPoint("TOPLEFT")
    frame.LeftIcon:SetPoint("BOTTOMLEFT")

    frame.LeftIconButton = CreateFrame("Button", nil, frame)
    frame.LeftIconButton:SetAllPoints(frame.LeftIcon)
    frame.LeftIconButton:SetScript("OnClick", function (self)
        if not personalityTraitsEditor[traitIndex]["id"] then
			mrp_iconselector_show(function(selectedTexture)
				mrp_SetTraitIcon(selectedTexture, traitIndex, "left")
			end, personalityTraitsEditor[traitIndex]["left-icon"])
        end
		MRPIconSelect_ClearIconButton:Hide();
    end)
	
	local leftIconTexture = frame.LeftIconButton:CreateTexture(nil, "OVERLAY")
	leftIconTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
	leftIconTexture:SetAllPoints(frame.LeftIcon)
	leftIconTexture:Hide()
	
	frame.LeftIconButton:SetScript("OnEnter", function (self)
		leftIconTexture:Show()
		frame.LeftValue:SetShown(frame:IsMouseOver())
		frame.RightValue:SetShown(frame:IsMouseOver())
	end )
	frame.LeftIconButton:SetScript("OnLeave", function (self)
		leftIconTexture:Hide()
		frame.LeftValue:SetShown(frame:IsMouseOver())
		frame.RightValue:SetShown(frame:IsMouseOver())
	end )
 
    frame.RightIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.RightIcon:SetTexture([[Interface\Buttons\WHITE8X8]])
    frame.RightIcon:SetSize(frame:GetHeight(), frame:GetHeight())
    frame.RightIcon:SetPoint("TOPRIGHT")
    frame.RightIcon:SetPoint("BOTTOMRIGHT")
 
    frame.RightIconButton = CreateFrame("Button", nil, frame)
    frame.RightIconButton:SetAllPoints(frame.RightIcon)
    frame.RightIconButton:SetScript("OnClick", function (self)
		if not personalityTraitsEditor[traitIndex]["id"] then
			mrp_iconselector_show(function(selectedTexture)
				mrp_SetTraitIcon(selectedTexture, traitIndex, "right")
			end, personalityTraitsEditor[traitIndex]["right-icon"])
        end
		MRPIconSelect_ClearIconButton:Hide();
    end)
	
	local rightIconTexture = frame.RightIconButton:CreateTexture(nil, "OVERLAY")
	rightIconTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
	rightIconTexture:SetAllPoints(frame.RightIcon)
	rightIconTexture:Hide()
	
	frame.RightIconButton:SetScript("OnEnter", function (self)
		rightIconTexture:Show()
		frame.RightValue:SetShown(frame:IsMouseOver())
		frame.LeftValue:SetShown(frame:IsMouseOver())
	end )
	frame.RightIconButton:SetScript("OnLeave", function (self)
		rightIconTexture:Hide()
		frame.RightValue:SetShown(frame:IsMouseOver())
		frame.LeftValue:SetShown(frame:IsMouseOver())
	end )
   
    -- Bar colours
    frame.ColourLeft = CreateFrame("Button", nil, frame)
    frame.ColourLeft:SetPoint( "TOPLEFT", frame.LeftIcon, "BOTTOMRIGHT", 9, -1 )
    frame.ColourLeft:SetHeight(15)
    frame.ColourLeft:SetWidth(15)
	
    frame.ColourLeftTexture = frame.ColourLeft:CreateTexture(nil, "BORDER")
    frame.ColourLeftTexture:SetTexture([[Interface\Buttons\WHITE8X8]])
    frame.ColourLeftTexture:SetAllPoints(frame.ColourLeft)
	
	frame.ColorLeftBorder = frame.ColourLeft:CreateTexture(nil, "ARTWORK")
    frame.ColorLeftBorder:SetTexture([[Interface\PVPFrame\SilverIconBorder]])
    frame.ColorLeftBorder:SetPoint("TOPLEFT", -6, 6)
    frame.ColorLeftBorder:SetPoint("BOTTOMRIGHT", 6, -6)
    
    frame.ColourRight = CreateFrame("Button", nil, frame)
    frame.ColourRight:SetPoint( "TOPRIGHT", frame.RightIcon, "BOTTOMLEFT", -9, -1 )
    frame.ColourRight:SetHeight(15)
    frame.ColourRight:SetWidth(15)

    frame.ColourRightTexture = frame.ColourRight:CreateTexture(nil, "BORDER")
    frame.ColourRightTexture:SetTexture([[Interface\Buttons\WHITE8X8]])
    frame.ColourRightTexture:SetAllPoints(frame.ColourRight)
	
	frame.ColorRightBorder = frame.ColourRight:CreateTexture(nil, "ARTWORK")
    frame.ColorRightBorder:SetTexture([[Interface\PVPFrame\SilverIconBorder]])
    frame.ColorRightBorder:SetPoint("TOPLEFT", -6, 6)
    frame.ColorRightBorder:SetPoint("BOTTOMRIGHT", 6, -6)
    
    frame.ColourLeft:SetScript("OnClick", function (self)
        if not personalityTraitsEditor[traitIndex]["id"] then
        	local r, g, b = hexToRGB(personalityTraitsEditor[traitIndex]["left-color"])
            mrp_ShowColourPicker(r, g, b, 1, function(previousValues)
                mrp_TraitColourCallback(previousValues, traitIndex, "left")
            end)
        end
    end)
    frame.ColourRight:SetScript("OnClick", function (self)
        if not personalityTraitsEditor[traitIndex]["id"] then
            local r, g, b = hexToRGB(personalityTraitsEditor[traitIndex]["right-color"])
            mrp_ShowColourPicker(r, g, b, 1, function(previousValues)
                mrp_TraitColourCallback(previousValues, traitIndex, "right")
            end)
        end
    end)
 
    -- Create the statusbar as a child of the outer frame.
    frame.Bar = CreateFrame("StatusBar", nil, frame)
 
    -- Anchor the bar to go between the icons.
    frame.Bar:SetPoint("LEFT", frame.LeftIcon, "RIGHT", 8, 0)
    frame.Bar:SetPoint("RIGHT", frame.RightIcon, "LEFT", -8, 0)
    frame.Bar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
    frame.Bar:SetPoint("TOP", frame, "CENTER", 0, 1)
 
    -- Default statusbar texture.
    frame.Bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    frame.Bar:SetStatusBarColor(0.2, 0.67, 0.86)
    frame.Bar:SetMinMaxValues(0, 1)
    frame.Bar:SetValue(0.75)
	
	-- Mostly invisible slider for picking the value.
  	-- We overlay this atop the slider bar and give it just a thumb texture so that the slider
  	-- itself is practically invisible, but has something that the user can click and drag with
  	-- their grubby hands.
  	frame.Slider = CreateFrame("Slider", nil, frame.Bar)
  	frame.Slider:SetFrameLevel(frame.Bar:GetFrameLevel() + 1)
  	frame.Slider:SetPoint("TOPLEFT", -16, 0)
  	frame.Slider:SetPoint("BOTTOMRIGHT", 16, 0)
  	frame.Slider:SetHitRectInsets(12, 12, 0, 0)
  	frame.Slider:EnableMouse(true)
  
  	frame.Slider:SetOrientation("HORIZONTAL")
  	frame.Slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
  	frame.Slider:SetValueStep(0.01)
  	frame.Slider:SetStepsPerPage(5)
  	frame.Slider:SetObeyStepOnDrag(true)
	frame.Slider:SetMinMaxValues(0, 1)
  
  	-- Commit the value to the store when modified.
  	frame.Slider:SetScript("OnValueChanged", function(self, newValue)
      	local trait = personalityTraitsEditor[traitIndex]
      	local currentValue = tonumber(trait["value"])
      
      	-- If the difference between our current/new values is too small then
      	-- don't commit the change. This is because we could otherwise in theory
      	-- infinitely loop if the value changes, we store it, and when refreshing
      	-- it's not perfectly identical due to floating point shenanigans.
      	if math.abs(currentValue - newValue) <= 1e-5 then
        	return
        end
      
        trait["value"] = ("%.2f"):format(newValue)
        mrp:ShowTraitEditorBars(personalityTraitsEditor)
    end)
 
    -- Background fill for the bar.
    local barBg = frame.Bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("TOPLEFT")
    barBg:SetPoint("BOTTOMRIGHT")
    barBg:SetTexture(0, 0, 0, 0.4)
 
    -- Textures we use for the border, these are an example, feel free to play.
    local barBorderLeft = frame.Bar:CreateTexture(nil, "ARTWORK")
    barBorderLeft:SetTexture([[Interface\AchievementFrame\UI-Achievement-ProgressBar-Border]])
    barBorderLeft:SetTexCoord(0, 0.0625, 0, 0.75)
    barBorderLeft:SetPoint("TOPLEFT", -6, 5)
    barBorderLeft:SetPoint("BOTTOMLEFT", -6, -5)
    barBorderLeft:SetWidth(16)
 
    local barBorderRight = frame.Bar:CreateTexture(nil, "ARTWORK")
    barBorderRight:SetTexture([[Interface\AchievementFrame\UI-Achievement-ProgressBar-Border]])
    barBorderRight:SetTexCoord(0.812, 0.8745, 0, 0.75)
    barBorderRight:SetPoint("TOPRIGHT", 6, 5)
    barBorderRight:SetPoint("BOTTOMRIGHT", 6, -5)
    barBorderRight:SetWidth(16)
 
    local barBorderCenter = frame.Bar:CreateTexture(nil, "ARTWORK")
    barBorderCenter:SetTexture([[Interface\AchievementFrame\UI-Achievement-ProgressBar-Border]])
    barBorderCenter:SetTexCoord(0.0625, 0.812, 0, 0.75)
    barBorderCenter:SetPoint("TOPLEFT", barBorderLeft, "TOPRIGHT")
    barBorderCenter:SetPoint("BOTTOMRIGHT", barBorderRight, "BOTTOMLEFT")
 
    -- The left fill is the existing texture for the bar.
    frame.LeftFill = frame.Bar:GetStatusBarTexture()
    frame.LeftFill:SetDrawLayer("BORDER", 1)
 
    -- This is the "opposite" fill that'll be on the right side of the bar.
    frame.RightFill = frame.Bar:CreateTexture(nil, "BORDER")
    frame.RightFill:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    frame.RightFill:SetVertexColor(1, 0.46, 0.8)
    frame.RightFill:SetPoint("TOPLEFT", frame.LeftFill, "TOPRIGHT")
    frame.RightFill:SetPoint("BOTTOMLEFT", frame.LeftFill, "BOTTOMRIGHT")
    frame.RightFill:SetPoint("RIGHT")
 
    -- Left and right texts.
    frame.LeftText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.LeftText:SetPoint("TOP")
    frame.LeftText:SetPoint("BOTTOMLEFT", frame.Bar, "TOPLEFT", 0, 4)
    frame.LeftText:SetPoint("BOTTOMRIGHT", frame.Bar, "TOP", 0, 4)
    frame.LeftText:SetJustifyH("LEFT")
    frame.LeftText:SetJustifyV("MIDDLE")
    frame.LeftText:SetShadowColor(0, 0, 0)
    frame.LeftText:SetShadowOffset(1, -1)
	
	frame.LeftEditText = CreateFrame( "EditBox", nil, frame )
	frame.LeftEditText:SetBackdrop(	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = { left = 5, right = 3, top = 3, bottom = 3	},
	} )
	frame.LeftEditText:SetPoint( "BOTTOMLEFT", frame.Bar, "TOPLEFT", -4, 1 )
	frame.LeftEditText:SetPoint( "BOTTOMRIGHT", frame.Bar, "TOP", 0, 5)
	frame.LeftEditText:SetHeight( 25 )
	frame.LeftEditText:SetWidth( 300 )
	frame.LeftEditText:SetTextInsets( 7, 7, 0, 0 )
	frame.LeftEditText:EnableMouse(true)
	frame.LeftEditText:SetAutoFocus(false)
	frame.LeftEditText:SetMultiLine(false)
	frame.LeftEditText:SetFontObject( "GameFontHighlight" )
  
	frame.LeftEditText:SetScript( "OnEscapePressed", EditBox_ClearFocus )
  	frame.LeftEditText:SetScript("OnTextChanged", function(self)
      	mrp_OnTraitNameChanged(self, traitIndex, "left")
    end)
   
    frame.RightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.RightText:SetPoint("TOP")
    frame.RightText:SetPoint("BOTTOMLEFT", frame.Bar, "TOP", 0, 4)
    frame.RightText:SetPoint("BOTTOMRIGHT", frame.Bar, "TOPRIGHT", 0, 4)
    frame.RightText:SetJustifyH("RIGHT")
    frame.RightText:SetJustifyV("MIDDLE")
    frame.RightText:SetShadowColor(0, 0, 0)
    frame.RightText:SetShadowOffset(1, -1)
	
	frame.RightEditText = CreateFrame( "EditBox", nil, frame )
	frame.RightEditText:SetBackdrop(	{
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = { left = 5, right = 3, top = 3, bottom = 3	},
	} )
	frame.RightEditText:SetPoint( "BOTTOMLEFT", frame.Bar, "TOP", 0, 1 )
	frame.RightEditText:SetPoint( "BOTTOMRIGHT", frame.Bar, "TOPRIGHT", 4, 3)
	frame.RightEditText:SetHeight( 25 )
	frame.RightEditText:SetWidth( 300 )
	frame.RightEditText:SetTextInsets( 7, 7, 0, 0 )
	frame.RightEditText:EnableMouse(true)
	frame.RightEditText:SetAutoFocus(false)
	frame.RightEditText:SetMultiLine(false)
	frame.RightEditText:SetFontObject( "GameFontHighlight" )
	frame.RightEditText:SetJustifyH("RIGHT")

	frame.RightEditText:SetScript( "OnEscapePressed", EditBox_ClearFocus )
  	frame.RightEditText:SetScript("OnTextChanged", function(self)
      	mrp_OnTraitNameChanged(self, traitIndex, "right")
    end)
   
    -- Left and right values.
    frame.LeftValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.LeftValue:SetPoint("BOTTOMLEFT", frame.LeftIcon, "TOPLEFT", 0, 4)
    frame.LeftValue:SetJustifyH("LEFT")
    frame.LeftValue:SetJustifyV("MIDDLE")
    frame.LeftValue:SetShadowColor(0, 0, 0)
    frame.LeftValue:SetShadowOffset(1, -1)
	frame.LeftValue:Hide()
   
    frame.RightValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.RightValue:SetPoint("BOTTOMRIGHT", frame.RightIcon, "TOPRIGHT", 0, 4)
    frame.RightValue:SetJustifyH("RIGHT")
    frame.RightValue:SetJustifyV("MIDDLE")
    frame.RightValue:SetShadowColor(0, 0, 0)
    frame.RightValue:SetShadowOffset(1, -1)
	frame.RightValue:Hide()
	
	local updateTextVisibility = function()
		local isMouseOver = frame:IsMouseOver()
		frame.LeftValue:SetShown(isMouseOver)
		frame.RightValue:SetShown(isMouseOver)
	end

	frame:SetScript("OnEnter", updateTextVisibility)
	frame:SetScript("OnLeave", updateTextVisibility)
	frame.Slider:SetScript("OnEnter", updateTextVisibility)
	frame.Slider:SetScript("OnLeave", updateTextVisibility)
	frame.LeftEditText:SetScript("OnEnter", updateTextVisibility)
	frame.LeftEditText:SetScript("OnLeave", updateTextVisibility)
	frame.RightEditText:SetScript("OnEnter", updateTextVisibility)
	frame.RightEditText:SetScript("OnLeave", updateTextVisibility)
   
    frame.Delete = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.Delete:SetPoint("LEFT", frame.RightIcon, "RIGHT", 2, 0)
    frame.Delete:SetScript("OnClick", function (self)
        table.remove(personalityTraitsEditor, traitIndex)
        mrp:ShowTraitEditorBars(personalityTraitsEditor)
    end )
    frame.Delete:SetScript( "OnEnter", function(self)
        GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
        GameTooltip:SetText( L["editor_deletetrait"], 1.0, 1.0, 1.0 )
    end )
    frame.Delete:SetScript( "OnLeave", GameTooltip_Hide )
   
   
   
    -- The returned frame will have Left/RightIcon textures, a Bar statusbar,
    -- and a Left/RightFill texture. You can set the colors/icon paths/values
    -- on these as needed.
    return frame
end

function mrp:UpdateTraitEditorBars(traitIndex, trait)
  	-- True if this is a custom trait.
	local isCustom = (trait["id"] == nil)
  
     -- TODO: Set the value, texts, etc.
    local percent = math.floor(trait["value"] * 100);
	
	local frame = existingBars[traitIndex]
    frame.LeftValue:SetText(("%d%%"):format(percent))
    frame.RightValue:SetText(("%d%%"):format(100 - percent))
    frame.Bar:SetValue(trait["value"])
	frame.Slider:SetValue(trait["value"])
  
  	-- Show/hide the custom colour pickers if this is a custom trait.
    frame.ColourLeft:SetShown(isCustom)
    frame.ColourRight:SetShown(isCustom)
	frame.LeftEditText:SetShown(isCustom)
	frame.LeftText:SetShown(not isCustom)
	frame.RightEditText:SetShown(isCustom)
	frame.RightText:SetShown(not isCustom)
	frame.LeftIconButton:SetShown(isCustom)
	frame.RightIconButton:SetShown(isCustom)
  
  	if not isCustom then
        local traitID = tonumber(trait["id"])
        frame.LeftIcon:SetTexture("Interface\\Icons\\" .. defaultTraitsMapping[traitID]["LI"])
        frame.RightIcon:SetTexture("Interface\\Icons\\" .. defaultTraitsMapping[traitID]["RI"])
        frame.LeftText:SetText(defaultTraitsMapping[traitID]["LT"])
        frame.RightText:SetText(defaultTraitsMapping[traitID]["RT"])
		frame.Bar:SetStatusBarColor(0.2, 0.67, 0.86)
		frame.RightFill:SetVertexColor(1, 0.46, 0.8)
    else
        frame.LeftIcon:SetTexture("Interface\\Icons\\" .. trait["left-icon"])
        frame.RightIcon:SetTexture("Interface\\Icons\\" .. trait["right-icon"])
        frame.LeftEditText:SetText(trait["left-name"])
        frame.RightEditText:SetText(trait["right-name"])
   
    	frame.ColourLeftTexture:SetVertexColor(hexToRGB(trait["left-color"]))
		frame.LeftFill:SetVertexColor(hexToRGB(trait["left-color"]))
    
    	frame.ColourRightTexture:SetVertexColor(hexToRGB(trait["right-color"]))
        frame.RightFill:SetVertexColor(hexToRGB(trait["right-color"]))
    end
end
 
function mrp:ShowTraitEditorBars(traits) -- Show / adjust personality trait bars.
    -- Grab the outer scrollframe and its child panel.
    local scrollFrame = MyRolePlayTraitsEditScrollFrame
    local scrollChild = scrollFrame:GetScrollChild()
 
    -- We'll record the total height of the traits we display.
    local scrollHeight = 0
 
    -- Loop over the traits for this profile.
    for i, trait in ipairs(traits) do
        -- Recycle or create the bar frame. We want to recycle bars because
        -- creating them from scratch is expensive, and if we don't keep a
        -- history of the bars we've made then we'd  have no way to hide them.
        local frame = existingBars[i] or mrp:CreateTraitEditorBars(i)
        existingBars[i] = frame
    
    	-- Update the bar with data from this trait.
    	mrp:UpdateTraitEditorBars(i, trait)
       
        frame:SetParent(scrollChild)
        frame:Show()
 
        -- Make each bar anchor to the bottom left of the previous; unless
        -- it's the first in which case use the scroll child.
        local relFrame = (i == 1) and scrollChild or existingBars[i - 1]
        local relPoint = (i == 1) and "TOP" or "BOTTOM"
        local offsetX = (i == 1) and 16 or 0
        local offsetY = 24
 
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", relFrame, relPoint .. "LEFT", offsetX, -offsetY)
        frame:SetPoint("TOPRIGHT", relFrame, relPoint .. "RIGHT", -offsetX, -offsetY)
 
        -- Accumulate the scrollable region height with the height of the
        -- frame and its vertical offset thrown in.
        scrollHeight = scrollHeight + frame:GetHeight() + offsetY;
    end
 
    -- Hide any extraneous bars, for example if you go from viewing a profile with
    -- 6 traits to just 3 you'll wanna hide bars #4 through #6.
    for i = #traits + 1, #existingBars do
        existingBars[i]:Hide()
    end
 
    -- Ensure the scrollchild is positioned and sized appropriately.
    scrollChild:SetParent(scrollFrame)
    if scrollChild:GetNumPoints() == 0 then
        scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
    end

    scrollChild:SetHeight(scrollHeight)
    scrollChild:SetWidth(300)
end

----------------
-- Dropdowns
----------------
local function mrp_AddTrait(dropdownTable, traitID) -- Add a trait from the menu. Standard traits will use traitIDs from the table, custom ones will setup additional attributes.
	if(traitID >= 1) then
		for k, v in pairs(personalityTraitsEditor) do
			if(v["id"] and v["id"] == tostring(traitID)) then
				mrp:Print("You can't add two of the same trait.")
				return;
			end
		end
		table.insert(personalityTraitsEditor, {id = tostring(traitID), value = "0.5"})
	else
		table.insert(personalityTraitsEditor, {["left-name"] = "Trait1", ["right-name"] = "Trait2", ["left-icon"] = "INV_MISC_QUESTIONMARK", ["right-icon"] = "INV_MISC_QUESTIONMARK", ["left-color"] = "33AADD", ["right-color"] = "FF77CC", value = "0.5"})
	end
	mrp:ShowTraitEditorBars(personalityTraitsEditor)
end

local function mrp_AddTraitDropdown(frame, level, menuList) -- 1 - 11 (Or more if added to defaultTraitsMapping table) = Default TRP traits. Custom added below as integer 0.
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, #defaultTraitsMapping, 1 do
		info.text, info.func, info.arg1, info.notCheckable = defaultTraitsMapping[i]["LT"] .. " <=> " .. defaultTraitsMapping[i]["RT"], mrp_AddTrait, i, true
		UIDropDownMenu_AddButton(info)
	end
	info.text, info.func, info.arg1 = L["editor_customtrait"], mrp_AddTrait, 0
	UIDropDownMenu_AddButton(info)
end

local function mrp_AddHeader(dropdownTable, alignment, size) -- Add a header, choosing alignment from the menu. Alignment will be "Left", "Centre", or "Right".
	if(alignment == "Left") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{h" .. size .. "}YourTextHere{/h" .. size .. "}")
	elseif(alignment == "Centre") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{h" .. size .. ":c}YourTextHere{/h" .. size .. "}")
	elseif(alignment == "Right") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{h" .. size .. ":r}YourTextHere{/h" .. size .. "}")
	end
	MyRolePlayMultiEditFrame_EditBox:SetCursorPosition(MyRolePlayMultiEditFrame_EditBox:GetCursorPosition() - 5)
	MyRolePlayMultiEditFrame_EditBox:HighlightText((MyRolePlayMultiEditFrame_EditBox:GetCursorPosition() - 12), MyRolePlayMultiEditFrame_EditBox:GetCursorPosition())
end

local function mrp_AddHeaderDropdown(frame, level, menuList)
	local size = {
		[1] = "Large headers",
		[2] = "Medium headers",
		[3] = "Small headers"
	}
	local info = UIDropDownMenu_CreateInfo()
	for i = 1, 3, 1 do
		info.text, info.isTitle, info.notCheckable = size[i], true, true
		UIDropDownMenu_AddButton(info)
	
		info.text, info.func, info.arg1, info.arg2, info.notCheckable, info.isTitle, info.disabled = "Left Alignment", mrp_AddHeader, "Left", i, true, false, false -- Add left alignment header option
		UIDropDownMenu_AddButton(info)
	
		info.text, info.func, info.arg1, info.arg2, info.notCheckable = "Centre Alignment", mrp_AddHeader, "Centre", i, true -- Add centre alignment header option
		UIDropDownMenu_AddButton(info)
	
		info.text, info.func, info.arg1, info.arg2, info.notCheckable = "Right Alignment", mrp_AddHeader, "Right", i, true -- Add right alignment header option
		UIDropDownMenu_AddButton(info)
	end
end

local function mrp_AddParagraph(dropdownTable, alignment) -- Add a header, choosing alignment from the menu. Alignment will be "Left", "Centre", or "Right".
	if(alignment == "Left") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{p}YourTextHere{/p}")
	elseif(alignment == "Centre") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{p:c}YourTextHere{/p}")
	elseif(alignment == "Right") then
		MyRolePlayMultiEditFrame_EditBox:Insert("{p:r}YourTextHere{/p}")
	end
	MyRolePlayMultiEditFrame_EditBox:SetCursorPosition(MyRolePlayMultiEditFrame_EditBox:GetCursorPosition() - 4)
	MyRolePlayMultiEditFrame_EditBox:HighlightText((MyRolePlayMultiEditFrame_EditBox:GetCursorPosition() - 12), MyRolePlayMultiEditFrame_EditBox:GetCursorPosition())
end

local function mrp_AddParagraphDropdown(frame, level, menuList)
	local info = UIDropDownMenu_CreateInfo()
	info.text, info.func, info.arg1, info.arg2, info.notCheckable = "Left Alignment", mrp_AddParagraph, "Left", i, true -- Add left alignment paragraph option
	UIDropDownMenu_AddButton(info)
	
	info.text, info.func, info.arg1, info.arg2, info.notCheckable = "Centre Alignment", mrp_AddParagraph, "Centre", i, true -- Add centre alignment paragraph option
	UIDropDownMenu_AddButton(info)
	
	info.text, info.func, info.arg1, info.arg2, info.notCheckable = "Right Alignment", mrp_AddParagraph, "Right", i, true -- Add right alignment paragraph option
	UIDropDownMenu_AddButton(info)
end
-----------------------------------------

-- Create the EditFrames to sit alongside MyRolePlayCharacterFrame
function mrp:CreateEditFrames()
	-- MyRolePlayGlanceEditFrame
	if not MyRolePlayGlanceEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayGlanceEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -20 )
		mef:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 752 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)

		mef:EnableDrawLayer("OVERLAY")
		
		----------------------------------
		-- Glance 1
		----------------------------------
		
		mef.Glance1Icon = CreateFrame("Frame", "Glance1Icon", mef)
		mef.Glance1Icon:SetPoint( "TOPLEFT", MyRolePlayGlanceEditFrame, "TOPLEFT", 5, -15 )
		mef.Glance1Icon:SetHeight(64)
		mef.Glance1Icon:SetWidth(64)
		local glance1IconTexture = mef.Glance1Icon:CreateTexture("Glance1IconTexture", "ARTWORK")
		glance1IconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		glance1IconTexture:SetAllPoints(mef.Glance1Icon)
		
		local glance1IconHighlightTexture = mef.Glance1Icon:CreateTexture("Glance1IconHighlightTexture", "OVERLAY")
		glance1IconHighlightTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		glance1IconHighlightTexture:SetAllPoints(mef.Glance1Icon)
		glance1IconHighlightTexture:Hide()
		
		mef.Glance1Icon:SetScript("OnMouseDown", function (self)
			mrp_iconselector_show(mrp_IconCallbackGlance1Icon, mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][1]["Icon"] or nil)
		end )
		
		mef.Glance1Icon:SetScript("OnEnter", function (self)
			glance1IconHighlightTexture:Show()
		end )
		
		mef.Glance1Icon:SetScript("OnLeave", function (self)
			glance1IconHighlightTexture:Hide()
		end )


		mef.Glance1Title = CreateFrame( "EditBox", "Glance1Title", mef )
		mef.Glance1Title:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance1Title:SetPoint( "TOPLEFT", mef.Glance1Icon, "TOPRIGHT", 3, 0 )
		mef.Glance1Title:SetHeight( 25 )
		mef.Glance1Title:SetWidth( 280 )
		mef.Glance1Title:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance1Title:EnableMouse(true)
		mef.Glance1Title:SetAutoFocus(false)
		mef.Glance1Title:SetMultiLine(false)
		mef.Glance1Title:SetFontObject( "GameFontHighlight" )

		mef.Glance1Title:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		mef.Glance1Descrip = CreateFrame( "ScrollFrame", "Glance1Descrip", mef, "UIPanelScrollFrameTemplate" )
		
		mef.Glance1Descrip.scrollBarHideable = false
		
		mef.Glance1Descrip.Backdrop = CreateFrame("Frame", "Glance1DescripBackdrop", mef)
		mef.Glance1Descrip.Backdrop:SetPoint( "TOPLEFT", Glance1Title, "BOTTOMLEFT", 0, 3)
		mef.Glance1Descrip.Backdrop:SetPoint( "BOTTOMRIGHT", Glance1Title, "BOTTOMRIGHT", -5, -40)
		mef.Glance1Descrip.Backdrop:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance1Descrip:SetPoint( "TOPLEFT", Glance1Title, "BOTTOMLEFT", 0, -5)
		mef.Glance1Descrip:SetPoint( "BOTTOMRIGHT", Glance1Title, "BOTTOMRIGHT", -10, -30)
		mef.Glance1Descrip:EnableMouse(true)

		mef.Glance1Descrip.scrollBarHideable = false

		mef.Glance1Descrip.editbox = CreateFrame( "EditBox", nil, sf )
		mef.Glance1Descrip.editbox:SetPoint( "TOPLEFT", 10, 10 )
		mef.Glance1Descrip.editbox:SetPoint( "BOTTOMRIGHT", 10, 0 )
		mef.Glance1Descrip.editbox:SetHeight( 325 )
		mef.Glance1Descrip.editbox:SetWidth( 280 )
		mef.Glance1Descrip.editbox:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance1Descrip.editbox:EnableMouse(true)
		mef.Glance1Descrip.editbox:SetAutoFocus(false)
		mef.Glance1Descrip.editbox:SetMultiLine(true)
		mef.Glance1Descrip.editbox:SetFontObject( "GameFontHighlight" )
		mef.Glance1Descrip:SetScrollChild( mef.Glance1Descrip.editbox )


		mef.Glance1Descrip.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.Glance1Descrip.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.Glance1Descrip.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.Glance1Descrip.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(Glance1Descrip)
		
		-- FontString Title / Details
		
		mef.glance1header = mef:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		mef.glance1header:SetJustifyH( "LEFT" )
		mef.glance1header:SetJustifyV( "TOP" )
		mef.glance1header:SetPoint( "BOTTOMLEFT", mef.Glance1Title, "TOPLEFT", 3, 1 )
		mef.glance1header:SetText( L["editor_glance_headers"] )
		
		-- Clear glance button
		mef.Glance1Clear = CreateFrame( "Button", "Glance1ClearButton", mef, uipbt )
		mef.Glance1Clear:SetPoint( "LEFT", mef.Glance1Title, "RIGHT", -5, 2 )
		mef.Glance1Clear:SetText( L["C"] )
		mef.Glance1Clear:SetWidth( 20 )
		mef.Glance1Clear:SetFrameStrata("HIGH")
		mef.Glance1Clear:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_glanceclear_button"], 1.0, 1.0, 1.0 )
		end )
		mef.Glance1Clear:SetScript( "OnLeave", GameTooltip_Hide )
		mef.Glance1Clear:SetScript("OnClick", function (self)
			mrp:ClearGlance(1)
		end )
		
		-------------------------------
		-- Glance 2
		-------------------------------
		
		mef.Glance2Icon = CreateFrame("Frame", "Glance2Icon", mef)
		mef.Glance2Icon:SetPoint( "TOPLEFT", mef.Glance1Icon, "BOTTOMLEFT", 0, -10 )
		mef.Glance2Icon:SetHeight(64)
		mef.Glance2Icon:SetWidth(64)
		local glance2IconTexture = mef.Glance2Icon:CreateTexture("Glance2IconTexture", "ARTWORK")
		glance2IconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		glance2IconTexture:SetAllPoints(mef.Glance2Icon)
		mef.Glance2Icon:SetScript("OnMouseDown", function (self)
			mrp_iconselector_show(mrp_IconCallbackGlance2Icon, mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][2]["Icon"] or nil)
		end )
		
		local glance2IconHighlightTexture = mef.Glance2Icon:CreateTexture("Glance2IconHighlightTexture", "OVERLAY")
		glance2IconHighlightTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		glance2IconHighlightTexture:SetAllPoints(mef.Glance2Icon)
		glance2IconHighlightTexture:Hide()
		
		mef.Glance2Icon:SetScript("OnEnter", function (self)
			glance2IconHighlightTexture:Show()
		end )
		
		mef.Glance2Icon:SetScript("OnLeave", function (self)
			glance2IconHighlightTexture:Hide()
		end )

		mef.Glance2Title = CreateFrame( "EditBox", "Glance2Title", mef )
		mef.Glance2Title:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance2Title:SetPoint( "TOPLEFT", mef.Glance2Icon, "TOPRIGHT", 3, 0 )
		mef.Glance2Title:SetHeight( 25 )
		mef.Glance2Title:SetWidth( 280 )
		mef.Glance2Title:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance2Title:EnableMouse(true)
		mef.Glance2Title:SetAutoFocus(false)
		mef.Glance2Title:SetMultiLine(false)
		mef.Glance2Title:SetFontObject( "GameFontHighlight" )

		mef.Glance2Title:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		mef.Glance2Descrip = CreateFrame( "ScrollFrame", "Glance2Descrip", mef, "UIPanelScrollFrameTemplate" )
		
		mef.Glance2Descrip.scrollBarHideable = false
		
		mef.Glance2Descrip.Backdrop = CreateFrame("Frame", "Glance2DescripBackdrop", mef)
		mef.Glance2Descrip.Backdrop:SetPoint( "TOPLEFT", Glance2Title, "BOTTOMLEFT", 0, 3)
		mef.Glance2Descrip.Backdrop:SetPoint( "BOTTOMRIGHT", Glance2Title, "BOTTOMRIGHT", -5, -40)
		mef.Glance2Descrip.Backdrop:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance2Descrip:SetPoint( "TOPLEFT", Glance2Title, "BOTTOMLEFT", 0, -5)
		mef.Glance2Descrip:SetPoint( "BOTTOMRIGHT", Glance2Title, "BOTTOMRIGHT", -10, -30)
		mef.Glance2Descrip:EnableMouse(true)

		mef.Glance2Descrip.scrollBarHideable = false

		mef.Glance2Descrip.editbox = CreateFrame( "EditBox", nil, sf )
		mef.Glance2Descrip.editbox:SetPoint( "TOPLEFT", 10, 10 )
		mef.Glance2Descrip.editbox:SetPoint( "BOTTOMRIGHT", 10, 0 )
		mef.Glance2Descrip.editbox:SetHeight( 325 )
		mef.Glance2Descrip.editbox:SetWidth( 280 )
		mef.Glance2Descrip.editbox:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance2Descrip.editbox:EnableMouse(true)
		mef.Glance2Descrip.editbox:SetAutoFocus(false)
		mef.Glance2Descrip.editbox:SetMultiLine(true)
		mef.Glance2Descrip.editbox:SetFontObject( "GameFontHighlight" )
		mef.Glance2Descrip:SetScrollChild( mef.Glance2Descrip.editbox )


		mef.Glance2Descrip.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.Glance2Descrip.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.Glance2Descrip.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.Glance2Descrip.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(Glance2Descrip)
		
		-- FontString Title / Details
		
		mef.glance2header = mef:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		mef.glance2header:SetJustifyH( "LEFT" )
		mef.glance2header:SetJustifyV( "TOP" )
		mef.glance2header:SetPoint( "BOTTOMLEFT", mef.Glance2Title, "TOPLEFT", 3, 0 )
		mef.glance2header:SetText( L["editor_glance_headers"] )
		
		-- Clear glance button
		mef.Glance2Clear = CreateFrame( "Button", "Glance2ClearButton", mef, uipbt )
		mef.Glance2Clear:SetPoint( "LEFT", mef.Glance2Title, "RIGHT", -5, 2 )
		mef.Glance2Clear:SetText( L["C"] )
		mef.Glance2Clear:SetWidth( 20 )
		mef.Glance2Clear:SetFrameStrata("HIGH")
		mef.Glance2Clear:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_glanceclear_button"], 1.0, 1.0, 1.0 )
		end )
		mef.Glance2Clear:SetScript( "OnLeave", GameTooltip_Hide )
		mef.Glance2Clear:SetScript("OnClick", function (self)
			mrp:ClearGlance(2)
		end )
		
		---------------------------------
		-- Glance 3
		---------------------------------
		
		mef.Glance3Icon = CreateFrame("Frame", "Glance3Icon", mef)
		mef.Glance3Icon:SetPoint( "TOPLEFT", mef.Glance2Icon, "BOTTOMLEFT", 0, -10 )
		mef.Glance3Icon:SetHeight(64)
		mef.Glance3Icon:SetWidth(64)
		local glance3IconTexture = mef.Glance3Icon:CreateTexture("Glance3IconTexture", "ARTWORK")
		glance3IconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		glance3IconTexture:SetAllPoints(mef.Glance3Icon)
		mef.Glance3Icon:SetScript("OnMouseDown", function (self)
			mrp_iconselector_show(mrp_IconCallbackGlance3Icon, mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][3]["Icon"] or nil)
		end )
		
		local glance3IconHighlightTexture = mef.Glance3Icon:CreateTexture("Glance3IconHighlightTexture", "OVERLAY")
		glance3IconHighlightTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		glance3IconHighlightTexture:SetAllPoints(mef.Glance3Icon)
		glance3IconHighlightTexture:Hide()
		
		mef.Glance3Icon:SetScript("OnEnter", function (self)
			glance3IconHighlightTexture:Show()
		end )
		
		mef.Glance3Icon:SetScript("OnLeave", function (self)
			glance3IconHighlightTexture:Hide()
		end )

		mef.Glance3Title = CreateFrame( "EditBox", "Glance3Title", mef )
		mef.Glance3Title:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance3Title:SetPoint( "TOPLEFT", mef.Glance3Icon, "TOPRIGHT", 3, 0 )
		mef.Glance3Title:SetHeight( 25 )
		mef.Glance3Title:SetWidth( 280 )
		mef.Glance3Title:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance3Title:EnableMouse(true)
		mef.Glance3Title:SetAutoFocus(false)
		mef.Glance3Title:SetMultiLine(false)
		mef.Glance3Title:SetFontObject( "GameFontHighlight" )

		mef.Glance3Title:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		mef.Glance3Descrip = CreateFrame( "ScrollFrame", "Glance3Descrip", mef, "UIPanelScrollFrameTemplate" )
		
		mef.Glance3Descrip.scrollBarHideable = false
		
		mef.Glance3Descrip.Backdrop = CreateFrame("Frame", "Glance3DescripBackdrop", mef)
		mef.Glance3Descrip.Backdrop:SetPoint( "TOPLEFT", Glance3Title, "BOTTOMLEFT", 0, 3)
		mef.Glance3Descrip.Backdrop:SetPoint( "BOTTOMRIGHT", Glance3Title, "BOTTOMRIGHT", -5, -40)
		mef.Glance3Descrip.Backdrop:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance3Descrip:SetPoint( "TOPLEFT", Glance3Title, "BOTTOMLEFT", 0, -5)
		mef.Glance3Descrip:SetPoint( "BOTTOMRIGHT", Glance3Title, "BOTTOMRIGHT", -10, -30)
		mef.Glance3Descrip:EnableMouse(true)

		mef.Glance3Descrip.scrollBarHideable = false

		mef.Glance3Descrip.editbox = CreateFrame( "EditBox", nil, sf )
		mef.Glance3Descrip.editbox:SetPoint( "TOPLEFT", 10, 10 )
		mef.Glance3Descrip.editbox:SetPoint( "BOTTOMRIGHT", 10, 0 )
		mef.Glance3Descrip.editbox:SetHeight( 325 )
		mef.Glance3Descrip.editbox:SetWidth( 280 )
		mef.Glance3Descrip.editbox:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance3Descrip.editbox:EnableMouse(true)
		mef.Glance3Descrip.editbox:SetAutoFocus(false)
		mef.Glance3Descrip.editbox:SetMultiLine(true)
		mef.Glance3Descrip.editbox:SetFontObject( "GameFontHighlight" )
		mef.Glance3Descrip:SetScrollChild( mef.Glance3Descrip.editbox )


		mef.Glance3Descrip.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.Glance3Descrip.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.Glance3Descrip.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.Glance3Descrip.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(Glance3Descrip)
		
		-- FontString Title / Details
		
		mef.glance3header = mef:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		mef.glance3header:SetJustifyH( "LEFT" )
		mef.glance3header:SetJustifyV( "TOP" )
		mef.glance3header:SetPoint( "BOTTOMLEFT", mef.Glance3Title, "TOPLEFT", 3, 0 )
		mef.glance3header:SetText( L["editor_glance_headers"] )
		
		-- Clear glance button
		mef.Glance3Clear = CreateFrame( "Button", "Glance3ClearButton", mef, uipbt )
		mef.Glance3Clear:SetPoint( "LEFT", mef.Glance3Title, "RIGHT", -5, 2 )
		mef.Glance3Clear:SetText( L["C"] )
		mef.Glance3Clear:SetWidth( 20 )
		mef.Glance3Clear:SetFrameStrata("HIGH")
		mef.Glance3Clear:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_glanceclear_button"], 1.0, 1.0, 1.0 )
		end )
		mef.Glance3Clear:SetScript( "OnLeave", GameTooltip_Hide )
		mef.Glance3Clear:SetScript("OnClick", function (self)
			mrp:ClearGlance(3)
		end )
		
		------------------------------------
		-- Glance 4
		------------------------------------
		
		mef.Glance4Icon = CreateFrame("Frame", "Glance4Icon", mef)
		mef.Glance4Icon:SetPoint( "TOPLEFT", mef.Glance3Icon, "BOTTOMLEFT", 0, -10 )
		mef.Glance4Icon:SetHeight(64)
		mef.Glance4Icon:SetWidth(64)
		local glance4IconTexture = mef.Glance4Icon:CreateTexture("Glance4IconTexture", "ARTWORK")
		glance4IconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		glance4IconTexture:SetAllPoints(mef.Glance4Icon)
		mef.Glance4Icon:SetScript("OnMouseDown", function (self)
			mrp_iconselector_show(mrp_IconCallbackGlance4Icon, mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][4]["Icon"] or nil)
		end )
		
		local glance4IconHighlightTexture = mef.Glance4Icon:CreateTexture("Glance4IconHighlightTexture", "OVERLAY")
		glance4IconHighlightTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		glance4IconHighlightTexture:SetAllPoints(mef.Glance4Icon)
		glance4IconHighlightTexture:Hide()
		
		mef.Glance4Icon:SetScript("OnEnter", function (self)
			glance4IconHighlightTexture:Show()
		end )
		
		mef.Glance4Icon:SetScript("OnLeave", function (self)
			glance4IconHighlightTexture:Hide()
		end )

		mef.Glance4Title = CreateFrame( "EditBox", "Glance4Title", mef )
		mef.Glance4Title:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance4Title:SetPoint( "TOPLEFT", mef.Glance4Icon, "TOPRIGHT", 3, 0 )
		mef.Glance4Title:SetHeight( 25 )
		mef.Glance4Title:SetWidth( 280 )
		mef.Glance4Title:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance4Title:EnableMouse(true)
		mef.Glance4Title:SetAutoFocus(false)
		mef.Glance4Title:SetMultiLine(false)
		mef.Glance4Title:SetFontObject( "GameFontHighlight" )

		mef.Glance4Title:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		mef.Glance4Descrip = CreateFrame( "ScrollFrame", "Glance4Descrip", mef, "UIPanelScrollFrameTemplate" )
		
		mef.Glance4Descrip.scrollBarHideable = false
		
		mef.Glance4Descrip.Backdrop = CreateFrame("Frame", "Glance4DescripBackdrop", mef)
		mef.Glance4Descrip.Backdrop:SetPoint( "TOPLEFT", Glance4Title, "BOTTOMLEFT", 0, 3)
		mef.Glance4Descrip.Backdrop:SetPoint( "BOTTOMRIGHT", Glance4Title, "BOTTOMRIGHT", -5, -40)
		mef.Glance4Descrip.Backdrop:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance4Descrip:SetPoint( "TOPLEFT", Glance4Title, "BOTTOMLEFT", 0, -5)
		mef.Glance4Descrip:SetPoint( "BOTTOMRIGHT", Glance4Title, "BOTTOMRIGHT", -10, -30)
		mef.Glance4Descrip:EnableMouse(true)

		mef.Glance4Descrip.scrollBarHideable = false

		mef.Glance4Descrip.editbox = CreateFrame( "EditBox", nil, sf )
		mef.Glance4Descrip.editbox:SetPoint( "TOPLEFT", 10, 10 )
		mef.Glance4Descrip.editbox:SetPoint( "BOTTOMRIGHT", 10, 0 )
		mef.Glance4Descrip.editbox:SetHeight( 325 )
		mef.Glance4Descrip.editbox:SetWidth( 280 )
		mef.Glance4Descrip.editbox:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance4Descrip.editbox:EnableMouse(true)
		mef.Glance4Descrip.editbox:SetAutoFocus(false)
		mef.Glance4Descrip.editbox:SetMultiLine(true)
		mef.Glance4Descrip.editbox:SetFontObject( "GameFontHighlight" )
		mef.Glance4Descrip:SetScrollChild( mef.Glance4Descrip.editbox )


		mef.Glance4Descrip.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.Glance4Descrip.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.Glance4Descrip.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.Glance4Descrip.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(Glance4Descrip)
		
		-- FontString Title / Details
		
		mef.glance4header = mef:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		mef.glance4header:SetJustifyH( "LEFT" )
		mef.glance4header:SetJustifyV( "TOP" )
		mef.glance4header:SetPoint( "BOTTOMLEFT", mef.Glance4Title, "TOPLEFT", 3, 0 )
		mef.glance4header:SetText( L["editor_glance_headers"] )
		
		-- Clear glance button
		mef.Glance4Clear = CreateFrame( "Button", "Glance4ClearButton", mef, uipbt )
		mef.Glance4Clear:SetPoint( "LEFT", mef.Glance4Title, "RIGHT", -5, 2 )
		mef.Glance4Clear:SetText( L["C"] )
		mef.Glance4Clear:SetWidth( 20 )
		mef.Glance4Clear:SetFrameStrata("HIGH")
		mef.Glance4Clear:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_glanceclear_button"], 1.0, 1.0, 1.0 )
		end )
		mef.Glance4Clear:SetScript( "OnLeave", GameTooltip_Hide )
		mef.Glance4Clear:SetScript("OnClick", function (self)
			mrp:ClearGlance(4)
		end )
		
		--------------------------------
		-- Glance 5
		--------------------------------
		
		mef.Glance5Icon = CreateFrame("Frame", "Glance5Icon", mef)
		mef.Glance5Icon:SetPoint( "TOPLEFT", mef.Glance4Icon, "BOTTOMLEFT", 0, -10 )
		mef.Glance5Icon:SetHeight(64)
		mef.Glance5Icon:SetWidth(64)
		local glance5IconTexture = mef.Glance3Icon:CreateTexture("Glance5IconTexture", "ARTWORK")
		glance5IconTexture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		glance5IconTexture:SetAllPoints(mef.Glance5Icon)
		mef.Glance5Icon:SetScript("OnMouseDown", function (self)
			mrp_iconselector_show(mrp_IconCallbackGlance5Icon, mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][5]["Icon"] or nil)
		end )
		
		local glance5IconHighlightTexture = mef.Glance5Icon:CreateTexture("Glance5IconHighlightTexture", "OVERLAY")
		glance5IconHighlightTexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		glance5IconHighlightTexture:SetAllPoints(mef.Glance5Icon)
		glance5IconHighlightTexture:Hide()
		
		mef.Glance5Icon:SetScript("OnEnter", function (self)
			glance5IconHighlightTexture:Show()
		end )
		
		mef.Glance5Icon:SetScript("OnLeave", function (self)
			glance5IconHighlightTexture:Hide()
		end )

		mef.Glance5Title = CreateFrame( "EditBox", "Glance5Title", mef )
		mef.Glance5Title:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance5Title:SetPoint( "TOPLEFT", mef.Glance5Icon, "TOPRIGHT", 3, 0 )
		mef.Glance5Title:SetHeight( 25 )
		mef.Glance5Title:SetWidth( 280 )
		mef.Glance5Title:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance5Title:EnableMouse(true)
		mef.Glance5Title:SetAutoFocus(false)
		mef.Glance5Title:SetMultiLine(false)
		mef.Glance5Title:SetFontObject( "GameFontHighlight" )

		mef.Glance5Title:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		mef.Glance5Descrip = CreateFrame( "ScrollFrame", "Glance5Descrip", mef, "UIPanelScrollFrameTemplate" )
		
		mef.Glance5Descrip.scrollBarHideable = false
		
		mef.Glance5Descrip.Backdrop = CreateFrame("Frame", "Glance5DescripBackdrop", mef)
		mef.Glance5Descrip.Backdrop:SetPoint( "TOPLEFT", Glance5Title, "BOTTOMLEFT", 0, 3)
		mef.Glance5Descrip.Backdrop:SetPoint( "BOTTOMRIGHT", Glance5Title, "BOTTOMRIGHT", -5, -40)
		mef.Glance5Descrip.Backdrop:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\FriendsFrame\\UI-Toast-Border",
				tile = true,
				tileSize = 16,
				edgeSize = 12,
				insets = { left = 5, right = 3, top = 3, bottom = 3	},
		} )
		mef.Glance5Descrip:SetPoint( "TOPLEFT", Glance5Title, "BOTTOMLEFT", 0, -5)
		mef.Glance5Descrip:SetPoint( "BOTTOMRIGHT", Glance5Title, "BOTTOMRIGHT", -10, -30)
		mef.Glance5Descrip:EnableMouse(true)

		mef.Glance5Descrip.scrollBarHideable = false

		mef.Glance5Descrip.editbox = CreateFrame( "EditBox", nil, sf )
		mef.Glance5Descrip.editbox:SetPoint( "TOPLEFT", 10, 10 )
		mef.Glance5Descrip.editbox:SetPoint( "BOTTOMRIGHT", 10, 0 )
		mef.Glance5Descrip.editbox:SetHeight( 325 )
		mef.Glance5Descrip.editbox:SetWidth( 280 )
		mef.Glance5Descrip.editbox:SetTextInsets( 7, 7, 0, 0 )
		mef.Glance5Descrip.editbox:EnableMouse(true)
		mef.Glance5Descrip.editbox:SetAutoFocus(false)
		mef.Glance5Descrip.editbox:SetMultiLine(true)
		mef.Glance5Descrip.editbox:SetFontObject( "GameFontHighlight" )
		mef.Glance5Descrip:SetScrollChild( mef.Glance5Descrip.editbox )


		mef.Glance5Descrip.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.Glance5Descrip.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		mef.Glance5Descrip.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.Glance5Descrip.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(Glance5Descrip)
		
		-- FontString Title / Details
		
		mef.glance5header = mef:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		mef.glance5header:SetJustifyH( "LEFT" )
		mef.glance5header:SetJustifyV( "TOP" )
		mef.glance5header:SetPoint( "BOTTOMLEFT", mef.Glance5Title, "TOPLEFT", 3, 0 )
		mef.glance5header:SetText( L["editor_glance_headers"] )
		
		-- Clear glance button
		mef.Glance5Clear = CreateFrame( "Button", "Glance5ClearButton", mef, uipbt )
		mef.Glance5Clear:SetPoint( "LEFT", mef.Glance5Title, "RIGHT", -5, 2 )
		mef.Glance5Clear:SetText( L["C"] )
		mef.Glance5Clear:SetWidth( 20 )
		mef.Glance5Clear:SetFrameStrata("HIGH")
		mef.Glance5Clear:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_glanceclear_button"], 1.0, 1.0, 1.0 )
		end )
		mef.Glance5Clear:SetScript( "OnLeave", GameTooltip_Hide )
		mef.Glance5Clear:SetScript("OnClick", function (self)
			mrp:ClearGlance(5)
		end )
		
		mef.ok = CreateFrame( "Button", "MyRolePlayGlanceEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "BOTTOMRIGHT", -7, 4 )
		mef.ok:SetText( L["save_button"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			local field = MyRolePlayGlanceEditFrame.field
			local profile = mrpSaved.SelectedProfile
			if(type(mrpSaved.Profiles[profile]["glances"]) ~= "table") then -- If they don't have glances in their profile, make it.
				mrpSaved.Profiles[profile]["glances"] = {}
				for i = 1, 5, 1 do
					mrpSaved.Profiles[profile]["glances"][i] = {}
				end
			end
			for i = 1, 5, 1 do
				mrpSaved.Profiles[profile]["glances"][i]["Title"] = _G["Glance" .. i .. "Title"]:GetText()
				mrpSaved.Profiles[profile]["glances"][i]["Description"] = _G["Glance" .. i .. "Descrip"].editbox:GetText()
			end
			-- Setup MSP readable glances
			local glanceMSP = ""
			local checkTitle
			local first = true
			for i = 1, 5, 1 do
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
			glanceMSP = glanceMSP:gsub("|TINTERFACE\\ICONS", "|TInterface\\Icons")
			mrp:SaveField('PE', glanceMSP)
			MyRolePlayGlanceEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayGlanceEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["cancel_button"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			for i = 1, 5, 1 do -- Restore the previous icons if they cancel instead of save.
				mrpSaved.Profiles[mrpSaved.SelectedProfile]["glances"][i]["Icon"] = previousGlanceIcons[i]
			end
			MyRolePlayGlanceEditFrame:Hide()
		end )
	end
	-- MyRolePlayMultiEditFrame
	if not MyRolePlayMultiEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayMultiEditFrame", MyRolePlayCharacterFrame, "InsetFrameTemplate" )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 21 )
		mef:SetPoint( "RIGHT", MyRolePlayCharacterFrame, "RIGHT", -3, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 917 ) -- was 700
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayMultiEditFrame.sf.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", 0, 37 )
		mef.subtitle = mef:CreateFontString( "MyRolePlayMultiEditFrame_FormattingToolsSubtitle", "ARTWORK", "GameFontNormalSmall" )
		mef.subtitle:SetPoint( "TOP", mef.title, "BOTTOM", 0, 0 )
		mef.subtitle:SetText(L["editor_formattingtools_header"])

		mef:EnableDrawLayer("OVERLAY")
		mef.sf = CreateFrame( "ScrollFrame", "MyRolePlayMultiEditFrameScrollFrame", mef, "UIPanelScrollFrameTemplate2" )
		mef.sf:SetPoint( "TOPLEFT", 8, -6 )
		mef.sf:SetPoint( "BOTTOMRIGHT", -28, 3 )
		mef.sf:SetSize( 325, 325 )

		mef.sf.scrollBarHideable = false

		mef.sf.editbox = CreateFrame( "EditBox", "MyRolePlayMultiEditFrame_EditBox", mef.sf )
		mef.sf.editbox:SetPoint( "TOPLEFT" )
		mef.sf.editbox:SetPoint( "BOTTOMLEFT" )
		mef.sf.editbox:SetHeight( 325 )
		mef.sf.editbox:SetWidth( 500 )
		mef.sf.editbox:SetTextInsets( 5, 5, 3, 3 )
		mef.sf.editbox:EnableMouse(true)
		mef.sf.editbox:SetAutoFocus(false)
		mef.sf.editbox:SetMultiLine(true)
		--mef.sf.editbox:SetFontObject( "GameFontHighlight" )
		mef.sf.editbox:SetFont("Fonts\\ARIALN.ttf", 14)
		mef.sf:SetScrollChild( mef.sf.editbox )


		mef.sf.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.sf.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
			if(mef.sf.editbox:GetNumLetters() > maxRecommendedCharacters[mrp.EditorShown]) then
				ExcessiveTextWarning:Show();
			else
				ExcessiveTextWarning:Hide();
			end
		end	)
		mef.sf.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		mef.sf.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)
		
		mef.ExcessiveTextWarning = CreateFrame("Frame", "ExcessiveTextWarning", mef)
		mef.ExcessiveTextWarning:SetPoint( "BOTTOMLEFT", MyRolePlayMultiEditFrameScrollFrame, "TOPLEFT", -7, 5 )
		mef.ExcessiveTextWarning:SetHeight(32)
		mef.ExcessiveTextWarning:SetWidth(32)
		local excessiveTextTexture = mef.ExcessiveTextWarning:CreateTexture("ExcessiveTextTexture", "ARTWORK")
		excessiveTextTexture:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		excessiveTextTexture:SetAllPoints(mef.ExcessiveTextWarning)
		mef.ExcessiveTextWarning:SetScript("OnEnter", function (self)
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["Large Profile Warning"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( "This field of your profile is getting quite lengthy, over " .. maxRecommendedCharacters[mrp.EditorShown] .. " characters, and while you may exceed this, it could deter some players and impact load times.", 1.0, 0.8, 0.06, true)
			GameTooltip:Show()
		end )
		mef.ExcessiveTextWarning:SetScript( "OnLeave", GameTooltip_Hide )


		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)
		
		-- Descrip link button
		mef.ilnk = CreateFrame( "Button", "MyRolePlayMultiEditFrame_LinkInsertButton", mef, uipbt )
		local mrpColourButtonTexture = mef.ilnk:CreateTexture("MyRolePlay_LinkInsertButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.ilnk)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.ilnk:SetPoint( "TOP", mef.title, "BOTTOM", 30, -10 )
		mef.ilnk:SetText( L["editor_insertlink_button"] )
		mef.ilnk:SetWidth( 70 )
		mef.ilnk:SetHeight( 18 )
		mef.ilnk:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_insertlink_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_insertlink_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:AddLine( "    ", 0.26, 0.95, 0.31, true )
			GameTooltip:AddLine( L["editor_insertlink_tt_2"], 0.26, 0.95, 0.31, true )
			GameTooltip:Show()
		end )
		mef.ilnk:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ilnk:SetScript("OnClick", function (self)
			mef.sf.editbox:Insert("{link*http://your.url.here*Your text here}")
			mef.sf.editbox:SetCursorPosition(mef.sf.editbox:GetCursorPosition() - 16)
			mef.sf.editbox:HighlightText((mef.sf.editbox:GetCursorPosition() - 20), mef.sf.editbox:GetCursorPosition())
			
		end )
		
		-- Descrip insert colour button
		mef.icdb = CreateFrame( "Button", "MyRolePlayMultiEditFrame_DescripInsertColourButton", mef, uipbt )
		local mrpColourButtonTexture = mef.icdb:CreateTexture("MyRolePlay_DescripInsertColourButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.icdb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.icdb:SetPoint( "RIGHT", mef.ilnk, "LEFT", 0, 0 )
		mef.icdb:SetText( L["editor_insertcolour_button"] )
		mef.icdb:SetWidth( 70 )
		mef.icdb:SetHeight( 18 )
		mef.icdb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_insertcolour_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_insertcolour_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:AddLine( "    ", 0.26, 0.95, 0.31, true )
			GameTooltip:AddLine( L["editor_insertcolour_tt_2"], 0.26, 0.95, 0.31, true )
			GameTooltip:Show()
		end )
		mef.icdb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.icdb:SetScript("OnClick", function (self)
			mrpColourInsert = "ffffff"
			mrp_ShowColourPicker(1, 1, 1, 1, mrp_DescripInsertColourChangedCallback)
			ColorPickerOkayButton:SetScript("OnClick", function (self)
				mef.sf.editbox:Insert("{col:" .. mrpColourInsert .. "}{/col}")
				mef.sf.editbox:SetCursorPosition(mef.sf.editbox:GetCursorPosition() - 6)
				ColorPickerOkayButton:SetScript("OnClick", function (self) -- Restore the colour picker back to how it was after we're done with it.
					ColorPickerFrame:Hide()
				end )
				ColorPickerFrame:Hide()
			end )
		end )
		
		-- Descrip insert Paragraph button
		mef.ipb = CreateFrame( "Button", "MyRolePlayMultiEditFrame_DescripInsertParagraphButton", mef, uipbt )
		local mrpParagraphButtonTexture = mef.ipb:CreateTexture("MyRolePlay_DescripInsertParagraphButtonBackground", "BACKGROUND")
		mrpParagraphButtonTexture:SetAllPoints(mef.ipb)
		mrpParagraphButtonTexture:SetTexture(0.5,0.5,1)
		mef.ipb:SetPoint( "RIGHT", mef.icdb, "LEFT", 0, 0 )
		mef.ipb:SetText( L["editor_insertparagraph_button"] )
		mef.ipb:SetWidth( 80 )
		mef.ipb:SetHeight( 18 )
		mef.ipb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_insertparagraph_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_insertparagraph_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:AddLine( "    ", 0.26, 0.95, 0.31, true )
			GameTooltip:AddLine( L["editor_insertparagraph_tt_2"], 0.26, 0.95, 0.31, true )
			GameTooltip:Show()
		end )
		mef.ipb:SetScript( "OnLeave", GameTooltip_Hide )
		
		mef.pdropdown = CreateFrame( "Frame", "MyRolePlayMultiEditFrame_ParagraphDropDown", mef, "UIDropDownMenuTemplate" )
		UIDropDownMenu_Initialize(mef.pdropdown, mrp_AddParagraphDropdown, "MENU")
		
		mef.ipb:SetScript("OnClick", function (self)
			ToggleDropDownMenu(1, nil, mef.pdropdown, "cursor", 3, -3)
		end )
		
		-- Descrip insert Header button
		mef.ih1b = CreateFrame( "Button", "MyRolePlayMultiEditFrame_DescripInsertHeader1Button", mef, uipbt )
		local mrpHeader1ButtonTexture = mef.ih1b:CreateTexture("MyRolePlay_DescripInsertHeader1ButtonBackground", "BACKGROUND")
		mrpHeader1ButtonTexture:SetAllPoints(mef.ih1b)
		mrpHeader1ButtonTexture:SetTexture(0.5,0.5,1)
		mef.ih1b:SetPoint( "RIGHT", mef.ipb, "LEFT", 0, 0 )
		mef.ih1b:SetText( L["editor_insertheader_button"] )
		mef.ih1b:SetWidth( 80 )
		mef.ih1b:SetHeight( 18 )
		mef.ih1b:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_insertheader_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_insertheader_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:AddLine( "    ", 0.26, 0.95, 0.31, true )
			GameTooltip:AddLine( L["editor_insertheader_tt_2"], 0.26, 0.95, 0.31, true )
			GameTooltip:Show()
		end )
		mef.ih1b:SetScript( "OnLeave", GameTooltip_Hide )
		
		mef.h1dropdown = CreateFrame( "Frame", "MyRolePlayMultiEditFrame_H1DropDown", mef, "UIDropDownMenuTemplate" )
		UIDropDownMenu_Initialize(mef.h1dropdown, mrp_AddHeaderDropdown, "MENU")
		
		mef.ih1b:SetScript("OnClick", function (self)
			ToggleDropDownMenu(1, nil, mef.h1dropdown, "cursor", 3, -3)
		end )
		
		-- Insert icon button
		mef.icb = CreateFrame( "Button", "MyRolePlayMultiEditFrame_InsertIconButton", mef, uipbt )
		local mrpColourButtonTexture = mef.icb:CreateTexture("MyRolePlay_InsertIconButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.icb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.icb:SetPoint( "LEFT", mef.ilnk, "RIGHT", 0, 0 )
		mef.icb:SetText( L["editor_inserticon_button"] )
		mef.icb:SetWidth( 70 )
		mef.icb:SetHeight( 18 )
		mef.icb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_inserticon_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_inserticon_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:Show()
		end )
		mef.icb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.icb:SetScript("OnClick", function (self)
			mrp_iconselector_show(mrp_IconCallbackDescripInsert)
		end )
		
		-- Insert image button
		mef.imgb = CreateFrame( "Button", "MyRolePlayMultiEditFrame_InsertImageButton", mef, uipbt )
		local mrpColourButtonTexture = mef.imgb:CreateTexture("MyRolePlay_InsertImageButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.imgb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.imgb:SetPoint( "LEFT", mef.icb, "RIGHT", 0, 0 )
		mef.imgb:SetText( L["editor_insertimage_button"] )
		mef.imgb:SetWidth( 70 )
		mef.imgb:SetHeight( 18 )
		mef.imgb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_insertimage_tt_title"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_insertimage_tt_1"], 0.97, 0.80, 0.05, true )
			GameTooltip:Show()
		end )
		mef.imgb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.imgb:SetScript("OnClick", function (self)
			mrp_imageselector_show(mrp_IconCallbackDescripInsert)
		end )
		
		-- Preview profile button
		mef.ppb = CreateFrame( "Button", "MyRolePlayMultiEditFrame_PreviewProfileButton", mef, uipbt )
		local mrpColourButtonTexture = mef.ppb:CreateTexture("MyRolePlay_PreviewProfileButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.ppb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.ppb:SetPoint( "LEFT", mef.imgb, "RIGHT", -2, 12 )
		mef.ppb:SetText( L["editor_previewprofile_button"] )
		mef.ppb:SetWidth( 65 )
		mef.ppb:SetHeight( 40 )
		mef.ppb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_previewprofile_tt_1"], 1.0, 1.0, 1.0 )
			GameTooltip:AddLine( L["editor_previewprofile_tt_2"], 0.97, 0.80, 0.05, true )
			GameTooltip:Show()
		end )
		mef.ppb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ppb:SetScript("OnClick", function (self)
			MyRolePlayMultiEditFrame:Hide()
			MyRolePlayDescriptionPreviewFrame:Show()
			local f = msp.char[ mrp:UnitNameWithRealm("player") ].field
			local t = mef.sf.editbox:GetText()
			local formattedProfile = mrp:ConvertPreview( t )
	
			MyRolePlayDescriptionPreviewFrameScrollFrame.html:SetText( formattedProfile )
			ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameAScrollFrame)
		end )
	

		mef.ok = CreateFrame( "Button", "MyRolePlayMultiEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", mef, "BOTTOMRIGHT", -8, -22 )
		mef.ok:SetText( L["save_button"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			local field = MyRolePlayMultiEditFrame.field
			local newtext = MyRolePlayMultiEditFrame.sf.editbox:GetText()
			mrp:SaveField( field, newtext )
			MyRolePlayMultiEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayMultiEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["cancel_button"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayMultiEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayMultiEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( L["editor_inherit_button"] )
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_inherit_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayMultiEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayMultiEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -16 )
		mef.inherited:SetText( L["editor_inherited_label"] )
		mef.inherited:Hide()
	end
	
	-- MyRolePlayDescriptionPreviewFrame
	if not MyRolePlayDescriptionPreviewFrame then
		local mdp = CreateFrame( "Frame", "MyRolePlayDescriptionPreviewFrame", MyRolePlayCharacterFrame, "InsetFrameTemplate" )
		mdp:Hide()
		mdp:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mdp:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 30 )
		mdp:SetPoint( "RIGHT", MyRolePlayCharacterFrame, "RIGHT", -3, 0 )
		mdp:EnableDrawLayer("ARTWORK")

		mdp:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 917 ) -- was 700
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mdp:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mdp.title = mdp:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mdp.title:SetPoint( "TOP", mdp, "TOP", 0, 37 )
		mdp.title:SetText("Profile Preview");

		mdp:EnableDrawLayer("OVERLAY")
		mdp.sf = CreateFrame( "ScrollFrame", "MyRolePlayDescriptionPreviewFrameScrollFrame", mdp, "UIPanelScrollFrameTemplate2" )
		mdp.sf:SetPoint( "TOPLEFT", 8, -6 )
		mdp.sf:SetPoint( "BOTTOMRIGHT", -28, 3 )
		mdp.sf:SetSize( 325, 325 )

		mdp.sf.scrollBarHideable = false

		mdp.sf.html = CreateFrame( "SimpleHTML", nil, mdp.sf )
		mdp.sf.html:SetPoint( "TOPLEFT" )
		mdp.sf.html:SetPoint( "BOTTOMLEFT" )
		mdp.sf.html:SetHeight( 325 )
		mdp.sf.html:SetWidth( 500 )
		mdp.sf.html:SetFontObject( "GameFontHighlight" )
		mdp.sf.html:SetFontObject("p", GameFontHighlight);
		mdp.sf.html:SetFontObject("h1", GameFontNormalHuge3);
		mdp.sf.html:SetFontObject("h2", GameFontNormalHuge);
		mdp.sf.html:SetFontObject("h3", GameFontNormalLarge);
		mdp.sf.html:SetTextColor("h1", 1, 1, 1);
		mdp.sf.html:SetTextColor("h2", 1, 1, 1);
		mdp.sf.html:SetTextColor("h3", 1, 1, 1);
		mdp.sf.html:EnableMouse(false)
		mdp.sf:SetScrollChild( mdp.sf.html )
		
		mdp.sf.html:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
			if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
				local linkName = link:match("^mrpweblink:(.+)");
				if(linkName) then 
					Show_Hyperlink_Box(linkName, linkName); 
				end
				return;
			end  	
		end)
		mdp.sf.html:SetScript("OnHyperlinkEnter", function(f, link, text, button, ...) 
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
		mdp.sf.html:SetScript( "OnHyperlinkLeave", GameTooltip_Hide )
		mdp.sf.html:SetHyperlinksEnabled(1)
		
		mdp:SetScript( "OnHide", function (self)
			MyRolePlayDescriptionPreviewFrame:Hide();
		end )

		mdp.sf.html:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)


		ScrollFrame_OnScrollRangeChanged(MyRolePlayDescriptionPreviewFrameScrollFrame)
		
		-- Return to editor button.
		mdp.ppb = CreateFrame( "Button", "MyRolePlayDescriptionPreviewFrame_PreviewProfileButton", mdp, uipbt )
		local mrpColourButtonTexture = mdp.ppb:CreateTexture("MyRolePlay_PreviewProfileButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mdp.ppb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mdp.ppb:SetPoint( "TOPRIGHT", 0, 38 )
		mdp.ppb:SetText( L["editor_returntoeditor_button"] )
		mdp.ppb:SetWidth( 65 )
		mdp.ppb:SetHeight( 40 )
		mdp.ppb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_returntoeditor_tt_1"], 1.0, 1.0, 1.0 )
			GameTooltip:Show()
		end )
		mdp.ppb:SetScript( "OnLeave", GameTooltip_Hide )
		mdp.ppb:SetScript("OnClick", function (self)
			MyRolePlayDescriptionPreviewFrame:Hide();
			MyRolePlayMultiEditFrame:Show();
		end )
	end

	-- MyRolePlayEditFrame
	if not MyRolePlayEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 742 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayEditFrame.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", -12, 27 )

		mef.desc = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.desc:SetWordWrap(true)
		mef.desc:SetJustifyH( "LEFT" )
		mef.desc:SetJustifyV( "TOP" )
		mef.desc:SetPoint( "TOP", mef, "TOP", -12, -10 )


		mef:EnableDrawLayer("OVERLAY")

		mef.editbox = CreateFrame( "EditBox", nil, mef )
		mef.editbox:SetBackdrop(	{
				bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
				edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				insets = { left = 11, right = 12, top = 12, bottom = 11	},
		} )
		--mef.editbox:SetPoint( "CENTER", -25 )
		--mef.editbox:SetPoint( "LEFT", 5 )
		--mef.editbox:SetPoint( "RIGHT", -25 )
		mef.editbox:SetPoint("TOPLEFT", mef, "TOP", -175, -140)
		mef.editbox:SetPoint("BOTTOMRIGHT", mef, "TOP", 147, -180)
		--mef.editbox:SetHeight( 40 )
		--mef.editbox:SetWidth( 310 )
		mef.editbox:SetTextInsets( 12, 12, 3, 3 )
		mef.editbox:EnableMouse(true)
		mef.editbox:SetAutoFocus(false)
		mef.editbox:SetMultiLine(false)
		mef.editbox:SetFontObject( "GameFontHighlight" )

		mef.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		
		-- Name colour button
		mef.cpb = CreateFrame( "Button", "MyRolePlayCharacterFrame_ColourButton", mef, uipbt )
		local mrpColourButtonTexture = mef.cpb:CreateTexture("MyRolePlay_ColourButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.cpb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.cpb:SetPoint( "BOTTOMLEFT", mef.editbox, "BOTTOMLEFT", 10, -50 )
		mef.cpb:SetText( L["editor_namecolour_button"] )
		mef.cpb:SetWidth( 150 )
		mef.cpb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_namecolour_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cpb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cpb:SetScript("OnClick", function (self)
		local savedR, savedG, savedB
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]) then
				savedR = mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["r"]
				savedG = mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["g"]
				savedB = mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"]["b"]
			elseif(mrpSaved.Profiles["Default"]["nameColour"]) then
				savedR = mrpSaved.Profiles["Default"]["nameColour"]["r"]
				savedG = mrpSaved.Profiles["Default"]["nameColour"]["g"]
				savedB = mrpSaved.Profiles["Default"]["nameColour"]["b"]
			else
				savedR, savedG, savedB = 0.69, 0.29, 1 -- Magic values :3
			end
			mrp_ShowColourPicker(savedR, savedG, savedB, 1, mrp_NameColourChangedCallback)
		end )
		
		-- Eyes colour button
		mef.cepb = CreateFrame( "Button", "MyRolePlayCharacterFrame_EyeColourButton", mef, uipbt )
		local mrpColourButtonTexture = mef.cepb:CreateTexture("MyRolePlay_EyeColourButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.cepb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.cepb:SetPoint( "BOTTOMLEFT", mef.editbox, "BOTTOMLEFT", 10, -50 )
		mef.cepb:SetText( L["editor_eyecolour_button"] )
		mef.cepb:SetWidth( 150 )
		mef.cepb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_eyecolour_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cepb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cepb:SetScript("OnClick", function (self)
			local savedR, savedG, savedB
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]) then
				savedR = mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["r"]
				savedG = mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["g"]
				savedB = mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"]["b"]
			elseif(mrpSaved.Profiles["Default"]["eyeColour"]) then
				savedR = mrpSaved.Profiles["Default"]["eyeColour"]["r"]
				savedG = mrpSaved.Profiles["Default"]["eyeColour"]["g"]
				savedB = mrpSaved.Profiles["Default"]["eyeColour"]["b"]
			else
				savedR, savedG, savedB = 0.9924675, 0.9924675, 0.9924675 -- Magic values :3
			end
			mrp_ShowColourPicker(savedR, savedG, savedB, 1, mrp_EyeColourChangedCallback)
		end )
		
		-- Restore name colour to default button
		mef.dfb = CreateFrame( "Button", "MyRolePlayCharacterFrame_RestoreDefaultColourButtonName", mef, uipbt )
		local mrpColourButtonTexture = mef.dfb:CreateTexture("MyRolePlay_ColourButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.dfb)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.dfb:SetPoint( "RIGHT", mef.cpb, "RIGHT", 150, 0)
		mef.dfb:SetText( L["editor_restorecolour_button"] )
		mef.dfb:SetWidth( 150 )
		mef.dfb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_restorecolour_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.dfb:SetScript( "OnLeave", GameTooltip_Hide )
		mef.dfb:SetScript("OnClick", function (self)
			mrpSaved.Profiles[mrpSaved.SelectedProfile]["nameColour"] = nil
			ColorPickerFrame:Hide()
			if(msp.my["NA"]) then
				msp.my["NA"] = string.gsub(msp.my["NA"], "|cff%x%x%x%x%x%x", "")
			end
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["NA"]) then
				mrpSaved.Profiles[mrpSaved.SelectedProfile]["NA"] = string.gsub(mrpSaved.Profiles[mrpSaved.SelectedProfile]["NA"], "|cff%x%x%x%x%x%x", "")
			end
			if(MyRolePlayEditFrame) then
				local currentText = MyRolePlayEditFrame.editbox:GetText()
				currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
				MyRolePlayEditFrame.editbox:SetText(currentText)
			end
			mrp:UpdateColour("NA")
			mrp:UpdateCharacterFrame()
		end )
		
		-- Restore eye colour to default button
		mef.dfbe = CreateFrame( "Button", "MyRolePlayCharacterFrame_RestoreDefaultColourButtonEyes", mef, uipbt )
		local mrpColourButtonTexture = mef.dfbe:CreateTexture("MyRolePlay_ColourButtonBackground", "BACKGROUND")
		mrpColourButtonTexture:SetAllPoints(mef.dfbe)
		mrpColourButtonTexture:SetTexture(0.5,0.5,1)
		mef.dfbe:SetPoint( "RIGHT", mef.cepb, "RIGHT", 150, 0)
		mef.dfbe:SetText( L["editor_restorecolour_button"] )
		mef.dfbe:SetWidth( 150 )
		mef.dfbe:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_restorecolour_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.dfbe:SetScript( "OnLeave", GameTooltip_Hide )
		mef.dfbe:SetScript("OnClick", function (self)
			mrpSaved.Profiles[mrpSaved.SelectedProfile]["eyeColour"] = nil
			ColorPickerFrame:Hide()
			if(msp.my["AE"]) then
				msp.my["AE"] = string.gsub(msp.my["AE"], "|cff%x%x%x%x%x%x", "")
			end
			if(mrpSaved.Profiles[mrpSaved.SelectedProfile]["AE"]) then
				mrpSaved.Profiles[mrpSaved.SelectedProfile]["AE"] = string.gsub(mrpSaved.Profiles[mrpSaved.SelectedProfile]["AE"], "|cff%x%x%x%x%x%x", "")
			end
			if(MyRolePlayEditFrame) then
				local currentText = MyRolePlayEditFrame.editbox:GetText()
				currentText = string.gsub(currentText, "|cff%x%x%x%x%x%x", "")
				MyRolePlayEditFrame.editbox:SetText(currentText)
			end
			mrp:UpdateColour("AE")
			mrp:UpdateCharacterFrame()
		end )

		mef.ok = CreateFrame( "Button", "MyRolePlayEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "BOTTOMRIGHT", -6, 4 )
		mef.ok:SetText( L["save_button"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			local field = MyRolePlayEditFrame.field
			local newtext = MyRolePlayEditFrame.editbox:GetText()
			mrp:SaveField( field, newtext )
			MyRolePlayEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["cancel_button"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			if(MyRolePlayEditFrame.field == "NA") then                                                           -- We need to update msp.char now because it's not properly updating the colour in the tooltip when they hit cancel instead of save.
				local fullName = select(1, UnitFullName("player")) .. "-" .. select(2, UnitFullName("player")) -- Doing this way seems less risky than running mrp:SetCurrentProfile(), even if it'd be easier.
				if(msp.my["NA"]) then
					msp.char[fullName]["field"]["NA"] = msp.my["NA"]
				end
				if(msp.my["RC"]) then
					msp.char[fullName]["field"]["RC"] = msp.my["RC"]
				end
			end
			-- we, uh, don't need to do anything
			MyRolePlayEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( L["editor_inherit_button"] )
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_inherit_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -22 )
		mef.inherited:SetText( L["editor_inherited_label"] )
		mef.inherited:Hide()
	end
	
	-- MyRolePlayTraitsEditFrame
	if not MyRolePlayTraitsEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayTraitsEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 742 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayTraitsEditFrame:Hide();
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", 0, 27 )

		mef:EnableDrawLayer("OVERLAY")
		
		mef.sf = CreateFrame( "ScrollFrame", "MyRolePlayTraitsEditScrollFrame", mef, "UIPanelScrollFrameTemplate" )
		mef.sf:SetPoint( "TOPLEFT", 20, 0 )
		mef.sf:SetPoint( "BOTTOMRIGHT", -53, 7 )
		mef.sf:SetScrollChild(CreateFrame("Frame"));
		
		mef.sf.bg = CreateFrame("Frame", nil, mef.sf, "InsetFrameTemplate")
        mef.sf.bg:SetPoint("TOPLEFT", mef.sf, "TOPLEFT", -3, 3)
        mef.sf.bg:SetPoint("BOTTOMRIGHT", mef.sf, "BOTTOMRIGHT", 3, -3)
		mef.sf.bg:SetFrameLevel(mef.sf:GetFrameLevel() - 1);
		
		
		ScrollBar_AdjustAnchors( MyRolePlayTraitsEditScrollFrameScrollBar, -1, -1, 1)

		mef.sf.scrollBarHideable = false
		
		mef.new = CreateFrame( "Button", "MyRolePlayTraitsEditFrameNew", mef, uipbt )
		mef.new:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "BOTTOMRIGHT", -210, 4 )
		mef.new:SetText( L["editor_addpersonalitytrait"] )
		mef.new:SetWidth( 150 )
		
		mef.dropdown = CreateFrame( "Frame", "MyRolePlayTraitsEditFrame_DropDown", mef, "UIDropDownMenuTemplate" )
		UIDropDownMenu_Initialize(mef.dropdown, mrp_AddTraitDropdown, "MENU")
		
		mef.new:SetScript("OnClick", function (self)
			ToggleDropDownMenu(1, nil, mef.dropdown, "cursor", 3, -3)
		end )

		mef.ok = CreateFrame( "Button", "MyRolePlayTraitsEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "BOTTOMRIGHT", -7, 4 )
		mef.ok:SetText( L["save_button"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			mrp_SubmitPendingEdits()
			local newtext = mrp_ConvertTraits(personalityTraitsEditor)
			mrp:SaveField( "PS", newtext )
			MyRolePlayTraitsEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayTraitsEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["cancel_button"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayTraitsEditFrame:Hide()
		end )
	end

	-- MyRolePlayComboEditFrame
	if not MyRolePlayComboEditFrame then
		local mef = CreateFrame( "Frame", "MyRolePlayComboEditFrame", MyRolePlayCharacterFrame )
		mef:Hide()
		mef:SetPoint( "TOPLEFT", MyRolePlayCharacterFrame, "TOPLEFT", 332, -61 )
		mef:SetPoint( "BOTTOM", MyRolePlayCharacterFrameInset, "BOTTOM", 0, 30 )
		mef:SetPoint( "RIGHT", CharacterFrame, "RIGHT", -8, 0 )
		mef:EnableDrawLayer("ARTWORK")

		mef:SetScript("OnShow", function(self)
			CharacterFrame:SetWidth( 742 )
			CharacterFrame.Expanded = true
			UpdateUIPanelPositions(CharacterFrame)
			MyRolePlayComboEditFrame.editbox:SetFocus()
		end	)
		mef:SetScript("OnHide", function(self)
			CharacterFrame:SetWidth( 384 )
			CharacterFrame.Expanded = false
			UpdateUIPanelPositions(CharacterFrame)
		end	)
		mef.title = mef:CreateFontString( nil, "ARTWORK", "GameFontNormal" )
		mef.title:SetPoint( "TOP", mef, "TOP", -12, 27 )

		mef.desc = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.desc:SetWordWrap(true)
		mef.desc:SetJustifyH( "LEFT" )
		mef.desc:SetJustifyV( "TOP" )
		mef.desc:SetPoint( "TOP", mef, "TOP", -12, -10 )

		mef:EnableDrawLayer("OVERLAY")

		mef.cb = CreateFrame( "Frame", "MyRolePlayComboEditFrameComboBox", mef, "UIDropDownMenuTemplate" )
		mef.cb:SetPoint( "CENTER", -12, 50 )
		UIDropDownMenu_SetWidth( mef.cb, 205 )

		mef.cb.dd = CreateFrame( "Button", "MyRolePlayComboEditFrameComboBoxDropDown", mef, "UIDropDownListTemplate" )

		MyRolePlayComboEditFrameComboBoxButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.comboboxfields[ MyRolePlayComboEditFrame.field ], MyRolePlayComboEditFrame.cb.dd, MyRolePlayComboEditFrame.cb, 0, 5 )
				mrp.CFComboBoxUpdate( MyRolePlayComboEditFrame, true )
			end
		end )

		mef.editbox = CreateFrame( "EditBox", nil, mef )
		mef.editbox:SetBackdrop( {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
				edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
				tile = true,
				tileSize = 32,
				edgeSize = 32,
				insets = { left = 11, right = 12, top = 12, bottom = 11	},
		} )
		mef.editbox:SetPoint( "BOTTOM", mef, "BOTTOM", 0, 30 )
		mef.editbox:SetHeight( 40 )
		mef.editbox:SetWidth( 205 )
		mef.editbox:SetMaxLetters( 35 )

		mef.editbox:SetTextInsets( 12, 12, 3, 3 )
		mef.editbox:EnableMouse(true)
		mef.editbox:SetAutoFocus(false)
		mef.editbox:SetMultiLine(false)
		mef.editbox:SetFontObject( "GameFontHighlight" )

		mef.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		mef.ok = CreateFrame( "Button", "MyRolePlayComboEditFrameOK", mef, uipbt )
		mef.ok:SetPoint( "BOTTOMRIGHT", MyRolePlayCharacterFrame, "BOTTOMRIGHT", -7, 4 )
		mef.ok:SetText( L["save_button"] )
		mef.ok:SetWidth( 90 )
		mef.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.ok:SetScript( "OnLeave", GameTooltip_Hide )
		mef.ok:SetScript("OnClick", function (self)
			if type( MyRolePlayComboEditFrame.value ) == "string" then
				MyRolePlayComboEditFrame.value = strtrim( MyRolePlayComboEditFrame.editbox:GetText() )
				if strtrim( MyRolePlayComboEditFrame.value ) == "" then 
					MyRolePlayComboEditFrame:Hide()
					return
				else
					local e = strlower( MyRolePlayComboEditFrame.value )
					for i = 0, 4 do 
						if e == strlower( L[ MyRolePlayComboEditFrame.field .. tostring( i ) ] ) then
							MyRolePlayComboEditFrame.value = i
							break
						end
					end 
				end
			end
			mrp:SaveField( MyRolePlayComboEditFrame.field, tostring( MyRolePlayComboEditFrame.value ) )
			MyRolePlayComboEditFrame:Hide()
		end )

		mef.cancel = CreateFrame( "Button", "MyRolePlayComboEditFrameCancel", mef, uipbt )
		mef.cancel:SetPoint( "RIGHT", mef.ok, "LEFT", -16, 0 )
		mef.cancel:SetText( L["cancel_button"] )
		mef.cancel:SetWidth( 90 )
		mef.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		mef.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayComboEditFrame:Hide()
		end )

		mef.inherit = CreateFrame( "Button", "MyRolePlayComboEditFrameInherit", mef, uipbt )
		mef.inherit:SetPoint( "LEFT", mef )
		mef.inherit:SetPoint( "TOP", mef.ok )
		mef.inherit:SetText( L["editor_inherit_button"])
		mef.inherit:SetWidth( 90 )
		mef.inherit:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["editor_inherit_button_tt"], 1.0, 1.0, 1.0 )
		end )
		mef.inherit:SetScript( "OnLeave", GameTooltip_Hide )
		mef.inherit:SetScript("OnClick", function (self)
			local field = MyRolePlayComboEditFrame.field
			mrp:SaveField( field, nil )
			MyRolePlayComboEditFrame:Hide()
		end )
		mef.inherit:Hide()

		mef.inherited = mef:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		mef.inherited:SetJustifyH( "LEFT" )
		mef.inherited:SetPoint( "LEFT", mef, "LEFT", 16, 0 )
		mef.inherited:SetPoint( "BOTTOMLEFT", mef, "BOTTOM", 0, -22 )
		mef.inherited:SetText( L["editor_inherited_label"] )
		mef.inherited:Hide()
	end
	-- Garbage-collect functions we only need once
	mrp.CreateEditFrames = mrp_dummyfunction
end

function mrp.CFComboBoxClick( self, iscustom )
	if iscustom then
		if MyRolePlayComboEditFrame.value == 0 then
			MyRolePlayComboEditFrame.value = ""
		else
			MyRolePlayComboEditFrame.value = emptynil( strtrim( MyRolePlayComboEditFrame.editbox:GetText() ) ) or mrp.Display[ MyRolePlayComboEditFrame.field ]( MyRolePlayComboEditFrame.value )
		end
	else
		MyRolePlayComboEditFrame.value = self.value
	end
	mrp.CFComboBoxUpdate( MyRolePlayComboEditFrame, true )
end

function mrp.CFComboBoxUpdate( mef, doset )
	if type( mef.value ) == "number" then
		if doset then UIDropDownMenu_SetSelectedID( MyRolePlayComboEditFrame.cb, MyRolePlayComboEditFrame.value + 1 ) end
		if mef.value == 0 then 
			mef.editbox:SetText( "" )
			mef.editbox:SetCursorPosition( 0 )
		else
			mef.editbox:SetText( mrp.comboboxfields[ mef.field ][ mef.value + 1 ].text )
			mef.editbox:SetCursorPosition( #mrp.comboboxfields[ mef.field ][ mef.value + 1 ].text )
		end
		mef.editbox:Hide()
	else
		if doset then UIDropDownMenu_SetSelectedID( MyRolePlayComboEditFrame.cb, 6 ) end
		mef.editbox:SetCursorPosition( 0 )
		mef.editbox:SetText( mef.value )
		mef.editbox:SetCursorPosition( #mef.value )
		mef.editbox:Show()
		mef.editbox:SetFocus()
	end
end

mrp.comboboxfields = {
	['FR'] = {
		{ text = L["FR0"], colorCode = "|cff808080", tooltipTitle = L["FR0t"], tooltipText = L["FR0d"], tooltipOnButton = 1, value = 0, func = mrp.CFComboBoxClick },
		{ text = L["FR1"], colorCode = "|cff66b380", tooltipTitle = L["FR1t"], tooltipText = L["FR1d"], tooltipOnButton = 1, value = 1, func = mrp.CFComboBoxClick },
		{ text = L["FR2"], colorCode = "|cff99b3cc", tooltipTitle = L["FR2t"], tooltipText = L["FR2d"], tooltipOnButton = 1, value = 2, func = mrp.CFComboBoxClick },
		{ text = L["FR3"], colorCode = "|cffe6ccb3", tooltipTitle = L["FR3t"], tooltipText = L["FR3d"], tooltipOnButton = 1, value = 3, func = mrp.CFComboBoxClick },
		{ text = L["FR4"], colorCode = "|cff99664d", tooltipTitle = L["FR4t"], tooltipText = L["FR4d"], tooltipOnButton = 1, value = 4, func = mrp.CFComboBoxClick },
		{ text = L["FRc"], tooltipTitle = L["FRct"], tooltipText = L["FRcd"], tooltipOnButton = 1, arg1 = true, func = mrp.CFComboBoxClick },
	},
	['FC'] = {
		{ text = L["FC0"], colorCode = "|cff808080", tooltipTitle = L["FC0t"], tooltipText = L["FC0d"], tooltipOnButton = 1, value = 0, func = mrp.CFComboBoxClick },
		{ text = L["FC1"], colorCode = "|cff99664d", tooltipTitle = L["FC1t"], tooltipText = L["FC1d"], tooltipOnButton = 1, value = 1, func = mrp.CFComboBoxClick },
		{ text = L["FC2"], colorCode = "|cff66b380", tooltipTitle = L["FC2t"], tooltipText = L["FC2d"], tooltipOnButton = 1, value = 2, func = mrp.CFComboBoxClick },
		{ text = L["FC3"], colorCode = "|cff99b3cc", tooltipTitle = L["FC3t"], tooltipText = L["FC3d"], tooltipOnButton = 1, value = 3, func = mrp.CFComboBoxClick },
		{ text = L["FC4"], colorCode = "|cffe6ccb3", tooltipTitle = L["FC4t"], tooltipText = L["FC4d"], tooltipOnButton = 1, value = 4, func = mrp.CFComboBoxClick },
		{ text = L["FCc"], tooltipTitle = L["FCct"], tooltipText = L["FCcd"], tooltipOnButton = 1, arg1 = true, func = mrp.CFComboBoxClick },
	},
	['RS'] = {
		{ text = L["RS0"], colorCode = "|cff808080", tooltipTitle = L["RS0t"], tooltipText = L["RS0d"], tooltipOnButton = 1, value = 0, func = mrp.CFComboBoxClick },
		{ text = L["RS1"], colorCode = "|cffFF0000", tooltipTitle = L["RS1t"], tooltipText = L["RS1d"], tooltipOnButton = 1, value = 1, func = mrp.CFComboBoxClick },
		{ text = L["RS2"], colorCode = "|cff00BBAA", tooltipTitle = L["RS2t"], tooltipText = L["RS2d"], tooltipOnButton = 1, value = 2, func = mrp.CFComboBoxClick },
		{ text = L["RS3"], colorCode = "|cff00CC55", tooltipTitle = L["RS3t"], tooltipText = L["RS3d"], tooltipOnButton = 1, value = 3, func = mrp.CFComboBoxClick },
		{ text = L["RS4"], colorCode = "|cffCCAA77", tooltipTitle = L["RS4t"], tooltipText = L["RS4d"], tooltipOnButton = 1, value = 4, func = mrp.CFComboBoxClick },
		{ text = L["RS5"], colorCode = "|cffCC66CC", tooltipTitle = L["RS5t"], tooltipText = L["RS5d"], tooltipOnButton = 1, value = 5, func = mrp.CFComboBoxClick },
	},
}

-- When you click on a field: display and set up the appropriate edit frame
function mrp.CFEditField( field, fieldname, fielddesc )
	mrp.EditorShown = field -- So we know what field is open to use for editors.
		-- Advanced combination of both for glances, we want MyRolePlayGlanceEditFrame
	if field == 'PE' then
		MyRolePlayEditFrame:Hide()
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayComboEditFrame:Hide()
		MyRolePlayTraitsEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()

		local mef = MyRolePlayGlanceEditFrame
		mef.field = field
		
		local profile = mrpSaved.SelectedProfile
		
		if(type(mrpSaved.Profiles[profile]["glances"]) ~= "table") then -- If they don't have glances in their profile, make it.
			mrpSaved.Profiles[profile]["glances"] = {}
			for i = 1, 5, 1 do
				mrpSaved.Profiles[profile]["glances"][i] = {}
				mrpSaved.Profiles[profile]["glances"][i]["Title"] = _G["Glance" .. i .. "Title"]:GetText()
				mrpSaved.Profiles[profile]["glances"][i]["Description"] = _G["Glance" .. i .. "Descrip"].editbox:GetText()
				mrpSaved.Profiles[profile]["glances"][i]["Icon"] = "Interface\\Icons\\INV_Misc_QuestionMark"
			end
		end
		
		if(profile and mrpSaved.Profiles[profile] and mrpSaved.Profiles[profile]["glances"]) then
			for i = 1, 5, 1 do
				if(mrpSaved.Profiles[profile]["glances"][i]) then
					_G["Glance" .. i .. "Title"]:SetText(mrpSaved.Profiles[profile]["glances"][i]["Title"])
					_G["Glance" .. i .. "Descrip"].editbox:SetText(mrpSaved.Profiles[profile]["glances"][i]["Description"])
					if(mrpSaved.Profiles[profile]["glances"][i]["Icon"] and mrpSaved.Profiles[profile]["glances"][i]["Icon"] ~= "") then
						previousGlanceIcons[i] = mrpSaved.Profiles[profile]["glances"][i]["Icon"]
						_G["Glance" .. i .. "IconTexture"]:SetTexture(mrpSaved.Profiles[profile]["glances"][i]["Icon"])
					else
						previousGlanceIcons[i] = "Interface\\Icons\\INV_Misc_QuestionMark"
						_G["Glance" .. i .. "IconTexture"]:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
					end
				end
			end
		end

		mef:Hide()
		mef:Show()
	elseif field == 'PS' then -- Personality traits, we want MyRolePlayTraitsEditFrame
		MyRolePlayEditFrame:Hide()
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayComboEditFrame:Hide()
		MyRolePlayGlanceEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()

		local mef = MyRolePlayTraitsEditFrame
		mef.field = field
		
		local profile = mrpSaved.SelectedProfile
		
		-- Whatever we need to do.
		
		personalityTraitsEditor = {} -- Table to hold all attributes.
		
		if(mrpSaved.Profiles[profile]["PS"] and mrpSaved.Profiles[profile]["PS"] ~= "") then
			for trait in mrpSaved.Profiles[profile]["PS"]:gmatch("%[trait [^%]]-%]") do
				local structure = {};

				for key, value in trait:gmatch("([%w_-]+)=\"([^\"]*)\"") do
					structure[key] = value;
				end

				table.insert(personalityTraitsEditor, structure);
			end
		end

		mrp:ShowTraitEditorBars(personalityTraitsEditor)
		mef:Hide()
		mef:Show()
	elseif field == 'DE' or field == 'HI' or field == 'CO' or field == 'CU' then
		-- Multiple lines, we want MyRolePlayMultiEditFrame
		MyRolePlayGlanceEditFrame:Hide()
		MyRolePlayComboEditFrame:Hide()
		MyRolePlayEditFrame:Hide()
		MyRolePlayTraitsEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()
		local mef = MyRolePlayMultiEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )

		mef.sf.editbox:SetCursorPosition(0)
		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)

		local text = msp.my[field] or ""
		
		if(field == "DE" or field == "HI") then
			if(MyRolePlayDescriptionPreviewFrame:IsShown() == true) then
				MyRolePlayDescriptionPreviewFrame:Hide();
			end
			-- Swap colour codes to tags in the editor for DE and HI fields.
			text = text:gsub("|cff(%x%x%x%x%x%x)", "{col:%1}")
			text = text:gsub("|r", "{/col}")
			text = text:gsub("|TInterface\\Icons\\(.-):(%d+).-|t", "{icon:%1:%2}")
			-- Links to tags in the editor
			text = text:gsub("%[(.-)]%(%s(.-)%s%)", "{link*%2*%1}")
		end

		mef.sf.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.sf.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.sf.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mef.sf.editbox:SetText( text )
		mef.sf.editbox:SetCursorPosition( #text )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayMultiEditFrameScrollFrame)

		mef:Hide()
		mef:Show()
	elseif field == 'FR' or field == 'FC' then
		-- Combo box + custom text, we want MyRolePlayComboEditFrame
		MyRolePlayGlanceEditFrame:Hide()
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayEditFrame:Hide()
		MyRolePlayTraitsEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()
		local mef = MyRolePlayComboEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )
		mef.desc:SetText( fielddesc )

		mef.editbox:SetCursorPosition(0)

		local text = emptynil( msp.my[field] ) or "0"

		if text == "0" or text == "1" or text == "2" or text == "3" or text == "4" then
			mef.value = tonumber( text )
			MyRolePlayComboEditFrameComboBoxText:SetText( (mrp.comboboxfields[field][ tonumber( text ) + 1 ].colorCode or "") .. mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
			if text == "0" then
				mef.editbox:SetText( "" )
				mef.editbox:SetCursorPosition( 0 )
			else
				mef.editbox:SetText( mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
				mef.editbox:SetCursorPosition( #mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
			end
		else
			mef.value = text
			MyRolePlayComboEditFrameComboBoxText:SetText( mrp.comboboxfields[field][ 6 ].text )
			mef.editbox:SetText( text ) 
			mef.editbox:SetCursorPosition( #text )
		end

		mef.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mrp.CFComboBoxUpdate( mef, false )

		mef:Hide()
		mef:Show()
	elseif field == 'RS' then
		-- Combo box + custom text, we want MyRolePlayComboEditFrame
		MyRolePlayGlanceEditFrame:Hide()
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayEditFrame:Hide()
		MyRolePlayTraitsEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()
		local mef = MyRolePlayComboEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )
		mef.desc:SetText( fielddesc )

		local text = emptynil( msp.my[field] ) or "0"

		if text == "0" or text == "1" or text == "2" or text == "3" or text == "4" or text == "5" or text == "6" then
			mef.value = tonumber( text )
			MyRolePlayComboEditFrameComboBoxText:SetText( (mrp.comboboxfields[field][ tonumber( text ) + 1 ].colorCode or "") .. mrp.comboboxfields[field][ tonumber( text ) + 1 ].text )
		end

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mrp.CFComboBoxUpdate( mef, false )

		mef:Hide()
		mef:Show()
	else
		-- Single line, we want MyRolePlayEditFrame
		MyRolePlayGlanceEditFrame:Hide()
		MyRolePlayMultiEditFrame:Hide()
		MyRolePlayComboEditFrame:Hide()
		MyRolePlayTraitsEditFrame:Hide()
		MyRolePlayDescriptionPreviewFrame:Hide()

		local mef = MyRolePlayEditFrame
		mef.field = field
		mef.fieldname = fieldname
		mef.fielddesc = fielddesc
		mef.title:SetText( fieldname )
		mef.desc:SetText( fielddesc )

		mef.editbox:SetCursorPosition(0)
		
		local text = msp.my[field] or ""
		mef.editbox:EnableKeyboard(true)

		if msp.my[field] == mrpSaved.Profiles.Default[field] and mrpSaved.SelectedProfile ~= "Default" then
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 0.4 )
			mef.inherit:Hide()
			mef.inherited:Show()
		else
			mef.editbox:SetTextColor( 1.0, 1.0, 1.0, 1.0 )
			mef.inherited:Hide()
			if mrpSaved.SelectedProfile == "Default" then
				mef.inherit:Hide()
			else
				mef.inherit:Show()
			end
		end

		mef.editbox:SetText( text )
		mef.editbox:SetCursorPosition( #text )

		mef:Hide()
		mef:Show()
	end
end
function mrp:HideEditFrames()
	MyRolePlayEditFrame:Hide()
	MyRolePlayMultiEditFrame:Hide()
	MyRolePlayComboEditFrame:Hide()
end

-- Icon callback for description/history insert.
function mrp_IconCallbackDescripInsert(selectedTexture)
	MyRolePlayMultiEditFrameScrollFrame.editbox:Insert("{icon:" .. selectedTexture .. ":20}")
end

