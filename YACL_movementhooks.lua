function yacl_char_moved()
   if(yacl_global_settings.m_auto_hide) then
      if(not yacl_global_settings.m_minimized_mode) then
         yacl:set_minimized_mode(true);
      end
   end
end

function yacl:install_movement_hooks()
   if(not self.movement_hooks_installed) then
      
      hooksecurefunc("MoveBackwardStart",yacl_char_moved);
      hooksecurefunc("MoveForwardStart" ,yacl_char_moved);
      hooksecurefunc("StrafeLeftStart"  ,yacl_char_moved);
      hooksecurefunc("StrafeRightStart" ,yacl_char_moved);
      hooksecurefunc("TurnLeftStart"    ,yacl_char_moved);
      hooksecurefunc("TurnRightStart"   ,yacl_char_moved);
      
      self.movement_hooks_installed=true;
   end
end

