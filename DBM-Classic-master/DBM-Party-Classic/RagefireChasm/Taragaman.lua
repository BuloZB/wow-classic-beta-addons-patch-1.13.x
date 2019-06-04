local mod	= DBM:NewMod("Taragaman", "DBM-Party-Classic", 8)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(11520)
--mod:SetEncounterID(1446)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 18072 11970"
)

local warningUppercut			= mod:NewSpellAnnounce(18072, 3, nil, "Tank")
local warningFireNova			= mod:NewSpellAnnounce(11970, 3)

local timerUppercutCD			= mod:NewAITimer(180, 18072, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerFireNovaCD			= mod:NewAITimer(180, 11970, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)

function mod:OnCombatStart(delay)
	timerUppercutCD:Start(1-delay)
	timerFireNovaCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 18072 then
		warningUppercut:Show()
		timerUppercutCD:Start()
	elseif args.spellId == 11970 then
		warningFireNova:Show()
		timerFireNovaCD:Start()
	end
end
