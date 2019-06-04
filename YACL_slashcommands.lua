
function yacl:slash_command_help(param)
   for cmd,entry in pairs(yacl.slash_commands) do
      local text=format("%s :  %s",cmd,entry[2]);
      print(text);
   end
end

local param_on_off=
{
   ["1"  ]=true;
   ["on" ]=true;
   ["ein"]=true;
};

function yacl:slash_command_reset(param)
   self:on_reset_combatlog_confirmed();
end

function yacl:slash_command_heal(param)
   self:on_show_damage(false);
end

function yacl:slash_command_damage(param)
   self:on_show_damage(true);
end

function yacl:slash_command_percent(param)
   self:on_toggle_percent_mode();
end

function yacl:slash_command_min(param)
   self:set_minimized_mode(true);
end

function yacl:slash_command_max(param)
   self:set_minimized_mode(false);
end

function yacl:slash_command_use_cursor(param)
   if(param) then
      param=param_on_off[param];
   else
      if(yacl_global_settings.m_use_cursor_keys) then
         param=false;
      else
         param=true;
      end
   end
   yacl_global_settings.m_use_cursor_keys=param;
   self:SetCursorBindings();
   if(yacl_global_settings.m_use_cursor_keys) then
      self:debug("enable cursor keys");
   else
      self:debug("disable cursor keys");
   end
end

function yacl:slash_command_autohide(param)
   if(param) then
      param=param_on_off[param];
   else
      param= not yacl_global_settings.m_auto_hide;
   end
   yacl_global_settings.m_auto_hide=param;
   if(yacl_global_settings.m_auto_hide) then
      self:debug("enable auto hide");
   else
      self:debug("disable auto hide");
   end
end

function yacl:slash_command_autoshow(param)
   if(param) then
      param=param_on_off[param];
   else
      param= not yacl_global_settings.m_auto_show;
   end
   yacl_global_settings.m_auto_show=param;
   if(yacl_global_settings.m_auto_show) then
      self:debug("enable auto show");
   else
      self:debug("disable auto show");
   end
end

function yacl:slash_command_autoreset(param)
   if(param) then
      param=param_on_off[param];
   else
      param= not yacl_global_settings.m_auto_reset;
   end
   yacl_global_settings.m_auto_reset=param;
   if(yacl_global_settings.m_auto_reset) then
      self:debug("enable auto reset");
   else
      self:debug("disable auto reset");
   end
end

function yacl:slash_command_sound(param)
   if(param) then
      param=param_on_off[param];
   else
      param= not yacl_global_settings.m_use_sounds;
   end
   yacl_global_settings.m_use_sounds=param;
   if(yacl_global_settings.m_use_sounds) then
      self:debug("enable sounds");
   else
      self:debug("disable sounds");
   end
end

function yacl:slash_command_defaults(param)
   yacl_global_settings=yacl_copy_table(yacl_global_defaults);
   self:debug("YACL reset to global defaults");
   yacl_database.m_structure_update=true;
   self:setup_title();
end

function yacl:slash_command_bars(param)
   
   param=tonumber(param);
   
   if(param~=nil) then
      yacl_global_settings.m_anz_bars=param;
      if(yacl_global_settings.m_anz_bars<0) then
         yacl_global_settings.m_anz_bars=0;
      end
      if(yacl_global_settings.m_anz_bars>20) then
         yacl_global_settings.m_anz_bars=20;
      end
   else
      if(yacl_global_settings.m_anz_bars>0) then
         yacl_global_settings.m_anz_bars=0;
      else
         yacl_global_settings.m_anz_bars=10;
      end
   end
   
   self:debug("Settings bars to "..yacl_global_settings.m_anz_bars);
end

function yacl:slash_command_hide()
   self.m_mainframe:Hide();
   self:debug("Hiding interface");
end

function yacl:slash_command_show()
   self.m_mainframe:Show();
   self:debug("Showing interface");
end


yacl.slash_commands=
{
   ["help"   ]={ yacl.slash_command_help   ,"List all commands" };
   ["reset"  ]={ yacl.slash_command_reset  ,"Reset combat log"  };
   ["heal"   ]={ yacl.slash_command_heal   ,"Show healing data" };
   ["damage" ]={ yacl.slash_command_damage ,"Show damage data"  };
   ["percent"]={ yacl.slash_command_percent,"Toggle percentage mode" };
   ["defaults"]={ yacl.slash_command_defaults,"Reset settings to default" };
   ["min"]={ yacl.slash_command_min,"Minimizes the window" };
   ["max"]={ yacl.slash_command_max,"Maximizes the window" };
   ["cursor"]={ yacl.slash_command_use_cursor,"Enables scrolling with cursor keys" };
   ["autohide"]={ yacl.slash_command_autohide,"Set auto hide on/off" };
   ["autoshow"]={ yacl.slash_command_autoshow,"Set auto show on/off" };
   ["autoreset"]={ yacl.slash_command_autoreset,"Set auto reset on/off" };
   ["bars"]     ={ yacl.slash_command_bars    ,"Set number of bars" };
   ["sound"]    ={ yacl.slash_command_sound   ,"Set sound on/off" };
   ["hide"]     ={ yacl.slash_command_hide    ,"Hide interface" };
   ["show"]     ={ yacl.slash_command_show    ,"Show interface" };
};


function YACL_SlashParse( msg )
   -- extract option name and option argument from message string
   local _, _, cmd, param = string.find( string.lower(msg), "([%w_]*)[ ]*([-%w]*)")
   
   if(param=="") then param=nil; end
   
   -- yacl:debug("Slash Parse: cmd  ='" .. (cmd or nil) .. "'");
   -- yacl:debug("Slash Parse: param='" .. (param or nil) .. "'");
   
   if(cmd) then
      local entry = yacl.slash_commands[cmd];
      if(entry) then
         entry[1](yacl,param);
         yacl:setup_settings_frame();
      else
         yacl:debug("Unkown command. Try /yacl help");
      end
   end
end


