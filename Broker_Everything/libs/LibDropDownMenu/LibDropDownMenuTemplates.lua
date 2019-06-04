
-- Replacement of LibDropDownMenu.xml

local lib = LibStub("LibDropDownMenu");

local function buttonOnClick(self)
	lib.UIDropDownMenuButton_OnClick(self, button, down);
end

local function buttonOnEnter(self)
	if ( self.hasArrow ) then
		local level =  self:GetParent():GetID() + 1;
		local listFrame = _G["LibDropDownMenu_List"..level];
		if ( not listFrame or not listFrame:IsShown() or select(2, listFrame:GetPoint()) ~= self ) then
			lib.ToggleDropDownMenu(level, self.value, nil, nil, nil, nil, self.menuList, self.arrow);
		end
	else
		lib.CloseDropDownMenus(self:GetParent():GetID() + 1);
	end
	lib.UIDropDownMenu_StopCounting(self:GetParent());
	_G[self:GetName().."Highlight"]:Show();
	if ( self.tooltipTitle ) then
		if ( self.tooltipOnButton ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip:AddLine(self.tooltipTitle, 1.0, 1.0, 1.0);
			GameTooltip:AddLine(self.tooltipText, nil, nil, nil, true);
			GameTooltip:Show();
		else
			GameTooltip_AddNewbieTip(self, self.tooltipTitle, 1.0, 1.0, 1.0, self.tooltipText, 1);
		end
	end
end

local function buttonOnLeave(self)
	_G[self:GetName().."Highlight"]:Hide();
	lib.UIDropDownMenu_StartCounting(self:GetParent());
	GameTooltip:Hide();
end

local function buttonOnEnable(self)
	self.invisibleButton:Hide();
end

local function buttonOnDisable(self)
	self.invisibleButton:Show();
end

local function buttonColorSwatchOnClick(self)
	lib.CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1);
	_G[self:GetName().."SwatchBg"]:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	lib.UIDropDownMenu_StopCounting(self:GetParent():GetParent());
end

local function buttonColorSwatchOnEnter(self)
	CloseMenus();
	lib.UIDropDownMenuButton_OpenColorPicker(self:GetParent());
end

local function buttonColorSwatchOnLeave(self)
	_G[self:GetName().."SwatchBg"]:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	lib.UIDropDownMenu_StartCounting(self:GetParent():GetParent());
end

local function buttonInvisibleButtonOnEnter(self)
	lib.UIDropDownMenu_StopCounting(self:GetParent():GetParent());
	lib.CloseDropDownMenus(self:GetParent():GetParent():GetID() + 1);
	local parent = self:GetParent();
	if ( parent.tooltipTitle and parent.tooltipWhileDisabled) then
		if ( parent.tooltipOnButton ) then
			GameTooltip:SetOwner(parent, "ANCHOR_RIGHT");
			GameTooltip:AddLine(parent.tooltipTitle, 1.0, 1.0, 1.0);
			GameTooltip:AddLine(parent.tooltipText, nil, nil, nil, true);
			GameTooltip:Show();
		else
			GameTooltip_AddNewbieTip(parent, parent.tooltipTitle, 1.0, 1.0, 1.0, parent.tooltipText, 1);
		end
	end
end

local function buttonInvisibleButtonOnLeave(self)
	lib.UIDropDownMenu_StartCounting(self:GetParent():GetParent());
	GameTooltip:Hide();
end

local function listOnClick(self)
	self:Hide();
end

local function listOnEnter(self,motion)
	lib.UIDropDownMenu_StopCounting(self, motion);
end

local function listOnLeave(self,motion)
	lib.UIDropDownMenu_StartCounting(self, motion);
end

local function listOnUpdate(self,elapsed)
	lib.UIDropDownMenu_OnUpdate(self, elapsed);
end

local function listOnShow(self)
	for i=1, lib.UIDROPDOWNMENU_MAXBUTTONS do
		if (not self.noResize) then
			_G[self:GetName().."Button"..i]:SetWidth(self.maxWidth);
		end
	end
	if (not self.noResize) then
		self:SetWidth(self.maxWidth+25);
	end
	self.showTimer = nil;
	if ( self:GetID() > 1 ) then
		self.parent = _G["LibDropDownMenu_List"..(self:GetID() - 1)];
	end
end

local function listOnHide(self)
	lib.UIDropDownMenu_OnHide(self);
end

local function menuOnHide(self)
	lib.CloseDropDownMenus();
end

local function menuButtonOnEnter(self)
	local parent = self:GetParent();
	local myscript = parent:GetScript("OnEnter");
	if(myscript ~= nil) then
		myscript(parent);
	end
end

local function menuButtonOnLeave(self)
	local parent = self:GetParent();
	local myscript = parent:GetScript("OnLeave");
	if(myscript ~= nil) then
		myscript(parent);
	end
end

local function menuButtonOnClick(self,button)
	lib.ToggleDropDownMenu(nil, nil, self:GetParent());
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

local templates = {};

function lib.Create_DropDownMenuButton(name,parent,opts)
	local button = CreateFrame("Button",name,parent);
	button:SetSize(180,16);
	button:SetFrameLevel(parent:GetFrameLevel()+2); -- OnLoad
	button:SetScript("OnClick",buttonOnClick);
	button:SetScript("OnEnter",buttonOnEnter);
	button:SetScript("OnLeave",buttonOnLeave);
	button:SetScript("OnEnable",buttonOnEnable);
	button:SetScript("OnDisable",buttonOnDisable);

	if opts then
		if opts.id then
			button:SetID(opts.id);
		end
	end

	local text = button:CreateFontString(name.."NormalText","ARTWORK");
	text:SetPoint("LEFT",-5,0);
	button:SetFontString(text);
	button:SetNormalFontObject("GameFontHighlightSmallLeft")
	button:SetHighlightFontObject("GameFontHighlightSmallLeft");
	button:SetDisabledFontObject("GameFontDisableSmallLeft");

	local highlight = button:CreateTexture(name.."Highlight","BACKGROUND");
	highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]]);
	highlight:SetBlendMode("ADD");
	highlight:SetAllPoints();
	highlight:Hide();

	local check = button:CreateTexture(name.."Check","ARTWORK");
	check:SetTexture([[Interface\Common\UI-DropDownRadioChecks]]);
	check:SetSize(16,16);
	check:SetPoint("LEFT",0,0);
	check:SetTexCoord(0,0.5,0.5,1);

	local uncheck = button:CreateTexture(name.."UnCheck","ARTWORK");
	uncheck:SetTexture([[Interface\Common\UI-DropDownRadioChecks]]);
	uncheck:SetSize(16,16);
	uncheck:SetPoint("LEFT",0,0);
	uncheck:SetTexCoord(0.5,1,0.5,1);

	local icon = button:CreateTexture(name.."Icon","ARTWORK");
	icon:Hide();
	icon:SetSize(16,16);
	icon:SetPoint("RIGHT",0,0);

	local color = CreateFrame("Button",name.."ColorSwatch",button);
	color:Hide();
	color:SetSize(16,16);
	color:SetPoint("RIGHT",-6,0);
	color:SetScript("OnClick",buttonColorSwatchOnClick);
	color:SetScript("OnEnter",buttonColorSwatchOnEnter);
	color:SetScript("OnLeave",buttonColorSwatchOnLeave);
	color:SetNormalTexture([[Interface\ChatFrame\ChatFrameColorSwatch]]);

	local swatchBg = color:CreateTexture(name.."ColorSwatchSwatchBg","BACKGROUND");
	swatchBg:SetSize(14,14);
	swatchBg:SetPoint("CENTER",0,0);
	swatchBg:SetVertexColor(1,1,1);

	button.arrow = CreateFrame("Frame",name.."ExpandArrow",button);
	button.arrow:SetSize(16,16);
	button.arrow:SetPoint("RIGHT",0,0);

	local arrow = button.arrow:CreateTexture(nil,"ARTWORK");
	arrow:SetTexture([[Interface\ChatFrame\ChatFrameExpandArrow]]);
	arrow:SetAllPoints();

	button.invisibleButton = CreateFrame("Frame",name.."InvisibleButton",button);
	button.invisibleButton:Hide();
	button.invisibleButton:SetPoint("TOPLEFT");
	button.invisibleButton:SetPoint("BOTTOMLEFT");
	button.invisibleButton:SetPoint("RIGHT",color,"LEFT",0,0);
	button.invisibleButton:SetScript("OnEnter",buttonInvisibleButtonOnEnter);
	button.invisibleButton:SetScript("OnLeave",buttonInvisibleButtonOnLeave);

	return button;
end

function lib.Create_DropDownMenuList(name,parent,opts)
	local list = CreateFrame("Button",name,parent);
	list:Hide();
	list:SetToplevel(true);
	list:SetFrameStrata("FULLSCREEN_DIALOG");
	list:EnableMouse(true);
	list:SetScript("OnClick",listOnClick);
	list:SetScript("OnEnter",listOnEnter);
	list:SetScript("OnLeave",listOnLeave);
	list:SetScript("OnUpdate",listOnUpdate);
	list:SetScript("OnShow",listOnShow);
	list:SetScript("OnHide",listOnHide);

	if opts then
		if opts.id then
			list:SetID(opts.id);
		end
	end

	local backdrop = CreateFrame("Frame",name.."Backdrop",list);
	backdrop:SetAllPoints();
	backdrop:SetBackdrop({
		bgFile=[[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
		edgeFile=[[Interface\DialogFrame\UI-DialogBox-Border]],
		tile=true, tileSize=32, edgeSize=32,
		insets = {left=11, right=12, top=12, bottom=9}
	});

	local menuBackdrop = CreateFrame("Frame",name.."MenuBackdrop",list);
	menuBackdrop:SetAllPoints();
	menuBackdrop:SetBackdrop({
		bgFile=[[Interface\Tooltips\UI-Tooltip-Background]],
		edgeFile=[[Interface\Tooltips\UI-Tooltip-Border]],
		tile=true, edgeSize=16, tileSize=16,
		insets={left=5, right=5, top=5, bottom=4}
	});
	menuBackdrop:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	menuBackdrop:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);

	for i=1, 8 do
		lib.Create_DropDownMenuButton(name.."Button"..i,list,{id=i});
	end

	return list;
end

function lib.Create_DropDownMenu(name,parent,opts)
	local menu = CreateFrame("Frame",name);
	menu:SetSize(40,32);
	menu:SetScript("OnHide",menuOnHide);

	if opts then
		if opts.id then
			menu:SetID(opts.id);
		end
	end

	local left = menu:CreateTexture(name.."Left","ARTWORK");
	left:SetSize(25,64);
	left:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]]);
	left:SetTexCoord(0,0.1953125,0,1);
	left:SetPoint("TOPLEFT",0,17);

	local middle = menu:CreateTexture(name.."Middle","ARTWORK");
	middle:SetSize(115,64);
	middle:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]]);
	middle:SetTexCoord(0.1953125,0.8046875,0,1);
	middle:SetPoint("LEFT",left,"RIGHT",0,0);

	local right = menu:CreateTexture(name.."Right","ARTWORK");
	right:SetSize(25,64);
	right:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]]);
	right:SetTexCoord(0.8046875,1,0,1);
	right:SetPoint("LEFT",middle,"RIGHT",0,0);

	menu.Text = menu:CreateFontString(name.."Text","ARTWORK","GameFontHighlightSmall");
	menu.Text:SetNonSpaceWrap(false);
	menu.Text:SetJustifyH("RIGHT");
	menu.Text:SetSize(0,10);
	menu.Text:SetPoint("RIGHT",right,"RIGHT",-43,2);

	menu.Icon = menu:CreateTexture(name.."Icon","OVERLAY");
	menu.Icon:Hide();
	menu.Icon:SetSize(16,16);
	menu.Icon:SetPoint("LEFT",30,2);

	menu.Button = CreateFrame("Button",name.."Button",menu);
	menu.Button:SetMotionScriptsWhileDisabled(true);
	menu.Button:SetSize(24,24);
	menu.Button:SetPoint("TOPRIGHT",right,"TOPRIGHT",-16,-18);
	menu.Button:SetScript("OnEnter",menuButtonOnEnter);
	menu.Button:SetScript("OnLeave",menuButtonOnLeave);
	menu.Button:SetScript("OnClick",menuButtonOnClick);
	menu.Button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]]);
	menu.Button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]]);
	menu.Button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]]);
	menu.Button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]],"ADD");

	return menu;
end

if not _G.LibDropDownMenu_List1 then
	lib.Create_DropDownMenuList("LibDropDownMenu_List1",nil,{id=1});
	lib.Create_DropDownMenuList("LibDropDownMenu_List2",nil,{id=2});
end

