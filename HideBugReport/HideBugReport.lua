-- Author: Ketho (EU-Boulderfist)
-- License: Public Domain

local db
local f = CreateFrame("Frame")

local defaults = {
	version = 1,
	hide = true,
	scale = false,
	alpha = false,
}

function f:OnEvent(event, addon)
	if addon == "HideBugReport" then
		if not HideBugReportDB or HideBugReportDB.version < defaults.version then
			HideBugReportDB = CopyTable(defaults)
		end
		db = HideBugReportDB
		
		if db.hide then
			PTR_IssueReporter:Hide()
		end
		if db.scale then
			PTR_IssueReporter:SetScale(db.scale)
		end
		if db.alpha then
			PTR_IssueReporter:SetAlpha(db.alpha)
		end
		
		-- it would otherwise show itself again; called on PLAYER_ENTERING_WORLD
		hooksecurefunc(PTR_IssueReporter, "CreateMainView", function()
			PTR_IssueReporter:SetScript("OnHide", nil)
		end)
		
		-- for some reason default keybinds are unloaded after a /reload
		-- dont need to check for combat restriction on ADDON_LOADED
		if not GetBindingKey("Toggle Bug Report") then
			SetBinding("SHIFT-F6", "Toggle Bug Report")
		end
		
		self:UnregisterEvent(event)
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

for i, v in pairs({"bug", "bugreporter", "hidebugreport"}) do
	_G["SLASH_HIDEBUGREPORT"..i] = "/"..v
end

SlashCmdList.HIDEBUGREPORT = function(msg)
	local command, value = strsplit(" ", msg)
	value = tonumber(value)
	
	if command == "scale" then
		db.scale = value or 1
		PTR_IssueReporter:SetScale(db.scale)
	elseif command == "alpha" then
		db.alpha = value or 1
		PTR_IssueReporter:SetAlpha(db.alpha)
	else
		db.hide = not db.hide
		PTR_IssueReporter[db.hide and "Hide" or "Show"](PTR_IssueReporter)
	end
end
