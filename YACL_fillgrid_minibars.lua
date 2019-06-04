-- ************************************************************
--
-- ************************************************************

function yacl:on_update_mini_view(force)
   local t=GetTime();
   if( force or (t-self.m_update_time)>1) then
      self.m_update_time=t;
      
      local db=yacl_database;
      
      local func=self.GetAbsolute;
      local var_name1="S";
      local var_name2=nil;
      local format_string="%d";
      
      if(yacl_global_settings.m_bars_type==1) then
         if(yacl_global_settings.m_show_damage) then
            if(yacl_global_settings.m_show_incoming) then
               var_name1="T"
            end
         else
            if(not yacl_global_settings.m_show_incoming) then
               var_name1="H"
            else
               var_name1="I"
            end
         end
      else
         if(yacl_global_settings.m_bars_type==2) then
            func=self.GetPerSecond;
            format_string="%.1f";
            elseif(yacl_global_settings.m_bars_type==3) then
            func=self.GetPerSecond;
            var_name1="H";
            format_string="%.1f";
            elseif(yacl_global_settings.m_bars_type==4) then
            var_name2="H";
         end
      end
      
      local sort={};
      local sum_value=0;
      for guid,person in pairs(db.players) do
         local value=func(self,guid,var_name1,var_name2);
         person.value=value;
         if(value>0) then
            table.insert(sort,person);
            if(not person.owner_guid) then
               sum_value=sum_value+value;
            end
         end
      end
      table.sort(sort, function(p1,p2) return p1.value > p2.value; end );
      
      local n=#sort;
      if(n>yacl_global_settings.m_anz_bars) then n=yacl_global_settings.m_anz_bars; end
      
      local ref;
      for line=1,20 do
         local slider=self.m_slider[line];
         if(line>n) then
            slider:Hide();
         else
            local person=sort[line];
            local value=person.value;
            local h=slider:GetHeight();
            local h2=h/2;
            local w=slider:GetWidth();
            
            slider.t :SetFormattedText("%2d. %s",line,person.name);
            if(yacl_global_settings.m_percentage_mode) then
               slider.tr:SetFormattedText("%.1f%%",value*100/sum_value);
            else
               slider.tr:SetFormattedText(format_string,value);
            end
            local color=person.color;
            if(color) then
               slider.tx_l:SetVertexColor(color.r,color.g,color.b,0.5);
               slider.tx_m:SetVertexColor(color.r,color.g,color.b,0.5);
               slider.tx_r:SetVertexColor(color.r,color.g,color.b,0.5);
            else
               slider.tx_l:SetVertexColor(1,1,1,0.5);
               slider.tx_m:SetVertexColor(1,1,1,0.5);
               slider.tx_r:SetVertexColor(1,1,1,0.5);
            end
            
            if(line==1) then
               ref=value;
               slider.tx_l:SetWidth(h2);
               slider.tx_m:SetWidth(w-h);
               slider.tx_r:SetWidth(h2);
            else
               local wl=w*value/ref;
               if(wl>h) then
                  slider.tx_l:SetWidth(h2);
                  slider.tx_m:SetWidth(wl-h);
                  slider.tx_r:SetWidth(h2);
               else
                  slider.tx_l:SetWidth(wl/2);
                  slider.tx_m:SetWidth(0.01);
                  slider.tx_r:SetWidth(wl/2);
               end
            end
            
            slider:Show();
         end
      end
   end
end
