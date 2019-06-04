--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	Init.lua - Initialisation functions
]]

local L = mrp.L

local strsplit = strsplit

BINDING_HEADER_MYROLEPLAY = L["MyRolePlay"]
BINDING_NAME_CHARACTER_SHEET = L["Browse Character Profile"]

-- Reset profiles to hard defaults, clearing everything
function mrp:HardResetProfiles()
	mrpSaved.SelectedProfile = "Default"

	-- Default Profile
	mrpSaved["Profiles"] = {
		["Default"] = {
			['NA'] = UnitName("player"),
		},
	}
end

-- Setup variables from mrpSaved
function mrp:Initialise()
	msp:AddFieldsToTooltip({'CO', 'RC', 'IC', 'RC', 'RS', 'TR'})
	if mrp.Initialised then return end

	if type(mrpSaved) ~= "table" then
		-- Fresh start: reset everything!
		mrpSaved = {
			["Build"] = mrp.Build,
			["Options"] = {},
			["Versions"] = {},
			["Positions"] = {},
		}
		for k, v in pairs( mrp.DefaultOptions ) do
			mrpSaved.Options[ k ] = v
		end
		mrp:HardResetProfiles( )
		mrp:Print("Welcome to MRP classic! If you haven't used the addon in a while, take some time to get familiar with the new fields and options. A couple features were removed from this version due to classic being incompatible.")
	end
	
	if type(mrpNotes) ~= "table" then
		mrpNotes = {}
	end

	if not mrpSaved.Build or mrpSaved.Build < mrp.Build then
		mrp:UpgradeSaved( mrpSaved.Build )
		mrpSaved.Build = mrp.Build
	end
	
	if not mrpLastViewedChangeLogBuild or mrpLastViewedChangeLogBuild < mrp.Build then
		mrp_FormatChangeLog() -- Setup and show changelog for a new version.
		MyRolePlayChangeLogFrame:Show();
		mrpLastViewedChangeLogBuild = mrp.Build
	end

	-- Selected profile safety net!
	if not mrpSaved.SelectedProfile or type(mrpSaved.Profiles[mrpSaved.SelectedProfile]) ~= "table" then
		mrpSaved.SelectedProfile = "Default"
	end

	-- Restore saved versions
	for field, ver in pairs( mrpSaved.Versions ) do
		msp.myver[ field ] = ver
	end

	mrp:SetCurrentProfile( )
	
	MRP_Refresh_RPChats() -- Setup the RPEVENTS table in ChatName.lua so we know what chats they've registered to show RP chat names in.

	mrp.Initialised = true

	mrp.UpgradeSaved = mrp_dummyfunction
	mrp.Initialise = mrp_dummyfunction
end

function mrp:OnEnable()
	if mrp.Enabled then return end

	mrp:RegisterChatCommand()
	mrp:CreateOptionsPanel()

	if mrpSaved.Options.Enabled==false then return end

	mrp:CreateCharacterFrame()
	mrp:CreateBrowseFrame()
	mrp:CreateGlanceFrame()
	mrp:CreateMRPButton()
	mrp:AddMRPTab()

	mrp:HookTooltip()
	mrp:HookTarget()
	if mrp.HookFormChange then mrp:HookFormChange() end
	if mrp.HookEquipSet then mrp:HookEquipSet() end
	if mrp.HookPredictive then mrp:HookPredictive() end
	if mrp.HookChatName then mrp:HookChatName() end

	msp.dummyframe:RegisterEvent( "CHAT_MSG_ADDON" )
	if mrp_MSPTooltipCallback then table.insert( msp.callback.received, mrp_MSPTooltipCallback ) end
	if mrp_MSPBrowserCallback then table.insert( msp.callback.received, mrp_MSPBrowserCallback ) end
	if mrp_MSPGlancePreviewCallback then table.insert( msp.callback.received, mrp_MSPGlancePreviewCallback ) end
	if mrp_MSPButtonCallback then table.insert( msp.callback.received, mrp_MSPButtonCallback ) end
	if mrp_MSPUpdateCallback then table.insert( msp.callback.received, mrp_MSPUpdateCallback ) end
	if mrp_MSPExchangeCallback then table.insert( msp.callback.received, mrp_MSPExchangeCallback ) end

	mrpSaved.Options.Enabled = true
	mrp.Enabled = true
	collectgarbage( "collect" )
end

function mrp:Enable()
	mrpSaved.Options.Enabled = true
	mrp:OnEnable()
end

local function tvanish( t, value )
	for k, v in ipairs( t ) do
		if v == value then
			table.remove( t, k )
			break
		end
	end
end

-- Disable the addon entirely, unregistering events and hooks and hiding the frames (we can't destroy)
function mrp:OnDisable()
	if not mrp.Enabled or mrpSaved.Options.Enabled==false then return end

	msp.dummyframe:UnregisterEvent( "CHAT_MSG_ADDON" )
	if mrp_MSPTooltipCallback then tvanish( msp.callback.received, mrp_MSPTooltipCallback ) end
	if mrp_MSPBrowserCallback then tvanish( msp.callback.received, mrp_MSPBrowserCallback ) end
	if mrp_MSPButtonCallback then tvanish( msp.callback.received, mrp_MSPButtonCallback ) end
	if mrp_MSPUpdateCallback then tvanish( msp.callback.received, mrp_MSPUpdateCallback ) end
	if mrp_MSPExchangeCallback then tvanish( msp.callback.received, mrp_MSPExchangeCallback ) end

	mrp:UnhookTooltip()
	mrp:UnhookTarget()
	if mrp.UnhookFormChange then mrp:UnhookFormChange() end
	if mrp.UnhookEquipSet then mrp:UnhookEquipSet() end
	if mrp.UnhookPredictive then mrp:UnhookPredictive() end
	if mrp.UnhookChatName then mrp:UnhookChatName() end

	mrp:RemoveMRPTab()

	MyRolePlayCharacterFrame:Hide()
	MyRolePlayButton:Hide()

	mrpSaved.Options.Enabled = false
	mrp.Enabled = false
end

function mrp:Disable()
	mrp:OnDisable()
end

-- Obviously, kind of a dangerous function. Not added to command line for safety.
function mrp:HardReset( really )
	if really then
		mrpSaved = nil
		mdbSaved = nil
		mrp:InitMRPSaved()
		mrp:Print( L["Hard reset! All profiles wiped, all settings returned to default."] )
		mrp:Print( L["Changes may not be visible for other users until they next disconnect or reload."] )
	else
		mrp:Print( L["Call /run mrp:HardReset(true) to delete ALL YOUR MRP PROFILES AND SETTINGS!"] )
	end
end

local elvAlreadyStopped = false;
local function Stop_Evil_ElvUI()

	if elvAlreadyStopped then return end

    --*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
    --Workaround to a certain UI wrecking our tooltips
    --*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
    if(ElvUI) then
        local E = unpack(ElvUI)
        local TT = E:GetModule("Tooltip")
        TT.RemoveTrashLines = function() return end
    end
    --*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
    --Workaround to the same certain UI wrecking our chat names
    --*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*
    local ElvUIGetColoredName
    if(ElvUI) then
        local ElvUIChatModule = ElvUI[1]:GetModule("Chat", true);
        local ElvUIGetColoredName
        if(ElvUIChatModule) then
            ElvUIGetColoredName = ElvUIChatModule.GetColoredName;
        end
        if(ElvUIGetColoredName) then
            mrp.ColourFunction = "ElvUI";
            if mrp.Enabled then mrp:HookChatName() end
        end
    end
	
	elvAlreadyStopped = true
end

local function mrp_InitEvent( this, event, addon )
	if event == "ADDON_LOADED" then
		if addon == "MyRolePlay" then
			mrp:Initialise()
		elseif addon == "ElvUI" then
            if not ElvUI[1].initialized then
				hooksecurefunc( ElvUI[1], "Initialize", Stop_Evil_ElvUI)
            else
                Stop_Evil_ElvUI()
            end
		end
	elseif event == "PLAYER_LOGIN" then
		mrp:Initialise()
		if ElvUI then
			if not ElvUI[1].initialized then
				hooksecurefunc( ElvUI[1], "Initialize", Stop_Evil_ElvUI)
            else
                Stop_Evil_ElvUI()
            end
		end
		mrp:OnEnable()
	end
end

local df = MyRolePlayDummyInitFrame or CreateFrame( "Frame", "MyRolePlayDummyInitFrame" )
df:SetScript( "OnEvent", mrp_InitEvent )
if mrp.AbortLoad then
	msp.dummyframe:UnregisterEvent( "CHAT_MSG_ADDON" )
else
	df:RegisterEvent( "ADDON_LOADED" )
	df:RegisterEvent( "PLAYER_LOGIN" )
end