-- **************************************************************************
-- * TitanShard.lua
-- *
-- * By: Kheledhir, inspired by TitanAmmo
-- **************************************************************************

-- ******************************** Constants *******************************
local TITAN_SHARD_ID = "Shard";
local TITAN_SHARD_THRESHOLD_TABLE = {
     Values = { 8,16,24 },
     Colors = { RED_FONT_COLOR, ORANGE_FONT_COLOR, NORMAL_FONT_COLOR, GREEN_FONT_COLOR },

}

GSoulShardText = "Soul Shard"
if ( GetLocale() == "deDE" ) then GSoulShardText = "Seelensplitter" end
if ( GetLocale() == "frFR" ) then GSoulShardText = "Fragment d'\195\162me" end

local Ammos = { "Light Shot","Solid Shot","Rough Arrow","Sharp Arrow","Razor Arrow",
				"Feathered Arrow","Precision Arrow","Jagged Arrow","Ice Threaded Arrow","Thorium Headed Arrow",
				"Doomshot","Wicked Arrow","Flash Pellet","Heavy Shot","Smooth Pebble",
				"Exploding Shot","Hi-Impact Mithril Slugs","Accurate Slugs","Mithril Gyro-Shot","Ice Threaded Bullet",
				"Thorium Shells","Rockshard Pellets","Miniature Cannon Balls","Impact Shot","___"}

		
-- ******************************** Variables *******************************

local class = select(2, UnitClass("player"))
local TSise,TSisHunter;
if class == "WARLOCK" then TSisWarlock = true else TSisWarlock = false end
if class == "HUNTER" then TSisHunter = true else TSisHunter = false end

local count = 0;

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)


-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelShardButton_OnLoad()
-- DESC : Registers the plugin upon it loading
-- **************************************************************************
function TitanPanelShardButton_OnLoad(self)

	-- little lazy tweak to show ammo instead if you are a Hunter... (english only)
	if TSisHunter then
		TITAN_SHARD_BUTTON_LABEL_SHARD = "Ammo: ";
		TITAN_SHARD_TOOLTIP = "Ammo";
		TITAN_SHARD_MENU_TEXT = "Ammo";
		TITAN_SHARD_BUTTON_NOSHARD = "No Ammo";
	end;

		self.registry = {
			id = TITAN_SHARD_ID,
			builtIn = 1,
			version = TITAN_VERSION,
			menuText = TITAN_SHARD_MENU_TEXT,
			buttonTextFunction = "TitanPanelShardButton_GetButtonText", 
			tooltipTitle = TITAN_SHARD_TOOLTIP,
			icon = "Interface\\AddOns\\TitanShard\\TitanSoul",
			iconWidth = 16,
			savedVariables = {
               ShowIcon = 1,
               ShowLabelText = 1,
               ShowColoredText = 1,
               ShowShardName = false,
			}
		};     

		self:SetScript("OnEvent",  function(_, event, arg1, ...)				
			if event == "PLAYER_LOGIN" then
				TitanPanelShardButton_PLAYER_LOGIN()
			elseif event == "UNIT_INVENTORY_CHANGED" then
				TitanPanelShardButton_UNIT_INVENTORY_CHANGED(arg1, ...)
			elseif event == "ACTIONBAR_HIDEGRID" then
				TitanPanelShardButton_ACTIONBAR_HIDEGRID()
			elseif event == "PLAYER_ENTERING_WORLD" then
				TitanPanelShardButton_PLAYER_ENTERING_WORLD()
			elseif event == "BAG_UPDATE" then
				TitanPanelShardButton_BAG_UPDATE(arg1, ...)
			end				
		end)
		TitanPanelShardButton:RegisterEvent("PLAYER_LOGIN")	
end

function TitanPanelShardButton_PLAYER_LOGIN()
-- Class check
	if (class ~= "WARLOCK") and (class ~= "HUNTER") then
		TitanPanelShardButton_PLAYER_LOGIN = nil
		return
	end

	TitanPanelShardButton:RegisterEvent("ACTIONBAR_HIDEGRID")			
	TitanPanelShardButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	TitanPanelShardButton:RegisterEvent("UNIT_INVENTORY_CHANGED")
	TitanPanelShardButton:RegisterEvent("BAG_UPDATE")
	TitanPanelShardButton_PLAYER_LOGIN = nil

	if math.floor(UnitLevel("player")/10) > 0 then
		TITAN_SHARD_THRESHOLD_TABLE.Values[1] = math.floor(UnitLevel("player")/10)
		TITAN_SHARD_THRESHOLD_TABLE.Values[1] = math.floor(UnitLevel("player")/10)*2
		TITAN_SHARD_THRESHOLD_TABLE.Values[1] = math.floor(UnitLevel("player")/10)*3
	end
	
end

function TitanPanelShardButton_PLAYER_ENTERING_WORLD() 
	TitanPanelShardCalculate();
	TitanPanelButton_UpdateButton(TITAN_SHARD_ID);
end

function TitanPanelShardButton_UNIT_INVENTORY_CHANGED(arg1, ...)
 if arg1 == "player" then
	TitanPanelShardCalculate();
 	TitanPanelButton_UpdateButton(TITAN_SHARD_ID);
 end
end

function TitanPanelShardButton_BAG_UPDATE(arg1, ...)
	TitanPanelShardUpdateDisplay()
end

function TitanPanelShardButton_ACTIONBAR_HIDEGRID()
	local prev = 0
	TitanPanelShardButton:SetScript("OnUpdate", function(_, e)
		prev = prev + e
		if prev > 2 then
			TitanPanelShardButton:SetScript("OnUpdate", nil)			
			TitanPanelShardCalculate();
			TitanPanelButton_UpdateButton(TITAN_SHARD_ID);
		end
	end)
end


function TitanPanelShardCountDisplay()
	ChatFrame1:AddMessage(count);
end

function TitanPanelShardUpdateDisplay()
	TitanPanelShardCalculate();
	TitanPanelButton_UpdateButton(TITAN_SHARD_ID);
end

-- **************************************************************************
-- NAME : TitanPanelShardCalculate()
-- DESC : Calculates the amount of Soul Shards in inventory
-- **************************************************************************
function TitanPanelShardCalculate()
	local amount = 0

	if TSisWarlock then 
		for i=0, 4, 1 do
			for j=1, GetContainerNumSlots(i), 1 do
				link = GetContainerItemLink(i, j);
				if link ~= nil then				
					if (string.find(link, GSoulShardText)) then amount = amount + 1; end
					--local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, itemName = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
					--if itemName == "Soul Shard" then amount = amount + 1; end
				end
			end
		end	
	elseif TSisHunter then
		local tex,icount
		for i=0, 4, 1 do
			for j=1, GetContainerNumSlots(i), 1 do
				link = GetContainerItemLink(i, j);
				if link ~= nil then
					for amf = 1,table.getn(Ammos) do 
						if (string.find(link, Ammos[amf])) then 
							tex,icount = GetContainerItemInfo(i, j);
							amount = amount + icount; 
						end						
					end
				end
			end
		end		
	end
	count = amount	
	
end




-- **************************************************************************
-- NAME : TitanPanelShardButton_GetButtonText(id)
-- VARS : id = button ID
-- **************************************************************************
function TitanPanelShardButton_GetButtonText(id)
     local labelText, shardText, shardRichText, color;
     
     -- safeguard to prevent malformed labels
     if not count then count = 0 end

	labelText = TITAN_SHARD_BUTTON_LABEL_SHARD;
	shardText = format(TITAN_SHARD_FORMAT, count);
     
     if (TitanGetVar(TITAN_SHARD_ID, "ShowColoredText")) then     
          color = TitanUtils_GetThresholdColor(TITAN_SHARD_THRESHOLD_TABLE, count);
          shardRichText = TitanUtils_GetColoredText(shardText, color);
     else
          shardRichText = TitanUtils_GetHighlightText(shardText);
     end
     
	 if TSisWarlock or TSisHunter then return labelText, shardRichText; else return "","" end
end


-- **************************************************************************
-- NAME : TitanPanelRightClickMenu_PrepareShardMenu()
-- DESC : Display rightclick menu options
-- **************************************************************************
function TitanPanelRightClickMenu_PrepareShardMenu()

     TitanPanelRightClickMenu_AddTitle(TitanPlugins[TITAN_SHARD_ID].menuText);
     TitanPanelRightClickMenu_AddToggleIcon(TITAN_SHARD_ID);
     TitanPanelRightClickMenu_AddToggleLabelText(TITAN_SHARD_ID);
     TitanPanelRightClickMenu_AddToggleColoredText(TITAN_SHARD_ID);
     
     TitanPanelRightClickMenu_AddSpacer();
     TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_SHARD_ID, TITAN_PANEL_MENU_FUNC_HIDE);

end