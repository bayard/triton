local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local HEIGHT_NO_CONTENT = 71;
local listItemHeight = TritonKeywordUI.scrollFrame.items[1]:GetHeight();
local listElementCount = #TritonKeywordUI.scrollFrame.items;
local maxElementCount = listElementCount;

local sortedEntries = {};
local entryCount = 0;

----------------------------------------------------------------------------------------------------------------
-- Top bar button actions
----------------------------------------------------------------------------------------------------------------

--- Open settings menu
TritonKeywordUI.settingsBtn:SetScript("OnClick", function(self) 
    InterfaceOptionsFrame_Show()
    InterfaceOptionsFrame_OpenToCategory(addonName);
    InterfaceOptionsFrame_OpenToCategory(addonName);
end);

--- Open add frame
TritonKeywordUI.addBtn:SetScript("OnClick", function(self)
    addon:MainUI_ShowAddForm();
end);

--- Toggle addon on/off
TritonKeywordUI.toggleBtn:SetScript("OnClick", function(self) 
    addon:ToggleAddon();
    TritonKeywordUI:UpdateKeywordUIState();
end);

--- Open delete frame
TritonKeywordUI.deleteBtn:SetScript("OnClick", function(self) 
    TritonKeywordUI:ShowContent("RM");
end);


----------------------------------------------------------------------------------------------------------------
-- Content frame button actions
----------------------------------------------------------------------------------------------------------------

-- Delete all frame buttons
TritonKeywordUI.deleteAllFrame.okbutton:SetScript("OnClick", function(self) 
    addon:ClearList();
    TritonKeywordUI:ShowContent("LIST");
end);
TritonKeywordUI.deleteAllFrame.backbutton:SetScript("OnClick", function(self) 
    TritonKeywordUI:ShowContent("LIST");
end);

-- Add frame buttons
TritonKeywordUI.addFrame.okbutton:SetScript("OnClick", function (self)
    local sstring = TritonKeywordUI.addFrame.searchEdit:GetText();
    sstring = strtrim(sstring);
    if string.len(sstring) == 0 then
        addon:PrintError(L["Keyword could not be empty"]);
		return;
    end
	addon:AddToList(sstring);
	TritonKeywordUI:ShowContent("LIST");
end);
TritonKeywordUI.addFrame.backbutton:SetScript("OnClick", function (self)
	TritonKeywordUI:ShowContent("LIST");
end);

-- Edit frame functions
TritonKeywordUI.editFrame:SetScript("OnShow", function(self)
    self.oldsearch = self.searchEdit:GetText()
end)

TritonKeywordUI.editFrame.backbutton:SetScript("OnClick", function(self)
    TritonKeywordUI:ShowContent("LIST")
end)

TritonKeywordUI.editFrame.okbutton:SetScript("OnClick", function(self)
    local nstring = strtrim(TritonKeywordUI.editFrame.searchEdit:GetText())
    if string.len(nstring) == 0 then
        addon:PrintError(L["Keyword could not be empty"]);
		return;
    end
     addon:RemoveFromList(TritonKeywordUI.editFrame.oldsearch)
     addon:AddToList(nstring); 
    TritonKeywordUI:ShowContent("LIST")
end)


----------------------------------------------------------------------------------------------------------------
-- Control functions
----------------------------------------------------------------------------------------------------------------

--- Show the add form
-- @param search A search string to prefill (optional)
function addon:MainUI_ShowAddForm(search)
    if search == nil and TritonKeywordUI:IsShown() and TritonKeywordUI.addFrame:IsShown() then 
        return; 
    end
    
	TritonKeywordUI.addFrame.searchEdit:SetText("");
	if search ~= nil then
		TritonKeywordUI.addFrame.searchEdit:SetText(search);
		TritonKeywordUI.addFrame.searchEdit:SetCursorPosition(0);
    else
        TritonKeywordUI.addFrame.searchEdit:SetFocus();
    end
    
    TritonKeywordUI:Show();
    TritonKeywordUI:ShowContent("ADD");
end

--- Update scroll frame 
local function UpdateScrollFrame()
    local scrollHeight = 0;
	if entryCount > 0 then
        scrollHeight = (entryCount - listElementCount) * listItemHeight;
        if scrollHeight < 0 then
            scrollHeight = 0;
        end
    end

    local maxRange = (entryCount - listElementCount) * listItemHeight;
    if maxRange < 0 then
        maxRange = 0;
    end

    TritonKeywordUI.scrollFrame.ScrollBar:SetMinMaxValues(0, maxRange);
    TritonKeywordUI.scrollFrame.ScrollBar:SetValueStep(listItemHeight);
    TritonKeywordUI.scrollFrame.ScrollBar:SetStepsPerPage(listElementCount-1);

    if TritonKeywordUI.scrollFrame.ScrollBar:GetValue() == 0 then
        TritonKeywordUI.scrollFrame.ScrollBar.ScrollUpButton:Disable();
    else
        TritonKeywordUI.scrollFrame.ScrollBar.ScrollUpButton:Enable();
    end

    if (TritonKeywordUI.scrollFrame.ScrollBar:GetValue() - scrollHeight) == 0 then
        TritonKeywordUI.scrollFrame.ScrollBar.ScrollDownButton:Disable();
    else
        TritonKeywordUI.scrollFrame.ScrollBar.ScrollDownButton:Enable();
    end	

    for line = 1, listElementCount, 1 do
      local offsetLine = line + FauxScrollFrame_GetOffset(TritonKeywordUI.scrollFrame);
      local item = TritonKeywordUI.scrollFrame.items[line];
      if offsetLine <= entryCount then
        curdta = addon.db.global.keywords[sortedEntries[offsetLine]];
        item.searchString:SetText(sortedEntries[offsetLine]);
		if curdta.active then
			item.disb:SetNormalTexture([[Interface\AddOns\Triton\Media\on]]);
            item.disb:SetHighlightTexture([[Interface\AddOns\Triton\Media\on]]);
            item.disb:GetParent():SetBackdropColor(0.2,0.2,0.2,0.8);
            item.searchString:SetTextColor(1, 1, 1, 1);
		else
			item.disb:SetNormalTexture([[Interface\AddOns\Triton\Media\off]]);
            item.disb:SetHighlightTexture([[Interface\AddOns\Triton\Media\off]]);
            item.disb:GetParent():SetBackdropColor(0.2,0.2,0.2,0.4);
            item.searchString:SetTextColor(0.5, 0.5, 0.5, 1);
        end
        item:Show();
      else
        item:Hide();
      end
    end
end

--- Recalculates height and shown item count
-- @param ignoreHeight If true will not resize and reanchor UI
local function RecalculateSize(ignoreHeight)
    local oldHeight = TritonKeywordUI:GetHeight();
    local showCount = math.floor((oldHeight - HEIGHT_NO_CONTENT + (listItemHeight/2 + 2)) / listItemHeight);

    if ignoreHeight ~= true then
        local newHeight = showCount * listItemHeight + HEIGHT_NO_CONTENT;

        TritonKeywordUI:SetHeight(newHeight);

        local point, relTo, relPoint, x, y = TritonKeywordUI:GetPoint(1);
        local yadjust = 0;

        if point == "CENTER" or point == "LEFT" or point == "RIGHT" then
            yadjust = (oldHeight - newHeight) / 2;
        elseif point == "BOTTOM" or point == "BOTTOMRIGHT" or point == "BOTTOMLEFT" then
            yadjust = oldHeight - newHeight;
        end

        TritonKeywordUI:ClearAllPoints();
        TritonKeywordUI:SetPoint(point, relTo, relPoint, x, y + yadjust);
    end

    for i = 1, maxElementCount, 1 do
        if i > showCount then
            TritonKeywordUI.scrollFrame.items[i]:Hide();
        end
    end

    listElementCount = showCount;
    UpdateScrollFrame();
end

--- Fill list from SV data
function addon:MainUI_UpdateList()
	entryCount = 0;
	wipe(sortedEntries);
    if addon.db.global.keywords ~= nil then
    	for k in pairs(addon.db.global.keywords) do 
    		table.insert(sortedEntries, k);
    		entryCount = entryCount + 1;
    	end
    end
    table.sort(sortedEntries);
    UpdateScrollFrame();
end

--- Open the main list frame
function addon:KeywordUI_OpenList()
    TritonKeywordUI:Show();
    TritonKeywordUI:ShowContent("LIST");
    
    TritonKeywordUI:UpdateKeywordUIState( true );
    RecalculateSize(true);
    UpdateScrollFrame();
end


----------------------------------------------------------------------------------------------------------------
-- Resize behaviour
----------------------------------------------------------------------------------------------------------------

-- Trigger update on scroll action
TritonKeywordUI.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, listItemHeight, UpdateScrollFrame);
end);

TritonKeywordUI.resizeBtn:SetScript("OnMouseDown", function(self, button) 
    TritonKeywordUI:StartSizing("BOTTOMRIGHT"); 
end);

-- Resize snaps to full list items shown, updates list accordingly
TritonKeywordUI.resizeBtn:SetScript("OnMouseUp", function(self, button) 
    TritonKeywordUI:StopMovingOrSizing(); 
    RecalculateSize();
end);