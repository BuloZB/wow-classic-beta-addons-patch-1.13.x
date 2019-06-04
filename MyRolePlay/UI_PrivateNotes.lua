--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_GlancePreview.lua - MyRolePlayGlanceFrame (the glance preview box), and support functions
]]

local L = mrp.L
local function emptynil( x ) return x ~= "" and x or nil end

local uipbt = "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

function mrp:CreateNotesFrame()
	if not MyRolePlayNotesFrame then
		local nf = CreateFrame( "Frame", "MyRolePlayNotesFrame", UIParent, "ButtonFrameTemplate" )
		nf:Hide()
		nf:SetWidth(250)
		nf:SetHeight(300)

		nf:ClearAllPoints()
		nf:SetPoint( "TOPLEFT", "MyRolePlayBrowseFrame", "TOPRIGHT", 5, 0 )
		nf:SetFrameStrata( "HIGH" )
		nf:SetToplevel( true )

		MyRolePlayNotesFrameTitleText:SetPoint("RIGHT", -30, 0)
		SetPortraitToTexture( "MyRolePlayNotesFramePortrait", "Interface\\Icons\\INV_Misc_Book_06" )

		nf:EnableMouse( true )
		nf:SetMovable( false )
		nf:SetClampedToScreen( true )
		ButtonFrameTemplate_ShowButtonBar( nf )

		nf:EnableDrawLayer( "OVERLAY" )
		
		nf.HeaderFontString = nf:CreateFontString("MyRolePlayNotesFrameHeaderFontString", "ARTWORK", "MyRolePlayMediumFont")
		nf.HeaderFontString:SetWidth(240)
		nf.HeaderFontString:SetHeight(0)
		nf.HeaderFontString:SetPoint("TOP", 25, -30)
		MyRolePlayNotesFrameHeaderFontString:SetText("Write notes about a character here.\nOnly you can see them.")
		MyRolePlayNotesFrameHeaderFontString:SetJustifyH( "CENTER" )
		
		nf.sf = CreateFrame( "ScrollFrame", "MyRolePlayNotesFrameScrollFrame", nf, "UIPanelScrollFrameTemplate" )
		nf.sf:SetPoint( "TOPLEFT", MyRolePlayNotesFrameInset, "TOPLEFT", 4, 0 )
		nf.sf:SetPoint( "BOTTOMRIGHT", MyRolePlayNotesFrameInset, "BOTTOMRIGHT", -26, 3 )

		nf.sf:EnableMouse(true)
		nf.sf.scrollbarHideable = false

		ScrollBar_AdjustAnchors( MyRolePlayNotesFrameScrollFrameScrollBar, -1, -1, 1)

		nf.sf.editbox = CreateFrame( "EditBox", "MyRolePlayNotesFrameEditBox", nf.sf )
		nf.sf.editbox.cursorOffset = 0
		nf.sf.editbox:SetPoint( "TOPLEFT" )
		nf.sf.editbox:SetPoint( "BOTTOMLEFT" )

		nf.sf.editbox:SetWidth( 217 )
		nf.sf.editbox:SetSpacing( 1 )
		nf.sf.editbox:SetTextInsets( 3, 3, 4, 4 )
		nf.sf.editbox:EnableMouse(true)
		nf.sf.editbox:EnableKeyboard(true)
		nf.sf.editbox:SetAutoFocus(false)
		nf.sf.editbox:SetMultiLine(true)
		nf.sf.editbox:SetFontObject( "GameFontHighlight" )
		nf.sf:SetScrollChild( nf.sf.editbox )

		
		nf.sf.editbox:SetScript( "OnEscapePressed", EditBox_ClearFocus )

		nf.sf.editbox:SetScript( "OnTextChanged", function(self)
			ScrollingEdit_OnTextChanged(self, self:GetParent())
		end	)
		nf.sf.editbox:SetScript( "OnCursorChanged", function(self, x, y, w, h)
			ScrollingEdit_OnCursorChanged(self, x, y-10, w, h)
		end )
		nf.sf.editbox:SetScript( "OnUpdate", function(self, elapsed)
			ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
		end	)

		ScrollFrame_OnScrollRangeChanged(MyRolePlayNotesFrameScrollFrame)
		
		nf.ok = CreateFrame( "Button", "MyRolePlayNotesFrameOK", nf, uipbt )
		nf.ok:SetPoint( "BOTTOMRIGHT", nf, "BOTTOMRIGHT", -8, 4 )
		nf.ok:SetText( L["save_button"] )
		nf.ok:SetWidth( 90 )
		nf.ok:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["save_button_tt"], 1.0, 1.0, 1.0 )
		end )
		nf.ok:SetScript( "OnLeave", GameTooltip_Hide )
		nf.ok:SetScript("OnClick", function (self)
			local newtext = nf.sf.editbox:GetText()
			local name
			local realm
			if(mrp.BFShown:match("%-")) then
				name = mrp.BFShown:match("(.-)%-"):upper()
				realm = mrp.BFShown:match(".-%-(.+)"):upper()
			else
				name = UnitName("player"):upper()
				realm = GetRealmName():gsub(" ", ""):upper()
			end
			if(name and realm) then
				mrp:SaveNotesFrame(name, realm, newtext)
			end
			mrp:UpdateBrowseFrame( mrp.BFShown )
			MyRolePlayNotesFrame:Hide()
		end )

		nf.cancel = CreateFrame( "Button", "MyRolePlayNotesFrameCancel", nf, uipbt )
		nf.cancel:SetPoint( "RIGHT", nf.ok, "LEFT", -8, 0 )
		nf.cancel:SetText( L["cancel_button"] )
		nf.cancel:SetWidth( 90 )
		nf.cancel:SetScript( "OnEnter", function(self) 
			GameTooltip:SetOwner( self, "ANCHOR_RIGHT" )
			GameTooltip:SetText( L["cancel_button_tt"], 1.0, 1.0, 1.0 )
		end )
		nf.cancel:SetScript( "OnLeave", GameTooltip_Hide )
		nf.cancel:SetScript("OnClick", function (self)
			-- we, uh, don't need to do anything
			MyRolePlayNotesFrame:Hide()
		end )
	end
end


function mrp:UpdateNotesFrame()
	local name
	local realm
	if(mrp.BFShown:match("%-")) then
		name = mrp.BFShown:match("(.-)%-"):upper()
		realm = mrp.BFShown:match(".-%-(.+)"):upper()
	else
		name = UnitName("player"):upper()
		realm = GetRealmName():gsub(" ", ""):upper()
	end
	MyRolePlayNotesFrameTitleText:SetText( "Notes for " .. Ambiguate(mrp.BFShown, "short"))
	if(mrpNotes and mrpNotes[realm] and mrpNotes[realm][name]) then
		MyRolePlayNotesFrameEditBox:SetText(mrpNotes[realm][name])
	else
		MyRolePlayNotesFrameEditBox:SetText("")
	end
end

function mrp:SaveNotesFrame(name, realm, newtext)
	if(type(mrpNotes) ~= "table") then
		mrpNotes = {}
	end
	if(type(mrpNotes[realm]) ~= "table") then
		mrpNotes[realm] = {}
	end
	if(type(mrpNotes[realm][name]) ~= "table") then
		mrpNotes[realm][name] = {}
	end
	if(newtext ~= nil and newtext ~= "") then
		mrpNotes[realm][name] = newtext
	else
		mrpNotes[realm][name] = nil
	end
end