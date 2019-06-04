local mod	= DBM:NewMod("DeathswornCaptain", "DBM-Party-Classic", 15)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(3872)

mod:RegisterCombat("combat")
