
--Q u o t e:
--Every player GUID i've run across so far begins with 0x00, i've been trying (with success so far, but who knows if there are counterexamples, I'd love to see them) to use the upper bits of the GUID to determine what kind of GUID it is, right now I have:
--0xF13 -- NPC
--0xF53 -- NPC
--0xF14 -- PET
--0xF54 -- PET
--0x000 -- Player

--It's a player if the upper bits masked with 0x00f = 0x000
--It's a creature if the upper bits masked with 0x00f = 0x003
--It's a pet if the upper bits masked with 0x00f = 0x004

--There are two new combat log events for the next test realm update:
--SPELL_SUMMON
--SPELL_CREATE  (trap, warlock portacl etc)
--These are sent with the guid and name of the creature or object that is created by a spell (along with who cast it, naturally)

--spellSchool Decimal school
--0x01 1 physical
--0x02 2 holy
--0x04 4 fire
--0x08 8 nature
--0x10 16 frost
--0x20 32 shadow
--0x40 64 arcane

--powerType Type:
-- -2 health
--  0 mana
--  1 rage
--  2 focus
--  3 energy
--  4 pet happiness

--missType:
--"DODGE"
--"ABSORB"
--"RESIST"
--"PARRY"
--"MISS"
--"BLOCK"
--"REFLECT"
--"DEFLECT" (unconfirmed)
--"IMMUNE"
--"EVADE"

--auraType:
--"BUFF"
--"DEBUFF"

--environmentalType:
--"DROWNING"
--"FALLING"
--"FATIGUE"
--"FIRE"
--"LAVA"
--"SLIME"

--failedType:
--"Out of range"
--"Interrupted"
--"Not enough mana/rage/energy"
--"Not yet recovered"
--"Target needs to be in front of you."
--"Your target is dead"
--"No target"
--"Must have a Ranged Weapon equipped"

local unpack = table.unpack or unpack;

-- *************************************************************************
-- all the event handling
-- *************************************************************************

yacl.event_table    = { };
yacl.eventtype_table= { };

-- *************************************************************************
-- register yacl to receive a primary event from the game
-- *************************************************************************

function yacl:register_event(frame,event,func)
   frame:RegisterEvent(event);
   self.event_table[event]=func;
   -- self:debug("Registered Event " .. event);
end

-- *************************************************************************
-- register subfunctions to analyse the combat log
-- *************************************************************************

function yacl:register_eventtype(eventtype,func)
   self.eventtype_table[eventtype]=func;
end

-- *************************************************************************
-- primary event dispatcher
-- *************************************************************************

function yacl:on_event(frame,event,...)
   local func=self.event_table[event];
   if(func) then
      func(self,...);
   end
end

-- *************************************************************************
-- all the events we want to be informed about:
-- *************************************************************************

function yacl:init_events(frame)
   
   -- primary game events
   
   
   self:register_event(frame,"PLAYER_REGEN_DISABLED"  ,self.on_combat_start);
   self:register_event(frame,"PLAYER_REGEN_ENABLED"   ,self.on_combat_stop);
   
   self:register_event(frame,"VARIABLES_LOADED"           ,self.on_variables_loaded);
   -- self:register_event(frame,"COMBAT_LOG_EVENT"           ,self.on_combat_log);
   self:register_event(frame,"COMBAT_LOG_EVENT_UNFILTERED",self.on_combat_log);
   
   self:register_event(frame,"GROUP_ROSTER_UPDATE"        ,self.on_party_change);
   self:register_event(frame,"RAID_ROSTER_UPDATE"         ,self.on_party_change);
   self:register_event(frame,"UNIT_NAME_UPDATE"           ,self.on_party_change);
   self:register_event(frame,"UNIT_PET"                   ,self.on_party_change);
   self:register_event(frame,"PLAYER_ENTERING_WORLD"      ,self.on_entering_world);
   self:register_event(frame,"ZONE_CHANGED_NEW_AREA"      ,self.on_zone_changed);
   
   self:register_event(frame,"PLAYER_DEAD"                ,self.on_player_dead   );
   
   -- combat log subevents
   
   self:register_eventtype("SWING_DAMAGE"               ,self.onSWING_DAMAGE               );
   self:register_eventtype("SWING_MISSED"               ,self.onSWING_MISSED               );
   self:register_eventtype("RANGE_DAMAGE"               ,self.onRANGE_DAMAGE               );
   self:register_eventtype("RANGE_MISSED"               ,self.onRANGE_MISSED               );
   self:register_eventtype("DAMAGE_SHIELD"              ,self.onDAMAGE_SHIELD              );
   self:register_eventtype("DAMAGE_SHIELD_MISSED"       ,self.onDAMAGE_SHIELD_MISSED       );
   self:register_eventtype("DAMAGE_SPLIT"               ,self.onDAMAGE_SPLIT               );
   self:register_eventtype("SPELL_DAMAGE"               ,self.onSPELL_DAMAGE               );
   self:register_eventtype("SPELL_MISSED"               ,self.onSPELL_MISSED               );
   self:register_eventtype("SPELL_HEAL"                 ,self.onSPELL_HEAL                 );
   self:register_eventtype("SPELL_ENERGIZE"             ,self.onSPELL_ENERGIZE             );
   self:register_eventtype("SPELL_PERIODIC_MISSED"      ,self.onSPELL_PERIODIC_MISSED      );
   self:register_eventtype("SPELL_PERIODIC_DAMAGE"      ,self.onSPELL_PERIODIC_DAMAGE      );
   self:register_eventtype("SPELL_PERIODIC_HEAL"        ,self.onSPELL_PERIODIC_HEAL        );
   self:register_eventtype("SPELL_PERIODIC_DRAIN"       ,self.onSPELL_PERIODIC_DRAIN       );
   self:register_eventtype("SPELL_PERIODIC_LEECH"       ,self.onSPELL_PERIODIC_LEECH       );
   self:register_eventtype("SPELL_PERIODIC_ENERGIZE"    ,self.onSPELL_PERIODIC_ENERGIZE    );
   self:register_eventtype("SPELL_DRAIN"                ,self.onSPELL_DRAIN                );
   self:register_eventtype("SPELL_LEECH"                ,self.onSPELL_LEECH                );
   self:register_eventtype("SPELL_INTERRUPT"            ,self.onSPELL_INTERRUPT            );
   self:register_eventtype("SPELL_EXTRA_ATTACKS"        ,self.onSPELL_EXTRA_ATTACKS        );
   self:register_eventtype("SPELL_INSTAKILL"            ,self.onSPELL_INSTAKILL            );
   self:register_eventtype("SPELL_DURABILITY_DAMAGE"    ,self.onSPELL_DURABILITY_DAMAGE    );
   self:register_eventtype("SPELL_DURABILITY_DAMAGE_ALL",self.onSPELL_DURABILITY_DAMAGE_ALL);
   self:register_eventtype("SPELL_DISPEL_FAILED"        ,self.onSPELL_DISPEL_FAILED        );
   self:register_eventtype("SPELL_AURA_DISPELLED"       ,self.onSPELL_AURA_DISPELLED       );
   self:register_eventtype("SPELL_AURA_STOLEN"          ,self.onSPELL_AURA_STOLEN          );
   self:register_eventtype("SPELL_AURA_APPLIED"         ,self.onSPELL_AURA_APPLIED         );
   self:register_eventtype("SPELL_AURA_REMOVED"         ,self.onSPELL_AURA_REMOVED         );
   self:register_eventtype("SPELL_AURA_APPLIED_DOSE"    ,self.onSPELL_AURA_APPLIED_DOSE    );
   self:register_eventtype("SPELL_AURA_REMOVED_DOSE"    ,self.onSPELL_AURA_REMOVED_DOSE    );
   self:register_eventtype("SPELL_CAST_START"           ,self.onSPELL_CAST_START           );
   self:register_eventtype("SPELL_CAST_SUCCESS"         ,self.onSPELL_CAST_SUCCESS         );
   self:register_eventtype("SPELL_CAST_FAILED"          ,self.onSPELL_CAST_FAILED          );
   
   self:register_eventtype("SPELL_CREATE"               ,self.onSPELL_CREATE              );
   self:register_eventtype("SPELL_SUMMON"               ,self.onSPELL_SUMMON              );
   
   self:register_eventtype("ENVIRONMENTAL_DAMAGE"       ,self.onENVIRONMENTAL_DAMAGE      );
   
   self:register_eventtype("PARTY_KILL"  ,self.onPARTY_KILL);
   self:register_eventtype("UNIT_DIED"   ,self.onUNIT_DIED);
   
end

-- *************************************************************************
-- hopefully not needed
-- *************************************************************************

function yacl:on_unfiltered_combat_log()
   -- self:analyse_arguments("unfiltered");
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:on_combat_start()
   self.m_in_combat=true;
   self:setup_color();
   if(yacl_global_settings.m_auto_hide) then
      if(not yacl_global_settings.m_minimized_mode) then
         self:set_minimized_mode(true);
      end
   end
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:on_combat_stop()
   self.m_in_combat=nil;
   self:check_combat_timeouts(true);
   self:setup_color();
   if(yacl_global_settings.m_auto_show) then
      self:set_minimized_mode(false);
   end
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:on_variables_loaded()
   
   self:debug("YACL vars loaded");
   self.m_vars_loaded=true;
   
   self:UpdateDataBaseMetaTables();
   yacl_database.m_structure_update=true;
   
   if(yacl_global_settings.m_bars_type==nil) then yacl_global_settings.m_bars_type=1; end
   
   if(not yacl_global_settings.m_version or (yacl_global_settings.m_version<yacl_global_defaults.m_version) ) then
      yacl_global_settings=yacl_copy_table(yacl_global_defaults);
      self:debug("YACL reset to global defaults");
   end
   yacl:set_minimized_mode(yacl_global_settings.m_minimized_mode);
   self:setup_settings_frame();
   
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:on_entering_world()
   self.update_party_flag=true;
   self.update_zone_flag =true;
   
   if(not GetBindingKey("YACLTOGGLE")) then
      SetBinding("^",nil);
      SetBinding("^","YACLTOGGLE");
      -- self:debug("Set default keybindings");
   end
   
end


function yacl:on_zone_changed()
   self.update_zone_flag=true;
end

-- *************************************************************************
-- combat log subevent dispatcher
-- *************************************************************************

function yacl:on_combat_log()
   
   local e=self.event;
   e.timestamp,     -- 1 ok
   e.eventtype,     -- 2 ok
   e.hideCaster,    -- 3 ok
   e.srcGUID,       -- 4 ok
   e.srcName,       -- 5 ok
   e.srcFlags,      -- 6 ok
   e.srcFlags2,     -- 7 ok
   e.dstGUID,       -- 8 ok
   e.dstName,       -- 9 ok
   e.dstFlags,      -- 10 ok
   e.dstFlags1,		-- 11
   e[1],e[2],e[3],e[4],e[5],e[6],e[7],e[8],e[9],e[10],e[11],e[12] = CombatLogGetCurrentEventInfo();
   
   if(e.eventtype) then
      local func=self.eventtype_table[e.eventtype];
      if(func) then
         local source_control = bit.band(e.srcFlags,COMBATLOG_OBJECT_CONTROL_MASK);
         local source_person=nil;
         if( ( source_control==COMBATLOG_OBJECT_CONTROL_PLAYER ) and e.srcGUID) then
            source_person=yacl_database.players[e.srcGUID];
            if(not source_person) then
               source_person=self.totems[e.srcGUID];
               -- self:debug("Warning : missing source person in database = " .. (e.srcName or "Unknown") .. " : " .. e.srcGUID);
            else
               if(not source_person.in_group) then
                  --still in combat log, but no longer in group. do not record events ...
                  source_person=nil;
                  -- yacl:debug("ignoring source person");
               end
            end
         end
         
         local dest_control   = bit.band(e.dstFlags,COMBATLOG_OBJECT_CONTROL_MASK);
         local dest_person=nil;
         if(( dest_control==COMBATLOG_OBJECT_CONTROL_PLAYER ) and e.dstGUID) then
            dest_person=yacl_database.players[e.dstGUID];
            if(not dest_person) then
               dest_person=self.totems[e.dstGUID];
               --  self:debug("Warning : missing dest person in database = " .. (e.dstName or "Unknown"));
            else
               if(not dest_person.in_group) then
                  --still in combat log, but no longer in group. do not record events ...
                  dest_person=nil;
                  -- yacl:debug("ignoring dest person");
               end
            end
         end
         
         if( source_person or dest_person) then
            --local text=format("%s from %s to %s",e.eventtype,e.srcName or e.srcGUID,e.dstName or e.dstGUID);
            --self:debug(text);
            func(self,source_person,dest_person,e);
         else
            -- local text=format("Without persons: %s",e.eventtype);
            -- self:debug(text);
         end
      else
         --local text=format("UNKNOWN %s from %s to %s",e.eventtype,e.srcName or e.srcGUID,e.dstName or e.dstGUID);
         --self:debug(text);
      end
   end
end

-- *****************************************************************************************************

function yacl:onSPELL_CREATE(source_person,dest_person)
   
   --self:debug("SPELL_CREATE");
end

function yacl:onSPELL_SUMMON(source_person,dest_person)
   
   local e=self.event;
   local dest_type = bit.band(e.dstFlags,COMBATLOG_OBJECT_TYPE_MASK);
   
   if(dest_type==COMBATLOG_OBJECT_TYPE_NPC) then
      
      local totems=source_person.totems;
      if(not totems) then
         totems={};
         source_person.totems=totems;
      end
      
      local old_totem_guid=totems[e.dstName];
      if(old_totem_guid) then
         self.totems[old_totem_guid]=nil;
         -- self:debug("Replacing totem type");
      end
      
      self.totems[e.dstGUID]=source_person;
      totems[e.dstName]=e.dstGUID;
      -- self:debug("Summon Totem " .. source_person.name .. " : " .. e.dstGUID );
   else
      if(dest_type==COMBATLOG_OBJECT_TYPE_PET) then
         --self:debug("Summon new Pet " .. source_person.name .. " : " .. e.dstGUID );
      else
         if(dest_type==COMBATLOG_OBJECT_TYPE_GUARDIAN) then
            --self:debug("Summon Guardian " .. source_person.name .. " : " .. e.dstGUID );
         else
            if(dest_type==COMBATLOG_OBJECT_TYPE_OBJECT) then
               --self:debug("Summon Object " .. source_person.name .. " : " .. e.dstGUID );
            else
               -- self:debug("Summon TYPE " .. dest_type .. " " .. source_person.name .. " : " .. e.dstGUID );
            end
         end
      end
   end
end

-- *****************************************************************************************************

local yacl_spell_info_numbers=  -- update also yacl_spell_info
{
   ["UNKNOWN"  ]=65536;
   ["DROWNING" ]=65537;
   ["FALLING"  ]=65538;
   ["FATIGUE"  ]=65539;
   ["FIRE"     ]=65540;
   ["LAVA"     ]=65541;
   ["SLIME"    ]=65542;
};

function yacl:onENVIRONMENTAL_DAMAGE(source_person,dest_person,e)
   local environmentalType,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing = unpack(e,1,10);
   spellId=yacl_spell_info_numbers[environmentalType];
   if(not spellId) then  spellId=65536; end -- unknown
   self:AddCombatDamage(source_person,dest_person,spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,school);
end

function yacl:onSWING_DAMAGE(source_person,dest_person,e)
   local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = unpack(e,1,9);
   self:AddCombatDamage(source_person,dest_person,0,amount,overkill ,resisted,blocked,critical,glancing,crushing,school);
end

function yacl:onSWING_MISSED(source_person,dest_person,e)
   local missType, isOffHand, amountMissed = unpack(e,1,3);
   self:AddCombatMiss(source_person,dest_person,0,missType,1);
end

function yacl:onRANGE_DAMAGE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing = unpack(e,1,12);
   self:AddCombatDamage(source_person,dest_person,spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,spellSchool);
end

function yacl:onRANGE_MISSED(source_person,dest_person,e)
   local spellId, spellName, spellSchool, missType, isOffHand, amountMissed = unpack(e,1,6);
   self:AddCombatMiss(source_person,dest_person,spellId,missType,spellSchool);
end

function yacl:onDAMAGE_SHIELD(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing	= unpack(e,1,12);
   self:AddCombatDamage(source_person,dest_person,spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,spellSchool);
end

function yacl:onDAMAGE_SHIELD_MISSED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,missType,isOffHand,amountMissed = unpack(e,1,6);
   self:AddCombatMiss(source_person,dest_person,spellId,missType,spellSchool);
end

function yacl:onDAMAGE_SPLIT(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing = unpack(e,1,12);
   self:AddCombatDamage(source_person,dest_person,spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,spellSchool);
end

function yacl:onSPELL_DAMAGE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing = unpack(e,1,12);
   self:AddCombatDamage(source_person,dest_person,spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,spellSchool);
end

function yacl:onSPELL_MISSED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,missType,isOffHand,amountMissed = unpack(e,1,6);
   --self:debug("Spell miss " .. spellName .. " type=" .. missType .. " school=" ..spellSchool);
   self:AddCombatMiss(source_person,dest_person,spellId,missType,spellSchool);
end

function yacl:onSPELL_HEAL(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overhealing,absorbed,critical = unpack(e,1,7);
   self:AddCombatHeal(source_person,dest_person,spellId,amount,overhealing,critical);
end

function yacl:onSPELL_ENERGIZE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType	= unpack(e,1,5);
end

function yacl:onSPELL_PERIODIC_MISSED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,missType,isOffHand,amountMissed = unpack(e,1,6);
   self:AddCombatMiss(source_person,dest_person,-spellId,missType,spellSchool);
end

function yacl:onSPELL_PERIODIC_DAMAGE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing = unpack(e,1,12);
   self:AddCombatDamage(source_person,dest_person,-spellId,amount,overkill ,resisted,blocked,critical,glancing,crushing,spellSchool);
end

function yacl:onSPELL_PERIODIC_HEAL(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,overhealing,absorbed,critical	= unpack(e,1,7);
   self:AddCombatHeal(source_person,dest_person,spellId,amount,overhealing,critical);
end

function yacl:onSPELL_PERIODIC_DRAIN(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType,extraAmount	= unpack(e,1,6);
end

function yacl:onSPELL_PERIODIC_LEECH(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType,extraAmount	= unpack(e,1,6);
end

function yacl:onSPELL_PERIODIC_ENERGIZE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType = unpack(e,1,5);
end

function yacl:onSPELL_DRAIN(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType,extraAmount	= unpack(e,1,6);
end

function yacl:onSPELL_LEECH(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount,powerType,extraAmount = unpack(e,1,6);
end

function yacl:onSPELL_INTERRUPT(source_person,dest_person,e)
   local spellId,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool	= unpack(e,1,6);
end

function yacl:onSPELL_EXTRA_ATTACKS(source_person,dest_person,e)
   local spellId,spellName,spellSchool,amount = unpack(e,1,4);
   self:AddCombatDamage(source_person,dest_person,spellId,amount,0,nil,nil,nil,nil,spellSchool);
end

function yacl:onSPELL_INSTAKILL(source_person,dest_person,e)
   local spellId,spellName,spellSchool	= unpack(e,1,3);
end

function yacl:onSPELL_DURABILITY_DAMAGE(source_person,dest_person,e)
   local spellId,spellName,spellSchool	= unpack(e,1,3);
end

function yacl:onSPELL_DURABILITY_DAMAGE_ALL(source_person,dest_person,e)
   local spellId,spellName,spellSchool	= unpack(e,1,3);
end

function yacl:onSPELL_DISPEL_FAILED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool	= unpack(e,1,6);
end

function yacl:onSPELL_AURA_DISPELLED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool,auraType = unpack(e,1,7);
end

function yacl:onSPELL_AURA_STOLEN(source_person,dest_person,e)
   local spellId,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool,auraType = unpack(e,1,7);
end

function yacl:onSPELL_AURA_APPLIED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,auraType = unpack(e,1,4);
   --(source arguments are nil)
end

function yacl:onSPELL_AURA_REMOVED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,auraType = unpack(e,1,4);
   --(source arguments are nil)
end

function yacl:onSPELL_AURA_APPLIED_DOSE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,auraType,amount = unpack(e,1,5);
   --(source arguments are nil)
end

function yacl:onSPELL_AURA_REMOVED_DOSE(source_person,dest_person,e)
   local spellId,spellName,spellSchool,auraType,amount = unpack(e,1,5);
   --(source arguments are nil)
end

function yacl:onSPELL_CAST_START(source_person,dest_person,e)
   local spellId,spellName,spellSchool	= unpack(e,1,3);
   if(source_person and not source_person.t_combat) then
      spellId=tonumber(spellId);
      local pre_combat=source_person.pre_combat;
      if(not pre_combat) then
         pre_combat={};
         source_person.pre_combat=pre_combat;
      end
      if(not pre_combat[spellId]) then
         pre_combat[spellId]=self.event.timestamp;
         --self:debug("Creating pre combat time for code " .. spellId);
      end
   end
   --self:debug(self.event.timestamp.."Spellcast start " .. spellName);
end

function yacl:onSPELL_CAST_SUCCESS(source_person,dest_person,e)
   local spellId,spellName,spellSchool	= unpack(e,1,3);
   if(source_person and not source_person.t_combat) then
      spellId=tonumber(spellId);
      local pre_combat=source_person.pre_combat;
      if(not pre_combat) then
         pre_combat={};
         source_person.pre_combat=pre_combat;
      end
      if(not pre_combat[spellId]) then
         pre_combat[spellId]=self.event.timestamp;
         --self:debug("Creating pre combat time for code " .. spellId);
      end
   end
end

local ignore_hammering=
{
   [SPELL_FAILED_SPELL_IN_PROGRESS]=true;
   [SPELL_FAILED_NOT_READY]=true;
}

function yacl:onSPELL_CAST_FAILED(source_person,dest_person,e)
   local spellId,spellName,spellSchool,missType		= unpack(e,1,4);
   if(source_person and not source_person.t_combat) then
      spellId=tonumber(spellId);
      local pre_combat=source_person.pre_combat;
      if(pre_combat) then
         if(not ignore_hammering[missType]) then
            pre_combat[spellId]=nil;
            --self:debug("Removing pre combat time for code " .. spellId .. " : " .. missType);
         end
      end
   end
end

function yacl:onPARTY_KILL(source_person,dest_person,e)
   -- inc kill counter for source person
   if(source_person) then
      local info=source_person.i[1];
      info.k=info.k+1;
      source_person.i_changed=true;
      yacl_database.value_update=true;
   end
end

function yacl:onUNIT_DIED(source_person,dest_person,e)
   -- inc death counter for dest_person
   if(dest_person) then
      if(self.event.dstGUID==dest_person.guid) then
         local info=dest_person.i[1];
         info.d=info.d+1;
         dest_person.i_changed=true;
         yacl_database.value_update=true;
      else
         -- self:debug("Delete Totem for " .. dest_person.name );
         self.totems[self.event.dstGUID]=nil;
      end
   end
end

function yacl:on_player_dead()
   -- this is a dirty work around ! that needs to be fixed in the combat log !
   -- self:debug("PLAYER DIED");
   -- self:onUNIT_DIED(nil,yacl_database.players[self.player_guid]);
end
