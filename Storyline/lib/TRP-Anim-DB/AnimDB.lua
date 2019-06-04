----------------------------------------------------------------------------------
-- Total RP 3: Animations DB
-- ---------------------------------------------------------------------------
-- Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
----------------------------------------------------------------------------------

local MAJOR, MINOR = "TRP-Dialog-Animation-DB", 2

---@class TRPDialogAnimationDB
local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then return end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Animations durations
-- This section contains a DB of animations duration for all playable races/sex and some NPC.
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- 193 : levitate
-- 195 : /train
-- 225 : /fear
-- 520 : read
-- 66 : /bow
-- 67 : /hi
-- 113 : /salute
-- 209 : /point
-- 61 : /eat
-- 63 : /use
-- 68 : /acclame

local CHAR_TO_ID = {
	HUMAN = {
		FEMALE = "1000764",
		MALE = "1011653",
	},
	NIGHT_ELF = {
		FEMALE = "921844",
		MALE = "974343",
	},
	DWARF = {
		FEMALE = "950080",
		MALE = "878772",
	},
	GNOME = {
		FEMALE = "940356",
		MALE = "900914",
	},
	DRAENEI = {
		FEMALE = "1022598",
		MALE = "1005887",
	},
	WORGEN = {
		FEMALE = "307453",
		MALE = "307454",
	},
	PANDAREN = {
		FEMALE = "589715",
		MALE = "535052",
	},
	ORC = {
		FEMALE = "949470",
		MALE = "917116",
	},
	GOBLIN = {
		FEMALE = "119369",
		MALE = "119376",
	},
	BLOOD_ELF = {
		FEMALE = "1100258",
		MALE = "1100087",
	},
	TAUREN = {
		FEMALE = "986648",
		MALE = "968705",
	},
	TROLL = {
		FEMALE = "1018060",
		MALE = "1022938",
	},
	UNDEAD = {
		FEMALE = "997378",
		MALE = "959310",
	},
}

local EXCLAME_ID = "64";
local QUESTION_ID = "65";
local TALK_ID = "60";
local YES_ID = "185";
local NOPE_ID = "186";
local ACLAIM_ID = "68";

local ANIMATION_SEQUENCE_DURATION = {
	[EXCLAME_ID] = 3.000,
	[QUESTION_ID] = 3.000,
	[TALK_ID] = 4.000,
	[YES_ID] = 3.000,
	[NOPE_ID] = 3.000,
	[ACLAIM_ID] = 2.400,
	["0"] = 1.500,
}

local ANIMATION_SEQUENCE_DURATION_BY_MODEL = {

	-- NIGHT ELVES
	[CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.600,
		[TALK_ID] = 2.1,
		[YES_ID] = 1.9,
		[NOPE_ID] = 1.5,
		[ACLAIM_ID] = 2.4,
	},
	[CHAR_TO_ID.NIGHT_ELF.MALE] = {
		[TALK_ID] = 2.00,
		[EXCLAME_ID] = 2.0,
		[QUESTION_ID] = 2.00,
		[YES_ID] = 1.1,
		[NOPE_ID] = 1.3,
		[ACLAIM_ID] = 2,
	},
	-- DWARF
	[CHAR_TO_ID.DWARF.MALE] = {
		[EXCLAME_ID] = 2.00,
		[QUESTION_ID] = 1.800,
		[TALK_ID] = 2.000,
		[YES_ID] = 1.9,
		[NOPE_ID] = 1.9,
		[ACLAIM_ID] = 3,
	},
	[CHAR_TO_ID.DWARF.FEMALE] = {
		[TALK_ID] = 1.900,
		[EXCLAME_ID] = 2.00,
		[QUESTION_ID] = 1.800,
		[YES_ID] = 2.0,
		[NOPE_ID] = 1.9,
		[ACLAIM_ID] = 2,
	},
	-- GNOMES
	[CHAR_TO_ID.GNOME.MALE] = {
		[EXCLAME_ID] = 1.800,
		[QUESTION_ID] = 2.250,
		[TALK_ID] = 3.900,
		[YES_ID] = 0.9,
		[NOPE_ID] = 1.0,
		[ACLAIM_ID] = 2.0,
	},
	[CHAR_TO_ID.GNOME.FEMALE] = {
		[EXCLAME_ID] = 1.850,
		[QUESTION_ID] = 2.250,
		[TALK_ID] = 3.900,
		[YES_ID] = 0.9,
		[NOPE_ID] = 1.7, -- Multi anim ...
		[ACLAIM_ID] = 2.0,
	},
	-- HUMAN
	[CHAR_TO_ID.HUMAN.MALE] = {
		[EXCLAME_ID] = 1.800,
		[QUESTION_ID] = 1.800,
		[TALK_ID] = 2.000,
		[YES_ID] = 2.6,
		[NOPE_ID] = 3.2,
		[ACLAIM_ID] = 2.400,
	},
	[CHAR_TO_ID.HUMAN.FEMALE] = {
		[EXCLAME_ID] = 2.700,
		[QUESTION_ID] = 1.800,
		[TALK_ID] = 2.650,
		[YES_ID] = 1.900,
		[NOPE_ID] = 1.900,
		[ACLAIM_ID] = 2.300,
	},
	-- DRAENEI
	[CHAR_TO_ID.DRAENEI.FEMALE] = {
		[TALK_ID] = 2.850,
		[QUESTION_ID] = 1.850,
		[EXCLAME_ID] = 2.100,
		[YES_ID] = 1.9,
		[NOPE_ID] = 2.200,
		[ACLAIM_ID] = 2,
	},
	[CHAR_TO_ID.DRAENEI.MALE] = {
		[TALK_ID] = 3.300,
		[QUESTION_ID] = 1.850,
		[EXCLAME_ID] = 3.000,
		[YES_ID] = 1.3,
		[NOPE_ID] = 1.2,
		[ACLAIM_ID] = 1.8,
	},
	-- WORGEN
	[CHAR_TO_ID.WORGEN.FEMALE] = {
		[QUESTION_ID] = 3.7,
		[TALK_ID] = 4.000,
		[EXCLAME_ID] = 2.700,
		[YES_ID] = 1.7,
		[ACLAIM_ID] = 3.5,
		[NOPE_ID] = 1.8,
	},
	[CHAR_TO_ID.WORGEN.MALE] = {
		[TALK_ID] = 4.300,
		[EXCLAME_ID] = 3.00,
		[QUESTION_ID] = 3.800,
		[YES_ID] = 1.8,
		[NOPE_ID] = 1.75,
		[ACLAIM_ID] = 3.8,
	},
	-- PANDAREN
	[CHAR_TO_ID.PANDAREN.FEMALE] = {
		[TALK_ID] = 3.200,
		[EXCLAME_ID] = 3,
		[QUESTION_ID] = 3.8,
		[ACLAIM_ID] = 3.200,
		[YES_ID] = 2.00,
		[NOPE_ID] = 3.50, -- Multi anim ...
	},
	[CHAR_TO_ID.PANDAREN.MALE] = {
		[EXCLAME_ID] = 3.400,
		[QUESTION_ID] = 4.2,
		[TALK_ID] = 4.200,
		[YES_ID] = 4,
		[NOPE_ID] = 3.2,
		[ACLAIM_ID] = 2.400,
	},
	-- ORCS
	[CHAR_TO_ID.ORC.FEMALE] = {
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.600,
		[TALK_ID] = 2.1,
		[YES_ID] = 1.2,
		[NOPE_ID] = 1.3,
		[ACLAIM_ID] = 1.4,
	},
	[CHAR_TO_ID.ORC.MALE] = { -- Male
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.800,
		[TALK_ID] = 2.00,
		[YES_ID] = 1.8,
		[NOPE_ID] = 1.8,
		[ACLAIM_ID] = 2.7,
	},
	-- GOBLIN
	[CHAR_TO_ID.GOBLIN.MALE] = {
		[TALK_ID] = 4.3,
		[QUESTION_ID] = 3.7,
		[EXCLAME_ID] = 2.600,
		[YES_ID] = 2.5,
		[NOPE_ID] = 2.8,
		[ACLAIM_ID] = 3.2,
	},
	[CHAR_TO_ID.GOBLIN.FEMALE] = {
		[TALK_ID] = 4.2,
		[QUESTION_ID] = 4.5,
		[EXCLAME_ID] = 3.5,
		[YES_ID] = 2.6,
		[NOPE_ID] = 2.5,
		[ACLAIM_ID] = 1.8,
	},
	-- Blood elves
	[CHAR_TO_ID.BLOOD_ELF.MALE] = {
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 2.00,
		[TALK_ID] = 2.000,
		[YES_ID] = 1.3,
		[ACLAIM_ID] = 2.1,
		[NOPE_ID] = 1.5,
	},
	[CHAR_TO_ID.BLOOD_ELF.FEMALE] = {
		[YES_ID] = 1.7,
		[QUESTION_ID] = 1.6,
		[ACLAIM_ID] = 1.5,
		[NOPE_ID] = 2.3,
		[EXCLAME_ID] = 3.2,
	},
	-- Taurene
	[CHAR_TO_ID.TAUREN.FEMALE] = {
		[TALK_ID] = 3.0,
		[YES_ID] = 1.5,
		[NOPE_ID] = 1.8,
		[QUESTION_ID] = 1.7,
		[EXCLAME_ID] = 1.9,
		[ACLAIM_ID] = 1.8,
	},
	[CHAR_TO_ID.TAUREN.MALE] = {
		[TALK_ID] = 2.90,
		[EXCLAME_ID] = 2.0,
		[QUESTION_ID] = 1.8,
		[YES_ID] = 1.9,
		[ACLAIM_ID] = 1.9,
		[NOPE_ID] = 2,
	},
	-- Troll
	[CHAR_TO_ID.TROLL.FEMALE] = {
		[TALK_ID] = 2.45,
		[YES_ID] = 1.4,
		[NOPE_ID] = 1.6,
		[QUESTION_ID] = 1.4,
		[EXCLAME_ID] = 2.3,
		[ACLAIM_ID] = 2.1,
	},
	[CHAR_TO_ID.TROLL.MALE] = {
		[TALK_ID] = 2.400,
		[EXCLAME_ID] = 2.600,
		[QUESTION_ID] = 1.9,
		[YES_ID] = 1.6,
		[ACLAIM_ID] = 3,
		[NOPE_ID] = 1.6,
	},
	-- Undead
	[CHAR_TO_ID.UNDEAD.MALE] = {
		[YES_ID] = 2,
		[NOPE_ID] = 2,
		[QUESTION_ID] = 2.3,
		[EXCLAME_ID] = 2.3,
		[ACLAIM_ID] = 2.1,
		[TALK_ID] = 2.6,
	},
	[CHAR_TO_ID.UNDEAD.FEMALE] = {
		[YES_ID] = 2.0,
		[NOPE_ID] = 2.0,
		[QUESTION_ID] = 2,
		[EXCLAME_ID] = 2,
		[ACLAIM_ID] = 2.1,
		[TALK_ID] = 2.5,
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NPC
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	["117412"] = {
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.7,
		[TALK_ID] = 3.000,
	},
	["125589"] = {
		[TALK_ID] = 2.000,
		[QUESTION_ID] = 1.600,
	},
	["1024776"] = {
		[TALK_ID] = 2.000,
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.7,
	},
	["234694"] = {
		[TALK_ID] = 2.000,
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.5,
	},
	-- ARRAKOA
	["1033563"] = {
		[TALK_ID] = 1.700,
	},
	["986699"] = {
		[TALK_ID] = 4.300,
	},
	["930099"] = {
		[TALK_ID] = 1.9,
	},
	["984967"] = {
		[TALK_ID] = 3.2,
	},
	["124118"] = {
		[TALK_ID] = 2.65,
	},
	-- Greymane
	["1246857"] = {
		[TALK_ID] = 2.000,
		[EXCLAME_ID] = 2.000,
		[QUESTION_ID] = 1.8,
	},
	["1247772"] = { -- Anduin
		[EXCLAME_ID] = 2.00,
		[QUESTION_ID] = 1.800,
		[TALK_ID] = 2.000,
	},
}

ANIMATION_SEQUENCE_DURATION_BY_MODEL["579571"] = ANIMATION_SEQUENCE_DURATION_BY_MODEL["974343"];

local DEFAULT_SEQUENCE_TIME = 4;

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Animation mapping
-- As some NPC models does not have some basing dialog animation, the mapping can map back a missing animation to a existing one.
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local DEFAULT_ANIM_MAPPING = {
	["!"] = 64,
	["?"] = 65,
	["."] = 60,
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Animations API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local after, tostring = C_Timer.After, tostring;
local assert = assert;

function Lib:GetCorrectAnim(model, animationID)
	-- For question and exclamation animations, check if they are available for this model
	-- and default to one that is available instead.
	if not Lib:ModelHasAnimation(model, animationID) and animationID == DEFAULT_ANIM_MAPPING["?"] then
		animationID = DEFAULT_ANIM_MAPPING["!"];
	end
	if not Lib:ModelHasAnimation(model, animationID) and animationID == DEFAULT_ANIM_MAPPING["!"] then
		animationID = DEFAULT_ANIM_MAPPING["."];
	end
	return animationID
end

function Lib:PlayAnim(model, animationID, animationVariation)

	-- For question and exclamation animations, check if they are available for this model
	-- and default to one that is available instead.
	if not Lib:ModelHasAnimation(model, animationID) and animationID == DEFAULT_ANIM_MAPPING["?"] then
		animationID = DEFAULT_ANIM_MAPPING["!"];
	end
	if not Lib:ModelHasAnimation(model, animationID) and animationID == DEFAULT_ANIM_MAPPING["!"] then
		animationID = DEFAULT_ANIM_MAPPING["."];
	end

	-- If the model doesn't implement an animation for the given animation ID, default to 0 (standing)
	if not Lib:ModelHasAnimation(model, animationID) then
		animationID = 0;
	end

	model:SetAnimation(animationID, animationVariation or 0);

	if model.debug then
		model.debug:SetText(animationID);
	end
end

function Lib:PlayAnimationDelay(model, sequence, duration, delay, token, animationVariation)
	if delay == 0 then
		self:PlayAnim(model, sequence, animationVariation)
	else
		model.token = token;
		after(delay, function()
			if model.token == token then
				self:PlayAnim(model, sequence, animationVariation);
			end
		end)
	end

	return delay + duration;
end

function Lib:PlayAnimationAndStand(model, sequence, duration, token, animationVariation)
	model.token = token;
	self:PlayAnim(model, sequence, animationVariation);
	after(duration, function()
		if model.token == token then
			self:PlayAnim(model, 0);
		end
	end);
end

function Lib:GetAnimationDuration(model, sequence)
	sequence = tostring(sequence);
	if ANIMATION_SEQUENCE_DURATION_BY_MODEL[model] and ANIMATION_SEQUENCE_DURATION_BY_MODEL[model][sequence] then
		return ANIMATION_SEQUENCE_DURATION_BY_MODEL[model][sequence];
	end
	return ANIMATION_SEQUENCE_DURATION[sequence] or DEFAULT_SEQUENCE_TIME;
end

--- Return the animation ID corresponding to the given punctuation mark (for example: 60 for .)
--- @param model string
--- The model ID was previously given to this function as we used a table to keep track of models that do not
--- implement some animations and return a fallback animation that was implemented.
--- @param animationType string
function Lib:GetDialogAnimation(model, animationType)
	return DEFAULT_ANIM_MAPPING[animationType] or DEFAULT_ANIM_MAPPING["."];
end

--- Check if the given Model implements an animation for the given animation ID
--- @param model Model
--- Model widget (or another widget inheriting the Model widget methods) to test.
--- @param animationID number
--- ID of the animation to check
function Lib:ModelHasAnimation(model, animationID)
	assert(model and model.HasAnimation, "model is not a Model widget and doesn't implement Model:HasAnimation(animationID)!");
	return model:HasAnimation(animationID);
end