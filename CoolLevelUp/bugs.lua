1 { fixed
Date: 2010-12-06 20:12:43
ID: 1
Error occured in: Global
Count: 1
Message: ..\AddOns\CoolLevelUp\gui\engine.lua line 153:
   attempt to perform arithmetic on a string value
Debug:
   [C]: ?
   CoolLevelUp\gui\engine.lua:153: api()
   CoolLevelUp\gui\engine.lua:211: FillStats()
   CoolLevelUp\gui\engine.lua:319: ?()
   CoolLevelUp\CoolLevelUp.lua:55: InvokeHandler()
   CoolLevelUp\CoolLevelUp.lua:128: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

2 { fixed
Date: 2010-12-06 20:43:27
ID: 1
Error occured in: Global
Count: 1
Message: ..\AddOns\CoolLevelUp\gui\engine.lua line 155:
   attempt to call global 'UnitCharacterPoints' (a nil value)
Debug:
   [C]: UnitCharacterPoints()
   CoolLevelUp\gui\engine.lua:155: api()
   CoolLevelUp\gui\engine.lua:211: FillStats()
   CoolLevelUp\gui\engine.lua:319: ?()
   CoolLevelUp\CoolLevelUp.lua:55: InvokeHandler()
   CoolLevelUp\CoolLevelUp.lua:128: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

3 { fixed
Date: 2010-12-06 21:09:21
ID: 1
Error occured in: Global
Count: 8
Message: ..\AddOns\CoolLevelUp\gui\hole.lua line 157:
   attempt to perform arithmetic on local 'elapsed' (a nil value)
Debug:
   [C]: ?
   CoolLevelUp\gui\hole.lua:157: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

4 { fixed
Date: 2010-12-06 21:09:17
ID: 2
Error occured in: Global
Count: 8
Message: ..\AddOns\CoolLevelUp\gui\hole.lua line 152:
   attempt to perform arithmetic on local 'elapsed' (a nil value)
Debug:
   [C]: ?
   CoolLevelUp\gui\hole.lua:152: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

5 { fixed
Date: 2010-12-06 21:09:21
ID: 3
Error occured in: Global
Count: 8
Message: ..\AddOns\CoolLevelUp\gui\arrow.lua line 173:
   attempt to perform arithmetic on local 'elapsed' (a nil value)
Debug:
   [C]: ?
   CoolLevelUp\gui\arrow.lua:173: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

6 { cut-out
Date: 2010-12-06 22:54:03
ID: 1
Error occured in: Global
Count: 1
Message: ..\AddOns\CoolLevelUp\data\trainer.lua line 64:
   attempt to call global 'ExpandTrainerSkillLine' (a nil value)
Debug:
   [C]: ExpandTrainerSkillLine()
   CoolLevelUp\data\trainer.lua:64: ?()
   CoolLevelUp\CoolLevelUp.lua:55: InvokeHandler()
   CoolLevelUp\CoolLevelUp.lua:122: OnEvent()
   [string "*:OnEvent"]:1:
	  [string "*:OnEvent"]:1
}

8 { changed
.WAV is no longer playable

> converted all soundfiles to .OGG and changed 
data/music.lua
data/sound.lua
accordingly.
}

9 { fixed
Date: 2010-12-15 17:25:40
ID: 3
Error occured in: Global
Count: 1
Message: ..\AddOns\CoolLevelUp\gui\grats.lua line 163:
   attempt to perform arithmetic on local 'elapsed' (a nil value)
Debug:
   [C]: ?
   CoolLevelUp\gui\grats.lua:163: OnUpdate()
   [string "*:OnUpdate"]:1:
	  [string "*:OnUpdate"]:1
}

9