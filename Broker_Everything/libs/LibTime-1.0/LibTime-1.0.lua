
--[[
Name: LibTime-1.0
Revision: $Revision: 5 $
Author: Hizuro (hizuro@gmx.net)
Description: A little library around date, time and GetGameTime and more...
Dependencies: LibStub
License: GPL v3
]]

local MAJOR, MINOR = "LibTime-1.0", 5;
local lib = LibStub:NewLibrary(MAJOR, MINOR);

if not lib then return; end

local GetGameTime, date, time, _G = GetGameTime, date, time, _G;
local hms,hm = "%02d:%02d:%02d","%02d:%02d";
local realmTime,minute = false,nil;
local playedTimeout, playedHide = 12, false;
local playedTotal, playedLevel, playedSession = 0, 0, false;
local suppressAllPlayedMsgs = false;
local events = {};

lib.countryLocalizedNames = {}; -- filled by localizations_(.*).lua *** this table is temporary and will be nil after VARIABLES_LOADED ***

local countryNames = {};
local countries = {
	"Afghanistan;4.5;0","Alaska;-9;1","Arabian;3;0","Argentina;-3;0","Armenia;4;1","Australian Central;9.5;1","Australian Eastern;10;1",
	"AustralianWestern;8;0","Azerbaijan;4;1","Azores;-1;1","Bangladesh;6;0","Bhutan;6;0","Bolivia;-4;0","Brazil;-3;0","Brunei;8;0","Cape Verde;-1;0",
	"Central Africa;2;0","Central Brazilian;-4;1","Central European;1;1","Central Greenland;-3;1","Central Indonesian;8;0","Chamorro;10;0","Chile;-4;1",
	"China;8;0","Christmas Island;7;0","Chuuk;10;0","Cocos Islands;6.5;0","Colombia;-5;0","Cook Islands;-10;0","East Africa;3;0","Eastern;-5;1",
	"Eastern European;2;1","Eastern Indonesian;9;0","Eastern Kazakhstan;6;0","East Greenland;-1;1","East Timor;9;0","Ecuador;-5;0","Falkland Island;-4;0",
	"Fernando de Noronha;-2;0","Fiji;12;1","French Guiana;-3;0","Galapagos;-6;0","Georgia;4;0","Germany;1;1","Gilbert Island;12;0","Greenwich Mean;0;1",
	"Gulf;4;0","Guyana;-4;0","Hawaii;-10;1","Hovd;7;0","Indian;5.5;0","Indochina;7;0","Iran;3.5;1","Irkutsk;9;0","Israel;2;1","Japan;9;0",
	"Kaliningrad;3;0","Korea;9;0","Krasnoyarsk;8;0","Kyrgyzstan;5;0","Magadan;12;0","Malaysia;8;0","Maldives;5;0","Marshall Islands;12;0","Mauritius;4;0",
	"Moscow;4;0","Mountain;-7;1","Myanmar;6.5;0","Nauru;12;0","Nepal;5.75;0","New Caledonia;11;0","Newfoundland;-3.5;1","New Zealand;12;1","Niue;-11;0",
	"Norfolk;11.5;0","Omsk;7;0","Pacific;-8;1","Pakistan;5;0","Palau;9;0","Papua New Guinea;10;0","Paraguay;-4;1","Peru;-5;0","Philippine;8;0",
	"Pierre & Miquelon;-3;1","Ponape;11;0","Reunion;4;0","Seychelles;4;0","Singapore;8;0","Solomon Islands;11;0","South Africa;2;0","Sri Lanka;5.5;0",
	"Suriname;-3;0","Tahiti;-10;0","Tajikistan;5;0","Tokelau;13;0","Tonga;13;0","Turkmenistan;5;0","Tuvalu;12;0","Ulaanbaatar;8;0","Uruguay;-3;1",
	"US Central Standart Time (CST);-6;1","Uzbekistan;5;0","Vanuatu;11;0","Venezuela;-4.5;0","Vladivostok;11;0","Wallis & Futuna;12;0","West Africa;1;1",
	"Western European;0;1","Western Indonesian;7;0","Western Kazakhstan;5;0","West Samoa;13;1","Yakutsk;10;0","Yap;10;0","Yekaterinburg;6;0"
};


--[[ internal event and update functions ]]--

local chatFrames = false;
local function toggleChatFramesTimePlayedMsgEvent()
	if not chatFrames then
		chatFrames = {};
		for i=1, 10 do
			local frame = _G["ChatFrame"..i];
			if _G["ChatFrame"..i] and _G["ChatFrame"..i].messageTypeList then
				for _, group in ipairs(_G["ChatFrame"..i].messageTypeList) do
					if group=="SYSTEM" then
						_G["ChatFrame"..i]:UnregisterEvent("TIME_PLAYED_MSG");
						tinsert(chatFrames,i);
					end
				end
			end
		end
	else
		for i=1, #chatFrames do
			if _G["ChatFrame"..chatFrames[i]] then
				_G["ChatFrame"..chatFrames[i]]:RegisterEvent("TIME_PLAYED_MSG");
			end
		end
	end
end

local function playedTimeoutFunc()
	if not playedTimeout then
		return;
	end
	playedHide = true;
	RequestTimePlayed();
end

local function realmTimeSyncTickerFunc()
	local hours, minutes, seconds = GetGameTime();
	if minute~=minutes then
		minute = nil;
		local t = date("*t");
		t.hour,t.min,t.sec = hours,minutes,0;
		realmTime = time() - time(t);
		realmTimeSyncTicker:Cancel();
	end
end

function events.VARIABLES_LOADED()
	for index,data in ipairs(countries) do
		local name,shift,dst = strsplit(";",data);
		countries[index] = {name=lib.countryLocalizedNames[name] or name,timeshift=tonumber(shift),dst=dst==1};
		countryNames[index] = lib.countryLocalizedNames[name] or name;
	end
	lib.countryLocalizedNames = nil; -- one table with names is enough ;)
	UIParent:RegisterEvent("TIME_PLAYED_MSG");
end

function events.PLAYER_LOGIN()
	local hours, minutes, seconds = GetGameTime();
	playedSession = time();
	if tonumber(seconds) then
		-- YEAH! Surprise! GetGameTime returns time "with seconds"... [maybe in future? ^_^]
		realmTimeSyncTickerFunc = nil;
		lib.GetGameTime = GetGameTime;
	else
		minute = minutes;
		realmTimeSyncTicker = C_Timer.NewTicker(0.5,realmTimeSyncTickerFunc);
	end
	toggleChatFramesTimePlayedMsgEvent();
	if playedTimeout then
		C_Timer.After(playedTimeout,playedTimeoutFunc);
	end
end

function events.TIME_PLAYED_MSG(...)
	playedTimeout, playedTotal, playedLevel = false, ...;
	if not suppressAllPlayedMsgs and chatFrames then
		toggleChatFramesTimePlayedMsgEvent();
	end
end

UIParent:HookScript("OnEvent",function(self,event,...)
	if events[event] then
		events[event](...);
		events[event]=nil;
	end
end);


--[[ library functions ]]--

--- GetGameTime
-- @return hours, minutes, seconds, boolSecondsSynced
function lib.GetGameTime(inSeconds)
	if realmTime then
		local t = time()-realmTime;
		if inSeconds==true then
			return t,(minute==nil);
		end
		local t = {strsplit(":",date("%H:%M:%S",t))};
		return tonumber(t[1]),tonumber(t[2]),tonumber(t[3]),(minute==nil);
	end
	if inSeconds==true then
		return time();
	end
	return lib.GetLocalTime();
end


--- GetLocalTime
-- @return hours, minutes, seconds
function lib.GetLocalTime()
	local t = {strsplit(":",date("%H:%M:%S"))};
	return tonumber(t[1]),tonumber(t[2]),tonumber(t[3]);
end


--- GetUTCTime
-- @param inSeconds [bool]
-- @return hours, minutes, seconds
function lib.GetUTCTime(inSeconds)
	if inSeconds==true then
		return time(date("!*t"));
	end
	local t = {strsplit(":",date("!%H:%M:%S"))};
	return tonumber(t[1]),tonumber(t[2]),tonumber(t[3]);
end


--- GetCountryTime
-- @param country [string|number]
-- @param inSeconds [bool]
-- @return hour, minute, second, country name
function lib.GetCountryTime(countryId,inSeconds)
	assert(countryId and countries[countryId], "usage: <LibTime-1.0>.GetCountryTime(<iCountryId>[,<bInSeconds>])");
	local country = countries[countryId];
	local t = lib.GetUTCTime(true);
	local l = date("*t");
	if (l.isdst==true and country.dst==0) then
		t = t - 3600;
	elseif (l.isdst==false and country.dst==1) then
		t = t + 3600;
	end
	t = t+(3600*country.timeshift);
	if inSeconds==true then
		return t, country.name;
	end
	local H,M,S = date("%H:%M:%S",t);
	return tonumber(H), tonumber(M), tonumber(S), country.name;
end


--- ListCountries - plain list of countries. table index corresponding with neccessary countryId in other functions of this library
-- @return [table]
function lib.iterateCountryList()
	return ipairs(countryNames);
end


--- GetPlayedTime
-- @return playedTotal, playedLevel, playedSession
function lib.GetPlayedTime()
	local session = time()-playedSession;
	if (playedTotal) then
		return playedTotal+session, playedLevel+session, session;
	end
	return 0, 0, session;
end


--- GetTimeString
-- @param name of time   <GameTime|LocalTime|UTCTime|CountryTime>
-- @param 24hours        [boolean] - optional, default = true
-- @param displaySeconds [boolean] - optional, default = false
-- @param countryId      [number]  - only for use with GetCountryTime
function lib.GetTimeString(name,b24hours,displaySeconds,countryId)
	assert(lib["Get"..name],"Usage: <LibTime-1.0>.GetTimeString(<GameTime|LocalTime|UTCTime|CountryTime>[,<b24hours>[,<bDisplaySeconds>[,<iCountryId>]]])");
	local h,m,s,synced = lib["Get"..name](countryId);
	local suffix = "";
	if (b24hours~=true) then
		h,suffix = tonumber(h), " "..TIMEMANAGER_AM;
		if h >= 12 then
			h,suffix = h-12," "..TIMEMANAGER_PM;
		end
	end
	if (displaySeconds==true) then
		if name=="GameTime" and not synced then
			suffix = ":−−"..suffix;
		else
			return hms:format(h,m,s)..suffix;
		end
	end
	return hm:format(h,m)..suffix;
end


--- SuppressAllPlayedForSeconds
-- @param seconds [number] - time in seconds from login to suppress all played time messages
function lib.SuppressAllPlayedForSeconds(seconds)
	if (type(seconds)=="number") then
		suppressAllPlayedMsgs = seconds;
		local since = time()-(playedSession or 0);
		if since<seconds then
			C_Timer.After(seconds-since+15,function()
				if chatFrame then
					toggleChatFramesTimePlayedMsgEvent();
				end
			end);
		end
	end
end
