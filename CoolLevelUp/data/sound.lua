local Root = CoolLevelUp;

Root.Sound = { };

local Sound = Root["Sound"];

Sound.folder = Root.folder.."sfx\\";

-- --------------------------------------------------------------------
-- **							 Data							   **
-- --------------------------------------------------------------------

local sounds = {
	["LEVEL_CHANGE"] = "LevelChange.ogg",
	["STAT_UP"] = "StatUp.ogg",
	["NEW_SKILL"] = "NewSkill.ogg",
};

-- --------------------------------------------------------------------
-- **							  API							   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * Root -> Sound -> Play(name)									  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> name: the name of the sound to start, from the list above.	*
-- ********************************************************************
-- * Plays a sound. Note that SFX playback cannot be stopped.		 *
-- * If it is not found or for some reason can't be played, nil is	*
-- * returned; 1 elsewise is.										 *
-- ********************************************************************
function Root.Sound.Play(name)
	local filename = sounds[name];
	if ( filename ) then
		return PlaySoundFile(Sound.folder..filename);
	end
	return nil;
end