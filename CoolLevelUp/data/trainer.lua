local Root = CoolLevelUp;

local Trainer = Root.GetOrNewModule("Trainer");

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local EMPTY_TABLE = { };

-- --------------------------------------------------------------------
-- **							Methods							 **
-- --------------------------------------------------------------------

Trainer.GetNumResults = function(self)
	return #self.list;
end

Trainer.GetResultInfo = function(self, index)
	local info = self.list[index] or EMPTY_TABLE;
	return info.name or nil, info.rank or 0, info.tree or nil, info.level or 0;
end

Trainer.ListSkillsAtLevel = function(self, level)
	wipe(self.list);

	local myClass = select(2, UnitClass("player"));
	local classDB = Root.Database.Get("trainer", myClass);

	if ( not classDB ) then return; end

	local i;
	for i=1, #classDB do
		local skillInfo = classDB[i];
		if ( skillInfo.level ) and ( skillInfo.level == level ) then
			tinsert(self.list, skillInfo);
		end
	end
end

-- --------------------------------------------------------------------
-- **							Handlers							**
-- --------------------------------------------------------------------

Trainer.OnStart = function(self)
	self.list = { };
end

Trainer.OnTrainerVisit = function(self)
	if IsTradeskillTrainer() then return; end

	-- Reveal all available services by nullifying the filter

	local availableStatus   = GetTrainerServiceTypeFilter("available");
	local unavailableStatus = GetTrainerServiceTypeFilter("unavailable");
	local alreadyStatus	 = GetTrainerServiceTypeFilter("used");

	SetTrainerServiceTypeFilter("available", 1);
	SetTrainerServiceTypeFilter("unavailable", 1);
	SetTrainerServiceTypeFilter("used", 1);

	-- Expand all (done by default).

		--changed from ExpandTrainerSkillLine(0);

	-- Prepare database update

	local myClass = select(2, UnitClass("player"));
	local classDB = Root.Database.Get("trainer", myClass) or { };

	local wowVersion = select(1, GetBuildInfo());
	if ( not classDB.version ) or ( classDB.version ~= wowVersion ) then
		wipe(classDB);
		classDB.version = wowVersion;
		classDB.lookup = { };
	end

	-- Now grab infos

	local i, name, rank, category, expanded, classTree;

	for i=1, GetNumTrainerServices() do
		name, rank, category, expanded = GetTrainerServiceInfo(i);
		classTree = GetTrainerServiceSkillLine(i);
		--_, _, rank = string.find(rank, "(%d+)");
		rank = tonumber(rank) or 0;
		if ( category ~= "header" and classTree ) then
			local reqLevel = GetTrainerServiceLevelReq(i) or 0;
			if ( reqLevel > 0 ) then
				-- Potential skill.
					print(name);
				local lookupString = name.."|"..rank;
				if ( not classDB.lookup[lookupString] ) then
					local num = #classDB+1;
					classDB[num] = {name = name, rank = rank, tree = classTree, level = reqLevel};
					classDB.lookup[lookupString] = num;
				end
			end
		end
	end

	-- Terminate database update

	Root.Database.Set("trainer", myClass, classDB);

	-- Restore old filters

	SetTrainerServiceTypeFilter("available", 1);
	SetTrainerServiceTypeFilter("unavailable", 1);
	SetTrainerServiceTypeFilter("used", 1);
end
