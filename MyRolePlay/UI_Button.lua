--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	UI_Button.lua - The MRP button (shown/hidden by UI_Target.lua)
]]

local L = mrp.L

function mrp:CreateMRPButton()
	if not MyRolePlayButton then 
		local f
		f = CreateFrame( "Button", "MyRolePlayButton", UIParent )
		f:Hide()
		f:EnableMouse( true )
		f:SetMovable( true )
		f:SetSize( 34, 34 )
		f:SetClampedToScreen( true )
		if mrpSaved.Positions.Button then
			f:ClearAllPoints()
			f:SetPoint( mrpSaved.Positions.Button[1], nil, mrpSaved.Positions.Button[1], mrpSaved.Positions.Button[2], mrpSaved.Positions.Button[3] )
		else
			mrp:ResetMRPButtonPosition()
		end
		f:SetFrameStrata( "MEDIUM" )
		f:SetNormalTexture( "Interface\\AddOns\\MyRolePlay\\Artwork\\MRPInfoBoxButton_Up.blp" )
		f:SetPushedTexture( "Interface\\AddOns\\MyRolePlay\\Artwork\\MRPInfoBoxButton_Down.blp" )
		f:SetHighlightTexture( "Interface\\AddOns\\MyRolePlay\\Artwork\\MRPInfoBoxButton_Highlight.blp", "ADD" )
		f:RegisterForDrag( "LeftButton" )
		f:RegisterForClicks( "LeftButtonUp", "RightButtonUp" )

		f:SetScript("OnShow", function(self) -- first time only
			if not mrp.ButtonAnchored then
				if mrpSaved.Positions.Button then
					MyRolePlayButton:ClearAllPoints()
					MyRolePlayButton:SetPoint( mrpSaved.Positions.Button[1], nil, mrpSaved.Positions.Button[1], mrpSaved.Positions.Button[2], mrpSaved.Positions.Button[3] )
				else
					mrp:ResetMRPButtonPosition()
				end
				mrp.ButtonAnchored = true
			end
		end	)
		f:SetScript("OnDragStart", function(self)
			if mrp.ButtonMovable then
				self:StartMoving()
			end
		end	)
		f:SetScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			if not select( 2, MyRolePlayButton:GetPoint() ) then
				mrpSaved.Positions.Button = { select( 3, MyRolePlayButton:GetPoint() ) }
			end
		end	)
		f:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				if UnitIsUnit("player", "target") then
					mrp:Show( UnitName("player") )
				else
					mrp:Show( mrp:UnitNameWithRealm("target") )
				end
			elseif button == "RightButton" then
				mrp.ButtonMovable = not mrp.ButtonMovable
				if mrp.ButtonMovable then
					mrp:Print( L["button_unlocked"] )
					self:LockHighlight()
				else
					mrp:Print( L["button_locked"] )
					self:UnlockHighlight()
				end
				MyRolePlayButton:GetScript("OnEnter")(self) -- i.e. update the tooltip
			end
		end	)
		f:SetScript( "OnEnter", function(self) 
			GameTooltip:ClearLines();
            GameTooltip_SetDefaultAnchor(GameTooltip, self);

            mrp:UpdateTooltip(UnitName("player"), "player");
			
			GameTooltip:AddLine( " " )
			GameTooltip:AddLine( L["button_click_to_show"], 1.0, 1.0, 1.0 )
			if mrp.ButtonMovable then
				GameTooltip:AddLine( L["button_rightclick_to_lock"], 1.0, 1.0, 1.0 )
			else
				GameTooltip:AddLine( L["button_rightclick_to_unlock"], 1.0, 1.0, 1.0 )
			end
			GameTooltip:Show()
		end )
		f:SetScript( "OnLeave", GameTooltip_Hide )
	end
end

function mrp:ResetMRPButtonPosition()
	--[[
		Edit me to add support for floating the button alongside replacement unit frames.

		Out of all tested unit frames, only Perl Classic and XPerl completely nuke the TargetFrame.
		All other tested unit frames put the button somewhere about right, and of course it can be moved.
	]]
	mrpSaved.Positions.Button = nil
	MyRolePlayButton:ClearAllPoints()
	if XPerl_Target then
		MyRolePlayButton:SetPoint( "TOPLEFT", XPerl_Target, "BOTTOMRIGHT", -8, 0 )
	elseif Perl_Target_StatsFrame then
		MyRolePlayButton:SetPoint( "TOPLEFT", Perl_Target_StatsFrame, "BOTTOMRIGHT", -8, 0 )
	elseif SUFUnittarget then
		MyRolePlayButton:SetPoint( "TOPLEFT", SUFUnittarget, "BOTTOMRIGHT", -8, 0 )
	else
		MyRolePlayButton:SetPoint( "TOPLEFT", TargetFrame, "BOTTOMRIGHT", -55, 24 )
	end
end