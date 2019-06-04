-- Some postfix's for certain controls.
local Performance = "\n|cffFF0000Disabling this may increase performance|r" -- For high CPU options
local PerformanceSlight = "\n|cffFF0000Disabling this may slightly increase performance|r" -- For semi-high CPU options
local RestoreDefault = "\n|cffFFFF00Right-click to restore to default|r" -- For color pickers

TukuiConfig["enUS"] = {
	["General"] = {
		["BackdropColor"] = {
			["Name"] = "Backdrop Color",
			["Desc"] = "Set the backdrop color for all Tukui frames"..RestoreDefault,
		},

		["BorderColor"] = {
			["Name"] = "Border Color",
			["Desc"] = "Set the border color for all Tukui frames"..RestoreDefault,
		},

		["HideShadows"] = {
			["Name"] = "Hide Shadows",
			["Desc"] = "Display or hide shadows on certain Tukui frames",
		},

		["Scaling"] = {
			["Name"] = "UI Scale",
			["Desc"] = "Define how big the user interface is displayed",
		},

		["Themes"] = {
			["Name"] = "Theme",
			["Desc"] = "Applying a theme changes user interface look and feel",
		},

		["AFKSaver"] = {
			["Name"] = "AFK Screensaver",
			["Desc"] = "Enable or disable the afk screensaver",
		},
	},

	["ActionBars"] = {
		["Enable"] = {
			["Name"] = "Enable action bars",
			["Desc"] = "Derp",
		},

		["AddNewSpells"] = {
			["Name"] = "Automatically Add New Spells",
			["Desc"] = "Derp",
		},

		["EquipBorder"] = {
			["Name"] = "Equipped Item Border",
			["Desc"] = "Display Green Border on Equipped Items",
		},

		["HotKey"] = {
			["Name"] = "Hotkeys",
			["Desc"] = "Display Hotkey text on buttons",
		},

		["Macro"] = {
			["Name"] = "Macro keys",
			["Desc"] = "DIsplay macro text on buttons",
		},

		["ShapeShift"] = {
			["Name"] = "Stance Bar",
			["Desc"] = "Enable Tukui style stance bar",
		},

		["Pet"] = {
			["Name"] = "Pet Bar",
			["Desc"] = "Enable Tukui style pet bar",
		},

		["SwitchBarOnStance"] = {
			["Name"] = "Swap main bar on new stance",
			["Desc"] = "Enable main action bar swap when you change stance.",
		},

		["NormalButtonSize"] = {
			["Name"] = "Button Size",
			["Desc"] = "Set a size for action bar buttons",
		},

		["PetButtonSize"] = {
			["Name"] = "Pet Button Size",
			["Desc"] = "Set a size for pet action bar buttons",
		},

		["ButtonSpacing"] = {
			["Name"] = "Button Spacing",
			["Desc"] = "Set the spacing between action bar buttons",
		},

		["HideBackdrop"] = {
			["Name"] = "Hide Backdrop",
			["Desc"] = "Disable the backdrop on action bars",
		},

		["Font"] = {
			["Name"] = "Action bar font",
			["Desc"] = "Set a font for the action bars",
		},
	},

	["Auras"] = {
		["Enable"] = {
			["Name"] = "Enable Auras",
			["Desc"] = "Derp",
		},

		["Flash"] = {
			["Name"] = "Flash Auras",
			["Desc"] = "Flash auras when their duration is low"..PerformanceSlight,
		},

		["ClassicTimer"] = {
			["Name"] = "Classic Timer",
			["Desc"] = "Use the text timer beneath auras",
		},

		["HideBuffs"] = {
			["Name"] = "Hide Buffs",
			["Desc"] = "Disable buff display",
		},

		["HideDebuffs"] = {
			["Name"] = "Hide Debuffs",
			["Desc"] = "Disable debuff display",
		},

		["Animation"] = {
			["Name"] = "Animation",
			["Desc"] = "Show a 'pop in' animation on auras"..PerformanceSlight,
		},

		["BuffsPerRow"] = {
			["Name"] = "Buffs Per Row",
			["Desc"] = "Set the number of buffs to show before creating a new row",
		},

		["Font"] = {
			["Name"] = "Aura font",
			["Desc"] = "Set a font for auras",
		},
	},

	["Bags"] = {
		["Enable"] = {
			["Name"] = "Enable Bags",
			["Desc"] = "Derp",
		},

		["ButtonSize"] = {
			["Name"] = "Slot Size",
			["Desc"] = "Set a size for bag slots",
		},

		["Spacing"] = {
			["Name"] = "Spacing",
			["Desc"] = "Set the spacing between bag slots",
		},

		["ItemsPerRow"] = {
			["Name"] = "Items Per Row",
			["Desc"] = "Set how many slots are on each row of the bags",
		},

		["PulseNewItem"] = {
			["Name"] = "Flash New Item(s)",
			["Desc"] = "New items in your bags will have a flash animation",
		},

		["Font"] = {
			["Name"] = "Bag font",
			["Desc"] = "Set a font for bags",
		},
	},

	["Chat"] = {
		["Enable"] = {
			["Name"] = "Enable Chat",
			["Desc"] = "Derp",
		},

		["WhisperSound"] = {
			["Name"] = "Whisper Sound",
			["Desc"] = "Play a sound when receiving a whisper",
		},

		["LinkColor"] = {
			["Name"] = "URL Link Color",
			["Desc"] = "Set a color to display URL links in"..RestoreDefault,
		},

		["LinkBrackets"] = {
			["Name"] = "URL Link Brackets",
			["Desc"] = "Display URL links wrapped in brackets",
		},

		["Background"] = {
			["Name"] = "Chat Background",
			["Desc"] = "Create a background for the left and right chat frames",
		},

		["ChatFont"] = {
			["Name"] = "Chat Font",
			["Desc"] = "Set a font to be used by chat",
		},

		["TabFont"] = {
			["Name"] = "Chat Tab Font",
			["Desc"] = "Set a font to be used by chat tabs",
		},

		["ScrollByX"] = {
			["Name"] = "Mouse Scrolling",
			["Desc"] = "Set the number of lines that the chat will jump when scrolling",
		},

		["ShortChannelName"] = {
			["Name"] = "Reduced channel name",
			["Desc"] = "Reduces the names of the channels of the chat in abbreviation",
		},
	},

	["Cooldowns"] = {
		["Font"] = {
			["Name"] = "Cooldown Font",
			["Desc"] = "Set a font to be used by cooldown timers",
		},
	},

	["DataTexts"] = {
		["Battleground"] = {
			["Name"] = "Enable Battleground",
			["Desc"] = "Enable data texts displaying battleground information",
		},

		["LocalTime"] = {
			["Name"] = "Local Time",
			["Desc"] = "Use local time in the Time data text, rather than realm time",
		},

		["Time24HrFormat"] = {
			["Name"] = "24-Hour Time Format",
			["Desc"] = "Enable to set the Time data text to 24 hour format.",
		},

		["NameColor"] = {
			["Name"] = "Label Color",
			["Desc"] = "Set a color for the label of a data text, usually the name"..RestoreDefault,
		},

		["ValueColor"] = {
			["Name"] = "Value Color",
			["Desc"] = "Set a color for the value of a data text, usually a number"..RestoreDefault,
		},

		["Font"] = {
			["Name"] = "Data Text Font",
			["Desc"] = "Set a font to be used by the data texts",
		},
	},

	["Loot"] = {
		["Enable"] = {
			["Name"] = "Enable Loot",
			["Desc"] = "Enable our loot frame window",
		},

		["StandardLoot"] = {
			["Name"] = "Blizzard Loot Frame",
			["Desc"] = "Replace our loot frame with a skinned version of Blizzard loot frame",
		},
	},

	["Merchant"] = {
		["AutoSellGrays"] = {
			["Name"] = "Auto Sell Grays",
			["Desc"] = "When visiting a vendor, automatically sell gray quality items",
		},

		["AutoRepair"] = {
			["Name"] = "Auto Repair",
			["Desc"] = "When visiting a repair merchant, automatically repair our gear",
		},

		["UseGuildRepair"] = {
			["Name"] = "Use Guild Repair",
			["Desc"] = "When using 'Auto Repair', use funds from the Guild bank",
		},
	},

	["Misc"] = {
		["ThreatBarEnable"] = {
			["Name"] = "Enable Threat Bar",
			["Desc"] = "Derp",
		},

		["AltPowerBarEnable"] = {
			["Name"] = "Enable Alt-Power Bar",
			["Desc"] = "Derp",
		},

		["ExperienceEnable"] = {
			["Name"] = "Enable Experience Bars",
			["Desc"] = "Enable two experience bars on the left and right of the screen.",
		},

		["ReputationEnable"] = {
			["Name"] = "Enable Reputation Bars",
			["Desc"] = "Enable two reputation bars on the left and right of the screen.",
		},

		["ErrorFilterEnable"] = {
			["Name"] = "Enable Error Filtering",
			["Desc"] = "Filters out messages from the UIErrorsFrame.",
		},

		["AutoInviteEnable"] = {
			["Name"] = "Enable Auto Invites",
			["Desc"] = "Automatically accept group invites from friends, and guild members.",
		},

		["TalkingHeadEnable"] = {
			["Name"] = "Enable Talking Head",
			["Desc"] = "Display Blizzard Talking Head Frame.",
		},
	},

	["NamePlates"] = {
		["Enable"] = {
			["Name"] = "Enable Nameplates",
			["Desc"] = "Derp"..PerformanceSlight,
		},

		["Width"] = {
			["Name"] = "Set Width",
			["Desc"] = "Set the width of NamePlates",
		},

		["Height"] = {
			["Name"] = "Set Height",
			["Desc"] = "Set the height of NamePlates",
		},

		["CastHeight"] = {
			["Name"] = "Cast Bar Height",
			["Desc"] = "Set the height of the cast bar on NamePlates",
		},

		["Font"] = {
			["Name"] = "NamePlates Font",
			["Desc"] = "Set a font for nameplates",
		},

		["OnlySelfDebuffs"] = {
			["Name"] = "Display my debuffs only",
			["Desc"] = "Only display our debuffs on nameplates",
		},
	},

	["Party"] = {
		["Enable"] = {
			["Name"] = "Enable Party Frames",
			["Desc"] = "Derp",
		},

		["HealBar"] = {
			["Name"] = "HealComm",
			["Desc"] = "Display a bar showing incoming heals & absorbs",
		},

		["ShowPlayer"] = {
			["Name"] = "Show Player",
			["Desc"] = "Show yourself in the party",
		},

		["ShowHealthText"] = {
			["Name"] = "Health Text",
			["Desc"] = "Show the amount of health the unit lost.",
		},

		["Font"] = {
			["Name"] = "Party Frame Name Font",
			["Desc"] = "Set a font for name text on party frames",
		},

		["HealthFont"] = {
			["Name"] = "Party Frame Health Font",
			["Desc"] = "Set a font for health text on party frames",
		},

		["RangeAlpha"] = {
			["Name"] = "Out Of Range Alpha",
			["Desc"] = "Set the transparency of units that are out of range",
		},
	},

	["Raid"] = {
		["Enable"] = {
			["Name"] = "Enable Raid Frames",
			["Desc"] = "Derp",
		},

		["ShowPets"] = {
			["Name"] = "Show Pets",
			["Desc"] = "Derp",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "Raid members per column",
			["Desc"] = "Change the max number of raid members per column",
		},

		["HealBar"] = {
			["Name"] = "HealComm",
			["Desc"] = "Display a bar showing incoming heals & absorbs",
		},

		["AuraWatch"] = {
			["Name"] = "Aura Watch",
			["Desc"] = "Display timers for class specific buffs in the corners of the raid frames",
		},

		["AuraWatchTimers"] = {
			["Name"] = "Aura Watch Timers",
			["Desc"] = "Display a timer on debuff icons created by Debuff Watch",
		},

		["DebuffWatch"] = {
			["Name"] = "Debuff Watch",
			["Desc"] = "Display a big icon on the raid frames when a player has an important debuff",
		},

		["RangeAlpha"] = {
			["Name"] = "Out Of Range Alpha",
			["Desc"] = "Set the transparency of units that are out of range",
		},

		["ShowRessurection"] = {
			["Name"] = "Show Ressurection Icon",
			["Desc"] = "Display incoming ressurections on players",
		},

		["ShowHealthText"] = {
			["Name"] = "Health Text",
			["Desc"] = "Show the amount of health the unit lost.",
		},

		["VerticalHealth"] = {
			["Name"] = "Vertical Health",
			["Desc"] = "Display health lost vertically",
		},

		["Font"] = {
			["Name"] = "Raid Frame Name Font",
			["Desc"] = "Set a font for name text on raid frames",
		},

		["HealthFont"] = {
			["Name"] = "Raid Frame Health Font",
			["Desc"] = "Set a font for health text on raid frames",
		},

		["GroupBy"] = {
			["Name"] = "Group By",
			["Desc"] = "Define how raids groups are sorted",
		},
	},

	["Tooltips"] = {
		["Enable"] = {
			["Name"] = "Enable Tooltips",
			["Desc"] = "Derp",
		},

		["MouseOver"] = {
			["Name"] = "Mouseover",
			["Desc"] = "Enable mouseover tooltip",
		},

		["HideOnUnitFrames"] = {
			["Name"] = "Hide on Unit Frames",
			["Desc"] = "Don't display Tooltips on unit frames",
		},

		["UnitHealthText"] = {
			["Name"] = "Display Health Text",
			["Desc"] = "Display health text on the tooltip health bar",
		},

		["ShowSpec"] = {
			["Name"] = "Specialization and iLevel",
			["Desc"] = "Display player specialization and ilevel in tooltip when you press ALT",
		},

		["HealthFont"] = {
			["Name"] = "Health Bar Font",
			["Desc"] = "Set a font to be used by the health bar below unit tooltips",
		},
	},

	["Textures"] = {
		["QuestProgressTexture"] = {
			["Name"] = "Quest [Progress]",
		},

		["TTHealthTexture"] = {
			["Name"] = "Tooltip [Health]",
		},

		["UFPowerTexture"] = {
			["Name"] = "UnitFrames [Power]",
		},

		["UFHealthTexture"] = {
			["Name"] = "UnitFrames [Health]",
		},

		["UFCastTexture"] = {
			["Name"] = "UnitFrames [Cast]",
		},

		["UFPartyPowerTexture"] = {
			["Name"] = "UnitFrames [Party Power]",
		},

		["UFPartyHealthTexture"] = {
			["Name"] = "UnitFrames [Party Health]",
		},

		["UFRaidPowerTexture"] = {
			["Name"] = "UnitFrames [Raid Power]",
		},

		["UFRaidHealthTexture"] = {
			["Name"] = "UnitFrames [Raid Health]",
		},

		["NPHealthTexture"] = {
			["Name"] = "Nameplates [Health]",
		},

		["NPPowerTexture"] = {
			["Name"] = "Nameplates [Power]",
		},

		["NPCastTexture"] = {
			["Name"] = "Nameplates [Cast]",
		},
	},

	["UnitFrames"] = {
		["Enable"] = {
			["Name"] = "Enable Unit Frames",
			["Desc"] = "Derp",
		},

		["TargetEnemyHostileColor"] = {
			["Name"] = "Enemy Target Hostile Color",
			["Desc"] = "Enemy target health bar will be colored by hostility instead of by class color",
		},

		["Portrait"] = {
			["Name"] = "Enable Player & Target Portrait",
			["Desc"] = "Enable Player & Target Portrait",
		},

		["CastBar"] = {
			["Name"] = "Cast Bar",
			["Desc"] = "Enable cast bar for unit frames",
		},

		["UnlinkCastBar"] = {
			["Name"] = "Unlink Cast Bar",
			["Desc"] = "Move player and target cast bar outside unit frame and allow moving of cast bar around the screen",
		},

		["CastBarIcon"] = {
			["Name"] = "Cast Bar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["CastBarLatency"] = {
			["Name"] = "Cast Bar Latency",
			["Desc"] = "Display your latency on the cast bar",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
			["Desc"] = "Smooth out the updating of the health bars"..PerformanceSlight,
		},

		["CombatLog"] = {
			["Name"] = "Combat Feedback",
			["Desc"] = "Display incoming heals and damage on the player unit frame",
		},

		["WeakBar"] = {
			["Name"] = "Weakened Soul Bar",
			["Desc"] = "Display a bar to show the Weakened Soul debuff",
		},

		["HealBar"] = {
			["Name"] = "HealComm",
			["Desc"] = "Display a bar showing incoming heals & absorbs",
		},

		["TotemBar"] = {
			["Name"] = "Totem Bar",
			["Desc"] = "Create a tukui style totem bar",
		},

		["ComboBar"] = {
			["Name"] = "Combo Points",
			["Desc"] = "Enable the combo points bar",
		},

		["SerendipityBar"] = {
			["Name"] = "Priest Serendipity Bar",
			["Desc"] = "Display a bar showing priest serendipity stacks",
		},

		["OnlySelfDebuffs"] = {
			["Name"] = "Display my debuffs only",
			["Desc"] = "Only display our debuffs on nameplates",
		},

		["OnlySelfBuffs"] = {
			["Name"] = "Display My Buffs Only",
			["Desc"] = "Only display our buffs on the target frame",
		},

		["Threat"] = {
			["Name"] = "Enable threat display",
			["Desc"] = "Health Bar on party and raid members will turn red if they have aggro",
		},

		["Arena"] = {
			["Name"] = "Arena Frames",
			["Desc"] = "Display arena opponents when inside a battleground or arena",
		},

		["Boss"] = {
			["Name"] = "Boss Frames",
			["Desc"] = "Display boss frames while doing pve",
		},

		["TargetAuras"] = {
			["Name"] = "Target Auras",
			["Desc"] = "Display buffs and debuffs on target",
		},

		["FocusAuras"] = {
			["Name"] = "Focus Auras",
			["Desc"] = "Display buffs and debuffs on focus",
		},

		["FocusTargetAuras"] = {
			["Name"] = "Focus Target Auras",
			["Desc"] = "Display buffs and debuffs on focus target",
		},

		["ArenaAuras"] = {
			["Name"] = "Arena Frames Auras",
			["Desc"] = "Display debuffs on arena frames",
		},

		["BossAuras"] = {
			["Name"] = "Boss Frames Auras",
			["Desc"] = "Display debuffs on boss frames",
		},

		["AltPowerText"] = {
			["Name"] = "AltPower Text",
			["Desc"] = "Display altpower text values on altpower bar",
		},

		["Font"] = {
			["Name"] = "Unit Frame Font",
			["Desc"] = "Set a font for unit frames",
		},
	},
}
