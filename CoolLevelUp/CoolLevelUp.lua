-- --------------------------------------------------------------------
-- ////////////////////////////////////////////////////////////////////
-- --						   INSTALLER							--
-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- --------------------------------------------------------------------

-- /!\ This file has to be loaded first.

CoolLevelUp = { };

local Root = CoolLevelUp;

-- Global stuff
Root.folder = "Interface\\AddOns\\CoolLevelUp\\";
Root.version = 4;

Root.Modules = { };

-- --------------------------------------------------------------------
-- **							Functions						   **
-- --------------------------------------------------------------------

-- ********************************************************************
-- * Root -> GetOrNewModule(moduleName)							   *
-- ********************************************************************
-- * Arguments:													   *
-- * >> moduleName: the name of the module.						   *
-- ********************************************************************
-- * Gets an existing module's table object or create it if it does   *
-- * not exist. Whatever this function does, it'll return the table.  *
-- ********************************************************************
function Root.GetOrNewModule(moduleName)
	if type(moduleName) ~= "string" then return; end
	local module = Root.Modules;
	if type(module[moduleName]) == "table" then return module[moduleName]; end
	module[moduleName] = { };
	return module[moduleName];
end

-- ********************************************************************
-- * Root -> InvokeHandler(handlerName, ...)						  *
-- ********************************************************************
-- * Arguments:													   *
-- * >> handlerName: the name of the handler to call.				 *
-- * >> ...: arguments to pass to the handler.						*
-- ********************************************************************
-- * Invoke a given handler on all registered modules.				*
-- ********************************************************************
function Root.InvokeHandler(handlerName, ...)
	if type(handlerName) ~= "string" then return; end
	local k, v;
	for k, v in pairs(Root.Modules) do
		if type(v) == "table" then
			if type(v[handlerName]) == "function" then
				v[handlerName](v, ...);
			end
		end
	end
end

-- ********************************************************************
-- * Root -> Test(level)											  *
-- * /run CoolLevelUp.Test(level)									 *
-- ********************************************************************
-- * Arguments:													   *
-- * >> level: the level the fake Level Up is supposed to get you to. *
-- ********************************************************************
-- * Makes CoolLevelUp believes you have gained a level.			  *
-- ********************************************************************
function Root.Test(level)
	local changeTable = { level = level or 70, hp = 142, mp = 84, tp = 1,
						  str = 5, agi = 3, stm = -3, int = 0, spi = 7 };
	Root.InvokeHandler("OnLevelUp", changeTable);
end

-- ********************************************************************
-- * Root -> ClearDB()												*
-- ********************************************************************
-- * Arguments:													   *
-- *	<none>														*
-- ********************************************************************
-- * Clear the whole database. For development/debug purposes.		*
-- ********************************************************************
function Root.ClearDB()
	Root.Database.Clear();
end

-- --------------------------------------------------------------------
-- **							Handlers							**
-- --------------------------------------------------------------------

function Root.OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("UNIT_DISPLAYPOWER");
	self:RegisterEvent("TRAINER_SHOW");
end

function Root.OnEvent(self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		Root.OnStart();
		Root.InvokeHandler("OnStart");
		return;
	end
	if ( event == "PLAYER_LEVEL_UP" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...;
		local changeTable = { level = arg1, hp = arg2, mp = arg3, tp = arg4,
							  str = arg5, agi = arg6, stm = arg7, int = arg8, spi = arg9 };
		Root.InvokeHandler("OnLevelUp", changeTable);
		return;
	end
	if ( event == "PLAYER_REGEN_DISABLED" ) then
		Root.InvokeHandler("OnEnterCombat");
		return;
	end
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		Root.InvokeHandler("OnLeaveCombat");
		return;
	end
	if ( event == "TRAINER_SHOW" ) then
		Root.InvokeHandler("OnTrainerVisit");
		return;
	end
end

function Root.OnUpdate(self, elapsed)
	Root.InvokeHandler("OnUpdate", elapsed);
end

function Root.OnStart()
	Root.Database.CheckVersion();
end