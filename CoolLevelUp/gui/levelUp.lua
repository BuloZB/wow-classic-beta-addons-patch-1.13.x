local Root = CoolLevelUp;

Root["LevelUp"] = { };

local LevelUp = Root["LevelUp"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local PARENT = WorldFrame;

local HALO_TEXTURE = Root.folder.."gfx\\Halo";

local textures = {
	[1] = Root.folder.."gfx\\LevelUpL1",
	[2] = Root.folder.."gfx\\LevelUpE1",
	[3] = Root.folder.."gfx\\LevelUpV",
	[4] = Root.folder.."gfx\\LevelUpE2",
	[5] = Root.folder.."gfx\\LevelUpL2",
	[6] = Root.folder.."gfx\\LevelUpU",
	[7] = Root.folder.."gfx\\LevelUpP",
};

local lettersOffset = {
	[1] = 0,
	[2] = 32,
	[3] = 64,
	[4] = 96,
	[5] = 128,
	[6] = 192,
	[7] = 224,
}

-- In sec.
local JUMP_DURATION = 1.500;
local CLOSE_TIME = 1.000;

-- Normalised value between 0.000 and 1.000.
local LETTER_ANIM_DURATION = 0.500;

local INITIAL_SCALE = 0.800;
local INITIAL_HALO_SCALE = 0.200;


-- Increase in scale by sec.
local SCALE_RATE = 0.100;
local HALO_SCALE_RATE = 0.150;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Display(holdTime)										   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the Level Up anim frame.								*
-- * >> holdTime: the amount of timde the Level Up message will stay  *
-- * still, slowly zooming in till fading away.					   *
-- ********************************************************************
-- * Starts displaying the Level Up animation.						*
-- ********************************************************************
local function Display(self, holdTime)
	if type(self) ~= "table" then return; end
	if ( self.status ~= "STANDBY" and self.status ~= "CLOSING" ) then return; end

	self.status = "JUMPING";
	self.timer = JUMP_DURATION;
	self.holdTime = holdTime;
	self.scale = INITIAL_SCALE;
	self.haloScale = INITIAL_HALO_SCALE;

	self:Show();
	LevelUp.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the Level Up anim frame.								*
-- ********************************************************************
-- * Stops the Level Up animation.									*
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

function LevelUp.OnLoad(self)
	-- Children
	self.halo = self:CreateTexture(nil, "BACKGROUND");
	self.halo:SetPoint("CENTER", self, "CENTER", 0 , 0);
	self.halo:SetTexture(HALO_TEXTURE);
	self.halo:SetTexCoord(0, 1, 0, 1);
	self.halo:Show(); 

	local i;
	self.letters = { };
	for i=1, #textures do
		self.letters[i] = self:CreateTexture(nil, "ARTWORK");
		self.letters[i]:SetWidth(32);
		self.letters[i]:SetHeight(64);
		self.letters[i]:SetTexture(textures[i]);
		self.letters[i]:SetTexCoord(0, 1, 0, 1);
		self.letters[i]:SetAlpha(0);
	end

	-- Properties
	self.status = "STANDBY";
	self.timer = 0;
	self.holdTime = 0;
	self.scale = 1;
	self.haloScale = 1;

	-- Methods
	self.Display = Display;
	self.Remove = Remove;

	-- Fixed position
	self:SetPoint("CENTER", PARENT, "CENTER", 0, 0);

	-- Greater draw priority
	self:SetFrameLevel(self:GetFrameLevel()+5);
end

function LevelUp.OnUpdate(self, elapsed)
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
			letterJumpOffset = 32 - cos(letterProgression * 360) * 32;
			self.letters[i]:SetAlpha(min(1, letterProgression / 0.200));
			self.letters[i]:SetPoint("LEFT", self, "LEFT", lettersOffset[i], letterJumpOffset - 16);
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
	self.haloScale = self.haloScale + HALO_SCALE_RATE * elapsed;
	self.halo:SetAlpha(min(1, self.haloScale - INITIAL_HALO_SCALE));
	self.halo:SetWidth(256 * self.haloScale);
	self.halo:SetHeight(256 * self.haloScale);
	self:SetAlpha(alpha);
	self:SetScale(self.scale);
end