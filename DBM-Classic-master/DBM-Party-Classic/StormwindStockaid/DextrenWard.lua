local mod	= DBM:NewMod("DextrenWard", "DBM-Party-Classic", 12)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(1663)

mod:RegisterCombat("combat")

--[[
mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 5246"
)

--TODO, get a valid spellID not used by friendly units
local warningFear			= mod:NewSpellAnnounce(5246, 2)

local timerFearCD			= mod:NewAITimer(180, 5246, nil, nil, nil, 3, nil, DBM_CORE_CURSE_ICON)

function mod:OnCombatStart(delay)
	timerFearCD:Start(1-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 5246 then
		warningFear:Show()
		timerFearCD:Start()
	end
end
--]]
