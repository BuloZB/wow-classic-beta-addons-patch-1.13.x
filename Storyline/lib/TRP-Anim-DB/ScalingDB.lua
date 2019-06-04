----------------------------------------------------------------------------------
-- Total RP 3: Dialogues animations
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

local MAJOR, MINOR = "TRP-Dialog-Scaling-DB", 2

local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then return end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Model scaling
-- Give the scaling between two models
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

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

local DEFAULT_PROPERTIES = {
	scale = 1.45,
	feet = 0.4,
	offset = 0.215,
	facing = 0.75
};

Lib.DEFAULT_PROPERTIES = DEFAULT_PROPERTIES;

local SCALE_MAPPING = {

	-- NIGHT ELF FEMALE

	[CHAR_TO_ID.NIGHT_ELF.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.56, -- [1]
		1.41, -- [2]
	},

	-- NIGHT ELF FEMALE

	[CHAR_TO_ID.NIGHT_ELF.MALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.38, -- [1]
		2.03, -- [2]
	},

	-- ORC FEMALE

	[CHAR_TO_ID.ORC.FEMALE .. "~" .. CHAR_TO_ID.TROLL.FEMALE] = {
		1.56, -- [1]
		1.42, -- [2]
	},
	[CHAR_TO_ID.ORC.FEMALE .. "~" .. CHAR_TO_ID.TROLL.MALE] = {
		1.63, -- [1]
		1.45, -- [2]
	},
	[CHAR_TO_ID.ORC.FEMALE .. "~" .. CHAR_TO_ID.ORC.MALE] = {
		1.54, -- [1]
		1.45, -- [2]
	},
	[CHAR_TO_ID.ORC.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		1.52, -- [1]
		1.2, -- [2]
	},

	-- BLOOD ELF FEMALE
	[CHAR_TO_ID.BLOOD_ELF.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.53, -- [1]
		1.39, -- [2]
	},
	[CHAR_TO_ID.BLOOD_ELF.FEMALE .. "~" .. CHAR_TO_ID.BLOOD_ELF.MALE] = {
		1.5, -- [1]
		1.33, -- [2]
	},
	[CHAR_TO_ID.BLOOD_ELF.FEMALE .. "~" .. CHAR_TO_ID.TROLL.FEMALE] = {
		1.55, -- [1]
		1.25, -- [2]
	},
	[CHAR_TO_ID.BLOOD_ELF.FEMALE .. "~" .. CHAR_TO_ID.TAUREN.MALE] = {
		1.79, -- [1]
		1.05, -- [2]
	},

	-- DWARF FEMALE
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.GNOME.FEMALE] = {
		1.299, -- [1]
		1.799, -- [2]
	},
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.WORGEN.MALE] = {
		1.639, -- [1]
		1.299, -- [2]
	},
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.299, -- [1]
		1.179, -- [2]
	},
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.709, -- [1]
		1.23, -- [2]
	},
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.TAUREN.MALE] = {
		2, -- [1]
		1.029, -- [2]
	},
	[CHAR_TO_ID.DWARF.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		1.769, -- [1]
		1.299, -- [2]
	},

	-- GNOME MALE
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.HUMAN.MALE] = {
		2.06, -- [1]
		1.3, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		2.389, -- [1]
		1.26, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.58, -- [1]
		1.08, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.WORGEN.MALE] = {
		2.5, -- [1]
		1.3, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		2.599, -- [1]
		1.12, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.DWARF.FEMALE] = {
		1.6, -- [1]
		1.21, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		2.5199, -- [1]
		1.35, -- [2]
	},
	[CHAR_TO_ID.GNOME.MALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		2.24, -- [1]
		1.37, -- [2]
	},

	-- WORGEN MALE
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.41, -- [1]
		1.78
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.45, -- [1]
		1.35, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.HUMAN.FEMALE] = {
		1.39, -- [1]
		1.62, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.HUMAN.MALE] = {
		1.52, -- [1]
		1.56, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		1.45, -- [1]
		1.45, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.GNOME.FEMALE] = {
		1.41, -- [1]
		2.72, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		1.45, -- [1]
		1.35, -- [2]
	},
	[CHAR_TO_ID.WORGEN.MALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.45, -- [1]
		1.63, -- [2]
	},

	-- WORGEN FEMALE
	[CHAR_TO_ID.WORGEN.FEMALE .. "~" .. CHAR_TO_ID.HUMAN.MALE] = {
		1.49, -- [1]
		1.61, -- [2]
	},
	[CHAR_TO_ID.WORGEN.FEMALE .. "~" .. CHAR_TO_ID.HUMAN.FEMALE] = {
		1.42, -- [1]
		1.67, -- [2]
	},
	[CHAR_TO_ID.WORGEN.FEMALE .. "~" .. CHAR_TO_ID.WORGEN.MALE] = {
		1.53, -- [1]
		1.49, -- [2]
	},
	[CHAR_TO_ID.WORGEN.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		1.45, -- [1]
		1.45, -- [2]
	},

	-- DRAENEI MALE
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.ORC.FEMALE] = {
		1.42, -- [1]
		1.68, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.DRAENEI.FEMALE] = {
		1.43, -- [1]
		1.48, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.WORGEN.MALE] = {
		1.45, -- [1]
		1.65, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.GNOME.FEMALE] = {
		1.44, -- [1]
		2.7599, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.GNOME.MALE] = {
		1.45,
		2.43,
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.45,
		2.04,
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.DWARF.FEMALE] = {
		1.45,
		2.02,
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.45,
		1.7,
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~1284603"] = { -- Odyn
		4,
		1.31,
	},
	[CHAR_TO_ID.DRAENEI.MALE .. "~1286521"] = {
		1.9,
		1.31,
	},

	-- DRAENEI FEMALE
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.DWARF.FEMALE] = {
		1.27, -- [1]
		1.83, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.32, -- [1]
		2.01, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~~" .. CHAR_TO_ID.BLOOD_ELF.FEMALE] = {
		1.36, -- [1]
		1.63, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		1.39, -- [1]
		1.54, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~~" .. CHAR_TO_ID.UNDEAD.MALE] = {
		1.37, -- [1]
		1.66, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.46, -- [1]
		1.41, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.GNOME.MALE] = {
		1.36, -- [1]
		2.66, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.4, -- [1]
		1.61, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		1.45, -- [1]
		1.39, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.WORGEN.MALE] = {
		1.45, -- [1]
		1.57, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.GNOME.FEMALE] = {
		1.44, -- [1]
		2.5599, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.ORC.FEMALE] = {
		1.38, -- [1]
		1.62, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.HUMAN.MALE] = {
		1.4, -- [1]
		1.64, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.WORGEN.FEMALE] = {
		1.38, -- [1]
		1.6, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.BLOOD_ELF.MALE] = {
		1.41, -- [1]
		1.57, -- [2]
	},
	[CHAR_TO_ID.DRAENEI.FEMALE .. "~" .. CHAR_TO_ID.ORC.MALE] = {
		1.41, -- [1]
		1.58, -- [2]
	},

	-- HUMAN MALE
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		1.389, -- [1]
		1.299, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.59, -- [1]
		1.28, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.29, -- [1]
		1.55, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.399, -- [1]
		1.35, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.DWARF.FEMALE] = {
		1.279, -- [1]
		1.599, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.GNOME.FEMALE] = {
		1.29, -- [1]
		1.99, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.ORC.MALE] = {
		1.289, -- [1]
		1.429, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.GOBLIN.FEMALE] = {
		1.279, -- [1]
		1.959, -- [2]
	},
	[CHAR_TO_ID.HUMAN.MALE .. "~" .. CHAR_TO_ID.DRAENEI.MALE] = {
		1.65, -- [1]
		1.45
	},

	-- HUMAN FEMALE
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.DRAENEI.FEMALE] = {
		1.81, -- [1]
		1.31, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.HUMAN.MALE] = {
		1.56, -- [1]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.FEMALE] = {
		1.61, -- [1]
		1.32, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.FEMALE] = {
		1.58, -- [1]
		1.38, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.DRAENEI.MALE] = {
		1.63, -- [1]
		1.27, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.GOBLIN.MALE] = {
		1.4, -- [1]
		1.91, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.NIGHT_ELF.MALE] = {
		1.61, -- [1]
		1.27, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.PANDAREN.MALE] = {
		1.58, -- [1]
		1.13, -- [2]
	},
	[CHAR_TO_ID.HUMAN.FEMALE .. "~" .. CHAR_TO_ID.DWARF.MALE] = {
		1.45, -- [1]
		1.63, -- [2]
	},
}

local PLACEMENT_PROPERTIES = {
	[CHAR_TO_ID.WORGEN.MALE] = {
		["offset"] = 0.165,
	},
	[CHAR_TO_ID.DWARF.MALE] = {
		["offset"] = 0.185,
	},
	[CHAR_TO_ID.DWARF.FEMALE] = {
		["offset"] = 0.255,
	},
	[CHAR_TO_ID.GNOME.MALE] = {
		["offset"] = 0.185,
		["scale"] = 2.66,
	},
	[CHAR_TO_ID.GNOME.FEMALE] = {
		["offset"] = 0.215,
		["scale"] = 2.66,
	},
	[CHAR_TO_ID.HUMAN.FEMALE] = {
		["offset"] = 0.235,
	},
	[CHAR_TO_ID.PANDAREN.MALE] = {
		["offset"] = 0.235,
	},
	[CHAR_TO_ID.PANDAREN.FEMALE] = {
		["offset"] = 0.265,
	},

	-- NPCs
	["123455"] = { -- Draenei child female
		["scale"] = 2.82,
	},
	["124495"] = { -- Human child male
		["scale"] = 2.22,
		["feet"] = 0.42,
		["offset"] = 0.125,
	},
	["124456"] = { -- Human child female
		["scale"] = 2.89,
	},
	["126286"] = { -- Tuskarr
		["scale"] = 1.92,
		["offset"] = 0.105,
	},
	["971357"] = { -- Velen
		["scale"] = 0.87,
		["offset"] = 0.255,
	},
	["536149"] = { -- Tyrande
		["scale"] = 1.37,
	},
	["1249799"] = { -- Malfurion
		["scale"] = 0.94,
	},
	["646095"] = { -- Jaina
		["scale"] = 1.43,
		["offset"] = 0.285,
	},
	["977063"] = { -- Elementaire de truc
		["scale"] = 0.83,
	},
	["1281267"] = { -- Valkyr
		["scale"] = 1.01,
	},
	["1286521"] = { -- Valajar
		["scale"] = 1.31,
		["offset"] = 0.265,
	},
	["122815"] = { -- Vrykul
		["scale"] = 1.28,
		["offset"] = 0.295,
	},
	["1324256"] = { -- Druid panel
		["scale"] = 2.82,
		["feet"] = 0.4,
		["offset"] = 0.095,
		["facing"] = -3.99,
	},
}

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Scaling API
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

function Lib:GetModelKeys(model1, model2)
	local key = (model1 or "") .. "~" .. (model2 or "");
	local inverted = (model2 or "") .. "~" .. (model1 or "");
	return key, inverted;
end

function Lib:IsRecorded(model1, model2)
	local key, inverted = self:GetModelKeys(model1, model2);
	return SCALE_MAPPING[key] ~= nil or SCALE_MAPPING[inverted] ~= nil;
end

function Lib:GetModelPlacementProperties(model)
	return PLACEMENT_PROPERTIES[model] or DEFAULT_PROPERTIES;
end

function Lib:GetModelCoupleProperties(model1, model2)
	local key, inverted = self:GetModelKeys(model1, model2);

	local scalingMe, scalingYou;
	if SCALE_MAPPING[key] then
		scalingMe, scalingYou = SCALE_MAPPING[key][1] or DEFAULT_PROPERTIES.scale, SCALE_MAPPING[key][2] or DEFAULT_PROPERTIES.scale;
	end
	if SCALE_MAPPING[inverted] then
		scalingMe, scalingYou = SCALE_MAPPING[inverted][2] or DEFAULT_PROPERTIES.scale, SCALE_MAPPING[inverted][1] or DEFAULT_PROPERTIES.scale;
	end

	local propsMe, propsYou = self:GetModelPlacementProperties(model1), self:GetModelPlacementProperties(model2);

	return
	{
		scale = scalingMe or propsMe.scale,
		feet = propsMe.feet,
		offset = propsMe.offset,
		facing = propsMe.facing,
	},
	{
		scale = scalingYou or propsYou.scale,
		feet = propsYou.feet,
		offset = propsYou.offset,
		facing = propsYou.facing,
	};
end

function Lib:SetModelHeight(scale, frame)
	scale = scale or DEFAULT_PROPERTIES.scale;
	frame.scale = scale;
	frame:InitializeCamera(scale);
end

function Lib:SetModelFacing(facing, frame, isMe)
	facing = facing or DEFAULT_PROPERTIES.facing;
	frame.facing = facing;
	frame:SetFacing(facing * (isMe and 1 or -1));
end

function Lib:SetModelFeet(feet, frame)
	feet = feet or DEFAULT_PROPERTIES.feet;
	frame.feet = feet;
	frame:SetHeightFactor(feet);
end

function Lib:SetModelOffset(offset, frame, isMe)
	offset = offset or DEFAULT_PROPERTIES.offset;
	frame.offset = offset;
	frame:SetTargetDistance(offset * (isMe and 1 or -1));
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- DEBUG AND MAINTENANCE
-- Don't use it on your code. :)
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

-- /run StorylineGenerate();
function StorylineGenerate()
	Storyline_Data.SCALE_MAPPING = {};

	local keys = {};
	-- Get the keys
	for key, _ in pairs(SCALE_MAPPING) do
		tinsert(keys, key);
	end

	table.sort(keys);

	local nameFinder = function(key)
		for race, _ in pairs(CHAR_TO_ID) do
			if CHAR_TO_ID[race].FEMALE == key then
				return race .. ".FEMALE";
			elseif CHAR_TO_ID[race].MALE == key then
				return race .. ".MALE";
			end
		end
	end

	for _, key in pairs(keys) do
		local structure = SCALE_MAPPING[key];
		if structure.me and structure.you then
			Storyline_Data.SCALE_MAPPING[key] = {
				structure.me.scale, structure.you.scale
			}
		elseif structure.me then
			Storyline_Data.SCALE_MAPPING[key] = {
				structure.me.scale
			}
		end
	end

	ReloadUI();
end

local debugPlayerModelList = {
	-- Alliance
	"1000764",
	"1011653",
	"940356",
	"900914",
	"950080",
	"878772",
	"1022598",
	"1005887",
	"535052",
	"589715",
	"921844",
	"974343",
	"307453",
	"307454",

	-- Horde
	--	"119376",
	--	"119369",
}

--function TRP3_API.extended.animations.debugMissingScaling()
--	local alreadyTreated = {};
--	local count = 0;
--	for _, firstModel in pairs(debugPlayerModelList) do
--		for _, secondModel in pairs(debugPlayerModelList) do
--			if firstModel ~= secondModel then
--				local key, invertedKey = firstModel .. "~" .. secondModel, secondModel .. "~" .. firstModel;
--				if not TRP3_API.extended.animations.SCALE_MAPPING[key] and not TRP3_API.extended.animations.SCALE_MAPPING[invertedKey] and not alreadyTreated[key] and not alreadyTreated[invertedKey] then
--					alreadyTreated[key] = true;
--					alreadyTreated[invertedKey] = true;
--					count = count + 1;
--					print(("Missing scaling for %s + %s"):format(firstModel, secondModel));
--				end
--			end
--		end
--	end
--	print(("Total %s"):format(count));
--end
--
--local IMPORT = {
--
--}
--
--function TRP3_API.extended.animations.API.debugComplete()
--	if not TRP3_API.extended.animations.Data.debug.finalImport then
--		TRP3_API.extended.animations.Data.debug.finalImport = {};
--	end
--	wipe(TRP3_API.extended.animations.Data.debug.finalImport);
--	-- Find which key to import
--	local toImport = {};
--	for key, info in pairs(IMPORT) do
--		local firstModel = key:sub(1, key:find("~") - 1);
--		local secondModel = key:sub(key:find("~") + 1);
--		local invertedKey = secondModel .. "~" .. firstModel;
--		if not TRP3_API.extended.animations.SCALE_MAPPING[key] and not TRP3_API.extended.animations.SCALE_MAPPING[invertedKey] then
--			print("new to import: " .. key);
--			TRP3_API.extended.animations.Data.debug.finalImport[key] = info;
--		end
--	end
--end