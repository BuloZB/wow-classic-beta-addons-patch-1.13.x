local mod	= DBM:NewMod("Roogug", "DBM-Party-Classic", 10)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(6168)
--mod:SetEncounterID(438)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 8270"
)

local warningSummonEarthRumbler		= mod:NewSpellAnnounce(8270, 2)

local timerSummonEarthRumblerCD		= mod:NewAITimer(180, 8270, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

function mod:OnCombatStart(delay)
	timerSummonEarthRumblerCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 8270 then
		warningSummonEarthRumbler:Show()
		timerSummonEarthRumblerCD:Start()
	end
end
