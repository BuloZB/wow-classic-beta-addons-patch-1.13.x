local mod	= DBM:NewMod("LadySerevess", "DBM-Party-Classic", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(4831)
--mod:SetEncounterID(1667)

mod:RegisterCombat("combat")
