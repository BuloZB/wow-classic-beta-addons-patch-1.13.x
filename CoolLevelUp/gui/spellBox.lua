local Root = CoolLevelUp;

Root["SpellBox"] = { };

local SpellBox = Root["SpellBox"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local PARENT = WorldFrame;

local EDGE_TEXTURE = Root.folder.."gfx\\NewSpellEdge";
local TILE_TEXTURE = Root.folder.."gfx\\NewSpellTile";

-- In sec.
local OPEN_TIME  = 1.000;
local CLOSE_TIME = 0.500;

-- Position info
local POSITION_X = 0.75;
local POSITION_Y = 0.50;
local INITIAL_Y = 1.4;

local MAX_SPELLS = 16;
local BIG_PARCHMENT_THRESHOLD = 8;

local SPELL_UPDATE_RATE = 0.800;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(numNewSpells)									   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the spell box frame.									*
-- * >> numNewSpells: the number of new spell, to resize the frame.   *
-- ********************************************************************
-- * Starts displaying the spell box frame.						   *
-- ********************************************************************
local function Display(self, numNewSpells)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "OPENING";
	self.timer = OPEN_TIME;
	self.size = min(MAX_SPELLS, numNewSpells);
	self.currentSpell = nil;

	if ( numNewSpells >= BIG_PARCHMENT_THRESHOLD ) then
		self:SetHeight(512);
	elseif ( numNewSpells >= 4 ) then
		self:SetHeight(256);
	elseif ( numNewSpells >= 3 ) then
		self:SetHeight(172);
	elseif ( numNewSpells <= 2 ) then
		self:SetHeight(128);
	end

	-- Reposition spell frame.
	local i;
	for i=1, MAX_SPELLS do
		if ( i <= numNewSpells ) then
			self.spells[i]:Set(i);
	  else
			self.spells[i]:Remove(i);
		end
	end

	self:Show();
	SpellBox.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the spell box frame.									*
-- ********************************************************************
-- * Stops displaying the spell box frame.							*
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "OPENING" and self.status ~= "RUNNING" ) then return; end

	self.status = "CLOSING";
	self.timer = CLOSE_TIME;
	self.currentSpell = nil;
end

-- ********************************************************************
-- * self:WriteSpells(newSpells[, table], callback)				   *
-- ********************************************************************
-- * >> self: the spell box frame.									*
-- * >> table: in case callback is a method, the object.			  *
-- * >> callback: the callback function.							  *
-- ********************************************************************
-- * Write spells one by one in a nice manner in the spell box.	   *
-- * Issue a callback when finished.								  *
-- ********************************************************************
local function WriteSpells(self, newSpells, table, callback)
	if type(self) ~= "table" then return; end
	if type(newSpells) ~= "table" then return; end

	self.currentSpell = 0;
	self.nextSpellTimer = 0;
	self.newSpells = newSpells;
	self.object = table;
	self.callback = callback;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function SpellBox.OnLoad(self)
	-- Children
	self.text = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_TitleTextTemplate");
	self.text:SetPoint("BOTTOM", self, "TOP", 0, -2);
	self.text:SetJustifyH("MIDDLE");
	self.text:SetJustifyV("BOTTOM");
	self.text:SetText(Root.Localise("newskills"));
	self.text:Show();

	local i;
	self.spells = { };
	for i=1, MAX_SPELLS do
		self.spells[i] = CreateFrame("Frame", nil, nil, "CoolLevelUp_SpellTemplate");
		self.spells[i]:SetParent(self);
	end

	-- Backdrop
	local myBackdrop = { bgFile = TILE_TEXTURE,
						 edgeFile = EDGE_TEXTURE,
						 tileSize = 128,
						 edgeSize = 64,
						 tile = true,
						 insets = { left = 64, right = 64, top = 64, bottom = 64 } };
	self:SetBackdrop(myBackdrop);
	self:SetBackdropBorderColor(1.0, 1.0, 1.0, 0.75);
	self:SetBackdropColor(1.0, 1.0, 1.0, 0.75);

	-- Properties
	self.status = "STANDBY";
	self.timer = 0.000;
	self.size = 0;
	self.currentSpell = nil;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;
	self.WriteSpells = WriteSpells;
end

function SpellBox.OnUpdate(self, elapsed)
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

	if ( self.currentSpell ) then
		self.nextSpellTimer = max(0, self.nextSpellTimer - elapsed);
		if ( self.nextSpellTimer == 0 ) then
			self.nextSpellTimer = SPELL_UPDATE_RATE;
			self.currentSpell = self.currentSpell + 1;
			if ( self.currentSpell > #self.newSpells ) or ( self.currentSpell > MAX_SPELLS ) then
				self.currentSpell = nil;
				self.callback(self.object);
		  else
				Root.Sound.Play("NEW_SKILL");
				self.spells[self.currentSpell]:Write(self.newSpells[self.currentSpell], SPELL_UPDATE_RATE);
			end
		end
	end

	self:ClearAllPoints();
	self:SetPoint("CENTER", PARENT, "BOTTOMLEFT", adjX * PARENT:GetWidth(), adjY * PARENT:GetHeight());
end