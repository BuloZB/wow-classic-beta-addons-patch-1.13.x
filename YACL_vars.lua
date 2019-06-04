
-----------------------------
-- global settings
-----------------------------

yacl_global_defaults=
{
   m_version=15;
   
   m_auto_hide  =true;
   m_auto_show  =false;
   m_auto_reset =true;
   m_title_type =1;
   m_bars_type  =1;
   
   m_percentage_mode=true;
   m_use_cursor_keys=false;
   m_use_sounds     =true;
   
   m_anz_bars=10;
   
   m_big_height =500;
   m_big_width  =500;
   m_big_x      =-250;
   m_big_y      =-150;
   
   m_small_x=-18;
   m_small_y=-180;
   
   m_cols=
   {
      -- n   = visible column name
      -- ni  = name of var to display
      -- w   = column width
      -- sd  = sort direction
      -- rel = name of var to scale with
      
      damage=
      {  -- see yacl_spells.lua for details of var names
         { n="Name"   , ni="name"  ,w=120 ,sd=false; };
         { n="Damage" , ni="S"     ,w=60  ,sd=true;  };
         { n="Time"   , ni="t"     ,w=60  ,sd=true;  type="time"; };
         { n="DPS"    , ni="dps"   ,w=60  ,sd=true;  type="raw"; };
         { n="Max"    , ni="x"     ,w=60  ,sd=true;  type="raw"; };
         { n="Crit"   , ni="c"     ,w=50  ,sd=true;  type="perc"; rel="n"  };
         { n="Miss"   , ni="m"     ,w=50  ,sd=true;  type="perc"; rel="n" };
         { n="Kills"  , ni="k"     ,w=50  ,sd=true;  type="raw"; };
      };
      
      damage_in=
      {  -- see yacl_spells.lua for details of var names
         { n="Name"  , ni="name"  ,w=120 ,sd=false; };
         { n="Taken" , ni="T"     ,w=60  ,sd=true;  };
         { n="Max"   , ni="x"     ,w=60  ,sd=true;  type="raw"; };
         { n="Avoid" , ni="m"     ,w=60  ,sd=true;  type="perc"; rel="n"  };
         { n="Crit"  , ni="c"     ,w=50  ,sd=true;  type="raw"; };
         { n="Crush" , ni="r"     ,w=50  ,sd=true;  type="raw"; };
         { n="Deaths" , ni="d"    ,w=50  ,sd=true;  type="raw"; };
      };
      
      healing=
      { -- see yacl_spells.lua for details of var names
         { n="Name"    , ni="name"  ,w=120 ,sd=false;};
         { n="Healing" , ni="H"     ,w=60  ,sd=true; };
         { n="Time"    , ni="t"     ,w=60  ,sd=true; type="time"; };
         { n="HPS"     , ni="hps"   ,w=60  ,sd=true; type="raw"; };
         { n="Max"     , ni="x"     ,w=60  ,sd=true; type="raw"; };
         { n="Crit"    , ni="c"     ,w=50  ,sd=true; type="perc"; rel="n"};
         { n="Overheal", ni="o"     ,w=70  ,sd=true; type="perc"; rel="s"};
      };
      
      healing_in=
      { -- see yacl_spells.lua for details of var names
         { n="Name"    , ni="name"  ,w=120 ,sd=false;};
         { n="Healed"  , ni="I"     ,w=60  ,sd=true; };
         { n="Max"     , ni="x"     ,w=60  ,sd=true;  type="raw"; };
         { n="Crit"    , ni="c"     ,w=50  ,sd=true; type="perc"; rel="n"};
         { n="Overheal", ni="o"     ,w=70  ,sd=true; type="perc"; rel="s"};
      };
      
   };
   
   m_cols_detail=
   {
      damage=
      {  -- see yacl_spells.lua for details of var names
         { n="Spell" , ni="name",w=120 ,sd=false;};
         { n="Damage", ni="s"   ,w=60  ,sd=true; };
         { n="Max"   , ni="x"   ,w=60  ,sd=true; type="raw"; };
         { n="Aver"  , ni="a"   ,w=60  ,sd=true; type="raw"; };
         { n="N"     , ni="n"   ,w=40  ,sd=true; };
         { n="Crit"  , ni="c"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Glance", ni="l"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Miss"  , ni="m"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Dodge" , ni="g"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Parry" , ni="p"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Block" , ni="b"   ,w=50  ,sd=true; type="perc"; rel="n" };
      };
      
      damage_in=
      {  -- see yacl_spells.lua for details of var names
         { n="Spell" , ni="name",w=120 ,sd=false;};
         { n="Taken" , ni="s"   ,w=60  ,sd=true; };
         { n="Max"   , ni="x"   ,w=60  ,sd=true; type="raw"; };
         { n="Aver"  , ni="a"   ,w=60  ,sd=true; type="raw"; };
         { n="N"     , ni="n"   ,w=40  ,sd=true; };
         { n="Crit"  , ni="c"   ,w=50  ,sd=true; type="raw"; };
         { n="Crush" , ni="r"   ,w=50  ,sd=true; type="raw"; };
         { n="Avoid" , ni="m"   ,w=60  ,sd=true; type="perc"; rel="n"  };
         { n="Dodge" , ni="g"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Parry" , ni="p"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Block" , ni="b"   ,w=50  ,sd=true; type="perc"; rel="n" };
      };
      
      healing=
      {  -- see yacl_spells.lua for details of var names
         { n="Spell"   , ni="name",w=120 ,sd=false;};
         { n="Healing" , ni="s"   ,w=60  ,sd=true; };
         { n="Max"     , ni="x"   ,w=60  ,sd=true; type="raw"; };
         { n="Aver"    , ni="a"   ,w=60  ,sd=true; type="raw"; };
         { n="N"       , ni="n"   ,w=40  ,sd=true; };
         { n="Crit"    , ni="c"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Overheal", ni="o"   ,w=70  ,sd=true; type="perc"; rel="s" };
      };
      
      healing_in=
      {  -- see yacl_spells.lua for details of var names
         { n="Spell"   , ni="name",w=120 ,sd=false;};
         { n="Healed"  , ni="s"   ,w=60  ,sd=true; };
         { n="Max"     , ni="x"   ,w=60  ,sd=true; type="raw"; };
         { n="Aver"    , ni="a"   ,w=60  ,sd=true; type="raw"; };
         { n="N"       , ni="n"   ,w=40  ,sd=true; };
         { n="Crit"    , ni="c"   ,w=50  ,sd=true; type="perc"; rel="n" };
         { n="Overheal", ni="o"   ,w=70  ,sd=true; type="perc"; rel="s" };
      };
      
   };
   
   m_show_fight   =false;   -- true = last fight, false(nil)=summary
   m_show_damage  =true;
   m_show_incoming=false;
   m_party_type   =0;       -- for auto reset on group join
   
};

yacl_global_settings={};


-----------------------------
-- the main combat log object
-----------------------------

yacl=
{
   event={};
   
   detail_guid=nil;
   m_update_time          =0; -- last time we update data for the grid (max once per second)
   m_update_title_time    =0;
   m_combat_message_time =0; -- last time we created delta values for sync ( max once per 10 seconds)
   m_last_check_combat_time=0;
   m_group_in_combat=nil;
   section_count=1;
   send_pet=false;
   
   temp={}; -- temporary copys of combat log to create deltas
   totems={};
   
   m_grid=grid.new("MainGrid");
   m_slider={};
   
};

-- *************************************************************************
-- the global database
-- *************************************************************************

yacl_database=
{
   players   ={};
   fight_start={};
   m_structure_update=nil;
   m_last_zone       =nil;
   m_last_instance   =nil;
   m_last_ghost      =nil;
};

-- *************************************************************************
-- key bindings
-- *************************************************************************

BINDING_HEADER_YACL      = "YACL";
BINDING_NAME_YACLRESET   = "Reset";
BINDING_NAME_YACLTOGGLE  = "Toggle size";
BINDING_NAME_YACLDETAILS = "Details";
BINDING_NAME_YACLCURSORLEFT ="Do not edit";
BINDING_NAME_YACLCURSORRIGHT="Do not edit";
BINDING_NAME_YACLCURSORUP   ="Do not edit";
BINDING_NAME_YACLCURSORDOWN ="Do not edit";

