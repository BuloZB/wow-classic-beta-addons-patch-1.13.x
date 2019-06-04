local SniperTips_VendorPrice = LibStub("AceAddon-3.0"):NewAddon('SniperTips_VendorPrice');

local LibTooltip = LibStub("SniperTips-1.0");

local tipColour = { 0.2, 0.6, 1 }

function SniperTips_VendorPrice:HandleItem(self, itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount,
  itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent)
  if itemSellPrice ~= nil then
    if (itemSellPrice == 0) then
      -- do nothing
    else
      count = GetItemCount(itemLink);
      priceEach = GetCoinTextureString(itemSellPrice);
      priceAll = GetCoinTextureString(itemSellPrice * count);

      if (count > 1) then
        self:AddDoubleLine("Vendor Sell (All): ",priceAll,unpack(tipColour));
        self:AddDoubleLine("Vendor Sell (Each): ",priceEach,unpack(tipColour));
      else
        self:AddDoubleLine("Vendor Sell: ",priceAll,unpack(tipColour));
      end
    end
  end
end

LibTooltip:AddItemHandler(SniperTips_VendorPrice)
