
function yacl_frame_template_create_texture(frame,point,width,height)
   local t=frame:CreateTexture(nil,"BACKGROUND");
   t:SetTexture("Interface\\Addons\\yacl\\Textures\\yacl_settingsframe");
   -- t:SetColorTexture(1,1,1,1);
   if(point ~=nil) then t:SetPoint(point,frame); end
   if(width ~=nil) then t:SetWidth(width);       end
   if(height~=nil) then t:SetHeight(height);     end
   t:Show();
   return t;
end

function yacl_frame_template_on_load(frame)
   
   local corner=16;
   local xres  =64;
   local l=xres-2*corner;
   local d0=corner/xres;
   local d1=1-d0;
   
   frame.m_texture_tl=yacl_frame_template_create_texture(frame,"TOPLEFT",corner,corner);
   frame.m_texture_tl:SetTexCoord(0,d0,0,d0);
   
   frame.m_texture_tr=yacl_frame_template_create_texture(frame,"TOPRIGHT",corner,corner);
   frame.m_texture_tr:SetTexCoord(d1,1,0,d0);
   
   frame.m_texture_bl=yacl_frame_template_create_texture(frame,"BOTTOMLEFT",corner,corner);
   frame.m_texture_bl:SetTexCoord(0,d0,d1,1);
   
   frame.m_texture_br=yacl_frame_template_create_texture(frame,"BOTTOMRIGHT",corner,corner);
   frame.m_texture_br:SetTexCoord(d1,1,d1,1);
   
   frame.m_texture_center=yacl_frame_template_create_texture(frame);
   frame.m_texture_center:SetTexCoord(d0,d1,d0,d1);
   frame.m_texture_center:SetPoint("TOPLEFT"    ,frame,"TOPLEFT",corner,-corner);
   frame.m_texture_center:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-corner,corner);
   
   frame.m_texture_t=yacl_frame_template_create_texture(frame);
   frame.m_texture_t:SetTexCoord(d0,d1,0,d0);
   frame.m_texture_t:SetPoint("TOPLEFT"    ,frame,"TOPLEFT",corner,0);
   frame.m_texture_t:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",-corner,-corner);
   
   frame.m_texture_b=yacl_frame_template_create_texture(frame);
   frame.m_texture_b:SetTexCoord(d0,d1,d1,1);
   frame.m_texture_b:SetPoint("BOTTOMLEFT" ,frame,"BOTTOMLEFT" ,corner,0);
   frame.m_texture_b:SetPoint("TOPRIGHT"   ,frame,"BOTTOMRIGHT",-corner,corner);
   
   frame.m_texture_l=yacl_frame_template_create_texture(frame);
   frame.m_texture_l:SetTexCoord(0,d0,d0,d1);
   frame.m_texture_l:SetPoint("TOPLEFT"    ,frame,"TOPLEFT",0,-corner);
   frame.m_texture_l:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT",corner,corner);
   
   frame.m_texture_r=yacl_frame_template_create_texture(frame);
   frame.m_texture_r:SetTexCoord(d1,1,d0,d1);
   frame.m_texture_r:SetPoint("TOPRIGHT"  ,frame,"TOPRIGHT",0,-corner);
   frame.m_texture_r:SetPoint("BOTTOMLEFT",frame,"BOTTOMRIGHT",-corner,corner);
   
end

function yacl_frame_template_SetVertextColor(frame,r,g,b,a)
   if(frame) then
      frame.m_texture_tl:SetVertexColor(r,g,b,a);
      frame.m_texture_tr:SetVertexColor(r,g,b,a);
      frame.m_texture_bl:SetVertexColor(r,g,b,a);
      frame.m_texture_br:SetVertexColor(r,g,b,a);
      
      frame.m_texture_t:SetVertexColor(r,g,b,a);
      frame.m_texture_b:SetVertexColor(r,g,b,a);
      frame.m_texture_l:SetVertexColor(r,g,b,a);
      frame.m_texture_r:SetVertexColor(r,g,b,a);
      
      frame.m_texture_center:SetVertexColor(r,g,b,a);
   end
end


function yacl:on_load_slider(slider)
   
   local id    =slider:GetID();
   local parent=slider:GetParent();
   local h     =slider:GetHeight();
   local h2    =h/2;
   local w     =slider:GetWidth()-h;
   
   self.m_slider[id]=slider;
   
   slider:SetPoint("TOP",parent,"BOTTOM",0,-((id-1)*h));
   
   local tx_l=slider:CreateTexture(nil,"BACKGROUND");
   local tx_m=slider:CreateTexture(nil,"BACKGROUND");
   local tx_r=slider:CreateTexture(nil,"BACKGROUND");
   
   slider.tx_l=tx_l;
   slider.tx_m=tx_m;
   slider.tx_r=tx_r;
   
   tx_l:SetTexture("Interface\\Addons\\yacl\\Textures\\round32");
   tx_m:SetTexture("Interface\\Addons\\yacl\\Textures\\round32");
   tx_r:SetTexture("Interface\\Addons\\yacl\\Textures\\round32");
   
   local d=0.05;
   
   tx_l:SetTexCoord(0    ,0.5-d,0,1);
   tx_m:SetTexCoord(0.5-d,0.5+d,0,1);
   tx_r:SetTexCoord(0.5+d,    1,0,1);
   
   tx_l:SetVertexColor(1,1,1,0.5);
   tx_m:SetVertexColor(1,1,1,0.5);
   tx_r:SetVertexColor(1,1,1,0.5);
   
   tx_l:SetPoint("TOPLEFT",slider,"TOPLEFT",0,0);
   tx_l:SetWidth(h2);
   tx_l:SetHeight(h);
   
   tx_m:SetPoint("LEFT",tx_l,"RIGHT",0,0);
   tx_m:SetWidth(w);
   tx_m:SetHeight(h);
   
   tx_r:SetPoint("LEFT",tx_m,"RIGHT",0,0);
   tx_r:SetWidth(h2);
   tx_r:SetHeight(h);
   
   local t=slider:CreateFontString(nil,nil,"GameFontNormalSmall");
   slider.t =t;
   t:SetJustifyH("LEFT");
   --t:SetShadowOffset(0,0);
   --t:SetShadowColor(0, 0, 0, 0);
   t:SetTextColor(1,1,1,0.8);
   t:SetAllPoints(slider);
   
   local tr=slider:CreateFontString(nil,nil,"GameFontNormalSmall");
   slider.tr =tr;
   tr:SetJustifyH("RIGHT");
   --t:SetShadowOffset(0,0);
   --t:SetShadowColor(0, 0, 0, 0);
   tr:SetTextColor(1,1,1,0.8);
   tr:SetAllPoints(slider);
   
end


function yacl:message_box(text,func_ok,THIS,param1,param2)
   
   local box=self.m_message_box;
   if(not box) then
      box=CreateFrame("Frame","YACL_message_box",UIParent,"YACL_MessageBoxFrame");
      self.m_message_box=box;
      tinsert(UISpecialFrames,"YACL_message_box");
      
      local h=box:GetHeight();
      local w=box:GetWidth();
      
      box.m_text=box:CreateFontString(nil,nil,"GameFontNormalLarge");
      box.m_text:SetPoint("TOPLEFT",box,0,0);
      box.m_text:SetHeight(h/2);
      box.m_text:SetWidth(w);
      
      box.m_button_ok:SetText("OK");
      box.m_button_cancel:SetText("Cancel");
   end
   
   box.m_text:SetText(text);
   box.m_button_ok.m_func=func_ok;
   box.m_button_ok.m_THIS  =THIS;
   box.m_button_ok.m_param1=param1;
   box.m_button_ok.m_param2=param2;
   
   box:Show();
end

