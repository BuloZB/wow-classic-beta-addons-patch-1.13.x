local Root = CoolLevelUp;

Root["Header"] = { };

local Header = Root["Header"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local PARENT = WorldFrame;

local TEXTURE = Root.folder.."gfx\\LevelBox";
local FLASH = Root.folder.."gfx\\Halo";

-- In sec.
local OPEN_TIME  = 1.000;
local CLOSE_TIME = 0.500;
local FLASH_TIME = 2.000;

-- Position info
local POSITION_X = 0.25;
local POSITION_Y = 0.6;
local INITIAL_X = -0.1;

local VALUE_HEIGHT = 14;
local VALUE_HEIGHT_ZOOM = 38;
local CHANGE_VALUE_HOLD_TIME = 0.500;
local CHANGE_VALUE_SHRINK_TIME = 0.250;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(text, value)										*
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the header frame.									   *
-- * >> text: the header text to display.							 *
-- * >> value: the value next to the header text.					 *
-- ********************************************************************
-- * Starts displaying the header frame.							  *
-- ********************************************************************
local function Display(self, text, value)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "OPENING";
	self.timer = OPEN_TIME;

	self.text:SetFont("Fonts\\SKURRI.TTF", 14, "OUTLINE")
	self.text:SetText(text);
	self.value:SetText(value);
	self.valueHoldTime = 0;
	self.valueShrinkTime = 0;

	self:Show();
	Header.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the header frame.									   *
-- ********************************************************************
-- * Stops displaying the header frame.							   *
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "OPENING" and self.status ~= "RUNNING" ) then return; end

	self.status = "CLOSING";
	self.timer = CLOSE_TIME;
end

-- ********************************************************************
-- * self:ChangeValue(value)										  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the header frame.									   *
-- * >> value: the new value.										 *
-- ********************************************************************
-- * Starts displaying the header frame.							  *
-- ********************************************************************
local function ChangeValue(self, value)
	if type(self) ~= "table" then return; end

	self.valueHoldTime = CHANGE_VALUE_HOLD_TIME;
	self.valueShrinkTime = CHANGE_VALUE_SHRINK_TIME;
	self.value:SetText(value);
	self.value:SetTextHeight(VALUE_HEIGHT_ZOOM);

	self.flashTimer = FLASH_TIME;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Header.OnLoad(self)
	-- Children
	self.texture = self:CreateTexture(nil, "BACKGROUND");
	self.texture:SetAllPoints(self);
	self.texture:SetTexture(TEXTURE);
	self.texture:SetTexCoord(38/256, 218/256, 0, 1);
	self.texture:Show(); 
	self.text = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_HeaderTextTemplate");
	self.text:SetPoint("LEFT", self, "LEFT", 16, 0);
	self.text:SetJustifyH("LEFT");
	self.text:Show();
	self.value = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_ValueTextTemplate");
	self.value:SetPoint("CENTER", self, "RIGHT", -24, 0);
	self.value:Show();
	self.valueHoldTime = 0;
	self.valueShrinkTime = 0;
	self.flash = self:CreateTexture(nil, "OVERLAY");
	self.flash:SetWidth(128);
	self.flash:SetHeight(128);
	self.flash:SetTexture(FLASH);
	self.flash:SetTexCoord(0, 1, 0, 1);
	self.flash:SetPoint("CENTER", self.value, "CENTER", 0, 0);
	self.flash:Hide();

	-- Properties
	self.status = "STANDBY";
	self.timer = 0.000;
	self.flashTimer = 0.000;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;
	self.ChangeValue = ChangeValue;
end

function Header.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	if ( self.status == "STANDBY" ) then
		self:Hide();
		return;
	end

	local adjX, adjY = POSITION_X, POSITION_Y;

	if ( self.status == "OPENING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "RUNNING"; end
		adjX = INITIAL_X + (POSITION_X - INITIAL_X) * (1 - (self.timer / OPEN_TIME)^2);

	elseif ( self.status == "CLOSING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "STANDBY" end
		adjX = INITIAL_X + (POSITION_X - INITIAL_X) * ((self.timer / CLOSE_TIME)^0.5);
	end

	if ( self.valueHoldTime > 0 ) then
		self.valueHoldTime = self.valueHoldTime - elapsed;
	elseif ( self.valueShrinkTime > 0 ) then
		self.valueShrinkTime = max(0, self.valueShrinkTime - elapsed);
		self.value:SetTextHeight(VALUE_HEIGHT_ZOOM - (VALUE_HEIGHT_ZOOM - VALUE_HEIGHT) * (1 - self.valueShrinkTime / CHANGE_VALUE_SHRINK_TIME));
	else
		self.value:SetTextHeight(VALUE_HEIGHT);
	end

	if ( self.flashTimer > 0.000 ) then
		self.flash:Show();
		self.flashTimer = max(0, self.flashTimer - elapsed);
		self.flash:SetAlpha(self.flashTimer / FLASH_TIME);
	else
		self.flash:Hide();
	end

	self:ClearAllPoints();
	self:SetPoint("CENTER", PARENT, "BOTTOMLEFT", adjX * PARENT:GetWidth(), adjY * PARENT:GetHeight());
end