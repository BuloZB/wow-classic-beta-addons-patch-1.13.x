local _FLOOR   =math.floor;

-- ************************************************************
-- transform the internal data into visible grid format
-- ************************************************************

function yacl:on_update()
   if(self.update_zone_flag) then
      self:update_zone();
   end
   if(self.update_party_flag) then
      self:update_party();
   end
   self:check_combat_timeouts();
end

-- ************************************************************
--
-- ************************************************************

function yacl_switch_to_detail_view(grid,col_index,row_index,event)
   if(event=="RightButton") then
      yacl:set_minimized_mode(true);
   else
      for guid,person in pairs(yacl_database.players) do
         if(person.row==row_index) then
            yacl.detail_guid=guid;
            yacl:on_update_detailed_view(true);
            yacl:setup_title();
         end
      end
   end
end

function yacl_switch_to_global_view(grid,col_index,row_index,event)
   if(event=="RightButton") then
      yacl:set_minimized_mode(true);
   else
      if(yacl.detail_guid) then
         yacl.detail_guid=nil;
         yacl:on_update_global_view(true);
         yacl:setup_title();
      end
   end
end

-- ************************************************************
--
-- ************************************************************

function yacl:on_update_view(force)
   if(self.m_grid.m_grid_widget and self.m_vars_loaded) then
      if(self.m_grid.m_grid_widget:IsVisible()) then
         if(self.detail_guid) then
            self:on_update_detailed_view(force);
         else
            self:on_update_global_view(force);
         end
      else
         self:on_update_mini_title(force);
         self:on_update_mini_view(force);
      end
   end
end

-- ************************************************************
--
-- ************************************************************

function yacl:update_mini_title1()
   return "YACL";
end

function yacl:update_mini_title_clock()
   local hour,minute = GetGameTime();
   return format("%2d:%02d",hour,minute);
end

function yacl:update_mini_title_fight()
   local start=yacl_database.fight_start_time;
   if(start) then
      local value;
      if(self.m_group_in_combat) then
         value=GetTime()-start;
      else
         value=yacl_database.fight_duration;
      end
      if(value) then
         local h=_FLOOR(value/3600); value=value-3600*h;
         local m=_FLOOR(value/60  ); value=value-60*m;
         local s=_FLOOR(value);
         if(h>0) then
            return format("%d:%02d:%02d",h,m,s);
         else
            return format("%d:%02d",m,s);
         end
      else
         return "-:-";
      end
   else
      return "-:-";
   end
end

function yacl:update_mini_title_dps()
   local value=self:GetPerSecond(self.player_guid,"S");
   if(value>1000000) then
      return format("%.1fM",value/1000000);
      elseif(value>1000) then
      return format("%.1fK",value/1000);
   else
      return format("%.1f",value);
   end
end

function yacl:update_mini_title_hps()
   local value=self:GetPerSecond(self.player_guid,"H");
   if(value>1000000) then
      return format("%.1fM",value/1000000);
      elseif(value>1000) then
      return format("%.1fK",value/1000);
   else
      return format("%.1f",value);
   end
end


local mini_title_functions=
{
   [1]=yacl.update_mini_title1;
   [2]=yacl.update_mini_title_clock;
   [3]=yacl.update_mini_title_fight;
   [4]=yacl.update_mini_title_dps;
   [5]=yacl.update_mini_title_hps;
}

function yacl:on_update_mini_title(force)
   local t=GetTime();
   if( force or ((t-self.m_update_title_time)>=1)) then
      self.m_update_title_time=t;
      self.m_title:SetText(mini_title_functions[yacl_global_settings.m_title_type](self))
   end
end

-- ************************************************************
--
-- ************************************************************

local yacl_spell_info=  -- update also yacl_spell_info_numbers
{
   [    0]="Melee";
   [65536]="Env. unknown";
   [65537]="Env. drowning";
   [65538]="Env. falling";
   [65539]="Env. fatigue";
   [65540]="Env. fire";
   [65541]="Env. lava";
   [65542]="Env. slime";
};

-- ************************************************************
--
-- ************************************************************

local rank_names=
{
   [ 1]=1,[ 2]= 2,[ 3]= 3,[ 4]= 4,[ 5]= 5,[ 6]= 6,[ 7]= 7,[ 8]=8,
   [ 9]=9,[10]=10,[11]=11,[12]=12,[13]=13,[14]=14,[15]=15,[16]=16,

   ["Rank 1" ]= 1,["Rank 2" ]= 2,["Rank 3" ]= 3,["Rank 4" ]= 4,["Rank 5" ]=5,
   ["Rank 6" ]= 6,["Rank 7" ]= 7,["Rank 8" ]= 8,["Rank 9" ]= 9,["Rank 11"]=10,
   ["Rank 12"]=11,["Rank 13"]=12,["Rank 14"]=13,["Rank 15"]=15,["Rank 16"]=16,

   ["Rang 1" ]= 1,["Rang 2" ]= 2,["Rang 3" ]= 3,["Rang 4" ]= 4,["Rang 5" ]=5,
   ["Rang 6" ]= 6,["Rang 7" ]= 7,["Rang 8" ]= 8,["Rang 9" ]= 9,["Rang 11"]=10,
   ["Rang 12"]=11,["Rang 13"]=12,["Rang 14"]=13,["Rang 15"]=15,["Rang 16"]=16,
};

-- ************************************************************
--
-- ************************************************************

function yacl:on_update_detailed_view(force)
   
   local t=GetTime();
   if( force or (t-self.m_update_time)>1) then
      self.m_update_time=t;
      
      local G=self.m_grid;
      local db=yacl_database;
      
      local combatant=db.players[self.detail_guid];
      if(not combatant) then
         self.detail_guid=nil;
         return;
      end
      
      local yacl_cols;
      local section_name;
      
      if(yacl_global_settings.m_show_damage) then
         if(yacl_global_settings.m_show_incoming) then
            yacl_cols=yacl_global_settings.m_cols_detail.damage_in;
            section_name="di";
         else
            yacl_cols=yacl_global_settings.m_cols_detail.damage;
            section_name="d";
         end
      else
         if(yacl_global_settings.m_show_incoming) then
            yacl_cols=yacl_global_settings.m_cols_detail.healing_in;
            section_name="hi";
         else
            yacl_cols=yacl_global_settings.m_cols_detail.healing;
            section_name="h";
         end
      end
      
      
      local anz_cols=#yacl_cols;
      local rows_updated=nil;
      local spells=combatant[section_name];
      local start_spells=nil;
      
      if(yacl_global_settings.m_show_fight) then
         -- show last fight. so we subtract the fight start from all values !
         local start_person=db.fight_start[self.detail_guid];
         if(start_person) then
            start_spells=start_person[section_name];
         end
      end
      
      if(db.m_structure_update or force) then
         db.m_structure_update=nil; --spell update, spells have changed
         
         --self:debug("Setting up rows for detailed view");
         
         local icons    ={};
         local data_rows={};
         local extra_rows={};
         local row_index=1;
         self.spell_rows={};
         for spellId,spell in pairs(spells) do
            local old_spell=nil;
            if(start_spells) then old_spell=start_spells[spellId]; end
            if(not old_spell or (old_spell.n~=spell.n) ) then
               
               local s=spell.s;
               if(old_spell) then s=s-old_spell.s; end
               
               if(s>0) then
                  -- only spells with values>0 show up !
                  self.spell_rows[spellId]=row_index;
                  local name=yacl_spell_info[spellId];
                  local rank=nil;
                  local icon=nil;
                  
                  if(name==nil) then
                     if(spellId>0) then
                        name,rank,icon=GetSpellInfo(spellId);
                     else
                        name,rank,icon=GetSpellInfo(-spellId);
                        name=name.."*";
                     end
                  end
                  
                  if(rank) then
				     rank=rank_names[rank];
                     if(rank) then
                        name=name.." "..rank;
                     end
                  end
                  
                  data_rows[row_index]={ [1]=name; color=combatant.color; };
                  extra_rows[row_index]= { };
                  icons    [row_index]=icon;
                  row_index=row_index+1;
               end
            end
         end
         
         G.m_data_rows =data_rows;
         G.m_data_extra=extra_rows;
         G.m_cols      =yacl_cols;
         G.m_icons     =icons;
         G.m_click_callback=yacl_switch_to_global_view;
         rows_updated=true;
         
      end
      
      if(db.value_update or rows_updated) then
         db.value_update=nil;
         
         -- self:debug("Setting values for detail view");
         
         local data_rows=G.m_data_rows;
         local extra_rows=G.m_data_extra;
         for spellId,spell in pairs(spells) do
            local row_index=self.spell_rows[spellId];
            if(row_index) then
               local old_spell=nil;
               if(start_spells) then old_spell=start_spells[spellId]; end
               local data_row=data_rows[row_index];
               local extra_row=extra_rows[row_index];
               if(data_row) then
                  local s=spell.s;
                  local n=spell.n;
                  if(old_spell) then
                     s=s-old_spell.s;
                     n=n-old_spell.n;
                     old_spell.a=0;  --hrhr
                  end
                  spell.a=math.floor(s/n);
                  for col_index=2,anz_cols do
                     local col=yacl_cols[col_index];
                     local value    =spell[col.ni];
                     local rel_value=spell[col.rel];
                     if(old_spell) then value    =value-old_spell[col.ni]; end
                     if( (value>0) and rel_value and (rel_value>0)) then
                        if(old_spell) then
                           local old_rel=old_spell[col.rel];
                           if(old_rel) then
                              rel_value=rel_value-old_rel;
                           end
                        end
                        extra_row[col_index]=format("%.1f of %.1f",value,rel_value);
                        value=value*100/rel_value;
                     end
                     data_row[col_index]=value;
                  end
                  spell.a=0; -- do not transmit !
               end
            end
         end
         
         --local t_end=GetTime();
         --self:debug("Updating details in " .. t_end - t);
         
         if(rows_updated) then
            grid.on_show(G);
         else
            G.m_update=true;
         end
      end
      
   end
end


