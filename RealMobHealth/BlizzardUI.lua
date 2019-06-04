--[[	RealMobHealth Blizzard UI Module
	by SDPhantom
	https://www.wowinterface.com/forums/member.php?u=34145	]]
------------------------------------------------------------------

local Name,AddOn=...;

----------------------------------
--[[	Helper Functions	]]
----------------------------------
local math_abs=math.abs;
local math_floor=math.floor;
local math_log10=math.log10;
local math_max=math.max;

local NumberCaps={FIRST_NUMBER_CAP,SECOND_NUMBER_CAP};
local function AbbreviateNumber(val)--	Abbreviates large numbers
	local exp=math_max(0,math_floor(math_log10(math_abs(val))));--	Calculate exponent of 10 and clamp to zero
	if exp<3 then return tostring(math_floor(val)); end--	Less than 1k, return as-is

	local factor=math_floor(exp/3);--	Exponent factor of 1k
	local precision=math_max(0,2-exp%3);--	Dynamic precision based on how many digits we have (Returns numbers like 100k, 10.0k, and 1.00k)

--	Fallback to scientific notation if we run out of units
	return ((val<0 and "-" or "").."%0."..precision.."f%s"):format(val/1000^factor,NumberCaps[factor] or "e"..(factor*3));
end

--------------------------
--[[	GameTooltip	]]
--------------------------
do
	GameTooltip:HookScript("OnTooltipSetUnit",function(self)
		local _,unit=self:GetUnit();
		if unit and AddOn.IsUnitMob(unit) then
			local cur,max=AddOn.GetHealth(unit);
			if cur and max then
				self:AddLine("Unit health is recorded.",0,1,0);
			else
				self:AddLine("Unit health is missing.",1,0,0);
			end
		end
	end);
end

--------------------------
--[[	TargetFrame	]]
--------------------------
do
	local function SetupUFStatusBarText(parent,bar)--	Create strings for TextStatusBars
		local text,left,right=	parent:CreateFontString(nil,"OVERLAY","TextStatusBarText")
					,parent:CreateFontString(nil,"OVERLAY","TextStatusBarText")
					,parent:CreateFontString(nil,"OVERLAY","TextStatusBarText");

		bar.TextString,bar.LeftText,bar.RightText=text,left,right;
		text:SetPoint("CENTER",bar,"CENTER",0,0);
		left:SetPoint("LEFT",bar,"LEFT",2,0);
		right:SetPoint("RIGHT",bar,"RIGHT",-2,0);
	end

--	TargetFrame doesn't have FontStrings for the health and mana bars
	SetupUFStatusBarText(TargetFrameTextureFrame,TargetFrameManaBar);
	SetupUFStatusBarText(TargetFrameTextureFrame,TargetFrameHealthBar);

--	Hook healthbars
	local HookedBars={};
	hooksecurefunc("UnitFrameHealthBar_Update",function(self,unit)
		if not HookedBars[self] then
			HookedBars[self]=true;
			TextStatusBar_UpdateTextString(self);--	Runs our hook below
		end
	end);

--	Replace health text with our own values
	local TextStatusBar_UpdateTextStringWithValues=TextStatusBar_UpdateTextStringWithValues;--	Local cache so we don't run our own hook indefinitely
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(bar,txt,val,min,max)
		if HookedBars[bar] and bar.unit then--	Run only on bars we've noted, can run on uninitialized ones
			local val,max=AddOn.GetHealth(bar.unit,true);--	These can be nil if we don't have enough data for speculation (Don't update in that case)
			if val and max then TextStatusBar_UpdateTextStringWithValues(bar,txt,val,min,max); end
		end
	end);
end

--------------------------
--[[	Nameplates	]]
--------------------------
do
	local HealthText={};
	hooksecurefunc(NamePlateDriverFrame,"OnNamePlateCreated",function(self,base)--	Hook Nameplate creation
		local uf=base.UnitFrame;

--		Make health FontString
		local health=uf.healthBar:CreateFontString(nil,"OVERLAY",FontName);--"NumberFontNormalSmall");
		health:SetFont("Fonts\\ArialN.ttf",10,"THICKOUTLINE");--	Fonts are easier to read when made from scratch rather than resizing an inherited one
		health:SetPoint("LEFT",0,0);
		health:SetTextColor(0,1,0);

		HealthText[uf]=health;
	end);

	hooksecurefunc("CompactUnitFrame_UpdateHealth",function(self)
		if not HealthText[self] then return; end--	This is a shared function with other UnitFrames
		local health=AddOn.GetHealth(self.displayedUnit,true) or UnitHealth(self.displayedUnit);--	Fallback if nil (Not enough data for speculation)
		HealthText[self]:SetText(AbbreviateNumber(health));
	end);
end