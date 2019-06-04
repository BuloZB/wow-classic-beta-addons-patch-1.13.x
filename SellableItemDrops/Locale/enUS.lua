------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Locale/enUS.lua - Strings for enUS
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
local silent = true
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true, silent)
if not L then return end
------------------------------------------------------------------------------

-- SellableItemDrops.lua
L["enter /sid for interface"] = true
L["|cffff0000IMPORTANT:|r"] = true
L["There was an error loading the previous item data. "] = true
L["Heads up, recover is possible:\n"] = true
L[" 1. Logout (Character Screen is ok).\n"] = true
L[" 2. Find your game data directory WTF\\<Account>>\\SaveVariables\n"] = true
L[" 3. Delete the file "] = true
L[".lua and rename "] = true
L[".bak to"] = true
L[".lua\n"] = true
L["TSM returned no valid price sources. Please enable TSM and/or check your price source."] = true
L["Your custom price source '%s' is currently not usable."] = true
L["TSM returned the following error: %s."] = true
L["'%s' is used for now."] = true
L["Your price source '%s' is currently not usable."] = true
L["Please enable your TSM modules and/or check if your TSM desktop app is running."] = true
L["'%s' is used for now."] = true
L["Until '%s' is available, 'VendorSell' is used instead."] = true
L["Your entry of '%s' for noteworthy items is not usable. It has been reset to 500g."] = true
L["Debug is off"] = true
L["Debug is on"] = true

-- Modules\Options.lua
L["Market Value Source"] = true
L["Select your TSM market value source."] = true
L["Minimum Quality"] = true
L["Select the minimum item quality to display."] = true
L["Time Format"] = true
L["Select the format to display times."] = true
L["Misc. Options"] = true
L["Use VendorSell for Grays"] = true
L["If checked, the price source VendorSell is used for gray items instead of the market value, which is almost a really wrong value for grays."] = true
L["Use VendorSell for BOPs"] = true
L["If checked, the price source VendorSell is used for BOP items and items without a market value."] = true
L["Discard Item Variants"] = true
L["Use only the base items and discard the variants and upgrades of an item. "] = true
L["This may lead to inacurate results, because the variants and upgrades could have different vendor sell values. "] = true
L["You may switch this on for more compatibilty with Loot Appraiser. "] = true
L["Turning from on to off or vice versa does only alter the listed database contnt and does not alter the current session Looted Item Value."] = true
L["Next Lap resets all instances too"] = true
L["When pressing Next Lap button or Rightclicking on minimap icon or LDB text an instance reset is done too."] = true
L["Show Player in List"] = true
L["If checked, show the player in the item list."] = true
L["Show Time in List"] = true
L["If checked, show the time in the item list."] = true
L["Show Zone in List"] = true
L["If checked, show the zone in the item list."] = true
L["SPAM Options"] = true
L["Suppress messages about looted gold"] = true
L["If checked, no message is shown about looted gold."] = true
L["Suppress messages about looted items"] = true
L["If checked, no message is shown about looted items."] = true
L["Suppress messages about looted noteworthy items"] = true
L["If checked, no message is shown about looted noteworthy items."] = true
L["Suppress messages about new transmog items"] = true
L["If checked, no message is shown about looted new transmog items."] = true
L["Show Item ID"] = true
L["If checked, the base item id is printed in chat messages."] = true
L["Noteworthy Item Options"] = true
L["Noteworthy Item Value"] = true
L["Count items above this value and play an alarm sound."] = true
L["Noteworthy Sound"] = true
L["Select the sound file that is played if an item value is above the Noteworthy setting."] = true

-- Modules\Data.lua
L["Saving session %s."] = true
L["Loading History Data..."] = true
L["Session %s already loaded."] = true
L["Loading session %s."] = true
L["Deleting session %s."] = true
L["Bag "] = true
L["Unknown"] = true
L["Uuups, saving Item %s without ','."] = true
L["Probably no free bag space for %s."] = true
L["#%s. %sx%s (%s): %s (blacklisted)"] = true
L["#%s. %s (%s): %s (blacklisted)"] = true
L[">>> Known Transmog <<<"] = true
L[">>> New Transmog <<<"] = true
L["Session is not running, so there's no reason to look at the loot."] = true
L["Imported %s blacklisted items: %s"] = true
L["Imported %s blacklisted items."] = true
L["Imported %s vendorsell items."] = true
L["now"] = true
L["infight"] = true

-- Modules\LDB.lua
L["Resetting the instance."] = true
L["Finishing Lap #%s with Looted Item Value %s."] = true
L["Current Session"] = true
L["%sStarted at:%s"] = true
L["%sDuration:%s"] = true
L["%sDuration:%s"] = true
L["%sLooted Item Value:%s"] = true
L["%sLooted Gold:%s"] = true
L["%sGold per Hour:%s"] = true
L["%sLeft-Click%s opens the item database"] = true
L["%sRight-Click%s starts the next lap and resets the instances"] = true
L["%sRight-Click%s starts the next lap"] = true
L["Running: "] = true
L["Running (Lap #"] = true
L["Stopped: "] = true

-- Modules\GUI.lua
L["_ Hr. _ Min. ago"] = true
L["Session"] = true
L["Current Session"] = true
L["History"] = true
L["Database"] = true
L["Bags"] = true
L["Tools"] = true
L["Information"] = true
L["Information"] = true
L["T.B.D."] = true
L["Starting a new session."] = true
L["Continuing a previous session. Current Looted Item Value is %s"] = true
L["Session is stopped. A new session starts after saving or wiping the current session data."] = true
L["  Quality filter is >=%s."] = true
L["  Noteworthy items are worth >%s."] = true
L["  A custom price source '%s' is used."] = true
L["  Price source is '%s'."] = true
L["Good luck farming items!"] = true
L["All"] = true
L["Today"] = true
L["Yesterday"] = true
L["Last %d Days"] = true
L[" (! = variant)"] = true
L[" (TM = New Transmog)"] = true
L["Click to start a new lap."] = true
L["Click to start a new lap and reset all instances."] = true
L["Session Control"] = true
L["Session Start"] = true
L["Duration / Lap #"] = true
L["LIV / Gold"] = true
L["Price Source"] = true
L["Items"] = true
L["Stop"] = true
L["Click this button to stop a session."] = true
L["Stopping the session after %s. Click 'Save' or 'Wipe' to start a new one."] = true
L["Session has been stopped %s ago. Click 'Save' or 'Wipe' to start a new one."] = true
L["Next"] = true
L["Resetting the instance."] = true
L["Finishing lap #%s with Looted Item Value %s."] = true
L["Can't start lap of a stopped session."] = true
L["Save"] = true
L["Click this button to save the current session to the database and start a new session."] = true
L["Wipe"] = true
L["Click this button to wipe the current session data and start a new session. To purge a single item from the list, mouseover it and Alt+RightMouseButtonClick."] = true
L["Session Data"] = true
L["Search"] = true
L["Rarity"] = true
L["Player"] = true
L["Zone"] = true
L["Timeframe"] = true
L["Player"] = true
L["%sx %s purged."] = true
L["Data Source"] = true
L["LIV"] = true
L["Session Start"] = true
L["Duration / Lap #"] = true
L["Duration"] = true
L["LIV / Gold"] = true
L["Items"] = true
L[" (TM = New Transmog)"] = true
L["Session History Selection"] = true
L["no sessions saved"] = true
L["Session History Data"] = true
L["Click this button to delete the current session history data. To purge a single item from the list, mouseover it and Alt+RightMouseButtonClick."] = true
L["%sx %s purged."] = true
L["Bag Summary"] = true
L["Bag"] = true
L["Item"] = true
L["Item Value"] = true
L["Qty"] = true
L["Player"] = true
L["Information"] = true
L["Tools"] = true
L["T.B.D."] = true
L["%s ago"] = true


L["Stop the current session."] = true
L["Save the current session and start a new one."] = true
L["Wipe the current session data and start a new session."] = true
L["Delete the displayed history session data."] = true
L["Unknown"] = true
L["Use VendorSell as default item value"] = true
L["If checked, the price source VendorSell is used if a price source returns 0 gold."] = true
L["Display the shorter base item and discard the variants and upgrades of an item. "] = true
L["LA/LAC values"] = true
L["Use a predefined blacklist and VendorSell list to be more compatible with LA/LAC."] = true
L["If checked, the price source VendorSell is used for BOP items and if a price source returns 0."] = true
L["Discard Silver"] = true
L["If checked, any values below 1g are not displayed."] = true
L["Discard Copper"] = true
L["If checked, any values below 1s are not displayed."] = true

L["Leftclick to sort this column / Rightclick to show all columns"] = true
L["Leftclick to sort this column"] = true
L["Leftclick to sort and Rightclick to hide Player column"] = true
L["Leftclick to sort and RightClick to hide Zone column"] = true
L["Leftclick to sort and RightClick to hide Time column"] = true

L["Start"] = true
L["Dur/Lap #"] = true
L["Selection"] = true

L["Extra VendorSells"] = true
L["Use VendorSell values for blacklisted/VendorSell items from LA/LAC and some additional items."] = true
L["Imported %s extra vendorsell items."] = true

L["STOP"] = true
L["NEXT"] = true
L["SAVE"] = true
L["WIPE"] = true
L["Bag Data"] = true

-- EOF
