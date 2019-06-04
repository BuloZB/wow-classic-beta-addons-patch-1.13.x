local mod	= DBM:NewMod("DeathSpeakerJargba", "DBM-Party-Classic", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4428)
--mod:SetEncounterID(438)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 14515",
	"SPELL_AURA_APPLIED 14515"
)

local warningMC				= mod:NewTargetNoFilterAnnounce(14515, 4)

local timerMCCD				= mod:NewAITimer(180, 14515, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerMCCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 14515 then
		timerMCCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 14515 then
		warningMC:Show(args.destName)
	end
end
