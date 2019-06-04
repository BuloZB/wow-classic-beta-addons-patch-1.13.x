--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	MyRolePlay.lua - Base functions to initialise the mrp table and a couple of frequently-used utility functions
]]

-- MyRolePlay: Detect any other MSP AddOn, and bail out in case of imminent conflict

-- Alert and bail if someone tries to load classic MRP in live WoW.
local displayBuild, _, _, interfaceVersionNumber = GetBuildInfo()

if interfaceVersionNumber > 20000 then
	error(([[This version of MyRolePlay only supports *CLASSIC* servers, but you are attempting to run it on live servers, patch %s.

	Please obtain the live version of MyRolePlay from Curse.]]):format(displayBuild))
	return
end

mrp = {}

mrp.Version = GetAddOnMetadata( "MyRolePlay", "Version" )
mrp.Build = tonumber( strmatch( mrp.Version, "%d+%.%d+%.%d+%.(%d+)" ) )
mrp.VersionString = "MyRolePlay/"..mrp.Version
mrp.Alpha = GetAddOnMetadata( "MyRolePlay", "X-Test" ) == "Alpha"
mrp.Beta = GetAddOnMetadata( "MyRolePlay", "X-Test" ) == "Beta"
mrp.Release = not GetAddOnMetadata( "MyRolePlay", "X-Test" )
mrp.Debug = false
mrp.DebugMSP = false
mrp.VerInfo = format( "%s%s", 
	mrp.Alpha and "|cffff7722Alpha|r " or mrp.Beta and "|cff77eeaaBeta|r " or 
	IsGMClient() and "|cff00b3ff<GM>|r " or "" , mrp.Version )
mrp.VerText = "MyRolePlay |cff996622Classic|r " .. mrp.VerInfo
mrp.WoWVer = format( "%s.%s", GetBuildInfo() )
if GetCVar("portal") == "public-test" then mrp.WoWVer = mrp.WoWVer .. " (PTR)" end
mrp.WoWBuild = tonumber((select(2, GetBuildInfo())))
mrp.WoWTOC = tonumber((select(4, GetBuildInfo())))

if _G.msp_RPAddOn then
	mrp.AbortLoad = true
	StaticPopupDialogs[ "MRP_MSP_CONFLICT" ] = {
		text = format( "ERROR: You can only use one MSP AddOn at once, but you have both MyRolePlay and %s loaded.\n\nAll MSP AddOns can communicate with each other, but please do not try to use more than one at once as conflicts will arise.", tostring(_G.msp_RPAddOn) or "another MSP AddOn" ),
		button1 = OKAY or "OK",
		whileDead = true,
		timeout = 0,
	}
	StaticPopup_Show( "MRP_MSP_CONFLICT" )
end 
_G.msp_RPAddOn = "MyRolePlay"

-------------------------------
-- Addons that break us
-------------------------------
if(IsAddOnLoaded("AddonSkins") and tonumber(GetAddOnMetadata("AddonSkins", "Version")) <= 3.91) then -- Older versions of this addon were incompatible so we'll leave this for a little while until people upgrade. (Only blocks old versions)
	if AddOnSkins then
		local AS = unpack(AddOnSkins)
		AS:UnregisterSkin('MyRolePlay')
	end
end

function mrp_dummyfunction()
end

function mrp:Print( ... )
	DEFAULT_CHAT_FRAME:AddMessage( "|cffA050D0MyRolePlay: |r" .. format(...) )
end

function mrp:DebugSpam( ... )
	if not mrp.Debug then return end
	DEFAULT_CHAT_FRAME:AddMessage( "|cff403850MRPDebug: |cffa070d0" .. format(...) )
end

function mrp:UnitNameWithRealm( unit )
        local name, realm = UnitName(unit)
        if type(realm) == "nil" then
                realm = GetRealmName():gsub("%s+", "")
        end
        if type(name) ~= "nil" then
                return name.."-"..realm
        else
                return nil
        end
end