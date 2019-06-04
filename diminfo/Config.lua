local addon, ns = ...
local cfg = CreateFrame("Frame")

cfg.Positions = true
cfg.PositionsPoint = {"TOP", Minimap, 0, 10}

cfg.Time = true
cfg.TimePoint = {"TOP", Minimap, "BOTTOM", 0, 8}

cfg.Durability = true
cfg.DurabilityPoint = {"TOPLEFT", UIParent, 20, -6}

cfg.Bags = true
cfg.BagsPoint = {"LEFT", "diminfo_dura", "RIGHT", 20, 0}

cfg.Memory = true
cfg.MemoryPoint = {"LEFT", "diminfo_Bag", "RIGHT", 20, 0}
cfg.MaxAddOns = 30

cfg.System = true
cfg.SystemPoint = {"LEFT", "diminfo_Memory", "RIGHT", 20, 0}

cfg.Friends = true
cfg.FriendsPoint =  {"LEFT", "diminfo_System", "RIGHT", 20, 0}

cfg.Guild = true
cfg.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 20, 0}

cfg.Spec = false
cfg.SpecPoint = {"RIGHT", "diminfo_Bag", "LEFT", -20, 0}

cfg.Currency = false
cfg.CurrencyPoint = {"TOPRIGHT", UIParent, -600, 16}

cfg.Fonts = {STANDARD_TEXT_FONT, 16, "OUTLINE"}
cfg.ColorClass = true

ns.cfg = cfg