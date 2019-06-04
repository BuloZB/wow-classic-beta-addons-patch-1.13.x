--update for level increases from expansions
local hugeLevel = 150

local ttName, TipTop = ...

--CREATE & ASSIGN FRAMES--
local evfr = CreateFrame("Frame")
local tt = GameTooltip
local ttSBar = GameTooltipStatusBar
local ttSBarBG = CreateFrame("Frame", nil, ttSBar)
local ttHealth = ttSBar:CreateFontString("ttHealth", "OVERLAY")
	ttHealth:SetPoint("CENTER")
local raidIcon = ttSBar:CreateTexture(nil, "OVERLAY")

--OTHER LOCALS--
local LSM = LibStub("LibSharedMedia-3.0")
local player = UnitName("player")
local server = GetRealmName()
local _, db, color, font, classif, talentsGUID, factionIcon, factionTable, ttStyle
local specializationText = SPECIALIZATION..":"
local tooltips = {	GameTooltip,
					ItemRefTooltip,
					ShoppingTooltip1,
					ShoppingTooltip2,
					ItemRefShoppingTooltip1,
					ItemRefShoppingTooltip2,
					WorldMapTooltip,
					WorldMapCompareTooltip1,
					WorldMapCompareTooltip2,
					AdventureMap_MissionPinTooltip,}

--UPVALUES--
local table_sort = _G.table.sort
local GetItemInfo = _G.GetItemInfo
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local SetRaidTargetIconTexture = _G.SetRaidTargetIconTexture
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitIsAFK = _G.UnitIsAFK
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsDND = _G.UnitIsDND
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsFriend = _G.UnitIsFriend
local UnitLevel = _G.UnitLevel
local UnitHealthMax = _G.UnitHealthMax
local UnitName = _G.UnitName
local UnitFactionGroup = _G.UnitFactionGroup
local UnitPlayerControlled = _G.UnitPlayerControlled
local GameTooltipTextLeft1 = GameTooltipTextLeft1
local qualityColor = ITEM_QUALITY_COLORS
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetGuildInfo = _G.GetGuildInfo
local strsplit = strsplit
local SetBorderColor = tt.SetBackdropBorderColor
local IsClassic = select(4, GetBuildInfo()) < 20000

function TipTop:SetBackgrounds()
	local backdrop = {	bgFile = LSM:Fetch("background", db.bg),
						insets = {left=db.inset, right=db.inset, top=db.inset, bottom=db.inset},
						edgeFile = LSM:Fetch("border", db.border),
						edgeSize = db.borderWidth	}
	for i = 1, #tooltips do
		tooltips[i]:SetScale(db.scale)
		tooltips[i]:SetBackdrop(backdrop)
		tooltips[i]:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
		SetBorderColor(tooltips[i], db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	end
	--copy our style to default style (can't just do ttStyle = backdrop because there's other stuff in there)
	ttStyle.bgFile = backdrop.bgFile
	ttStyle.insets = backdrop.insets
	ttStyle.edgeFile = backdrop.edgeFile
	ttStyle.edgeSize = backdrop.edgeSize
	ttStyle.tile = false
	ttStyle.tileEdge = false
	ttStyle.backdropColor:SetRGBA(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
	ttStyle.backdropBorderColor:SetRGBA(db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
end

function TipTop:SetFonts()
	font = LSM:Fetch("font", db.font)
	local size = db.fontSize
	if db.diffFont then
		ttHealth:SetFont(LSM:Fetch("font", db.healthFont), db.healthSize, "OUTLINE")
	else
		ttHealth:SetFont(font, db.healthSize, "OUTLINE")
	end
	GameTooltipHeaderText:SetFont(font, size + 2, db.fontFlag)
	GameTooltipText:SetFont(font, size, db.fontFlag)
	GameTooltipTextSmall:SetFont(font, size - 2, db.fontFlag)
	ShoppingTooltip1TextLeft1:SetFont(font, size -2, db.fontFlag)
	ShoppingTooltip1TextLeft2:SetFont(font, size, db.fontFlag)
	ShoppingTooltip1TextLeft3:SetFont(font, size -2, db.fontFlag)
	ShoppingTooltip2TextLeft1:SetFont(font, size -2, db.fontFlag)
	ShoppingTooltip2TextLeft2:SetFont(font, size, db.fontFlag)
	ShoppingTooltip2TextLeft3:SetFont(font, size -2, db.fontFlag)
	for i = 1, ShoppingTooltip1:NumLines() do
		_G["ShoppingTooltip1TextRight"..i]:SetFont(font, size -2, db.fontFlag)
	end
	for i = 1, ShoppingTooltip2:NumLines() do
		_G["ShoppingTooltip2TextRight"..i]:SetFont(font, size -2, db.fontFlag)
	end
	if GameTooltipMoneyFrame1 then
		GameTooltipMoneyFrame1PrefixText:SetFont(font, size, db.fontFlag)
		GameTooltipMoneyFrame1SuffixText:SetFont(font, size, db.fontFlag)
		GameTooltipMoneyFrame1CopperButtonText:SetFont(font, size, db.fontFlag)
		GameTooltipMoneyFrame1SilverButtonText:SetFont(font, size, db.fontFlag)
		GameTooltipMoneyFrame1GoldButtonText:SetFont(font, size, db.fontFlag)
	end
end

local SetSBarColor = ttSBar.SetStatusBarColor
ttSBar.SetStatusBarColor = function() return end
function TipTop:SBarCustom()
	ttSBar:SetStatusBarTexture(LSM:Fetch("statusbar", db.healthBar))
	SetSBarColor(ttSBar, db.sbarcolor.r, db.sbarcolor.g, db.sbarcolor.b, db.sbarcolor.a)
	ttSBarBG:SetAllPoints()
	ttSBarBG:SetFrameLevel(ttSBar:GetFrameLevel() - 1)
	ttSBarBG:SetBackdrop({bgFile = LSM:Fetch("statusbar", db.sbarbg)})
	ttSBarBG:SetBackdropColor(db.sbarbgcolor.r, db.sbarbgcolor.g, db.sbarbgcolor.b, db.sbarbgcolor.a)
end

function TipTop:SBPosition()	--call on load and when setting changed
	if db.insideBar then
		if db.topBar then
			ttSBar:ClearAllPoints()
			ttSBar:SetPoint("TOPLEFT", 7, -7)
			ttSBar:SetPoint("TOPRIGHT", -7, -7)
		else
			ttSBar:ClearAllPoints()
			ttSBar:SetPoint("BOTTOMLEFT", 7, 7)
			ttSBar:SetPoint("BOTTOMRIGHT", -7, 7)
		end
	else
		if db.topBar then
			ttSBar:ClearAllPoints()
			ttSBar:SetPoint("BOTTOMLEFT", tt, "TOPLEFT", 2, 1)
			ttSBar:SetPoint("BOTTOMRIGHT", tt, "TOPRIGHT", -2, 1)
		else
			ttSBar:ClearAllPoints()
			ttSBar:SetPoint("TOPLEFT", tt, "BOTTOMLEFT", 2, -1)
			ttSBar:SetPoint("TOPRIGHT", tt, "BOTTOMRIGHT", -2, -1)
		end
	end
end

local function AdjustTooltipBG()	--call when unit is set to tooltip
	if db.insideBar then
		if db.topBar then
			GameTooltipTextLeft1:ClearAllPoints()
			GameTooltipTextLeft1:SetPoint("TOPLEFT", 10, -23)
			tt:SetHeight(tt:GetHeight() + 13)
		else
			tt:SetHeight(tt:GetHeight() + 10)
		end
	end
end

function TipTop:FactionIcon()
	if not factionIcon then
		factionIcon = ttSBar:CreateTexture(nil, "OVERLAY")
		factionTable = {
				["Alliance"] = "Interface\\Timer\\Alliance-Logo",
				["Horde"] = "Interface\\Timer\\Horde-Logo",
				["Neutral"] = "Interface\\Timer\\Panda-Logo",
			}
	end
	factionIcon:SetWidth(db.factionIconSize)
	factionIcon:SetHeight(db.factionIconSize)
	factionIcon:SetPoint("CENTER", tt, db.factionIconPosition, db.factionIconX, db.factionIconY)
	factionIcon:Hide()
end

local function FactionIconUpdate()
	if UnitPlayerControlled("mouseover") then
		factionIcon:SetTexture(factionTable[UnitFactionGroup("mouseover")])
		factionIcon:Show()
	else
		factionIcon:Hide()
	end
end

function TipTop:RaidIcon()
	raidIcon:SetWidth(db.raidIconSize)
	raidIcon:SetHeight(db.raidIconSize)
	raidIcon:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons")
	raidIcon:SetPoint("CENTER", tt, db.raidIconPosition, db.raidIconX, db.raidIconY)
	raidIcon:Hide()
end

local function RaidIconUpdate()
	local icon = GetRaidTargetIndex("mouseover")
	if icon and icon < 9 then
		SetRaidTargetIconTexture(raidIcon, icon)
		raidIcon:Show()
	else
		raidIcon:Hide()
	end
end

local function FadedTip()	--grays out tooltip if unit is tapped or dead
	local tapped = false
	if not UnitPlayerControlled("mouseover") then
		if UnitIsTapDenied("mouseover") then
			tapped = true
		end
	end
	if UnitIsDead("mouseover") or tapped or not UnitIsConnected("mouseover") then
		local borderColor = db.borderColor
		SetBorderColor(tt, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		local bgColor = db.bgColor
		tt:SetBackdropColor(bgColor.r + .2, bgColor.g +.2, bgColor.b + .2, db.alpha-.1)
	end
end

local function Appendices()	--appends info to the name/guild of the unit - ALSO sets elite graphic
	classif = UnitClassification("mouseover")
	if db.elite then
		if not elitetexture then
			elitetexture = ttSBar:CreateTexture(nil, "OVERLAY")
			elitetexture:SetHeight(70)
			elitetexture:SetWidth(70)
			elitetexture:SetPoint("CENTER", tt, "TOPLEFT", 8, -18)
		end
		elitetexture:Hide()
	end
	
	if classif == "rare" or classif == "rareelite" then
		tt:AppendText(" (Rare)")
		if db.elite and classif == "rareelite" then
			elitetexture:SetTexture("Interface\\AddOns\\TipTop\\media\\rare_graphic")
			elitetexture:Show()
		end
	elseif classif == "elite" or classif == "worldboss" or classif == "boss" then 
		if db.elite then
			elitetexture:SetTexture("Interface\\AddOns\\TipTop\\media\\elite_graphic")
			elitetexture:Show()
		end
	end
	
	if UnitIsAFK("mouseover") then
		tt:AppendText(" (AFK)")
	elseif UnitIsDND("mouseover") then
		tt:AppendText(" (DND)")
	end
	
	if db.guildRank then
		local guild, rank, _, realm = GetGuildInfo("mouseover")
		if guild then
			local text = nil
			text = GameTooltipTextLeft2:GetText()
			if text then
				if realm then
					text = strsplit("-", text)
				end
				if text == guild then
					GameTooltipTextLeft2:SetFormattedText("%s (%s)", text, rank)
					tt:Show()
					AdjustTooltipBG()
				end
			end
		end
	end
end

local function BorderClassColor()	--colors tip border and adds class icon
	local _,class = UnitClass("mouseover")
	local level = UnitLevel("mouseover")
	local isNPC = not UnitIsPlayer("mouseover")
	if db.diffColor and level then	--if coloring by difficulty
		if db.classColor and class and UnitIsFriend("player", "mouseover") and ((isNPC and db.npcClassColor) or not isNPC) then	--if class enabled, too, use that if unit is friendly
			SetBorderColor(tt, color[class].r - .2, color[class].g - .2, color[class].b - .2, db.borderColor.a)
		else	--all else, color by difficulty
			if level == -1 then	--where a skull might show instead of a level # (account for bosses and elites being harder)
				level = hugeLevel
			elseif classif == "elite" or classif == "rareelite" then
				level = level + 3
			elseif classif == "boss" or classif == "worldboss" then
				level = level + 5
			end
			level = GetQuestDifficultyColor(level)
			SetBorderColor(tt, level.r, level.g, level.b, db.borderColor.a)
		end
	elseif db.classColor and class and ((isNPC and db.npcClassColor) or not isNPC) then	--if just coloring by class
		SetBorderColor(tt, color[class].r - .2, color[class].g - .2, color[class].b - .2, db.borderColor.a)
	else	--default border color
		local borderColor = db.borderColor
		SetBorderColor(tt, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
	end
	if db.classIcon and class and ((isNPC and db.npcClassIcon) or not isNPC)then
		local text = nil	--reset text var so as to not get a repeating icon issue...
		text = GameTooltipTextLeft1:GetText()
		if text then
			local path
			if db.classIconStyle == "Default UI" then
				path = "Interface\\TARGETINGFRAME\\UI-Classes-Circles"
			else
				path = "Interface\\AddOns\\TipTop\\media\\ClassIcons\\"..db.classIconStyle
			end
			local x1, x2, y1, y2 = unpack(CLASS_ICON_TCOORDS[class])
			GameTooltipTextLeft1:SetFormattedText("|T%s:22:22:0:0:256:256:%d:%d:%d:%d|t %s", path, x1*256, x2*256, y1*256, y2*256, text)
			tt:Show()
			AdjustTooltipBG()
		end
	end
	if db.sbarclass and class then
		SetSBarColor(ttSBar, color[class].r, color[class].g, color[class].b)
	end
end

local function ItemQualityBorder(tip)	--colors tip border by item quality
	if db.itemColor then
		local _,item = tip:GetItem()
		if item then
			local _,_,quality = GetItemInfo(item)
			if quality then
				local r, g, b = GetItemQualityColor(quality)
				if r and g and b then
					SetBorderColor(tip, r - .2, g - .2, b - .2, db.borderColor.a)
				end
			end
		end
	else
		if tip == ItemRefTooltip then
			SetBorderColor(tip, db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
		end
	end
end

local function CalcHealth(_,hp)	--sets health text on status bar
	if db.healthText then
		local per, hpmult, hpdiv, maxhpmult, maxhpdiv, hpformat, maxhpformat	--upvalues
		local maxhp = UnitHealthMax("mouseover")
		if maxhp == 0 then	--mouseover unit no longer exists
			return
		end
		local hp = hp or UnitHealth("mouseover")
		if db.textformat == "100/100" then
			hp = tostring(hp)	--needed to store huge health numbers as strings in WoD
			maxhp = tostring(maxhp)
			ttHealth:SetFormattedText("%s / %s", hp, maxhp)
		elseif db.textformat == "100%" then
			per = (hp/maxhp) * 100
			if per <= 100 then
				ttHealth:SetFormattedText("%d%%", per)
			end
		elseif db.textformat == "100/100 (100%)" then
			per = (hp/maxhp) * 100
			if per <= 100 then
				hp = tostring(hp)
				maxhp = tostring(maxhp)
				ttHealth:SetFormattedText("%s / %s (%d%%)", hp, maxhp, per)
			end
		elseif db.textformat == "1.2k/1.2k" or db.textformat == "1.2k/1.2k (100%)" then
			hpformat, maxhpformat = "%.1f", "%.1f"
			if hp >= 1000000 then
				hpmult, hpdiv = "m", 1000000
			elseif hp >= 1000 then
				hpmult, hpdiv = "k", 1000
			else
				hpmult, hpdiv = "", 1
				hpformat = "%d"
			end
			if maxhp >= 1000000 then
				maxhpmult, maxhpdiv = "m", 1000000
			elseif hp >= 1000 then
				maxhpmult, maxhpdiv = "k", 1000
			else
				maxhpmult, maxhpdiv = "", 1
				maxhpformat = "%d"
			end
			if db.textformat == "1.2k/1.2k" then
				ttHealth:SetFormattedText(hpformat.."%s / "..maxhpformat.."%s", hp/hpdiv, hpmult, maxhp/maxhpdiv, maxhpmult)
			else
				ttHealth:SetFormattedText(hpformat.."%s / "..maxhpformat.."%s (%d%%)", hp/hpdiv, hpmult, maxhp/maxhpdiv, maxhpmult, hp/maxhp*100)
			end
		end
	end
end

local function TargetTextUpdate()	--shows and updates target text
	if db.showTargetText then
		local target, tserver = UnitName("mouseovertarget")
		local _,tclass = UnitClass("mouseovertarget")
		if target and target ~= UNKNOWN and tclass then
			local targetLine
			for i=1, GameTooltip:NumLines() do	--scan tip to see if Target line is already added
				local left, right, leftText, rightText
				left = _G[GameTooltip:GetName().."TextLeft"..i]
				leftText = left:GetText()
				right = _G[GameTooltip:GetName().."TextRight"..i]
				if leftText == "Target:" then	--if already present, then just update it
					if db.you and target == player and (tserver == nil or tserver == server) then
						right:SetText("<<YOU>>")
						right:SetTextColor(.9, 0, .1)
					else
						right:SetText(target)
						right:SetTextColor(color[tclass].r,color[tclass].g,color[tclass].b)
					end
					tt:Show()
					AdjustTooltipBG()
					targetLine = true
				end
			end
			if targetLine ~= true then	--if not present, then add it
				if db.you and target == player and (tserver == nil or tserver == server) then
					tt:AddDoubleLine("Target:", "<<YOU>>", nil, nil, nil, .9, 0, .1)
				else
					local tcolor = color[tclass]
					if tcolor then
						tt:AddDoubleLine("Target:", target, nil,nil,nil,tcolor.r,tcolor.g,tcolor.b)
					end
				end
				tt:Show()
				AdjustTooltipBG(true)
			else 
				targetLine = false
			end
		end
	end
end

local function TalentQuery()	--send request for talent info
	if CanInspect("mouseover") and db.showTalentText then
		if UnitName("mouseover") ~= player and UnitLevel("mouseover") > 9 then
			local talentline = false
			for i=1, tt:NumLines() do
				local left, leftText
				left = _G["GameTooltipTextLeft"..i]
				leftText = left:GetText()
				if leftText == specializationText then
					talentline = true
					break
				end
			end
			if not talentline then
				if InspectFrame and InspectFrame:IsShown() then	--to not step on default UI's toes
					tt:AddDoubleLine(specializationText, "Inspect Frame is open", nil,nil,nil, 1,0,0)
				elseif Examiner and Examiner:IsShown() then		--same thing with Examiner
					tt:AddDoubleLine(specializationText, "Examiner frame is open", nil,nil,nil, 1,0,0)
				else
					talentsGUID = UnitGUID("mouseover")
					NotifyInspect("mouseover")
					evfr:RegisterEvent("INSPECT_READY")
					tt:AddDoubleLine(specializationText, "...")	--adds the Talents line with a placeholder for info
				end
				tt:Show()
				AdjustTooltipBG()
			end
		end
	end
end

local maxtree,left,leftText
local function TalentText()

	if UnitExists("mouseover") then
		maxtree = GetInspectSpecialization("mouseover")
		if maxtree and maxtree > 0 then
			for i=1, tt:NumLines() do
				left = _G[GameTooltip:GetName().."TextLeft"..i]
				leftText = left:GetText()
				if leftText == specializationText then	--finds the Talents line and updates with info
					_G[GameTooltip:GetName().."TextRight"..i]:SetText(select(2,GetSpecializationInfoByID(maxtree)))
					tt:Show()
					AdjustTooltipBG()
					break
				end
			end
		end
	end

	evfr:UnregisterEvent("INSPECT_READY")
	maxtree = nil	--reset this variable
end

local ttWidth
local function MouseoverTargetUpdate()	--do this stuff whenever the mouseover unit is changed
	AdjustTooltipBG()
	Appendices()
	BorderClassColor()
	CalcHealth()
	RaidIconUpdate()
	if not IsClassic then
			TalentQuery()
	end
	FadedTip()
	if db.factionIcon then
		FactionIconUpdate()
	end
	--sets min size for aesthetics and for extended health text
	ttWidth = tt:GetWidth()
	if ttWidth < 175 and db.healthText and db.textformat == "100/100 (100%)" then
		tt:SetWidth(200)
	elseif ttWidth < 125 then
		tt:SetWidth(125)
	end
end

local function PlayerLogin()
	if TipTopPCDB.charSpec then
		db = TipTopPCDB
	else
		db = TipTopDB
	end
	
	--set the default style to ours
	ttStyle = GAME_TOOLTIP_BACKDROP_STYLE_DEFAULT
	
	--totally ugly chunk of code to ensure tooltip style and colors are consistent
	tt:HookScript("OnTooltipCleared", function(self)
		if not self:GetUnit() and not self:GetItem() then
			local borderColor = db.borderColor
			SetBorderColor(self, borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		end
	end)
	hooksecurefunc("GameTooltip_SetBackdropStyle", function(self)
		SetBorderColor(self, db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	end)
	WorldMapTooltip:HookScript("OnShow", function(self)
		SetBorderColor(self, db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	end)
	-- QuestScrollFrame.StoryTooltip:HookScript("OnShow", function(self)
	-- 	self:SetBackdrop(ttStyle)
	-- 	SetBorderColor(self, db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	-- 	self:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
	-- end)
	-- QuestScrollFrame.WarCampaignTooltip:HookScript("OnShow", function(self)
	-- 	self:SetBackdrop(ttStyle)
	-- 	SetBorderColor(self, db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a)
	-- 	self:SetBackdropColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha)
	-- end)

	TipTop:SetBackgrounds()
	TipTop:SBarCustom()
	TipTop:SBPosition()
	TipTop:SetFonts()
	TipTop:RaidIcon()
	if db.factionIcon then
		TipTop:FactionIcon()
	end
	
	color = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS	--support for CUSTOM_CLASS_COLORS addons
	if CUSTOM_CLASS_COLORS then
		CUSTOM_CLASS_COLORS:RegisterCallback(function() color = CUSTOM_CLASS_COLORS end)
	end
		
	--moves tooltip
	local mover = TipTop.mover
	hooksecurefunc("GameTooltip_SetDefaultAnchor", function (tooltip, parent)
			if db.onCursor then
				tooltip:SetOwner(parent, "ANCHOR_CURSOR")
			else
				tooltip:SetOwner(parent, "ANCHOR_NONE")
				tooltip:ClearAllPoints()
				tooltip:SetPoint(db.anchor, mover)
			end
		end)
	
	--set item tooltip hook
	local moneyfontset
	for i=1,#tooltips do
		if tooltips[i]:GetScript("OnTooltipSetItem") then
			tooltips[i]:HookScript("OnTooltipSetItem", function(tip)
				ItemQualityBorder(tip)
				--the vendor price strings don't exist until the first time they're needed
				if GameTooltipMoneyFrame1 and not moneyfontset then
					TipTop:SetFonts()
					moneyfontset = true
				end
			end)
		end
		tooltips[i].SetBackdropBorderColor = function() end
	end
	
	--sb text updates
	ttSBar:HookScript("OnValueChanged", CalcHealth)
	ttSBar:HookScript("OnUpdate", TargetTextUpdate)
	
	evfr:UnregisterEvent("PLAYER_LOGIN")
	evfr:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	evfr:SetScript("OnEvent", function(_, event, arg)
			if event == "UPDATE_MOUSEOVER_UNIT" then
				MouseoverTargetUpdate()
			elseif event == "INSPECT_READY" then
				if not IsClassic then
					if talentsGUID == arg then	--only gather information about the unit we requested
						TalentText()
					end
				end
			end
		end)
	
	PlayerLogin = nil	--let this function be garbage collected
end

evfr:RegisterEvent("PLAYER_LOGIN")
evfr:SetScript("OnEvent", PlayerLogin)