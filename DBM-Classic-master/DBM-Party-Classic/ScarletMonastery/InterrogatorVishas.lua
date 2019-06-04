local mod	= DBM:NewMod("Vishas", "DBM-Party-Classic", 11)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3983)
--mod:SetEncounterID(585)

mod:RegisterCombat("combat")
