local mod	= DBM:NewMod("HoundmasterLoksey", "DBM-Party-Classic", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3974)
--mod:SetEncounterID(585)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 6742"
)

local warningEnrage			= mod:NewTargetNoFilterAnnounce(6742, 2)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 6742 then
		warningEnrage:Show(args.destName)
	end
end
