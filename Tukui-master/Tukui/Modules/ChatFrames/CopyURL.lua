local T, C, L = select(2, ...):unpack()

local TukuiChat = T["Chat"]
local gsub = gsub
local strsub = strsub

function TukuiChat:PrintURL(url)
	if C.Chat.LinkBrackets then
		url = T.RGBToHex(unpack(C.Chat.LinkColor)).."|Hurl:"..url.."|h["..url.."]|h|r "
	else
		url = T.RGBToHex(unpack(C.Chat.LinkColor)).."|Hurl:"..url.."|h"..url.."|h|r "
	end

	return url
end

function TukuiChat:FindURL(event, msg, ...)
	local NewMsg, Found = gsub(msg, "(%a+)://(%S+)%s?", TukuiChat:PrintURL("%1://%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = gsub(msg, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", TukuiChat:PrintURL("www.%1.%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = gsub(msg, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", TukuiChat:PrintURL("%1@%2%3%4"))

	if (Found > 0) then
		return false, NewMsg, ...
	end
end

function TukuiChat:EnableURL()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", TukuiChat.FindURL)
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", TukuiChat.FindURL) -- This event is removed
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", TukuiChat.FindURL) -- This event is removed
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", TukuiChat.FindURL)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", TukuiChat.FindURL)
	--ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", TukuiChat.FindURL) -- This event is removed

	local CurrentLink = nil
	local SetHyperlink = ItemRefTooltip.SetHyperlink

	ItemRefTooltip.SetHyperlink = function(self, data, ...)
		if (strsub(data, 1, 3) == "url") then
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()

			CurrentLink = (data):sub(5)

			if (not ChatFrameEditBox:IsShown()) then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end

			ChatFrameEditBox:Insert(CurrentLink)
			ChatFrameEditBox:HighlightText()
			CurrentLink = nil
		else
			SetHyperlink(self, data, ...)
		end
	end
end
