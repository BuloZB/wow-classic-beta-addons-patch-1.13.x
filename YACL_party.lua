
function yacl:on_party_change()
   self.update_party_flag=true;
end

function yacl:update_zone()
   local zone = GetRealZoneText();
   if zone and zone ~= "" then
      self.update_zone_flag=nil;
      local db    = yacl_database;
      if(db.m_last_zone~=zone) then
         local inInstance, instanceType = IsInInstance();
         local ghost = UnitIsGhost("player");
         if(inInstance) then
            ----------------------------------------------
            -- zoning from outside into the instance
            ----------------------------------------------
            --if(ghost) then
            --   yacl:debug("Entering Instance " .. zone .. " as ghost");
            --else
            --   if(yacl_database.m_last_ghost) then
            --       yacl:debug("Entering Instance " .. zone .. " to get body");
            --   else
            --       yacl:debug("Entering Instance " .. zone .. " ,reset combatlog ?");
            --   end
            --end
            if( (zone~=db.m_last_instance) or ( instanceType=="arena")) then
               db.m_last_instance=zone;
               local has_combatlog=false;
               for guid,person in pairs(db.players) do
                  if(person.i[1].t>0) then
                     has_combatlog=true;
                     break;
                  end
               end
               
               if(has_combatlog) then
                  if(yacl_global_settings.m_auto_reset) then
                     self:debug("Auto resetting combat log (entering instance)");
                     self:on_reset_combatlog_confirmed();
                  else
                     self:on_reset_combatlog();
                  end
               end
            end
         else
            ----------------------------------------------
            -- zoning from the instance into the outside
            ----------------------------------------------
            
            --if(ghost) then
            --   yacl:debug("Entering Zone " .. zone .. " as ghost");
            --else
            --   yacl:debug("Entering Zone " .. zone);
            --end
         end
         
         db.m_last_zone      =zone;
         db.m_last_ghost     =ghost;
         db.m_last_inInstance=inInstance;
         
      end
   end
end


function yacl:update_party()
   self.update_party_flag=nil;
   
   
   local party_type=0;
   local num_raidmembers =0;
   local num_partymembers=GetNumGroupMembers();
   
   if(num_raidmembers>0) then
      party_type=2;
   else
      if(num_partymembers>0) then
         party_type=1;
      end
   end
   
   if(party_type~=yacl_global_settings.m_party_type) then
      if( (yacl_global_settings.m_party_type==0) and
         (yacl_global_settings.m_auto_reset))  then
         self:debug("Auto resetting combat log");
         self.temp={};
         yacl_database.players={};
         yacl_database.fight_start={};
         yacl_database.m_structure_update=true;
      end
      yacl_global_settings.m_party_type=party_type;
   end
   
   -- self:debug("Update Party");
   
   self.player_guid=UnitGUID("player");
   self.pet_guid   =UnitGUID("pet");
   self.player_name=UnitName("player");
   self.pet_name   =UnitName("pet");
   
   self.addon_channel=nil;
   
   for key,person in pairs(yacl_database.players) do
      person.in_group=nil;
   end
   
   
   local new_party_members=nil;
   if(num_raidmembers>0) then
      
      local inInstance, instanceType = IsInInstance();
      if(instanceType=="pvp") then
         self.addon_channel="BATTLEGROUND";
      else
         self.addon_channel="RAID";
      end
      
      for i=1,num_raidmembers do
         if(self:update_party_member("raid"..i)) then
            new_party_members=true;
         end
      end
   else
      self.addon_channel="PARTY";
      self:update_party_member("player");
      for i=1,4 do
         if(self:update_party_member("party"..i)) then
            new_party_members=true;
         end
      end
   end
   
   
   -- change my own color in the grid
   local combat_player=yacl_database.players[self.player_guid];
   if(combat_player) then
      combat_player.color={ r=0; g=1; b=0; };
   end
   
   local combat_pet=yacl_database.players[self.pet_guid];
   if(combat_pet) then
      combat_pet.color={ r=0.7; g=1; b=0.7; };
   end
   
end

function yacl:update_party_member(unitID)
   local player_is_new=nil;
   local player_guid=UnitGUID(unitID);
   if(player_guid) then
      
      local combat_player=yacl_database.players[player_guid];
      if(not combat_player) then
         combat_player=self:NewPerson();
         combat_player.guid =player_guid;
         yacl_database.players[player_guid]=combat_player;
         yacl_database.m_structure_update=true;
         player_is_new       =true;
      end
      
      local temp_player=self.temp[player_guid];
      if(not temp_player) then
         self.temp[player_guid]=yacl_copy_table(combat_player);
      end
      
      combat_player.id   =unitID;   -- can change from party to raid id
      combat_player.in_group=true;
      
      local player_name=UnitName(unitID);
      if(player_name~=combat_player.name) then
         combat_player.name=player_name;
         yacl_database.m_structure_update=true;
      end
      
      local unit_lclass,unit_class=UnitClass(unitID);
      if(unit_class~=combat_player.class) then
         combat_player.class=unit_class;
         yacl_database.m_structure_update=true;
         -- self:debug("Class = " .. unit_class);
      end
      
      if(self:update_party_pet(combat_player,unitID.."pet")) then
         player_is_new=true;
      end
      
   end
   return player_is_new;
end

function yacl:update_party_pet(combat_player,unitID)
   local pet_is_new=nil;
   local pet_guid=UnitGUID(unitID);
   if(pet_guid) then
      
      local combat_pet=nil;
      local old_guid  =combat_player.pet_guid;
      
      if( old_guid and pet_guid~=old_guid) then
         combat_pet=yacl_database.players[old_guid];
         if(combat_pet) then
            -- recycle the old pet, just assign the new guid
            yacl_database.players[old_guid]=nil;
            self.temp[old_guid]=nil;
            combat_pet.guid=pet_guid;
            yacl_database.players[pet_guid]=combat_pet;
            yacl_database.m_structure_update=true;
         end
      else
         combat_pet=yacl_database.players[pet_guid];
      end
      
      if(not combat_pet) then
         combat_pet=self:NewPerson();
         combat_pet.guid =pet_guid;
         combat_pet.color={ r=0.5; g=0.5; b=0.5; };
         yacl_database.players[pet_guid]=combat_pet;
         yacl_database.m_structure_update=true;
         pet_is_new       =true;
      end
      
      local temp_pet=self.temp[pet_guid];
      if(not temp_pet) then
         self.temp[pet_guid]=yacl_copy_table(combat_pet);
      end
      
      combat_pet.id      =unitID;   -- can change from party to raid id
      combat_pet.in_group=true;
      
      local pet_name=UnitName(unitID);
      if(pet_name~=combat_pet.name) then
         combat_pet.name=pet_name;
         yacl_database.m_structure_update=true;
      end
      
      local unit_lclass,unit_class=UnitClass(unitID);
      if(unit_class~=combat_pet.class) then
         combat_pet.class=unit_class;
         yacl_database.m_structure_update=true;
      end
      
      local creatureFamily = UnitCreatureFamily(unitID) or pet_name;
      if(creatureFamily~=combat_pet.creatureFamily) then
         combat_pet.creatureFamily=creatureFamily;
         yacl_database.m_structure_update=true;
         -- yacl:debug("Creature Family = " .. creatureFamily);
      end
      
      combat_player.pet_guid=pet_guid;
      combat_pet.owner_guid =combat_player.guid;
   end
   return pet_is_new;
end




