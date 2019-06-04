-- 創建框架
local CreatePanel = function(name, w, h, parent, point)
	local panel = CreateFrame("Frame", name, UIParent)
    panel:SetWidth(w)
	panel:SetHeight(h)
	panel:SetPoint(unpack(point))
	panel:SetFrameStrata("BACKGROUND")
	panel:SetFrameLevel(2)
	panel:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,})
	panel:SetBackdropColor( .1, .1, .1, .6)
	panel:SetBackdropBorderColor( .1, .1, .1, .6)

	sd = CreateFrame("Frame", nil, panel)
	sd:SetPoint("TOPLEFT", -5, 5)
	sd:SetPoint("BOTTOMRIGHT", 5, -5)
	sd:SetFrameStrata(parent:GetFrameStrata())
	sd:SetFrameLevel(0)
	sd:SetBackdrop({edgeFile = "Interface\\addons\\diminfo\\Media\\glow", edgeSize = 5,})
	sd:SetBackdropBorderColor(0, 0, 0)

	return panel
end

-- 創建面板
local TopLeftPanel = CreatePanel("TopLeftPanel", 600, 8, UIParent, {"TOPLEFT", 10, -5})

--[[
local CreatePanel = function(name, width, height, parent, point, size)
	local Panel = CreateFrame("Frame", name, parent)
	Panel:SetWidth(width)
	Panel:SetHeight(height)
	Panel:ClearAllPoints()
	Panel:SetPoint(unpack(point))
	Panel:SetFrameStrata("BACKGROUND")
	Panel:SetFrameLevel(0)
	Panel:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\addons\\diminfo\\Media\\glow",
		edgeSize = size or 3,
		insets = {left = size, right = size, top = size, bottom = size}
		})
	
	Panel:SetBackdropColor( .1, .1, .1, .6)
	Panel:SetBackdropBorderColor( 0, 0, 0)
	

	local fadeIn = Panel:CreateAnimationGroup()
	fadeIn:SetLooping("BOUNCE")
	fadeIn.anim = fadeIn:CreateAnimation("Alpha")
	fadeIn.anim:SetFromAlpha(.4)
	fadeIn.anim:SetToAlpha(1)
	fadeIn.anim:SetDuration(3)
	fadeIn.anim:SetSmoothing("IN")
	fadeIn:Play()
	return panel
end

local TLP = CreatePanel("TLP", 540, 14, UIParent, {"TOPLEFT", 10, -5}, 5)

]]--