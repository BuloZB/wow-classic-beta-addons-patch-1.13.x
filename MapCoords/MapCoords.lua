--[[	MapCoords
	by SDPhantom
	https://www.wowinterface.com/forums/member.php?u=34145	]]
------------------------------------------------------------------

Minimap:CreateFontString("MapCoordsMinimapText","OVERLAY","NumberFontNormalSmall");
MapCoordsMinimapText:SetPoint("TOP",0,-16);
MapCoordsMinimapText:SetTextColor(1,0.875,0,0.625);
MapCoordsMinimapText:SetText("Hook Failed!");

local EventFrame=CreateFrame("Frame",nil,Minimap);
EventFrame:RegisterEvent("PLAYER_LOGIN");
EventFrame:RegisterEvent("ZONE_CHANGED_INDOORS");
EventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");

local MapID=MapUtil.GetDisplayableMapForPlayer();
EventFrame:SetScript("OnEvent",function() MapID=MapUtil.GetDisplayableMapForPlayer(); end);

EventFrame:SetScript("OnUpdate",function()
	local vector=C_Map.GetPlayerMapPosition(MapID,"player");
	if vector then
		local x,y=vector:GetXY();
		MapCoordsMinimapText:SetFormattedText((x>0 or y>0) and "%0.2f,%0.2f" or "",x*100,y*100);
	end
end);
