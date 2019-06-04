local mod	= DBM:NewMod("Garr-Classic", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12057)--, 12099
mod:SetEncounterID(666)
mod:SetModelID(12110)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 15732",
	"SPELL_CAST_SUCCESS 19492"
)

local warnAntiMagicPulse	= mod:NewSpellAnnounce(19492, 2)
local warnImmolate			= mod:NewTargetNoFilterAnnounce(15732, 2, nil, "RemoveMagic|Healer", 2)

local timerAntiMagicPulseCD	= mod:NewCDTimer(16, 19492, nil, nil, nil, 2)--16-20 variation

function mod:OnCombatStart(delay)
	timerAntiMagicPulseCD:Start(10-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 15732 and self:IsInCombat() then
		warnImmolate:CombinedShow(1, args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19492 then
		warnAntiMagicPulse:Show()
		timerAntiMagicPulseCD:Start()
	end
end
