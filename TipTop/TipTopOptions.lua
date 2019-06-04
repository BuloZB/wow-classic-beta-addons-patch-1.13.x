local ttName, TipTop = ...
local f = CreateFrame("FRAME")
local LSM = LibStub("LibSharedMedia-3.0")
local widgetLists = AceGUIWidgetLSMlists
local db, mover

local positions = {"TOP", "TOPRIGHT", "TOPLEFT",
					"BOTTOM", "BOTTOMRIGHT", "BOTTOMLEFT",
					"RIGHT", "LEFT", "CENTER"}
local formats = {"100/100", "100%", "100/100 (100%)", "1.2k/1.2k", "1.2k/1.2k (100%)"}
local fontFlags = {"None", "Outline", "Monochrome Outline"}	--, "Monochrome"}
local classIconStyles = {"Default UI", "Bright Class Color", "Dark Grey", "Dark", "Light Grey", "Medium Grey", "Muted Class Color", "WoW Website"}


local defaults = {
	alpha = 1,
	scale = 1,
	font = "Friz Quadrata TT",
	fontFlag = "None",
	fontSize = 12,
	bg = "brushed",
	bgColor = {r=.09, g=.09, b=.19},	--TOOLTIP_DEFAULT_BACKGROUND_COLOR
	border = "Seerah Solid",
	borderWidth = 2.5,
	inset = 0,
	diffColor = true,
	classColor = true,
	npcClassColor = true,
	classIcon = false,
	npcClassIcon = true,
	classIconStyle = "Default UI",
	guildRank = false,
	itemColor = true,
	borderColor = {r=.6, g=.6, b=.6, a=1},
	healthBar = "TipTop Default",
	sbarcolor = {r=0, g=1, b=0, a=1},
	sbarbg = "TipTop Default",
	sbarbgcolor = {r=0, g=0, b=0, a=.4},
	sbarclass = true,
	topBar = false,
	insideBar = false,
	raidIconSize = 16,
	raidIconPosition = "TOP",
	raidIconX = "0",
	raidIconY = "0",
	factionIcon = false,
	factionIconSize = 32,
	factionIconPosition = "TOPRIGHT",
	factionIconX = "-16",
	factionIconY = "-4",
	onCursor = false,
	anchor = "BOTTOMRIGHT",
	anchorTo = "BOTTOMRIGHT",
	offsetX = "-2",
	offsetY = "109",
	showTargetText = true,
	you = true,
	showTalentText = true,
	elite = true,
	healthText = true,
	textformat = "100%",
	healthSize = 12,
	diffFont = false,
	healthFont = "Friz Quadrata TT",
}


local function SetUpDB()
	TipTopDB = TipTopDB or {}
	TipTopPCDB = TipTopPCDB or {}
		if TipTopPCDB.charSpec == nil then
			TipTopPCDB.charSpec = false
		end
	for k,v in pairs(defaults) do
	    if type(TipTopDB[k]) == "nil" then
	        TipTopDB[k] = v
	    end
	end
	if TipTopPCDB.charSpec then
		--set defaults if new charSpec DB
		for k,v in pairs(defaults) do
			if type(TipTopPCDB[k]) == "nil" then
				TipTopPCDB[k] = v
			end
		end
		db = TipTopPCDB
	else
		db = TipTopDB
	end
end

local function SetUpMover()
	mover.t = mover:CreateTexture()
	mover.t:SetAllPoints()
	mover.t:SetColorTexture(0,0,1,.4)
	mover.l = mover:CreateLine()
	mover.l:SetThickness(1)
	mover.l:SetStartPoint("CENTER", mover)
	mover.l:SetEndPoint(db.anchor, mover)
	mover.l:SetColorTexture(1,1,1,1)
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	mover:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	
	--close and confirm--
	StaticPopupDialogs["TIPTOP_MOVER"] = {
		text = "Save tooltip position.",
		button1 = "Save",
		button2 = "Cancel",
		OnAccept = function()
				db.anchorTo, _, _, x, y = mover:GetPoint()
				db.offsetX, db.offsetY = tostring(x), tostring(y)
				mover:Hide()
				InterfaceOptionsFrame:Show()
			end,
		OnCancel = function()
				mover:Hide()
				InterfaceOptionsFrame:Show()
			end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}
end


local options = {
	name = "TipTop Options",
	type = "group",
	args = {
		general = {
			name = "General",
			type = "group",
			args = {
				header1 = {
					name = "General",
					type = "header",
					order = 1,
				},
				font = {
					name = "Font",
					desc = "Select the font for the tooltip and health text.",
					type = "select",
					dialogControl = "LSM30_Font",
					values = widgetLists.font,
					get = function()
							return db.font
						end,
					set = function(self, font)
							db.font = font
							TipTop:SetFonts()
						end,
					order = 2,
				},
				fontFlag = {
					name = "Font Flag",
					desc = "Set how to alter the tooltip's font.",
					type = "select",
					values = fontFlags,
					get = function()
								for k, v in pairs(fontFlags) do
									if db.fontFlag == v then
										return k
									end
								end
							end,
					set = function(_,key)
								db.fontFlag = fontFlags[key]
								TipTop:SetFonts()
							end,
					order = 3,
				},
				fontSize = {
					name = "Font Size",
					desc = "The base size of the text in all tooltips.",
					type = "range",
					min = 6,
					max = 20,
					step = 1,
					get = function() return db.fontSize end,
					set = function(_, fontSize) 
								db.fontSize = fontSize
								TipTop:SetFonts()
							end,
					order = 3.5,
				},
				scale = {
					name = "Tooltip scale",
					desc = "The scale of the entire tooltip.",
					type = "range",
					min = .5,
					max = 2,
					step = .05,
					get = function() return db.scale end,
					set = function(_, scale) 
								db.scale = scale
								TipTop:SetBackgrounds()
							end,
					order = 4,
				},
				bgColor = {
					name = "Background Color/Alpha",
					desc = "The background color and transparency.\n\nIf you wish to use a custom background texture and do not want it colored, set this to white.",
					type = "color",
					hasAlpha = true,
					get = function() return db.bgColor.r, db.bgColor.g, db.bgColor.b, db.alpha end,
					set = function(_,r,g,b,a)
							db.bgColor.r = r
							db.bgColor.g = g
							db.bgColor.b = b
							db.alpha = a
							TipTop:SetBackgrounds()
						end,
					order = 5,
				},
				bg = {
					name = "Background",
					desc = "Texture to use as the tip's background.",
					type = "select",
					dialogControl = "LSM30_Background",
					values = widgetLists.background,
					get = function()
							return db.bg
						end,
					set = function(self, bg)
							db.bg = bg
							TipTop:SetBackgrounds()
						end,
					order = 6,
				},
				empty1 = {
					name = "   ",
					type = "description",
					order = 7,
				},
				empty5 = {
					name = "   ",
					type = "description",
					order = 8,
				},
				header5 = {
					name = "Tooltip Position",
					type = "header",
					order = 9,
				},
				onCursor = {
					name = "On Cursor",
					desc = "Whether you want the tooltip attached to the cursor or not.\n\nNote: If checked, anchor and offsets below do not apply.",
					type = "toggle",
					get = function() return db.onCursor end,
					set = function()
								db.onCursor = not db.onCursor
							end,
					order = 10,
				},
				anchor = {
					name = "Grow from...",
					desc = "What side/corner of the tooltip you would like it to expand from.",
					type = "select",
					disabled = function() return db.onCursor end,
					values = positions,
					get = function()
								for k, v in pairs(positions) do
									if db.anchor == v then
										return k
									end
								end
							end,
					set = function(_, anchor)
								db.anchor = positions[anchor]
								mover.l:SetEndPoint(db.anchor, mover)
							end,
					order = 11,
				},
				anchorTo = {
					name = "Anchor To...",
					desc = "What side of the screen you would like the tooltip located at.",
					type = "select",
					disabled = function() return db.onCursor end,
					values = positions,
					get = function()
								for k, v in pairs(positions) do
									if db.anchorTo == v then
										return k
									end
								end
							end,
					set = function(_, anchorTo)
								db.anchorTo = positions[anchorTo]
							end,
					order = 12,
				},
				empty1 = {
					name = " ",
					type = "description",
					order = 13,
				},
				offsetX = {
					name = "X Offset",
					desc = "Offsets from the tooltip's anchor left/right",
					type = "input",
					disabled = function() return db.onCursor end,
					get = function() return db.offsetX end,
					set = function(_,offsetX)
								if offsetX == nil or offsetX == "" then
									offsetX = "0"
								end
								db.offsetX = offsetX
								mover:ClearAllPoints()
								mover:SetPoint(db.anchorTo, UIParent, db.anchorTo, db.offsetX, db.offsetY)
							end,
					order = 14,
				},
				offsetY = {
					name = "Y Offset",
					desc = "Offsets from the tooltip's anchor up/down",
					type = "input",
					disabled = function() return db.onCursor end,
					get = function() return db.offsetY end,
					set = function(_,offsetY)
								if offsetY == nil or offsetY == "" then
									offsetY = "0"
								end
								db.offsetY = offsetY
								mover:ClearAllPoints()
								mover:SetPoint(db.anchorTo, UIParent, db.anchorTo, db.offsetX, db.offsetY)
							end,
					order = 15,
				},
				mover = {
					name = "Draggable Mover",
					desc = "Shows an anchor to move the tooltip's position. The line shows from which side/corner the tooltip will grow from.",
					type = "execute",
					disabled = function() return db.onCursor end,
					func = function()
								InterfaceOptionsFrame:Hide()
								if not mover.t then
									SetUpMover()
								end
								mover:ClearAllPoints()
								mover:SetPoint(db.anchorTo, UIParent, db.anchorTo, db.offsetX, db.offsetY)
								mover:Show()
								StaticPopup_Show("TIPTOP_MOVER")
							end,
					order = 16,
				},
			},
		},
		baropts = {
			name = "Health Bar",
			type = "group",
			args = {
				header2 = {
					name = "",
					type = "group",
					type = "header",
					order = 1,
				},
				healthBar = {
					name = "Health bar texture",
					desc = "Texture to use for the status bar below the tooltip.",
					type = "select",
					dialogControl = "LSM30_Statusbar",
					values = widgetLists.statusbar,
					get = function()
							return db.healthBar
						end,
					set = function(self, healthBar)
							db.healthBar = healthBar
							TipTop:SBarCustom()
						end,
					order = 2,
				},
				sbarcolor = {
					name = "Health bar color",
					desc = "The color of the health bar.",
					type = "color",
					hasAlpha = true,
					get = function() return db.sbarcolor.r, db.sbarcolor.g, db.sbarcolor.b, db.sbarcolor.a end,
					set = function(_,r,g,b,a)
							db.sbarcolor.r = r
							db.sbarcolor.g = g
							db.sbarcolor.b = b
							db.sbarcolor.a = a
							TipTop:SBarCustom()
						end,
					order = 3,
				},
				sbarclass = {
					name = "Color By Class",
					desc = "Color the health bar by class.",
					type = "toggle",
					get = function() return db.sbarclass end,
					set = function()
								db.sbarclass = not db.sbarclass
								if not db.sbarclass then
									TipTop:SBarCustom()
								end
							end,
					order = 4,
				},
				sbarbg = {
					name = "Background texture",
					desc = "Texture to use for the status bar's background.",
					type = "select",
					dialogControl = "LSM30_Statusbar",
					values = widgetLists.statusbar,
					get = function()
							return db.sbarbg
						end,
					set = function(self, sbarbg)
							db.sbarbg = sbarbg
							TipTop:SBarCustom()
						end,
					order = 5,
				},
				sbarbgcolor = {
					name = "Background Color",
					desc = "The color of the health bar's background.",
					type = "color",
					hasAlpha = true,
					width = "double",
					get = function() return db.sbarbgcolor.r, db.sbarbgcolor.g, db.sbarbgcolor.b, db.sbarbgcolor.a end,
					set = function(_,r,g,b,a)
							db.sbarbgcolor.r = r
							db.sbarbgcolor.g = g
							db.sbarbgcolor.b = b
							db.sbarbgcolor.a = a
							TipTop:SBarCustom()
						end,
					order = 6,
				},
				empty2 = {
					name = " ",
					type = "description",
					order = 7,
				},
				topBar = {
					name = "Health bar on top",
					desc = "If checked, the health bar will be displayed above the tooltip instead of below.",
					type = "toggle",
					get = function() return db.topBar end,
					set = function()
								db.topBar = not db.topBar
								TipTop:SBPosition()
							end,
					order = 8,
				},
				insideBar = {
					name = "Health bar inside",
					desc = "If checked, the health bar will be displayed within the tooltip frame.",
					type = "toggle",
					get = function() return db.insideBar end,
					set = function()
								db.insideBar = not db.insideBar
								TipTop:SBPosition()
							end,
					order = 9,
				},
				empty3 = {
					name = " ",
					type = "description",
					order = 10,
				},
				healthText = {
					name = "Health text",
					desc = "If checked, health amount will be displayed on the tooltip's status bar.",
					type = "toggle",
					get = function() return db.healthText end,
					set = function()
								db.healthText = not db.healthText
								if db.healthText == true then
									ttHealth:Show()
								else
									ttHealth:Hide()
								end
							end,
					order = 11,
				},
				textformat = {
					name = "Text format",
					desc = "Select how you would like health text displayed.",
					type = "select",
					disabled = function() return not db.healthText end,
					values = formats,
					get = function()
								for k, v in pairs(formats) do
									if db.textformat == v then
										return k
									end
								end
							end,
					set = function(_, textformat)
							db.textformat = formats[textformat]
						end,
					order = 12,
				},
				healthSize = {
					name = "Health Text Size",
					desc = "The size of the text on the statusbar.",
					type = "range",
					min = 6,
					max = 20,
					step = 1,
					get = function() return db.healthSize end,
					set = function(_, healthSize) 
								db.healthSize = healthSize
								TipTop:SetFonts()
							end,
					order = 13,
				},
				diffFont = {
					name = "Use different font",
					desc = "Use a different font for the health text than for the rest of the tooltip.",
					type = "toggle",
					get = function() return db.diffFont end,
					set = function()
							db.diffFont = not db.diffFont
							TipTop:SetFonts()
						end,
					order = 14,
				},
				healthFont = {
					name = "Health font",
					desc = "The font to use for the health text, if different from the rest of the tooltip.",
					disabled = function() return not db.diffFont end,
					type = "select",
					dialogControl = "LSM30_Font",
					values = widgetLists.font,
					get = function() return db.healthFont end,
					set = function(self, font)
							db.healthFont = font
							TipTop:SetFonts()
						end,
					order = 15,
				},
			},
		},
		borderopts = {
			name = "Borders",
			type = "group",
			args = {
				header3 = {
					name = "",
					type = "header",
					order = 1,
				},
				border = {
					name = "Border",
					desc = "Texture for the tooltip borders.",
					type = "select",
					width = "double",
					dialogControl = "LSM30_Border",
					values = widgetLists.border,
					get = function()
							return db.border
						end,
					set = function(self, border)
							db.border = border
							TipTop:SetBackgrounds()
						end,
					order = 2,
				},
				borderColor = {
					name = "Border color",
					desc = "Color of the border when not class, difficulty, or item quality colored.",
					type = "color",
					hasAlpha = true,
					get = function() return db.borderColor.r, db.borderColor.g, db.borderColor.b, db.borderColor.a end,
					set = function(_,r,g,b,a)
								db.borderColor.r = r
								db.borderColor.g = g
								db.borderColor.b = b
								db.borderColor.a = a
								TipTop:SetBackgrounds()
							end,
					order = 3,
				},
				empty1 = {
					name = " ",
					type = "description",
					order = 3.5,
				},
				borderWidth = {
					name = "Border Width",
					desc = "Width of the border.",
					type = "range",
					min = 1,
					max = 24,
					step = .5,
					get = function() return db.borderWidth end,
					set = function(_, borderWidth) 
								db.borderWidth = borderWidth
								TipTop:SetBackgrounds()
							end,
					order = 4,
				},
				inset = {
					name = "Inset",
					desc = "The inset of the background from the border texture.",
					type = "range",
					min = 0,
					max = 10,
					step = .5,
					get = function() return db.inset end,
					set = function(_, inset) 
								db.inset = inset
								TipTop:SetBackgrounds()
							end,
					order = 5,
				},
				empty2 = {
					name = " ",
					type = "description",
					order = 6,
				},
				classColor = {
					name = "Class-colored borders",
					desc = "If checked, the border is colored by class when mousing over a unit.\n\nIf difficulty-colored is also checked, difficulty coloring has priority for hostile units.",
					type = "toggle",
					get = function() return db.classColor end,
					set = function()
								db.classColor = not db.classColor
							end,
					order = 7,
				},
				npcClassColor = {
					name = "NPCs too",
					desc = "If checked, the border of NPCs will also be colored by class.\n\nIf difficulty-colored is also checked, difficulty coloring has priority for hostile units.",
					type = "toggle",
					disabled = function() return not db.classColor end,
					get = function() return db.npcClassColor end,
					set = function()
								db.npcClassColor = not db.npcClassColor
							end,
					order = 7.5,
				},
				diffColor = {
					name = "Difficulty-colored borders",
					desc = "If checked, the border is colored by level difficulty when mousing over a unit.\n\nIf class-colored is also checked, class coloring has priority for friendly units.",
					type = "toggle",
					get = function() return db.diffColor end,
					set = function()
								db.diffColor = not db.diffColor
							end,
					order = 8,
				},
				itemColor = {
					name = "Item quality borders",
					desc = "If checked, the border is colored by item quality when mousing over an item",
					type = "toggle",
					get = function() return db.itemColor end,
					set = function()
								db.itemColor = not db.itemColor
							end,
					order = 9,
				},
			},
		},
		iconopts = {
			name = "Icons",
			type = "group",
			args = {
				header4 = {
					name = "",
					type = "header",
					order = 1,
				},
				cIconOpts = {
					name = "Class Icon Settings",
					type = "group",
					inline = true,
					order = 2,
					args = {
						classIcon = {
							name = "Display Class Icon",
							desc = "Display a class icon next to the unit's name in the tooltip.",
							type = "toggle",
							get = function() return db.classIcon end,
							set = function()
										db.classIcon = not db.classIcon
									end,
							order = 1,
						},				
						npcClassIcon = {
							name = "NPCs too",
							desc = "Display a class icon next to the unit's name in the tooltip for NPCs also.",
							type = "toggle",
							disabled = function() return not db.classIcon end,
							get = function() return db.npcClassIcon end,
							set = function()
										db.npcClassIcon = not db.npcClassIcon
									end,
							order = 2,
						},
						classIconStyle = {
							name = "Class Icon Style",
							desc = "Select the style of class icon displayed.",
							type = "select",
							disabled = function() return not db.classIcon end,
							values = classIconStyles,
							get = function()
									for k, v in pairs(classIconStyles) do
										if db.classIconStyle == v then
											return k
										end
									end
								end,
							set = function(_, style)
									db.classIconStyle = classIconStyles[style]
								end,
							order = 3,
						},
					},
				},
				fIconOpts = {
					name = "Faction Icon Settings",
					type = "group",
					inline = true,
					order = 3,
					args = {
						factionIcon = {
							name = "Display Faction Icon",
							desc = "Display the faction icon for player controlled characters.",
							type = "toggle",
							width = "full",
							get = function() return db.factionIcon end,
							set = function()
										db.factionIcon = not db.factionIcon
										TipTop:FactionIcon()
									end,
							order = 1,
						},
						factionIconSize = {
							name = "Faction icon size",
							desc = "Width and height of the faction icon on the tooltip",
							type = "range",
							disabled = function() return not db.factionIcon end,
							min = 8,
							max = 64,
							step = 1,
							get = function() return db.factionIconSize end,
							set = function(_, factionIconSize) 
										db.factionIconSize = factionIconSize
										TipTop:FactionIcon()
									end,
							order = 2,
						},
						factionIconPosition = {
							name = "Faction icon position",
							desc = "What side of the tip you would like the icon located at.",
							type = "select",
							disabled = function() return not db.factionIcon end,
							values = positions,
							get = function()
										for k, v in pairs(positions) do
											if db.factionIconPosition == v then
												return k
											end
										end
									end,
							set = function(_, factionIconPosition)
										db.factionIconPosition = positions[factionIconPosition]
										TipTop:FactionIcon()
									end,
							order = 3,
						},
						factionIconX = {
							name = "X Offset",
							desc = "Offsets from the icon's position left/right",
							type = "input",
							width = "half",
							disabled = function() return not db.factionIcon end,
							get = function() return db.factionIconX end,
							set = function(_,factionIconX)
										if factionIconX == nil or factionIconX == "" then
											factionIconX = "0"
										end
										db.factionIconX = factionIconX
										TipTop:FactionIcon()
									end,
							order = 4,
						},
						factionIconY = {
							name = "Y Offset",
							desc = "Offsets from the icon's position up/down",
							type = "input",
							width = "half",
							disabled = function() return not db.factionIcon end,
							get = function() return db.factionIconY end,
							set = function(_,factionIconY)
										if factionIconY == nil or factionIconY == "" then
											factionIconY = "0"
										end
										db.factionIconY = factionIconY
										TipTop:FactionIcon()
									end,
							order = 5,
						},
					},
				},
				rIconOpts = {
					name = "Raid Icon Settings",
					type = "group",
					inline = true,
					order = 4,
					args = {
						raidIconSize = {
							name = "Raid icon size",
							desc = "Width and height of the raid icon on the tooltip",
							type = "range",
							min = 8,
							max = 32,
							step = 1,
							get = function() return db.raidIconSize end,
							set = function(_, raidIconSize) 
										db.raidIconSize = raidIconSize
										TipTop:RaidIcon()
									end,
							order = 1,
						},
						raidIconPosition = {
							name = "Raid icon position",
							desc = "What side of the tip you would like the icon located at.",
							type = "select",
							values = positions,
							get = function()
										for k, v in pairs(positions) do
											if db.raidIconPosition == v then
												return k
											end
										end
									end,
							set = function(_, raidIconPosition)
										db.raidIconPosition = positions[raidIconPosition]
										TipTop:RaidIcon()
									end,
							order = 2,
						},
						raidIconX = {
							name = "X Offset",
							desc = "Offsets from the icon's position left/right",
							type = "input",
							width = "half",
							get = function() return db.raidIconX end,
							set = function(_,raidIconX)
										if raidIconX == nil or raidIconX == "" then
											raidIconX = "0"
										end
										db.raidIconX = raidIconX
										TipTop:RaidIcon()
									end,
							order = 3,
						},
						raidIconY = {
							name = "Y Offset",
							desc = "Offsets from the icon's position up/down",
							type = "input",
							width = "half",
							get = function() return db.raidIconY end,
							set = function(_,raidIconY)
										if raidIconY == nil or raidIconY == "" then
											raidIconY = "0"
										end
										db.raidIconY = raidIconY
										TipTop:RaidIcon()
									end,
							order = 4,
						},
					},
				},
			},
		},
		extraopts = {
			name = "Extra Stuff",
			type = "group",
			args = {
				header6 = {
					name = "",
					type = "header",
					order = 37,
				},
				showTargetText = {
					name = "Target text",
					desc = "Whether you wish to view the mouseover unit's target in the tooltip",
					type = "toggle",
					get = function() return db.showTargetText end,
					set = function()
								db.showTargetText = not db.showTargetText
							end,
					order = 38,
				},
				you = {
					name = "Target emphasis",
					desc = "When checked, if the mouseover unit's target is you, it will be displayed as |c00E30016<<YOU>>|r.",
					type = "toggle",
					disabled = function() return not db.showTargetText end,
					get = function() return db.you end,
					set = function()
								db.you = not db.you
							end,
					order = 39,
				},
				showTalentText = {
					name = "Talent text",
					desc = "Whether you wish to view the mouseover unit's talent specialization in the tooltip",
					type = "toggle",
					get = function() return db.showTalentText end,
					set = function()
								db.showTalentText = not db.showTalentText
							end,
					order = 40,
				},
				elite = {
					name = "Elite graphic",
					desc = "Will display the gold and silver elite dragons for elites and rare elites at the top left of the tooltip.",
					type = "toggle",
					get = function() return db.elite end,
					set = function()
								db.elite = not db.elite
							end,
					order = 44,
				},
				guildRank = {
					name = "Guild Rank",
					desc = "Display the unit's rank next to the guild name in the tooltip.",
					type = "toggle",
					get = function() return db.guildRank end,
					set = function()
								db.guildRank = not db.guildRank
							end,
					order = 45,
				},
			},
		},
		profile = {
			name = "Profile",
			type = "group",
			args = {
				header7 = {
					name = "",
					type = "header",
					order = 42,
				},
				charSpec = {
					name = "Character specific settings",
					desc = "Have this character use their own profile.  If checked, any changes made will not affect other characters.\n\n|c00E30016WARNING:|r Your UI will be reloaded in the process!",
					type = "toggle",
					width = "full",
					confirm = true,
					get = function() return TipTopPCDB.charSpec end,
					set = function()
								TipTopPCDB.charSpec = not TipTopPCDB.charSpec
								ReloadUI()
							end,
					order = 43,
				},
--[[				warning = {
					name = "Have this character use their own profile.  If checked, any changes made will not affect other characters.\n\n|c00E30016WARNING:|r Your UI will be reloaded in the process!",
					type = "description",
					order = 44,
				},]]--
				copyProfile = {
					name = "Copy from Default",
					desc = "Copy all settings from the default, global profile to this character's profile.  This will not effect other characters' specific profiles.\n\n|c00E30016WARNING:|r Your UI will be reloaded in the process!",
					type = "execute",
					confirm = true,
					disabled = function() return not TipTopPCDB.charSpec end,
					func = function()
								TipTopPCDB = TipTopDB
								TipTopPCDB.charSpec = true
								ReloadUI()
							end,
					order = 44,
				},
				resetProfile = {
					name = "Profile Reset",
					desc = "Reset this profile back to the out-of-the-box settings.  If you reset the character specific profile, the global profile will be untouched, and vice versa.  This will not effect other character specific profiles.\n\n|c00E30016WARNING:|r Your UI will be reloaded in the process!",
					type = "execute",
					confirm = true,
					func = function()
								if TipTopPCDB.charSpec then
									TipTopPCDB = {charSpec = true}
								else
									TipTopDB = {}
								end
								ReloadUI()
							end,
					order = 45,
				},
			},
		},
	},
}

local function OnInitialize()
	SetUpDB()
	
	--create mover to anchor the tooltip to
	mover = CreateFrame("Frame", "TipTopMover", UIParent)
	TipTop.mover = mover
	mover:SetSize(200, 100)
	mover:SetPoint(db.anchorTo, UIParent, db.anchorTo, db.offsetX, db.offsetY)

	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TipTop", options)
	TipTop.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "TipTop", nil, "general")
	TipTop.optionsFrame.baropts = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "Health Bar", "TipTop", "baropts")
	TipTop.optionsFrame.borderopts = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "Borders", "TipTop", "borderopts")
	TipTop.optionsFrame.iconopts = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "Icons", "TipTop", "iconopts")
	TipTop.optionsFrame.extraopts = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "Extra Stuff", "TipTop", "extraopts")
	TipTop.optionsFrame.profile = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TipTop", "Profile", "TipTop", "profile")
	
	SlashCmdList["TIPTOP"] = function()
		InterfaceOptionsFrame_OpenToCategory("TipTop")
		InterfaceOptionsFrame_OpenToCategory("TipTop")
	end
	SLASH_TIPTOP1 = "/tiptop"
	SLASH_TIPTOP2 = "/tip"
end

--register media with LibSharedMedia
LSM:Register("statusbar", "TipTop Default", "Interface\\AddOns\\TipTop\\media\\bar2.blp")
LSM:Register("statusbar", "TipTop Alt", "Interface\\AddOns\\TipTop\\media\\bar1.blp")
LSM:Register("border", "Seerah Solid", "Interface\\AddOns\\TipTop\\media\\SeerahSolidBorder.blp")
LSM:Register("background", "brushed", "Interface\\AddOns\\TipTop\\media\\brushed.tga")

	
f:SetScript("OnEvent", OnInitialize)
f:RegisterEvent("PLAYER_LOGIN")