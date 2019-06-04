
local _,s = ...
_Select = s

s.main = CreateFrame("Frame",nil,UIParent,"SecureHandlerBaseTemplate")

s.activeMacros = {} -- table of macro indexes and the /select commands they contain
s.knownFlyouts = {} -- table indexed by flyout list ("item, spell, item") to frames for those flyouts
s.arrowHooks = {} -- table indexed by action button frame for hooks to show the little arrow
s.numFlyouts = 0 -- each created flyout is named "SelectFlyout%d" of this index for UISpecialFrames
s.iconsToUpdate = {} -- table of macro indexes that need icons updated
s.firstLogin = true
s.flyoutsNeedFilled = true

local DEBUG_TIMES = false -- enable to gather how long each flyout takes to fill in debugTimes
s.debugTimes = {} -- indexed by flyout list, is the debugprofilestop() duration of its FillFlyout()

s.main:SetScript("OnEvent",function(self,event,...)
	if s[event] then
		s[event](self,...)
	end
end)
s.main:RegisterEvent("PLAYER_LOGIN")

function s.PLAYER_LOGIN()
	Select_Settings = Select_Settings or {}
	Select_PerCharacter_Settings = Select_PerCharacter_Settings or {}

	-- global savedvars (UseWhenSelecting, DontSelectWithAlt) are set as attributes
	-- to the secure main frame so snippets can GetAttribute their value
	for k,v in pairs(Select_Settings) do
		s.main:SetAttribute(k,v and true)
	end

	-- for transition from 2.1 to 2.2, convert per-character savedvars to new format
	local per = Select_PerCharacter_Settings
	if not per[""] then -- The flyout list "" probably does not exist in most's 2.1 savedvars
		for k,v in pairs(per) do
			local list = k:match("^SelectFlyout:(.+)")
			if list then
				if v.actionType=="spell" then
					per[list] = {"spell",v.actionBody}
				elseif v.actionType=="item" then
					per[list] = {"item",format("item:%s",tostring(v.actionDetail))}
				end
			end
		end
	end

	s.main:RegisterEvent("UPDATE_MACROS")
	s.main:RegisterEvent("BAG_UPDATE")
	s.main:RegisterEvent("SPELLS_CHANGED")
	s.main:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	s.main:RegisterEvent("PLAYER_LOGOUT")
	s.main:RegisterEvent("PLAYER_REGEN_DISABLED")
	s.main:RegisterEvent("PLAYER_ENTERING_WORLD")
	s.main:RegisterEvent("ACTIONBAR_SLOT_CHANGED")

--    s.main:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
--    s.main:RegisterEvent("COMPANION_LEARNED")
--    s.main:RegisterEvent("COMPANION_UNLEARNED")
--    s.main:RegisterEvent("COMPANION_UPDATE")
--    s.UpdateOwnedMountIDs()

	s.CreateFlyout("") -- create an empty flyout

	-- s.main:RegisterEvent("TOYS_UPDATED")
	--C_Timer.After(0,s.TOYS_UPDATED) -- update toy cache

	s.UpdateAllMacros()
	s.CacheBags()

	-- create an arrow overlay to indicate an action button contains a select macro
	s.arrow = CreateFrame("Frame",nil,UIParent)
	s.arrow:SetSize(20,20)
	s.arrow.texture = s.arrow:CreateTexture(nil,"OVERLAY")
	s.arrow.texture:SetAllPoints(true)
	s.arrow.texture:SetTexture("Interface\\Buttons\\Arrow-Up-Up")

end

function s.PLAYER_LOGOUT()
	local per = Select_PerCharacter_Settings
	wipe(per)
	for list,flyout in pairs(s.knownFlyouts) do
		local attribType = flyout:GetAttribute("attribType")
		local attribValue = flyout:GetAttribute("attribValue")
		if attribType and attribValue then
			per[list] = {attribType,attribValue}
		end
	end
	Select_Settings.UseWhenSelecting = s.main:GetAttribute("UseWhenSelecting")
	Select_Settings.DontSelectWithAlt = s.main:GetAttribute("DontSelectWithAlt")
end

-- when player enters combat, fill all flyouts since they can't be filled during combat
function s.PLAYER_REGEN_DISABLED()
	if s.flyoutsNeedFilled then
      if DEBUG_TIMES then
         wipe(s.debugTimes)
      end
		for list,flyout in pairs(s.knownFlyouts) do
         if DEBUG_TIMES then
            s.debugTimer = debugprofilestop()
         end
			s.FillFlyout(flyout)
         if DEBUG_TIMES then
            s.debugTimes[list] = debugprofilestop()-s.debugTimer
         end
		end
		s.flyoutsNeedFilled = nil
	end
	-- remove any flyouts from UISpecialFrames when entering combat
	for i=#UISpecialFrames,1,-1 do
		if tostring(UISpecialFrames[i]):match("^SelectFlyout%d+$") then
			tremove(UISpecialFrames,i)
		end
	end
end

function s.SPELLS_CHANGED()
	s.flyoutsNeedFilled = true
end

function s.PLAYER_ENTERING_WORLD()
	C_Timer.After(0,s.UpdateAllMacroIcons) -- wait until game starts rendering before updating icons
end

-- in 7.2, icons seem to revert when slots change; doing a quick refresh of all icons without
-- digging for actionIDs seems to be a lot more efficient
function s.ACTIONBAR_SLOT_CHANGED()
	s.StartTimer(0,s.UpdateAllMacroIcons)
end

--[[ Macro Maintenance ]]

function s.UPDATE_MACROS()
	if not InCombatLockdown() then
		s.UpdateAllMacros()
	else -- in combat, register and wait to leave combat
		s.main:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

-- this event will only fire if it was registered during an UPDATE_MACROS in combat
function s.PLAYER_REGEN_ENABLED()
	s.main:UnregisterEvent("PLAYER_REGEN_ENABLED")
	s.UpdateAllMacros()
end

function s.UpdateAllMacros()
	s.UpdateAllClicklines() -- go through all macros and confirm/add/repair proper /clicklines
	s.CreateNewFlyouts() -- create flyouts not already created
	s.CreateNewClickFrames() -- go through all activeMacros and create any S000M/S000A frames not already made
	if not s.firstLogin then
		s.FillAttributes() -- assign attributes to flyouts and S000As
	end
	s.UpdateNeededMacroIcons(true)
end

-- returns a string with "magic characters" escaped, for a literal gsub
local function literal(str)
	return (str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%"..c end))
end

-- returns the selectline and clickline from a strsplit("\n",macroBody)
function s.GetLines(...)
	local selectline
	for i=1,select("#",...) do
		local line = select(i,...)
		if line:match("^/select%s+[^%s]") then
			selectline = line
		elseif selectline and line:match("^/click ") then
			return selectline, line -- return selectline and first line that contains /click after it
		end
	end
	return selectline -- no clickline to return if we reached here
end

-- runs func for each ...
function s.RunForEach(func,...)
	for i=1,select("#",...) do
		func((select(i,...)))
	end
end

-- this goes through all macros and confirms the clickline is properly set on
-- macros that contain /select, correcting/adding them if need be
-- also populates s.activeMacros indexes to note which macros have a /select
function s.UpdateAllClicklines()
	for i=1,138 do
		local _,_,body = GetMacroInfo(i)
		if body and body:match("/select ") then -- this macro has a /select
			local correctClickline = format("/click [btn:2]S%03dM;S%03dA",i,i) -- it will have this line also
			local selectline,clickline = s.GetLines(strsplit("\n",body))
			local newBody -- if macro needs a new body it will go here
			if selectline then
				if not clickline then
					newBody = body:gsub(literal(selectline),selectline.."\n"..correctClickline)
				elseif clickline ~= correctClickline then
					newBody = body:gsub(literal(clickline),correctClickline)
				end
				if newBody then -- clickline added/changed the macro's body needs changed to newBody
					s.main:UnregisterEvent("UPDATE_MACROS") -- unregister, we're about to trigger this event
					EditMacro(i,nil,nil,newBody)
					s.main:RegisterEvent("UPDATE_MACROS")
					s.WipeButtonAttributes(format("S%03dA",i))
				elseif s.activeMacros[i]~=selectline then -- selectline changed
					s.WipeButtonAttributes(format("S%03dA",i))
				end
				s.activeMacros[i] = selectline
			else
				s.activeMacros[i] = nil -- has /select but it's not start of a line
			end
		else
			s.activeMacros[i] = nil -- does not have /select or no macro
		end
	end
end

-- create any S000A/S000M /clicked frames if needed
function s.CreateNewClickFrames()
	for index,selectline in pairs(s.activeMacros) do
		local actionName = format("S%03dA",index)
		local menuName = format("S%03dM",index)
		if not _G[actionName] then
			local action = CreateFrame("Button",actionName,s.main,"SecureActionButtonTemplate")
			local menu = CreateFrame("Button",menuName,action,"SecureHandlerClickTemplate,SecureHandlerStateTemplate")
			action:SetID(index)
			action:SetScript("OnAttributeChanged",s.ActionOnAttributeChanged)
			menu:RegisterForClicks("AnyUp")

			-- [@unit] conditions don't trigger a state change. pre-click wrap will set unit
			SecureHandlerWrapScript(action,"OnClick",action,[[
				local trimline = self:GetAttribute("trimline")
				if trimline then
					local _,unit = SecureCmdOptionParse(trimline)
					if unit ~= self:GetAttribute("unit") then
						self:SetAttribute("unit",unit)
					end
				end
			]])

			-- when state is created or changed, hide its flyout if open and copy the new state's flyout attributes to S000A
			menu:SetAttribute("_onstate-select",[[
				local oldstate = self:GetAttribute("activelist")
				local action = self:GetParent()

				if oldstate~=newstate then -- if a new state
					local oldFlyout = self:GetParent():GetParent():GetFrameRef(oldstate)
					if oldFlyout and oldFlyout:IsVisible() then
						oldFlyout:Hide() -- hide open flyout if state is changing
					end
				end

					self:SetAttribute("activelist",newstate)
					action:SetAttribute("activelist",newstate)

				-- copy the attribType/Value from the flyout we're changing to, to the action button
				local flyout = self:GetParent():GetParent():GetFrameRef(newstate)
				if flyout then
					local attribType = flyout:GetAttribute("attribType")
					if attribType then
						local attribValue = flyout:GetAttribute("attribValue")
						action:SetAttribute("type",attribType)
						action:SetAttribute(attribType=="macro" and "macrotext" or attribType,attribValue)
						return
					end
				end
				action:SetAttribute("type",nil)
			]])

			-- the /click of S000M opens the flyout menu
			menu:SetAttribute("_onclick",[[
				local frame = self:GetParent():GetParent():GetFrameRef(self:GetAttribute("activelist"))
				if frame then
					if frame:IsVisible() then
						frame:Hide()
						frame:UnregisterAutoHide()
					else
						frame:SetParent(self:GetParent())
						frame:SetFrameStrata("FULLSCREEN_DIALOG")
						frame:SetPoint("BOTTOM","$cursor",0,-2)
						frame:RegisterAutoHide(.5)
						frame:Show()
					end
				end
			]])

			-- unsecure bit before click
			menu:SetScript("PreClick",function(self)
				if not InCombatLockdown() then
					s.FillFlyout(self:GetAttribute("activelist"))
				end
			end)
		end
		-- register the new/changed trimline to the menu
		local trimline = selectline:match("/select (.+)"):trim()..";" -- ";" guarantees one state will always be valid
		local menu = _G[menuName]
		local action = _G[actionName]
		action:SetAttribute("trimline",trimline) -- and the action for unit pre-click wrap
		UnregisterStateDriver(menu,"select")
		RegisterStateDriver(menu,"select",trimline)
	end

end

-- wipes all attributes from a button
s.allAttributes = {"type","alt-type*","item","alt-item*","spell","alt-spell*","macrotext","alt-macrotext*"}
function s.WipeButtonAttributes(button)
	if type(button)=="string" then
		button = _G[button]
	end
	if button then
		for i=1,#s.allAttributes do
			button:SetAttribute(s.allAttributes[i],nil)
		end
	end
end

-- for a "[condition1] item, spell; [condition2] item", "item, spell" and "item" are separate flyouts
function s.CreateNewFlyouts()
	for index,selectline in pairs(s.activeMacros) do
		local whole = selectline:match("/select (.+)")
		s.RunForEach(s.CreateFlyout,strsplit(";",whole))
	end
end

-- converts a string to a case-insensitive pattern: "Hello" -> "[Hh][Ee][Ll][Ll][Oo]"
local function caseInsensitive(txt)
	if txt then
		return (txt:gsub("%a",function(a) return "["..a:upper()..a:lower().."]" end))
	end
end

-- list is "item, spell, item", the collected entries in a flyout
function s.CreateFlyout(list)
	list = list:gsub("%[.-%]",""):trim() -- remove [conditions] and extra whitespace
	if not s.knownFlyouts[list] then
		s.numFlyouts = s.numFlyouts+1
		s.knownFlyouts[list] = CreateFrame("Frame","SelectFlyout"..s.numFlyouts,s.main,"SecureHandlerBaseTemplate")
		local flyout = s.knownFlyouts[list]
		flyout:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\DialogFrame\\UI-DialogBox-Gold-Border", edgeSize=16})
		flyout:SetClampedToScreen(1)
		flyout:EnableMouse(true)
		flyout:Hide()
		s.main:SetFrameRef(list,flyout)
		-- flyout.entries is a list of entries in the flyout
		-- "item name, spell name, item:part" -> {{"none","item name"},{"none","spell name"},{"item","part"}}
		flyout.entries = {strsplit(",",list)}
		for i=1,#flyout.entries do
			local entry = flyout.entries[i]:trim()
			local search,keyword = entry:match("(%w+):(%S.+)")
			if search and keyword then
				search = search:lower()
				if s.filter[search] then
					-- for search:keyword pairs, the keyword is made case insensitive and magic characters (-*[]etc) escaped
					flyout.entries[i] = {search,caseInsensitive(literal(keyword))}
				end
			else
				flyout.entries[i] = {"none",entry}
			end
		end
		flyout.buttons = {} -- where the actual buttons in the flyout are stored
		flyout:SetScript("OnShow",s.FlyoutOnShow)
		flyout:SetScript("OnHide",s.FlyoutOnHide)
		-- set attribType and attribValue from savedvars if they exist
		local saved = Select_PerCharacter_Settings
		if saved[list] then
			flyout:SetAttribute("attribType",saved[list][1])
			flyout:SetAttribute("attribValue",saved[list][2])
		end
	end
end

-- for someone with many select macros, creating all flyouts at once may cause a small freeze
-- calling FillFlyoutsOverTime when the cache is finished loading will fill one flyout every
-- quarter second; if the player opens an un-filled flyout or they enter combat before the
-- process is done it's okay. ** this is called from s.CacheBags to get run after cache complete

s.flyoutsToFill = {} -- ordered list of flyouts

-- call this to fill all flyouts, one every 1/10th of a second
function s.FillFlyoutsOverTime()
   if s.flyoutsNeedFilled then
      for list,flyout in pairs(s.knownFlyouts) do
         tinsert(s.flyoutsToFill,flyout)
      end
      s.StartTimer(0.25,s.RolloutFlyouts) -- kick off first fill a quarter second after cache complete
   end
end

-- timer function to fill one flyout and call itself again until all flyouts are done
function s.RolloutFlyouts()
   -- if not in combat and there's a flyout to fill
   if not InCombatLockdown() and #s.flyoutsToFill>0 then
      s.FillFlyout(s.flyoutsToFill[1])
      tremove(s.flyoutsToFill,1)
      s.StartTimer(0.1,s.RolloutFlyouts)
   else
      s.flyoutsNeedFilled = nil
   end
end

--[[ Timer Management ]]

s.timerFrame = CreateFrame("Frame") -- timer independent of main frame visibility
s.timerFrame:Hide()
s.timerTimes = {} -- indexed by arbitrary name, the duration to run the timer
s.timersRunning = {} -- indexed numerically, timers that are running

function s.StartTimer(duration,func)
	local timers = s.timersRunning
	s.timerTimes[func] = duration
	if not tContains(s.timersRunning,func) then
		tinsert(s.timersRunning,func)
	end
	s.timerFrame:Show()
end

s.timerFrame:SetScript("OnUpdate",function(self,elapsed)
	local tick
	local times = s.timerTimes
	local timers = s.timersRunning

	for i=#timers,1,-1 do
		local func = timers[i]
		times[func] = times[func] - elapsed
		if times[func] < 0 then
			tremove(timers,i)
			func()
		end
		tick = true
	end

	if not tick then
		self:Hide()
	end
end)

--[[ Macro Icons ]]

-- when S000A attribute changes, we want to update its icon only
function s.ActionOnAttributeChanged(self,attribType,attribValue)
	local index = self:GetID()
	s.iconsToUpdate[self:GetID()] = 1
	s.StartTimer(0,s.UpdateNeededMacroIcons)
end

function s.UpdateMacroIcon(index)
	local name = format("S%03dA",index)
	local button = _G[name]
	if button then
		local attribType = button:GetAttribute("type")
		if attribType=="spell" then
			SetMacroSpell(index,button:GetAttribute("spell"))
		elseif attribType=="item" then
			local itemID = button:GetAttribute("item")
			if itemID:match("^item:") then
				SetMacroItem(index,itemID)
			elseif itemID then -- this is a toy if it's named without item:number
				local _,link = GetItemInfo(itemID)
				if link then
					SetMacroItem(index,link)
				else
					-- if no link from an itemID then retry in 0.5 seconds (don't abort; let GetItemInfo cache others too)
					s.StartTimer(0.5,s.UpdateAllMacroIcons)
				end
			end
		elseif attribType=="macro" then
			SetMacroSpell(index,(GetSpellInfo(125439))) -- Revive Battle Pet icon
		else
			SetMacroSpell(index,"")
		end
	end
end

-- updates all macro icons that need updated
-- if updateAll true, update the icons of all active macros
function s.UpdateNeededMacroIcons(updateAll)
	for index in pairs(updateAll and s.activeMacros or s.iconsToUpdate) do
		s.UpdateMacroIcon(index)
	end
	wipe(s.iconsToUpdate)
end

function s.UpdateAllMacroIcons()
	s.UpdateNeededMacroIcons(true)
end

--[[ Attribute filling ]]

-- this must be run after s.firstLogin is nil, to allow items to cache
function s.FillAttributes()
	-- go through all flyouts first and any that do not have attribType
	-- defined, fill the flyout's buttons and set attribType/Value to
	-- the first button
	local form = s.main:GetAttribute("UseWhenSelecting") and "%s" or "alt-%s*"
	for list,flyout in pairs(s.knownFlyouts) do
		if not flyout:GetAttribute("attribType") then
			s.FillFlyout(flyout)
			if #flyout.buttons>0 then
				local button = flyout.buttons[1]
				local attribType = button:GetAttribute(format(form,"type"))
				local attribValue
				if attribType then
					attribValue = button:GetAttribute(format(form,attribType=="macro" and "macrotext" or attribType))
				end
				flyout:SetAttribute("attribType",attribType)
				flyout:SetAttribute("attribValue",attribValue)
			end
		end
	end

	-- now go through all S000As and it any are missing type attribute,
	-- get the flyout attribType/Value
	for index,selectline in pairs(s.activeMacros) do
		local action = _G[format("S%03dA",index)]
		if action and not action:GetAttribute("type") then
			local list = SecureCmdOptionParse((selectline:match("/select (.+)")))
			local flyout = s.knownFlyouts[list]
			if flyout then
				local attribType = flyout:GetAttribute("attribType")
				local attribValue = flyout:GetAttribute("attribValue")
				if attribType and attribValue then
					action:SetAttribute("type",attribType)
					action:SetAttribute(attribType=="macro" and "macrotext" or attribType,attribValue)
				end
			end
		end
	end

end


-- hook GameTooltip:SetAction
hooksecurefunc(GameTooltip,"SetAction",function(self,actionSlot)
  local actionType,index = GetActionInfo(actionSlot)
  if actionType=="macro" and s.activeMacros[index] then
		local focus = GetMouseFocus()
		if focus then
			local actionID = focus:GetAttribute("action") or focus.action
			if actionID and actionID==actionSlot  then
				local action = _G[format("S%03dA",index)]
				if GetCVar("UberTooltips")=="1" then
					local attribType = action:GetAttribute("type")
					if attribType then
						local attribValue = action:GetAttribute(attribType=="macro" and "macrotext" or attribType)
						s.SetTooltip(attribType,attribValue)
					end
					GameTooltip:AddLine(format("\124cffbbbbbb/select macro: \124cffffd200%s",GetMacroInfo(index)))
					if not Select_Settings.DontAddToMacroTooltip then
						local list = action:GetAttribute("activelist")
						if list then
							GameTooltip:AddLine(list,.85,.85,.85,1)
						end
					end
				end
				GameTooltip:Show()

				-- if we've not added a hook to show the arrow for this button, create one
				if not s.arrowHooks[focus] then
					s.arrowHooks[focus] = 1
					focus:HookScript("OnEnter",s.RealActionButtonOnEnter)
					focus:HookScript("OnLeave",s.RealActionButtonOnLeave)
					s.RealActionButtonOnEnter(focus)
				end
			end
		end
	end
end)

-- these display/hide the little yellow arrow over action buttons that contain /select macros
function s.RealActionButtonOnEnter(self)
	local action = self:GetAttribute("action") or self.action
	if action then
		local actionType,index = GetActionInfo(action)
		if actionType=="macro" and s.activeMacros[index] then
			s.arrow:SetParent(self)
			s.arrow:SetPoint("TOP",self,"TOP",1,11)
			s.arrow:Show()
		end
	end
end
function s.RealActionButtonOnLeave(self)
	s.arrow:Hide()
end

-- the calling function should have already GameTooltip:SetOwner
function s.SetTooltip(attribType,attribValue,activelist)

	if not attribType or attribType=="nil" then
		GameTooltip:AddLine("No results found.")
		if activelist then
			GameTooltip:AddLine(activelist,.85,.85,.85,1)
		end
	else
		if attribType=="item" then
			local toyID = s.toyCache[attribValue]
			if toyID then -- this is a toy
				GameTooltip:ClearLines()
				GameTooltip:SetToyByItemID(toyID)
			else
				local itemID = tonumber(attribValue:match("item:(%d+)"))
				s.SetTooltipByItemID(itemID)
			end
		elseif attribType=="spell" then
			local spellID = (GetSpellLink(attribValue) or ""):match("spell:(%d+)")
			if spellID then
				GameTooltip:SetSpellByID(spellID)
			end
		elseif attribType=="macro" then
			local name = attribValue:match("/summonpet (.+)")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(name,1,1,1)
		end
	end
	GameTooltip:Show()

end

-- neither GameTooltip:SetItemByID() or GameTooltip:SetHyperlink() will show a cooldown.
-- so this finds the bag,slot or inventory slot to set the tooltip. since this is only
-- called when a tooltip is actually displayed (mouse is over an action or flyout button),
-- this is better than storing extra info with every item.
function s.SetTooltipByItemID(itemID)
	if not itemID then return end -- not a valid itemID
	if IsEquippedItem(itemID) then -- it's worn
		for i=1,19 do
			if GetInventoryItemID("player",i)==itemID then
				GameTooltip:SetInventoryItem("player",i)
				return
			end
		end
	else -- it's (probably) in bags
		for i=0,4 do
			for j=1,GetContainerNumSlots(i) do
				if GetContainerItemID(i,j)==itemID then
					GameTooltip:SetBagItem(i,j)
					return
				end
			end
		end
	end
	-- we didn't find it, so cooldown doesn't matter
	GameTooltip:SetItemByID(itemID)
end

--[[ Options Panel ]]

-- the options panel is now defined in Select_Options.xml
local opt = SelectOptionsPanel
local useOpt = SelectOptionsUseWhenSelecting
local dontOpt = SelectOptionsDontSelectWithAlt
local macroOpt = SelectOptionsDontAddToMacroTooltip

opt.name = "Select"
InterfaceOptions_AddCategory(opt)

function opt.refresh()
	useOpt:SetChecked(s.main:GetAttribute("UseWhenSelecting"))
	dontOpt:SetChecked(s.main:GetAttribute("DontSelectWithAlt"))
	macroOpt:SetChecked(Select_Settings.DontAddToMacroTooltip)
end

function opt.default()
	s.main:SetAttribute("UseWhenSelecting",false)
	s.main:SetAttribute("DontSelectWithAlt",false)
	Select_Settings.DontAddToMacroTooltip = nil
end

function s.UpdateSetting(self)
	if self.variable=="DontAddToMacroTooltip" then
		Select_Settings.DontAddToMacroTooltip = not Select_Settings.DontAddToMacroTooltip
	elseif InCombatLockdown() then
		print("\124cffff0000Select settings can't be changed in combat, sorry!")
		opt.refresh()
	else
		s.main:SetAttribute(self.variable,self:GetChecked() and true)
		s.flyoutsNeedFilled = true -- flag to fill flyouts, button attributes about to be wiped
		-- wipes the alt-type* or type attributes from all flyout buttons
		for _,flyout in pairs(s.knownFlyouts) do
			for i=1,#flyout.buttons do
				s.WipeButtonAttributes(flyout.buttons[i])
			end
		end
	end
end

useOpt.text:SetText("Use Item Or Spell When Selecting")
useOpt.text:SetFontObject("GameFontNormal")
useOpt.variable = "UseWhenSelecting"
useOpt:SetScript("OnClick",s.UpdateSetting)

dontOpt.text:SetText("Use But Don't Select With <Alt>")
dontOpt.text:SetFontObject("GameFontNormal")
dontOpt.variable = "DontSelectWithAlt"
dontOpt:SetScript("OnClick",s.UpdateSetting)

macroOpt.text:SetText("Don't Add Macro To Tooltip")
macroOpt.text:SetFontObject("GameFontNormal")
macroOpt.variable = "DontAddToMacroTooltip"
macroOpt:SetScript("OnClick",s.UpdateSetting)

opt.version:SetText(format("version %s",GetAddOnMetadata("Select","Version")))

--[[ The All-Important Slash Command ]]

SlashCmdList["SELECT"] = function()
	-- actually, the actual /select does nothing
	-- the command is necessary to exist in the macro so the /click knows what to do
end
SLASH_SELECT1 = "/select"


