local Root = CoolLevelUp;

Root["Hole"] = { };

local Hole = Root["Hole"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local TEXTURE = Root.folder.."gfx\\StatHole";
local TEXTURE_GREEN = Root.folder.."gfx\\StatHoleGreen";

local BLINK_SPEED = 0.750; -- Per sec.

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Set(line, column, name, value)							  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the hole.											   *
-- * >> line: the line in the box to use. 1-4.						*
-- * >> column: the column to use. 1-2.							   *
-- * >> name: the name of the stat.								   *
-- * >> value: the value of the stat.								 *
-- ********************************************************************
-- * Starts displaying a hole in a box frame.						 *
-- ********************************************************************
local function Set(self, line, column, name, value)
	if type(self) ~= "table" then return; end

	self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 16 + (column-1) * 128, -24 - (line-1) * 24);

	self.text:SetText(name);
	self.value:SetText(value);

	self.isBlinking = false;
	self.blinkValue = 0.000;
	self.blinkDirection = "SHOW";

	-- When set (again), we hide the hole's arrow till it is needed.
	self:GetArrow():Remove(true);

	self:Show();
	Hole.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the hole.											   *
-- ********************************************************************
-- * Stops display of a hole.										 *
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	self:Hide();
end

-- ********************************************************************
-- * self:Blink(flag)												 *
-- ********************************************************************
-- * >> self: the hole.											   *
-- * >> flag: if set, start the blinking, if not, stop it.			*
-- ********************************************************************
-- * Makes a hole blink in green.									 *
-- ********************************************************************
local function Blink(self, flag)
	if type(self) ~= "table" then return; end
	self.isBlinking = flag;
end

-- ********************************************************************
-- * self:ChangeValue(value)										  *
-- ********************************************************************
-- * >> self: the hole.											   *
-- * >> value: the new value.										 *
-- ********************************************************************
-- * Changes the value.											   *
-- ********************************************************************
local function ChangeValue(self, value)
	if type(self) ~= "table" then return; end
	self.value:SetText(value);
end

-- ********************************************************************
-- * self:GetArrow()												  *
-- ********************************************************************
-- * >> self: the hole.											   *
-- ********************************************************************
-- * Get the arrow frame attached to a hole frame.					*
-- ********************************************************************
local function GetArrow(self)
	if type(self) ~= "table" then return; end
	return self.arrow;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Hole.OnLoad(self)
	-- Children
	self.texture = self:CreateTexture(nil, "BACKGROUND");
	self.texture:SetAllPoints(self);
	self.texture:SetTexture(TEXTURE);
	self.texture:SetTexCoord(0/128, 96/128, 0, 1);
	self.texture:Show(); 
	self.greenTexture = self:CreateTexture(nil, "ARTWORK");
	self.greenTexture:SetAllPoints(self);
	self.greenTexture:SetTexture(TEXTURE_GREEN);
	self.greenTexture:SetTexCoord(0/128, 96/128, 0, 1);
	self.greenTexture:SetAlpha(0);
	self.arrow = CreateFrame("Frame", nil, nil, "CoolLevelUp_ArrowTemplate");
	self.arrow:SetParent(self);

	self.text = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_NameTextTemplate");
	self.text:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 2, 0);
	self.text:SetJustifyH("LEFT");
	self.text:Show();
	self.value = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_StatTextTemplate");
	self.value:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
	self.value:SetJustifyH("RIGHT");
	self.value:Show();

	-- Properties
	self.isBlinking = false;
	self.blinkValue = 0.000;
	self.blinkDirection = "SHOW";

	-- Methods
	self.Set = Set;
	self.Remove = Remove;
	self.Blink = Blink;
	self.ChangeValue = ChangeValue;
	self.GetArrow = GetArrow;
end

function Hole.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	if ( not self.isBlinking ) or ( self.blinkDirection == "HIDE" ) then
		self.blinkValue = max(0, self.blinkValue - BLINK_SPEED * elapsed);
		if ( self.blinkValue == 0 ) and ( self.isBlinking ) then
			self.blinkDirection = "SHOW";
		end
  else
		self.blinkValue = min(1, self.blinkValue + BLINK_SPEED * elapsed);
		if ( self.blinkValue == 1 ) then
			self.blinkDirection = "HIDE";
		end
	end

	self.greenTexture:SetAlpha(self.blinkValue);
end