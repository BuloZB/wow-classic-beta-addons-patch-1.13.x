local Root = CoolLevelUp;

local Manager = Root.GetOrNewModule("Manager");

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							Methods							 **
-- --------------------------------------------------------------------

Manager.GetLevelUp = function(self)
	return self.levelUp;
end

Manager.GetHeader = function(self)
	return self.header;
end

Manager.GetBox = function(self)
	return self.box;
end

Manager.GetSpellBox = function(self)
	return self.spellBox;
end

Manager.GetGrats = function(self)
	return self.grats;
end

-- --------------------------------------------------------------------
-- **							Handlers							**
-- --------------------------------------------------------------------

Manager.OnStart = function(self)
	-- Create level up frame. Only one needed.
	self.levelUp = CreateFrame("Frame", nil, nil, "CoolLevelUp_LevelUpTemplate");
	-- Create header frame. Only one needed.
	self.header = CreateFrame("Frame", nil, nil, "CoolLevelUp_HeaderTemplate");
	-- Create box frame. Only one needed.
	self.box = CreateFrame("Frame", nil, nil, "CoolLevelUp_BoxTemplate");
	-- Create spell box frame. Only one needed.
	self.spellBox = CreateFrame("Frame", nil, nil, "CoolLevelUp_SpellBoxTemplate");
	-- Create congrats frame. Only one needed.
	self.grats = CreateFrame("Frame", nil, nil, "CoolLevelUp_GratsTemplate");
end;

Manager.OnUpdate = function(self, elapsed)

end

