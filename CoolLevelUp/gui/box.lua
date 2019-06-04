local Root = CoolLevelUp;

local Engine = Root.GetOrNewModule("Engine");

Root["Box"] = { };

local Box = Root["Box"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local PARENT = WorldFrame;

local TEXTURE = Root.folder.."gfx\\StatsBox";

-- In sec.
local OPEN_TIME  = 1.000;
local CLOSE_TIME = 0.500;

-- Position info
local POSITION_X = 0.25;
local POSITION_Y = 0.48;
local INITIAL_Y = -0.1;

local NUM_HOLES = 8;

local STAT_UPDATE_RATE = 0.400;
local ARROW_HOLD_TIME = 8.000;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display()												   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the box frame.										  *
-- ********************************************************************
-- * Starts displaying the box frame.								 *
-- ********************************************************************
local function Display(self)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "OPENING";
	self.timer = OPEN_TIME;
	self.currentStat = nil;

	self:Show();
	Box.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the box frame.										  *
-- ********************************************************************
-- * Stops displaying the box frame.								  *
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "OPENING" and self.status ~= "RUNNING" ) then return; end

	self.status = "CLOSING";
	self.timer = CLOSE_TIME;
	self.currentStat = nil;
end

-- ********************************************************************
-- * self:SetStats(oldStats, newStats)								*
-- ********************************************************************
-- * >> self: the box frame.										  *
-- * >> oldStats: the table containing all old stats.				 *
-- * >> newStats: the table containing all new stats.				 *
-- ********************************************************************
-- * Set the stats inside the box.									*
-- ********************************************************************
local function SetStats(self, oldStats, newStats)
	if type(self) ~= "table" then return; end

	local k, v;
	for k, v in ipairs(self.stats) do self.stats[k] = nil; end

	local i;
	for i=1, Engine:GetNumStats() do
		local name = Engine:GetStatInfo(i);
		if ( oldStats[name] and newStats[name] and newStats[name] > 0 and name ~= "level" ) then
			self.stats[#self.stats+1] = {
				name = name,
				value = oldStats[name],
			};
		end
	end

	-- Prepare the hole
	for i=1, NUM_HOLES do
		local myStat = self.stats[i];
		if ( myStat ) then
			self.holes[i]:Set(math.fmod(i-1, 4)+1, math.floor((i-1)/4)+1, Root.Localise(myStat.name), myStat.value);
			if ( myStat.name == "hp" or myStat.name == "mp" ) then
				-- Special fix
				self.holes[i]:GetArrow():ChangeOffset(6);
			end
		else
			self.holes[i]:Remove();
		end
	end
end

-- ********************************************************************
-- * self:UpdateStats(changeTable, statsTable[, table], callback)	 *
-- ********************************************************************
-- * >> self: the box frame.										  *
-- * >> changeTable: the table containing the changes.				*
-- * >> statsTable: the table containing all new stats.			   *
-- * >> table: in case callback is a method, the object.			  *
-- * >> callback: the callback function.							  *
-- ********************************************************************
-- * Updates stats in a nice manner. Issue a callback when finished.  *
-- ********************************************************************
local function UpdateStats(self, changeTable, statsTable, table, callback)
	if type(self) ~= "table" then return; end
	if type(self.stats) ~= "table" then return; end

	self.currentStat = 0;
	self.nextStatTimer = 0;
	self.changeTable = changeTable;
	self.newStats = statsTable;
	self.object = table;
	self.callback = callback;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Box.OnLoad(self)
	-- Children
	self.texture = self:CreateTexture(nil, "BACKGROUND");
	self.texture:SetAllPoints(self);
	self.texture:SetTexture(TEXTURE);
	self.texture:SetTexCoord(0, 1, 0, 1);
	self.texture:Show(); 

	local i;
	self.holes = { };
	for i=1, NUM_HOLES do
		self.holes[i] = CreateFrame("Frame", nil, nil, "CoolLevelUp_HoleTemplate");
		self.holes[i]:SetParent(self);
	end

	-- Properties
	self.status = "STANDBY";
	self.timer = 0.000;
	self.stats = { };
	self.currentStat = nil;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;
	self.SetStats = SetStats;
	self.UpdateStats = UpdateStats;
end

function Box.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	if ( self.status == "STANDBY" ) then
		self:Hide();
		return;
	end

	local adjX, adjY = POSITION_X, POSITION_Y;

	if ( self.status == "OPENING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "RUNNING"; end
		adjY = INITIAL_Y + (POSITION_Y - INITIAL_Y) * (1 - (self.timer / OPEN_TIME)^2);

elseif ( self.status == "CLOSING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "STANDBY" end
		adjY = INITIAL_Y + (POSITION_Y - INITIAL_Y) * ((self.timer / CLOSE_TIME)^0.5);
	end

	if ( self.currentStat ) then
		self.nextStatTimer = max(0, self.nextStatTimer - elapsed);
		if ( self.nextStatTimer == 0 ) then
			self.nextStatTimer = STAT_UPDATE_RATE;
			self.currentStat = self.currentStat + 1;
			if ( self.currentStat > #self.stats ) or ( self.currentStat > NUM_HOLES ) then
				self.currentStat = nil;
				self.callback(self.object);
			else
				local statName = self.stats[self.currentStat].name;
				local statChange = self.changeTable[statName];

				if ( statChange > 0 ) then
					Root.Sound.Play("STAT_UP");
					self.holes[self.currentStat]:Blink(true);
					self.holes[self.currentStat]:GetArrow():Display("UP", statChange, ARROW_HOLD_TIME);
				elseif ( statChange < 0 ) then
					Root.Sound.Play("STAT_UP");
					self.holes[self.currentStat]:GetArrow():Display("DOWN", statChange, ARROW_HOLD_TIME);
				else
					self.nextStatTimer = 0;
				end

				self.holes[self.currentStat]:ChangeValue(self.newStats[statName]);
			end
		end
	end

	self:ClearAllPoints();
	self:SetPoint("CENTER", PARENT, "BOTTOMLEFT", adjX * PARENT:GetWidth(), adjY * PARENT:GetHeight());
end