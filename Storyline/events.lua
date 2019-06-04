----------------------------------------------------------------------------------
--  Storyline
--	---------------------------------------------------------------------------
--	Copyright 2015 Sylvain Cossement (telkostrasz@totalrp3.info)
--	Copyright 2015 Renaud "Ellypse" Parize (ellypse@totalrp3.info)
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
----------------------------------------------------------------------------------

local animationLib = LibStub:GetLibrary("TRP-Dialog-Animation-DB");
local Ellyb = Ellyb(...);

-- Storyline API
local configureHoverFrame = Storyline_API.lib.configureHoverFrame;
local setTooltipForSameFrame, setTooltipAll = Storyline_API.lib.setTooltipForSameFrame, Storyline_API.lib.setTooltipAll;
local refreshTooltipForFrame = Storyline_RefreshTooltipForFrame;
local Storyline_MainTooltip = Storyline_MainTooltip;
local log = Storyline_API.lib.log;
local getTextureString, colorCodeFloat = Storyline_API.lib.getTextureString, Storyline_API.lib.colorCodeFloat;
local getId = Storyline_API.lib.generateID;
local loc = Storyline_API.locale.getText;
local format = format;
local getQuestIcon, getQuestActiveIcon = Storyline_API.getQuestIcon, Storyline_API.getQuestActiveIcon;
local selectFirstGossip, 	selectMultipleGossip = Storyline_API.selectFirstGossip, Storyline_API.selectMultipleGossip;
local selectMultipleRewards, selectFirstGreetingActive = Storyline_API.selectMultipleRewards, Storyline_API.selectFirstGreetingActive;
local hideStorylineFrame = Storyline_API.layout.hideStorylineFrame;
local hideQuestRewardFrameIfNeed = Storyline_API.layout.hideQuestRewardFrameIfNeed;
local debug = Storyline_API.debug;
local tsize = Storyline_API.lib.tsize;

-- WOW API
local faction, faction_loc = UnitFactionGroup("player");
local pairs, CreateFrame, wipe, type, tinsert, after, select, huge = pairs, CreateFrame, wipe, type, tinsert, C_Timer.After, select, math.huge;

-- UI
local Storyline_NPCFrameObjectives, Storyline_NPCFrameObjectivesNo, Storyline_NPCFrameObjectivesYes = Storyline_NPCFrameObjectives, Storyline_NPCFrameObjectivesNo, Storyline_NPCFrameObjectivesYes;
local Storyline_NPCFrameObjectivesImage = Storyline_NPCFrameObjectivesImage;
local Storyline_NPCFrameRewardsItemIcon, Storyline_NPCFrameRewardsItem, Storyline_NPCFrameRewards = Storyline_NPCFrameRewardsItemIcon, Storyline_NPCFrameRewardsItem, Storyline_NPCFrameRewards;
local Storyline_NPCFrame, Storyline_NPCFrameChatNextText = Storyline_NPCFrame, Storyline_NPCFrameChatNextText;
local Storyline_NPCFrameChat, Storyline_NPCFrameChatText = Storyline_NPCFrameChat, Storyline_NPCFrameChatText;
local Storyline_NPCFrameChatNext, Storyline_NPCFrameChatPrevious = Storyline_NPCFrameChatNext, Storyline_NPCFrameChatPrevious;
local Storyline_NPCFrameConfigButton, Storyline_NPCFrameObjectivesContent = Storyline_NPCFrameConfigButton, Storyline_NPCFrameObjectivesContent;
local Storyline_NPCFrameGossipChoices = Storyline_NPCFrameGossipChoices;
local Dialogs = Storyline_API.dialogs;
local DialogsButtons = Storyline_API.dialogs.buttons;
local DialogsScrollFrame = Storyline_API.dialogs.scrollFrame;
local Rewards = Storyline_API.rewards;
local RewardsButtons = Storyline_API.rewards.buttons;

-- Constants
local OPTIONS_MARGIN, OPTIONS_TOP = 175, -175;
local GOSSIP_DELAY = 0.2;
local gossipColor = "|cffffffff";
local EVENT_INFO;
local eventHandlers = {};
local BONUS_SKILLPOINTS = BONUS_SKILLPOINTS;
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS;
local REQUIRED_MONEY = REQUIRED_MONEY;
local QUEST_SUGGESTED_GROUP_NUM, QUEST_OBJECTIVES = QUEST_SUGGESTED_GROUP_NUM, QUEST_OBJECTIVES;
---@type Texture
local frameBackground = Storyline_NPCFrameBG;
---@type Texture
local frameSpecialAtlas = Storyline_NPCFrameSpecialAtlas;

--region Sealed quest info
local SEAL_QUESTS = {
	[40519] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_VARIAN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},
	[43926] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_VOLJIN.."|r", sealAtlas = "Quest-Horde-WaxSeal"},
	[47221] = { bgAtlas = "QuestBG-TheHandofFate", },
	[47835] = { bgAtlas = "QuestBG-TheHandofFate", },
	[49929] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal" },
	[49930] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal" },
	[50476] = { bgAtlas = "QuestBG-Horde", sealAtlas = "Quest-Horde-WaxSeal" },
	-- BfA start quests
	[46727] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal" },
	[50668] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal"},

	[51795] = { bgAtlas = "QuestBG-Alliance" },
	[52058] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},

	[51796] = { bgAtlas = "QuestBG-Horde" },

	[53372] = { bgAtlas = "QuestBG-Horde", text = "|cff480404"..QUEST_WARCHIEF_SYLVANAS_WINDRUNNER.."|r", sealAtlas = "Quest-Horde-WaxSeal"},
	[53370] = { bgAtlas = "QuestBG-Alliance", text = "|cff042c54"..QUEST_KING_ANDUIN_WRYNN.."|r", sealAtlas = "Quest-Alliance-WaxSeal"},
};
local EXCEPTION_QUESTS = {
	[53029] = true,
	[53026] = true,
	[51211] = true,
	[52428] = true,
};
--endregion

function Storyline_API.getSpecialQuestInfo(questID)
	return SEAL_QUESTS[questID]
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Auto equip part, greatly inspired by AutoTurnIn by Alex Shubert (alex.shubert@gmail.com)
-- Thanks to him !
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local SUPPORTED_SLOTS = {
	["INVTYPE_AMMO"]={"AmmoSlot"},
	["INVTYPE_HEAD"]={"HeadSlot"},
	["INVTYPE_NECK"]={"NeckSlot"},
	["INVTYPE_SHOULDER"]={"ShoulderSlot"},
	["INVTYPE_CHEST"]={"ChestSlot"},
	["INVTYPE_WAIST"]={"WaistSlot"},
	["INVTYPE_LEGS"]={"LegsSlot"},
	["INVTYPE_FEET"]={"FeetSlot"},
	["INVTYPE_WRIST"]={"WristSlot"},
	["INVTYPE_HAND"]={"HandsSlot"},
	["INVTYPE_FINGER"]={"Finger0Slot", "Finger1Slot"},
	["INVTYPE_TRINKET"]={"Trinket0Slot", "Trinket1Slot"},
	["INVTYPE_CLOAK"]={"BackSlot"},
	["INVTYPE_WEAPON"]={"MainHandSlot", "SecondaryHandSlot"},
	["INVTYPE_2HWEAPON"]={"MainHandSlot"},
	["INVTYPE_RANGED"]={"MainHandSlot"},
	["INVTYPE_RANGEDRIGHT"]={"MainHandSlot"},
	["INVTYPE_WEAPONMAINHAND"]={"MainHandSlot"},
	["INVTYPE_SHIELD"]={"SecondaryHandSlot"},
	["INVTYPE_WEAPONOFFHAND"]={"SecondaryHandSlot"},
	["INVTYPE_HOLDABLE"]={"SecondaryHandSlot"}
}

local function getItemLevel(itemLink)
	if (not itemLink) then
		return 0
	end
	-- 7 for heirloom http://wowprogramming.com/docs/api_types#itemQuality
	local invQuality, invLevel = select(3, GetItemInfo(itemLink));
	return (invQuality == 7) and huge or invLevel;
end

local AUTO_EQUIP_DELAY = 2;
local function autoEquip(itemLink)

	-- We do not need to do anything if auto equip is disabled
	if not Storyline_Data.config.autoEquip then
		return
	end

	-- Hotfix for a weir bug introduced with world scaling in 7.3.5: some quests rewards doesn't have item link (Blizz please…)
	if not itemLink then return end;

	local name, link, quality, lootLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemLink);
	log(("autoEquip %s on slot %s"):format(name, equipSlot));

	-- First, determine if we should auto equip
	local shouldAutoEquip = false;
	local equipOn;
	if Storyline_Data.config.autoEquip then
		-- Compares reward and already equipped item levels. If reward level is greater than equipped item, auto equip reward
		local slot = SUPPORTED_SLOTS[equipSlot]
		if slot then
			log(("Supported slot %s"):format(equipSlot));
			local firstSlot = GetInventorySlotInfo(slot[1]);
			local invLink = GetInventoryItemLink("player", firstSlot);
			local eqLevel = getItemLevel(invLink);

			-- If reward is a ring  trinket or one-handed weapons all slots must be checked in order to swap one with a lesser item-level
			if #slot > 1 then
				local secondSlot = GetInventorySlotInfo(slot[2]);
				invLink = GetInventoryItemLink("player", secondSlot);
				if invLink then
					local eq2Level = getItemLevel(invLink);
					firstSlot = (eqLevel > eq2Level) and secondSlot or firstSlot;
					eqLevel = (eqLevel > eq2Level) and eq2Level or eqLevel;
				end
			end

			-- comparing lowest equipped item level with reward's item level
			log(("Comparing lvl: lootLevel %s vs eqLevel %s"):format(lootLevel, eqLevel));
			if lootLevel > eqLevel then
				shouldAutoEquip = true;
				equipOn = firstSlot;
			end
		end
	end

	if shouldAutoEquip then
		log(("Will auto equip %s on slot %s"):format(name, equipOn));
		after(AUTO_EQUIP_DELAY, function()
			if InCombatLockdown() then
				return;
			end
			for container=0, NUM_BAG_SLOTS do
				for slot=1, GetContainerNumSlots(container) do
					local link = GetContainerItemLink (container, slot);
					if link then
						local itemName = GetItemInfo(link);
						if itemName == name then
							log(("Found and trying to auto equip %s"):format(itemName, equipOn));
							EquipItemByName(name, equipOn);
							return;
						end
					end
				end
			end
		end);
	end
end
Storyline_API.autoEquip = autoEquip;

local function autoEquipAllReward()
	if GetNumQuestRewards() > 0 then
		for i=1, GetNumQuestRewards() do
			local link = GetQuestItemLink("reward", i);
			autoEquip(link);
		end
	end
end
Storyline_API.autoEquipAllReward = autoEquipAllReward;
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- Utils
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function getQuestData(qTitle)
	for questIndex=1, GetNumQuestLogEntries() do
		local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questIndex);
		if questTitle == qTitle then
			SelectQuestLogEntry(questIndex);
			local questDescription, questObjectives = GetQuestLogQuestText();
			return questObjectives or "";
		end
	end
	return "";
end

local function showQuestPortraitFrame(isOnCompleteStep)
	if not Storyline_Data.config.hideOriginalFrames then
		return;
	end

	local questPortrait, questPortraitText, questPortraitName, questPortraitMount

	if isOnCompleteStep then
		questPortrait, questPortraitText, questPortraitName, questPortraitMount = GetQuestPortraitTurnIn();
	else
		questPortrait, questPortraitText, questPortraitName, questPortraitMount = GetQuestPortraitGiver();
	end

	if questPortrait and questPortrait ~= 0 then
		QuestFrame_ShowQuestPortrait(Storyline_NPCFrame, questPortrait, questPortraitMount, questPortraitText, questPortraitName, -16, -48);
		QuestNPCModel:SetFrameStrata("LOW")
	else
		QuestFrame_HideQuestPortrait();
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- EVENT PART
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

local function gossipEventHandler(eventType)
	local dialogChoices = Storyline_API.dialogs.getChoices(eventType);
	local buttonIndex = 0;
	local previousFrame;
	local totalButtonHeights = 0;

	for bucketType, bucket in pairs(dialogChoices) do
		for choiceIndex, choice in pairs(bucket) do
			buttonIndex = buttonIndex + 1;
			-- Get a dialog button for the current index (it will either be created or we'll be given an existing one).
			local dialogChoiceButton = DialogsButtons.getButton(DialogsScrollFrame.container, previousFrame);
			-- Decorate the button appropriately for its type and data
			dialogChoiceButton:Decorate(buttonIndex, choiceIndex, choice, bucketType, eventType);

			totalButtonHeights = totalButtonHeights + dialogChoiceButton:GetHeight() + DialogsButtons.getMargin();
			previousFrame = dialogChoiceButton;
		end
	end

	if buttonIndex > 0 then
		DialogsScrollFrame.show(totalButtonHeights);
	end
end

eventHandlers[Dialogs.EVENT_TYPES.GOSSIP_SHOW] = function()
	gossipEventHandler(Dialogs.EVENT_TYPES.GOSSIP_SHOW);
	if Storyline_Data.config.forceGossip and  not Storyline_API.isCurrentNPCBlacklisted() then
		Storyline_NPCFrameBlacklistButton:Show()
	end
end;
eventHandlers[Dialogs.EVENT_TYPES.QUEST_GREETING] = function()
	gossipEventHandler(Dialogs.EVENT_TYPES.QUEST_GREETING);
end

local HOVERED_FRAME_TITLE_MARGIN = 10;
local HOVERED_FRAME_TEXT_MARGIN = 5;

local function setObjectiveText(fontString, text, anchor)
	fontString:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -1 * HOVERED_FRAME_TEXT_MARGIN);
	fontString:SetText(text);
	fontString:Show();
	return fontString:GetHeight() + HOVERED_FRAME_TEXT_MARGIN;
end

eventHandlers["QUEST_DETAIL"] = function()

	local previousText = Storyline_NPCFrameObjectivesContent.Title;

	Storyline_NPCFrameObjectivesContent.Title:SetPoint("TOP", 0, -1 * HOVERED_FRAME_TITLE_MARGIN);
	local contentHeight = Storyline_NPCFrameObjectivesContent.Title:GetHeight() + HOVERED_FRAME_TITLE_MARGIN;

	Storyline_NPCFrameObjectives:Show();
	Storyline_NPCFrameObjectivesImage:SetDesaturated(false);
	setTooltipForSameFrame(Storyline_NPCFrameObjectives, "TOP", 0, 0, QUEST_OBJECTIVES, loc("SL_CHECK_OBJ"));

	local objectives = GetObjectiveText();
	if objectives:len() > 0 then
		contentHeight = contentHeight + setObjectiveText(Storyline_NPCFrameObjectivesContent.Objectives, objectives, previousText);
		previousText = Storyline_NPCFrameObjectivesContent.Objectives;
	end

	local rewardsBucket = Rewards.getRewards();

	for bucketType, bucket in pairs(rewardsBucket) do
		if tsize(bucket) > 0 then
			contentHeight = contentHeight + RewardsButtons.displayRewardsOnGrid(bucketType, bucket, Storyline_NPCFrameObjectivesContent, previousText);
		end
	end

	-- Add some margin on the bottom
	contentHeight = contentHeight + HOVERED_FRAME_TEXT_MARGIN;

	Storyline_NPCFrameObjectivesContent:SetHeight(contentHeight);

	if GetNumQuestItems() > 0 then
		local _, icon = GetQuestItemInfo("required", 1);
		Storyline_NPCFrameObjectivesImage:SetTexture(icon);
	end
end

eventHandlers["QUEST_PROGRESS"] = function()

	local previousText = Storyline_NPCFrameObjectivesContent.Title;

	Storyline_NPCFrameObjectivesContent.Title:SetPoint("TOP", 0, -1 * HOVERED_FRAME_TITLE_MARGIN);
	local contentHeight = Storyline_NPCFrameObjectivesContent.Title:GetHeight() + HOVERED_FRAME_TITLE_MARGIN;

	Storyline_NPCFrameObjectives:Show();
	Storyline_NPCFrameObjectivesImage:SetDesaturated(not IsQuestCompletable());
	setTooltipForSameFrame(Storyline_NPCFrameObjectives, "TOP", 0, 0, QUEST_OBJECTIVES, loc("SL_CHECK_OBJ"));
	local objectives = GetObjectiveText();
	if objectives:len() > 0 then
		if IsQuestCompletable() then
			objectives = getTextureString("Interface\\RAIDFRAME\\ReadyCheck-Ready", 15) .. " |cff00ff00" .. objectives;
		else
			objectives = getTextureString("Interface\\RAIDFRAME\\ReadyCheck-NotReady", 15) .. " |cffff0000" .. objectives;
		end
		contentHeight = contentHeight + setObjectiveText(Storyline_NPCFrameObjectivesContent.Objectives, objectives, previousText);
		previousText = Storyline_NPCFrameObjectivesContent.Objectives;
	end

	local objectivesBucket = Rewards.getObjectiveItems();

	if tsize(objectivesBucket) > 0 then
		contentHeight = contentHeight + RewardsButtons.displayRewardsOnGrid(Rewards.BUCKET_TYPES.OBJECTIVES, objectivesBucket, Storyline_NPCFrameObjectivesContent, previousText);
	end

	-- Add some margin on the bottom
	contentHeight = contentHeight + HOVERED_FRAME_TEXT_MARGIN;

	Storyline_NPCFrameObjectivesContent:SetHeight(contentHeight);
end

local CLICKING_ON_REWARDS_MEANS_CHOOSING_IT = true;
eventHandlers["QUEST_COMPLETE"] = function(eventInfo)

	local rewardsBucket, bestIcon, totalNumberOfRewards = Rewards.getRewards();

	if totalNumberOfRewards > 0 then

		Storyline_NPCFrameRewards:Show();
		setTooltipForSameFrame(Storyline_NPCFrameRewardsItem, "TOP", 0, 0, REWARDS, loc("SL_GET_REWARD"));

		local previousText = Storyline_NPCFrameRewards.Content.Title;

		Storyline_NPCFrameRewards.Content.Title:SetPoint("TOP", 0, -1 * HOVERED_FRAME_TITLE_MARGIN);
		local contentHeight = Storyline_NPCFrameRewards.Content.Title:GetHeight() + HOVERED_FRAME_TITLE_MARGIN;

		for bucketType, bucket in pairs(rewardsBucket) do
			if tsize(bucket) > 0 then
				contentHeight = contentHeight + RewardsButtons.displayRewardsOnGrid(bucketType, bucket, Storyline_NPCFrameRewards.Content, previousText, CLICKING_ON_REWARDS_MEANS_CHOOSING_IT);
			end
		end

		-- Add some margin on the bottom
		contentHeight = contentHeight + HOVERED_FRAME_TEXT_MARGIN;

		Storyline_NPCFrameObjectivesContent:SetHeight(contentHeight);

		Storyline_NPCFrameRewardsItemIcon:SetTexture(bestIcon);
		Storyline_NPCFrameRewards.Content:SetHeight(contentHeight);
	else
		Storyline_NPCFrameRewards:Hide();
	end
end

local currentEvent;

function Storyline_API.getCurrentEvent()
	return currentEvent;
end

local function handleEventSpecifics(event, texts, textIndex, eventInfo)

	Storyline_NPCFrameGossipChoices:Hide();
	Storyline_NPCFrameRewards:Hide();
	Storyline_NPCFrameObjectives:Hide();
	Storyline_NPCFrameObjectivesYes:Hide();
	Storyline_NPCFrameObjectivesNo:Hide();
	Storyline_NPCFrameObjectives.OK:Hide();
	Storyline_NPCFrameObjectivesContent.RequiredItemText:Hide();
	Storyline_NPCFrameObjectivesContent.GroupSuggestion:Hide();
	Storyline_NPCFrameObjectivesContent.Objectives:SetText('');
	Storyline_NPCFrameObjectivesContent.Objectives:Hide();
	Storyline_NPCFrameRewards.Content:Hide();
	setTooltipForSameFrame(Storyline_NPCFrameObjectives);
	Storyline_NPCFrameObjectivesImage:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon");
	QuestFrame_HideQuestPortrait();

	DialogsScrollFrame.hide();
	DialogsButtons.hideAllButtons();
	RewardsButtons.hideAllButtons();

	showQuestPortraitFrame(event == "QUEST_COMPLETE");

	if textIndex == #texts and eventHandlers[event] then
		currentEvent = event;
		eventHandlers[event](eventInfo);
	end
end

local EMOTE_COLOR;
---@param targetModel Storyline_PlayerModelMixin
local function playText(textIndex, targetModel)
	local animTab = targetModel.animTab;
	wipe(animTab);

	if not EMOTE_COLOR then
		EMOTE_COLOR = Ellyb.Color(ChatTypeInfo["MONSTER_EMOTE"]):Freeze()
	end

	local text = Storyline_NPCFrameChat.texts[textIndex];
	local delay = GOSSIP_DELAY;
	local textLineToken = getId();

	Storyline_NPCFrameChatText:SetTextColor(ChatTypeInfo["MONSTER_SAY"].r, ChatTypeInfo["MONSTER_SAY"].g, ChatTypeInfo["MONSTER_SAY"].b);

	local stillEmote = Storyline_NPCFrameChat.stillEmote[textIndex];
	if text:byte() == 60 or not UnitExists("npc") or UnitIsUnit("player", "npc") or UnitIsDead("npc") or stillEmote then -- Emote if begins with <
		-- Blizzard is now coloring part of the text in some cases.
	    -- We will look for colosing color tags and add an opening color tag for our color right after it
		local colorCodeStart = EMOTE_COLOR:GetColorCodeStartSequence();
		local displayedText = text:gsub("|r", "|r" .. colorCodeStart)
		displayedText = displayedText:gsub("<", colorCodeStart .. "<");
		displayedText = displayedText:gsub(">", ">|r");

		if stillEmote then
			displayedText = EMOTE_COLOR(displayedText);
		end

		Storyline_NPCFrameChatText:SetText(displayedText);
	else
		Storyline_NPCFrameChatText:SetText(text);
		text:gsub("[%.%?%!]+", function(finder)
			animTab[#animTab + 1] = animationLib:GetDialogAnimation(targetModel.model, finder:sub(1, 1));
		end);
	end

	if #animTab == 0 then
		animTab[1] = 0;
	end

	if UnitIsDead("npc") then
		targetModel:DisplayDead();
	else
		targetModel:PlayAnimSequence(animTab);
	end


	Storyline_NPCFrameChat.start = 0;

	if #Storyline_NPCFrameChat.texts > 1 then
		Storyline_NPCFrameChatPrevious:Show();
	end

	handleEventSpecifics(Storyline_NPCFrameChat.event, Storyline_NPCFrameChat.texts, textIndex, Storyline_NPCFrameChat.eventInfo);

	Storyline_NPCFrameChat:SetHeight(Storyline_NPCFrameChatText:GetHeight() + Storyline_NPCFrameChatName:GetHeight() + Storyline_NPCFrameChatNextText:GetHeight() + 50);
end

---@param targetModel Storyline_PlayerModelMixin
function Storyline_API.playNext(targetModel)
	Storyline_NPCFrameChatNext:Enable();
	Storyline_NPCFrameChat.currentIndex = Storyline_NPCFrameChat.currentIndex + 1;

	Storyline_NPCFrameChatNextText:SetText(loc("SL_NEXT"));
	if Storyline_NPCFrameChat.currentIndex >= #Storyline_NPCFrameChat.texts then
		if Storyline_NPCFrameChat.eventInfo.finishText and (type(Storyline_NPCFrameChat.eventInfo.finishText) ~= "function" or Storyline_NPCFrameChat.eventInfo.finishText()) then
			if type(Storyline_NPCFrameChat.eventInfo.finishText) == "function" then
				Storyline_NPCFrameChatNextText:SetText(Storyline_NPCFrameChat.eventInfo.finishText());
			else
				Storyline_NPCFrameChatNextText:SetText(Storyline_NPCFrameChat.eventInfo.finishText);
			end
		end
	end

	if Storyline_NPCFrameChat.currentIndex <= #Storyline_NPCFrameChat.texts then
		playText(Storyline_NPCFrameChat.currentIndex, targetModel);
	else
		if Storyline_NPCFrameChat.eventInfo.finishMethod then
			Storyline_NPCFrameChat.eventInfo.finishMethod();
		else
			hideStorylineFrame();
		end
	end
end

local specialFrameBackgroundTransitionator = Ellyb.Transitionator();
local function fadeInSpecialFrameBackground(value)
	frameSpecialAtlas:SetAlpha(value);
end
local function displaySpecialDetails()
	-- Special quest with sealed background
	local questID = GetQuestID()
	if SEAL_QUESTS[questID] then
		local specialQuestDisplayInfo = SEAL_QUESTS[questID];
		if specialQuestDisplayInfo.bgAtlas then
			frameSpecialAtlas:SetAtlas(specialQuestDisplayInfo.bgAtlas);
			specialFrameBackgroundTransitionator:RunValue(0, 0.8, 0.8, fadeInSpecialFrameBackground)
			frameBackground:SetAlpha(0)
		end

		if specialQuestDisplayInfo.sealAtlas then
			Storyline_QuestInfoSealFrame:Show();
			Storyline_QuestInfoSealFrame.Texture:SetAtlas(specialQuestDisplayInfo.sealAtlas);
		end

		if specialQuestDisplayInfo.text then
			Storyline_QuestInfoSealFrame:Show();
			Storyline_QuestInfoSealFrame.Text:SetText(specialQuestDisplayInfo.text);
			Storyline_NPCFrameChatName:Hide()
		end
		Storyline_QuestInfoSealFrame:Show()
	end
end

--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- INIT
--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

---@type Storyline_PlayerModelMixin
local targetModel = Storyline_NPCFrame.models.you;
---@type Storyline_PlayerModelMixin
local playerModel = Storyline_NPCFrame.models.me;
local ANIMATIONS = Storyline_API.ANIMATIONS;

function Storyline_API.initEventsStructure()
	local startDialog = Storyline_API.startDialog;

	EVENT_INFO = {
		--[[
		TODO REMOVE
		["SCALING_DEBUG"] = {
			text = function() return "DEBUG TEXT" end,
			cancelMethod = function() end,
			titleGetter = function() return "DEBUG TITLE" end,
		},]]
		["QUEST_GREETING"] = {
			text = GetGreetingText,
			finishMethod = function()
				local firstChoice, bucketType, index = Dialogs.getFirstChoice(Dialogs.EVENT_TYPES.QUEST_GREETING);

				if Dialogs.getDialogChoiceSelectorForEventType(Dialogs.EVENT_TYPES.QUEST_GREETING, bucketType) then
					debug(("QUEST_GREETING – Finish method : Using selector method found for bucket type %s at index %s."):format(bucketType, index));
					Dialogs.getDialogChoiceSelectorForEventType(Dialogs.EVENT_TYPES.QUEST_GREETING, bucketType)(index);
				else
					debug("QUEST_GREETING – Finish method : No valid options found, fallback to closing quest.");
					CloseQuest();
				end
			end,
			finishText = function()
				local finishText = GOODBYE;
				local firstChoice = Dialogs.getFirstChoice(Dialogs.EVENT_TYPES.QUEST_GREETING);

				if firstChoice then
					finishText = firstChoice.title;
					debug(("QUEST_GREETING – Finish text : Found first choice with text %s."):format(finishText));
				else
					debug(("QUEST_GREETING – Finish text : Could not find a first choice, using default finish text %s."):format(finishText));
				end

				return finishText;
			end,
			cancelMethod = CloseQuest,
			titleGetter = GetTitleText,
		},
		["QUEST_DETAIL"] = {
			text = GetQuestText,
			cancelMethod = CloseQuest,
			titleGetter = GetTitleText,
			finishText = loc("SL_CHECK_OBJ"),
			finishMethod = function()
				if not Storyline_NPCFrameObjectivesContent:IsVisible() then
					configureHoverFrame(Storyline_NPCFrameObjectivesContent, Storyline_NPCFrameObjectives, "TOP");
					setTooltipForSameFrame(Storyline_NPCFrameObjectives, "TOP", 0, 0, nil, nil);
					Storyline_MainTooltip:Hide();
					Storyline_NPCFrameObjectivesYes:Show();
					setTooltipForSameFrame(Storyline_NPCFrameObjectivesNo, "TOP", 0, 0,loc("SL_DECLINE"));
					Storyline_NPCFrameObjectivesNo:Show();
					Storyline_NPCFrameChatNextText:SetText(loc("SL_ACCEPTANCE"));
				else
					AcceptQuest();
				end
			end,
		},
		["QUEST_PROGRESS"] = {
			text = GetProgressText,
			finishMethod = function()
				if not Storyline_NPCFrameObjectivesContent:IsVisible() then
					configureHoverFrame(Storyline_NPCFrameObjectivesContent, Storyline_NPCFrameObjectives, "TOP");
					setTooltipForSameFrame(Storyline_NPCFrameObjectives, "TOP", 0, 0, nil, nil);
					Storyline_MainTooltip:Hide();
					if IsQuestCompletable() then
						Storyline_NPCFrameObjectives.OK:Show();
						Storyline_NPCFrameChatNextText:SetText(loc("SL_CONTINUE"));
						playerModel:PlayAnimation(ANIMATIONS.YES);
					else
						Storyline_NPCFrameChatNextText:SetText(loc("SL_NOT_YET"));
						playerModel:PlayAnimation(ANIMATIONS.NO);
					end
				elseif IsQuestCompletable() then
					CompleteQuest();
				else
					CloseQuest();
				end
			end,
			finishText = function()
				return loc("SL_CHECK_OBJ");
			end,
			cancelMethod = CloseQuest,
			titleGetter = GetTitleText,
		},
		["QUEST_COMPLETE"] = {
			text = GetRewardText,
			finishMethod = function()
				local rewardsBucket, bestIcon, totalNumberOfRewards = Rewards.getRewards();

				if not Storyline_NPCFrameRewards.Content:IsVisible() and totalNumberOfRewards > 0 then
					configureHoverFrame(Storyline_NPCFrameRewards.Content, Storyline_NPCFrameRewardsItem, "TOP");
					setTooltipForSameFrame(Storyline_NPCFrameRewardsItem, "TOP", 0, 0);
					Storyline_MainTooltip:Hide();
					if GetNumQuestChoices() > 1 then
						Storyline_NPCFrameChatNextText:SetText(loc("SL_SELECT_REWARD"));
						Storyline_NPCFrameChatNext:Disable();
					else
						Storyline_NPCFrameChatNextText:SetText(loc("SL_CONTINUE"));
					end
				elseif GetNumQuestChoices() == 1 then
					GetQuestReward(1);
					autoEquip(GetQuestItemLink("choice", 1));
					autoEquipAllReward();
				elseif GetNumQuestChoices() == 0 then
					GetQuestReward();
					autoEquipAllReward();
				end
			end,
			finishText = function()
				local rewardsBucket, bestIcon, totalNumberOfRewards = Rewards.getRewards();

				return totalNumberOfRewards > 0 and loc("SL_GET_REWARD") or Storyline_NPCFrameChatNextText:SetText(loc("SL_CONTINUE"));
			end,
			cancelMethod = CloseQuest,
			titleGetter = GetTitleText,
		},
		["GOSSIP_SHOW"] = {
			text = GetGossipText,
			finishMethod = function()
				local firstChoice, bucketType, index = Dialogs.getFirstChoice(Dialogs.EVENT_TYPES.GOSSIP_SHOW);

				if firstChoice and Dialogs.getDialogChoiceSelectorForEventType(Dialogs.EVENT_TYPES.GOSSIP_SHOW, bucketType) then
					debug(("GOSSIP_SHOW – Finish method : Using selector method found for bucket type %s at index %s."):format(bucketType, index));
					Dialogs.getDialogChoiceSelectorForEventType(Dialogs.EVENT_TYPES.GOSSIP_SHOW, bucketType)(index);
				else
					debug("GOSSIP_SHOW – Finish method : No valid options found, fallback to closing dialog.");
					CloseGossip();
				end
			end,
			finishText = function()
				local finishText = GOODBYE;
				local firstChoice = Dialogs.getFirstChoice(Dialogs.EVENT_TYPES.GOSSIP_SHOW);

				if firstChoice then
					finishText = firstChoice.title;
					debug(("GOSSIP_SHOW – Finish text : Found first choice with text %s."):format(finishText));
				else
					debug(("GOSSIP_SHOW – Finish text : Could not find a first choice, using default finish text %s."):format(finishText));
				end

				return finishText;
			end,
			cancelMethod = CloseGossip,
		},
		--[[ TODO REMOVE
		["REPLAY"] = {
			titleGetter = function()
				local questTitle = GetQuestLogTitle(GetQuestLogSelection());
				return questTitle;
			end,
			nameGetter = function()
				return QUEST_LOG;
			end,
			finishText = CLOSE,
		}]]
	};
	Storyline_API.EVENT_INFO = EVENT_INFO;

	local storylineFrameShouldOpen = false;

	for event, info in pairs(EVENT_INFO) do
		Ellyb.GameEvents.registerCallback(event, function(...)

			-- Reset special frame stuff
			-- TODO Move that in a nice place later
			Storyline_QuestInfoSealFrame.Texture:SetTexture(nil);
			Storyline_QuestInfoSealFrame.Text:SetText("");
			Storyline_QuestInfoSealFrame:Hide();
			Storyline_NPCFrameChatName:Show();
			frameSpecialAtlas:SetAlpha(0);
			frameBackground:SetAlpha(0.5)

			if Storyline_Data.config.disableInInstances then
				if IsInInstance() then
					return
				end
			end
			if Storyline_Data.config.disableInDMF then
				local _, _, _, mapID = UnitPosition("player");
				if mapID and mapID == 974 then
					return
				end
			end

			if event == "QUEST_DETAIL" or event == "QUEST_COMPLETE" then
				displaySpecialDetails();
			end

			-- Thanks to Blizzard for firing GOSSIP_SHOW and then GOSSIP_CLOSED when ForceGossip is false...
			if not ForceGossip() then
				storylineFrameShouldOpen = true;
				C_Timer.After(0.5, function()
					if storylineFrameShouldOpen then
						startDialog("npc", info.text(), event, info);
					end
				end)
			else
				startDialog("npc", info.text(), event, info);
			end
		end);
	end

	Ellyb.GameEvents.registerCallback("UNIT_PORTRAIT_UPDATE", function(unit)
		if unit == "player" and Storyline_NPCFrame:IsVisible() then
			playerModel:SetModelUnit("player", false):Success(Storyline_API.onModelsLoaded);
		end
	end)

	Ellyb.GameEvents.registerCallback("QUEST_ITEM_UPDATE", RewardsButtons.refreshButtons);
	Ellyb.GameEvents.registerCallback("GOSSIP_CLOSED", function()
		storylineFrameShouldOpen = false;
	end);

	-- UI
	setTooltipAll(Storyline_NPCFrameChatPrevious, "BOTTOM", 0, 0, loc("SL_RESET"), loc("SL_RESET_TT"));
	setTooltipForSameFrame(Storyline_NPCFrameObjectivesYes, "TOP", 0, 0,  loc("SL_ACCEPTANCE"));
	setTooltipForSameFrame(Storyline_NPCFrameObjectivesNo, "TOP", 0, 0, loc("SL_DECLINE"));
	Storyline_NPCFrameObjectivesYes:SetScript("OnClick", AcceptQuest);
	Storyline_NPCFrameObjectivesYes:SetScript("OnEnter", function(self)
		playerModel:PlayAnimation(ANIMATIONS.CHEER);
		refreshTooltipForFrame(self);
	end);
	Storyline_NPCFrameObjectivesNo:SetScript("OnClick", DeclineQuest);
	Storyline_NPCFrameObjectivesNo:SetScript("OnEnter", function(self)
		playerModel:PlayAnimation(ANIMATIONS.NO);
		refreshTooltipForFrame(self);
	end);

	Storyline_NPCFrameObjectives:SetScript("OnClick", function() EVENT_INFO["QUEST_PROGRESS"].finishMethod(); end);
	Storyline_NPCFrameObjectivesContent.Title:SetText(QUEST_OBJECTIVES);
	Storyline_NPCFrameObjectivesContent.RequiredItemText:SetText(TURN_IN_ITEMS);

	Storyline_NPCFrameRewardsItem:SetScript("OnClick", function() EVENT_INFO["QUEST_COMPLETE"].finishMethod(); end);
	Storyline_NPCFrameRewards.Content.Title:SetText(REWARDS);

	-- Hook reward
	hooksecurefunc("QuestInfo_ShowRewards", hideQuestRewardFrameIfNeed);

	local function goBackOnRightClick(_, button)
		if button == "RightButton" then
			Storyline_API.goBackToPreviousStep();
		end
	end

	Storyline_NPCFrameObjectivesContent:SetScript("OnMouseDown", goBackOnRightClick);
	Storyline_NPCFrameRewards.Content:SetScript("OnMouseDown", goBackOnRightClick);
end
