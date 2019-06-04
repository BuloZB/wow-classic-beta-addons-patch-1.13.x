

-- ******************************** Constants *******************************
local TITAN_RELOADUI_ID = "ReloadUI";
local TITAN_RELOADUIRIGHT_ID = "ReloadUIRight";
local TITAN_RELOADUI_VERSION = "1.0";

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)

-- ******************************** Variables *******************************

-- ******************************** Functions *******************************

function TitanPanelReloadUIButton_OnLoad(self)
	self.registry = {
		id = TITAN_RELOADUI_ID,
		category = "Interface",
		version = TITAN_RELOADUI_VERSION,
		menuText = "ReloadUI Button",
		buttonTextFunction = "TitanPanelReloadUIButton_GetButtonText",
		tooltipTitle = "Reload UI",
		tooltipTextFunction = "TitanPanelReloadUIButton_GetTooltipText",
		icon = "Interface\\AddOns\\TitanReloadUI\\Artwork\\TitanReload",
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true
		},
		savedVariables = {
			ShowIcon = true,
			ShowLabelText = true
		}
	};

end

function TitanPanelReloadUIRightButton_OnLoad(self)
	self.registry = {
		id = TITAN_RELOADUIRIGHT_ID,
		category = "Interface",
		version = TITAN_RELOADUI_VERSION,
		menuText = "ReloadUI Button (Right)",
		buttonTextFunction = "TitanPanelReloadUIRightButton_GetButtonText",
		tooltipTitle = "Reload UI",
		tooltipTextFunction = "TitanPanelReloadUIRightButton_GetTooltipText",
		icon = "Interface\\AddOns\\TitanReloadUI\\Artwork\\TitanReload",
		iconWidth = 16,
		--controlVariables = {
		--	ShowIcon = true,
		--	ShowLabelText = true
		--},
		--savedVariables = {
		--	ShowIcon = true,
		--	ShowLabelText = true
		--}
	};

end
-------------------------------------------------------------------------------------------------------------------


function TitanPanelReloadUIButton_GetTooltipText()
	return "Click: |cffeda55fReloads the User Interface|r\nRight-Click: |cffeda55fOpen the options menu|r"
end

function TitanPanelReloadUIRightButton_GetTooltipText()
	return "Click: |cffeda55fReloads the User Interface|r\nRight-Click: |cffeda55fOpen the options menu|r"

end

-------------------------------------------------------------------------------------------------------------------



function TitanPanelReloadUIButton_GetButtonText(id)
	--return "Reload UI"
	if (TitanGetVar(TITAN_RELOADUI_ID, "ShowLabelText")) then
		return "Reload UI"
	else
		return ""
	end
end

function TitanPanelReloadUIRightButton_GetButtonText(id)
	--return "Reload UI"
	if (TitanGetVar(TITAN_RELOADUIRIGHT_ID, "ShowLabelText")) then
		return "Reload UI"
	else
		return ""
	end
end

-------------------------------------------------------------------------------------------------------------------


function TitanPanelReloadUIButton_OnClick(self, button)
	if (button == "LeftButton") then
		ReloadUI();
	end
end

function TitanPanelReloadUIRightButton_OnClick(self, button)
	if (button == "LeftButton") then
		ReloadUI();
	end
end

-------------------------------------------------------------------------------------------------------------------
function TitanPanelRightClickMenu_PrepareReloadUIMenu()

	TitanPanelRightClickMenu_AddToggleIcon(TITAN_RELOADUI_ID);
	TitanPanelRightClickMenu_AddToggleLabelText(TITAN_RELOADUI_ID);
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_RELOADUI_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

function TitanPanelRightClickMenu_PrepareReloadUIRightMenu()

	--TitanPanelRightClickMenu_AddToggleIcon(TITAN_RELOADUIRIGHT_ID);
	--TitanPanelRightClickMenu_AddToggleLabelText(TITAN_RELOADUIRIGHT_ID);
	--TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(L["TITAN_PANEL_MENU_HIDE"], TITAN_RELOADUIRIGHT_ID, TITAN_PANEL_MENU_FUNC_HIDE);
end

