
--[[
	type:
		none: (item) or (spell) of said name
		item: (item) partial name, item id
		type: (item) Quest, Herb, Metal & Stone, Gem, Leather, Cloth
		spell: (spell) partial name, spell id
		mount: (spell) flying, land, any, fflying, fland
		profession: (spell) primary, secondary, any
		pet: (macro) name, any, favorite
		toy: (item) favorite, any, partial
]]

local _,s = ...

s.rtable = {} -- reusable table where flyout button attributes are accumulated
local rtable = s.rtable

s.filter = {} -- table of search:keyword search functions (s.filter.item(arg))
s.mountIDs = {} -- table of owned mountIDs populated when mount filter used/number of owned mounts changes

s.toySearchString = "" -- there is no C_ToyBox.GetFilterString, so need to watch for it ourselfs

-- adds a type/value attribute pair to rtable if it's not already there
local function addToTable(actionType,actionValue)
	for i=1,#rtable,2 do
		if rtable[i]==actionType and rtable[i+1]==actionValue then
			return
		end
	end
	tinsert(rtable,actionType)
	tinsert(rtable,actionValue)
end

-- returns true if arg and compareTo match. arg is a [Cc][Aa][Ss][Ee]-insensitive pattern
-- so we can't equate them and to get an exact match we need to append ^ and $ to the pattern
local function compare(arg,compareTo,exact)
	return compareTo:match(format("^%s$",arg)) and true
end

--[[ Item Cache ]]

s.itemCache = {}
s.bagsToCache = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,["Worn"]=true}

function s.BAG_UPDATE(self,bag)
	if bag>=0 and bag<=4 then
		s.bagsToCache[bag] = true
		s.StartTimer(0.05,s.CacheBags)
	end
end

function s.PLAYER_EQUIPMENT_CHANGED(self,slot,equipped)
	if equipped then
		s.bagsToCache.Worn = true
		s.StartTimer(0.05,s.CacheBags)
	end
end

local function addToCache(itemID)
	local name = GetItemInfo(itemID)
	if name then
		s.itemCache[format("item:%d",itemID)] = name
	else
		s.StartTimer(0.1,s.CacheBags)
		return true
	end
end

function s.CacheBags()
	local cacheComplete = true
	if not s.cacheTimeout or s.cacheTimeout < 10 then
		for bag in pairs(s.bagsToCache) do
			if bag=="Worn" then
				for slot=1,19 do
					local itemID = GetInventoryItemID("player",slot)
					if itemID and addToCache(itemID) then
						cacheComplete = false
					end
				end
			else
				for slot=1,GetContainerNumSlots(bag) do
					local itemID = GetContainerItemID(bag,slot)
					if itemID and addToCache(itemID) then
						cacheComplete = false
					end
				end
			end
		end
	end
	if cacheComplete then
		s.flyoutsNeedFilled = true
		wipe(s.bagsToCache)
		if s.firstLogin then
			s.firstLogin = nil
			s.FillAttributes()
         s.FillFlyoutsOverTime() -- once cache complete, start filling flyouts
		end
	else
		s.cacheTimeout = (s.cacheTimeout or 0)+1
	end
end

--[[ Toy Cache ]]

-- toy cache is backwards due to bugs with secure action buttons' inability to
-- cast a toy by item:id (and inability to SetMacroItem from a name /sigh)
-- cache is indexed by the toyName and equals the itemID
-- the attribValue for toys will be the toyName, and unsecure stuff can pull
-- the itemID from toyCache where needed
s.toyCache = {}
s.toysUpdating = nil -- semaphore to prevent re-scanning toys after changing filters

-- TOYS_UPDATED is firing in the frame after changing filters; this is run on a delay
function s.ToysUpdateEnded()
	s.toysUpdating = false
end

function s.TOYS_UPDATED()
	if s.toysUpdating then
		return
	end
	s.toysUpdating = true
	-- note filter settings
	local filterCollected = C_ToyBox.GetCollectedShown()
	local filterUncollected = C_ToyBox.GetUncollectedShown()
   local filterUnusable = C_ToyBox.GetUnusableShown()
	local sources = {}
   local expansions = {}
	for i=1,6 do
		sources[i] = not C_ToyBox.IsSourceTypeFilterChecked(i)
	end
   for i=1,GetNumExpansions() do
      expansions[i] = not C_ToyBox.IsExpansionTypeFilterChecked(i)
   end
	-- set filters to all toys
	C_ToyBox.SetCollectedShown(true)
	C_ToyBox.SetUncollectedShown(false) -- we don't need to uncollected toys
	C_ToyBox.SetAllSourceTypeFilters(true)
   C_ToyBox.SetUnusableShown(true)
   local oldSearchString = s.toySearchString
   C_ToyBox.SetFilterString("")

	-- fill cache with itemIDs = name
	for i=1,C_ToyBox.GetNumFilteredToys() do
		local itemID = C_ToyBox.GetToyFromIndex(i)
		local name = GetItemInfo(itemID)
		if name then
			s.toyCache[name] = itemID
		else
			-- if an itemID doesn't have a name, retry in 0.5 seconds
			s.StartTimer(0.5,s.TOYS_UPDATED)
			-- (don't abort; let other GetItemInfo attempts trigger the rest of the items to cache)
		end
	end

	-- restore filters
   C_ToyBox.SetUnusableShown(filterUnusable)
	C_ToyBox.SetCollectedShown(filterCollected)
	C_ToyBox.SetUncollectedShown(filterUncollected)
	for i=1,6 do
		C_ToyBox.SetSourceTypeFilter(i,sources[i])
	end
   for i=1,GetNumExpansions() do
      C_ToyBox.SetExpansionTypeFilter(i,expansions[i])
   end
   C_ToyBox.SetFilterString(oldSearchString)
   s.StartTimer(0.2,s.ToysUpdateEnded)
end

--[[ Mount Cache ]]

-- instead of digging through all mountIDs when filling a flyout, mountIDs are narrowed to owned mountIDs,
-- and then to flying and land mountIDs

s.ownedMountIDs = {} -- list of mountIDs owned by the player; gathered on PLAYER_LOGIN and mount journal events
s.flyingMountIDs = {} -- list of mountIDs that can fly
s.landMountIDs = {} -- list of mountIDs that can't fly
s.aquaticMountIDs = {} -- list of mountIDs that deal with water

-- lookup table indexed by the mountType return of GetMountInfoExtraByID that says which table a mount belongs to
local mountTypeGroups = {
	[247] = "flyingMountIDs",
	[248] = "flyingMountIDs",
	[231] = "aquaticMountIDs",
	[232] = "aquaticMountIDs",
	[254] = "aquaticMountIDs",
	[269] = "aquaticMountIDs",
}

function s.UpdateOwnedMountIDs()
   wipe(s.ownedMountIDs)
   wipe(s.flyingMountIDs)
   wipe(s.landMountIDs)
   s.mountIDs = C_MountJournal.GetMountIDs()
   for i,mountID in ipairs(s.mountIDs) do
      local _,_,_,_,_,_,_,_,_,hideOnChar,isCollected = C_MountJournal.GetMountInfoByID(mountID)
      if isCollected and hideOnChar~=true then
		 tinsert(s.ownedMountIDs,mountID)
		 local _,_,_,_,mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
		 local mountGroup = mountTypeGroups[mountType]
		 -- if flying or aquatic, mountGroup will be either "flyingMountIDs" or "aquaticMountIDs"
		 if mountGroup then
			tinsert(s[mountGroup], mountID)
		 else -- not flying or aquatic, put in land mounts
            tinsert(s.landMountIDs,mountID)
         end
      end
   end
end

-- when mount journal events fire to change owned pets, repopulate ownedMountIDs
s.MOUNT_JOURNAL_USABILITY_CHANGED = s.UpdateOwnedMountIDs
function s.COMPANION_LEARNED(companionType)
   if companionType=="MOUNT" then
      s.UpdateOwnedMountIDs()
   end
end
s.COMPANION_UNLEARNED = s.COMPANION_LEARNED
s.COMPANION_UPDATE = s.COMPANION_UPDATE


--[[ Filters ]]

-- for arguments without a search, look for items or spells by that name
function s.filter.none(arg)
	-- if a regular item in bags/on person
	if GetItemCount(arg)>0 then
		local _, link = GetItemInfo(arg)
		if link then
			addToTable("item",(link:match("(item:%d+)")))
			return
		end
	end
	-- if a spell
	local spellName,subName = GetSpellInfo(arg)
	if spellName and spellName~="" then
		if subName and subName~="" then
			addToTable("spell",format("%s(%s)",spellName,subName)) -- for Polymorph(Turtle)
		else
			addToTable("spell",spellName)
		end
		return
	end
	-- if a toy
	local toyName = GetItemInfo(arg)
	if toyName and s.toyCache[toyName] then
		addToTable("item",toyName)
	end
end

-- item:id will get all items of that itemID
-- item:name will get all items that contain "name" in its name
function s.filter.item(arg)
	local itemID = tonumber(arg)
	if itemID and GetItemCount(itemID)>0 then
		addToTable("item",format("item:%d",itemID))
		return
	end
	-- look for arg in itemCache
	for itemID,name in pairs(s.itemCache) do
		if name:match(arg) and GetItemCount(name)>0 then
			addToTable("item",itemID)
		end
	end
end
s.filter.i = s.filter.item

-- spell:id will get all spells of that spellID
-- spell:name will get all spells that contain "name" in its name or its flyout parent
function s.filter.spell(arg)
	if tonumber(arg) and IsSpellKnown(arg) then
		local name = GetSpellInfo(arg)
		if name then
			addToTable("spell",name)
			return
		end
	end
	-- look for arg in the spellbook
	for i=1,GetNumSpellTabs() do
		local tabName,_,offset,numSpells,_,offSpecID = GetSpellTabInfo(i)
		if offSpecID==0 then -- don't look through offspec tabs
			for j=offset+1, offset+numSpells do
				local spellType,spellID = GetSpellBookItemInfo(j,"spell")
				local name = GetSpellBookItemName(j,"spell")
				if name and name:match(arg) then
					if spellType=="SPELL" and IsSpellKnown(spellID) then
						addToTable("spell",name)
					elseif spellType=="FLYOUT" then
						local _, _, numFlyoutSlots, isFlyoutKnown = GetFlyoutInfo(spellID)
						if isFlyoutKnown then
							for k=1,numFlyoutSlots do
								local _,_,flyoutSpellKnown,flyoutSpellName = GetFlyoutSlotInfo(spellID,k)
								if flyoutSpellKnown then
									addToTable("spell",flyoutSpellName)
								end
							end
						end
					end
				end
			end
		end
	end
end
s.filter.s = s.filter.spell

-- type:quest will get all quest items in bags, or those on person with Quest in a type field
-- type:name will get all items that have "name" in its type, subtype or slot name
function s.filter.type(arg)
	if ("quest"):match(arg) then
		-- many quest items don't have "Quest" in a type field, but GetContainerItemQuestInfo
		-- has them flagged as quests.  check those first
		for i=0,4 do
			for j=1,GetContainerNumSlots(i) do
				local isQuestItem, questID, isActive = GetContainerItemQuestInfo(i,j)
				if isQuestItem or questID or isActive then
					addToTable("item",format("item:%d",GetContainerItemID(i,j)))
				end
			end
		end
	end
	-- some quest items can be marked quest as an item type also
	for itemID,name in pairs(s.itemCache) do
		if GetItemCount(name)>0 then
			local _, _, _, _, _, itemType, itemSubType, _, itemSlot = GetItemInfo(itemID)
			if itemType and (itemType:match(arg) or itemSubType:match(arg) or itemSlot:match(arg)) then
				addToTable("item",itemID)
			end
		end
	end
end
s.filter.t = s.filter.type

-- mount:any, mount:flying, mount:land, mount:favorite, mount:fflying, mount:fland
-- mount:arg filters mounts that include arg in the name or arg="flying" or arg="land" or arg=="any"
function s.filter.mount(arg)

	-- in Legion mounts indexes aren't "always expanded" but fortunately they gave us GetMountIDs()
	if C_MountJournal.GetNumMounts()~=#s.mountIDs then
		s.mountIDs = C_MountJournal.GetMountIDs()
	end

	-- checking if arg is a number, if so we will do special handling
	local mountSpellID = tonumber(arg)
	if mountSpellID then -- this is a numerical mount (like m:118089)
      for _,mountID in ipairs(s.ownedMountIDs) do
         local mountName,ownedSpellID,_,_,canSummon = C_MountJournal.GetMountInfoByID(mountID)
         if ownedSpellID==mountSpellID or mountID==mountSpellID then
            if canSummon then
               local spellName = GetSpellInfo(ownedSpellID)
               addToTable("spell",spellName)
            end
            return -- can leave early; found the mount
         end
      end
		return -- don't both looking further if a number isn't identified as a mount
	end
	
	local any = compare(arg,"Any")
	local flying = compare(arg,"Flying")
	local land = compare(arg,"Land")
	local aquatic = compare(arg,"Aquatic")
	local fflying = compare(arg,"FFlying") or compare(arg,"FavFlying")
	local fland = compare(arg,"FLand") or compare(arg,"FavLand")
	local faquatic = compare(arg,"FAquatic") or compare(arg,"FavAquatic")
	local favorite = compare(arg,"Favorite") or fflying or fland

   -- some repetition of code here done for optimization; look for flying, land or either independently

   if flying or fflying then -- only look through flying mounts
      for _,mountID in ipairs(s.flyingMountIDs) do
         local mountName, mountSpellID, _,_, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
         if mountName and canSummon then
            local spellName = GetSpellInfo(mountSpellID)
            if not fflying or isFavorite then
               addToTable("spell",spellName)
            end
         end
      end
   elseif land or fland then -- only look through land mounts
      for _,mountID in ipairs(s.landMountIDs) do
         local mountName, mountSpellID, _,_, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
         if mountName and canSummon then
            local spellName = GetSpellInfo(mountSpellID)
            if not fland or isFavorite then
               addToTable("spell",spellName)
            end
         end
	  end
	elseif aquatic or faquatic then -- only look through aquatic mounts
		for _,mountID in ipairs(s.aquaticMountIDs) do
		   local mountName, mountSpellID, _,_, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
		   if mountName and canSummon then
			  local spellName = GetSpellInfo(mountSpellID)
			  if not faquatic or isFavorite then
				 addToTable("spell",spellName)
			  end
		   end
		end
   else -- look through all mounts
      for _,mountID in ipairs(s.ownedMountIDs) do
         local mountName, mountSpellID, _,_, canSummon, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
         if mountName and canSummon then
            local spellName = GetSpellInfo(mountSpellID)
            if (favorite and isFavorite) or any or mountName:match(arg) or spellName:match(arg) then
               addToTable("spell",spellName)
            end
         end
      end
   end

end
s.filter.m = s.filter.mount



-- profession:arg filters professions that include arg in the name or arg="primary" or arg="secondary" or arg="all"
function s.filter.profession(arg)
	s.professions = s.professions or {}
	wipe(s.professions)
	s.RunForEach(function(entry) tinsert(s.professions,entry or false) end,GetProfessions())
	local any = compare(arg,"Any")
	local primaryOnly = compare(arg,"Primary")
	local secondaryOnly = compare(arg,"Secondary")

	for index,profession in pairs(s.professions) do
		if profession then
			local name, _, _, _, numSpells, offset = GetProfessionInfo(profession)
			if (index<3 and primaryOnly) or (index>2 and secondaryOnly) or any or name:match(arg) then
				for i=1,numSpells do
					local _, spellID = GetSpellBookItemInfo(offset+i,"professions")
					addToTable("spell",(GetSpellInfo(spellID)))
				end
			end
		end
	end
end



-- pet:arg filters companion pets that include arg in the name or arg="any" or arg="favorite(s)"
function s.filter.pet(arg,rtable)
	local any = compare(arg,"Any")
	local favorite = compare(arg,"Favorite")
	if not any and not favorite then
		local name = arg:gsub("%[[A-Z][a-z]%]",function(c) return c:sub(2,2) end) -- convert arg to a regular string
		local speciesID,petID = C_PetJournal.FindPetIDByName(name)
		if petID then
			local _,customName,_,_,_,_,_,realName = C_PetJournal.GetPetInfoByPetID(petID)
			addToTable("macro",format("/summonpet %s",customName or realName))
			return
		end
	end
	-- the following can create 150-200k of garbage...why? pets are officially unsupported so this is permitted to stay
	for i=1,C_PetJournal.GetNumPets() do
		local petID,_,owned,customName,_,isFavorite,_,realName = C_PetJournal.GetPetInfoByIndex(i)
		if petID and owned then
			if any or (favorite and isFavorite) or (customName and customName:match(arg)) or (realName and realName:match(arg)) then
				addToTable("macro",format("/summonpet %s",customName or realName))
			end
		end
	end
end
s.filter.p = s.filter.pet

-- toy:arg filters items from the toybox; arg="favorite" "any" or partial name
function s.filter.toy(arg)
	local any = compare(arg,"Any")
	local favorite = compare(arg,"Favorite")
	if favorite then -- toy:favorite
		for toyName,itemID in pairs(s.toyCache) do
			if C_ToyBox.GetIsFavorite(itemID) then
				addToTable("item",toyName)
			end
		end
	elseif any then -- toy:any
		for toyName in pairs(s.toyCache) do
			addToTable("item",toyName)
		end
	else -- toy:name
		for toyName in pairs(s.toyCache) do
			if toyName:match(arg) then
				addToTable("item",toyName)
			end
		end
	end
end

