-- ************************************************************************************
--
-- ************************************************************************************

function Yacl_SelectTitleDropdown(self)
   yacl_global_settings.m_title_type=self.value;
   yacl:setup_settings_frame();
end

yacl_title_options=
{
   [1]={ text="Nothing"        ,value=1 ,func=Yacl_SelectTitleDropdown;};
   [2]={ text="Clock"          ,value=2 ,func=Yacl_SelectTitleDropdown;};
   [3]={ text="Fight duration" ,value=3 ,func=Yacl_SelectTitleDropdown;};
   [4]={ text="DPS"            ,value=4 ,func=Yacl_SelectTitleDropdown;};
   [5]={ text="HPS"            ,value=5 ,func=Yacl_SelectTitleDropdown;};
   
};

function Yacl_TitleDropDownMenu_OnLoad()
   for i,info in ipairs(yacl_title_options) do
      info.checked=(i==yacl_global_settings.m_title_type);
      UIDropDownMenu_AddButton(info);
   end
end

function Yacl_TitleDropDownMenuButton_OnClick()
   UIDropDownMenu_SetAnchor(YACL_TitleDropDownMenu,-10, 10, "TOPLEFT", yacl.YACL_OBTN_TITLE , "BOTTOMRIGHT")
   ToggleDropDownMenu(1, nil, YACL_TitleDropDownMenu);
end

-- ************************************************************************************
--
-- ************************************************************************************

function Yacl_SelectBarsDropdown(self)
   yacl_global_settings.m_bars_type=self.value;
   yacl:setup_settings_frame();
end

yacl_bars_options=
{
   [1]={ text="Default, follow main mode" ,short_text="Default", value=1 ,func=Yacl_SelectBarsDropdown;};
   [2]={ text="Damage per second"         ,short_text="DPS"    , value=2 ,func=Yacl_SelectBarsDropdown;};
   [3]={ text="Heal per second"           ,short_text="HPS"    , value=3 ,func=Yacl_SelectBarsDropdown;};
   [4]={ text="Damage+Healing"            ,short_text="D+H"    , value=4 ,func=Yacl_SelectBarsDropdown;};
   
};

function Yacl_BarsDropDownMenu_OnLoad()
   for i,info in ipairs(yacl_bars_options) do
      info.checked=(i==yacl_global_settings.m_bars_type);
      UIDropDownMenu_AddButton(info);
   end
end

function Yacl_BarsDropDownMenuButton_OnClick()
   UIDropDownMenu_SetAnchor(YACL_BarsDropDownMenu,-10, 10, "TOPLEFT", yacl.YACL_OBTN_BARS , "BOTTOMRIGHT")
   ToggleDropDownMenu(1, nil, YACL_BarsDropDownMenu);
end





