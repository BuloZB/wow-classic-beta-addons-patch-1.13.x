-- ************************************************************
-- textures used by the global view
-- ************************************************************

local yacl_class_icons=
{
   ["WARRIOR"]="Interface\\Addons\\yacl\\Textures\\class_warrior";
   ["SHAMAN" ]="Interface\\Addons\\yacl\\Textures\\class_shaman";
   ["PALADIN"]="Interface\\Addons\\yacl\\Textures\\class_paladin";
   ["ROGUE"  ]="Interface\\Addons\\yacl\\Textures\\class_rogue";
   ["DRUID"  ]="Interface\\Addons\\yacl\\Textures\\class_druid";
   ["PRIEST" ]="Interface\\Addons\\yacl\\Textures\\class_priest";
   ["WARLOCK"]="Interface\\Addons\\yacl\\Textures\\class_warlock";
   ["HUNTER" ]="Interface\\Addons\\yacl\\Textures\\class_hunter";
   ["MAGE"   ]="Interface\\Addons\\yacl\\Textures\\class_mage";
};

local PET_General          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_General";

local PET_Bat              ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Bat";
local PET_Bear             ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Bear";
local PET_Boar             ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Boar";
local PET_Cat              ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Cat";
local PET_Crab             ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Crab";
local PET_Crocolisk        ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Crocolisk";
local PET_DragonHawk       ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_DragonHawk";
local PET_Gorilla          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Gorilla";
local PET_Hyena            ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Hyena";
local PET_NetherRay        ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_NetherRay";
local PET_Owl              ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Owl";
local PET_Raptor           ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Raptor";
local PET_Ravager          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Ravager";
local PET_Scorpid          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Scorpid";
local PET_Spider           ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Spider";
local PET_Sporebat         ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Sporebat";
local PET_TallStrider      ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_TallStrider";
local PET_Turtle           ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Turtle";
local PET_Vulture          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Vulture";
local PET_WarpStalker      ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_WarpStalker";
local PET_WindSerpent      ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_WindSerpent";
local PET_Wolf             ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Wolf";
local PET_Serpent          ="Interface\\Addons\\yacl\\Textures\\Pets\\Pet_Serpent";



local PET_FelGuard          ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_FelGuard";
local PET_FelHunter         ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_FelHunter";
local PET_Imp               ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_Imp";
local PET_Infernal          ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_Infernal";
local PET_Succubus          ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_Succubus";
local PET_VoidWalker        ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_VoidWalker";
local PET_WaterElemental    ="Interface\\Addons\\yacl\\Textures\\Pets\\Summon_WaterElemental";


local yacl_pet_icons=
{
   ["Pet"]              =PET_General;
   
   -- english
   ["Bat"]              =PET_Bat;
   ["Bear"]             =PET_Bear;
   ["Boar"]             =PET_Boar;
   ["Cat"]              =PET_Cat;
   ["Crab"]             =PET_Crab;
   ["Crocolisk"]        =PET_Crocolisk;
   ["Dragonhawk"]       =PET_DragonHawk;
   ["Gorilla"]          =PET_Gorilla;
   ["Hyena"]            =PET_Hyena;
   ["Nether Ray"]       =PET_NetherRay;
   ["Owl"]              =PET_Owl;
   ["Raptor"]           =PET_Raptor;
   ["Ravager"]          =PET_Ravager;
   ["Scorpid"]          =PET_Scorpid;
   ["Spider"]           =PET_Spider;
   ["Sporebat"]         =PET_Sporebat;
   ["TallStrider"]      =PET_TallStrider;
   ["Turtle"]           =PET_Turtle;
   ["Carrion Bird"]     =PET_Vulture;
   ["Warp Stalker"]     =PET_WarpStalker;
   ["Wind Serpent"]     =PET_WindSerpent;
   ["Wolf"]             =PET_Wolf;
   ["Serpent"]          =PET_Serpent;
   
   
   -- german
   ["Fledermaus"]       =PET_Bat;
   ["B\195\164r"]       =PET_Bear;
   ["Eber"]             =PET_Boar;
   ["Katze"]            =PET_Cat;
   ["Krabbe"]           =PET_Crab;
   ["Krokodil"]         =PET_Crocolisk;
   ["Drachenfalke"]     =PET_DragonHawk;
   ["Gorilla"]          =PET_Gorilla;
   ["Hy\195\164ne"]     =PET_Hyena;
   ["Netherrochen"]     =PET_NetherRay;
   ["Eule"]             =PET_Owl;
   ["Raptor"]           =PET_Raptor;
   ["Felshetzer"]       =PET_Ravager;
   ["Skorpid"]          =PET_Scorpid;
   ["Spinne"]           =PET_Spider;
   ["Sporensegler"]     =PET_Sporebat;
   ["Ebenenschreiter"]  =PET_TallStrider;
   ["Schildkr\195\182te"]=PET_Turtle;
   ["Aasvogel"]         =PET_Vulture;
   ["Sph\195\164renj\195\164ger"]     =PET_WarpStalker;
   ["Windnatter"]       =PET_WindSerpent;
   ["Wolf"]             =PET_Wolf;
   ["Schlange"]         =PET_Serpent;
   
   -- french
   -- HELP !!!!!!!!!!!!!!!!!!!!
   
   -- spanish
   -- HELP !!!!!!!!!!!!!!!!!!!!
   
   
   -- english
   ["Felguard"]         =PET_FelGuard;
   ["Felhunter"]        =PET_FelHunter;
   ["Imp"]              =PET_Imp;
   ["Infernal"]         =PET_Infernal;
   ["Succubus"]         =PET_Succubus;
   ["Voidwalker"]       =PET_VoidWalker;
   ["Water Elemental"]  =PET_WaterElemental;
   
   -- german
   ["Teufelswache"]        =PET_FelGuard;
   ["Teufelsj\195\164ger"] =PET_FelHunter;
   ["Wichtel"]             =PET_Imp;
   ["Infernal"]            =PET_Infernal;
   ["Sukkubus"]            =PET_Succubus;
   ["Leerwandler"]         =PET_VoidWalker;
   ["Wasser Elementar"]    =PET_WaterElemental;
   
   -- french
   ["Gangregarde"]         =PET_FelGuard;
   ["Chasseur corrompu"]   =PET_FelHunter;
   ["Diablotin"]           =PET_Imp;
   ["Infernal"]            =PET_Infernal;
   ["Succube"]             =PET_Succubus;
   ["Marcheur du Vide"]    =PET_VoidWalker;
   ["WaterElemental"]      =PET_WaterElemental; -- ???
   
   -- spanish
   -- HELP !!!!!!!!!!!!!!!!!!!!!!
   
   
};

-- ************************************************************
-- collect data for global view
-- ************************************************************

function yacl:on_update_global_view(force)
   
   local t=GetTime();
   if( force or (t-self.m_update_time)>1) then
      self.m_update_time=t;
      
      local G=self.m_grid;
      local db=yacl_database;
      
      local yacl_cols;
      local spell_section;
      if(yacl_global_settings.m_show_damage) then
         if(yacl_global_settings.m_show_incoming) then
            yacl_cols=yacl_global_settings.m_cols.damage_in;
            spell_section="di";
         else
            yacl_cols=yacl_global_settings.m_cols.damage;
            spell_section="d";
         end
      else
         if(yacl_global_settings.m_show_incoming) then
            yacl_cols=yacl_global_settings.m_cols.healing_in;
            spell_section="hi";
         else
            yacl_cols=yacl_global_settings.m_cols.healing;
            spell_section="h";
         end
      end
      
      local rows_updated=nil;
      if(db.m_structure_update or force) then
         db.m_structure_update=nil;
         
         -- self:debug("Setting up rows for global view");
         
         local icons    ={};
         local data_rows={};
         local extra_rows={};
         local row_index=1;
         for guid,person in pairs(db.players) do
            person.row=row_index;
            local r={ [1]=person.name; color=person.color; };
            local extra_row={};
            if(person.owner_guid) then r.do_not_sum=true; end
            data_rows[row_index]=r;
            if(person.creatureFamily) then
               icons[row_index]=yacl_pet_icons[person.creatureFamily] or PET_General;
            else
               icons[row_index]=yacl_class_icons[person.class];
            end
            
            if(person.pet_guid) then
               local pet=db.players[person.pet_guid];
               if(pet) then
                  extra_row[1]=format("Owner of %s",pet.name);
               end
            end
            
            if(person.owner_guid) then
               local owner=db.players[person.owner_guid];
               if(owner) then
                  extra_row[1]=format("Pet of %s",owner.name);
               end
            end
            
            extra_rows[row_index]= extra_row;
            row_index=row_index+1;
         end
         
         -- self:debug("data rows=" .. #data_rows);
         -- self:debug("data cols=" .. #cols);
         
         G.m_data_rows =data_rows;
         G.m_data_extra=extra_rows;
         G.m_cols      =yacl_cols;
         G.m_icons     =icons;
         G.m_click_callback=yacl_switch_to_detail_view;
         rows_updated=true;
      end
      
      
      if(yacl_database.value_update or rows_updated) then
         yacl_database.value_update=nil;
         
         local sum_spell=yacl_spell.new();
         local anz_cols =#yacl_cols;
         
         -- self:debug("Setting values for global view");
         
         local fight_start=nil;
         if(yacl_global_settings.m_show_fight) then
            -- show last fight. so we subtract the fight start from all values !
            fight_start=yacl_database.fight_start;
         end
         
         local data_rows=G.m_data_rows;
         local extra_rows=G.m_data_extra;
         for guid,person in pairs(db.players) do
            local data_row =data_rows [person.row];
            local extra_row=extra_rows[person.row];
            if(data_row) then
               
               yacl_spell.clear(sum_spell);
               for spellId,spell in pairs(person[spell_section]) do
                  yacl_spell.add_spell(sum_spell,spell);
               end
               yacl_spell.add_spell(sum_spell,person.i[1]);
               
               --------------------------------------------------------
               local start_pet_sum=nil;
               if(fight_start) then
                  local start_person=fight_start[guid];
                  if(start_person) then
                     yacl_spell.sub_spell(sum_spell,start_person["sum_"..spell_section]);
                     local start_pet=fight_start[start_person.pet_guid];
                     if(start_pet) then
                        start_pet_sum=start_pet["sum_"..spell_section];
                     end
                  end
               end
               --------------------------------------------------------
               
               if(sum_spell.t>0) then
                  sum_spell.dps=math.ceil(sum_spell.S/sum_spell.t);
                  sum_spell.hps=math.ceil(sum_spell.H/sum_spell.t);
               else
                  sum_spell.dps=0;
                  sum_spell.hps=0;
               end
               
               if(person.pet_guid) then
                  -- add pet totals to players totals
                  local pet=db.players[person.pet_guid];
                  if(pet) then
                     
                     local col          =yacl_cols[2];
                     local player_value =sum_spell[col.ni];
                     
                     local petinfo=pet.i[1];
                     local S=petinfo.S;
                     local T=petinfo.T;
                     local H=petinfo.H;
                     local I=petinfo.I;
                     local t=petinfo.t;
                     
                     if(start_pet_sum) then
                        S=S-start_pet_sum.S;
                        T=T-start_pet_sum.T;
                        H=H-start_pet_sum.H;
                        I=I-start_pet_sum.I;
                        t=t-start_pet_sum.t;
                     end
                     
                     
                     sum_spell.S=sum_spell.S+S;
                     sum_spell.T=sum_spell.T+T;
                     sum_spell.H=sum_spell.H+H;
                     sum_spell.I=sum_spell.I+I;
                     
                     -- add pet dps
                     if(t>0) then
                        sum_spell.dps=sum_spell.dps+math.ceil(S/t);
                        sum_spell.hps=sum_spell.hps+math.ceil(H/t);
                     end
                     
                     local player_and_pet_value =sum_spell[col.ni];
                     if(player_and_pet_value>0) then
                        local pet_value     =player_and_pet_value-player_value;
                        local pet_percentage=100*pet_value/player_and_pet_value;
                        extra_row[2]=format("Pet contribution = %.2f %%",pet_percentage);
                     else
                        extra_row[2]=nil;
                     end
                  end
               end
               
               for col_index=2,anz_cols do
                  local col   =yacl_cols[col_index];
                  local value =sum_spell[col.ni];
                  local rel_value=sum_spell[col.rel];
                  if( (value>0) and rel_value and (rel_value>0) ) then
                     extra_row[col_index]=format("%.1f of %.1f",value,rel_value);
                     value=value*100/rel_value;
                  end
                  data_row[col_index]=value;
               end
            end
         end
         
         --local t_end=GetTime();
         --self:debug("Updating global in " .. t_end - t);
         
         if(rows_updated) then
            grid.on_show(G);
         else
            G.m_update=true;
         end
         
      end
      
   end
end


