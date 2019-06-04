
-- Declare the typical addon variables
local refresh_rate_hz = 4
local def_time_till_refresh = (1 / refresh_rate_hz)
local time_till_refresh = def_time_till_refresh
local def_time_till_refresh_loc = 1
local time_till_refresh_loc = def_time_till_refresh_loc
local addon_name_message = "|cFF00FFB0QualityTime: |r"
local first_load_message = [[Thank you for installing QualityTime by LeftHandedGlove!]]
local load_message = [[Addon Loaded. Use /qualitytime for more options.]]
local help_message =     
    [[Options...
    |cFFFFC300reset_times:|r Resets the state times.
    |cFFFFC300lock/unlock:|r Lock/Unlock the QualityTime addon frame.
    |cFFFFC300pause/play:|r Pause or resume recording state time.
    |cFFFFC300restore_defaults:|r Restore the addon to its default settings. (Does not reset times.)]]
local reset_time_message = [[The state times have been reset.]]
local unlock_message = [[The frame has been unlocked.]]
local lock_message = [[The frame has been locked.]]
local pause_message = [[The state times have been paused.]]
local play_message = [[The state times have been resumed.]]
local restore_defaults_message = [[The default settings have been restored.]]
local default_settings = {
    x_pos = 0,
    y_pos = 0,
    title_height = 30,
    body_height = 100,
    width = 250,
    rel_point = "CENTER",
    is_locked = false,
    is_paused = false,
    idle_time = 0,
    combat_time = 0,
    regen_time = 0,
    travel_time = 0
}

-- Declare all of the variables used for tracking the state
local state_variables = {
    class = "MAGE",
    locations = {{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}},
    in_combat = false,
    full_resources = false,
    moved_far = false,
    mounted = false,
    state = "Idle"
}

-- Create the main frame and register the events we'll use
local main_frame = CreateFrame("Frame", "MainFrame", UIParent)
main_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
main_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
main_frame:RegisterEvent("PLAYER_REGEN_DISABLED")


-- Prints a message to the chat frame
local function PrintMsg(msg)
    DEFAULT_CHAT_FRAME:AddMessage(addon_name_message .. msg)
end

-- Loads the settings for the addon.
-- If this is the first time loading the addon then use the default settings.
local function LoadSettings()
    if not LHG_QualityTime_Settings then
        LHG_QualityTime_Settings = {}
        PrintMsg(first_load_message)
    end
    for setting, value in pairs(default_settings) do
        if LHG_QualityTime_Settings[setting] == nil then
            LHG_QualityTime_Settings[setting] = value
        end
    end
    
end

-- Resets everything to the default values except the times
local function RestoreDefaults()
    local idle_time = LHG_QualityTime_Settings.idle_time
    local combat_time = LHG_QualityTime_Settings.combat_time
    local regen_time = LHG_QualityTime_Settings.regen_time
    local travel_time = LHG_QualityTime_Settings.travel_time
    for setting, value in pairs(default_settings) do
        LHG_QualityTime_Settings[setting] = value
    end
    LHG_QualityTime_Settings.idle_time = idle_time
    LHG_QualityTime_Settings.combat_time = combat_time
    LHG_QualityTime_Settings.regen_time = regen_time
    LHG_QualityTime_Settings.travel_time = travel_time
end

local function UpdateVisuals()
    main_frame:SetWidth(LHG_QualityTime_Settings.width)
    main_frame:SetHeight(LHG_QualityTime_Settings.title_height)
    main_frame:SetPoint(LHG_QualityTime_Settings.rel_point, LHG_QualityTime_Settings.x_pos, LHG_QualityTime_Settings.y_pos)
    main_frame.title_frame:SetWidth(main_frame:GetWidth())
    main_frame.title_frame:SetHeight(LHG_QualityTime_Settings.title_height)
    main_frame.title_frame:SetPoint("TOP", 0, 0)
    main_frame.body_frame:SetWidth(main_frame:GetWidth())
    main_frame.body_frame:SetHeight(LHG_QualityTime_Settings.body_height)
    main_frame.body_frame:SetPoint("TOP", 0, -LHG_QualityTime_Settings.title_height+2)
    if LHG_QualityTime_Settings.is_locked then
        main_frame.title_frame.lock_button:SetNormalTexture("Interface/Addons/QualityTime/Images/LockedUp")
        main_frame.title_frame.lock_button:SetPushedTexture("Interface/Addons/QualityTime/Images/LockedDown")
    else
        main_frame.title_frame.lock_button:SetNormalTexture("Interface/Addons/QualityTime/Images/UnlockedUp")
        main_frame.title_frame.lock_button:SetPushedTexture("Interface/Addons/QualityTime/Images/UnlockedDown")
    end
    if LHG_QualityTime_Settings.is_paused then
        main_frame.title_frame.pause_play_button:SetNormalTexture("Interface/Addons/QualityTime/Images/PlayUp")
        main_frame.title_frame.pause_play_button:SetPushedTexture("Interface/Addons/QualityTime/Images/PlayDown")
    else
        main_frame.title_frame.pause_play_button:SetNormalTexture("Interface/Addons/QualityTime/Images/PauseUp")
        main_frame.title_frame.pause_play_button:SetPushedTexture("Interface/Addons/QualityTime/Images/PauseDown")
    end
end

-- Resets the state times.
local function ResetTimes()
    LHG_QualityTime_Settings.idle_time = 0
    LHG_QualityTime_Settings.combat_time = 0
    LHG_QualityTime_Settings.regen_time = 0
    LHG_QualityTime_Settings.travel_time = 0
end

-- Handles moving the main frame
local function OnDragMainFrameStart()
    if not LHG_QualityTime_Settings.is_locked then
        main_frame:StartMoving()
    end
end

-- Handles stopping the main frame
local function OnDragMainFrameStop()
    main_frame:StopMovingOrSizing()
    _, _, rel_point, x_pos, y_pos = main_frame:GetPoint()
    LHG_QualityTime_Settings.rel_point = rel_point
    LHG_QualityTime_Settings.x_pos = x_pos
    LHG_QualityTime_Settings.y_pos = y_pos
end

-- Handles what happens when the lock button is pressed
local function LockButtonOnClickHandler()
    LHG_QualityTime_Settings.is_locked = not LHG_QualityTime_Settings.is_locked
    UpdateVisuals()
end

-- Handle what happens when the user clicks the export button
local function ExportButtonOnClickHandler()
    file_name = "Interface/Addons/QualityTime/QTLog_"
    export_file = io.open(file_name, "w+")
    io.output(export_file)
    io.write("Howdy!")
    io.close(export_file)
end

local function PausePlayButtonOnClickHandler()
    LHG_QualityTime_Settings.is_paused = not LHG_QualityTime_Settings.is_paused
    UpdateVisuals()
end

-- Converts the given seconds float into a string with the 0D 00H 00M 00S format.
local function ConvertSecToDayHourMinSec(seconds)
    local days = 0
    local hrs = 0
    local mins = 0
    local secs = 0
    local remaining_secs = seconds
    local rtn_string = ""
    days = floor(remaining_secs/86400)
    remaining_secs = remaining_secs % 86400
    hrs = floor(remaining_secs/3600)
    remaining_secs = remaining_secs % 3600
    mins = floor(remaining_secs/60)
    remaining_secs = remaining_secs % 60
    secs = floor(remaining_secs)
    days_str = "D "
    hrs_str = "H "
    mins_str = "M "
    if (hrs < 10) then days_str = days_str .. "0" end
    if (mins < 10) then hrs_str = hrs_str .. "0" end
    if (secs < 10) then mins_str = mins_str .. "0" end
    rtn_string = tostring(days) .. days_str .. 
                 tostring(hrs) .. hrs_str .. 
                 tostring(mins) .. mins_str .. 
                 tostring(secs) .. "S"
    return rtn_string
end

-- Updates the state variable moved_far by keeping track of the previous 5 locations 
-- and averaging the distance between them. If the average moved distance is large enough then
-- moved_far is true.
local function UpdateMovedFar()
    -- Move the array of positions over one
    for i = #state_variables.locations, 2, -1 do
        state_variables.locations[i][1] = state_variables.locations[i-1][1]
        state_variables.locations[i][2] = state_variables.locations[i-1][2]
    end
    -- Added the most recent location to the array
    loc_y, loc_x, _, _ = UnitPosition("player")
    state_variables.locations[1][1] = loc_x
    state_variables.locations[1][2] = loc_y
    -- Add up the differences between the points and average them
    avg_dist = 0
    for i = 1, #state_variables.locations - 1, 1 do
        loc_x_1 = state_variables.locations[i][1]
        loc_y_1 = state_variables.locations[i][2]
        loc_x_2 = state_variables.locations[i + 1][1]
        loc_y_2 = state_variables.locations[i + 1][2]
        dist = math.sqrt(((loc_x_1 - loc_x_2)^2) + ((loc_y_1 - loc_y_2)^2))
        avg_dist = avg_dist + dist
    end
    avg_dist = avg_dist / (#state_variables.locations - 1)
    -- If the difference is significant then we have moved far
    if (avg_dist > 5) then
        state_variables.moved_far = true
    else
        state_variables.moved_far = false
    end
end

-- Updates the state variable full_resources by checking to see if the resources are full.
-- If the class is a warrior then the only resource that matters is HP.
local function UpdateFullResources()
    local health_perc = UnitHealth("player") / UnitHealthMax("player")
    local power_perc = UnitPower("player") / UnitPowerMax("player")
    state_variables.full_resources = true
    if (health_perc > 0.99) then
        if (state_variables.class ~= "WARRIOR") then
            if (power_perc < 0.99) then
                state_variables.full_resources = false
            end
        end
    else
        state_variables.full_resources = false
    end
end

-- Updates the state variable mounted by checking to see if the player is mounted
local function UpdateMounted()
    state_variables.mounted = IsMounted()
end

-- Updates the state based on the state variables. 
-- The state chart can be found in this addon's folder.
local function UpdateState()
    if (state_variables.mounted == true) then
        state_variables.state = "Traveling"
    else
        if (state_variables.in_combat == true) then
            state_variables.state = "Combat"
        else
            if (state_variables.full_resources == false) then
                state_variables.state = "Regenerating"
            else
                if (state_variables.moved_far == true) then
                    state_variables.state = "Traveling"
                else
                    state_variables.state = "Idle"
                end
            end
        end
    end
end

-- Update the ammount of time spent in a state.
local function UpdateTimeSpentInState(elapsed)
    if LHG_QualityTime_Settings.is_paused then
        return
    end
    if (state_variables.state == "Idle") then
        LHG_QualityTime_Settings.idle_time = LHG_QualityTime_Settings.idle_time + elapsed
    elseif (state_variables.state == "Combat") then
        LHG_QualityTime_Settings.combat_time = LHG_QualityTime_Settings.combat_time + elapsed
    elseif (state_variables.state == "Regenerating") then
        LHG_QualityTime_Settings.regen_time = LHG_QualityTime_Settings.regen_time + elapsed
    elseif (state_variables.state == "Traveling") then
        LHG_QualityTime_Settings.travel_time = LHG_QualityTime_Settings.travel_time + elapsed
    else
        print("Unknown state in UpdateTimeSpentInState: " .. tostring(state_variables.state))
    end
end

-- Update the text in the main frame
local function UpdateMainFrameText()
    final_name_text = "State:\n" ..
                      "\n" ..
                      "Idle Time:\n" ..
                      "Combat Time:\n" ..
                      "Regen Time:\n" ..
                      "Travel Time:\n"
    final_value_text = tostring(state_variables.state) .. "\n\n" ..
                       ConvertSecToDayHourMinSec(LHG_QualityTime_Settings.idle_time) .. "\n" ..
                       ConvertSecToDayHourMinSec(LHG_QualityTime_Settings.combat_time) .. "\n" ..
                       ConvertSecToDayHourMinSec(LHG_QualityTime_Settings.regen_time) .. "\n" ..
                       ConvertSecToDayHourMinSec(LHG_QualityTime_Settings.travel_time)
    main_frame.body_frame.name_text:SetText(final_name_text)
    main_frame.body_frame.value_text:SetText(final_value_text)
end

-- Initialize the main frame with all of its components and their sub-components
local function InitializeMainFrame(self)
    --[[Setup the main frame]]--
    main_frame:SetMovable(true)
    main_frame:EnableMouse(true)
    main_frame:RegisterForDrag("LeftButton")
    main_frame:Show()
    --[[Create the title frame]]--
    main_frame.title_frame = CreateFrame("Frame", "MainFrameTitle", main_frame)
    main_frame.title_frame:SetBackdrop({
        bgFile = "Interface/Addons/QualityTime/Images/UI-Background-Rock",
        edgeFile = "Interface/Addons/QualityTime/Images/UI-Tooltip-Border",
        tile = true,
        tileSize = 64,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    main_frame.title_frame:SetBackdropColor(1,1,1,1)
    -- Create the main frame title text
    main_frame.title_frame.text = main_frame.title_frame:CreateFontString(nil, "ARTWORK")
    main_frame.title_frame.text:SetFont("Interface/Addons/QualityTime/Fonts/Inconsolata-Regular.ttf", 16)
    main_frame.title_frame.text:SetJustifyH("LEFT")
	main_frame.title_frame.text:SetJustifyV("CENTER")
    main_frame.title_frame.text:SetText("QualityTime")
    main_frame.title_frame.text:SetPoint("LEFT",10, 0)
    -- Create the main frame reset button
    main_frame.title_frame.reset_btn = CreateFrame("Button", "ResetButton", main_frame)
    main_frame.title_frame.reset_btn:SetWidth(20)
    main_frame.title_frame.reset_btn:SetHeight(20)
    main_frame.title_frame.reset_btn:SetNormalTexture("Interface/Addons/QualityTime/Images/ResetTimerUp")
    main_frame.title_frame.reset_btn:SetPushedTexture("Interface/Addons/QualityTime/Images/ResetTimerDown")
    main_frame.title_frame.reset_btn:SetPoint("RIGHT", -4, 0)
    main_frame.title_frame.reset_btn:SetScript("OnClick", ResetTimes)
    -- Create the main frame export button
    --[[
    main_frame.title_frame.export_button = CreateFrame("Button", "ExportButton", main_frame)
    main_frame.title_frame.export_button:SetWidth(20)
    main_frame.title_frame.export_button:SetHeight(20)
    main_frame.title_frame.export_button:SetNormalTexture("Interface/Addons/QualityTime/Images/ExportUp")
    main_frame.title_frame.export_button:SetPushedTexture("Interface/Addons/QualityTime/Images/ExportDown")
    main_frame.title_frame.export_button:SetPoint("RIGHT", -26, 0)
    main_frame.title_frame.export_button:SetScript("OnClick", ExportButtonOnClickHandler)
    ]]--
    -- Create the main frame pause/play button
    main_frame.title_frame.pause_play_button = CreateFrame("Button", "ExportButton", main_frame)
    main_frame.title_frame.pause_play_button:SetWidth(20)
    main_frame.title_frame.pause_play_button:SetHeight(20)
    if LHG_QualityTime_Settings.is_paused then
        main_frame.title_frame.pause_play_button:SetNormalTexture("Interface/Addons/QualityTime/Images/PlayUp")
        main_frame.title_frame.pause_play_button:SetPushedTexture("Interface/Addons/QualityTime/Images/PlayDown")
    else
        main_frame.title_frame.pause_play_button:SetNormalTexture("Interface/Addons/QualityTime/Images/PauseUp")
        main_frame.title_frame.pause_play_button:SetPushedTexture("Interface/Addons/QualityTime/Images/PauseDown")
    end
    main_frame.title_frame.pause_play_button:SetPoint("RIGHT", -26, 0)
    main_frame.title_frame.pause_play_button:SetScript("OnClick", PausePlayButtonOnClickHandler)
    -- Create the main frame lock button
    main_frame.title_frame.lock_button = CreateFrame("Button", "LockButton", main_frame)
    main_frame.title_frame.lock_button:SetWidth(20)
    main_frame.title_frame.lock_button:SetHeight(20)
    if LHG_QualityTime_Settings.is_locked then
        main_frame.title_frame.lock_button:SetNormalTexture("Interface/Addons/QualityTime/Images/LockedUp")
        main_frame.title_frame.lock_button:SetPushedTexture("Interface/Addons/QualityTime/Images/LockedDown")
    else
        main_frame.title_frame.lock_button:SetNormalTexture("Interface/Addons/QualityTime/Images/UnlockedUp")
        main_frame.title_frame.lock_button:SetPushedTexture("Interface/Addons/QualityTime/Images/UnlockedDown")
    end
    main_frame.title_frame.lock_button:SetPoint("RIGHT", -48, 0)
    main_frame.title_frame.lock_button:SetScript("OnClick", LockButtonOnClickHandler)
    --[[Create the body frame]]--
    main_frame.body_frame = CreateFrame("Frame", "MainFrameBody", main_frame)
    main_frame.body_frame:SetBackdrop({
        bgFile = "Interface/Addons/QualityTime/Images/UI-Tooltip-Background",
        edgeFile = "Interface/Addons/QualityTime/Images/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4}
    })
    main_frame.body_frame:SetBackdropColor(0,0,0,1)
    -- Create the name text
    main_frame.body_frame.name_text = main_frame.body_frame:CreateFontString(nil, "ARTWORK")
    main_frame.body_frame.name_text:SetFont("Interface/Addons/QualityTime/Fonts/Inconsolata-Regular.ttf", 14)
    main_frame.body_frame.name_text:SetJustifyH("LEFT")
	main_frame.body_frame.name_text:SetJustifyV("TOP")
    main_frame.body_frame.name_text:SetPoint("TOPLEFT",10,-10)
    -- Create the value text
    main_frame.body_frame.value_text = main_frame.body_frame:CreateFontString(nil, "ARTWORK")
    main_frame.body_frame.value_text:SetFont("Interface/Addons/QualityTime/Fonts/Inconsolata-Regular.ttf", 14)
    main_frame.body_frame.value_text:SetJustifyH("RIGHT")
	main_frame.body_frame.value_text:SetJustifyV("TOP")
    main_frame.body_frame.value_text:SetPoint("TOPRIGHT",-10, -10)
    -- Update the visuals
    UpdateVisuals()
end

-- The OnEvent Event handler for the main frame
local function MainFrame_OnEvent(self, event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        LoadSettings()
        InitializeMainFrame()
        _, state_variables.class, _ = UnitClass("player")
        PrintMsg(load_message)
    elseif (event == "PLAYER_REGEN_ENABLED") then
        state_variables.in_combat = false
    elseif (event == "PLAYER_REGEN_DISABLED") then
        state_variables.in_combat = true
    end
end

-- The OnUpdate Event handler for the main frame.
-- Only fires on occassion based on variables at the top of the file.
local function MainFrame_OnUpdate(self, elapsed)
    time_till_refresh = time_till_refresh - elapsed
    time_till_refresh_loc = time_till_refresh_loc - elapsed
    if (time_till_refresh_loc < 0) then
        UpdateMovedFar()
        time_till_refresh_loc = def_time_till_refresh_loc
    end
    if (time_till_refresh < 0 ) then
        UpdateFullResources()
        UpdateMounted()
        UpdateState()
        UpdateTimeSpentInState(def_time_till_refresh)
        UpdateMainFrameText()
        time_till_refresh = def_time_till_refresh
    else
        
    end
    
end

-- Registering functions to events that happen to the main frame
main_frame:SetScript("OnEvent", MainFrame_OnEvent)
main_frame:SetScript("OnUpdate", MainFrame_OnUpdate)
main_frame:SetScript("OnDragStart", OnDragMainFrameStart)
main_frame:SetScript("OnDragStop", OnDragMainFrameStop)

-- Add a slash command to bring back the window and reset to the defaults.
SLASH_QUALITYTIME_CONFIG1 = "/qualitytime"
SLASH_QUALITYTIME_CONFIG2 = "/QualityTime"
SlashCmdList["QUALITYTIME_CONFIG"] = function(option)
    local args = {strsplit(" ", option)}
    local cmd = args[1]
    if (cmd == "") then
        PrintMsg(help_message)
    elseif (cmd == "reset_times") then
        ResetTimes()
        PrintMsg(reset_time_message)
    elseif (cmd == "lock") then
        LHG_QualityTime_Settings.is_locked = false
        LockButtonOnClickHandler()
        PrintMsg(lock_message)
    elseif (cmd == "unlock") then
        LHG_QualityTime_Settings.is_locked = true
        LockButtonOnClickHandler()
        PrintMsg(unlock_message)
    elseif (cmd == "pause") then
        LHG_QualityTime_Settings.is_paused = false
        PausePlayButtonOnClickHandler()
        PrintMsg(pause_message)
    elseif (cmd == "play") then
        LHG_QualityTime_Settings.is_paused = true
        PausePlayButtonOnClickHandler()
        PrintMsg(play_message)        
    elseif (cmd == "restore_defaults") then
        RestoreDefaults()
        UpdateVisuals()
        C_UI.Reload()
        PrintMsg(restore_defaults_message)
    end
end