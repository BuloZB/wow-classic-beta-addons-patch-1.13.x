--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Options.lua - The options panel
]]

local L = mrp.L

-- BUG: Cancel doesn't. Not terribly worried about this.

-- I love it when Blizzard do most of the hard work for me.
function mrp:CreateOptionsPanel()
	if not MyRolePlayOptionsPanel then 
		local c = InterfaceOptionsFramePanelContainer
		local f = CreateFrame( "Frame", "MyRolePlayOptionsPanel", c )
		mrpopts = f
		f:Hide()
		f:SetPoint( "TOPLEFT" , c, "TOPLEFT" )
		f:SetPoint( "BOTTOMRIGHT", c, "BOTTOMRIGHT" )

		f.name = "MyRolePlay"
		f.options = {
			enable = { text = L["opt_enable"], tooltip = L["opt_enable_tt"] },
			mrpbutton = { text = L["opt_mrpbutton"], tooltip = L["opt_mrpbutton_tt"] },
			allowcolours = { text = L["opt_allowcolours"], tooltip = L["opt_allowcolours_tt"] },
			tooltipnamecolours = { text = L["opt_tooltipnamecolours"], tooltip = L["opt_tooltipnamecolours_tt"] },
			tooltipclasscolours = { text = L["opt_tooltipclasscolours"], tooltip = L["opt_tooltipclasscolours_tt"] },
			classnames = { text = L["opt_classnames"], tooltip = L["opt_classnames_tt"] },
			showooc = { text = L["opt_showooc"], tooltip = L["opt_showooc_tt"] },
			showtarget = { text = L["opt_showtarget"], tooltip = L["opt_showtarget_tt"] },
			showiconintt = { text = L["opt_showiconintt"], tooltip = L["opt_showiconintt_tt"] },
			autoplaymusic = { text = L["opt_autoplaymusic"], tooltip = L["opt_autoplaymusic_tt"] },
			showversion = { text = L["opt_showversion"], tooltip = L["opt_showversion_tt"] },
			hidettinencounters = { text = L["opt_hidettinencounters"], tooltip = L["opt_hidettinencounters_tt"] },
			showguildnames = { text = L["opt_showguildnames"], tooltip = L["opt_showguildnames_tt"] },
			maxlinesslider = { text = L["opt_maxlinesslider"], tooltip = L["opt_maxlinesslider_tt"] },
			showglancepreview = { text = L["opt_showglancepreview"], tooltip = L["opt_showglancepreview_tt"] },
			ttstyle = { },
			rpchatsay = { text = L["opt_rpchatnamesay"], tooltip = L["opt_rpchatnamesay_tt"] },
			rpchatwhisper = { text = L["opt_rpchatnamewhisper"], tooltip = L["opt_rpchatnamewhisper_tt"] },
			rpchatemote = { text = L["opt_rpchatnameemote"], tooltip = L["opt_rpchatnameemote_tt"] },
			rpchatyell = { text = L["opt_rpchatnameyell"], tooltip = L["opt_rpchatnameyell_tt"] },
			rpchatparty = { text = L["opt_rpchatnameparty"], tooltip = L["opt_rpchatnameparty_tt"] },
			rpchatraid = { text = L["opt_rpchatnameraid"], tooltip = L["opt_rpchatnameraid_tt"] },
			showiconsinchat = { text = L["opt_showiconsinchat"], tooltip = L["opt_showiconsinchat_tt"] },
			glanceposition = { },
			ahunit = { },
			awunit = { },
			formac = { text = L["opt_formac"] },
			equipac = { text = L["opt_equipac"], tooltip = L["opt_equipac_tt"] },
			biog = { text = L["opt_biog"], tooltip = L["opt_biog_tt"] },
			traits = { text = L["opt_traits"], tooltip = L["opt_traits_tt"] }
		}

		-- form auto change: Use the right tooltip for the job.
		if select( 2, UnitRace("player") ) == "Worgen" then
			if select( 2, UnitClass("player") ) == "DRUID" then
				f.options.formac.tooltip = L["opt_formac_tt_worgendruid"]
			elseif select( 2, UnitClass("player") ) == "PRIEST" then
				f.options.formac.tooltip = L["opt_formac_tt_worgenpriest"]
			elseif select( 2, UnitClass("player") ) == "WARLOCK" then
				f.options.formac.tooltip = L["opt_formac_tt_worgenwarlock"]
			else
				f.options.formac.tooltip = L["opt_formac_tt_worgen"]
			end
		else
			if select( 2, UnitClass("player") ) == "DRUID" then
				f.options.formac.tooltip = L["opt_formac_tt_druid"]
			elseif select( 2, UnitClass("player") ) == "SHAMAN" then
				f.options.formac.tooltip = L["opt_formac_tt_shaman"]
			elseif select( 2, UnitClass("player") ) == "PRIEST" then
				f.options.formac.tooltip = L["opt_formac_tt_priest"]
			elseif select( 2, UnitClass("player") ) == "WARLOCK" then
				f.options.formac.tooltip = L["opt_formac_tt_warlock"]
			else
				f.options.formac.tooltip = L["opt_formac_tt_disabled"]
			end
		end
		-- Save memory; we don't need them anymore
		L["opt_formac_tt"] = nil
		L["opt_formac_tt_druid"] = nil
		L["opt_formac_tt_shaman"] = nil
		L["opt_formac_tt_priest"] = nil
		L["opt_formac_tt_warlock"] = nil
		L["opt_formac_tt_suffix"] = nil
		L["opt_formac_tt_worgen"] = nil
		L["opt_formac_tt_worgendruid"] = nil
		L["opt_formac_tt_worgenshaman"] = nil
		L["opt_formac_tt_worgenpriest"] = nil
		L["opt_formac_tt_worgenwarlock"] = nil
		L["opt_formac_tt_worgensuffix"] = nil
		L["opt_formac_tt_disabled"] = nil
		L["opt_formac_tt_enabled1"] = nil

		f.title = f:CreateFontString( nil, "OVERLAY", "GameFontNormalLarge" )
		f.title:SetPoint( "TOPLEFT", 16, -16 )
		f.title:SetJustifyH( "LEFT" )
		f.title:SetJustifyV( "TOP" )
		f.title:SetText( "MyRolePlay" )

		f.ver = f:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
		f.ver:SetPoint( "TOP", f.title )
		f.ver:SetPoint( "RIGHT", f, -32, 0 )
		f.ver:SetJustifyH( "RIGHT" )
		f.ver:SetText( mrp.VerInfo )

		--[[f.st = f:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" ) -- Maybe we can add this back somewhere later, space is a bit limited right now.
		f.st:SetJustifyH( "LEFT" )
		f.st:SetJustifyV( "TOP" )
		f.st:SetPoint( "TOPLEFT", f.title, "BOTTOMLEFT", 0, -8 )
		f.st:SetPoint( "RIGHT", f, -32, 0 )
		f.st:SetWordWrap( true )
		f.st:SetHeight( 32 )
		f.st:SetText( L["mrp_addon_notes"] )]]
		
		-- "Basic Functionality" header
		f.BasicFunctionalityHeader = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.BasicFunctionalityHeader:SetJustifyH( "LEFT" )
		f.BasicFunctionalityHeader:SetJustifyV( "TOP" )
		f.BasicFunctionalityHeader:SetPoint( "TOPLEFT", f.title, "BOTTOMLEFT", 0, -5 )
		f.BasicFunctionalityHeader:SetText( L["opt_basicfunctionality_header"] )

		-- Enable / Disable MRP completely box
		f.enable = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_Enable", f, "InterfaceOptionsCheckButtonTemplate" )
		f.enable:SetPoint( "TOPLEFT", f.BasicFunctionalityHeader, "BOTTOMLEFT", -2, 0 )
		f.enable.avoiddisabling = true
		f.enable.label = "enable"
		f.enable.type = CONTROLTYPE_CHECKBOX
		f.enable.defaultValue = mrp.DefaultOptions.Enabled and "1" or "0"
		f.enable.GetValue = function()
			return mrpSaved.Options.Enabled and "1" or "0"
		end
		f.enable.setFunc = function( setting )
			if setting == "1" then
				mrp:Enable()
				for k, v in ipairs(MyRolePlayOptionsPanel.controls) do
					v:Enable()
				end
				if mtt then f.ttstyle:Disable() end -- If MyToolTip is loaded, let the beast handle it
			else
				mrp:Disable()
				for k, v in ipairs(MyRolePlayOptionsPanel.controls) do
					if not v.avoiddisabling then
						v:Disable()
					end
				end
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.enable, f )

		-- Enable / Disable MRP button
		f.mrpbutton = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_MRPButton", f, "InterfaceOptionsCheckButtonTemplate" )
		f.mrpbutton:SetPoint( "TOPLEFT", f.enable, "BOTTOMLEFT", 0, 5 )
		f.mrpbutton.label = "mrpbutton"
		f.mrpbutton.type = CONTROLTYPE_CHECKBOX
		f.mrpbutton.defaultValue = mrp.DefaultOptions.ShowButton and "1" or "0"
		f.mrpbutton.GetValue = function()
			return mrpSaved.Options.ShowButton and "1" or "0"
		end
		f.mrpbutton.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowButton = true
				mrp:TargetChanged() -- will display button if appropriate
			else
				mrpSaved.Options.ShowButton = false
				MyRolePlayButton:Hide()
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.mrpbutton, f )
		
		-- Show glance preview box
		f.showglancepreview = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowGlancePreview", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showglancepreview:SetPoint( "TOPLEFT", f.mrpbutton, "BOTTOMLEFT", 0, 5 )
		f.showglancepreview.label = "showglancepreview"
		f.showglancepreview.type = CONTROLTYPE_CHECKBOX
		f.showglancepreview.defaultValue = mrp.DefaultOptions.ShowGlancePreview and "1" or "0"
		f.showglancepreview.GetValue = function()
			return mrpSaved.Options.ShowGlancePreview and "1" or "0"
		end
		f.showglancepreview.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowGlancePreview = true
			else
				mrpSaved.Options.ShowGlancePreview = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showglancepreview, f )
		
		-- Allow colours in profiles / tooltip
		f.allowcolours = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_AllowColours", f, "InterfaceOptionsCheckButtonTemplate" )
		f.allowcolours:SetPoint( "TOPLEFT", f.showglancepreview, "BOTTOMLEFT", 0, 5 )
		f.allowcolours.label = "allowcolours"
		f.allowcolours.type = CONTROLTYPE_CHECKBOX
		f.allowcolours.defaultValue = mrp.DefaultOptions.AllowColours and "1" or "0"
		f.allowcolours.GetValue = function()
			return mrpSaved.Options.AllowColours and "1" or "0"
		end
		f.allowcolours.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.AllowColours = true
				f.tooltipclasscolours:Enable();
			else
				mrpSaved.Options.AllowColours = false
				f.tooltipclasscolours:Disable();
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.allowcolours, f )
		
		-- SUB-BUTTONS FOR COLOURS
		-- Use custom class colour in tooltip
		f.tooltipclasscolours = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_TooltipClassColours", f, "InterfaceOptionsCheckButtonTemplate" )
		f.tooltipclasscolours:SetPoint( "TOPLEFT", f.allowcolours, "BOTTOMLEFT", 20, 5 )
		f.tooltipclasscolours.label = "tooltipclasscolours"
		f.tooltipclasscolours.type = CONTROLTYPE_CHECKBOX
		f.tooltipclasscolours.defaultValue = mrp.DefaultOptions.TooltipClassColours and "1" or "0"
		f.tooltipclasscolours.GetValue = function()
			return mrpSaved.Options.TooltipClassColours and "1" or "0"
		end
		f.tooltipclasscolours.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.TooltipClassColours = true
			else
				mrpSaved.Options.TooltipClassColours = false
			end
		end
		f.tooltipclasscolours:SetHeight(22)
		f.tooltipclasscolours:SetWidth(22)
		BlizzardOptionsPanel_RegisterControl( f.tooltipclasscolours, f )
		
		-- Run on startup to disable these checkboxes if colours are disabled.
		if(mrpSaved.Options.AllowColours == false) then
			f.tooltipclasscolours:Disable();
		end
		
		-- Autoplay music
		f.autoplaymusic = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_DisableMusic", f, "InterfaceOptionsCheckButtonTemplate" )
		f.autoplaymusic:SetPoint( "TOPLEFT", f.tooltipclasscolours, "BOTTOMLEFT", -20, 5 )
		f.autoplaymusic.label = "autoplaymusic"
		f.autoplaymusic.type = CONTROLTYPE_CHECKBOX
		f.autoplaymusic.defaultValue = mrp.DefaultOptions.AutoplayMusic and "1" or "0"
		f.autoplaymusic.GetValue = function()
			return mrpSaved.Options.AutoplayMusic and "1" or "0"
		end
		f.autoplaymusic.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.AutoplayMusic = true
			else
				mrpSaved.Options.AutoplayMusic = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.autoplaymusic, f )
		
		-- Change header colour
		f.headercolour = CreateFrame("Frame", "MyRolePlayOptionsPanel_HeaderColourFrame", f)
		f.headercolour:SetPoint( "TOPLEFT", f.autoplaymusic, "BOTTOMRIGHT", -23, 1 )
		f.headercolour:SetHeight(15)
		f.headercolour:SetWidth(175)
		local headercolourtexture = f.headercolour:CreateTexture("MyRolePlayOptionsPanel_HeaderColourTexture", "ARTWORK")
		headercolourtexture:SetTexture("Interface\\AddOns\\MyRolePlay\\Artwork\\HeaderBackground.blp")
		headercolourtexture:SetAllPoints(f.headercolour)
		if(mrpSaved.Options["headerColour"]) then
			headercolourtexture:SetVertexColor(mrpSaved.Options["headerColour"]["r"], mrpSaved.Options["headerColour"]["g"], mrpSaved.Options["headerColour"]["b"]);
		else
			mrpSaved.Options["headerColour"] = {}
			mrpSaved.Options["headerColour"]["r"] = 1
			mrpSaved.Options["headerColour"]["g"] = 0
			mrpSaved.Options["headerColour"]["b"] = 0.101
			headercolourtexture:SetVertexColor(1, 0, 0.101)
		end
		
		f.headercolour.fs = f.headercolour:CreateFontString( nil, "ARTWORK", "GameFontNormalSmall" )
		f.headercolour.fs:SetJustifyH( "LEFT" )
		f.headercolour.fs:SetText( L["opt_headercolour_label"] )
		f.headercolour.fs:SetParent( f.headercolour )
		f.headercolour.fs:SetShadowColor( 0, 0, 0, 0.1 )
		f.headercolour.fs:SetAllPoints()
		f.headercolour.fs:SetPoint("TOPLEFT", f.headercolour, "TOPLEFT", 0, 3 )
		
		f.headercolour:SetScript("OnMouseDown", function (self)
			StaticPopupDialogs[ "MRP_HEADERCOLOUR_RELOAD" ] = {
				text = format( L["opt_headercolour_popup"] ),
				button1 = OKAY or "OK",
				whileDead = true,
				timeout = 0,
			}
			StaticPopup_Show( "MRP_HEADERCOLOUR_RELOAD" )
			local savedR, savedG, savedB
			if(mrpSaved.Options["headerColour"]) then
				savedR = mrpSaved.Options["headerColour"]["r"]
				savedG = mrpSaved.Options["headerColour"]["g"]
				savedB = mrpSaved.Options["headerColour"]["b"]
			else
				savedR, savedG, savedB = 0.69, 0.29, 1 -- Default purple, no previous values set.
			end
			mrp_ShowColourPicker(savedR, savedG, savedB, 1, mrp_HeaderColourChangedCallback)
		end )
		
		-- "Tooltip Settings" header
		f.TooltipDesignHeader = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.TooltipDesignHeader:SetJustifyH( "LEFT" )
		f.TooltipDesignHeader:SetJustifyV( "TOP" )
		f.TooltipDesignHeader:SetPoint( "TOPLEFT", f.autoplaymusic, "BOTTOMLEFT", 2, -30 )
		f.TooltipDesignHeader:SetText( L["opt_tooltipdesign_header"] )
		
		-- Tooltip Style dropdown
		f.ttstyle = CreateFrame( "Frame", "MyRolePlayOptionsPanel_TTStyle", f, "UIDropDownMenuTemplate" )
		f.ttstyle:SetPoint( "TOPLEFT", f.TooltipDesignHeader, "BOTTOMLEFT", -20, -17 )
		f.ttstyle.type = CONTROLTYPE_DROPDOWN
		f.ttstyle.isoption = "TooltipStyle"
		UIDropDownMenu_SetWidth( f.ttstyle, 125 )
		f.ttstyle:EnableMouse( true )
		f.ttstyle.label = "ttstyle"
		
		-- "Tooltip style" header
		f.ttstyle.capt = f.ttstyle:CreateFontString( "MyRolePlayOptionsPanel_TTStyleLabel", "OVERLAY", "GameFontHighlightSmall" )
		f.ttstyle.capt:SetJustifyH( "LEFT" )
		f.ttstyle.capt:SetJustifyV( "TOP" )
		f.ttstyle.capt:SetPoint( "TOPLEFT", f.TooltipDesignHeader, "BOTTOMLEFT", 0, -4 )
		f.ttstyle.capt:SetText( L["opt_tooltipstyle_header"] )

		f.ttstyle.dd = CreateFrame( "Button", "MyRolePlayOptionsPanel_TTStyleDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_TTStyleButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "ttstyle" ], MyRolePlayOptionsPanel_TTStyleDropDown, MyRolePlayOptionsPanel_TTStyle, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_TTStyle, mrpSaved.Options.TooltipStyle )
			end
		end )
		f.ttstyle.Disable = UIDropDownMenu_DisableDropDown
		f.ttstyle.Enable = UIDropDownMenu_EnableDropDown
		f.ttstyle.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.TooltipStyle )
			MyRolePlayOptionsPanel_TTStyleText:SetText( mrp.optionscomboboxfields[ "ttstyle" ][ mrpSaved.Options.TooltipStyle + 1 ].text )
		end
		MyRolePlayOptionsPanel_TTStyleText:SetText( mrp.optionscomboboxfields[ "ttstyle" ][ mrpSaved.Options.TooltipStyle + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.ttstyle, f )
		if mtt then f.ttstyle:Disable() end -- If MyToolTip is loaded, let the beast handle it
		
		-- Max lines slider
		f.maxlinesslider = CreateFrame("Slider", "MyRolePlayOptionsPanel_MaxLinesSlider", f, "OptionsSliderTemplate")
		getglobal(f.maxlinesslider:GetName() .. 'Low'):SetText('1');
		getglobal(f.maxlinesslider:GetName() .. 'High'):SetText('10');
		f.maxlinesslider:SetPoint( "TOPLEFT", f.ttstyle, "BOTTOMLEFT", 15, -10 )
		f.maxlinesslider.type = CONTROLTYPE_SLIDER
		f.maxlinesslider:SetMinMaxValues(1, 10)
		f.maxlinesslider:SetValueStep(1)
		f.maxlinesslider:SetObeyStepOnDrag(true)
		f.maxlinesslider.defaultValue = mrp.DefaultOptions.MaxLinesSlider
		f.maxlinesslider:SetValue(mrpSaved.Options.MaxLinesSlider or mrp.DefaultOptions.MaxLinesSlider)
		f.maxlinesslider.sliderLabel = f.maxlinesslider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		f.maxlinesslider.sliderLabel:SetPoint("TOP", f.maxlinesslider.Thumb, "BOTTOM", 0, 5);
		f.maxlinesslider.sliderLabel:SetText( tostring(f.maxlinesslider:GetValue()))
		f.maxlinesslider:SetScript("OnValueChanged", function()
			mrpSaved.Options.MaxLinesSlider = f.maxlinesslider:GetValue()
			f.maxlinesslider.sliderLabel:SetText( tostring(f.maxlinesslider:GetValue()))
		end);
		
		getglobal(f.maxlinesslider:GetName() .. 'Text'):SetText( L["opt_maxtooltiplines_header"] )
		f.maxlinesslider.tooltipText = 'Change the maximum number of lines displayed for the currently and OOC fields.'
		BlizzardOptionsPanel_RegisterControl( f.maxlinesslider, f )
		
		-- Show in tooltip... header
		f.ShowInTooltipHeader = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.ShowInTooltipHeader:SetJustifyH( "LEFT" )
		f.ShowInTooltipHeader:SetJustifyV( "TOP" )
		f.ShowInTooltipHeader:SetPoint( "TOPLEFT", f.maxlinesslider, "BOTTOMLEFT", 2, -15 )
		f.ShowInTooltipHeader:SetText( L["opt_showintooltip_header"] )
		
		-- Show custom class names
		f.classnames = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ClassNames", f, "InterfaceOptionsCheckButtonTemplate" )
		f.classnames:SetPoint( "TOPLEFT", f.ShowInTooltipHeader, "BOTTOMLEFT", 2, -4 )
		f.classnames.label = "classnames"
		f.classnames.type = CONTROLTYPE_CHECKBOX
		f.classnames.defaultValue = mrp.DefaultOptions.ClassNames and "1" or "0"
		f.classnames.GetValue = function()
			return mrpSaved.Options.ClassNames and "1" or "0"
		end
		f.classnames.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ClassNames = true
			else
				mrpSaved.Options.ClassNames = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.classnames, f )
		
		-- Show OOC field in tooltip
		f.showooc = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowOOC", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showooc:SetPoint( "TOPLEFT", f.classnames, "BOTTOMLEFT", 0, 5 )
		f.showooc.label = "showooc"
		f.showooc.type = CONTROLTYPE_CHECKBOX
		f.showooc.defaultValue = mrp.DefaultOptions.ShowOOC and "1" or "0"
		f.showooc.GetValue = function()
			return mrpSaved.Options.ShowOOC and "1" or "0"
		end
		f.showooc.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowOOC = true
			else
				mrpSaved.Options.ShowOOC = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showooc, f )
		
		-- Show target in tooltip
		f.showtarget = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowTarget", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showtarget:SetPoint( "TOPLEFT", f.showooc, "BOTTOMLEFT", 0, 5 )
		f.showtarget.label = "showtarget"
		f.showtarget.type = CONTROLTYPE_CHECKBOX
		f.showtarget.defaultValue = mrp.DefaultOptions.ShowTarget and "1" or "0"
		f.showtarget.GetValue = function()
			return mrpSaved.Options.ShowTarget and "1" or "0"
		end
		f.showtarget.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowTarget = true
			else
				mrpSaved.Options.ShowTarget = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showtarget, f )
		
		-- Show addon info in tooltip
		f.showversion = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowVersion", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showversion:SetPoint( "TOPLEFT", f.showtarget, "BOTTOMLEFT", 0, 5 )
		f.showversion.label = "showversion"
		f.showversion.type = CONTROLTYPE_CHECKBOX
		f.showversion.defaultValue = mrp.DefaultOptions.ShowVersion and "1" or "0"
		f.showversion.GetValue = function()
			return mrpSaved.Options.ShowVersion and "1" or "0"
		end
		f.showversion.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowVersion = true
			else
				mrpSaved.Options.ShowVersion = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showversion, f )
		
		-- Show custom icons in tooltip
		f.showiconintt = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowIconInTT", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showiconintt:SetPoint( "TOPLEFT", f.showversion, "BOTTOMLEFT", 0, 5 )
		f.showiconintt.label = "showiconintt"
		f.showiconintt.type = CONTROLTYPE_CHECKBOX
		f.showiconintt.defaultValue = mrp.DefaultOptions.ShowIconInTT and "1" or "0"
		f.showiconintt.GetValue = function()
			return mrpSaved.Options.ShowIconInTT and "1" or "0"
		end
		f.showiconintt.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowIconInTT = true
			else
				mrpSaved.Options.ShowIconInTT = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showiconintt, f )
		
		-- Show guild rank in tooltip
		f.showguildnames = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowGuildNames", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showguildnames:SetPoint( "TOPLEFT", f.showiconintt, "BOTTOMLEFT", 0, 5 )
		f.showguildnames.label = "showguildnames"
		f.showguildnames.type = CONTROLTYPE_CHECKBOX
		f.showguildnames.defaultValue = mrp.DefaultOptions.ShowGuildNames and "1" or "0"
		f.showguildnames.GetValue = function()
			return mrpSaved.Options.ShowGuildNames and "1" or "0"
		end
		f.showguildnames.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowGuildNames = true
			else
				mrpSaved.Options.ShowGuildNames = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.showguildnames, f )
		
		-- Hide MRP tooltip in raid fights
		f.hidettinencounters = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_HideTTInEncounters", f, "InterfaceOptionsCheckButtonTemplate" )
		f.hidettinencounters:SetPoint( "TOPLEFT", f.showguildnames, "BOTTOMLEFT", 0, 5 )
		f.hidettinencounters.label = "hidettinencounters"
		f.hidettinencounters.type = CONTROLTYPE_CHECKBOX
		f.hidettinencounters.defaultValue = mrp.DefaultOptions.HideTTInEncounters and "1" or "0"
		f.hidettinencounters.GetValue = function()
			return mrpSaved.Options.HideTTInEncounters and "1" or "0"
		end
		f.hidettinencounters.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.HideTTInEncounters = true
			else
				mrpSaved.Options.HideTTInEncounters = false
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.hidettinencounters, f )
		
		-- "Chat Settings" header
		f.ChatSettingsHeader = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.ChatSettingsHeader:SetJustifyH( "LEFT" )
		f.ChatSettingsHeader:SetJustifyV( "TOP" )
		f.ChatSettingsHeader:SetPoint( "LEFT", f.BasicFunctionalityHeader, "RIGHT", 180, 0 )
		f.ChatSettingsHeader:SetText( L["opt_chatsettings_header"] )
		
		-- "Show RP names in..." header
		f.RPNamesHeader = f:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
		f.RPNamesHeader:SetJustifyH( "LEFT" )
		f.RPNamesHeader:SetJustifyV( "TOP" )
		f.RPNamesHeader:SetPoint( "TOPLEFT", f.ChatSettingsHeader, "BOTTOMLEFT", 0, -4 )
		f.RPNamesHeader:SetText( L["opt_rpnamesinchat_header"] )
		
		-- Show RP Names in /say
		f.rpchatsay = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatSay", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatsay:SetPoint( "TOPLEFT", f.RPNamesHeader, "BOTTOMLEFT", -2, -2 )
		f.rpchatsay.label = "rpchatsay"
		f.rpchatsay.type = CONTROLTYPE_CHECKBOX
		f.rpchatsay.defaultValue = mrp.DefaultOptions.RPChatSay and "1" or "0"
		f.rpchatsay.GetValue = function()
			return mrpSaved.Options.RPChatSay and "1" or "0"
		end
		f.rpchatsay.setFunc = function( setting )
			mrpSaved.Options.RPChatSay = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatsay, f )
		
		-- Show RP Names in /whisper
		f.rpchatwhisper = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatWhisper", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatwhisper:SetPoint( "TOPLEFT", f.rpchatsay, "BOTTOMLEFT", 0, 5 )
		f.rpchatwhisper.label = "rpchatwhisper"
		f.rpchatwhisper.type = CONTROLTYPE_CHECKBOX
		f.rpchatwhisper.defaultValue = mrp.DefaultOptions.RPChatWhisper and "1" or "0"
		f.rpchatwhisper.GetValue = function()
			return mrpSaved.Options.RPChatWhisper and "1" or "0"
		end
		f.rpchatwhisper.setFunc = function( setting )
			mrpSaved.Options.RPChatWhisper = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatwhisper, f )
		
		-- Show RP Names in /emote
		f.rpchatemote = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatEmote", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatemote:SetPoint( "TOPLEFT", f.rpchatwhisper, "BOTTOMLEFT", 0, 5 )
		f.rpchatemote.label = "rpchatemote"
		f.rpchatemote.type = CONTROLTYPE_CHECKBOX
		f.rpchatemote.defaultValue = mrp.DefaultOptions.RPChatEmote and "1" or "0"
		f.rpchatemote.GetValue = function()
			return mrpSaved.Options.RPChatEmote and "1" or "0"
		end
		f.rpchatemote.setFunc = function( setting )
			mrpSaved.Options.RPChatEmote = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatemote, f )
		
		-- Show RP Names in /yell
		f.rpchatyell = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatYell", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatyell:SetPoint( "TOPLEFT", f.rpchatemote, "BOTTOMLEFT", 0, 5 )
		f.rpchatyell.label = "rpchatyell"
		f.rpchatyell.type = CONTROLTYPE_CHECKBOX
		f.rpchatyell.defaultValue = mrp.DefaultOptions.RPChatYell and "1" or "0"
		f.rpchatyell.GetValue = function()
			return mrpSaved.Options.RPChatYell and "1" or "0"
		end
		f.rpchatyell.setFunc = function( setting )
			mrpSaved.Options.RPChatYell = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatyell, f )
		
		-- Show RP Names in /party
		f.rpchatparty = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatParty", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatparty:SetPoint( "TOPLEFT", f.rpchatyell, "BOTTOMLEFT", 0, 5 )
		f.rpchatparty.label = "rpchatparty"
		f.rpchatparty.type = CONTROLTYPE_CHECKBOX
		f.rpchatparty.defaultValue = mrp.DefaultOptions.RPChatParty and "1" or "0"
		f.rpchatparty.GetValue = function()
			MRP_Refresh_RPChats() -- Refresh RPEVENTS table in ChatName.lua so it updates with their new selection right away.
			return mrpSaved.Options.RPChatParty and "1" or "0"
		end
		f.rpchatparty.setFunc = function( setting )
			mrpSaved.Options.RPChatParty = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatparty, f )
		
		-- Show RP Names in /raid
		f.rpchatraid = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_RPChatRaid", f, "InterfaceOptionsCheckButtonTemplate" )
		f.rpchatraid:SetPoint( "TOPLEFT", f.rpchatparty, "BOTTOMLEFT", 0, 5 )
		f.rpchatraid.label = "rpchatraid"
		f.rpchatraid.type = CONTROLTYPE_CHECKBOX
		f.rpchatraid.defaultValue = mrp.DefaultOptions.RPChatRaid and "1" or "0"
		f.rpchatraid.GetValue = function()
			return mrpSaved.Options.RPChatRaid and "1" or "0"
		end
		f.rpchatraid.setFunc = function( setting )
			mrpSaved.Options.RPChatRaid = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.rpchatraid, f )
		
		-- Show icons in chat
		f.showiconsinchat = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_ShowIconsInChat", f, "InterfaceOptionsCheckButtonTemplate" )
		f.showiconsinchat:SetPoint( "TOPLEFT", f.rpchatraid, "BOTTOMLEFT", 0, 1 )
		f.showiconsinchat.label = "showiconsinchat"
		f.showiconsinchat.type = CONTROLTYPE_CHECKBOX
		f.showiconsinchat.defaultValue = mrp.DefaultOptions.ShowIconsInChat and "1" or "0"
		f.showiconsinchat.GetValue = function()
			return mrpSaved.Options.ShowIconsInChat and "1" or "0"
		end
		f.showiconsinchat.setFunc = function( setting )
			mrpSaved.Options.ShowIconsInChat = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.showiconsinchat, f )
		
		-- "Profile Display" header
		f.dh = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.dh:SetJustifyH( "LEFT" )
		f.dh:SetJustifyV( "TOP" )
		f.dh:SetPoint( "TOPLEFT", f.showiconsinchat, "BOTTOMLEFT", 2, -5 )
		f.dh:SetText( L["opt_disp_header"] )
		
		-- Show Personality Traits tab checkbox
		f.traits = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_Traits", f, "InterfaceOptionsCheckButtonTemplate" )
		f.traits:SetPoint( "TOPLEFT", f.dh, "BOTTOMLEFT", -2, -2 )
		f.traits.label = "traits"
		f.traits.type = CONTROLTYPE_CHECKBOX
		f.traits.defaultValue = mrp.DefaultOptions.ShowTraitsInBrowser and "1" or "0"
		f.traits.GetValue = function()
			return mrpSaved.Options.ShowTraitsInBrowser and "1" or "0"
		end
		f.traits.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowTraitsInBrowser = true
				MyRolePlayBrowseFrameTab2:Show()
				MyRolePlayBrowseFrameTab3:SetPoint( "LEFT", MyRolePlayBrowseFrameTab2, "RIGHT", -15, 0 )
				if mrp.BFShown then
					mrp:RequestForBF()
				end
			else
				mrpSaved.Options.ShowTraitsInBrowser = false
				if mrp.BFShown and MyRolePlayBrowseFrame.Personality:IsVisible() then
					mrp:TabSwitchBF( "Appearance" )
				end
				MyRolePlayBrowseFrameTab2:Hide()
				MyRolePlayBrowseFrameTab3:SetPoint( "LEFT", MyRolePlayBrowseFrameTab1, "RIGHT", -15, 0 )
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.traits, f )
		
		-- Show biography tab checkbox
		f.biog = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_Biog", f, "InterfaceOptionsCheckButtonTemplate" )
		f.biog:SetPoint( "TOPLEFT", f.traits, "BOTTOMLEFT", 0, 5 )
		f.biog.label = "biog"
		f.biog.type = CONTROLTYPE_CHECKBOX
		f.biog.defaultValue = mrp.DefaultOptions.ShowBiographyInBrowser and "1" or "0"
		f.biog.GetValue = function()
			return mrpSaved.Options.ShowBiographyInBrowser and "1" or "0"
		end
		f.biog.setFunc = function( setting )
			if setting == "1" then
				mrpSaved.Options.ShowBiographyInBrowser = true
				MyRolePlayBrowseFrameTab3:Show()
				if mrp.BFShown then
					mrp:RequestForBF()
				end
			else
				mrpSaved.Options.ShowBiographyInBrowser = false
				if mrp.BFShown and MyRolePlayBrowseFrame.Biography:IsVisible() then
					mrp:TabSwitchBF( "Appearance" )
				end
				MyRolePlayBrowseFrameTab3:Hide()
			end
		end
		BlizzardOptionsPanel_RegisterControl( f.biog, f )
		
		-- Glance position drop down box
		f.glanceposition = CreateFrame( "Button", "MyRolePlayOptionsPanel_GlancePosition", f, "UIDropDownMenuTemplate" )
		f.glanceposition:SetPoint( "TOPLEFT", f.dh, "BOTTOMLEFT", -17, -63 )
		f.glanceposition.type = CONTROLTYPE_DROPDOWN
		f.glanceposition.isoption = "GlancePosition"
		UIDropDownMenu_SetWidth( f.glanceposition, 130 )
		f.glanceposition:EnableMouse( true )
		f.glanceposition.label = "glanceposition"
		
		f.glanceposition.capt = f.glanceposition:CreateFontString( "MyRolePlayOptionsPanel_GlancePositionLabel", "OVERLAY", "GameFontHighlightSmall" )
		f.glanceposition.capt:SetJustifyH( "LEFT" )
		f.glanceposition.capt:SetJustifyV( "TOP" )
		f.glanceposition.capt:SetPoint( "TOPLEFT", f.biog, "BOTTOMLEFT", 2, 0 )
		f.glanceposition.capt:SetText( L["opt_glanceposition_header"] )
		
		f.glanceposition.dd = CreateFrame( "Button", "MyRolePlayOptionsPanel_GlancePositionDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_GlancePositionButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "glanceposition" ], MyRolePlayOptionsPanel_GlancePositionDropDown, MyRolePlayOptionsPanel_GlancePosition, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_GlancePosition, mrpSaved.Options.GlancePosition )
			end
		end )
		f.glanceposition.Disable = UIDropDownMenu_DisableDropDown
		f.glanceposition.Enable = UIDropDownMenu_EnableDropDown
		f.glanceposition.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.GlancePosition )
			MyRolePlayOptionsPanel_GlancePositionText:SetText( mrp.optionscomboboxfields[ "glanceposition" ][ mrpSaved.Options.GlancePosition + 1 ].text )
		end
		MyRolePlayOptionsPanel_GlancePositionText:SetText( mrp.optionscomboboxfields[ "glanceposition" ][ mrpSaved.Options.GlancePosition + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.glanceposition, f )
		
		-- Height drop down box
		f.ahunit = CreateFrame( "Button", "MyRolePlayOptionsPanel_HeightUnit", f, "UIDropDownMenuTemplate" )
		f.ahunit:SetPoint( "TOPLEFT", f.glanceposition, "BOTTOMLEFT", 0, -14 )
		f.ahunit.type = CONTROLTYPE_DROPDOWN
		f.ahunit.isoption = "HeightUnit"
		UIDropDownMenu_SetWidth( f.ahunit, 130 )
		f.ahunit:EnableMouse( true )
		f.ahunit.label = "ahunit"
		
		f.ahunit.capt = f.ahunit:CreateFontString( "MyRolePlayOptionsPanel_HeightUnitLabel", "OVERLAY", "GameFontHighlightSmall" )
		f.ahunit.capt:SetJustifyH( "LEFT" )
		f.ahunit.capt:SetJustifyV( "TOP" )
		f.ahunit.capt:SetPoint( "TOPLEFT", f.glanceposition, "BOTTOMLEFT", 18, 0 )
		f.ahunit.capt:SetText( L["opt_displayheight_header"] )
		
		f.ahunit.dd = CreateFrame( "Button", "MyRolePlayOptionsPanel_HeightUnitDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_HeightUnitButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "ahunit" ], MyRolePlayOptionsPanel_HeightUnitDropDown, MyRolePlayOptionsPanel_HeightUnit, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_HeightUnit, mrpSaved.Options.HeightUnit )
			end
		end )
		f.ahunit.Disable = UIDropDownMenu_DisableDropDown
		f.ahunit.Enable = UIDropDownMenu_EnableDropDown
		f.ahunit.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.HeightUnit )
			MyRolePlayOptionsPanel_HeightUnitText:SetText( mrp.optionscomboboxfields[ "ahunit" ][ mrpSaved.Options.HeightUnit + 1 ].text )
		end
		MyRolePlayOptionsPanel_HeightUnitText:SetText( mrp.optionscomboboxfields[ "ahunit" ][ mrpSaved.Options.HeightUnit + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.ahunit, f )
		
		-- Weight drop down box
		f.awunit = CreateFrame( "Frame", "MyRolePlayOptionsPanel_WeightUnit", f, "UIDropDownMenuTemplate" )
		f.awunit:SetPoint( "TOPLEFT", f.ahunit, "BOTTOMLEFT", 0, -12 )
		f.awunit.type = CONTROLTYPE_DROPDOWN
		f.awunit.isoption = "WeightUnit"
		UIDropDownMenu_SetWidth( f.awunit, 130 )
		f.awunit:EnableMouse( true )
		f.awunit.label = "awunit"

		f.awunit.capt = f.awunit:CreateFontString( "MyRolePlayOptionsPanel_WeightUnitLabel", "OVERLAY", "GameFontHighlightSmall" )
		f.awunit.capt:SetJustifyH( "LEFT" )
		f.awunit.capt:SetJustifyV( "TOP" )
		f.awunit.capt:SetPoint( "TOPLEFT", f.ahunit, "BOTTOMLEFT", 17, 3 )
		f.awunit.capt:SetText( L["opt_displayweight_header"] )

		f.awunit.dd = CreateFrame( "Button", "MyRolePlayOptionsPanel_WeightUnitDropDown", f, "UIDropDownListTemplate" )
		MyRolePlayOptionsPanel_WeightUnitButton:SetScript( "OnClick", function( self )
			if DropDownList1:IsVisible() then
				DropDownList1:Hide()
			else
				EasyMenu( mrp.optionscomboboxfields[ "awunit" ], MyRolePlayOptionsPanel_WeightUnitDropDown, MyRolePlayOptionsPanel_WeightUnit, 0, 5 )
				UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_WeightUnit, mrpSaved.Options.WeightUnit )
			end
		end )
		f.awunit.Disable = UIDropDownMenu_DisableDropDown
		f.awunit.Enable = UIDropDownMenu_EnableDropDown
		f.awunit.RefreshValue = function( self )
			UIDropDownMenu_SetSelectedValue( self, mrpSaved.Options.WeightUnit )
			MyRolePlayOptionsPanel_WeightUnitText:SetText( mrp.optionscomboboxfields[ "awunit" ][ mrpSaved.Options.WeightUnit + 1 ].text )
		end
		MyRolePlayOptionsPanel_WeightUnitText:SetText( mrp.optionscomboboxfields[ "awunit" ][ mrpSaved.Options.WeightUnit + 1 ].text )
		BlizzardOptionsPanel_RegisterControl( f.awunit, f )
		
		-- "Automatically change profile on.. label"
		f.fch = f:CreateFontString( nil, "OVERLAY", "GameFontNormal" )
		f.fch:SetJustifyH( "LEFT" )
		f.fch:SetJustifyV( "TOP" )
		f.fch:SetPoint( "TOPLEFT", f.awunit, "BOTTOMLEFT", 17, 0 )
		f.fch:SetText( L["opt_ac_header"] )
		
		-- "Shapeshifting" checkbox
		f.formac = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_FormAC", f, "InterfaceOptionsCheckButtonTemplate" )
		f.formac:SetPoint( "TOPLEFT", f.fch, "BOTTOMLEFT", -2, 0 )
		f.formac.label = "formac"
		f.formac.type = CONTROLTYPE_CHECKBOX
		f.formac.defaultValue = mrp.DefaultOptions.FormAutoChange and "1" or "0"
		f.formac.GetValue = function()
			return mrpSaved.Options.FormAutoChange and "1" or "0"
		end
		f.formac.setFunc = function( setting )
			mrpSaved.Options.FormAutoChange = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.formac, f )

		-- "Changing equipment set" checkbox REMOVED FOR CLASSIC AS THERES NO EQUIPMENT SWAPPER
		--[[f.equipac = CreateFrame( "CheckButton", "MyRolePlayOptionsPanel_EquipAC", f, "InterfaceOptionsCheckButtonTemplate" )
		f.equipac:SetPoint( "TOPLEFT", f.formac, "BOTTOMLEFT", 0, 5 )
		f.equipac.label = "equipac"
		f.equipac.type = CONTROLTYPE_CHECKBOX
		f.equipac.defaultValue = mrp.DefaultOptions.EquipSetAutoChange and "1" or "0"
		f.equipac.GetValue = function()
			return mrpSaved.Options.EquipSetAutoChange and "1" or "0"
		end
		f.equipac.setFunc = function( setting )
			mrpSaved.Options.EquipSetAutoChange = ( setting == "1" ) and true or false
		end
		BlizzardOptionsPanel_RegisterControl( f.equipac, f )]]

		-- frame, okay, cancel, default, refresh
		BlizzardOptionsPanel_OnLoad( f, nil, nil, mrp.OptionsPanelDefaultFunction, nil )
		InterfaceOptions_AddCategory( f, true )

		if not mrpSaved.Options.Enabled then
			for k, v in ipairs( MyRolePlayOptionsPanel.controls ) do
				if not v.avoiddisabling then
					v:Disable()
				end
			end
		end

		mrp.CreateOptionsPanel = mrp_dummyfunction
	end
end

function mrp.OptionsPanelDefaultFunction()
	for k, v in ipairs( MyRolePlayOptionsPanel.controls ) do
		if type( v.setFunc ) == "function" then
			v.setFunc( v.defaultValue )
		elseif type( v.RefreshValue ) == "function" then
			mrpSaved.Options[ v.isoption ] = mrp.DefaultOptions[ v.isoption ]
			v:RefreshValue()
		elseif type( v.SetValue ) == "function" then
			v.SetValue( v.defaultValue)
		end
	end
end

function mrp.GlancePositionCBClick( self )
	mrp:DebugSpam("glancepositioncbclick: %s", self.value or "<nil>")
	mrpSaved.Options.GlancePosition = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_GlancePosition, self.value )
	mrp:UpdateGlanceIconPosition()
	if mrp.BFShown then
		mrp:UpdateBrowseFrame()
	end
end

function mrp.AHUnitCBClick( self )
	mrp:DebugSpam("ahunitcbclick: %s", self.value or "<nil>")
	mrpSaved.Options.HeightUnit = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_HeightUnit, self.value )
	if mrp.BFShown then
		mrp:UpdateBrowseFrame()
	end
end

function mrp.AWUnitCBClick( self )
	mrp:DebugSpam("awunitcbclick: %s", self.value or "<nil>")
	mrpSaved.Options.WeightUnit = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_WeightUnit, self.value )
	if mrp.BFShown then
		mrp:UpdateBrowseFrame()
	end
end

function mrp.TTStyleCBClick( self )
	mrp:DebugSpam("ttstylecbclick: %s", self.value or "<nil>")
	mrpSaved.Options.TooltipStyle = self.value
	UIDropDownMenu_SetSelectedValue( MyRolePlayOptionsPanel_TTStyle, self.value )
	if mrp.TTShown then
		mrp:UpdateTooltip( mrp.TTShown )
	end
end

mrp.optionscomboboxfields = {
	["glanceposition"] = {
		{ text = L["glance_position_right"], value = 0, func = mrp.GlancePositionCBClick },
		{ text = L["glance_position_left"], value = 1, func = mrp.GlancePositionCBClick },
	},
	["ahunit"] = {
		{ text = L["cm_format_name"], value = 0, func = mrp.AHUnitCBClick },
		{ text = L["m_format_name"], value = 1, func = mrp.AHUnitCBClick },
		{ text = L["ftin_format_name"], value = 2, func = mrp.AHUnitCBClick },
	},
	["awunit"] = {
		{ text = L["kg_format_name"], value = 0, func = mrp.AWUnitCBClick },
		{ text = L["lb_format_name"], value = 1, func = mrp.AWUnitCBClick },
		{ text = L["stlb_format_name"], value = 2, func = mrp.AWUnitCBClick },
	},
	["ttstyle"] = {
		{ text = L["ttstyle_0_name"], value = 0, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_1_name"], value = 1, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_2_name"], value = 2, func = mrp.TTStyleCBClick },
		{ text = L["ttstyle_3_name"], value = 3, func = mrp.TTStyleCBClick },
	},	
	["defontsize"] = {
		{ text = L["8 pt"], value = 0, func = mrp.DEFontSizeCBClick },
		{ text = L["10 pt"], value = 1, func = mrp.DEFontSizeCBClick },
		{ text = L["12 pt"], value = 2, func = mrp.DEFontSizeCBClick },
		{ text = L["14 pt"], value = 3, func = mrp.DEFontSizeCBClick },
		{ text = L["16 pt"], value = 4, func = mrp.DEFontSizeCBClick },
	},	
}