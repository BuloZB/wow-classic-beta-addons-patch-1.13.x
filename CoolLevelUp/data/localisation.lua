local Root = CoolLevelUp;

-- --------------------------------------------------------------------
-- **					 Localisation data						  **
-- --------------------------------------------------------------------

local MISSING_TRANSLATION = "%s"; -- Leave this one in English.

local modLocale = {
	["default"] = {
		["rank"] = "Rank",
		["newskills"] = "New Skills Available",
		["congratulations"] = "Congratulations!",

		["hp"] = "HP",
		["mp"] = "MP",
		["tp"] = "TP",
		["str"] = "Str.",
		["agi"] = "Agi.",
		["stm"] = "Stam.",
		["int"] = "Intel.",
		["spi"] = "Spi.",
	},

	["frFR"] = {
		["rank"] = "Rang",
		["newskills"] = "Capacités disponibles",
		["congratulations"] = "F@licitations!",

		["hp"] = "PV",
		["mp"] = "PM",
		["tp"] = "PT",
		["str"] = "For.",
		["agi"] = "Agi.",
		["stm"] = "Endu.",
		["int"] = "Intel.",
		["spi"] = "Esp.",
	},
	
	["deDE"] = {
		["rank"] = "Rang",
		["newskills"] = "Neue Fähigkeiten verfügbar",
		["congratulations"] = "Gratulation!",

		["hp"] = "HP",
		["mp"] = "MP",
		["tp"] = "TP",
		["str"] = "Str.",
		["agi"] = "Bew.",
		["stm"] = "Ausd.",
		["int"] = "Intel.",
		["spi"] = "Wille",
	},
};

-- --------------------------------------------------------------------
-- **					Localisation functions					  **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * Root -> Localise(key, noError)								   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> key: what to localise. If not found on the correct locale,	*
-- * will use default value. If there is no default value, this	   *
-- * function will return formatted MISSING_TRANSLATION.			  *
-- * >> noError: if set and the localisation is not available, this   *
-- * function will return nil instead of missing translation.		 *
-- ********************************************************************

function Root.Localise(key, noError)
	local locale = modLocale[GetLocale()];
	local defaultlocale = modLocale["default"];

	if ( locale ) and ( locale[key] ) then
		return locale[key];
  else
		if ( defaultlocale ) and ( defaultlocale[key] ) then
			return defaultlocale[key];
		end
	end

	if ( noError ) then return nil; end

	return string.format(MISSING_TRANSLATION, key);
end

-- ********************************************************************
-- * Root -> Unlocalise(translation)								  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> translation: translation thing to unlocalise.				 *
-- * If there is an error, <translation> value will be returned.	  *
-- ********************************************************************

function Root.Unlocalise(translation)
	local locale = modLocale[GetLocale()];
	local defaultlocale = modLocale["default"];
	local k, t;

	if ( locale ) then
		for k, t in pairs(locale) do
			if ( t == translation ) then
				return k;
			end
		end
	end

	if ( defaultlocale ) then
		for k, t in pairs(defaultlocale) do
			if ( t == translation ) then
				return k;
			end
		end
	end

	return translation;
end

-- ********************************************************************
-- * Root -> FormatLoc(key, ...)									  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> key: what to localise. If not found on the correct locale,	*
-- * will use default value. If there is no default value, this	   *
-- * function will return formatted MISSING_TRANSLATION.			  *
-- * >> ...: the arguments to pass to the format function.			*
-- ********************************************************************
-- * This acts like Localise, but it passes the localised string to a *
-- * format function, using parameters sent with "..." holder.		*
-- ********************************************************************

function Root.FormatLoc(key, ...)
	local localisation = Root.Localise(key, 1);
	if ( localisation ) then
		return string.format(localisation, ...);
  else
		return string.format(MISSING_TRANSLATION, key);
	end
end
