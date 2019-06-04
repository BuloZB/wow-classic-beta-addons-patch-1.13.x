------------------------------------------------------------------------------
-- SellableItemDrops - Logging your sellable item drops
------------------------------------------------------------------------------
-- Changelog.lua
--
-- Author: Caraxe/Expelliarmuuuuus / All Rights Reserved
--
-- Version 0.4.9
------------------------------------------------------------------------------
local addonName, addon = ...
------------------------------------------------------------------------------

addon.Changelog = {}

addon.Changelog.Changelog =
[[

## Changelog ##

v0.3.4: 
 - Alt-Rightclick to delete a single item
v0.3.5: 
 - LSM + Tooltip fix, 7.0.3
v0.3.6: 
 - Adjusting Item Cache calls
v0.3.7: 
 - Announcing new transmog items (using Can I Mog It?)
v0.3.8: 
 - Options to reduce addon spam about looted stuff
v0.3.9: 
 - Fix for SoundPlay() in 7.3.0
v0.3.10: 
 - Fix for Pet Farm Challenge Runs and vendorsell items
v0.4.7: 
 - Rewrite as standalone addon and compatible with UJ, TSM 3 and 4.
v0.4.8: 
 - Fix: deleting items mit Alt-Right-Click
 - Fix: update item lists if GetItemInfo() failed
 - New: extra vendorsell item list option
 - New: lesser size if shrinked
]]

addon.Changelog.ToDo =
[[

## Things To Do ##

- key = Item:GetItemInfo(val) stuff
- fix for Auctionator
- convert and/or import old data, clean up variables
- ACE3 profile support?
- Tools Tab: Statistics, Data Export
- Search Tab over all sessions
]]

addon.Changelog.infotext =
[[
Sellable Item Drops remembers your looted items.

A list shows the name, time, location of each dropped item and its market value based on a selectable Trade Skill Master v3 or v4 or The Undermine Journal price source.

The current session data can be archived in a database and that database of previous sessions can be searched for items and more.

Sellable Item Drops is helpful during competitive Transmog Challenge Runs or when farming instances to track the accumulated market value of all dropped items over a given time period.

Looted BOP pet items display their corresponding caged pet value. Pet Farm Challenges are therefor supported.

Sellable Item Drops provides a sortable list of all dropped items to identify rewarding farm locations or to document found items for yourself or others.

Sellable Item Drops works without any additional addons and then displays the vendor sell value of the items.

However, it may also use price sources from The Undermine Journal or Trade Skill Master Version 3 or 4. If TSM is used, the TSM Desktop App should also be installed for price source 'DBRegionMarketAvg' to be available.

The interface opens with /sid. Addon options are configured through the normal game options.

You can find me as Caraxe on Curse.com/Curseforge.com or as Expelliarmuuuuus on Twitch for suggestions and comments.
]]

addon.Changelog.infotextdeDE =
[[
Sellable Item Drops merkt sich alle erbeuteten und verkaufbaren Gegenstände, die während einer Farmsitzung droppen.

Es zeigt deren Namen, Fundort, Zeitpunkt und Marktwert, der durch eine einstellbare 'Trade Skill Master' oder 'The Undermine Journal'-Preisquelle ermittelt wird.

Alle Gegenstände werden in einer sortierbaren und durchsuchbaren Liste angezeigt. Über eine integrierte Chronik können auch die Ergebnisse vergangener Sitzungen angezeigt werden.

Zusätzlich werden 'Transmog Challenge Runs' unterstützt, bei denen im Wettstreit mit anderen versucht wird, den höchsten Marktwert aller erbeuteten Gegenstände während einer bestimmten Zeitspanne zu erreichen.

Sellable Item Drops liefert eine sortierbare Liste aller gedroppten Gegenstände um lohnende Farmorte zu identifizieren oder um gefundene Gegenstände für sich oder andere zu dokumentieren.

Sellable Item Drops funktioniert ganz ohne andere Addons und zeigt dann den Händlerverkaufswert der Items an.

Es kann jedoch auch Preisquellen von The Undermine Journal oder TradeSkillMaster Version 3 oder 4 benutzen.
Falls TSM verwendet wird, sollte auch die TSM Desktop App installiert sein, damit die Preisquelle 'DBRegionMarketAvg' zur Verfügung steht.

Für Wünsche und Fragen bin ich als Caraxe auf Curse.com/Curseforge.com oder als Expelliarmuuuuus auf Twitch zu erreichen.
]]

-- EOF
