local mod	= DBM:NewMod("Herod", "DBM-Party-Classic", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3975)
--mod:SetEncounterID(585)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 13736"
)

local specWarnWhirlwind				= mod:NewSpecialWarningRun(13736, nil, nil, nil, 4, 2)

local timerWhirlwindCD				= mod:NewAITimer(180, 13736, nil, nil, nil, 4, nil, DBM_CORE_DEADLY_ICON)

function mod:OnCombatStart(delay)
	timerWhirlwindCD:Start(1-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 8040 then
		specWarnWhirlwind:Show()
		specWarnWhirlwind:Play("justrun")
		timerWhirlwindCD:Start()
	end
end
