local Root = CoolLevelUp;

local Engine = Root.GetOrNewModule("Engine");

-- External modules required
local Manager = Root.GetOrNewModule("Manager");
local Trainer = Root.GetOrNewModule("Trainer");

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local sequenceInfo = {
	["NONEWSPELL"] = {
		music = "MINOR_LEVELUP",
		initialAnim = "LevelUp",
		levelUpHoldTime = 2.500,
		levelUpTotalTime = 3.500,
		program = {
			[1] = {
				time = 0.000,
				type = "DISPLAY_WINDOWS",
			},
			[2] = {
				time = 2.500,
				type = "UPDATE_LEVEL",
			},
			[3] = {
				time = 4.000,
				type = "UPDATE_STATS",
			},
			[4] = {
				time = 14.000,
				type = "END",
			},
		},
	},
	["NEWSPELL"] = {
		music = "MAJOR_LEVELUP",
		initialAnim = "LevelUp",
		levelUpHoldTime = 4.000,
		levelUpTotalTime = 3.300,
		program = {
			[1] = {
				time = 0.000,
				type = "DISPLAY_WINDOWS",
			},
			[2] = {
				time = 2.500,
				type = "UPDATE_LEVEL",
			},
			[3] = {
				time = 4.000,
				type = "UPDATE_STATS",
			},
			[4] = {
				time = 6.000,
				type = "UPDATE_SPELLS",
			},
			[5] = {
				time = 16.000,
				type = "END",
			},
		},
	},
	["NEWTIER"] = {
		music = "CRITICAL_LEVELUP",
		initialAnim = "LevelUp",
		levelUpHoldTime = 4.500,
		levelUpTotalTime = 3.000,
		program = {
			[1] = {
				time = 0.000,
				type = "DISPLAY_WINDOWS",
			},
			[2] = {
				time = 2.500,
				type = "UPDATE_LEVEL",
			},
			[3] = {
				time = 4.000,
				type = "UPDATE_STATS",
			},
			[4] = {
				time = 6.000,
				type = "UPDATE_SPELLS",
			},
			[5] = {
				time = 21.000,
				type = "END",
			},
		},
	},
	["FINALTIER"] = {
		music = "FINAL_LEVELUP",
		initialAnim = "Congratulations",
		levelUpHoldTime = 5.500,
		levelUpTotalTime = 3.000,
		program = {
			[1] = {
				time = 0.000,
				type = "DISPLAY_WINDOWS",
			},
			[2] = {
				time = 15.750,
				type = "DISPLAY_LEVELUP",
			},
			[3] = {
				time = 21.300,
				type = "UPDATE_LEVEL",
			},
			[4] = {
				time = 24.000,
				type = "UPDATE_STATS",
			},
			[5] = {
				time = 26.000,
				type = "UPDATE_SPELLS",
			},
			[6] = {
				time = 46.000,
				type = "END",
			},
		},
	},
};

local stats = {
	[1] = {
		name = "level",
		api = function()
				  return UnitLevel("player");
			  end,
	},
	[2] = {
		name = "hp",
		api = function()
				  return UnitHealthMax("player");
			  end,
	},
	[3] = {
		name = "mp",
		api = function()
				  return UnitPowerMax("player", SPELL_POWER_MANA);
			  end,
	},
	[4] = {
		name = "tp",
		api = function()
				  count = 0;
				  local i;
				  for i=1, GetNumTalentTabs() do
					  count = count + select(3, GetTalentTabInfo(i));	--changed 3 to 5 because of 4.0.1
				  end
				  return count + select(1, UnitCharacterPoints("player"));	--changed from	select(1, UnitCharacterPoints("player"));
			  end,
	},
	[5] = {
		name = "str",
		api = function()
				  return select(2, UnitStat("player", 1));
			  end,
	},
	[6] = {
		name = "agi",
		api = function()
				  return select(2, UnitStat("player", 2));
			  end,
	},
	[7] = {
		name = "stm",
		api = function()
				  return select(2, UnitStat("player", 3));
			  end,
	},
	[8] = {
		name = "int",
		api = function()
				  return select(2, UnitStat("player", 4));
			  end,
	},
	[9] = {
		name = "spi",
		api = function()
				  return select(2, UnitStat("player", 5));
			  end,
	},
};

-- --------------------------------------------------------------------
-- **							Methods							 **
-- --------------------------------------------------------------------

Engine.InstallHook = function(self)
	if ( self.hookInstalled ) then return; end
	self.hookInstalled = true;

	local Orig_ChatFrame_SystemEventHandler = ChatFrame_SystemEventHandler;
	ChatFrame_SystemEventHandler = function(self, event, ...)
		if ( event == "PLAYER_LEVEL_UP" ) then
			return;
		end
		Orig_ChatFrame_SystemEventHandler(self, event, ...);
	end;
end

Engine.FillStats = function(self, table)
	local i, statInfo;
	for i=1, #stats do
		statInfo = stats[i];
		table[statInfo.name] = statInfo.api();
	end
end

Engine.SubstractStats = function(self, resultTable, t1, t2)
	local i, statInfo;
	for i=1, #stats do
		statInfo = stats[i];
		resultTable[statInfo.name] = t1[statInfo.name] - t2[statInfo.name];
	end
end

Engine.GetNumStats = function(self)
	return #stats;
end

Engine.GetStatInfo = function(self, index)
	return stats[index].name;
end

-- --------------------------------------------------------------------
-- **							Handlers							**
-- --------------------------------------------------------------------

Engine.OnStart = function(self)
	self:InstallHook();

	self.status = "STANDBY";

	self.oldStats = { };
	self.changeTable = { };
	self.newStats = { };
	self.newSpells = { };
end

Engine.OnLevelUp = function(self, changeTable)
	-- Clean up

	local k, v;
	for k, v in ipairs(self.newSpells) do self.newSpells[k] = nil; end

	Manager:GetHeader():Remove();
	Manager:GetBox():Remove();
	Manager:GetSpellBox():Remove();
	Manager:GetGrats():Remove();

	-- Choose the sequence type.

	local levelUpType = "NONEWSPELL";
	local newLevel = changeTable.level;

	-- Try to see if new spells are taught on this level.
	Trainer:ListSkillsAtLevel(newLevel);
	local numSkills = Trainer:GetNumResults();
	if numSkills > 0 then
		levelUpType = "NEWSPELL";
		local i;
		for i=1, numSkills do
			local name, rank, classTree, reqLevel = Trainer:GetResultInfo(i);
			if ( name and rank and rank > 0 ) then
				self.newSpells[#self.newSpells+1] = string.format("%s - %s (%s %d)", classTree, name, Root.Localise("rank"), rank);
		  else
				self.newSpells[#self.newSpells+1] = string.format("%s - %s", classTree, name);
			end
		end
	end

	if ( math.floor(newLevel/10)*10 == newLevel ) or ( newLevel == 85 ) then
		-- Level dividable per 10.
		local tier = newLevel/10;
		if ( tier >= 6 ) then
			levelUpType = "FINALTIER";
		else
			levelUpType = "NEWTIER";
		end
	end

	self.sequence = sequenceInfo[levelUpType];
	if not self.sequence then return; end

	-- Start !

	if ( self.sequence.initialAnim == "LevelUp" ) then
		local LevelUp = Manager:GetLevelUp();
		LevelUp:Display(self.sequence.levelUpHoldTime);

	elseif ( self.sequence.initialAnim == "Congratulations" ) then
		local Grats = Manager:GetGrats();
		Grats:Display(5.000);
	end

	Root.Music.Play(self.sequence.music);

	self.status = "WAIT_LEVELUP";
	self.timer = self.sequence.levelUpTotalTime;
	self.getNewStatsTimer = 1.500;
	self.changeTable = changeTable;
	self.changeTable.level = 1; -- Hack => The change in level should be 1 instead of the new level.
end

Engine.OnUpdate = function(self, elapsed)
	if ( not self.status ) or ( self.status == "STANDBY" ) then return; end

	if ( self.getNewStatsTimer ) then
		self.getNewStatsTimer = self.getNewStatsTimer - elapsed;
		if ( self.getNewStatsTimer <= 0.000 ) then
			-- Enough time has elapsed, now APIs should return current stats.
			self.getNewStatsTimer = nil;
			self:FillStats(self.newStats);
			self:SubstractStats(self.oldStats, self.newStats, self.changeTable);
		end
	end

	if ( self.status == "WAIT_LEVELUP" ) then
		self.timer = self.timer - elapsed;
		if ( self.timer <= 0.000 ) and not ( self.getNewStatsTimer ) then -- We cannot proceed if we do not have all infos needed on stats.
			-- StopMusic();
			self.status = "PROGRAM";
			self.timer = 0.000;
			self.paused = false;
			self.events = { };
		end

	elseif ( self.status == "PROGRAM" ) and ( not self.paused ) then
		self.timer = self.timer + elapsed;
		local program = self.sequence.program;
		local k, event;
		for k, event in ipairs(program) do
			if ( not self.events[k] ) and ( event.time <= self.timer ) then
				self.events[k] = true;
				self:FireEvent(event);
			end
		end
	end
end

Engine.FireEvent = function(self, eventTable)
	if ( eventTable.type == "DISPLAY_LEVELUP" ) then
		Manager:GetLevelUp():Display(self.sequence.levelUpHoldTime);

	elseif ( eventTable.type == "DISPLAY_WINDOWS" ) then
		Manager:GetHeader():Display(select(1, UnitClass("player")), self.oldStats.level);
		Manager:GetBox():Display();
		Manager:GetBox():SetStats(self.oldStats, self.newStats);
		if ( #self.newSpells > 0 ) then
			Manager:GetSpellBox():Display(#self.newSpells);
		end

	elseif ( eventTable.type == "UPDATE_LEVEL" ) then
		Manager:GetHeader():ChangeValue(self.newStats.level);
		Root.Sound.Play("LEVEL_CHANGE");

	elseif ( eventTable.type == "UPDATE_STATS" ) then
		self.paused = true;
		Manager:GetBox():UpdateStats(self.changeTable, self.newStats, Engine, Engine.UnpauseProgram);

	elseif ( eventTable.type == "UPDATE_SPELLS" ) then
		if ( #self.newSpells > 0 ) then
			self.paused = true;
			Manager:GetSpellBox():WriteSpells(self.newSpells, Engine, Engine.UnpauseProgram);
		end

	elseif ( eventTable.type == "CONGRATULATE" ) then
		Manager:GetGrats():Display(5.000);

	elseif ( eventTable.type == "END" ) then
		Root.Music.Stop();
		Manager:GetHeader():Remove();
		Manager:GetBox():Remove();
		Manager:GetSpellBox():Remove();
		Manager:GetGrats():Remove();
	end
end

Engine.UnpauseProgram = function(self)
	if ( self.status ~= "PROGRAM" ) then return; end
	self.paused = false;
end