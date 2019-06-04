local max_cols=11; -- we support max 10 columns

local _FLOOR   =math.floor;

local round = function(value)
   return _FLOOR(value+0.5);
end


grid={
   
   -- *****************************************************************
   
   new = function (title)
      local THIS={
         
         m_title=title;
         
         m_grid_widget=nil;
         
         m_click_callback=nil;
         
         m_update=nil;
         m_update_time=0;
         
         m_height    =0;
         m_row_height=16;
         
         m_row_offset =0;
         m_col_offset =0;
         
         m_active_col=2;
         m_active_row=2;
         
         m_H_SLIDER=nil;
         m_V_SLIDER=nil;
         
         m_ignore_slider=false;
         
         m_cols       ={}; -- column definitions
         
         m_sum        ={}; -- for storing the sum per column in percentage mode
         m_sort       ={}; -- sorting translation for rows based on sorting column
         
         m_data_rows  ={};
         m_data_extra ={}; -- contains data for tooltip
         
         m_icons      ={};
         m_widget_rows={};
      };
      return THIS;
   end;
   
   -- *****************************************************************
   
   on_load = function (THIS,grid_frame)
      THIS.m_grid_widget=grid_frame;
   end;
   
   -- *****************************************************************
   
   h_scroll= function(THIS,delta)
      local anz_cols=#THIS.m_cols;
      if(anz_cols>1) then
         -- yacl:debug("HSCROLL"..delta);
         THIS.m_active_col=round(THIS.m_active_col+delta);
         if(THIS.m_active_col<1       ) then THIS.m_active_col=1;        end
         if(THIS.m_active_col>anz_cols) then THIS.m_active_col=anz_cols; end
         grid.on_show(THIS);
      end
   end;
   
   h_scroll_set= function(THIS,abs)
      if(not THIS.m_ignore_slider) then
         local anz_cols=#THIS.m_cols;
         if(anz_cols>1) then
            -- yacl:debug("HSCROLL SET " .. abs);
            THIS.m_active_col=round(abs);
            if(THIS.m_active_col<1       ) then THIS.m_active_col=1;        end
            if(THIS.m_active_col>anz_cols) then THIS.m_active_col=anz_cols; end
            grid.on_show(THIS);
         end
      end
   end;
   
   -- *****************************************************************
   
   v_scroll= function(THIS,delta)
      THIS.m_active_row=round(THIS.m_active_row+delta);
      local anz_rows=#THIS.m_data_rows+1;
      if(THIS.m_active_row<2       ) then THIS.m_active_row=2;        end
      if(THIS.m_active_row>anz_rows) then THIS.m_active_row=anz_rows; end
      grid.on_show(THIS);
   end;
   
   v_scroll_set= function(THIS,abs)
      if(not THIS.m_ignore_slider) then
         THIS.m_active_row=round(abs);
         local anz_rows=#THIS.m_data_rows+1;
         if(THIS.m_active_row<2       ) then THIS.m_active_row=2;        end
         if(THIS.m_active_row>anz_rows) then THIS.m_active_row=anz_rows; end
         grid.on_show(THIS);
      end
   end;
   
   -- *****************************************************************
   
   on_mouse_down=function(THIS)
      local callback=THIS.m_click_callback;
      if(callback) then
         callback(THIS);
      end
   end;
   
   on_mouse_up=function(THIS)
   end;
   
   -- *****************************************************************
   
   on_click = function (widget,event)
      local THIS=widget.m_grid;
      if(THIS) then
         local row_index=widget.m_row;
         if(row_index>0) then
            row_index=THIS.m_sort[row_index+THIS.m_row_offset];
            local callback=THIS.m_click_callback;
            if(callback) then
               --local text=format("Click at %d . %d (%d)",widget.m_col,widget.m_row,row_index);
               --yacl:debug(text .. THIS.m_data_rows[row_index][1]);
               callback(THIS,widget.m_col,row_index,event);
            else
               -- local text=format("Click at %d . %d (%s)",widget.m_col,widget.m_row,event or "nil");
               -- yacl:debug(text);
            end
         else
            -- clicked in the title row -> change sort col
            THIS.m_active_col=widget.m_col;
            grid.on_show(THIS);
            
            if ChatFrame1EditBox:IsVisible() then
               local chat_type = ChatFrame1EditBox:GetAttribute("chatType");
               local channel   = nil;
               if chat_type=="WHISPER" then
                  channel = ChatFrame1EditBox:GetAttribute("tellTarget");
                  yacl:message_box("Report to " .. channel .. " ?",grid.OnSpam,THIS,chat_type,channel);
                  --yacl:debug("Whisper to " .. channel);
                  elseif chat_type=="CHANNEL" then
                  channel = ChatFrame1EditBox:GetAttribute("channelTarget");
                  --yacl:debug("report in channel " .. channel);
                  yacl:message_box("Report in channel " .. channel .. " ?",grid.OnSpam,THIS,chat_type,channel);
               else
                  --yacl:debug("report in chattype " .. chat_type);
                  yacl:message_box("Report in " .. chat_type .. " ?",grid.OnSpam,THIS,chat_type,channel);
               end
            end
         end
      end
   end;
   
   -- *****************************************************************
   --
   -- *****************************************************************
   
   on_enter= function(widget)
      local THIS=widget.m_grid;
      if(THIS) then
         local row_index=widget.m_row;
         local col_index=widget.m_col;
         if(row_index>0 and col_index>0 ) then
            local sorted_index=THIS.m_sort[row_index+THIS.m_row_offset];
            local data_extra=THIS.m_data_extra[sorted_index];
            if(data_extra) then
               local data=data_extra[col_index];
               if(data) then
                  GameTooltip:SetOwner(widget, "ANCHOR_LEFT");
                  GameTooltip:SetText(data);
               end
            end
         end
      end
   end;
   
   -- *****************************************************************
   --
   -- *****************************************************************
   
   on_leave= function(widget)
      if(GameTooltip:GetOwner()==widget) then
         GameTooltip:Hide();
      end
   end;
   
   -- *****************************************************************
   --
   -- *****************************************************************
   
   OnSpam= function(THIS,chat_type,channel)
      local widget_rows=THIS.m_widget_rows;
      local cols       =THIS.m_cols;
      local col_index  =THIS.m_active_col;
      local anz_visible_rows=THIS.m_anz_visible_rows-1; -- without title row
      if(anz_visible_rows>10) then anz_visible_rows=10; end
      
      local language=GetDefaultLanguage("player");
      SendChatMessage("NORMAL","yacl",format("%s (%s)",THIS.m_title,cols[col_index].n or "???"),chat_type,language,channel);
      
      --local sum_text=format("YACL reports %s : %s",THIS.m_title,cols[col_index].n or "???");
      --local sum_count=1;
      
      for row_index = 1,anz_visible_rows do
         local widget_row =widget_rows[row_index+1];
         local t1=widget_row[        1].m_text;
         local tn=widget_row[col_index].m_text;
         
         SendChatMessage("NORMAL","yacl",format("%4d : %8s  %s",row_index,tn:GetText(),t1:GetText()),chat_type,language,channel);
         
         --local text= format("%c%4d : %8s  %s",13,row_index,tn:GetText(),t1:GetText());
         --sum_text=sum_text..text;
         --sum_count=sum_count+1;
         --if(sum_count>=5) then
         --  SendChatMessage(sum_text,chat_type,language,channel);
         --   sum_text="";
         --   sum_count=0;
         --end
      end
      
      --if(sum_count>0) then
      --   SendChatMessage(sum_text,chat_type,language,channel);
      --end
      
   end;
   
   -- *****************************************************************
   -- initialize dimensions and set up display areas inside the grid.
   -- call this function after resizing or scrolling
   -- *****************************************************************
   
   on_show= function (THIS)
      if(THIS.m_grid_widget) then
         -- *****************************************************************
         -- check dimensions
         -- *****************************************************************
         THIS.m_height          =THIS.m_grid_widget:GetHeight();
         THIS.m_width           =THIS.m_grid_widget:GetWidth();
         
         THIS.m_anz_visible_rows=_FLOOR(THIS.m_height/THIS.m_row_height);
         local anz_data_rows=#THIS.m_data_rows+1;
         if(THIS.m_anz_visible_rows+THIS.m_row_offset>anz_data_rows) then
            THIS.m_anz_visible_rows=anz_data_rows-THIS.m_row_offset;
         end
         
         -- *****************************************************************
         -- enlarge widget array if neccessary
         -- *****************************************************************
         local cols    =THIS.m_cols;
         local anz_cols=#cols;
         if(anz_cols>1) then
            if(THIS.m_active_col<1       ) then THIS.m_active_col=1; end
            if(THIS.m_active_col>anz_cols) then THIS.m_active_col=anz_cols; end
            
            if(THIS.m_active_row<2       ) then THIS.m_active_row=2;        end
            if(THIS.m_active_row>anz_data_rows) then THIS.m_active_row=anz_data_rows; end
            
            if(THIS.m_active_row-THIS.m_row_offset>THIS.m_anz_visible_rows) then
               THIS.m_row_offset=THIS.m_active_row-THIS.m_anz_visible_rows;
            end
            
            if((THIS.m_active_row-2)<THIS.m_row_offset) then
               THIS.m_row_offset=(THIS.m_active_row-2);
            end
            
            if(THIS.m_row_offset<0) then
               THIS.m_row_offset=0;
            end
            
            if(THIS.m_grid_widget:IsVisible()) then
               -- the sliders are usually not a child of the grid, so special care here sbout show/hide
               THIS.m_ignore_slider=true;
               if(anz_data_rows>2) then
                  THIS.m_V_SLIDER:SetMinMaxValues(2,anz_data_rows);
                  THIS.m_V_SLIDER:SetValue(THIS.m_active_row);
                  THIS.m_V_SLIDER:Show();
               else
                  THIS.m_V_SLIDER:Hide();
               end
               
               if(anz_cols>1) then
                  THIS.m_H_SLIDER:SetMinMaxValues(1,anz_cols);
                  THIS.m_H_SLIDER:SetValue(THIS.m_active_col);
                  THIS.m_H_SLIDER:Show();
               else
                  THIS.m_H_SLIDER:Hide();
               end
               THIS.m_ignore_slider=false;
            end
            
            -- local text=format("row=%d visible_rows=%d offset=%d",THIS.m_active_row,THIS.m_anz_visible_rows,THIS.m_row_offset);
            -- yacl:debug(text);
            
         end
         local max_rows=#THIS.m_widget_rows;
         if(THIS.m_anz_visible_rows>max_rows) then
            -- only enlarge. we never create garbage here
            local h=THIS.m_row_height;
            for row_index = max_rows+1,THIS.m_anz_visible_rows do
               local row={};
               for col_index = 0,max_cols do
                  local widget =CreateFrame("Frame",nil,THIS.m_grid_widget);
                  widget:SetHeight(h);
                  local tx=widget:CreateTexture(nil,"BACKGROUND");
                  widget.m_texture=tx;
                  if((col_index==0) and (row_index>1)) then
                     tx:SetPoint("TOPRIGHT"  ,widget,0,0);
                     tx:SetPoint("BOTTOMLEFT",widget,"BOTTOMRIGHT",-h,0);
                  else
                     tx:SetAllPoints(widget);
                  end
                  
                  local t=widget:CreateFontString(nil,nil,"GameFontNormal");
                  widget.m_text=t;
                  t:SetAllPoints(widget);
                  
                  if(row_index==1) then
                     t:SetTextColor(1,1,0);
                     t:SetJustifyH("CENTER");
                  else
                     if(col_index>1) then
                        t:SetJustifyH("RIGHT");
                     else
                        t:SetJustifyH("LEFT");
                     end
                     t:SetTextColor(1,1,1);
                     if(col_index>0) then
                        tx:SetColorTexture(1,1,0,0.1);
                     end
                  end
                  widget:EnableMouse(true);
                  widget:SetScript("OnMouseDown",grid.on_click);
                  widget:SetScript("OnEnter"    ,grid.on_enter);
                  widget:SetScript("OnLeave"    ,grid.on_leave);
                  row[col_index]=widget;
               end
               THIS.m_widget_rows[row_index]=row;
            end
         end
         
         grid.setup_positions(THIS);
         
         grid.on_update(THIS,true);
      end
   end;
   
   -- *****************************************************************
   -- setup widget positions, and determine which ones are visible
   -- *****************************************************************
   
   setup_positions = function(THIS)
      local max_rows=#THIS.m_widget_rows;
      local cols    =THIS.m_cols;
      local anz_cols=#cols;
      local y=0;
      local highlight_row=THIS.m_active_row-THIS.m_row_offset;
      for row_index = 1,max_rows do
         local widget_row=THIS.m_widget_rows[row_index];
         if(row_index<=THIS.m_anz_visible_rows) then
            local x=0;
            for col_index=0,max_cols do
               local widget=widget_row[col_index];
               if( (col_index<THIS.m_col_offset) or(col_index>anz_cols) ) then
                  widget:Hide();
               else
                  local width;
                  if(col_index==0) then
                     width=40;
                  else
                     width = cols[col_index].w;
                  end
                  local rest_width = THIS.m_width-x;
                  if(width> rest_width) then width=rest_width; end
                  if( (row_index<=THIS.m_anz_visible_rows) and (width>20) ) then
                     widget:SetPoint("TOPLEFT",THIS.m_grid_widget,"TOPLEFT",x,y);
                     widget:SetWidth(width);
                     
                     widget.m_row=row_index-1;
                     widget.m_col=col_index;
                     widget.m_grid=THIS;
                     
                     if(row_index==1) then
                        -- title area
                        if(THIS.m_active_col==col_index) then
                           widget.m_texture:SetColorTexture(1,1,0,0.4);
                        else
                           widget.m_texture:SetColorTexture(1,1,0,0.2);
                        end
                     else
                        
                        if(col_index>0) then
                           if((THIS.m_active_col==col_index) or
                              (highlight_row==row_index) ) then
                              widget.m_texture:Show();
                           else
                              widget.m_texture:Hide();
                           end
                        end
                        
                        -- data area
                        --if(THIS.m_row_index==row_index) then
                        --   if(THIS.m_col_index==col_index) then
                        --      widget.m_texture:SetColorTexture(0,1,0,0.3);
                        --   else
                        --      widget.m_texture:SetColorTexture(0,1,0,0.1);
                        --   end
                        --else
                        --   widget.m_texture:SetColorTexture(0,0,0,0);
                        --end
                     end
                     
                     widget:Show();
                  else
                     widget:Hide();
                  end
                  x=x+width;
               end
            end
         else
            for col_index=0,max_cols do
               widget_row[col_index]:Hide();
            end
         end
         y=y-THIS.m_row_height;
      end
   end;
   
   -- *****************************************************************
   
   on_update = function (THIS,force)
      if(THIS.m_grid_widget and THIS.m_grid_widget:IsVisible()) then
         if(THIS.m_update or force) then
            -- data has changed, update requested
            local t=GetTime();
            if( force or (t-THIS.m_update_time)>1) then
               -- updating the grid is limited to once per second
               -- if(force) then  yacl:debug("Grid is updating (forced)");
               -- else            yacl:debug("Grid is updating"); end
               THIS.m_update_time=t;
               THIS.m_update=nil;
               
               local widget_rows=THIS.m_widget_rows;
               local data_rows  =THIS.m_data_rows;
               local cols       =THIS.m_cols;
               local anz_cols   =#cols;
               local anz_rows   =#data_rows;
               local anz_visible_rows=THIS.m_anz_visible_rows-1; -- without title row
               local sorting_col=THIS.m_active_col;
               
               -- do the sorting of the rows by preparing sort table
               local sort ={};
               for i=1,anz_rows do sort[i]=i; end
               if( (sorting_col>0) and (anz_rows>1) ) then
                  if(cols[sorting_col].sd) then
                     table.sort(sort,
                     function(a,b)
                        local v1=data_rows[a][sorting_col];
                        local v2=data_rows[b][sorting_col];
                        return (v1 or 0) > (v2 or 0);
                     end );
                  else
                     table.sort(sort,
                     function(a,b)
                        local v1=data_rows[a][sorting_col];
                        local v2=data_rows[b][sorting_col];
                        return (v1 or 0) < (v2 or 0);
                     end );
                  end
               end
               THIS.m_sort    =sort;
               
               -- set title row text
               local title_widgets=widget_rows[1];
               if(title_widgets) then
                  title_widgets[0].m_text:SetText("#");
                  for col_index=1,anz_cols do
                     local t=title_widgets[col_index].m_text;
                     local col=cols[col_index];
                     t:SetText(col.n);
                     col.max_text_width=t:GetStringWidth();
                  end
               end
               
               if(yacl_global_settings.m_percentage_mode) then
                  -- pass 1, get max value per column
                  local sum=THIS.m_sum;
                  for col_index=1,anz_cols do
                     local s=0;
                     local col=cols[col_index];
                     if(not col.type) then
                        for row_index = 1,anz_rows do
                           local data_row=data_rows[row_index];
                           if(not data_row.do_not_sum) then
                              local value=data_row[col_index];
                              if(type(value)=="number") then
                                 s = s + value;
                              end
                           end
                        end
                     end
                     sum[col_index]=s;
                  end
                  -- pass 2, scale values to percent
                  for row_index = 1,anz_visible_rows do
                     local sorted_index=sort[row_index+THIS.m_row_offset];
                     local data_row   =data_rows[sorted_index];
                     local widget_row =widget_rows[row_index+1];
                     widget_row[0].m_text:SetText(row_index+THIS.m_row_offset);
                     local icon=THIS.m_icons[sorted_index];
                     if(icon) then
                        widget_row[0].m_texture:SetTexture(icon);
                        widget_row[0].m_texture:Show();
                     else
                        widget_row[0].m_texture:Hide();
                     end
                     local color=data_row.color;
                     for col_index=1,anz_cols do
                        local col=cols[col_index];
                        local value=data_row[col_index];
                        local t    =widget_row[col_index].m_text;
                        if(type(value)=="number") then
                           local coltype=col.type;
                           if(coltype) then
                              if(coltype=="perc") then
                                 if(value>0) then
                                    t:SetFormattedText("%5.1f%%",value);
                                 else
                                    t:SetText("-");
                                 end
                                 elseif(coltype=="time") then
                                 local h=_FLOOR(value/3600); value=value-3600*h;
                                 local m=_FLOOR(value/60  ); value=value-60*m;
                                 local s=_FLOOR(value);
                                 if(h>0) then
                                    t:SetFormattedText("%d:%02d:%02d",h,m,s);
                                 else
                                    t:SetFormattedText("%d:%02d",m,s);
                                 end
                              else
                                 t:SetText(value);
                              end
                           else
                              local summe=sum[col_index];
                              if(summe>0) then
                                 t:SetFormattedText("%5.1f%%",value*100/summe);
                              else
                                 t:SetText("-");
                              end
                           end
                        else
                           t:SetText(value);
                        end
                        if(color) then
                           t:SetTextColor(color.r,color.g,color.b);
                        else
                           t:SetTextColor(1,1,1);
                        end
                        
                        local w=t:GetStringWidth();
                        if(w>col.max_text_width) then
                           col.max_text_width=w;
                        end
                        
                     end
                  end
               else
                  -- absolute mode
                  for row_index = 1,anz_visible_rows do
                     local sorted_index=sort[row_index+THIS.m_row_offset];
                     local data_row   =data_rows[sorted_index];
                     local widget_row =widget_rows[row_index+1];
                     widget_row[0].m_text:SetText(row_index+THIS.m_row_offset);
                     
                     local icon=THIS.m_icons[sorted_index];
                     if(icon) then
                        widget_row[0].m_texture:SetTexture(icon);
                        widget_row[0].m_texture:Show();
                     else
                        widget_row[0].m_texture:Hide();
                     end
                     
                     local color=data_row.color;
                     for col_index=1,anz_cols do
                        local col=cols[col_index];
                        local value=data_row[col_index];
                        local t=widget_row[col_index].m_text;
                        if(type(value)=="number") then
                           local coltype=col.type;
                           if(coltype=="perc") then
                              if(value>0) then
                                 t:SetFormattedText("%5.1f%%",value);
                              else
                                 t:SetText("-");
                              end
                              elseif(coltype=="time") then
                              local h=_FLOOR(value/3600); value=value-3600*h;
                              local m=_FLOOR(value/60  ); value=value-60*m;
                              local s=_FLOOR(value);
                              if(h>0) then
                                 t:SetFormattedText("%d:%02d:%02d",h,m,s);
                              else
                                 t:SetFormattedText("%d:%02d",m,s);
                              end
                           else
                              t:SetText(value);
                           end
                        else
                           t:SetText(value);
                        end
                        if(color) then
                           t:SetTextColor(color.r,color.g,color.b);
                        else
                           t:SetTextColor(1,1,1);
                        end
                        local w=t:GetStringWidth();
                        if(w>col.max_text_width) then
                           col.max_text_width=w;
                        end
                     end
                  end
               end
               
               local change_size=false;
               local sum_width=40;
               for col_index=1,anz_cols do
                  local col=cols[col_index];
                  local w=col.max_text_width+10;
                  if(w>col.w) then
                     col.w=w;
                     change_size=true;
                  end
                  if(w<col.w) then
                     col.w=w;
                     change_size=true;
                  end
                  sum_width=sum_width+col.w;
               end
               
               local delta=THIS.m_width-sum_width;
               if(delta>0) then
                  local col=cols[1];
                  if(col) then
                     col.w = col.w + delta;
                     change_size=true;
                  end
               end
               
               if(change_size) then
                  grid.setup_positions(THIS);
               end
               
            end
         end
      end
   end;
   
}; -- end of class grid
