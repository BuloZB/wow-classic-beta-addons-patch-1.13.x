--PUI UI Version 1.0
--Author: MinguasBeef
--Description: PUI UI is intended to make panel development for addons simple and less cluttered.

function PUI_Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end
  
  function PUI_FormatWidgetName(addonID, widgetType, panelName)
      local formattedPanelName = "PUI_" .. widgetType .. "_" .. addonID .. "_" .. panelName
      return formattedPanelName
  end
  
  --Example Usage: local frame = PUI_GenerateFrame()
  --				 local frame = PUI_GenerateFrame("MyFrameName")
  function PUI_GenerateFrame(name)
      local frame = CreateFrame("Frame", name, UIParent)
      frame.events = {}
  
      function frame:RegisterNewEvent(eventname, eventfunction)
          frame.events[eventname] = eventfunction
          frame:RegisterEvent(eventname)
      end
  
      frame:SetScript("OnEvent", function(self, event, ...)
          if not frame.events[event] then
              return
          end
          frame.events[event](...)
      end)
  
      return frame
  end
  
  --Example Usage: PUI_RegisterPanel(addonID, "Main Panel", nil)
  --               PUI_RegisterPanel(addonID, "Subpanel","Main Panel")
  function PUI_RegisterPanel(addonID, panelName, parentPanelName)
      local formattedPanelName = PUI_FormatWidgetName(addonID, "PANEL", panelName)
      local formattedParentName = ""
      if (parentPanelName == nil) then
          formattedParentName = UIParent
      else
          formattedParentName = PUI_FormatWidgetName(addonID, "PANEL",parentPanelName)
      end
      
      if (parentPanelName == nil) then
          _G[formattedPanelName] = CreateFrame( "Frame", formattedPanelName, UIParent );
      else
          _G[formattedPanelName] = CreateFrame( "Frame", formattedPanelName, _G[formattedParentName] );
          _G[formattedPanelName].parent = _G[formattedParentName].name
      end
      _G[formattedPanelName].name = panelName
      InterfaceOptions_AddCategory(_G[formattedPanelName]);
      _G[formattedPanelName].lastWidget = nil
      _G[formattedPanelName].children = {}
      return _G[formattedPanelName]
  end
  
  --Usage Example: PUI_RegisterSlider(addonID, "My Addon", "slideridxyz", "Test Slider", "This is a test.", 200, 20, 0, 10, 1, 0, nil)
  function PUI_RegisterSlider(addonID, panelName, sliderID, description, toolTip, width, height, minValue, maxValue, stepValue, decimalPlaces, callback)
  
      local formattedPanelName = PUI_FormatWidgetName(addonID, "PANEL", panelName)
      local formattedSliderName = PUI_FormatWidgetName(addonID, "SLIDER",sliderID)
      local slider = CreateFrame("Slider", formattedSliderName, _G[formattedPanelName], "OptionsSliderTemplate")
      slider:SetWidth(width)
      slider:SetHeight(height)
      slider.tooltipText = toolTip --Creates a tooltip on mouseover.
      slider:SetMinMaxValues(minValue, maxValue)
      slider:SetValue(minValue)
      slider:SetValueStep(stepValue)
      slider:Show()
      slider:SetPoint("CENTER")
      slider:SetOrientation('HORIZONTAL')
      slider.description = description
      slider.id = sliderID
      slider.decimalPlaces = decimalPlaces
      slider.type = "SLIDER"
      
      function slider:SetLowText(text)
          _G[slider:GetName() .. 'Low']:SetText(text); --Sets the left-side slider text (default is "Low").
      end
  
      function slider:SetHighText(text)
          _G[slider:GetName() .. 'High']:SetText(text); --Sets the right-side slider text (default is "High").
      end
  
      function slider:SetText(text)
          _G[slider:GetName() .. 'Text']:SetText(text); --Set display text above slider
      end
  
      slider:SetText(description)
  
      if (_G[formattedPanelName].lastWidget == nil) then
          slider:SetPoint("TOPLEFT", _G[formattedPanelName], "TOPLEFT", 25, -30)
      else
          slider:SetPoint("BOTTOMLEFT", _G[formattedPanelName].lastWidget, "BOTTOMLEFT", 0, -65)
      end
      _G[formattedPanelName].lastWidget = slider
      
      if (callback ~= nil) then
          slider:SetScript("OnValueChanged", function(self, value) callback(self, value) end)
      end
  
      _G[formattedPanelName].children[formattedSliderName] = slider
      _G[formattedSliderName] = slider
  
      return slider
  end
  
  --Example Usage:  PUI_RegisterCheckBox(addonID, "My Addon", "checkboxidxyz", "Checkbox Label", "Stuff happens when you click this checkbox", 25, 25, nil)
  function PUI_RegisterCheckBox(addonID, panelName, checkboxID, description, toolTip, width, height, callback)
      local formattedPanelName = PUI_FormatWidgetName(addonID, "PANEL", panelName)
      local formattedCheckBoxname = PUI_FormatWidgetName(addonID, "CHECKBOX", checkboxID)
      
      local checkbutton = CreateFrame("CheckButton", formattedCheckBoxname, _G[formattedPanelName], "ChatConfigCheckButtonTemplate")
      checkbutton:SetWidth(width)
      checkbutton:SetHeight(height)
      checkbutton.tooltip = toolTip --Creates a tooltip on mouseover.
      checkbutton:SetChecked(defaultValue)
      checkbutton:Show()
      checkbutton:SetPoint("CENTER")
      checkbutton.description = description
      checkbutton.id = checkboxID
      checkbutton.type = "CHECKBOX"
      
      function checkbutton:SetText(text)
          _G[checkbutton:GetName() .. 'Text']:SetText(text);
      end
      
      checkbutton:SetText(description)
  
      if (_G[formattedPanelName].lastWidget == nil) then
          checkbutton:SetPoint("TOPLEFT", _G[formattedPanelName], "TOPLEFT", 25, -20)
      else
          checkbutton:SetPoint("BOTTOMLEFT", _G[formattedPanelName].lastWidget, "BOTTOMLEFT", 0, -35)
      end
  
      _G[formattedPanelName].lastWidget = checkbutton
      
      if (callback ~= nil) then
          checkbutton:SetScript("OnClick", function(self) callback(self) end)
      end
      
      _G[formattedPanelName].children[formattedCheckBoxname] = checkbutton
      return checkbutton
  end
  