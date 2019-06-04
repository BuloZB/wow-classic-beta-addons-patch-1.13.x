-- Always initialise enGB, as it's the default
local L = mrp.L

-- Default locale-dependent options

L["option_HeightUnit"] = 2 -- 0 = centimetres, 1 = metres, 2 = feet/inches
L["option_WeightUnit"] = 2 -- 0 = kilograms, 1 = pounds, 2 = stone/pounds

-- The title of the profile editor tab
L["tabtitle"] = "MyRolePlay"

-- Appears below MyRolePlay in the options panel, describes what the addon does
L["mrp_addon_notes"] = GetAddOnMetadata( "MyRolePlay", "Notes" )

-- Field formats
L["mo_format"] = [[“%s”]]
L["ni_format"] = [[“%s”]]
L["nh_format"] = "%s"
L["rs_format"] = "%s"
-- Height
L["opt_displayheight_header"] = "Display height in..."
L["cm_format"] = "%dcm"
L["cm_format_name"] = "Centimetres (170cm)"
L["m_format"] = "%.2fm"
L["m_format_name"] = "Metres (1.70m)"
L["ftin_format"] = [[%d'%d"]]
L["ftin_format_name"] = [[Feet & Inches (5'6")]]
-- Weight
L["opt_displayweight_header"] = "Display weight in..."
L["kg_format"] = "%dkg"
L["kg_format_name"] = "Kilograms (60kg)"
L["lb_format"] = "%dlb"
L["lb_format_name"] = "Pounds (132lb)"
L["stlb_format"] = "%dst %dlb"
L["stlb_format_name"] = "Stones & Pounds (9st 6lb)"
-- Description / History Font Size
L["opt_defontsize_header"] = "Description / History Font Size"

-- Tooltip style names
L["ttstyle_0_name"] = "|cffc0c0c0Blizzard Default|r"
L["ttstyle_1_name"] = "Basic (flag-style)"
L["ttstyle_2_name"] = "Enhanced (Default)"
L["ttstyle_3_name"] = "Compact"

-- Preset roleplaying styles
L["FR0"] = "(Style not set)"
L["FR0t"] = "Not yet set"
L["FR0d"] = [[Please choose your roleplaying style.]]
L["FR1"] = "Normal roleplayer"
L["FR1t"] = "Normal"
L["FR1d"] = [[Your roleplaying style is conventional.

You are usually in character, but sometimes revert to
out–of–character communication (for example in
instances, or when game mechanics demand it). ]]
L["FR2"] = "Casual roleplayer"
L["FR2t"] = "Casual"
L["FR2d"] = [[Your roleplaying style is casual.

You are often in character, but frequently revert to
out–of–character communication when it is more
convenient to do so. ]]
L["FR3"] = "Full–time roleplayer"
L["FR3t"] = "Full–time"
L["FR3d"] = [[Your roleplaying style is full–time.

You are almost always in character, and strive for
maximum immersion where possible. ]]
L["FR4"] = "Beginner roleplayer"
L["FR4t"] = "Beginner"
L["FR4d"] = [[Your roleplaying style is beginner.

You are new to roleplaying, or still getting a feel for
this character or the World of Warcraft setting.

Other players are requested to be forgiving of any
mistakes.]]
L["FRc"] = "(Custom)"
L["FRct"] = "Custom"
L["FRcd"] = [[Define a roleplaying style of your own not listed above.]]


-- Preset character statuses
L["FC0"] = "(Status not set)"
L["FC0t"] = "Not yet set"
L["FC0d"] = [[Please select your current status.]]
L["FC1"] = "Out Of Character"
L["FC1t"] = "Out Of Character (OOC)"
L["FC1d"] = [[You are currently out of character, playing the game rather
than playing as your character.

Anything you do while in this status should not be taken as
literally being done by your character.

Please remember that no out of character or non–fantasy
related dialogue should take place in /say, /emote, or /yell.]]
L["FC2"] = "In Character"
L["FC2t"] = "In Character (IC)"
L["FC2d"] = [[You are currently in character, talking and behaving however
your character would normally act.

In–character actions should yield in–character consequences.
Other characters may interact with your character.]]
L["FC3"] = "Looking For Contact"
L["FC3t"] = "Looking For Contact (LFC)"
L["FC3d"] = [[You are currently in character, talking and behaving however
your character would normally act.

In–character actions should yield in–character consequences.
Other characters are explicitly invited and encouraged to
interact with your character.]]
L["FC4"] = "Storyteller"
L["FC4t"] = "Storyteller"
L["FC4d"] = [[You are currently in character, talking and behaving however
your character would normally act.

You are currently leading a storyline in which other characters
may choose to participate.]]
L["FCc"] = "(Custom)"
L["FCct"] = "Custom"
L["FCcd"] = [[Define a character status of your own not listed above.]]

-- Preset relationship statuses
L["RS0"] = "Unknown"
L["RS0t"] = "No status set"
L["RS0d"] = [[Choose your character's relationship status, if you wish.

You may also use this option if you wish to not disclose your relationship status.]]
L["RS1"] = "Single"
L["RS1t"] = "Single"
L["RS1d"] = [[Your character is single.]]
L["RS2"] = "Taken"
L["RS2t"] = "In a relationship"
L["RS2d"] = [[Your character is in a relationship,
but not yet married.]]
L["RS3"] = "Married"
L["RS3t"] = "Married"
L["RS3d"] = [[Your character is married.]]
L["RS4"] = "Divorced"
L["RS4t"] = "Divorced"
L["RS4d"] = [[Your character is divorced from a former marriage.]]
L["RS5"] = "Widowed"
L["RS5t"] = "Widowed"
L["RS5d"] = [[Your character was married but their partner has fallen.]]

-- Tooltip stuff
L["level"] = "Level"

-- Field names and tooltip descriptions for the profile editor
L["NA"] = "Name"
L["efNA"] = [[The name of your character, as you like it to be displayed.

You can put a second name in here,
or change it however you wish.]]
--
L["NI"] = "Nickname"
L["efNI"] = [[Your character’s nickname, if they have one.

A name they’re commonly known by to friends, perhaps.]]
--
L["NT"] = "Title"
L["efNT"] = [[Your character’s title; what appears below their name.

Often a one-line description or synopsis.]]
--
L["NH"] = "House"
L["efNH"] = [[Your character’s “house name”, if applicable;
only a few races would have these.]]
--
L["RS"] = "Relationship Status"
L["efRS"] = [[Your character’s relationship status.

Selecting "Taken" or "Married" will show a heart on 
your tooltip to others.]]
--
L["PS"] = "Personality Traits"
L["PSsubheader"] = "Click to set Personality Traits."
L["efPS"] = [[Traits that describe your character's personality.

The sliders indicate how strongly your character favours a trait.

|cffff5533Tip:|r Most characters will not have a strong leaning
 in all traits.]]
--
L["AE"] = "Eyes"
L["efAE"] = [[The eye colour of your character, as appropriate.]]
--
L["RA"] = "Race"
L["efRA"] = [[Your character’s race (if not as it appears in–game).

|cffff5533Warning:|r playing as rare or exotic races is not
recommended for the beginner; it may be challenging
to convincingly roleplay as some races within
the World of Warcraft setting.

(Not everyone can, or should, be half–elves!)

You are advised extreme caution with this field.

Leave this blank to keep your race as it appears in–game.]]
--
L["RC"] = "Class"
L["efRC"] = [[Your character’s in-character class (if not as it appears in–game).

|cffff5533Warning:|r Use this field with care. Avoid using
verbose class names that make little sense from a lore perspective.

Leave this blank to keep your class as it appears in–game.]]
--
L["AH"] = "Height"
L["efAH"] = [[How tall (or short) your character is.

Either put:—
 · a specific height:
    (enter as a number in centimetres without units, e.g. 175); or,
 · a brief relative description (Tall, Short, Average…)]]
--
L["AW"] = "Weight"
L["efAW"] = [[How much your character appears to weigh.

Either put:—
 · a specific weight:
    (enter as a number in kilograms without units, e.g. 60.5); or,
 · a brief relative description (Slim, Bulky, Heavy-set…)]]
--
L["AG"] = "Age"
L["efAG"] = [[How old your character is.

Either put:—
 · A specific age:
    (in years, without units, e.g. 45); or,
 · a brief description (Young, Old, Middle-Aged…)

Bear in mind that if you put a specific age in years,
that races have wildly differing rates of aging.
(e.g. a 300–year–old night elf is just barely an adult…)]]
--
L["CU"] = "Currently"
L["efCU"] = [[If someone glances at your character right now: 
what’s the very first thing they notice?

Is your character happy? Sad? Tired? Suspicious?
Holding something? Covered in blood? Shopping? Preoccupied?

This field is deliberately intended to be very brief. 
Only a few words may be displayed: try to make them count!]]
--
L["CO"] = "Other Information (OOC)"
L["efCO"] = [[Place any relevant Out of Character (OOC) information here.]]
L["COabb"] = "OOC"
--
L["PE"] = "At a Glance"
L["efPE"] = [[These fields are *SHORT* notes about your character.

You may set up to 5, and include an icon. 
Please keep text in this field to a paragraph or so at maximum.]]
--
L["DE"] = "Description"
L["efDE"] = [[Describe the appearance of your character, as someone
looking at them would immediately see them.

Think of how a text adventure or a book might
describe them.

Please |cffff5533avoid|r the following:—
 · outlining the history of your character; put that in
   History if you wish;
 · specifying how other characters react to them
   (controlling other characters is best left to their
     respective players);
 · anything that doesn’t relate to how your character looks;
 · anything that would breach the rules or realm policies.

Remember that ONLY appearance descriptions go here.]]
--
L["HH"] = "Home"
L["efHH"] = [[The place your character currently lives, if any.]]
--
L["HB"] = "Birthplace"
L["efHB"] = [[Where your character was born.]]
--
L["MO"] = "Motto"
L["efMO"] = [[Either:—

 · the character’s motto;
 · how they would sum up their outlook on life; or,
 · something they say frequently that you
   think sums up their character.]]
--
L["HI"] = "History"
L["efHI"] = [[You may, if you wish, outline some of your character’s
history and background here.

Rather than a full biography, players may wish to
limit this information to only things that are known
publically about your character (rumours, perhaps)—as
many players prefer to discover this kind of thing
through actually interacting with you.

Try giving them a taste, instead of the whole pie!]]
--
L["FR"] = "Roleplaying Style"
L["efFR"] = [[Your preferred style of roleplaying for this character.]]
--
L["FC"] = "Character Status"
L["efFC"] = [[Whether you’re currently in or out of character,
looking for contact, or a storyteller.]]

-- Editor
L["editor_clicktoedit"] = "|cff4466eeClick|cffcccccc to edit.|r"
L["editor_icon_button"] = "Icon"
L["editor_icon_button_tt_active"] = "Current Icon:"
L["editor_icon_button_tt_inactive"] = "Set an icon for your profile."
L["editor_music_button"] = "Music"
L["editor_music_button_tt_active"] = "Currently selected music:"
L["editor_music_button_tt_inactive"] = "Set character theme music."
L["editor_newprofile_button"] = "Create a new profile."
L["editor_newprofile_popup"] = "Please enter the name for the new profile:"
L["editor_renameprofile_button"] = "Rename this profile."
L["editor_renameprofile_popup"] = "Please enter a new name for this profile:"
L["editor_deleteprofile_button"] = "Delete this profile."
L["editor_deleteprofile_button_default"] = "Destroy all of your profiles, returning them to the defaults."
L["editor_deleteprofile_popup"] = "Are you absolutely certain you want to delete this profile, destroying all the information in it?"
L["editor_deleteallprofiles_popup"] = "Are you absolutely certain you want to destroy ALL the data in your MyRolePlay profiles and go entirely back to the defaults? There is no going back!"
L["editor_settings_button"] = "Change MRP settings."
L["editor_glance_headers"] = "Title / Details"
L["editor_glanceclear_button"] = "Clear this glance, setting its icon back to default."
L["editor_inherited_label"] = "Inherited from default."
L["editor_namecolour_button"] = "Change Name Colour"
L["editor_namecolour_button_tt"] = "Change the colour of your name."
L["editor_eyecolour_button"] = "Change Eye Colour"
L["editor_eyecolour_button_tt"] = "Change the colour of your eyes."
L["editor_restorecolour_button"] = "Restore Colour Default"
L["editor_restorecolour_button_tt"] = "Restore your colour to the default profile's colour."
L["editor_inherit_button"] = "Inherit"
L["editor_inherit_button_tt"] = "Cancel any changes, and use the same contents as the Default profile."
L["editor_insertcolour_button"] = "Colour"
L["editor_insertcolour_tt_title"] = "Insert a colour code."
L["editor_insertcolour_tt_1"] = "Select a colour with the colour picker. Upon clicking 'Okay', a colour code will be placed at the position of your cursor, in the editbox. Place your desired text between these tags to colour it."
L["editor_insertcolour_tt_2"] = "{col:ff0000}Katorie has hooves.{/col}"
L["editor_insertlink_button"] = "Link"
L["editor_insertlink_tt_title"] = "Insert a link into your profile."
L["editor_insertlink_tt_1"] = "Insert a link template using this button, then replace the 'your.url.here' text with the URL of your choice. Replace 'Your text here' with what you want the clickable link text to appear as."
L["editor_insertlink_tt_2"] = "Example:\n{link*http://tinyurl.com/katorie*Kat's Art}"
L["editor_inserticon_button"] = "Icon"
L["editor_inserticon_tt_title"] = "Insert an icon."
L["editor_inserticon_tt_1"] = "Select an icon with the icon selector. A link containing the icon will appear in the profile editor (at the location of your cursor), while the icon itself will appear in your profile. (You can preview by clicking the preview button.)"
L["editor_insertheader_button"] = "Header"
L["editor_insertheader_tt_title"] = "Insert a header."
L["editor_insertheader_tt_1"] = "Select a header size and alignment in the dropdown, then place your text between the tags."
L["editor_insertheader_tt_2"] = "Example:\n{h1:c}My header text{/h1}"
L["editor_insertparagraph_button"] = "Paragraph"
L["editor_insertparagraph_tt_title"] = "Insert an aligned paragraph."
L["editor_insertparagraph_tt_1"] = "Select your desired alignment in the dropdown, then place your text between the tags."
L["editor_insertparagraph_tt_2"] = "Example:\n{p:c}My paragraph text{/p}"
L["editor_insertimage_button"] = "Image"
L["editor_insertimage_tt_title"] = "Insert an image."
L["editor_insertimage_tt_1"] = "Insert an image with the image selector. A link containing the image will appear in the profile editor at the location of your cursor. The image itself will appear in your profile. (You can preview using the preview button)"

L["editor_formattingtools_header"] = "Formatting Tools - Insert..."
L["editor_previewprofile_button"] = "Preview"
L["editor_previewprofile_tt_1"] = "Preview your profile."
L["editor_previewprofile_tt_2"] = "This will show your profile with all the colour/icon/link tags properly formatted, so you can see how it appears to other players."
L["editor_returntoeditor_button"] = "Return"
L["editor_returntoeditor_tt_1"] = "Changes not permanent until you click save."
L["editor_addpersonalitytrait"] = "Add Personality Trait"
L["editor_customtrait"] = "Add a custom trait"
L["editor_deletetrait"] = "Delete trait."
L["editor_mrptab_tt"] = "Edit your roleplaying profiles."
L["editor_import_button"] = "Import"
L["editor_import_tt_title"] = "Import RP profiles from other addons."
L["editor_import_tt_1_active"] = "You have another RP addon loaded alongside MRP and may import this character's profile from it."
L["editor_import_tt_2_active"] = "Aside from copying profiles, only one RP addon may be run at a time. Please disable conflicting addons after you are finished importing."
L["editor_import_tt_1_inactive"] = "You can load another compatible RP addon, such as TRP3 or XRP alongside MyRolePlay to import profiles from them."

-- Editor icon / music / image selector
L["editor_search"] = "Search:"
L["editor_matches"] = " matches"
L["editor_play"] = "Play"
L["editor_stop"] = "Stop"
L["editor_clearicon"] = "Clear Icon"
L["editor_clearmusic"] = "Clear Music"

L["save_button"] = "Save"
L["save_button_tt"] = "Save the changes you’ve made back to the profile."
L["cancel_button"] = "Cancel"
L["cancel_button_tt"] = "Cancel any changes and return to the way it was."

-- MRP Button
L["button_unlocked"] = "MRP Button unlocked, and can now be moved around as you wish. Right-click again to lock it in position."
L["button_locked"] = "MRP Button locked in position."
L["button_click_to_show"] = "|cffaabbccLeft-click|r to show roleplaying profile."
L["button_rightclick_to_lock"] = "|cffaabbccRight-click|r to lock this button in place."
L["button_rightclick_to_unlock"] = "|cffaabbccRight-click|r to unlock this button to move it."

-- Personality traits
L["lefttrait1"] = "Chaotic"
L["righttrait1"] = "Lawful"

L["lefttrait2"] = "Chaste"
L["righttrait2"] = "Lustful"

L["lefttrait3"] = "Forgiving"
L["righttrait3"] = "Vindictive"

L["lefttrait4"] = "Altruistic"
L["righttrait4"] = "Selfish"

L["lefttrait5"] = "Truthful"
L["righttrait5"] = "Deceitful"

L["lefttrait6"] = "Gentle"
L["righttrait6"] = "Brutal"

L["lefttrait7"] = "Superstitious"
L["righttrait7"] = "Rational"

L["lefttrait8"] = "Renegade"
L["righttrait8"] = "Paragon"

L["lefttrait9"] = "Cautious"
L["righttrait9"] = "Impulsive"

L["lefttrait10"] = "Ascetic"
L["righttrait10"] = "Bon vivant"

L["lefttrait11"] = "Valourous"
L["righttrait11"] = "Spineless"

-- Browser
L["browser_playmusic_button"] = "Click to play character theme music:"
L["browser_notesnone_button"] = "Set a note for this profile"
L["browser_notespresent_button"] = "Notes for this profile:"
L["browser_loading_nonewdata"] = "No additional data received."
L["browser_loading_inprogress"] = "|cFFFFFF00Profile loading:"
L["browser_loading_complete"] = "|cFF33FF11Profile successfully loaded."
L["browser_loading_error"] = "|cFFFF0000Profile transmission error."
L["browser_tab1"] = "Appearance"
L["browser_tab1_tt"] = "Descriptions of the character's physical appearance."
L["browser_tab2"] = "Personality"
L["browser_tab2_tt"] = "Character personality traits."
L["browser_tab3"] = "Biography"
L["browser_tab3_tt"] = "Biographical and historical information."

-- Command usage

L["commandusage"] = [[Usage: |cff99ffff/mrp|r |cffaaaa00<command>|r
Commands are as follows:
    |cff99ffffshow|r - Show target’s RP profile, if appropriate
    |cff99ffffshow|r |cffaaaa00<charactername>|r - Show someone’s RP profile, if appropriate
    |cff99ffffbrowser reset|r - Reset the profile browser to the default size & position
    |cff99ffffprofile|r |cffaaaa00<profile name>|r - Switch to another profile (by name)
    |cff99ffffedit|r - Show the profile editor
    |cff99ffffoptions|r - Show the options panel
    |cff99ffffbutton on|r/|cff99ffffoff|r - Show/hide an “MRP” button by the target frame, to browse their RP profile
    |cff99ffffbutton reset|r - Resets the MRP button to the default position by the target frame
    |cff99fffftooltip on|r/|cff99ffffoff|r - Control whether MRP shows enhanced tooltips for players including profile information
    |cff99ffffenable|r/|cff99ffffdisable|r - Completely enable/disable MyRolePlay
    |cff99ffffversion|r - Show version information]]

-- Options Panel

L["opt_basicfunctionality_header"] = "Basic Functionality"
L["opt_chatsettings_header"] = "Chat Settings"
L["opt_rpnamesinchat_header"] = "Show RP Names in..."
L["opt_enable"] = "Enable"
L["opt_enable_tt"] = [[Turn MyRolePlay on or off completely.]]
L["opt_tooltipdesign_header"] = "Tooltip Settings"
L["opt_maxtooltiplines_header"] = "Maximum Tooltip Lines"
L["opt_tooltipstyle_header"] = "Tooltip style:"
L["opt_headercolour_label"] = "    Set Header Colour"
L["opt_headercolour_popup"] = "|cffFFDD33MyRolePlay\n|cffFFFFFFYou must reload your UI after changing the header colour for changes to take effect."
L["opt_tt"] = "Enhanced Tooltips"
L["opt_tt_tt"] = [[Enhance player tooltips with roleplaying information.

Can be very useful, but can be disabled in case you dislike
the style, or if it interferes with other AddOns that also
modify player tooltips.]]
L["opt_mrpbutton"] = "Show MRP Button"
L["opt_mrpbutton_tt"]= [[Show an “MRP” button near the target frame when targeting players with a compatible AddOn.

Left-click it to browse the character profile.
Right-click it to lock/unlock it to drag it around to another place.]]
--
L["opt_allowcolours"] = "Use colours"
L["opt_allowcolours_tt"]= [[Enable or disable colours |cffff8040completely|r, throughout the addon.]]
--
L["opt_tooltipclasscolours"] = "Tooltip class colour"
L["opt_tooltipclasscolours_tt"]= [[Enable to show custom class colour in tooltip.

Disable to show the default game-class colour.]]
--
L["opt_showglancepreview"] = "Show glance preview"
L["opt_showglancepreview_tt"]= [[Show the glance preview box when targetting another player.]]
--
L["opt_showintooltip_header"] = "Show in tooltip..."
--
L["opt_classnames"] = "Custom class"
L["opt_classnames_tt"]= [[With this enabled, MRP will show custom class names set by other players instead of the default game class.

Disable it to return to showing the in-game class name.]]
--
L["opt_showooc"] = "OOC field"
L["opt_showooc_tt"]= [[Show the OOC / Other information field in the player tooltip.

Do note this will significantly increase the size of the tooltip. Disable it to hide.]]
--
L["opt_showtarget"] = "Player target"
L["opt_showtarget_tt"]= [[Show the target of the player you're mousing over in the tooltip.]]
--
L["opt_hidettinencounters"] = "Hide tooltips in combat"
L["opt_hidettinencounters_tt"]= [[Hide the enhanced MRP tooltip during combat.


The tooltip will revert to the standard Blizzard style.]]
--
L["opt_showiconintt"] = "Custom icons"
L["opt_showiconintt_tt"]= [[Show player selected icons in tooltip.]]
--
L["opt_autoplaymusic"] = "Autoplay profile music"
L["opt_autoplaymusic_tt"]= [[Automatically play player profile music.]]
--
L["opt_showversion"] = "RP addons / Status icons"
L["opt_showversion_tt"]= [[Show RP addons used by the player you're mousing over in the tooltip.]]
--
L["opt_showversionnumber"] = "Addon versions"
L["opt_showversionnumber_tt"]= [[Include detailed version information with addons.]]
--
L["opt_hidettinencounters"] = "Hide in combat"
L["opt_hidettinencounters_tt"]= [[Hide the enhanced MRP tooltip during combat.]]
--
L["opt_showguildnames"] = "Guild rank"
L["opt_showguildnames_tt"]= [[Show the guild rank alongside the guild name in the tooltip.]]
--
L["opt_maxlinesslider"] = "Number of tooltip lines"
L["opt_maxlinesslider_tt"]= [[Number of lines to show in currently / OOC sections.]]
--
L["opt_rpchatnamesay"] = "|cffffffff/say|r"
L["opt_rpchatnamesay_tt"]= [[Shows RP names in /say, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
L["opt_rpchatnamewhisper"] = "|cffff80ff/whisper|r"
L["opt_rpchatnamewhisper_tt"]= [[Shows RP names in /whisper, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_rpchatnameemote"] = "|cffff8040/emote|r"
L["opt_rpchatnameemote_tt"]= [[Shows RP names in /emote, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_rpchatnameyell"] = "|cffff4040/yell|r"
L["opt_rpchatnameyell_tt"]= [[Shows RP names in /yell, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_rpchatnameparty"] = "|cffaaaaff/party|r"
L["opt_rpchatnameparty_tt"]= [[Shows RP names in /party, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_rpchatnameraid"] = "|cffff7f00/raid|r"
L["opt_rpchatnameraid_tt"]= [[Shows RP names in /raid, where known and available.

Note: having this option enabled may occasionally prevent you from targeting people via right-clicking on their names in the chat frame. If this happens, try disabling and re-enabling it, or a /reload.]]
--
L["opt_showiconsinchat"] = "Show icons in chat"
L["opt_showiconsinchat_tt"] = [[Display player selected icons beside their name in the chat box.]]
--
L["opt_disp_header"] = "Profile Display"
L["opt_biog"] = "Show biography tab"
L["opt_biog_tt"] = [[Whether to show or hide the Biography tab in the profile browser.

Enable if you prefer more information.
Disable if you prefer discovering characters’ background information through interaction.]]
--
L["opt_traits"] = "Show personality traits tab"
L["opt_traits_tt"] = [[Whether to show or hide the Personality tab in the profile browser.]]
--
L["opt_glanceposition_header"] = "Show first glances on..."
L["glance_position_right"] = "Right Side"
L["glance_position_left"] = "Left Side"
--
L["opt_ahunit"] = "Show height in…"
L["opt_awunit"] = "Show weight in…"
--
L["opt_ac_header"] = "Automatically change profile on…"
--
L["opt_formac"] = "Shapeshifting"

L["opt_formac_tt"] = [[Automatically changes to another profile when you change form.
]]
L["opt_formac_tt_disabled"] = L["opt_formac_tt"] .. [[
(This character has no form changes available, so this does nothing.)]]
L["opt_formac_tt_enabled1"] = L["opt_formac_tt"] .. [[

Name the profile exactly after the form, as follows:—
]]
L["opt_formac_tt_suffix"] = [[  (|cffff9090do not|r include the quotes; profile names are |cffff9090case-sensitive|r!)

Changing back to your original form changes back to your original profile.

For non-Default profiles, use “|cffffff00Profilename:Form|r”: (e.g.)
· Select “|cffffff00Tuxedo|r” -> turn Worgen -> it tries to autochange to “|cffffff00Tuxedo:Worgen|r”
   (…tailor repair fees not included. Results May Vary™.)
]]

L["opt_formac_tt_worgensuffix"] = [[

|cffffa0a0Note: |rAlas, Human/Worgen detection is imperfect (due to a Blizzard oversight).
Cast |cff80c0c0Darkflight|r, |cff80c0c0Running Wild|r, or |cff80c0c0enter combat|r to try to fix.]]

L["opt_formac_tt_worgen"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…set up whichever form you feel is not the “Default”; you only need one)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_worgendruid"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one)
· “|cffffff00Cat|r”;
· “|cffffff00Bear|r”;
· “|cffffff00Travel|r” (or “|cffffff00Cheetah|r”);
· “|cffffff00Flight|r” (or “|cffffff00Bird|r”);
· “|cffffff00Aquatic|r” (or “|cffffff00Seal|r” or “|cffffff00Sealion|r”);
· “|cffffff00Moonkin|r” (or “|cffffff00Owlkin|r”) (where appropriate); and,
· “|cffffff00Tree|r” (where appropriate).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_druid"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Cat|r”;
· “|cffffff00Bear|r”;
· “|cffffff00Travel|r” (or “|cffffff00Cheetah|r”);
· “|cffffff00Flight|r” (or “|cffffff00Bird|r”);
· “|cffffff00Aquatic|r” (or “|cffffff00Seal|r” or “|cffffff00Sealion|r”);
· “|cffffff00Moonkin|r” (or “|cffffff00Owlkin|r”) (where appropriate); and,
· “|cffffff00Tree|r” (where appropriate).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_shaman"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Ghost Wolf|r” (or just “|cffffff00Wolf|r”).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_priest"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Shadow|r”.
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenpriest"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one); and,
· “|cffffff00Shadow|r”.
(Note: You may also wish to have “|cffffff00Shadow:Human|r” and/or “|cffffff00Shadow:Worgen|r”
            (or the other way around), because you can be in Shadow form
            AND a Human/Worgen at the same time…)
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]

L["opt_formac_tt_warlock"] = L["opt_formac_tt_enabled1"] .. [[
· “|cffffff00Demon|r” (where appropriate for your specialisation).
]] .. L["opt_formac_tt_suffix"]

L["opt_formac_tt_worgenwarlock"] = L["opt_formac_tt_enabled1"] .. [[
· Either “|cffffff00Worgen|r” or “|cffffff00Human|r”;
   (…whichever you feel is not the “Default”; you only need one); and,
· “|cffffff00Demon|r” (where appropriate for your specialisation).
]] .. L["opt_formac_tt_suffix"] .. L["opt_formac_tt_worgensuffix"]
--
L["opt_equipac"] = "Changing equipment set"
L["opt_equipac_tt"] = [[Changes to another profile automatically when you change equipment set.

Name the profile after the equipment set (|cffff9090case–sensitive|r).

Great for changing your description in different RP outfits.]]

-- Races - overrides for RaceEn, second return from UnitRace(), to localise them
L["NightElf"] = "Night Elf"
L["Scourge"] = "Forsaken"
L["VoidElf"] = "Void Elf"
L["LightforgedDraenei"] = "Lightforged Draenei"
L["BloodElf"] = "Blood Elf"
L["HighmountainTauren"] = "Highmountain Tauren"
L["DarkIronDwarf"] = "Dark Iron Dwarf"
L["MagharOrc"] = "Mag'har Orc"
L["KulTiran"] = "Kul Tiran"
L["ZandalariTroll"] = "Zandalari Troll"
L["MAGE"] = "Mage"
L["WARRIOR"] = "Warrior"
L["PALADIN"] = "Paladin"
L["HUNTER"] = "Hunter"
L["ROGUE"] = "Rogue"
L["PRIEST"] = "Priest"
L["DEATHKNIGHT"] = "Death Knight"
L["DEMONHUNTER"] = "Demon Hunter"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["MONK"] = "Monk"
L["DRUID"] = "Druid"

-- All other strings for enGB are as hardcoded