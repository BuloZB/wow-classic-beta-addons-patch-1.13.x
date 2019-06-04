local mod	= DBM:NewMod("BloodmageThalnos", "DBM-Party-Classic", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4543)
--mod:SetEncounterID(585)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 8814"
)

local warningFlameSpike				= mod:NewSpellAnnounce(8814, 2)

local timerFlameSpikeCD				= mod:NewAITimer(180, 8814, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerFlameSpikeCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 8814 then
		warningFlameSpike:Show()
		timerFlameSpikeCD:Start()
	end
end
