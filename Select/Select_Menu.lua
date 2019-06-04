
local _,s = ...

-- the following snippet is used in the _onclick of each flyout button.
-- It copies the menu button's attributes to the action button and
-- also to the parent flyout
s.FLYOUTBUTTON_ONCLICK_SNIPPET = [[

	local flyout = self:GetParent()
	local main = flyout:GetParent():GetParent()

	flyout:Hide() -- hide opened flyout

	if IsAltKeyDown() and main:GetAttribute("DontSelectWithAlt") then
		return -- don't touch action button if <Alt> down and DontSelectWithAlt set
	end

	local form = main:GetAttribute("UseWhenSelecting") and "%s" or "alt-%s*"
	local action = flyout:GetParent()
	local attribType = self:GetAttribute(string.format(form,"type"))
	local attribValue
	if attribType=="macro" then
		attribValue = self:GetAttribute(string.format(form,"macrotext"))
	elseif attribType then
		attribValue = self:GetAttribute(string.format(form,attribType))
	end

	-- if the button contains valid attributes
	if attribType=="item" or attribType=="spell" or attribType=="macro" then

		-- wipe whatever was in the action button before
		action:SetAttribute("item",nil)
		action:SetAttribute("spell",nil)
		action:SetAttribute("macrotext",nil)

		-- set the action button's attributes to the new selection
		action:SetAttribute("type",attribType)
		if attribType=="macro" then
			action:SetAttribute("macrotext",attribValue)
		else
			action:SetAttribute(attribType,attribValue)
		end

		-- store these in the flyout also for persistence (remember for state changes)
		flyout:SetAttribute("attribType",attribType)
		flyout:SetAttribute("attribValue",attribValue)
	end
]]

-- fills the flyout frame with buttons the user will click
function s.FillFlyout(flyout)
	local flyoutType = type(flyout)
	if flyoutType=="string" or flyoutType=="number" then
		flyout = s.knownFlyouts[flyout]
	end
	if not flyout then
		return
	end
	-- populates rtable with attribute type/value pairs that will fill the buttons
	local rtable = s.rtable
	wipe(rtable)
	local entries = flyout.entries
	for i=1,#entries do
		local search,keyword = entries[i][1],entries[i][2]
		if s.filter[search] then
			s.filter[search](keyword) -- run the filter for this search:keyword pair
		end
	end

	local buttonIdx = 1
	local rtableIdx = 1
	local button

	if #rtable==0 then -- nothing to display :(
		tinsert(rtable,"nil") -- a blank button
		tinsert(rtable,"nil")
	end

	local useWhenSelecting = s.main:GetAttribute("UseWhenSelecting")

	while rtableIdx<#rtable do

		if not flyout.buttons[buttonIdx] then -- button doesn't exist, create one
			flyout.buttons[buttonIdx] = CreateFrame("CheckButton",nil,flyout,"SecureActionButtonTemplate")
			button = flyout.buttons[buttonIdx]
			button:SetSize(36,36)
			button.icon = button:CreateTexture(nil,"ARTWORK")
			button.icon:SetAllPoints(true)
			button.count = button:CreateFontString(nil,"ARTWORK","NumberFontNormal")
			button.count:SetPoint("BOTTOMRIGHT",-5,2)
			button.cooldown = CreateFrame("Cooldown",nil,button,"CooldownFrameTemplate")
			button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
			local normal = button:GetNormalTexture()
			normal:SetPoint("TOPLEFT",-15,15)
			normal:SetPoint("BOTTOMRIGHT",15,-15)
			button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
			button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
			button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight","ADD")
			SecureHandlerWrapScript(button,"OnClick",button,s.FLYOUTBUTTON_ONCLICK_SNIPPET)
			button:SetScript("OnEnter",s.FlyoutButtonOnEnter)
			button:SetScript("OnLeave",s.FlyoutButtonOnLeave)
		end
		button = flyout.buttons[buttonIdx]

		local attribType = rtable[rtableIdx]
		local attribValue = rtable[rtableIdx+1]

		if useWhenSelecting then
			button:SetAttribute("type",attribType)
			button:SetAttribute(attribType=="macro" and "macrotext" or attribType,attribValue)
		else
			button:SetAttribute("alt-type*",attribType)
			button:SetAttribute(attribType=="macro" and "alt-macrotext*" or format("alt-%s*",attribType),attribValue)
		end

		buttonIdx = buttonIdx+1
		rtableIdx = rtableIdx+2
	end
	local numButtons = buttonIdx-1
	-- hide any leftover buttons that exist
	while flyout.buttons[buttonIdx] do
		flyout.buttons[buttonIdx]:Hide()
		buttonIdx = buttonIdx+1
	end

	-- now position them
	local aspectRatio = 1.62 -- 1:1.62
	if numButtons>150 then
		aspectRatio = 1.0 -- make flyout a big fat square if over 150 buttons
	end
	local numAcross = floor(sqrt(numButtons/aspectRatio)+.5)
	local parentWidth = numAcross*40+12
	local parentHeight = ceil(numButtons/numAcross)*40+12
	for i=1,numButtons do
		button = flyout.buttons[i]
		button:SetPoint("BOTTOMLEFT",8+((i-1)%numAcross)*40,8+(floor((i-1)/numAcross))*40)
		button:Show()
	end
	flyout:SetSize(parentWidth,parentHeight)

end

--[[ Unsecure Stuff ]]

-- tooltip of the buttons within the flyout
function s.FlyoutButtonOnEnter(self)
	GameTooltip:SetOwner(self,"ANCHOR_LEFT")
	local form = s.main:GetAttribute("UseWhenSelecting") and "%s" or "alt-%s*"
	local attribType = self:GetAttribute(format(form,"type"))
	local attribValue = self:GetAttribute(format(form,attribType=="macro" and "macrotext" or attribType))
	s.SetTooltip(attribType,attribValue,self:GetParent():GetParent():GetAttribute("activelist"))
end

function s.FlyoutButtonOnLeave(self)
	GameTooltip:Hide()
end

function s.FlyoutOnHide(self)
	-- remove from UISpecialFrames so we don't clutter the table
	if not InCombatLockdown() then
		local name = self:GetName()
		for i=#UISpecialFrames,1,-1 do
			if UISpecialFrames[i]==name then
				tremove(UISpecialFrames,i)
				return
			end
		end
	end
end

-- when a flyout is shown, go through and update all icons, counts/charges and cooldowns
function s.FlyoutOnShow(self)
	-- add to UISpecialFrames so it can be hidden with ESC (if not in combat)
	local name = self:GetName()
	if not InCombatLockdown() and not tContains(UISpecialFrames,name) then
		tinsert(UISpecialFrames,name)
	end
	-- update icons, counts and cooldowns on buttons
	local form = s.main:GetAttribute("UseWhenSelecting") and "%s" or "alt-%s*"
	local currentType = self:GetAttribute("attribType") -- flyout attribs, to mark currently selected
	local currentValue = self:GetAttribute("attribValue")
	for i=1,#self.buttons do
		local button = self.buttons[i]
		if button:IsShown() then
			button:SetChecked(false)
			button.count:SetText("")
			button.cooldown:SetAllPoints(button)
			local attribType = button:GetAttribute(format(form,"type"))
			local attribValue = button:GetAttribute(format(form,attribType=="macro" and "macrotext" or attribType))
			if attribType=="item" then
				local toyID = s.toyCache[attribValue]
				if toyID then -- this is a toy, its cache value is the itemID
					button.icon:SetTexture(GetItemIcon(toyID))
				else -- this is not a toy, its attribute is item:number
					button.icon:SetTexture(GetItemIcon(attribValue))
				end
				local count = GetItemCount(attribValue,nil,true)
				if count>1 then
					button.count:SetText(count)
				end
				local itemID = toyID or attribValue:match("item:(%d+)")
				if itemID then
					CooldownFrame_Set(button.cooldown,GetItemCooldown(itemID))
				end
			elseif attribType=="spell" then
				button.icon:SetTexture(GetSpellTexture(attribValue))
				local charges = GetSpellCharges(attribValue)
				if charges then
					button.count:SetText(charges)
				end
				CooldownFrame_Set(button.cooldown,GetSpellCooldown(attribValue))
			elseif attribType=="macro" then
				local name = attribValue:match("/summonpet (.+)")
				local speciesID = C_PetJournal.FindPetIDByName(name)
				if speciesID then
					local _,icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
					button.icon:SetTexture(icon)
				end
			elseif attribType=="nil" then
				button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			end
			if attribType==currentType and attribValue==currentValue then
				button:SetChecked(true)
			end
		end
	end
end
