print("BÄM-Mod Classic geladen")
local frame = CreateFrame("FRAME");
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
frame:SetScript("OnEvent", function(self, event)

--[[START CONFIG]]--
--hier Schwellwert für Ansage anpassen
--adjust amount for announcements here
local CritAmountDmg = 1000
local CritAmountHeal = 1000

--Ausgabe Damage (1 = Alle; 2 = persönlich)
--Output Damage (1 = everyone; 2 = personal)
local EveryoneGitInHereDmg = 1
--Ausgabe Heals (1 = Alle; 2 = persönlich)
--Output Heals (1 = everyone; 2 = personal)
local EveryoneGitInHereHeal = 1

--hier Ausgabekanal angeben (möglich: YELL, SAY, PARTY, GUILD, RAID, RAID_WARNING, EMOTE)
--adjust Chatchannel here (possible: YELL, SAY, PARTY, GUILD, RAID, RAID_WARNING, EMOTE)
local OutputChannel = "YELL"

--hier kann die angezeigte Meldung angepasst werden
--adjust Chatmessage here (spellname and amount are always displayed)
local OutputMessageDmg = "BÄM dicker Crit!"
local OutputMessageHeal = "Saved another ass!"
--[[END CONFIG]]--

--ab hier nur die Funktion

  local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = select(12, CombatLogGetCurrentEventInfo())
  local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  local playerGUID = UnitGUID("player")
  if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		-- critical damage from spells/abilities
		if (type == "SPELL_DAMAGE") and critical and (sourceGUID == playerGUID) then
			if amount >= CritAmountDmg then
				if EveryoneGitInHereDmg == 1 then
					SendChatMessage(OutputMessageDmg.." | "..spellName.." - "..format_thousand(amount), OutputChannel ,nil);
				else
					print(OutputMessageDmg.." | "..spellName.." - "..format_thousand(amount))
				end
			end
		end
		-- critical heals
		critical = select(18,CombatLogGetCurrentEventInfo())
		if (type == "SPELL_HEAL") and critical and (sourceGUID == playerGUID) then
			if amount >= CritAmountHeal then
				if EveryoneGitInHereHeal == 1 then
					SendChatMessage(OutputMessageHeal.." | "..destName.." - "..spellName.." - "..format_thousand(amount), OutputChannel ,nil);
				else
					print(OutputMessageHeal.." | "..destName.." with "..spellName.." for "..format_thousand(amount))
				end
			end
		end
  end
end);
--format the numbers
function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
    .. string.gsub(string.sub(s, pos+1), "(...)", ".%1")
end