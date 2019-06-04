local mod	= DBM:NewMod(422, "DBM-Party-Classic", 5, 231)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7800)
mod:SetEncounterID(382)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 10101 11130 11518 11521 11798 11524 11526 11527"
)

local warningKnockAway			= mod:NewSpellAnnounce(10101, 2)
local warningActivateBomb		= mod:NewSpellAnnounce(11518, 2)

local timerKnockAwayCD			= mod:NewAITimer(180, 10101, nil, nil, nil, 2)

function mod:OnCombatStart(delay)
	timerKnockAwayCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCESS(args)
	if args.spellId == 10101 or args.spellId == 11130 then
		warningKnockAway:Show()
		timerKnockAwayCD:Start()
	elseif (args.spellId == 11518 or args.spellId == 11521 or args.spellId == 11798 or args.spellId == 11524 or args.spellId == 11526 or args.spellId == 11527) and self:AntiSpam(3, 1) then
		warningActivateBomb:Show()
	end
end