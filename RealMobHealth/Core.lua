--[[	RealMobHealth
	by SDPhantom
	https://www.wowinterface.com/forums/member.php?u=34145	]]
------------------------------------------------------------------

local Name,AddOn=...;
_G[Name]=AddOn;

--	GUID Format
--	[Unit type]-0-[server ID]-[instance ID]-[zone UID]-[ID]-[spawn UID]
--	Unit Types:	Creature, GameObject, Pet, Vehicle, Vignette
--	Player:	Player-[server ID]-[ID]

--------------------------
--[[	SavedVar	]]
--------------------------
local HealthCache={};
RealMobHealth_CreatureHealthCache=HealthCache;

--------------------------
--[[	Local Variables	]]
--------------------------
local LevelCache={};
local DamageCache={};

----------------------------------
--[[	Local References	]]
----------------------------------
local CombatLogGetCurrentEventInfo=CombatLogGetCurrentEventInfo;
local math_ceil=math.ceil;
local math_max=math.max;
local string_format=string.format;
local string_gsub=string.gsub;
local string_match=string.match;
local UnitGUID=UnitGUID;
local UnitHealth=UnitHealth;
local UnitHealthMax=UnitHealthMax;
local UnitLevel=UnitLevel;

----------------------------------
--[[	Helper Functions	]]
----------------------------------
--	Extracts creature type and ID from GUID
local function GetCreatureFromGUID(guid) return string_match(guid,"^(.-)%-0%-%d+%-%d+%-%d+%-(%d+)%-%x+$"); end

local function ProcessUnit(unit)--	Called when we're aware of a new/updated unit
	local guid,level=UnitGUID(unit),UnitLevel(unit);
	if guid and (level or -1)>0 then
--		Check if mob dead/reset (Clear damage cache)
		local cur,max=UnitHealth(unit),UnitHealthMax(unit);
		if (cur==0 or cur==max) and DamageCache[guid] then
			DamageCache[guid]=nil;
		end

--		Cache level
		local utype=GetCreatureFromGUID(guid);
		if utype=="Creature" or utype=="Vignette" then
			if cur>0 then LevelCache[guid]=level;--	Save level if alive
			elseif LevelCache[guid] then LevelCache[guid]=nil; end--	Delete if dead
		end
	end
end

local function GetHealthAdjustmentFromEvent(...)--	Process CLE into relevant GUID and health change info (Also returns overkill/overheal as a flag)
	local _,event=...;
	local prefix,suffix=string_match(event,"^([^_]+)_(.-)$");

--	Convert SPELL_PERIODIC and SPELL_BUILDING into just SPELL (Previous line actually puts PERIODIC_ and BUILDING_ in suffix)
	if prefix=="SPELL" then suffix=string_gsub(string_gsub(suffix,"^PERIODIC_",""),"^BUILDING_",""); end

--	Capture relevant args
	local guid,amount,over;
	if prefix=="SWING" then			_,_,_,_,_,_,_,guid,_,_,_,amount,over=...;
	elseif prefix=="ENVIRONMENTAL" then	_,_,_,_,_,_,_,guid,_,_,_,_,amount,over=...;
	elseif prefix=="RANGE" then		_,_,_,_,_,_,_,guid,_,_,_,_,_,_,amount,over=...;
	elseif prefix=="SPELL" then		_,_,_,_,_,_,_,guid,_,_,_,_,_,_,amount,over=...;
	elseif event=="UNIT_DIED" then
		_,_,_,_,_,_,_,guid=...;
		return guid,0,true;--	Unit dead, send zero change and flag overkill
	end

	if guid and amount and (suffix=="DAMAGE" or suffix=="HEAL") then
--		Normalize damage to be positive and heals negative (We are recording damage taken)
		amount=amount-math_max(over,0);--	Remove overkill/overheal from damage/heal amount
		return guid,suffix=="DAMAGE" and amount or -amount,over>0;--	overkill/overheal is -1 when not present
	end
end

--------------------------
--[[	API Functions	]]
--------------------------
AddOn.CreatureHealthOverrides=AddOn.CreatureHealthOverrides or {};--	Future expansion (Pre-loaded values go here and are preferred over recorded ones)

local function IsMobGUID(guid)
	if not guid then return false; end
	local utype=GetCreatureFromGUID(guid);
	return utype=="Creature" or utype=="Vignette";
end

local function IsUnitMob(unit) return IsMobGUID(UnitGUID(unit)); end

AddOn.IsMobGUID=IsMobGUID;
AddOn.IsUnitMob=IsUnitMob;

function AddOn.GetHealth(unit,speculate)
	local guid,level=UnitGUID(unit),UnitLevel(unit);--	UnitLevel() returns -1 for units with hidden levels (Skull/??)
	if guid and (level or -1)>0 then
		local utype,creatureid=GetCreatureFromGUID(guid);
		if utype=="Creature" or utype=="Vignette" then--	We only work on Mobs/NPCs and Rares
			local key=string_format("%s-%02d",creatureid,level);--	Key is made from CreatureID and Level
			local max=AddOn.CreatureHealthOverrides[key] or HealthCache[key];
			local dmg=DamageCache[guid] or 0;--	Default to zero damage

			local pcnt; do--	Right now, health scales 1-100, automaticly adjusts for different scale if this changes
				local cur,max=UnitHealth(unit),UnitHealthMax(unit);
				pcnt=max>0 and cur/max or 0;
			end

			if max then--	Data found, no need to sleculate that
				if pcnt<=0 or pcnt>=1 then return pcnt>=1 and max or 0,max,false,false;--	Unit dead or full health
				elseif dmg>0 and pcnt<1 then return max-dmg,max,false,false;--	Calculate from damage taken
				else return math_ceil(max*pcnt),max,true,false; end--	No damage recorded, calculate from percentage (Less precise)
			elseif speculate and dmg>0 and pcnt<1 then--	Only speculate if allowed and requires damage taken
				max=math_ceil(dmg/(1-pcnt));--	Reverse calculation based on percent health and damage taken
				if pcnt<=0 then return 0,max,false,true;--	Current health can't be more precise than dead
				else return max-dmg,max,true,true; end--	Complete speculation here, precision should improve the more damage a unit takes
			end
		end
	end
end

--------------------------
--[[	Event Handler	]]
--------------------------
local EventFrame=CreateFrame("Frame");
EventFrame:RegisterEvent("ADDON_LOADED");
EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED");
EventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
EventFrame:RegisterEvent("UNIT_TARGET");
EventFrame:RegisterEvent("UNIT_HEALTH");
EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
EventFrame:SetScript("OnEvent",function(self,event,...)
	if event=="ADDON_LOADED" and (...)==Name then
		HealthCache=RealMobHealth_CreatureHealthCache;--	Sync upvalue with SavedVar
		self:UnregisterEvent(event);
	elseif event=="NAME_PLATE_UNIT_ADDED" then	ProcessUnit((...));--		Nameplate scan
	elseif event=="UPDATE_MOUSEOVER_UNIT" then	ProcessUnit("mouseover");--	Mouseover scan
	elseif event=="PLAYER_TARGET_CHANGED" then	ProcessUnit("target");--	Target scan
	elseif event=="UNIT_TARGET" then		ProcessUnit((...).."target");--	Party/Raid target scan
	elseif event=="UNIT_HEALTH" then		ProcessUnit((...));--	Revalidate in case of reset/death
	elseif event=="COMBAT_LOG_EVENT_UNFILTERED" then
		local guid,amount,isover=GetHealthAdjustmentFromEvent(CombatLogGetCurrentEventInfo());
		if guid and amount then--	GetHealthAdjustmentFromEvent() is doing our event filtering work for us, these are nil if the event is irrelevent
			local utype,creatureid=GetCreatureFromGUID(guid);
			if (utype=="Creature" or utype=="Vignette") then--	Only work on Mobs/NPCs and Rares
				local totaldmg=math_max((DamageCache[guid] or 0)+amount,0);--	Add the damage (Deals with overheal by clamping at zero)
				if isover and amount>=0 then--	If we overkilled, it's a death (amount<0 is overheal)
					if totaldmg>0 then--	Unit death event will trigger overkill and amount at zero, if we already wiped the damage cache, don't process again
						local level=LevelCache[guid];
						if level then--	We can only record health info if we have all the unit data
							local key=string_format("%s-%02d",creatureid,level);--	Key is made from CreatureID and Level
							HealthCache[key]=math_max(HealthCache[key] or 0,totaldmg);--	Record with the highest seen damage value (Fixes values from partially-witnessed fights)
						end
					end
					DamageCache[guid]=nil;--	Wipe damage cache
				else DamageCache[guid]=totaldmg; end--	Unit still alive, store new damage value
			end
		end
	end
end);
