local Root = CoolLevelUp;

Root["Spell"] = { };

local Spell = Root["Spell"];

-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --							GUI PART							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- **							 Locals							 **
-- --------------------------------------------------------------------

local HALO_TEXTURE = Root.folder.."gfx\\Halo";

local HALO_SIZE = 128;

local NUM_LETTER_CHECKS = 5;

local WRITE_COME_TIME = 0.300;
local WRITE_CLOSE_TIME = 0.300;

-- --------------------------------------------------------------------
-- **							 Methods							**
-- --------------------------------------------------------------------

-- ********************************************************************
-- * self:Set(line)												   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> self: the spell frame.										*
-- * >> line: the line in the spell box to use. 1-8.				  *
-- ********************************************************************
-- * Position a spell frame.										  *
-- ********************************************************************
local function Set(self, line)
	if type(self) ~= "table" then return; end

	local expectedSpells = self:GetParent().size or 0;
	if ( expectedSpells == 0 ) then return; end

	local chunkHeight = self:GetParent():GetHeight() / ( expectedSpells + 1);

	self.status = "STANDBY";
	self.timer = 0;
	self.text:SetText("");
	self.textString = "";
	self.textLength = 0;
	self.textCurrentString = "";
	self.duration = 0;

	self:SetPoint("LEFT", self:GetParent(), "TOPLEFT", 32, -(chunkHeight * line));

	self:Show();
	Spell.OnUpdate(self, 0);
end

-- ********************************************************************
-- * self:Remove()													*
-- ********************************************************************
-- * >> self: the spell frame.										*
-- ********************************************************************
-- * Stops display of a spell frame.								  *
-- ********************************************************************
local function Remove(self)
	if type(self) ~= "table" then return; end
	self:Hide();
end

-- ********************************************************************
-- * self:Write(text, duration)									   *
-- ********************************************************************
-- * >> self: the spell frame.										*
-- * >> text: the text to smoothly write.							 *
-- * >> duration: the time needed to write completely.				*
-- ********************************************************************
-- * Smoothly writes a text on the spell frame.					   *
-- ********************************************************************
local function Write(self, text, duration)
	if type(self) ~= "table" then return; end

	self.text:SetFont("Fonts\\SKURRI.TTF", 14, "OUTLINE")
	self.text:SetTextColor(1, 1, 1, 1);
	self.text:SetText(text);
	self.textLength = self.text:GetStringWidth();
	self.text:SetText("");
	self.textString = text;
	self.textCurrentString = "";
	self.duration = duration;

	self.status = "COMING";
	self.timer = WRITE_COME_TIME;
end

-- --------------------------------------------------------------------
-- **							 Handlers						   **
-- --------------------------------------------------------------------

function Spell.OnLoad(self)
	-- Children
	self.halo = self:CreateTexture(nil, "OVERLAY");
	self.halo:SetTexture(HALO_TEXTURE);
	self.halo:SetTexCoord(0, 1, 0, 1);
	self.halo:Show(); 
	self.text = self:CreateFontString(nil, "BORDER", "CoolLevelUp_SpellTextTemplate");
	self.text:SetPoint("LEFT", self, "LEFT", 0, 0);
	self.text:SetJustifyH("LEFT");
	self.text:SetJustifyV("MIDDLE");
	self.text:Show();

	-- Properties
	self.status = "STANDBY";
	self.timer = 0;
	self.duration = 0;
	self.textLength = 0;
	self.textString = "";
	self.textCurrentString = "";

	-- Methods
	self.Set = Set;
	self.Remove = Remove;
	self.Write = Write;
end

function Spell.OnUpdate(self, elapsed)
	if type(self) ~= "table" then return; end

	local haloAlpha = 1.00;
	local haloOffset = 0;
	local haloScale = 1.00;

	if ( self.status == "COMING" ) then
		self.timer = max(0, self.timer - elapsed);
		haloAlpha = 1 - self.timer / WRITE_COME_TIME;
		haloOffset = 0;
		if ( self.timer == 0 ) then
			self.status = "WRITING";
			self.timer = self.duration;
		end
elseif ( self.status == "WRITING" ) then
		self.timer = max(0, self.timer - elapsed);
		haloOffset = self.textLength * (1 - self.timer / self.duration);

		-- Advance partial text
		for i=1, NUM_LETTER_CHECKS do
			local currentLetter = #self.textCurrentString;
			if ( (currentLetter+1) <= #self.textString ) then
				local nextString = self.textCurrentString .. string.sub(self.textString, currentLetter+1, currentLetter+1);

				self.text:SetText(nextString);
				local newSize = self.text:GetStringWidth();

				if ( newSize <= haloOffset ) then
					self.textCurrentString = nextString;
			  else
					break;
				end
		  else
				self.textCurrentString = self.textString;
				break;
			end
		end
		self.text:SetText(self.textCurrentString);

		if ( self.timer == 0 ) then
			self.status = "CLOSING";
			self.timer = WRITE_CLOSE_TIME;
			self.text:SetText(self.textString);
		end
elseif ( self.status == "CLOSING" ) then
		self.timer = max(0, self.timer - elapsed);
		haloAlpha = self.timer / WRITE_CLOSE_TIME;
		haloOffset = self.textLength - self.textLength * ((self.timer - WRITE_CLOSE_TIME) / self.duration);
		if ( self.timer == 0 ) then
			self.status = "STANDBY";
		end
  else
		haloAlpha = 0;
	end

	haloScale = haloAlpha;

	self.halo:SetAlpha(haloAlpha);
	self.halo:SetWidth(HALO_SIZE * haloScale);
	self.halo:SetHeight(HALO_SIZE * haloScale);
	self.halo:ClearAllPoints();
	self.halo:SetPoint("CENTER", self, "LEFT", haloOffset, 0);
end