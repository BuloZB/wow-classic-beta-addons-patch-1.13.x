--[[
	MyRolePlay 4 (C) 2010-2019 Etarna Moonshyne <etarna@moonshyne.org>, Katorie @ Moon Guard
	Licensed under GNU General Public Licence version 2 or, at your option, any later version

	ChatName.lua - Use MSP names in RP channels in chat
]]

local strsub, format, select = strsub, format, select

local RAID_CLASS_COLORS_CODE = setmetatable( {}, { __index = function( table, key )
	table[ key ] = RAID_CLASS_COLORS[ key ] and format( "|cff%02x%02x%02x", RAID_CLASS_COLORS[ key ].r * 255, RAID_CLASS_COLORS[ key ].g * 255, RAID_CLASS_COLORS[ key ].b * 255 ) or ""
	return table[ key ]
end } )

local RPEVENTS = {};

function MRP_Refresh_RPChats()
	table.wipe(RPEVENTS)
	if(mrpSaved.Options.RPChatSay == true) then
		RPEVENTS["CHAT_MSG_SAY"] = true;
	end
	if(mrpSaved.Options.RPChatWhisper == true) then
		RPEVENTS["CHAT_MSG_WHISPER"] = true;
		RPEVENTS["CHAT_MSG_WHISPER_INFORM"] = true;
	end
	if(mrpSaved.Options.RPChatEmote == true) then
		RPEVENTS["CHAT_MSG_EMOTE"] = true;
		RPEVENTS["CHAT_MSG_TEXT_EMOTE"] = true;
	end
	if(mrpSaved.Options.RPChatYell == true) then
		RPEVENTS["CHAT_MSG_YELL"] = true;
	end
	if(mrpSaved.Options.RPChatParty == true) then
		RPEVENTS["CHAT_MSG_PARTY"] = true;
		RPEVENTS["CHAT_MSG_PARTY_LEADER"] = true;
	end
	if(mrpSaved.Options.RPChatRaid == true) then
		RPEVENTS["CHAT_MSG_RAID"] = true;
		RPEVENTS["CHAT_MSG_RAID_LEADER"] = true;
	end
end

local function mrp_GetColoredName( event, message, sender, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, lineid, guid)
	if RPEVENTS[ event ] and sender and sender ~= "" and sender ~= UNKNOWN and msp.char[ sender ].supported and msp.char[ sender ].field.NA and mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) ~= "" and mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) ~= sender then
		if ChatTypeInfo[ strsub( event, 10 ) or "" ] and guid ~= "" then
			if(mrpSaved.Options.ShowIconsInChat == true) then -- Toggle for showing icons beside player name in chat.
				return format( "%s%s%s|r", mrp:WrapIconFilename(msp.char[sender].field.IC, 15, 15), RAID_CLASS_COLORS_CODE[ ( select( 2, GetPlayerInfoByGUID( guid ) ) ) ], mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) )
			else
				return format( "%s%s|r", RAID_CLASS_COLORS_CODE[ ( select( 2, GetPlayerInfoByGUID( guid ) ) ) ], mrp.DisplayChat.NA( msp.char[ sender ].field.NA ) )
			end
		end
	else
		return mrp_Prehook_GetColoredName( event, message, sender, language, arg4, arg5, arg6, arg7, arg8, arg9, arg10, lineid, guid )
	end
end

function mrp:HookChatName()
    local ElvUIChatModule -- ElvUI workaround for not showing RP chat name / colour
    local ElvUIGetColoredName
    if ElvUI then
        ElvUIChatModule = ElvUI[1]:GetModule("Chat", true)
        if ElvUIChatModule then
            ElvUIGetColoredName = ElvUIChatModule.GetColoredName
        end
    end
    if(mrp.ColourFunction == "ElvUI") then
        mrp_Prehook_GetColoredName = function(...) return ElvUIGetColoredName(ElvUIChatModule, ...) end
        ElvUI[1]:GetModule("Chat", true).GetColoredName = function(...) return mrp_GetColoredName(select(2, ...)) end
    else
        mrp_Prehook_GetColoredName = GetColoredName
        GetColoredName = mrp_GetColoredName
    end
end

function mrp:UnhookChatName()
    if(mrp.ColourFunction == "ElvUI") then
        ElvUI[1]:GetModule("Chat", true).GetColoredName = function(self, ...) return mrp_Prehook_GetColoredName(...) end
    else
        GetColoredName = mrp_Prehook_GetColoredName
    end
end