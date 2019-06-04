local Root = CoolLevelUp;

Root.Music = { };

local Music = Root["Music"];

Music.folder = Root.folder.."bgm\\";

-- --------------------------------------------------------------------
-- **							 Data							   **
-- --------------------------------------------------------------------

local musics = {
	["MINOR_LEVELUP"] = "NoNewSpell.ogg",
	["MAJOR_LEVELUP"] = "NewSpells.ogg",
	["CRITICAL_LEVELUP"] = "NewTier.ogg",
	["FINAL_LEVELUP"] = "AlmostDone.ogg",
};

-- --------------------------------------------------------------------
-- **							  API							   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * Root -> Music -> Play(name)									  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> name: the name of the music to start, from the list above.	*
-- ********************************************************************
-- * Plays a music.												   *
-- * If it is not found or for some reason can't be played, nil is	*
-- * returned; 1 elsewise is.										 *
-- ********************************************************************
function Root.Music.Play(name)
	local filename = musics[name];
	if ( filename ) then
		return PlayMusic(Music.folder..filename);
	end
	return nil;
end

-- ********************************************************************
-- * Root -> Music -> Stop()										  *
-- ********************************************************************
-- * Arguments:													   *
-- * N/A															  *
-- ********************************************************************
-- * Stops the currently played music.								*
-- ********************************************************************
function Root.Music.Stop()
	StopMusic();
end