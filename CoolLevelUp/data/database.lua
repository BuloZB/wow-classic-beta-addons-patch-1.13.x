local Root = CoolLevelUp;

Root.Database = { };

-- --------------------------------------------------------------------
-- **					   Setup stuff							  **
-- --------------------------------------------------------------------

local DATABASE_VERSION = 2;

local DatabaseGlobalName = "CoolLevelUp_Database";

setglobal(DatabaseGlobalName, {});
local Database = getglobal(DatabaseGlobalName);

-- --------------------------------------------------------------------
-- **				   Database functions						   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * Root -> Database -> Get(part, key)							   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> part: which side of DB the data to fetch is stored into.	  *
-- * >> key: what data to retrieve. If not found, nil is returned.	*
-- ********************************************************************
-- * Returns a value from the database. The database is conserved	 *
-- * between game sessions.										   *
-- ********************************************************************

function Root.Database.Get(part, key)
	if ( Database[part] ) then
		return Database[part][key] or nil;
	end
	return nil;
end

-- ********************************************************************
-- * Root -> Database -> Set(part, key, value)						*
-- ********************************************************************
-- * Arguments:													   *
-- * >> part: the side of DB the data to write will be stored into.   *
-- * >> key: where to store data.									 *
-- * >> value: self-explanatory.									  *
-- ********************************************************************
-- * Changes a value inside a database's key.						 *
-- ********************************************************************

function Root.Database.Set(part, key, value)
	if not ( Database[part] ) then Database[part] = {}; end
	Database[part][key] = value;
end

-- ********************************************************************
-- * Root -> Database -> CheckVersion()							   *
-- ********************************************************************
-- * Arguments:													   *
-- * None															 *
-- ********************************************************************
-- * Check database version is still the same. If it isn't, it means  *
-- * the structured data it contains are no longer compatible and	 *
-- * have to be deleted.											  *
-- ********************************************************************

function Root.Database.CheckVersion()
	Database = getglobal(DatabaseGlobalName);

	local currentVersion = Database.version;

	if not ( currentVersion ) then
		-- Database has been formatted. This should occur the first time the mod is run.
		Database = {
			version = DATABASE_VERSION,
		};
		setglobal(DatabaseGlobalName, Database);
		return nil;
  else
		if ( currentVersion ~= DATABASE_VERSION ) then
			-- We reformat database, version has changed.
			Database = {
				version = DATABASE_VERSION,
			};
			setglobal(DatabaseGlobalName, Database);
			return 1;
		end
	end

	return nil;
end

-- ********************************************************************
-- * Root -> Database -> Clear()									  *
-- ********************************************************************
-- * Arguments:													   *
-- * N/A															  *
-- ********************************************************************
-- * Clear the whole database and create an empty one.				*
-- ********************************************************************

function Root.Database.Clear()
	-- Nullifying version will cause a quiet reformat.
	Database.version = nil;
	Root.Database.CheckVersion();
end