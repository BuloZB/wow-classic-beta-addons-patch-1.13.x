
-- ******************************************************************
--
-- ******************************************************************

function yacl:set_texture(name,x0,y0,b,h,visible_b,visible_h)
   
   local texture=self[name];
   if(texture) then
      
      if(visible_b==nil) then visible_b=b; end
      if(visible_h==nil) then visible_h=h; end
      
      texture:SetWidth (visible_b);
      texture:SetHeight(visible_h);
      
      if(x0~=nil) then
         local x1=x0+b-1;
         local y1=y0+h-1;
         
         x0=x0/127.0;
         y0=y0/127.0;
         x1=x1/127.0;
         y1=y1/127.0;
         
         texture:SetTexCoord(x0,x1,y0,y1);
      end
      texture:Show();
   end
end

function yacl:hide_texture(name)
   local texture=self[name];
   if(texture) then
      texture:Hide();
   end
end

-- ******************************************************************
--  after resize of window:
-- ******************************************************************

function yacl:set_texture_positions(store_position)
   
   if(self.m_mainframe) then
      local parent_h=self.m_parent:GetHeight();
      local parent_w=self.m_parent:GetWidth();
      
      local m_height=self.m_mainframe:GetHeight();
      local m_width =self.m_mainframe:GetWidth ();
      local x     =-(parent_w-self.m_mainframe:GetRight());
      local y     =-(parent_h-self.m_mainframe:GetTop());
      
      local xres=128;
      local yres=128;
      
      if(m_height<40) then
         yacl_global_settings.m_minimized_mode=true;
         if(store_position) then
            --self:debug("Storing small position at " .. x .. " , " .. y);
            yacl_global_settings.m_small_x=x;
            yacl_global_settings.m_small_y=y;
         end
      else
         yacl_global_settings.m_minimized_mode=false;
         if(store_position) then
            --self:debug("Storing big position at " .. x .. " , " .. y);
            yacl_global_settings.m_big_height=m_height;
            yacl_global_settings.m_big_width =m_width;
            yacl_global_settings.m_big_x=x;
            yacl_global_settings.m_big_y=y;
         end
      end
      
      if(yacl_global_settings.m_minimized_mode) then
         
         local corner_width =32;
         local corner_height=16;
         
         local side_width         =xres -2*corner_width;
         local side_visible_width =m_width -2*corner_width;
         
         self:set_texture("YACL_TC1",0                ,                 0,corner_width,corner_height);
         self:set_texture("YACL_TC2",xres-corner_width,                 0,corner_width,corner_height);
         
         self:set_texture("YACL_TC3",0                ,yres-corner_height,corner_width,corner_height);
         self:set_texture("YACL_TC4",xres-corner_width,yres-corner_height,corner_width,corner_height);
         
         self:hide_texture("YACL_TS1");
         self:hide_texture("YACL_TS2");
         
         self:set_texture("YACL_TS3",corner_width,                 0,side_width,corner_height,side_visible_width,corner_height);
         self:set_texture("YACL_TS4",corner_width,yres-corner_height,side_width,corner_height,side_visible_width,corner_height);
         
         self:hide_texture("YACL_CENTER");
         
         self.m_sizer_button1 :Hide();
         self.m_sizer_button2 :Hide();
         self.m_grid_widget:Hide();
         
         self.H_SLIDER:Hide();
         self.V_SLIDER:Hide();
         
         -- self:debug("Setting up textures for minimized mode");
         
      else
         
         
         local corner_width =32;
         local corner_height=32;
         
         local side_width =xres -2*corner_width;
         local side_height=yres -2*corner_height;
         
         local side_visible_width =m_width -2*corner_width;
         local side_visible_height=m_height -2*corner_height;
         
         
         self:set_texture("YACL_TC1",0                ,                 0,corner_width,corner_height);
         self:set_texture("YACL_TC2",xres-corner_width,                 0,corner_width,corner_height);
         
         self:set_texture("YACL_TC3",0                ,yres-corner_height,corner_width,corner_height);
         self:set_texture("YACL_TC4",xres-corner_width,yres-corner_height,corner_width,corner_height);
         
         self:set_texture("YACL_TS1",0                ,corner_height,corner_width,side_height,corner_width,side_visible_height);
         self:set_texture("YACL_TS2",xres-corner_width,corner_height,corner_width,side_height,corner_width,side_visible_height);
         
         self:set_texture("YACL_TS3",corner_width,                 0,side_width,corner_height,side_visible_width,corner_height);
         self:set_texture("YACL_TS4",corner_width,yres-corner_height,side_width,corner_height,side_visible_width,corner_height);
         
         --self:set_texture("YACL_CENTER",33,33,16,16,side_visible_width,side_visible_height);
         self:set_texture("YACL_CENTER",nil,nil,nil,nil,side_visible_width,side_visible_height);
         
         self.m_sizer_button1 :Show();
         self.m_sizer_button2 :Show();
         self.m_grid_widget:Show();
         
         self.H_SLIDER:Show();
         self.V_SLIDER:Show();
         
         for i,slider in ipairs(self.m_slider) do
            slider:Hide();
         end
         
         -- self:debug("Setting up textures for maximized mode");
         
      end
   end
   self:SetCursorBindings();
end

function yacl:SetCursorBindings()
   if(self.m_mainframe and not InCombatLockdown() ) then
      if(yacl_global_settings.m_minimized_mode or (not yacl_global_settings.m_use_cursor_keys)) then
         ClearOverrideBindings(self.m_mainframe);
      else
         SetOverrideBinding(self.m_mainframe,1,"LEFT" ,"YACLCURSORLEFT" );
         SetOverrideBinding(self.m_mainframe,1,"RIGHT","YACLCURSORRIGHT");
         SetOverrideBinding(self.m_mainframe,1,"UP"   ,"YACLCURSORUP"   );
         SetOverrideBinding(self.m_mainframe,1,"DOWN" ,"YACLCURSORDOWN" );
      end
   end
end


function yacl:SetVertexColor(r,g,b,a)
   
   self.YACL_TC1:SetVertexColor(r,g,b,a);
   self.YACL_TC2:SetVertexColor(r,g,b,a);
   
   self.YACL_TC3:SetVertexColor(r,g,b,a);
   self.YACL_TC4:SetVertexColor(r,g,b,a);
   
   self.YACL_TS1:SetVertexColor(r,g,b,a);
   self.YACL_TS2:SetVertexColor(r,g,b,a);
   
   self.YACL_TS3:SetVertexColor(r,g,b,a);
   self.YACL_TS4:SetVertexColor(r,g,b,a);
   
   self.YACL_CENTER:SetVertexColor(r,g,b,a);
   
   self.H_SLIDER_texture:SetVertexColor(r,g,b,a);
   self.V_SLIDER_texture:SetVertexColor(r,g,b,a);
   
   if(self.m_options_texture) then
      self.m_options_texture:SetVertexColor(r,g,b,a);
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_load_mainframe(mainframe)
   
   self.m_parent   =mainframe:GetParent();
   self.m_mainframe=mainframe;
   self.m_grid_widget=getglobal("YACL_Grid");
   self.m_title    =getglobal("YACL_TITLE");
   
   self.m_option_button  =getglobal("YACL_OPTIONS_BTN");
   self.m_minimize_button=getglobal("YACL_MINIMIZE_BTN");
   self.m_sizer_button1  =getglobal("YACL_SIZER_BTN1");
   self.m_sizer_button2  =getglobal("YACL_SIZER_BTN2");
   
   self.YACL_TC1  =getglobal("YACL_TC1");
   self.YACL_TC2  =getglobal("YACL_TC2");
   self.YACL_TC3  =getglobal("YACL_TC3");
   self.YACL_TC4  =getglobal("YACL_TC4");
   
   self.YACL_TS1  =getglobal("YACL_TS1");
   self.YACL_TS2  =getglobal("YACL_TS2");
   self.YACL_TS3  =getglobal("YACL_TS3");
   self.YACL_TS4  =getglobal("YACL_TS4");
   
   self.YACL_CENTER  =getglobal("YACL_CENTER");
   
   self.H_SLIDER=getglobal("YACL_H_SLIDER");
   self.V_SLIDER=getglobal("YACL_V_SLIDER");
   
   self.H_SLIDER_texture=getglobal("YACL_H_SLIDERThumb");
   self.V_SLIDER_texture=getglobal("YACL_V_SLIDERThumb");
   
   self.m_grid.m_H_SLIDER=self.H_SLIDER;
   self.m_grid.m_V_SLIDER=self.V_SLIDER;
   
   self.m_version=GetAddOnMetadata("YACL","Version");
   
   self:debug("Loaded YACL " .. self.m_version .. ", use /yacl slash commands");
   self:init_events(mainframe);
   
   mainframe:RegisterForDrag("LeftButton");
   mainframe:SetClampedToScreen( true );
   mainframe:SetMinResize(100,100);
   mainframe:SetMaxResize(768,680);
   
   SlashCmdList["YACL"] = YACL_SlashParse
   SLASH_YACL1 = "/yacl"
   
   self:install_movement_hooks();
   
   -- tinsert(UISpecialFrames,"YACLSETTINGSDIALOG");
   
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_drag_start_mainframe(mainframe)
   self:on_drag_stop_mainframe(mainframe);
   mainframe:StartMoving();
   mainframe.isMoving=true;
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_resize_start_mainframe(mainframe,point)
   self:on_drag_stop_mainframe(mainframe);
   mainframe:StartSizing(point);
   mainframe.isResizing = true;
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_drag_stop_mainframe(mainframe)
   if(mainframe.isMoving or mainframe.isResizing) then
      mainframe:StopMovingOrSizing();
      mainframe.isMoving   = false;
      mainframe.isResizing = false;
      self:set_texture_positions(true);
   end
   -- we do not want to be in the layout cache !
   mainframe:SetUserPlaced(false);
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_size_changed(mainframe)
   self:set_texture_positions();
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_toggle_options()
   if(self.m_options_frame:IsVisible()) then self.m_options_frame:Hide(); else self.m_options_frame:Show(); end
end

-- ******************************************************************
--
-- ******************************************************************

function  yacl:on_show_settings()
   -- self:debug("show settings");
   if(self.m_settings_frame) then
      
      if(self.m_settings_frame:IsVisible()) then
         self.m_settings_frame:Hide();
      else
         self.m_settings_frame:Show();
      end
      
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:setup_color()
   
   local r=1;
   local g=1;
   local b=1;
   local a=1;
   
   if(self.m_in_combat) then
      g=0; b=0; a=0.5;
   else
      if(self.detail_guid) then
         r=0.5; g=0.5;
      else
         if(not yacl_global_settings.m_show_damage) then
            r=0.5;b=0.5;
         end
      end
   end
   
   self:SetVertexColor(r,g,b,a);
   
   self:setup_button_texture(self.m_combat_btn,
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_HEAL",
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_COMBAT",
   yacl_global_settings.m_show_damage);
   
   self:setup_button_texture(self.m_in_btn,
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_OUT",
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_IN",
   yacl_global_settings.m_show_incoming );
   
   
   self:setup_button_texture(self.m_fight_btn,
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_SUM_FIGHT",
   "INTERFACE\\ADDONS\\YACL\\TEXTURES\\BUTTON_DELTA_FIGHT",
   yacl_global_settings.m_show_fight );
   
   self:setup_button_color(self.m_perc_btn   ,    yacl_global_settings.m_percentage_mode);
   
   yacl_frame_template_SetVertextColor(self.m_settings_frame,r,g,b,a);
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:setup_button_color(button,status)
   if(button) then
      
      local t=button.m_highlight_texture;
      if(not t) then
         t=button:CreateTexture(nil,"BACKGROUND");
         button.m_highlight_texture=t;
         t:SetAllPoints(button);
         t:SetTexture(1,1,0,0.5);
      end
      
      if(status) then
         t:Show();
      else
         t:Hide();
      end
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:setup_button_texture(button,t1,t2,status)
   if(button) then
      
      if(status) then
         button:SetNormalTexture(t2);
      else
         button:SetNormalTexture(t1);
      end
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:setup_title()
   
   local text;
   if(yacl_global_settings.m_minimized_mode) then
      text="YACL";
   else
      
      if(yacl_global_settings.m_show_fight) then
         text="Last ";
      else
         text="Summary ";
      end
      
      if(yacl_global_settings.m_show_incoming) then
         if(yacl_global_settings.m_show_damage) then
            text=text.."incoming damage";
         else
            text=text.."incoming healing";
         end
      else
         if(yacl_global_settings.m_show_damage) then
            text=text.."damage";
         else
            text=text.."healing";
         end
      end
      if(yacl_global_settings.m_percentage_mode) then
         text=text.." %";
      end
      
      if(self.detail_guid) then
         local combatant=yacl_database.players[self.detail_guid];
         if(combatant) then
            text=text.." for " .. combatant.name;
         end
      end
      
      self.m_grid.m_title=text;
      
   end
   self.m_title:SetText(text);
   self:setup_color();
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_select_fight(status)
   if(status==nil) then
      yacl_global_settings.m_show_fight=not yacl_global_settings.m_show_fight;
   else
      yacl_global_settings.m_show_fight=status;
   end
   self:setup_title();
   self:on_update_view(true);
   -- update the tooltip
   if(GameTooltip:GetOwner()==self.m_fight_btn) then
      self:on_show_fight_tooltip();
   end
end


-- ******************************************************************
--
-- ******************************************************************

function yacl:on_show_fight_tooltip()
   GameTooltip:SetOwner(self.m_fight_btn, "ANCHOR_LEFT");
   if(yacl_global_settings.m_show_fight) then
      GameTooltip:SetText("Last fight mode\nclick - changes to allfights");
   else
      GameTooltip:SetText("Allfights mode\nclick - changes to last fight");
   end
end

-- ******************************************************************
--
-- ******************************************************************

function  yacl:on_show_damage(status)
   -- self.m_options_frame:Hide();
   if(status==nil) then
      yacl_global_settings.m_show_damage=not yacl_global_settings.m_show_damage;
   else
      yacl_global_settings.m_show_damage=status;
   end
   self:setup_title();
   self:on_update_view(true);
   
   -- update the tooltip
   if(GameTooltip:GetOwner()==self.m_combat_btn) then
      self:on_show_damage_tooltip();
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_show_damage_tooltip()
   GameTooltip:SetOwner(self.m_combat_btn, "ANCHOR_LEFT");
   if(yacl_global_settings.m_show_damage) then
      GameTooltip:SetText("Damage mode\nclick - changes to heal");
   else
      GameTooltip:SetText("Healing mode\nclick - changes to damage");
   end
end

-- ******************************************************************
--
-- ******************************************************************

function  yacl:on_show_incoming(status)
   if(status==nil) then
      yacl_global_settings.m_show_incoming=not yacl_global_settings.m_show_incoming;
   else
      yacl_global_settings.m_show_incoming=status;
   end
   self:setup_title();
   self:on_update_view(true);
   -- update the tooltip
   if(GameTooltip:GetOwner()==self.m_in_btn) then
      self:on_show_incoming_tooltip();
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_show_incoming_tooltip()
   GameTooltip:SetOwner(self.m_in_btn, "ANCHOR_LEFT");
   if(yacl_global_settings.m_show_incoming) then
      GameTooltip:SetText("Incoming mode\nclick - changes to outgoing");
   else
      GameTooltip:SetText("Outgoing mode\nclick - changes to incoming");
   end
end


-- ******************************************************************
--
-- ******************************************************************

function yacl:on_toggle_percent_mode()
   yacl_global_settings.m_percentage_mode=not yacl_global_settings.m_percentage_mode;
   self:setup_title();
   self:on_update_view(true);
   -- update the tooltip
   if(GameTooltip:GetOwner()==self.m_perc_btn) then
      self:on_show_percentage_tooltip();
   end
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:on_show_percentage_tooltip()
   GameTooltip:SetOwner(self.m_perc_btn, "ANCHOR_LEFT");
   if(yacl_global_settings.m_percentage_mode) then
      GameTooltip:SetText("Percentage mode\nclick - changes to absolute");
   else
      GameTooltip:SetText("Absolute mode\nclick - changes to percentage");
   end
end


-- ******************************************************************
--
-- ******************************************************************

function  yacl:on_reset_combatlog()
   self:message_box("Reset combat log?",self.on_reset_combatlog_confirmed,yacl);
end

function  yacl:on_reset_combatlog_confirmed()
   
   self.m_options_frame:Hide();
   
   self.temp={};
   yacl_database.players={};
   yacl_database.fight_start={};
   self:update_party();
   
   self:on_update_view(true);
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:cursor_left()
   grid.h_scroll(self.m_grid,-1);
end

function yacl:cursor_right()
   grid.h_scroll(self.m_grid,1);
end

function yacl:cursor_up()
   grid.v_scroll(self.m_grid,-1);
end

function yacl:cursor_down()
   grid.v_scroll(self.m_grid, 1);
end


-- ******************************************************************
--
-- ******************************************************************

function yacl:set_minimized_mode(set_minimized)
   
   local parent_h=self.m_parent:GetHeight();
   local parent_w=self.m_parent:GetWidth();
   
   local height=self.m_mainframe:GetHeight();
   local width =self.m_mainframe:GetWidth ();
   local x     =-(parent_w-self.m_mainframe:GetRight());
   local y     =-(parent_h-self.m_mainframe:GetTop());
   
   if(set_minimized==nil) then
      yacl_global_settings.m_minimized_mode=not yacl_global_settings.m_minimized_mode;
   else
      yacl_global_settings.m_minimized_mode=set_minimized;
   end
   
   if(yacl_global_settings.m_minimized_mode) then
      height= 32;
      width= 128;
      x    = yacl_global_settings.m_small_x;
      y    = yacl_global_settings.m_small_y;
      --self:debug("Set small mode at " .. x .. " , " .. y .. " in " .. parent_w .. " , " .. parent_h );
   else
      height = yacl_global_settings.m_big_height;
      width  = yacl_global_settings.m_big_width ;
      x      = yacl_global_settings.m_big_x;
      y      = yacl_global_settings.m_big_y;
      if(not height or height<100) then height=100; end
      if(not width  or width <100) then width =100; end
      --self:debug("Set BIG mode at " .. x .. " , " .. y);
   end
   
   self.m_mainframe:ClearAllPoints();
   self.m_mainframe:SetPoint ("TOPRIGHT",self.m_parent,"TOPRIGHT",x,y);
   self.m_mainframe:SetHeight(height);
   self.m_mainframe:SetWidth (width);
   
   self.m_options_frame:Hide();
   self:setup_title();
   
   self.m_grid.m_update=true;
   self.m_update_time  =0;
   
end

-- ******************************************************************
--
-- ******************************************************************

function yacl:toggle_detail_mode()
   
   self:set_minimized_mode(false);
   
   if(self.detail_guid) then
      self.detail_guid=nil;
      self:on_update_global_view(true);
      self:setup_title();
   else
      self.detail_guid=self.player_guid;
      self:on_update_detailed_view(true);
      self:setup_title();
   end
end
-- *************************************************************************
--
-- *************************************************************************

function yacl:setup_settings_frame()
   
   self.YACL_OBTN_CURSOR:SetChecked(yacl_global_settings.m_use_cursor_keys);
   self.YACL_OBTN_AUTOHIDE:SetChecked(yacl_global_settings.m_auto_hide);
   self.YACL_OBTN_AUTOSHOW:SetChecked(yacl_global_settings.m_auto_show);
   self.YACL_OBTN_AUTORESET:SetChecked(yacl_global_settings.m_auto_reset);
   self.YACL_OBTN_AUDIO:SetChecked(yacl_global_settings.m_use_sounds);
   
   self.YACL_OBTN_TITLE:SetText(yacl_title_options[yacl_global_settings.m_title_type].text);
   self.YACL_OBTN_BARS:SetText(yacl_bars_options[yacl_global_settings.m_bars_type].short_text);
   
   yacl.YACL_BARS_SLIDER:SetValue(yacl_global_settings.m_anz_bars)
   self.m_update_time=0;
end





