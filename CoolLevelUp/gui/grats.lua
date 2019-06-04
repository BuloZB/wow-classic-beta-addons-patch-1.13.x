local Root = CoolLevelUp;

Root["Grats"] = { };

local Grats = Root["Grats"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local PARENT = WorldFrame;

local letters = { };	   -- Will be filled up with localized data.
local lettersOffset = { };

-- In sec.
local JUMP_DURATION = 2.000;
local CLOSE_TIME = 3.000;

-- Normalised value between 0.000 and 1.000.
local LETTER_ANIM_DURATION = 0.400;

local INITIAL_SCALE = 0.800;

-- Increase in scale by sec.
local SCALE_RATE = 0.050;

local LETTER_WIDTH = 20;
local LETTER_HEIGHT = 32;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(holdTime)										   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the congrats frame.									 *
-- * >> holdTime: the amount of time the grats message will stay	  *
-- * still, slowly zooming in till fading away.					   *
-- ********************************************************************
-- * Starts displaying the congratulations animation.				 *
-- ********************************************************************
local function Display(self, holdTime)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "JUMPING";
	self.timer = JUMP_DURATION;
	self.holdTime = holdTime;
	self.scale = INITIAL_SCALE;

	self:Show();
	Grats.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the congrats frame.									 *
-- ********************************************************************
-- * Stops the congratulations animation.							 *
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "JUMPING" and self.status ~= "HOLDING" ) then return; end

	self.status = "CLOSING";
	self.timer = CLOSE_TIME;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Grats.OnLoad(self)
	local i;

	-- Get translation
	local gratsMessage = Root.Localise("congratulations");
	for i=1, #gratsMessage do
		letters[i] = string.sub(gratsMessage, i, i);
		lettersOffset[i] = LETTER_WIDTH * (i-1);
	end
	self:SetWidth(#gratsMessage * LETTER_WIDTH);

	-- Children
	self.letters = { };
	for i=1, #letters do
		self.letters[i] = self:CreateFontString(nil, "OVERLAY", "CoolLevelUp_GratsTextTemplate");
		self.letters[i]:SetAlpha(0);
		self.letters[i]:SetText(string.gsub(letters[i], "@", "é")); -- Evil fix for frFR localisation.
		self.letters[i]:SetJustifyH("MIDDLE");
		self.letters[i]:SetTextHeight(LETTER_HEIGHT);
	end

	-- Properties
	self.status = "STANDBY";
	self.timer = 0;
	self.holdTime = 0;
	self.scale = 1;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;

	-- Fixed position
	self:SetPoint("CENTER", PARENT, "CENTER", 0, 0);

	-- Greater draw priority
	self:SetFrameLevel(self:GetFrameLevel()+4);
end

function Grats.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	if ( self.status == "STANDBY" ) then
		self:Hide();
		return;
	end

	local alpha = 1.00;

	if ( self.status == "JUMPING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then
			self.status = "HOLDING";
		end

		-- Update each letter.
		local i;
		local letterProgression, letterJumpOffset;
		local globalProgression = 1 - self.timer / JUMP_DURATION;
		local beginAnim, endAnim;

		for i=1, #self.letters do
			-- Determinate the progression, which is a bounded value between 0.000 and 1.000.
			beginAnim = (i-1) * ((1.0 - LETTER_ANIM_DURATION) / (#self.letters-1));
			endAnim = beginAnim + LETTER_ANIM_DURATION;
			letterProgression = ( globalProgression - beginAnim ) / ( endAnim - beginAnim);
			letterProgression = max(0.000, min(letterProgression, 1.000));

			-- Apply the progression on the letter
			letterJumpOffset = LETTER_HEIGHT - cos(letterProgression * 360) * LETTER_HEIGHT;
			self.letters[i]:SetAlpha(min(1, letterProgression / 0.200));
			self.letters[i]:SetPoint("CENTER", self, "LEFT", lettersOffset[i], letterJumpOffset - LETTER_HEIGHT/2);
		end

elseif ( self.status == "HOLDING" ) then
		self.holdTime = max(0, self.holdTime - elapsed);
		if ( self.holdTime == 0 ) then
			self:Remove();
		end

elseif ( self.status == "CLOSING" ) then
		self.timer = max(0, self.timer - elapsed);
		if ( self.timer == 0 ) then self.status = "STANDBY" end
		alpha = self.timer / CLOSE_TIME;
	end

	self.scale = self.scale + SCALE_RATE * elapsed;
	self:SetAlpha(alpha);
	self:SetScale(self.scale);
end