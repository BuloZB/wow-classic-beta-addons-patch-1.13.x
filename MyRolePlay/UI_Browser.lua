--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Browser.lua - MyRolePlayBrowseFrame (the profile browser), and support functions
]]

local L = mrp.L
local lastViewedPlayer -- XC field
local previousSoundHandle = 0
local autoplayAttemptMade = false -- Prevents autoplay music from repeating when mrp:UpdateBrowseFrame() fires over again while still open.

defaultTraitsMapping = { -- LI = Left Icon, RI = Right Icon, LT = Left Text, RT = Right Text
	[1] = {
		["LI"] = "Spell_Shadow_UnholyFrenzy",
		["RI"] = "Spell_Holy_RighteousFury",
		["LT"] = L["lefttrait1"],
		["RT"] = L["righttrait1"]
	},
	[2] = {
		["LI"] = "INV_Belt_27",
		["RI"] = "Spell_Shadow_SummonSuccubus",
		["LT"] = L["lefttrait2"],
		["RT"] = L["righttrait2"]
	},
	[3] = {
		["LI"] = "INV_RoseBouquet01",
		["RI"] = "Ability_Hunter_SniperShot",
		["LT"] = L["lefttrait3"],
		["RT"] = L["righttrait3"]
	},
	[4] = {
		["LI"] = "INV_Misc_Gift_02",
		["RI"] = "INV_Ingot_03",
		["LT"] = L["lefttrait4"],
		["RT"] = L["righttrait4"]
	},
	[5] = {
		["LI"] = "Spell_Holy_AuraOfLight",
		["RI"] = "Ability_Rogue_Disguise",
		["LT"] = L["lefttrait5"],
		["RT"] = L["righttrait5"]
	},
	[6] = {
		["LI"] = "INV_ValentinesCandySack",
		["RI"] = "Ability_Rogue_Eviscerate",
		["LT"] = L["lefttrait6"],
		["RT"] = L["righttrait6"]
	},
	[7] = {
		["LI"] = "Spell_Holy_PowerInfusion",
		["RI"] = "INV_Gizmo_02",
		["LT"] = L["lefttrait7"],
		["RT"] = L["righttrait7"]
	},
	[8] = {
		["LI"] = "Ability_Rogue_DualWeild",
		["RI"] = "ACHIEVEMENT_GUILDPERK_HAVEGROUP WILLTRAVEL",
		["LT"] = L["lefttrait8"],
		["RT"] = L["righttrait8"]
	},
	[9] = {
		["LI"] = "INV_Misc_PocketWatch_01",
		["RI"] = "SPELL_FIRE_INCINERATE",
		["LT"] = L["lefttrait9"],
		["RT"] = L["righttrait9"]
	},
	[10] = {
		["LI"] = "INV_Misc_Coin_05",
		["RI"] = "INV_Misc_Coin_02",
		["LT"] = L["lefttrait10"],
		["RT"] = L["righttrait10"]
	},
	[11] = {
		["LI"] = "Ability_Warrior_BattleShout",
		["RI"] = "Ability_Druid_Cower",
		["LT"] = L["lefttrait11"],
		["RT"] = L["righttrait11"]
	},
	
}

local uipbt = "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

local function emptynil( x ) return x ~= "" and x or nil end
do -- URL box thingie. (I'm great at comments c;)
	local frame, fontstring, fontstringFooter, editBox, urlText

	local function createFrame()
		frame = CreateFrame("Frame", _, UIParent)
		frame:SetFrameStrata("FULLSCREEN_DIALOG")
		frame:SetWidth(430)
		frame:SetHeight(140)
		frame:SetPoint("TOP", 0, -230)
		frame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true, tileSize = 32, edgeSize = 32,
			insets = {left = 11, right = 12, top = 12, bottom = 11},
		})
		fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		fontstring:SetWidth(410)
		fontstring:SetHeight(0)
		fontstring:SetPoint("TOP", 0, -16)
		fontstring:SetText("MyRolePlay")
		editBox = CreateFrame("EditBox", nil, frame)
		do
			local editBoxLeft = editBox:CreateTexture(nil, "BACKGROUND")
			local editBoxRight = editBox:CreateTexture(nil, "BACKGROUND")
			local editBoxMiddle = editBox:CreateTexture(nil, "BACKGROUND")
			editBoxLeft:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Left")
			editBoxLeft:SetHeight(32)
			editBoxLeft:SetWidth(32)
			editBoxLeft:SetPoint("LEFT", -14, 0)
			editBoxLeft:SetTexCoord(0, 0.125, 0, 1)
			editBoxRight:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
			editBoxRight:SetHeight(32)
			editBoxRight:SetWidth(32)
			editBoxRight:SetPoint("RIGHT", 6, 0)
			editBoxRight:SetTexCoord(0.875, 1, 0, 1)
			editBoxMiddle:SetTexture("Interface\\ChatFrame\\UI-ChatInputBorder-Right")
			editBoxMiddle:SetHeight(32)
			editBoxMiddle:SetWidth(1)
			editBoxMiddle:SetPoint("LEFT", editBoxLeft, "RIGHT")
			editBoxMiddle:SetPoint("RIGHT", editBoxRight, "LEFT")
			editBoxMiddle:SetTexCoord(0, 0.9375, 0, 1)
		end
		editBox:SetHeight(52)
		editBox:SetWidth(250)
		editBox:SetPoint("TOP", fontstring, "BOTTOM", 0, 10)
		editBox:SetFontObject("GameFontHighlight")
		editBox:SetTextInsets(0, 0, 0, 1)
		editBox:SetFocus()
		editBox:SetText(urlText)
		editBox:HighlightText()
		editBox:SetScript("OnTextChanged", function(self)
			editBox:SetText(urlText)
			editBox:HighlightText()
		end)
		fontstringFooter = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		fontstringFooter:SetWidth(410)
		fontstringFooter:SetHeight(0)
		fontstringFooter:SetPoint("TOP", editBox, "BOTTOM", 0, 10)
		fontstringFooter:SetText("Press CTRL+C to copy the link, CTRL+V into your browser.\n\n|cffFF0000**Links can be dangerous. MRP is not responsible for content.**|r")
		local button = CreateFrame("Button", nil, frame)
		button:SetHeight(25)
		button:SetWidth(75)
		button:SetPoint("BOTTOM", 0, 13)
		button:SetNormalFontObject("GameFontNormal")
		button:SetHighlightFontObject("GameFontHighlight")
		button:SetNormalTexture(button:CreateTexture(nil, nil, "UIPanelButtonUpTexture"))
		button:SetPushedTexture(button:CreateTexture(nil, nil, "UIPanelButtonDownTexture"))
		button:SetHighlightTexture(button:CreateTexture(nil, nil, "UIPanelButtonHighlightTexture"))
		button:SetText(OKAY)
		button:SetScript("OnClick", function(self)
			frame:Hide()
		end)

	end

	function Show_Hyperlink_Box(text, url)
		urlText = url
		if not frame then
			createFrame()
		else
			editBox:SetText(urlText)
			editBox:HighlightText()
		end
		frame:Show()
	end
end

local existingBars = {};

function mrp:CreateTraitBars() -- Create personality trait bars.
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

    frame.RightIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.RightIcon:SetTexture([[Interface\Buttons\WHITE8X8]])
    frame.RightIcon:SetSize(frame:GetHeight(), frame:GetHeight())
    frame.RightIcon:SetPoint("TOPRIGHT")
    frame.RightIcon:SetPoint("BOTTOMRIGHT")

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
    
    frame.RightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.RightText:SetPoint("TOP")
    frame.RightText:SetPoint("BOTTOMLEFT", frame.Bar, "TOP", 0, 4)
    frame.RightText:SetPoint("BOTTOMRIGHT", frame.Bar, "TOPRIGHT", 0, 4)
    frame.RightText:SetJustifyH("RIGHT")
    frame.RightText:SetJustifyV("MIDDLE")
    frame.RightText:SetShadowColor(0, 0, 0)
    frame.RightText:SetShadowOffset(1, -1)
	
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
	
	
    
    -- The returned frame will have Left/RightIcon textures, a Bar statusbar,
    -- and a Left/RightFill texture. You can set the colors/icon paths/values
    -- on these as needed.
    return frame
end

function mrp:ShowTraitBars(traits) -- Show / adjust personality trait bars.
    -- Grab the outer scrollframe and its child panel.
    local scrollFrame = MyRolePlayBrowseFrameEScrollFrame
    local scrollChild = scrollFrame:GetScrollChild()

    -- We'll record the total height of the traits we display.
    local scrollHeight = 0

    -- Loop over the traits for this profile.
    for i, trait in ipairs(traits) do
        -- Recycle or create the bar frame. We want to recycle bars because
        -- creating them from scratch is expensive, and if we don't keep a
        -- history of the bars we've made then we'd  have no way to hide them.
        local frame = existingBars[i] or mrp:CreateTraitBars()
        existingBars[i] = frame

        -- TODO: Set the value, texts, etc.
		local percent = math.floor(trait["value"] * 100);

		frame.LeftValue:SetText(("%d%%"):format(percent))
		frame.RightValue:SetText(("%d%%"):format(100 - percent))
        frame.Bar:SetValue(trait["value"])
		
        if(trait["id"] ~= nil) then
            local traitID = tonumber(trait["id"])
            frame.LeftIcon:SetTexture("Interface\\Icons\\" .. defaultTraitsMapping[traitID]["LI"])
            frame.RightIcon:SetTexture("Interface\\Icons\\" .. defaultTraitsMapping[traitID]["RI"])
            frame.LeftText:SetText(defaultTraitsMapping[traitID]["LT"])
            frame.RightText:SetText(defaultTraitsMapping[traitID]["RT"])
			frame.LeftFill:SetVertexColor(0.2, 0.67, 0.86)
			frame.RightFill:SetVertexColor(1, 0.46, 0.8)
        else
            frame.LeftIcon:SetTexture("Interface\\Icons\\" .. trait["left-icon"])
            frame.RightIcon:SetTexture("Interface\\Icons\\" .. trait["right-icon"])
            frame.LeftText:SetText(trait["left-name"])
            frame.RightText:SetText(trait["right-name"])
			frame.LeftFill:SetVertexColor(tonumber(trait["left-color"]:sub(1, 2), 16) / 255, tonumber(trait["left-color"]:sub(3, 4), 16) / 255, tonumber(trait["left-color"]:sub(5, 6), 16) / 255)
			frame.RightFill:SetVertexColor(tonumber(trait["right-color"]:sub(1, 2), 16) / 255, tonumber(trait["right-color"]:sub(3, 4), 16) / 255, tonumber(trait["right-color"]:sub(5, 6), 16) / 255)
        end
        
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
    scrollChild:ClearAllPoints()
    scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT")
    scrollChild:SetHeight(scrollHeight)
    scrollChild:SetWidth(scrollFrame:GetWidth())
	
	-- Show / hide the "No traits set." fontstring depending on if they have traits or not.
	if(#traits == 0) then
		MyRolePlayNoTraits:Show();
	else
		MyRolePlayNoTraits:Hide();
	end
end

function mrp:CreateGlanceIcons()
	local bf = MyRolePlayBrowseFrame
	local iterationRight = -60
	local iterationRightOffset = 0
	for i = 1, 5, 1 do -- Setup the 5 glances (Right side)
		iterationRight = (-60 + iterationRightOffset) -- itarationRight will initially be the offset from the top, then modified by the offset each time it loops to space them out.
		iterationRightOffset = (iterationRightOffset + -50)
		_G["Glance" .. i .. "BrowserListRight"] = CreateFrame("Frame", _G["Glance" .. i .. "BrowserListRight"], bf)
		_G["Glance" .. i .. "BrowserListRight"]:SetPoint("LEFT", bf, "TOPRIGHT", -2, (iterationRight))
		_G["Glance" .. i .. "BrowserListRight"]:SetHeight(70)
		_G["Glance" .. i .. "BrowserListRight"]:SetWidth(70)
		_G["Glance" .. i .. "BrowserListTextureRight"] = _G["Glance" .. i .. "BrowserListRight"]:CreateTexture(_G["Glance" .. i .. "BrowserListTextureRight"], "ARTWORK")
		_G["Glance" .. i .. "BrowserListTextureRight"]:SetAllPoints(_G["Glance" .. i .. "BrowserListRight"])
		_G["Glance" .. i .. "BrowserListTextureRight"]:SetTexture("Interface\\SPELLBOOK\\SpellBook-SkillLineTab.PNG")
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"] = CreateFrame("Frame", _G["Glance" .. i .. "BrowserListRight"], bf)
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:SetPoint( "TOPLEFT", _G["Glance" .. i .. "BrowserListRight"], "TOPLEFT", 4, -13)
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:SetPoint( "BOTTOMRIGHT", _G["Glance" .. i .. "BrowserListRight"], "BOTTOMRIGHT", -32, 22)
		_G["Glance" .. i .. "BrowserListTextureIconRight"] = _G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:CreateTexture(_G["Glance" .. i .. "BrowserListTextureIconRight"], "OVERLAY")
		_G["Glance" .. i .. "BrowserListTextureIconRight"]:SetAllPoints(_G["Glance" .. i .. "BrowserListTextureIconContainerRight"])
		_G["Glance" .. i .. "BrowserListTextureHighlightRight"] = _G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:CreateTexture(nil, "HIGHLIGHT")
		_G["Glance" .. i .. "BrowserListTextureHighlightRight"]:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		_G["Glance" .. i .. "BrowserListTextureHighlightRight"]:SetAllPoints(_G["Glance" .. i .. "BrowserListTextureIconContainerRight"])
	end
	
	local iterationLeft = -85
	local iterationLeftOffset = 0
	for i = 1, 5, 1 do -- Setup the 5 glances (Left side)
		iterationLeft = (-85 + iterationLeftOffset) -- itarationLeft will initially be the offset from the top, then modified by the offset each time it loops to space them out.
		iterationLeftOffset = (iterationLeftOffset + -50)
		_G["Glance" .. i .. "BrowserListLeft"] = CreateFrame("Frame", _G["Glance" .. i .. "BrowserListLeft"], bf)
		_G["Glance" .. i .. "BrowserListLeft"]:SetPoint("RIGHT", bf, "TOPLEFT", 0, (iterationLeft))
		_G["Glance" .. i .. "BrowserListLeft"]:SetHeight(70)
		_G["Glance" .. i .. "BrowserListLeft"]:SetWidth(70)
		_G["Glance" .. i .. "BrowserListTextureLeft"] = _G["Glance" .. i .. "BrowserListLeft"]:CreateTexture(_G["Glance" .. i .. "BrowserListTextureLeft"], "ARTWORK")
		_G["Glance" .. i .. "BrowserListTextureLeft"]:SetAllPoints(_G["Glance" .. i .. "BrowserListLeft"])
		_G["Glance" .. i .. "BrowserListTextureLeft"]:SetTexture("Interface\\SPELLBOOK\\SpellBook-SkillLineTab.PNG")
		_G["Glance" .. i .. "BrowserListTextureLeft"]:SetTexCoord(1, 0, 0, 1) -- We have to flip the texture around if they anchor glances to the left.
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"] = CreateFrame("Frame", _G["Glance" .. i .. "BrowserListLeft"], bf)
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:SetPoint( "TOPLEFT", _G["Glance" .. i .. "BrowserListLeft"], "TOPLEFT", 32, -13)
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:SetPoint( "BOTTOMRIGHT", _G["Glance" .. i .. "BrowserListLeft"], "BOTTOMRIGHT", -4, 22)
		_G["Glance" .. i .. "BrowserListTextureIconLeft"] = _G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:CreateTexture(_G["Glance" .. i .. "BrowserListTextureIconLeft"], "OVERLAY")
		_G["Glance" .. i .. "BrowserListTextureIconLeft"]:SetAllPoints(_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"])
		_G["Glance" .. i .. "BrowserListTextureHighlightLeft"] = _G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:CreateTexture(nil, "HIGHLIGHT")
		_G["Glance" .. i .. "BrowserListTextureHighlightLeft"]:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\GlanceHighlight.blp")
		_G["Glance" .. i .. "BrowserListTextureHighlightLeft"]:SetAllPoints(_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"])
	end
end

function mrp:UpdateGlanceIconPosition() -- When changing the option in the options dropdown, hide all of them, then show the relevant ones.
	for i = 1, 5, 1 do
		_G["Glance" .. i .. "BrowserListLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListRight"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconRight"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:Hide()
	end
	
	local glancePosition
	
	if(mrpSaved.Options.GlancePosition == 0) then
		glancePosition = "Right"
	elseif(mrpSaved.Options.GlancePosition == 1) then
		glancePosition = "Left"
	end
	if(glances ~= nil) then
		for i = 1, #glances, 1 do
			_G["Glance" .. i .. "BrowserList" .. glancePosition]:Show()
			_G["Glance" .. i .. "BrowserListTextureIcon" .. glancePosition]:Show()
			_G["Glance" .. i .. "BrowserListTextureIconContainer" .. glancePosition]:Show()
		end
	end
end

function mrp:CreateBrowseFrame()
	if not MyRolePlayBrowseFrame then
		-- make local when done dev
		local bf = CreateFrame( "Frame", "MyRolePlayBrowseFrame", UIParent, "ButtonFrameTemplate" )
		bf:Hide()
		bf:SetScript("OnShow", function(self)
			PlaySound(829)
		end	)
		bf:SetScript("OnHide", function(self)
			mrp.BFShown = nil
			autoplayAttemptMade = false
			PlaySound(1201)
			if(previousSoundHandle and previousSoundHandle ~= 0) then
				StopSound(previousSoundHandle)
			else
				previousSoundHandle = 0
			end
		end	)

		bf:ClearAllPoints()
		if mrpSaved.Positions.Browser then
			bf:SetPoint( mrpSaved.Positions.Browser[1], nil, mrpSaved.Positions.Browser[1], mrpSaved.Positions.Browser[2], mrpSaved.Positions.Browser[3] )
			bf:SetSize( mrpSaved.Positions.Browser[4] or 338, mrpSaved.Positions.Browser[5] or 424 )
			mrp:CheckBrowseFrameBounds()
		else
			bf:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
		end
		bf:SetFrameStrata( "HIGH" )
		bf:SetToplevel( true )

		MyRolePlayBrowseFrameTitleText:SetText( "MyRolePlay Profile Browser" )
		SetPortraitToTexture( "MyRolePlayBrowseFramePortrait", "Interface\\Icons\\INV_Misc_Book_01" )

		bf:EnableMouse( true )
		bf:SetMovable( true )
		bf:SetResizable( true )
		bf:SetClampedToScreen( true )
		bf:RegisterForDrag("LeftButton")
		bf:SetScript("OnDragStart", function(self)
			self:StartMoving()
		end	)
		bf:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			mrpSaved.Positions.Browser = { select( 3, MyRolePlayBrowseFrame:GetPoint() ) }
			mrpSaved.Positions.Browser[4] = MyRolePlayBrowseFrame:GetWidth()
			mrpSaved.Positions.Browser[5] = MyRolePlayBrowseFrame:GetHeight()
		end	)
			
		ButtonFrameTemplate_ShowButtonBar( bf )

		bf:SetMinResize( 450, 475 ) -- from UIPanelTemplates.xml > ButtonFrameTemplate > PortraitFrameTemplate (was 338, 424)
		
		-- Private notes button
		bf.npb = CreateFrame( "Button", "MyRolePlayBrowseFrame_NotesButton", bf, uipbt )
		bf.npb:SetPoint( "TOPRIGHT", bf, "TOPRIGHT", -23, 1 )
		bf.npb:SetText( L["|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:15:15:0:-2|t"] )
		bf.npb:SetWidth( 24 )
		bf.npb:SetHeight( 23 )
		bf.npb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_notesnone_button"], 1.0, 1.0, 1.0 )
		end )
		bf.npb:SetScript( "OnLeave", GameTooltip_Hide )
		bf.npb:SetScript("OnClick", function (self)
			if not(MyRolePlayNotesFrame) then
				mrp:CreateNotesFrame()
			end
			mrp:UpdateNotesFrame()
			MyRolePlayNotesFrame:Show()
		end )
		
		-- Play music button
		bf.pmb = CreateFrame( "Button", "MyRolePlayBrowseFrame_PlayMusicButton", bf, uipbt )
		bf.pmb:SetPoint( "RIGHT", bf.npb, "LEFT", 5, 0 )
		bf.pmb:SetText( L["  |TInterface\\COMMON\\VOICECHAT-SPEAKER:20:20:0:-2|t"] )
		bf.pmb:SetWidth( 24 )
		bf.pmb:SetHeight( 23 )
		bf.pmb:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["This profile has music available. Click to play."], 1.0, 1.0, 1.0 )
		end )
		bf.pmb:SetScript( "OnLeave", GameTooltip_Hide )
		
		mrp:CreateGlanceIcons() -- Create glance icons along the side of the browse frame, on the appropriate side, depending on selection.
		
		-- Swipe CharacterFrameTabButtonTemplate, and mould it to our purposes
		bf.tab1 = CreateFrame( "Button", "MyRolePlayBrowseFrameTab1", bf, "CharacterFrameTabButtonTemplate", 1 )
		bf.tab1:SetPoint( "TOPLEFT", bf, "BOTTOMLEFT", 11, 2 )
		bf.tab1:SetText( L["browser_tab1"] )
		bf.tab1:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_tab1_tt"], 1.0, 1.0, 1.0 )
		end )
		bf.tab1:SetScript( "OnLeave", GameTooltip_Hide )
		-- Due to our purloining the tab template from the CharacterFrame, we must override OnClick and OnShow as they have CharacterFrame-specific code
		bf.tab1:SetScript( "OnClick", function(self)
			mrp:TabSwitchBF( "Appearance" )
		end )
		-- CharacterFrameTabButtonTemplate has a bounds check in here too, but since we only have 2 tabs, there's no need to shoehorn them in, there's plenty of room
		bf.tab1:SetScript( "OnShow", function(self)
			PanelTemplates_TabResize( self, 0 )
		end )
		
		bf.tab2 = CreateFrame( "Button", "MyRolePlayBrowseFrameTab2", bf, "CharacterFrameTabButtonTemplate", 2 )
		bf.tab2:SetPoint( "LEFT", bf.tab1, "RIGHT", -15, 0 )
		bf.tab2:SetText( L["browser_tab2"] )
		bf.tab2:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_tab2_tt"], 1.0, 1.0, 1.0 )
		end )
		bf.tab2:SetScript( "OnLeave", GameTooltip_Hide )
		bf.tab2:SetScript( "OnClick", function(self)
			mrp:TabSwitchBF( "Personality" )
		end )
		bf.tab2:SetScript( "OnShow", function(self)
			PanelTemplates_TabResize( self, 0 )
		end )
		if(mrpSaved.Options.ShowTraitsInBrowser == false) then
			bf.tab2:Hide();
		end

		bf.tab3 = CreateFrame( "Button", "MyRolePlayBrowseFrameTab3", bf, "CharacterFrameTabButtonTemplate", 3 )
		if(mrpSaved.Options.ShowTraitsInBrowser == true) then
			bf.tab3:SetPoint( "LEFT", bf.tab2, "RIGHT", -15, 0 )
		else
			bf.tab3:SetPoint( "LEFT", bf.tab1, "RIGHT", -15, 0 )
		end
		bf.tab3:SetText( L["browser_tab3"] )
		bf.tab3:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_tab3_tt"], 1.0, 1.0, 1.0 )
		end )
		bf.tab3:SetScript( "OnLeave", GameTooltip_Hide )
		bf.tab3:SetScript( "OnClick", function(self)
			mrp:TabSwitchBF( "Biography" )
		end )
		bf.tab3:SetScript( "OnShow", function(self)
			PanelTemplates_TabResize( self, 0 )
		end )

		-- Appearance + Personality + Biography, makes three
		bf.numTabs = 3
		PanelTemplates_TabResize( bf.tab1, 0 )
		PanelTemplates_TabResize( bf.tab2, 0 )
		PanelTemplates_TabResize( bf.tab3, 0 )
		PanelTemplates_SetTab( bf, 1 )


		bf:EnableDrawLayer( "OVERLAY" )

		bf.ver = bf:CreateFontString( nil, "OVERLAY", "MyRolePlayMediumFont" )
		bf.ver:SetJustifyH( "RIGHT" )
		bf.ver:SetPoint( "BOTTOMRIGHT", -15, 10 )
		bf.ver:SetAlpha( 0.5 )
		bf.ver:SetSize( bf:GetWidth()-8, 10 )
		
		bf.load = bf:CreateFontString( nil, "OVERLAY", "MyRolePlayMediumFont" )
		bf.load:SetJustifyH( "LEFT" )
		bf.load:SetPoint( "BOTTOMLEFT", 8, 10 )
		bf.load:SetSize( bf:GetWidth()-8, 10 )

		bf.nickname = bf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		bf.nickname:SetPoint( "TOP", 0, -25 )
		bf.nickname:SetSize( bf:GetWidth()-16, 10 )

		bf.house = bf:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		bf.house:SetPoint( "TOP", 0, -36 )
		bf.house:SetSize( bf:GetWidth()-16, 10 )

		bf.title = bf:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		bf.title:SetPoint( "TOP", 0, -48 )
		bf.title:SetSize( bf:GetWidth()-16, 10 )


		bf.inset = MyRolePlayBrowseFrameInset
		bf.inset:SetPoint( "TOPLEFT", bf, "TOPLEFT", 4, -60 )
		bf.inset:SetPoint( "BOTTOMRIGHT", bf, "BOTTOMRIGHT", -6, 25 )
		--MyRolePlayBrowseFrameInset.Bg:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\backgroundtest2.blp", "REPEAT", "REPEAT") Messing with changing the BG texture.
		
		-- Appearance tab (1)
		
		bf.Appearance = CreateFrame( "Frame", nil, bf.inset, nil, 1 )
		bfa = bf.Appearance
		bfa:SetPoint( "TOPLEFT", 3, -3 )
		bfa:SetPoint( "BOTTOMRIGHT", -3, 3 )
		bfa:SetFrameLevel( bf.inset:GetFrameLevel()+2 )
		
		local x = bfa:GetWidth()
		local y

		bfa.fields = { }

		bfa:EnableDrawLayer( "OVERLAY" )
		
		y = (x - 6) / 2
 		
		-- vv Roleplay style and roleplay status. Removed from browser for now as we're out of space. They're still on the tooltip and glance frame.
		--mrp:CreateBFpfield( bfa, 'FR', L["FR"], 23, y, nil )
		--mrp:CreateBFpfield( bfa, 'FC', L["FC"], 23, y, bfa.fields.FR )

		y = (x - 18) / 8

		mrp:CreateBFpfield( bfa, 'AE', L["AE"], 17, y*1.63, nil )
 		mrp:CreateBFpfield( bfa, 'RA', L["RA"], 17, y*1.5, bfa.fields.AE )
		mrp:CreateBFpfield( bfa, 'RC', L["RC"], 17, y*1.8, bfa.fields.RA )
		mrp:CreateBFpfield( bfa, 'AH', L["AH"], 17, y*1.5, bfa.fields.RC )
		mrp:CreateBFpfield( bfa, 'AW', L["AW"], 17, y*1.5, bfa.fields.AH )
		
		mrp:CreateBFpfield( bfa, 'CU', L["CU"], 41, (-x/2), bfa.fields.AE, true )
		mrp:CreateBFpfield( bfa, 'CO', L["CO"], 41, ((x/2) - 5), bfa.fields.CU, true )

		mrp:CreateBFpfield( bfa, 'DE', L["DE"], nil, -x, bfa.fields.CU, true )

		bfa.sf = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameAScrollFrame", bfa, "UIPanelScrollFrameTemplate" )
		bfa.sf:SetPoint( "TOPLEFT", bfa.fields.DE.h, "BOTTOMLEFT", 4, 0 ) -- If stuff breaks the x was 0. Nudged these over a bit with the HTML update because HTML frames have no padding. :c
		bfa.sf:SetPoint( "BOTTOMRIGHT", bf.inset, "BOTTOMRIGHT", -24, 3 ) -- x was 26.

		bfa.sf:EnableMouse(true)
		bfa.sf.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameAScrollFrameScrollBar, -1, -1, 1)
		
		bfa.sf.html = CreateFrame("SimpleHTML", nil, bfa.sf)
		bfa.sf.html:SetSize(bfa.sf:GetWidth()-4, bfa.sf:GetHeight())
		bfa.sf.html:SetFrameStrata("HIGH")
		bfa.sf.html:SetBackdropColor(0, 0, 0, 1)
		bfa.sf.html:SetFontObject( "GameFontHighlight" )
		--local defaultFont = GameFontNormal:GetFont() -- Get whatever font they're using so we use the same one when we change the font size.
		bfa.sf.html:SetFontObject("p", GameFontHighlight); -- GameFontNormal is gold.
		bfa.sf.html:SetFontObject("h1", GameFontNormalHuge3);
		bfa.sf.html:SetFontObject("h2", GameFontNormalHuge);
		bfa.sf.html:SetFontObject("h3", GameFontNormalLarge);
		bfa.sf.html:SetTextColor("h1", 1, 1, 1);
		bfa.sf.html:SetTextColor("h2", 1, 1, 1);
		bfa.sf.html:SetTextColor("h3", 1, 1, 1);
		bfa.sf.html:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
			if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
				local linkName = link:match("^mrpweblink:(.+)");
				if(linkName) then 
					Show_Hyperlink_Box(linkName, linkName); 
				end
				return;
			end  	
		end)
		bfa.sf.html:SetScript("OnHyperlinkEnter", function(f, link, text, button, ...) 
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
		bfa.sf.html:SetScript( "OnHyperlinkLeave", GameTooltip_Hide )
		bfa.sf.html:SetHyperlinksEnabled(1)
		
		bfa.sf:SetScrollChild( bfa.sf.html )

		bfa.sf.html:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameAScrollFrame)
		
		-- Currently and OOC are now scrollable frames. Other addons send very long strings. (sfcu = Currently / sfco = OOC)
		
		bfa.sfcu = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameCScrollFrame", bfa, "UIPanelScrollFrameTemplate" )
		bfa.sfcu:SetPoint( "TOPLEFT", bfa.fields.CU.h, "BOTTOMLEFT", 0, 0 )
		bfa.sfcu:SetPoint( "BOTTOMRIGHT", bfa.fields.DE.h, "TOP", -23, 0 )
		
		bfa.sfcu.ScrollBar.scrollStep = 20 -- The scrollbar is so small, that if scrollStep isn't specified then Blizzard's scrollframe template defaults to using half the height of the scrollbar as the step

		bfa.sfcu:EnableMouse(true)
		bfa.sfcu.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameCScrollFrameScrollBar, -1, -1, 1)

		bfa.sfcu.editbox = CreateFrame( "EditBox", nil, bfa.sfcu )
		bfa.sfcu.editbox.cursorOffset = 0
		bfa.sfcu.editbox:SetPoint( "TOPLEFT" )
		bfa.sfcu.editbox:SetPoint( "BOTTOMLEFT" )
		
		bfa.sfcu.editbox:SetWidth( x/2 - 20)
		bfa.sfcu.editbox:SetSpacing( 1 )
		bfa.sfcu.editbox:SetTextInsets( 3, 3, 0, 4 )
		bfa.sfcu.editbox:EnableMouse(false)
		bfa.sfcu.editbox:EnableKeyboard(false)
		bfa.sfcu.editbox:SetAutoFocus(false)
		bfa.sfcu.editbox:SetMultiLine(true)
		bfa.sfcu.editbox:SetHyperlinksEnabled(1)
		bfa.sfcu.editbox:SetFontObject( "GameFontHighlight" )
		bfa.sfcu:SetScrollChild( bfa.sfcu.editbox )


		bfa.sfcu.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		bfa.sfcu.editbox:SetScript( "OnEditFocusLost", EditBox_ClearHighlight )
		bfa.sfcu.editbox:SetScript( "OnEditFocusGained", EditBox_HighlightText )

		bfa.sfcu.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		bfa.sfcu.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		bfa.sfcu.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)
		bfa.sfcu.editbox:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
			if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
				local linkName = link:match("^mrpweblink:(.+)");
				if(linkName) then 
					Show_Hyperlink_Box(linkName, linkName); 
				end
				return;
			end  	
		end)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameCScrollFrame)
		
		bfa.sfco = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameDScrollFrame", bfa, "UIPanelScrollFrameTemplate" )
		bfa.sfco:SetPoint( "TOPLEFT", bfa.fields.CO.h, "BOTTOMLEFT", 0, 0 )
		bfa.sfco:SetPoint( "BOTTOMRIGHT", bfa.fields.DE.h, "TOPRIGHT", -23, 0 )
		
		bfa.sfco.ScrollBar.scrollStep = 20 -- The scrollbar is so small, that if scrollStep isn't specified then Blizzard's scrollframe template defaults to using half the height of the scrollbar as the step

		bfa.sfco:EnableMouse(true)
		bfa.sfco.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameDScrollFrameScrollBar, -1, -1, 1)

		bfa.sfco.editbox = CreateFrame( "EditBox", nil, bfa.sfcu )
		bfa.sfco.editbox.cursorOffset = 0
		bfa.sfco.editbox:SetPoint( "TOPLEFT" )
		bfa.sfco.editbox:SetPoint( "BOTTOMLEFT" )

		bfa.sfco.editbox:SetWidth( x/2.2 )
		bfa.sfco.editbox:SetSpacing( 1 )
		bfa.sfco.editbox:SetTextInsets( 3, 3, 0, 4 )
		bfa.sfco.editbox:EnableMouse(false)
		bfa.sfco.editbox:EnableKeyboard(false)
		bfa.sfco.editbox:SetAutoFocus(false)
		bfa.sfco.editbox:SetMultiLine(true)
		bfa.sfco.editbox:SetHyperlinksEnabled(1)
		bfa.sfco.editbox:SetFontObject( "GameFontHighlight" )
		bfa.sfco:SetScrollChild( bfa.sfco.editbox )


		bfa.sfco.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )
		bfa.sfco.editbox:SetScript( "OnEditFocusLost", EditBox_ClearHighlight )
		bfa.sfco.editbox:SetScript( "OnEditFocusGained", EditBox_HighlightText )

		bfa.sfco.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		bfa.sfco.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		bfa.sfco.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)
		bfa.sfco.editbox:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
			if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
				local linkName = link:match("^mrpweblink:(.+)");
				if(linkName) then 
					Show_Hyperlink_Box(linkName, linkName); 
				end
				return;
			end  	
		end)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameDScrollFrame)
		
		-- Personality tab (2)
		
		bf.Personality = CreateFrame("Frame", nil, bf.inset, nil, 2) -- Personality tab (Tab 2, but we use bfc because it was added later and don't want to change existing code.)
		bfc = bf.Personality
		bfc:SetPoint( "TOPLEFT", 3, -3 )
		bfc:SetPoint( "BOTTOMRIGHT", -3, 3 )
		bfc:SetFrameLevel( bf.inset:GetFrameLevel()+2 )
		bfc:Hide()
		
		x = bfc:GetWidth()
		y = (x - 12) / 5
		
		bfc.fields = { }
		
		bfc:EnableDrawLayer( "OVERLAY" )
		
		mrp:CreateBFpfield( bfc, 'PS', L["PS"], nil, nil, nil )
		
		bfc.sf = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameEScrollFrame", bfc, "UIPanelScrollFrameTemplate" )
		bfc.sf:SetPoint( "TOPLEFT", bfc.fields.PS.h, "BOTTOMLEFT", 0, 0 )
		bfc.sf:SetPoint( "BOTTOMRIGHT", bf.inset, "BOTTOMRIGHT", -26, 3 )
		
		bfc.sf:EnableMouse(true)
		bfc.sf.scrollbarHideable = false
		
		bfc.sf:SetScrollChild(CreateFrame("Frame"));
		
		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameEScrollFrameScrollBar, -1, -1, 1)
		
		bfc.notraits = bfc:CreateFontString("MyRolePlayNoTraits", "ARTWORK", "GameFontNormalLarge")
		bfc.notraits:SetWidth(410)
		bfc.notraits:SetHeight(0)
		bfc.notraits:SetPoint("TOP", 0, -30)
		bfc.notraits:SetText("No personality traits set.")
		
		-- Biography tab (3)

		bf.Biography = CreateFrame( "Frame", nil, bf.inset, nil, 3 ) -- Biography tab (Tab 3)
		bfb = bf.Biography
		bfb:SetPoint( "TOPLEFT", 3, -3 )
		bfb:SetPoint( "BOTTOMRIGHT", -3, 3 )
		bfb:SetFrameLevel( bf.inset:GetFrameLevel()+2 )
		bfb:Hide()

		x = bfb:GetWidth()

		bfb.fields = { }

		bfb:EnableDrawLayer( "OVERLAY" )

		y = (x - 12) / 5
 		
		mrp:CreateBFpfield( bfb, 'AG', L["AG"], 21, y, nil )
		mrp:CreateBFpfield( bfb, 'HH', L["HH"], 21, y*2, bfb.fields.AG )
		mrp:CreateBFpfield( bfb, 'HB', L["HB"], 21, y*2, bfb.fields.HH )

		mrp:CreateBFpfield( bfb, 'RS', L["RS"], 21, -x/4, bfb.fields.AG)
		mrp:CreateBFpfield( bfb, 'MO', L["MO"], 21, x/1.358, bfb.fields.RS )

		mrp:CreateBFpfield( bfb, 'HI', L["HI"], nil, -x, bfb.fields.RS, true )

		bfb.sf = CreateFrame( "ScrollFrame", "MyRolePlayBrowseFrameBScrollFrame", bfb, "UIPanelScrollFrameTemplate" )
		bfb.sf:SetPoint( "TOPLEFT", bfb.fields.HI.h, "BOTTOMLEFT", 4, 0 )
		bfb.sf:SetPoint( "BOTTOMRIGHT", bf.inset, "BOTTOMRIGHT", -26, 3 )

		bfb.sf:EnableMouse(true)
		bfb.sf.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayBrowseFrameBScrollFrameScrollBar, -1, -1, 1)
		
		bfb.sf.html = CreateFrame("SimpleHTML", nil, bfb.sf)
		bfb.sf.html:SetSize(bfb.sf:GetWidth(), bfb.sf:GetHeight())
		bfb.sf.html:SetFrameStrata("HIGH")
		bfb.sf.html:SetBackdropColor(0, 0, 0, 1)
		bfb.sf.html:SetFontObject( "GameFontHighlight" )
		--local defaultFont = GameFontNormal:GetFont() -- Get whatever font they're using so we use the same one when we change the font size.
		bfb.sf.html:SetFontObject("p", GameFontHighlight);
		bfb.sf.html:SetFontObject("h1", GameFontNormalHuge3);
		bfb.sf.html:SetFontObject("h2", GameFontNormalHuge);
		bfb.sf.html:SetFontObject("h3", GameFontNormalLarge);
		bfb.sf.html:SetTextColor("h1", 1, 1, 1); -- White headers, gold text.
		bfb.sf.html:SetTextColor("h2", 1, 1, 1);
		bfb.sf.html:SetTextColor("h3", 1, 1, 1);
		bfb.sf.html:SetScript("OnHyperlinkClick", function(f, link, text, button, ...) 
			if(link:match("mrpweblink")) then -- Creates a new hyperlink type to allow for clicking of web links.
				local linkName = link:match("^mrpweblink:(.+)");
				if(linkName) then 
					Show_Hyperlink_Box(linkName, linkName); 
				end
				return;
			end  	
		end)
		bfb.sf.html:SetScript("OnHyperlinkEnter", function(f, link, text, button, ...) 
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
		bfb.sf.html:SetScript( "OnHyperlinkLeave", GameTooltip_Hide )
		bfa.sf.html:SetHyperlinksEnabled(1)
		
		bfb.sf:SetScrollChild( bfb.sf.html )

		bfb.sf.html:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameBScrollFrame)

		bf.sizer = CreateFrame( "Button", "MyRolePlayBrowseFrameSizer", bf )
		bf.sizer:SetNormalTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]] )
		bf.sizer:SetHighlightTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]] )
		bf.sizer:SetPushedTexture( [[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]] )
		bf.sizer:RegisterForDrag( "LeftButton" )
		bf.sizer:SetSize( 16, 16 )
		bf.sizer:SetPoint( "BOTTOMRIGHT", bf, "BOTTOMRIGHT", -5, 3 )
		bf.sizer:SetScript("OnDragStart", function(self)
			MyRolePlayBrowseFrame:StartSizing()
		end	)
		bf.sizer:SetScript("OnDragStop", function(self)
			MyRolePlayBrowseFrame:StopMovingOrSizing()
			mrp:CheckBrowseFrameBounds()
			mrp_BrowseFrameSizeUpdate( MyRolePlayBrowseFrame, MyRolePlayBrowseFrame:GetWidth(), MyRolePlayBrowseFrame:GetHeight() )
			mrpSaved.Positions.Browser = { select( 3, MyRolePlayBrowseFrame:GetPoint() ) }
			mrpSaved.Positions.Browser[4] = MyRolePlayBrowseFrame:GetWidth()
			mrpSaved.Positions.Browser[5] = MyRolePlayBrowseFrame:GetHeight()
			mrp:UpdateHTMLText() -- We need to update the HTML text in DE / HI everytime.
		end	)

		bf:SetScript( "OnSizeChanged", mrp_BrowseFrameSizeUpdate )

		-- Garbage-collect functions we only need once
		mrp.CreateBrowseFrame = mrp_dummyfunction
		mrp.CreateBFpfield = mrp_dummyfunction
	end
end

-- XC (profile load progress) field update
local function Update_XC(name, statusType, msgID, msgTotal)
	local loadPercent
	if(statusType == "MESSAGE") then
		if(MyRolePlayBrowseFrame:IsShown() == true and name == lastViewedPlayer) then
			if(msgID == msgTotal) then
				MyRolePlayBrowseFrame.load:SetText( L["browser_loading_complete"] )
			else
				loadPercent = math.floor((msgID / msgTotal) * 100)
				MyRolePlayBrowseFrame.load:SetText( L["browser_loading_inprogress"] .. " " .. loadPercent .. "% [" .. msgID .. "/" .. msgTotal .. " chunks]" )
			end
		end
	else
		MyRolePlayBrowseFrame.load:SetText( L["browser_loading_error"] )
	end
end

-- XC field update
C_Timer.After(0.5, function() table.insert(msp.callback.status, Update_XC); end);

function mrp_BrowseFrameSizeUpdate( bf, width, height )
	if not bf.Appearance then return end -- Bail if this is called before frame finishes init
	local x = bf.Appearance:GetWidth()
	local f = bf.Appearance.fields
	local y

	y = (x - 6) / 2
	--f.FR:SetWidth( y )
	--f.FC:SetWidth( y )

	y = (x - 18) / 8
	f.AE:SetWidth( y * 1.63 )
	f.RA:SetWidth( y * 1.5 )
	f.RC:SetWidth( y * 1.8 )
	f.AH:SetWidth( y * 1.5 )
	f.AW:SetWidth( y * 1.5 )

	f.CU:SetWidth( x/2 )
	f.CU.h:SetWidth( x/2 )
	f.CO:SetWidth( (x/2) - 5) 	
	f.CO.h:SetWidth( (x/2) - 5)
	
	f.DE:SetWidth( x )
	f.DE.h:SetWidth( x )
	bf.Appearance.sf.html:SetWidth( x-24 )
	bfa.sfcu.editbox:SetWidth( x/2 - 20)
	bfa.sfco.editbox:SetWidth( x/2 - 27)

	ScrollFrame_OnScrollRangeChanged( MyRolePlayBrowseFrameAScrollFrame )
	
	
	x = bf.Personality:GetWidth()
	f = bf.Personality.fields
	y = (x - 12) / 5
	
	mrp:ShowTraitBars(personalityTraits) -- Call this when we resize to adjust the bars to the frame.
	

	x = bf.Biography:GetWidth()
	f = bf.Biography.fields

	y = (x - 12) / 5

	f.AG:SetWidth( y )
	f.HH:SetWidth( y * 2 )
	f.HB:SetWidth( y * 2 )

	f.RS:SetWidth( x/4 )
	f.MO:SetWidth( x/1.358 )
	f.HI:SetWidth( x )
	f.HI.h:SetWidth( x )
	bf.Biography.sf.html:SetWidth( x-24 )

	ScrollFrame_OnScrollRangeChanged( MyRolePlayBrowseFrameBScrollFrame )
end

function mrp:TabSwitchBF( tab )
	if tab == "Appearance" then
		PanelTemplates_SetTab( MyRolePlayBrowseFrame, 1 )
		MyRolePlayBrowseFrame.Biography:Hide()
		MyRolePlayBrowseFrame.Personality:Hide()
		MyRolePlayBrowseFrame.Appearance:Show()
	elseif tab == "Personality" then
		PanelTemplates_SetTab( MyRolePlayBrowseFrame, 2 )
		MyRolePlayBrowseFrame.Biography:Hide()
		MyRolePlayBrowseFrame.Appearance:Hide()
		MyRolePlayBrowseFrame.Personality:Show()
	elseif tab == "Biography" then
		PanelTemplates_SetTab( MyRolePlayBrowseFrame, 3 )
		MyRolePlayBrowseFrame.Appearance:Hide()
		MyRolePlayBrowseFrame.Personality:Hide()
		MyRolePlayBrowseFrame.Biography:Show()
	end
	PlaySound(836)
end

-- Patterned off of CreateCFpfield, with some removals and amendments
-- c = container
function mrp:CreateBFpfield( c, field, name, height, width, anchor, complex )
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
			yoffs = 14
			anchorpointl = "BOTTOMLEFT"
		else
			sep = true
			yoffs = 0
			xoffs = 6
			anchorpointl = "TOPRIGHT"
		end
	else
		xoffs = 0
		yoffs = 14
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
	if height then
		f:SetHeight( height )
	end
	f.h = CreateFrame( "Frame", nil, f )
	f.h:SetPoint( "TOPLEFT", anchor, anchorpointl, xoffs, -yoffs )
	f.h:SetHeight( 14 )
	if width then
		if complex then
			f.h:SetWidth( width )
		else
			f.h:SetWidth( width )
			f.h:SetPoint( "TOPRIGHT", f )
		end
	else
		f.h:SetPoint( "TOPRIGHT", anchor, anchorpointr, xoffs, -yoffs )
	end
	if sep then
		f.sep = CreateFrame( "Frame", nil, f )
		f.sep:SetSize( 6, 14 )
		f.sep:SetPoint( "TOPRIGHT", f.h, "TOPLEFT", -1 )
		f.sep:SetBackdrop( {
			bgFile = [[Interface\AddOns\MyRolePlay\Artwork\FieldSep.blp]],
			tile = false,
		} )
	end
	f.h.fs = f.h:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" )
	f.h.fs:SetJustifyH( "LEFT" )
	f.h.fs:SetText( "    "..name )
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
	if not complex then
		f.t = f:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
		f.t:SetJustifyH( "LEFT" )
		f.t:SetJustifyV( "TOP" )
		f.t:SetWordWrap(true)
		f.t:SetNonSpaceWrap(false)
		f.t:SetSpacing( 1 )
		f.t:SetParent( f )
		f.t:SetPoint( "TOPLEFT", f.h, "BOTTOMLEFT", 3, -3 )
		f.t:SetPoint( "TOPRIGHT", f.h, "BOTTOMRIGHT", -3, -3 )
		if height then
			f.t:SetHeight( height - 14 )
		else
			f.t:SetHeight( 0 )
		end
	end
end

function mrp:CreateURLLink(t)
    t = gsub(t, "%f[%@%w]([%w%-%.]+%.com%f[^%w%/])", "http://%1") -- Some assistance from Meorawr / Itarater with the pattern matches.
    t = t:gsub("%f[%@%w]([%w%-%.]+%.net%f[^%w%/])", "http://%1")
    t = t:gsub("%f[%@%w]([%w%-%.]+%.org%f[^%w%/])", "http://%1")
    t = t:gsub("([%w%-%.]+%.[%w%-]+%/)", "http://%1")
    t = t:gsub("(https?://)http://", "%1")

    -- Ensure that any link immediately proceeded by a pipe didn't
    -- accidentally swallow up a color tag.
    t = t:gsub("|(https?://)c(%x%x%x%x%x%x%x%x)", "|c%2%1")
 
    -- Turn all markdown style links into WoW readable hyperlinks.
    t = t:gsub("%[([^%]]+)]%(%s*(.-)%s*%)", "|Hmrpweblink:%2|h|cff33FFEE[%1]|r|h")
 
    -- Replaces bare URLs. The additional "()" captures on either side will
    -- expose the indices in the original string where the URL is located.
    local URL_PATTERN = "()(https?://[%w:/?#%[%]@!$&'()*+,;=._%%-]+)()"
 
    -- Replace all matches of the bare URL pattern.
    return t:gsub(URL_PATTERN, function(start, url, finish)
        -- Skip the URL if the preceeding character is a ":" or if the
        -- immediate text afterwards looks like the end of an mrpweblink.
        if t:find("^:", start - 1) or t:find("^|r|h", finish) then
            -- Returning nothing will cause the URL to not be replaced.
            return
        end
			
 
       -- If a URL begins with a "(" then we want to additionally ignore
        -- any ")" immediately after it.
        if t:find("^%(", start - 1) then
            url, post = url:match("^(.-)(%)*)$")
        else
            -- URLs ending in certain special characters ("?", "!", ".", "]")
            -- will have those omitted from the URL since it's more likely
            -- they're intended to not be present.
            url, post = url:match("^(.-)([?!.%]]*)$")
        end
 
        -- Turn the URL into a WoW-readable hyperlink.
        return ("|Hmrpweblink:%s|h|cff33FFEE[%s]|r|h%s"):format(url, url, post)
    end)
end

function mrp:UpdateHTMLText() -- We need to refresh the text in the SimpleHTML frame on mrp:UpdateBrowseFrame and on resize, since the text doesn't adjust automatically like editboxes do.
	local player = mrp.BFShown or nil
	if not player or player == "" then
		return
	end
	local f = msp.char[ player ].field
	
	-- Description frame
	local t = mrp.DisplayBrowser.DE( f.DE )
	
	t = mrp:CreateURLLink(t) -- Swap links with clickable URLs.
	
	t = gsub(t, "#Physical Description\n\n", ""); -- TRP sends these because they use separate boxes. We can use these to split fields later, but right now they just look ugly.
	t = gsub(t, "%-%-%-\n\n#Personality Traits", "");
	
	t = mrp:ConvertStringToHTML(t) -- Convert all our text tags over to HTML format for the SimpleHTML frame, and add <HTML><BODY> tags etc.
	
	bfa.sf.html:SetText( t )
	ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameAScrollFrame)
	
	-- History frame
	t = mrp.DisplayBrowser.HI( f.HI )
	
	t = mrp:CreateURLLink(t); -- Swap links with clickable URLs.
	
	t = mrp:ConvertStringToHTML(t) -- Convert all our text tags over to HTML format for the SimpleHTML frame, and add <HTML><BODY> tags etc.
	
	bfb.sf.html:SetText( t )
	ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameBScrollFrame)
end
	

-- Update the text and so forth in the BrowseFrame
function mrp:UpdateBrowseFrame( player )
	lastViewedPlayer = player -- XC / Profile load progress
	player = player or mrp.BFShown or nil
	if not player or player == "" then
		return false
	end
	mrp.BFShown = player
	
	local f = msp.char[ player ].field
	local bf = MyRolePlayBrowseFrame

	MyRolePlayBrowseFrameTitleText:SetText( mrp.DisplayBrowser.NA( emptynil(f.NA) or player ) )
	if(f.IC and f.IC ~= "") then -- We'll use the icons sent through the IC field and place them in the super convenient portrait frame. c:
		local portraitFail = pcall(SetPortraitToTexture, "MyRolePlayBrowseFramePortrait", "Interface\\ICONS\\" .. f.IC) -- I don't know why some icons simply fail to work - More research is necessary.
		if(portraitFail) then
			SetPortraitToTexture( "MyRolePlayBrowseFramePortrait", ("Interface\\ICONS\\" .. f.IC) )
		else
			SetPortraitToTexture( "MyRolePlayBrowseFramePortrait", ("Interface\\Icons\\INV_Misc_Book_01") )
		end
	else
		SetPortraitToTexture( "MyRolePlayBrowseFramePortrait", ("Interface\\Icons\\INV_Misc_Book_01") )
	end
	
	-- Start playing music?
	if(f.MU and f.MU ~= "") then
		-- If they click the button to play music.
		MyRolePlayBrowseFrame_PlayMusicButton:SetScript( "OnClick", function(self)
			if(previousSoundHandle and previousSoundHandle ~= 0) then
				StopSound(previousSoundHandle)
			else
				previousSoundHandle = 0
			end
			_, previousSoundHandle = PlaySoundFile("Sound\\Music\\" .. f.MU .. ".mp3", "Master")
		end )
		MyRolePlayBrowseFrame_PlayMusicButton:Show()
		MyRolePlayBrowseFrame_PlayMusicButton:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_playmusic_button"], 0.97, 0.80, 0.05 )
			GameTooltip:AddLine( f.MU, 1.0, 1.0, 1.0, false )
			GameTooltip:Show()
		end )
		bf.pmb:SetScript( "OnLeave", GameTooltip_Hide )
		-- If they have autoplay on, just play it.
		if(mrpSaved.Options.AutoplayMusic == true and autoplayAttemptMade == false) then
			autoplayAttemptMade = true -- The browse frame update function fires multiple times when the viewer is up, so the music will repeat. Prevent it.
			if(previousSoundHandle and previousSoundHandle ~= 0) then
				StopSound(previousSoundHandle)
			else
				previousSoundHandle = 0
			end
			_, previousSoundHandle = PlaySoundFile("Sound\\Music\\" .. f.MU .. ".mp3", "Master")
		end
	else
		MyRolePlayBrowseFrame_PlayMusicButton:Hide() -- If they don't have music, don't show the button.
	end

	bf.ver:SetText( mrp.DisplayBrowser.VA( f.VA ) )
	bf.load:SetText( L["browser_loading_nonewdata"])
	bf.nickname:SetText( mrp.DisplayBrowser.NI( f.NI ) )
	bf.house:SetText( mrp.DisplayBrowser.NH( f.NH ) )
	bf.title:SetText( mrp.DisplayBrowser.NT( f.NT ) )
	
	-- Updates notes button to show note in tooltip if one exists. We need individual name and realm.
	local notesName
	local notesRealm
	if(mrp.BFShown:match("%-")) then
		notesName = mrp.BFShown:match("(.-)%-"):upper()
		notesRealm = mrp.BFShown:match(".-%-(.+)"):upper()
	else
		notesName = UnitName("player"):upper()
		notesRealm = GetRealmName():gsub(" ", ""):upper()
	end
	if(mrpNotes[notesRealm] and mrpNotes[notesRealm][notesName]) then
		MyRolePlayBrowseFrame_NotesButton:SetScript( "OnEnter", function(self)
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_notespresent_button"], 0.97, 0.80, 0.05 )
			GameTooltip:AddLine( mrpNotes[notesRealm][notesName], 1.0, 1.0, 1.0, true )
			GameTooltip:Show()
		end )
	else
		MyRolePlayBrowseFrame_NotesButton:SetScript( "OnEnter", function(self)
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["browser_notesnone_button"] )
			GameTooltip:Show()
		end )
	end

	bfa = bf.Appearance

	--bfa.fields.FR.t:SetText( mrp.DisplayBrowser.FR( f.FR ) )
	--bfa.fields.FC.t:SetText( mrp.DisplayBrowser.FC( f.FC ) )

	bfa.fields.RA.t:SetText( emptynil( mrp.DisplayBrowser.RA( f.RA ) ) or L[ mrp.DisplayBrowser.GR( f.GR ) ] )
	bfa.fields.RC.t:SetText( emptynil( mrp.DisplayBrowser.RC( f.RC ) ) or L[ mrp.DisplayBrowser.GC( f.GC ) ] ) -- RC

	bfa.fields.AE.t:SetText( mrp.DisplayBrowser.AE( f.AE ) )
	bfa.fields.AH.t:SetText( mrp.DisplayBrowser.AH( f.AH ) )
	bfa.fields.AW.t:SetText( mrp.DisplayBrowser.AW( f.AW ) )
	
	local data = mrp.DisplayBrowser.PE( f.PE ) .. "\n\n---\n\n";
	local icon, title, text;
	
	local glances = {};
	
	for icon, title, text in string.gmatch(data, "|T[^\n]+\\([^|:]+).-[\n]*#([^\n]+)[\n]*(.-)[\n]*%-%-%-[\n]*") do
		table.insert(glances, {icon, title, text});
	end
	
	for i = 1, 5, 1 do
		_G["Glance" .. i .. "BrowserListLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:Hide()
		_G["Glance" .. i .. "BrowserListRight"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconRight"]:Hide()
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:Hide()
	end
	
	local glancePosition
	
	if(mrpSaved.Options.GlancePosition == 0) then
		glancePosition = "Right"
	elseif(mrpSaved.Options.GlancePosition == 1) then
		glancePosition = "Left"
	end
	
	for i = 1, #glances, 1 do
		_G["Glance" .. i .. "BrowserListTextureIconRight"]:SetTexture("Interface\\Icons\\" .. glances[i][1])
		_G["Glance" .. i .. "BrowserListTextureIconLeft"]:SetTexture("Interface\\Icons\\" .. glances[i][1])
		_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( glances[i][2], 0.97, 0.80, 0.05, nil, true )
			GameTooltip:AddLine( glances[i][3], 1.0, 1.0, 1.0, true )
			GameTooltip:Show()
			_G["Glance" .. i .. "BrowserListTextureIconContainerRight"]:SetScript( "OnLeave", GameTooltip_Hide )
		end )
		_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( glances[i][2], 0.97, 0.80, 0.05, nil, true )
			GameTooltip:AddLine( glances[i][3], 1.0, 1.0, 1.0, true )
			GameTooltip:Show()
			_G["Glance" .. i .. "BrowserListTextureIconContainerLeft"]:SetScript( "OnLeave", GameTooltip_Hide )
		end )
		_G["Glance" .. i .. "BrowserList" .. glancePosition]:Show()
		_G["Glance" .. i .. "BrowserListTextureIcon" .. glancePosition]:Show()
		_G["Glance" .. i .. "BrowserListTextureIconContainer" .. glancePosition]:Show()
	end

	
	mrp:UpdateHTMLText() -- Update the DE / HI field in the browser in this function since they use a SimpleHTML frame.
	
	local defaultFont = GameFontNormal:GetFont() -- Get whatever font they're using so we use the same one when we change the font size.
	
	t = mrp.DisplayBrowser.CU( f.CU )
	
	t = mrp:CreateURLLink(t) -- Swap links with clickable URLs.
	
	if bfa.sfcu.editbox:GetText() ~= t then
		bfa.sfcu.editbox:SetText( t )
		bfa.sfcu.editbox:SetCursorPosition( 0 )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameCScrollFrame)
	end
	
	t = mrp.DisplayBrowser.CO( f.CO )
	
	t = mrp:CreateURLLink(t) -- Swap links with clickable URLs.
	
	if bfa.sfco.editbox:GetText() ~= t then
		bfa.sfco.editbox:SetText( t )
		bfa.sfco.editbox:SetCursorPosition( 0 )
		ScrollFrame_OnScrollRangeChanged(MyRolePlayBrowseFrameDScrollFrame)
	end
	
	bfc = bf.Personality
	
	personalityTraits = {} -- Table to hold all attributes.
	
	for trait in mrp.DisplayBrowser.PS( f.PS ):gmatch("%[trait [^%]]-%]") do
		local structure = {};

		for key, value in trait:gmatch("([%w_-]+)=\"([^\"]*)\"") do
			structure[key] = value;
		end

		table.insert(personalityTraits, structure);
	end
	
	mrp:ShowTraitBars(personalityTraits)

	bfb.fields.AG.t:SetText( mrp.DisplayBrowser.AG( f.AG ) )
	bfb.fields.HH.t:SetText( mrp.DisplayBrowser.HH( f.HH ) )
	bfb.fields.HB.t:SetText( mrp.DisplayBrowser.HB( f.HB ) )
	bfb.fields.MO.t:SetText( mrp.DisplayBrowser.MO( f.MO ) )
	bfb.fields.RS.t:SetText( mrp.DisplayBrowser.RS( f.RS ) )

	bf:Show()
end

-- A list of the fields which appear in the browse frame.
local bffields_full = { 'VP', 'VA', 'NA', 'NH', 'NI', 'NT', 'GR', 'RA', 'RC', 'FR', 'FC', 'AG', 'AE', 'AH', 'AW', 'HH', 'HB', 'MO', 'CU', 'DE', 'HI', 'CO', 'PE', 'RS', 'MU', 'PS' }
-- Same but without 'biographical' fields, as some users like the surprise
local bffields_nobiog = { 'VP', 'VA', 'NA', 'NH', 'NI', 'NT', 'GR', 'RA', 'RC', 'FR', 'FC', 'AE', 'AH', 'AW', 'CU', 'DE', 'CO', 'PE', 'RS', 'MU', 'PS' }

-- Make the request to another player to get all of the fields in the browse frame.
function mrp:RequestForBF( player )
	player = player or mrp.BFShown or nil
	if not player or player == "" or player == "Unknown" then
		return false
	end
	if mrpSaved.Options.ShowBiographyInBrowser == false then
		msp:Request( player, bffields_nobiog )
	else
		msp:Request( player, bffields_full )
	end
	mrp:UpdateBrowseFrame( player )
end

function mrp:Show( player )
	if not player or player == "" then
		if UnitIsUnit("player", "target") then
			--mrp:RequestForBF( UnitName("player") )
			mrp:UpdateBrowseFrame( player )
		elseif UnitIsPlayer("target") then
			if msp.char[ mrp:UnitNameWithRealm("target") ].supported == false then
				mrp:Print( L["%s doesn’t have a MSP compatible roleplay addon."], mrp:UnitNameWithRealm("target") )
			else
				mrp:RequestForBF( mrp:UnitNameWithRealm("target") )
			end
		else
			mrp:Print( L["Who do I show?"] )
		end
	else
		if msp.char[ player ].supported == false then
			mrp:Print( L["%s doesn’t have an MSP compatible roleplay addon."], player )
		else
			mrp:RequestForBF( player )
		end
	end
end

function mrp_MSPBrowserCallback( player )
	if player == mrp.BFShown then
		mrp:UpdateBrowseFrame( player )
	end
end

function mrp:BrowseFrameReset()
	mrpSaved.Positions.Browser = nil
	MyRolePlayBrowseFrame:StopMovingOrSizing()
	MyRolePlayBrowseFrame:ClearAllPoints()
	MyRolePlayBrowseFrame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
	MyRolePlayBrowseFrame:SetSize( 338, 424 )
	mrp_BrowseFrameSizeUpdate( MyRolePlayBrowseFrame, MyRolePlayBrowseFrame:GetWidth(), MyRolePlayBrowseFrame:GetHeight() )
end

function mrp:CheckBrowseFrameBounds()
	local bf = MyRolePlayBrowseFrame
	local _, _, w, h = UIParent:GetRect()
	local i, j, k, l = bf:GetRect()
	if i<0 or j<0 or k>w or l>(h-20) then
		mrp:BrowseFrameReset()
		mrp:Print( L["MRP browser rescued; automatically reset to default size & position as it was offscreen. Try /mrp browser reset if this persists."] )
	end
end