-- *************************************************************************
-- after loading the database, the meta info ist gone ...
-- *************************************************************************

local _DB      =yacl_database;
local _TONUMBER=tonumber;
local _SETMETA =setmetatable;
local _FLOOR   =math.floor;
local STRING_LEN=string.len;
local FORMAT    =format;


function yacl:UpdateSpellMetaTables(spells)
   if(spells) then
      for key,spell in pairs(spells) do
         _SETMETA(spell,yacl_spell.meta);
      end
   end
end

function yacl:UpdateDataBaseMetaTables()
   
   _DB =yacl_database; -- update DB !
   
   for key,person in pairs(_DB.players) do
      self:UpdateSpellMetaTables(person.d);
      self:UpdateSpellMetaTables(person.di);
      self:UpdateSpellMetaTables(person.h);
      self:UpdateSpellMetaTables(person.hi);
      self:UpdateSpellMetaTables(person.i);
      if(person.owner_guid) then
         -- reset all pet colors
         person.color={ r=0.5; g=0.5; b=0.5; };
      else
         -- reset all player colors
         person.color=nil;
      end
   end
   
   
   if(_DB.fight_start) then
      for key,person in pairs(_DB.fight_start) do
         self:UpdateSpellMetaTables(person.d);
         self:UpdateSpellMetaTables(person.di);
         self:UpdateSpellMetaTables(person.h);
         self:UpdateSpellMetaTables(person.hi);
         self:UpdateSpellMetaTables(person.i);
         
         _SETMETA(person.sum_d ,yacl_spell.meta);
         _SETMETA(person.sum_di,yacl_spell.meta);
         _SETMETA(person.sum_h ,yacl_spell.meta);
         _SETMETA(person.sum_hi,yacl_spell.meta);
      end
   else
      _DB.fight_start={};
   end
   
end

-- *************************************************************************
-- fill the combat database with peoples names  and match pets with owners
-- *************************************************************************

function yacl:NewPerson()
   local person=
   {
      d ={};   -- damage outgoing
      di={};   -- damage incoming
      h ={};   -- heal outgoing
      hi={};   -- heal incoming
      
      i ={};   -- general info section
      
      d_changed = nil;
      di_changed= nil;
      h_changed = nil;
      hi_changed= nil;
      i_changed = nil;
      
      t_combat  = nil; -- combat start time - local time
      t_sum_combat=0;
   };
   -- create dummy spell in info section right away !
   person.i[1]=yacl_spell.new();
   return person;
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:GetAbsolute(guid,var,var2)
   
   local V      =0;
   local players=_DB.players;
   local person =players[guid];
   if(person) then
      V=person.i[1][var];
      local pet=players[person.pet_guid];
      if(pet) then
         V=V+pet.i[1][var];
      end
      if(yacl_global_settings.m_show_fight) then
         local start       =_DB.fight_start;
         local start_person=start[person.guid];
         if(start_person) then
            V=V-start_person.i[1][var];
            local start_pet=start[start_person.pet_guid];
            if(start_pet) then
               V=V-start_pet.i[1][var];
            end
         end
      end
   end
   if(var2) then V=V+self:GetAbsolute(guid,var2); end
   return V;
end

function yacl:GetPerSecond(guid,var)
   local per_second=0;
   local players=_DB.players;
   local start  =_DB.fight_start;
   local person =players[guid];
   if(person) then
      local start_person=nil;
      local V=person.i[1][var];
      local t=person.i[1].t;
      if(yacl_global_settings.m_show_fight) then
         start_person=start[person.guid];
         if(start_person) then
            V=V-start_person.i[1][var];
            t=t-start_person.i[1].t;
         end
      end
      if(t>0) then per_second=V/t; end
      local pet=players[person.pet_guid];
      if(pet) then
         V=pet.i[1][var];
         t=pet.i[1].t;
         if(start_person) then
            local start_pet=start[start_person.pet_guid];
            if(start_pet) then
               V=V-start_pet.i[1][var];
               t=t-start_pet.i[1].t;
            end
         end
         if(t>0) then per_second=per_second+(V/t); end
      end
   end
   return per_second;
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:check_combat_timeouts(force)
   local t=GetTime();
   if( force or ((t-self.m_last_check_combat_time)>0.5) ) then
      self.m_last_check_combat_time=t;
      local _INCOMBAT=UnitAffectingCombat;
      local in_combat=nil;
      for guid,player in pairs(_DB.players) do
         if(player.t_combat) then
            if( ((t-player.t_combat)>10) or not _INCOMBAT(player.id) ) then
               player.t_combat =nil;
               player.pre_combat=nil;
            else
               in_combat=true;
            end
            elseif _INCOMBAT(player.id) then
            in_combat=true;
         end
      end
      
      if(in_combat~=self.m_group_in_combat) then
         if( in_combat) then
            self:start_combat();
         else
            self:leave_combat();
         end
      end
   end
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:prepare_startvalues(person,section)
   local sum_spell=yacl_spell.new();
   for spellId,spell in pairs(person[section]) do
      yacl_spell.add_spell(sum_spell,spell);
   end
   yacl_spell.add_spell(sum_spell,person.i[1]);
   person["sum_"..section]=sum_spell;
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:start_combat()
   if(not self.m_group_in_combat) then
      self.m_group_in_combat=true;
      --self:debug("Group is entering combat");
      local fight_start={};
      for guid,person in pairs(_DB.players) do
         local start_person=yacl_copy_table(person);
         self:prepare_startvalues(start_person,"d");
         self:prepare_startvalues(start_person,"di");
         self:prepare_startvalues(start_person,"h");
         self:prepare_startvalues(start_person,"hi");
         fight_start[guid]=start_person;
      end
      _DB.fight_start=fight_start;
      _DB.fight_start_time=GetTime();
      _DB.m_structure_update=true;
      
      if(yacl_global_settings.m_use_sounds) then
         PlaySound(SOUNDKIT.RAID_WARNING );
      end
   end
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:leave_combat()
   if(self.m_group_in_combat) then
      self.m_group_in_combat=false;
      _DB.fight_duration=GetTime()-_DB.fight_start_time;
   end
end

-- *************************************************************************
--
-- *************************************************************************

function yacl:RefreshCombatTime(person,spellId)
   local t=GetTime();
   local delta;
   if(person.t_combat) then
      delta=t-person.t_combat;
   else
      local pre_combat=person.pre_combat;
      delta=2; -- based on normal weapon speed
      if(pre_combat) then
         local t=pre_combat[spellId];
         if(t) then
            delta=self.event.timestamp-t;
            if(delta<1.5) then
               -- if somebody starts a fight with an instant spell,
               -- we consider the starting timer to be the global cooldown of 1.5 sec
               delta=1.5;
            end
         end
      end
      -- self:debug("Starting fight with combat time="..delta);
   end
   
   -- upper limit for delta is 6 seconds. (mage pyro)
   if(delta>6) then delta=6; end
   
   person.t_sum_combat=person.t_sum_combat+delta;
   person.i[1].t=_FLOOR(person.t_sum_combat*10)/10;
   person.i_changed=true;
   
   person.t_combat =t;
end


local spellSchoolTrans=
{
   [     1]=1;[     2]=2;[     4]=3;[     8]=4;[    16]=5;[    32]=6;[    64]=7;
   ["0x01"]=1;["0x02"]=2;["0x04"]=3;["0x08"]=4;["0x10"]=5;["0x20"]=6;["0x40"]=7;
}

-- *************************************************************************
-- fill the database miss numbers
-- *************************************************************************

local count_misstypes=
{
   ["MISS"  ] =true;
   ["RESIST"] =true;
   ["DODGE" ] =true;
   ["PARRY" ] =true;
   ["BLOCK" ] =true;
}

function yacl:AddCombatMiss(source_person,dest_person,spellId,missType,spellSchool)
   spellSchool=spellSchoolTrans[spellSchool];
   spellId    =_TONUMBER(spellId);
   
   if(spellSchool) then
      if(count_misstypes[missType]) then
         
         if(source_person) then
            self:RefreshCombatTime(source_person,spellId);
            local spell=source_person.d[spellId];
            
            if(not spell) then
               spell=yacl_spell.new();
               source_person.d[spellId]=spell;
               _DB.m_structure_update=true;
            end
            
            if(missType=="DODGE") then
               spell.g=spell.g+1;
               elseif(missType=="PARRY") then
               spell.p=spell.p+1;
               elseif(missType=="BLOCK") then
               spell.b=spell.b+1;
            end
            
            spell.m=spell.m+1;
            spell.n=spell.n+1;
            
            source_person.d_changed=true;
         end
         
         if(dest_person) then
            local spell=dest_person.di[spellId];
            
            if(not spell) then
               spell=yacl_spell.new();
               dest_person.di[spellId]=spell;
               _DB.m_structure_update=true;
            end
            
            if(missType=="DODGE") then
               spell.g=spell.g+1;
               elseif(missType=="PARRY") then
               spell.p=spell.p+1;
               elseif(missType=="BLOCK") then
               spell.b=spell.b+1;
            end
            
            spell.m=spell.m+1;
            spell.n=spell.n+1;
            
            dest_person.di_changed=true;
         end
         
      end
   end
end

-- *************************************************************************
-- fill the database damage numbers
-- *************************************************************************

function yacl:AddCombatDamage(source_person,dest_person,spellId,amount,overkill,resisted,blocked,critical,glancing,crushing,spellSchool)
   
   amount     =_TONUMBER(amount);
   spellId    =_TONUMBER(spellId);
   spellSchool=spellSchoolTrans[spellSchool];
   
   if(amount>0) then
      
      -- self:debug(self.event.timestamp.." AddCombatDamage " .. amount);
      local effective=amount-overkill;
      if(source_person) then
         
         if(not self.m_group_in_combat) then self:start_combat(); end
         
         self:RefreshCombatTime(source_person,spellId);
         local spell=source_person.d[spellId];
         if(not spell) then
            spell=yacl_spell.new();
            source_person.d[spellId]=spell;
            _DB.m_structure_update=true;
         end
         
         -- self:debug(self.event.timestamp.." AddCombatDamage " .. amount);
         
         yacl_spell.add(spell,amount,effective,resisted,blocked,critical,glancing,crushing);
         source_person.d_changed=true;
         
         -- update the damage done sums
         local info=source_person.i[1];
         info.S=info.S+amount;
         
         source_person.i_changed=true;
      end
      -- ***********************************************************
      if(dest_person) then
         local spell=dest_person.di[spellId];
         if(not spell) then
            spell=yacl_spell.new();
            dest_person.di[spellId]=spell;
            _DB.m_structure_update=true;
         end
         yacl_spell.add(spell,amount,effective,resisted,blocked,critical,glancing,crushing);
         dest_person.di_changed=true;
         
         -- update the damage taken sums
         local info=dest_person.i[1];
         info.T=info.T+amount;
         dest_person.i_changed=true;
         
      end
      -- ***********************************************************
      _DB.value_update=true;
   end
end

-- *************************************************************************
-- fill the database healing numbers
-- *************************************************************************

function yacl:AddCombatHeal(source_person,dest_person,spellId,amount,overhealing,critical)
   amount =_TONUMBER(amount);
   spellId=_TONUMBER(spellId);
   if(amount>0) then
      if(source_person) then
         self:RefreshCombatTime(source_person,spellId);
         local effective     =amount-overhealing;
         local spell=source_person.h[spellId];
         if(not spell) then
            spell=yacl_spell.new();
            source_person.h[spellId]=spell;
            _DB.m_structure_update=true;
         end
         yacl_spell.add(spell,amount,effective,nil,nil,critical);
         source_person.h_changed=true;
         
         -- update the healing done sums
         local info=source_person.i[1];
         info.H=info.H+effective;
         source_person.i_changed=true;
         
         if(dest_person) then
            spell=dest_person.hi[spellId];
            if(not spell) then
               spell=yacl_spell.new();
               dest_person.hi[spellId]=spell;
               _DB.m_structure_update=true;
            end
            yacl_spell.add(spell,amount,effective,nil,nil,critical);
            dest_person.hi_changed=true;
            
            -- update the healing done sums
            local info=dest_person.i[1];
            info.I=info.I+effective;
            dest_person.i_changed=true;
         end
         
         _DB.value_update=true;
      end
   end
end


