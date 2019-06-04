local Root = CoolLevelUp;

Root["Arrow"] = { };

local Arrow = Root["Arrow"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local DISPLAY_TIME = 0.200;
local REMOVE_TIME  = 0.500;

local UP_TEXTURE = Root.folder.."gfx\\ArrowUp";
local DOWN_TEXTURE = Root.folder.."gfx\\ArrowDown";
local FLASH_TEXTURE = Root.folder.."gfx\\Halo";

local JUMP_RATE = 0.050;

local JUMP_TABLE = {
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 0,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 0,
	[9] = 1,
	[10] = 2,
	[11] = 3,
	[12] = 4,
	[13] = 5,
	[14] = 6,
	[15] = 5,
	[16] = 4,
	[17] = 3,
	[18] = 4,
	[19] = 5,
	[20] = 6,
	[21] = 5,
	[22] = 4,
	[23] = 3,
	[24] = 2,
	[25] = 1,
};

local FLASH_TIME = 1.000;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(direction, text[, uptime])						  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the arrow.											  *
-- * >> direction: either "UP" or "DOWN".							 *
-- * >> text: text to display on the right of the arrow.			  *
-- * >> uptime: if set, it defines the amount of time (in sec) the	*
-- * arrow will be up till disapparearing by itself.				  *
-- ********************************************************************
-- * Starts displaying an arrow.									  *
-- ********************************************************************
local function Display(self, direction, text, uptime)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "OPENING";
	self.timer = DISPLAY_TIME;
	self.direction = direction;
	self.uptime = uptime;
	self.flashTimer = FLASH_TIME;

	if ( direction == "DOWN" ) then
		self.texture:SetTexture(DOWN_TEXTURE);
  else
		self.texture:SetTexture(UP_TEXTURE);
	end
	self.texture:SetTexCoord(0, 1, 0, 1);

	self.text:SetText(text);

	self:Show();
	Arrow.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove(atOnce)											  *
-- ********************************************************************
-- * >> self: the arrow.											  *
-- * >> atOnce: hide instantly the arrow?							 *
-- ********************************************************************
-- * Stops display of an arrow.									   *
-- ********************************************************************
local function Remove(self, atOnce)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "OPENING" and self.status ~= "RUNNING" and not atOnce ) then return; end

	if ( not atOnce ) then
		self.status = "CLOSING";
		self.timer = REMOVE_TIME;
  else
		self.status = "STANDBY";
		self.timer = 0;
		self:Hide();
	end
end

-- ********************************************************************
-- * self:ChangeOffset(offset)										*
-- ********************************************************************
-- * >> self: the arrow.											  *
-- * >> offset: desired offset (16 by default).					   *
-- ********************************************************************
-- * Changes the offset of the arrow from the center of the hole.	 *
-- ********************************************************************
local function ChangeOffset(self, offset)
	if type(self) ~= "table" then return; end

	self.offset = offset or 16;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Arrow.OnLoad(self)
	-- Children
	self.texture = self:CreateTexture(nil, "ARTWORK");
	self.texture:SetAllPoints(self); 
	self.texture:Show(); 
	self.text = self:CreateFontString(nil, "BORDER", "CoolLevelUp_ArrowTextTemplate");
	self.text:SetPoint("RIGHT", self, "LEFT", 2, 0);
	self.text:SetJustifyH("RIGHT");
	self.text:Show();
	self.flash = self:CreateTexture(nil, "OVERLAY");
	self.flash:SetTexture(FLASH_TEXTURE);
	self.flash:SetTexCoord(0, 1, 0, 1);
	self.flash:Hide();

	-- Properties
	self.status = "STANDBY";
	self.timer = 0.000;
	self.direction = "UP";
	self.flashTimer = 0.000;
	self.offset = 16;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;
	self.ChangeOffset = ChangeOffset;
end

function Arrow.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	if ( self.status == "STANDBY" ) then
		self:Hide();
		return;
	end

	local alpha = 1.00;

	if ( self.status == "OPENING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then
			self.status = "RUNNING";
		end
		alpha = 1 - self.timer / DISPLAY_TIME;

elseif ( self.status == "RUNNING" ) then
		if type(self.uptime) == "number" then
			self.uptime = max(0, self.uptime - elapsed);
			if ( self.uptime == 0 ) then
				self:Remove();
			end
		end

elseif ( self.status == "CLOSING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "STANDBY" end
		alpha = self.timer / REMOVE_TIME;
	end

	local flashAlpha = 1;
	if ( self.status ~= "OPENING" ) then
		self.flashTimer = max(0, self.flashTimer - elapsed);
		flashAlpha = self.flashTimer / FLASH_TIME;
	end
	if ( flashAlpha > 0 ) then self.flash:Show(); else self.flash:Hide(); end

	local duration = #JUMP_TABLE * JUMP_RATE;
	local frame = math.floor(math.fmod(GetTime(), duration) / duration * #JUMP_TABLE) + 1;

	local directionMod = 1;
	if ( self.direction == "DOWN" ) then directionMod = -1; end

	ofsY = 4 + (JUMP_TABLE[frame] or 0) * directionMod;

	self:SetAlpha(alpha);
	self:ClearAllPoints();
	self:SetPoint("CENTER", self:GetParent(), "CENTER", self.offset, ofsY);
	self.flash:SetPoint("CENTER", self:GetParent(), "CENTER", self.offset - 6, 4);
	self.flash:SetAlpha(flashAlpha);
	self.flash:SetWidth(64 * max(0.01, flashAlpha));
	self.flash:SetHeight(64 * max(0.01, flashAlpha));
end