local mod = DBM:NewMod("Bloodlord", "DBM-ZG", 1)
local L = mod:GetLocalizedStrings()

mod:SetRevision(("$Revision$"):sub(12, -3))

mod:SetCreatureID(11382, 14988)
mod:SetEncounterID(787)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 24314 24318 16856"
)

--TODO, actual timer for abilities. Tank swap for mortal?
local warnFrenzy	= mod:NewSpellAnnounce(24318, 3, nil, "Tank|Healer")
local warnGaze		= mod:NewTargetNoFilterAnnounce(24314, 2)
local warnMortal	= mod:NewTargetNoFilterAnnounce(16856, 2, nil, "Tank|Healer")

local timerGaze 	= mod:NewTargetTimer(6, 24314, nil, nil, nil, 3)
local timerMortal	= mod:NewTargetTimer(5, 16856, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(24314) then
		warnGaze:Show(args.destName)
		timerGaze:Start(args.destName)
	elseif args:IsSpellID(24318) then
		warnFrenzy:Show(args.destName)
	elseif args:IsSpellID(16856) and args:IsDestTypePlayer() then
		warnMortal:Show(args.destName)
		timerMortal:Start(args.destName)
	end
end

