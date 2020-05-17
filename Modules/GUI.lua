local addonName, addon = ...
local GUI = addon:NewModule("GUI", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

local fontName, fontHeight, fontFlags = DEFAULT_CHAT_FRAME:GetFont()


-- printing debug info
function GUI:DebugPrintf(...)
	if addon.isDebug then
		GUI:Printf(...)
	end
	-- addon.DebugLog(format(...))
end

-- do things on logout
function GUI:OnLogout()
end

function GUI:CreateNativeFrame( frmWidth, frmHeight )
	tObj = CreateFrame("Frame", "TritonUIFrame", UIParent)
    tObj:SetPoint("CENTER", UIParent, "CENTER")
    tObj:SetHeight(frmHeight)
    tObj:SetWidth(frmWidth)
    tObj:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 1, edgeSize = 10, insets = { left = 0, right = 0, top = 0, bottom = 0 }})
    tObj:SetBackdropColor(0, 0, 0, 0.75)
    tObj:EnableMouse(true)
    tObj:SetMovable(true)
    tObj:SetResizable(true)
    tObj:SetScript("OnDragStart", function(self) 
        self.isMoving = true
        self:StartMoving() 
    end)
    tObj:SetScript("OnDragStop", function(self) 
        self.isMoving = false
        self:StopMovingOrSizing() 
        self.x = self:GetLeft() 
        self.y = (self:GetTop() - self:GetHeight()) 
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x, self.y)
    end)
    tObj:SetScript("OnUpdate", function(self) 
        if self.isMoving == true then
            self.x = self:GetLeft() 
            self.y = (self:GetTop() - self:GetHeight()) 
            self:ClearAllPoints()
            self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x, self.y)
        end
    end)
    tObj:SetClampedToScreen(true)
    tObj:RegisterForDrag("LeftButton")
    tObj:SetScale(1)
    tObj.x = tObj:GetLeft() 
    tObj.y = (tObj:GetTop() - tObj:GetHeight()) 
    -- tObj:Show()
 
    local resizeButton = CreateFrame("Button", "resButton", tObj)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT")
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.isSizing = true
            self:GetParent():StartSizing("BOTTOMRIGHT")
            self:GetParent():SetUserPlaced(true)
        elseif button == "RightButton" then
            self.isScaling = true
        end
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.isSizing = false
            self:GetParent():StopMovingOrSizing()
        elseif button == "RightButton" then
            self.isScaling = false
        end
    end)
    resizeButton:SetScript("OnUpdate", function(self, button)
        if self.isScaling == true then
            local cx, cy = GetCursorPosition()
            cx = cx / self:GetEffectiveScale() - self:GetParent():GetLeft() 
            cy = self:GetParent():GetHeight() - (cy / self:GetEffectiveScale() - self:GetParent():GetBottom() )
 
            local tNewScale = cx / self:GetParent():GetWidth()
            local tx, ty = self:GetParent().x / tNewScale, self:GetParent().y / tNewScale
            
            self:GetParent():ClearAllPoints()
            self:GetParent():SetScale(self:GetParent():GetScale() * tNewScale)
            self:GetParent():SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", tx, ty)
            self:GetParent().x, self:GetParent().y = tx, ty
        end
    end)

	local closeButton = CreateFrame("BUTTON", "closeButton", tObj, "UIPanelCloseButton")
	closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT")
    --closeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    --closeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    --closeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	closeButton:SetScript("OnClick", function()
		tObj:Hide()
	end)
	tObj.closeButton = closeButton

    return tObj
end

function GUI:Load()
	-- Create frame container
	local frame = GUI:CreateNativeFrame( 480, 320 )

	frame:Show()

	GUI.display = frame
	GUI.display:Show()

	return GUI.display
end

function GUI:Load_Ace_Custom()

	--if GUI.display ~= nil then
	--	AceGUI:Release(GUI.display)
	--	GUI.display = nil
	--end

	local frame = AceGUI:Create("TritonFrame")

	addon.db.global.ui = addon.db.global.ui or {}
	frame:SetStatusTable(addon.db.global.ui)

	frame:SetTitle(addonName)
	frame.titletext:SetFont(fontName, 11.8)

	-- sizer adjust
	--[[
	frame.sizer_se:SetSize(10,10)
	frame.sizer_s:SetSize(10,10)
	frame.sizer_e:SetSize(10,10)
  	]]
  	
  	-- When close button clicked
	frame:SetCallback("OnClose",
		function(widget) 
			addon.TritonMessage:UnhookMessages()
			AceGUI:Release(widget) 
		end)
  
  	-- When settings button clicked
	frame:SetCallback("OnSettingsClick",
		function(widget) 
      		addon:KeywordUI_OpenList();
		end)
  
  	-- When power button clicked
  	frame:SetCallback("OnPowerClick",
		function(widget) 
      		addon:ToggleAddon();
      		TritonKeywordUI:UpdateKeywordUIState();
		end)
  
	frame:SetLayout("Fill")

	GUI.display = frame

	-- Add children
	local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	--local frame = scrollcontainer
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!
	GUI.display:AddChild(scrollcontainer)

	local scroll = AceGUI:Create("TritonScrollFrame")
	scroll:SetLayout("Flow") -- probably?
	scroll:SetFullWidth(true)
	scrollcontainer:AddChild(scroll)

	-- the scroll container is to hold message widgets
	self.scroll = scroll

	--addon:Printf('Wipe self.lines table')
	-- the table to save widgets
	if(self.lines ~=nil ) then
		wipe(self.lines)
	end
	self.lines = {}

	-- GUI:testmsg(scroll)

	-- Hook and filter chat messages
	-- addon.TritonMessage:HookMessages()

	return GUI.display
end

function GUI:UpdateAddonUIStatus(isactive)
  GUI.display:OnPowerButtonStatus(isactive)
  if isactive then
    GUI.display.titletext:SetTextColor(1, 0.82, 0, 1);
  else
    GUI.display.titletext:SetTextColor(1, 0, 0, 1);
  end
end

function GUI:RefreshTopicsOld(topics)

	-- release all child widgets
	self.scroll:ReleaseChildren()

	--[[
    Count = 0
    for Index, Value in pairs( topics ) do
        Count = Count + 1
    end
    print("Topics number=" .. tostring(Count))
	]]
	
	for key, topic in pairs(topics) do
		-- addon:Printf("test " .. topic["msg"])

		local linecontainer = AceGUI:Create("SimpleGroup")
		linecontainer:SetFullWidth(true)
		linecontainer:SetLayout("Flow")
		--linecontainer:SetHeight(25)

		--[[
		--local msgHeader = AceGUI:Create("Button")
		--msgHeader:SetText(L["@"])
		--msgHeader:SetWidth(100)
		local msgHeader = AceGUI:Create("Icon")
		msgHeader:SetImageSize(16,16)
		--local msgHeader = AceGUI:Create("TritonLabel")
		--msgHeader:SetText("M")
		--msgHeader:SetImage("Interface\\Addons\\Triton\\Media\\chat.png")
		--msgHeader:SetImage("Interface\\Icons\\Ability_Rogue_Sprint") 
		msgHeader:SetImage("Interface\\AddOns\\Triton\\Media\\chat-bubble")
		--msgHeader:SetImageSize(20,20)
		msgHeader:SetRelativeWidth(0.05)
		msgHeader:SetWidth(25)
		--msgHeader:SetHeight(25)
		msgHeader:SetPoint("LEFT")
		linecontainer:AddChild(msgHeader)
		]]

		local msgLine = AceGUI:Create("TritonLabel")
		msgLine:SetText(topic["msg"])
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetRelativeWidth(1)
		msgLine:SetHeight(25)
		msgLine:SetPoint("RIGHT")
		msgLine:SetFont(fontName, addon.db.global.fontsize)
		msgLine:SetCallback("OnEnter", ShowLabelTooltip(self))

		linecontainer:AddChild(msgLine)

		self.scroll:AddChild(linecontainer)
	end
end

function GUI:AddTopics(topics, topic)

	local linecontainer = AceGUI:Create("SimpleGroup")
	linecontainer:SetFullWidth(true)
	linecontainer:SetLayout("Flow")
	--linecontainer:SetHeight(25)

	local msgLine = AceGUI:Create("TritonLabel")
	msgLine:SetText(topic["msg"])
	--msgLine:SetRelativeWidth(0.93)
	msgLine:SetRelativeWidth(1)
	msgLine:SetHeight(25)
	msgLine:SetPoint("RIGHT")
	msgLine:SetFont(fontName, addon.db.global.fontsize)
	msgLine:SetCallback("OnEnter", ShowLabelTooltip)

	linecontainer:AddChild(msgLine)

	-- save container info in topic table
	--topic["widget"] = linecontainer
	--topic["label"] = msgLine

	-- find the latest topic
	local latestTopic = nil
	for key, t in pairs(topics) do
		if( (latestTopic == nil)  or ( latestTopic["time"] < t["time"] ) ) then
			latestTopic = t
		end
	end

	-- if latest topic found in previous
	if latestTopic == nil then
		self.scroll:AddChild(linecontainer)
	else
		self.scroll:AddChild(linecontainer, latestTopic["widget"])
	end

	return msgLine, linecontainer
end

function GUI:TouchTopic(topic)
	--print(table_to_string(topic))
	local secs = math.floor(GetTime() - topic["time"])
	topic["label"]:SetText( secs .. "s " .. topic["msg"])
end

function GUI:RemoveTopics(topic)
	--topic["widget"]:Release()
	topic["widget"].frame.Hide()
end

function GUI:AdjustLines(topics)
	local tsize = table_count(topics)
	local lsize = table_count(self.lines)
	local newlines = tsize - lsize
	--addon:Printf("newlines: " .. tostring(tsize) .. "-" .. tostring(lsize) .. "=" .. tostring(newlines))

	-- Add widgets to contain new lines
	if(newlines>=0) then
		for i = 1, newlines do
			--[[
			local linecontainer = AceGUI:Create("SimpleGroup") 
			linecontainer:SetFullWidth(true)
			linecontainer:SetLayout("Flow")
			]]

			local msgLine = AceGUI:Create("TritonLabel")
			--msgLine:SetRelativeWidth(0.93)
			msgLine:SetRelativeWidth(1)
			msgLine:SetHeight(addon.db.global.fontsize)
			msgLine:SetPoint("LEFT", 0, 0)
			msgLine:SetFont(fontName, addon.db.global.fontsize)
			--msgLine:SetFont(fontName, addon.db.global.fontsize, "THICKOUTLINE")
			--msgLine:SetFont("Interface\\Addons\\Triton\\Media\\Emblem.ttf", addon.db.global.fontsize)
			msgLine:SetCallback("OnEnter", ShowLabelTooltip)
			msgLine:SetCallback("OnClick", ClickLabel)

			--[[
			linecontainer:AddChild(msgLine)
			-- add line widget to scroll frame
			self.scroll:AddChild(linecontainer)
			]]

			self.scroll:AddChild(msgLine)

			-- apppend widgets in lines table
			line_widgets = {}
			-- line_widgets["linecontainer"] = linecontainer
			line_widgets["msgLine"] = msgLine
			table.insert(self.lines, line_widgets)
		end
	-- Remember to hide tailing empty lines 
	else
		for i = lsize, lsize+newlines+1, -1 do
			self.lines[i]["msgLine"]:SetText(nil)
			--self.lines[i]["msgLine"]:SetHeight(0)
			--self.lines[i]["linecontainer"]:SetHeight(0)
		end
	end


end

function GUI:RefreshTopicsSorted(topics, sort_field)
	self:AdjustLines(topics)

	local widgetIdx = 1
	local curTime = GetTime()

	function tcompare(a, b)
		return a[sort_field]>b[sort_field]
	end

	local sortedKeys = getKeysSortedByValue(topics, tcompare)

	for _, key in ipairs(sortedKeys) do
		-- addon:Printf("RefreshTopics: " .. topics[key]["msg"])
		local secs = curTime - topics[key]["time"]
		secs = math.floor(secs)

		local playerStr = ""
        local ccolor = RAID_CLASS_COLORS[topics[key]["class"]].colorStr
        playerStr = "|c" .. ccolor .. topics[key]["nameonly"]

        -- tostring(widgetIdx) .. " " ..
		local dispMsg = "|cff00cc00" .. topics[key]["keyword"] .. 
			" |cffca99ff[" ..playerStr .. 
			"|cffca99ff] |cff00cccc" .. topics[key]["msg"] ..  
			" |cff666666" .. tostring(secs) .. "s";
		self.lines[widgetIdx]["msgLine"]:SetText(dispMsg)

		-- if new update on old message
		if( topics[key]['animate'] ) then
			-- create animation
			--addon:Printf("do alpha animation")
			f = self.lines[widgetIdx]["msgLine"].frame
			flasher = f:CreateAnimationGroup() 

			fade1 = flasher:CreateAnimation("Alpha")
			fade1:SetDuration(0.3)
			fade1:SetFromAlpha(0.8)
			fade1:SetToAlpha(0.2)
			fade1:SetOrder(1)

			fade2 = flasher:CreateAnimation("Alpha")
			fade2:SetDuration(0.7)
			fade2:SetFromAlpha(0.2)
			fade2:SetToAlpha(1)
			fade2:SetOrder(2)

			flasher:Play()
		end

		-- save current top in widget line's container
		self.lines[widgetIdx]["topic"] = topics[key]

		-- increase index to access next widget line
		widgetIdx = widgetIdx + 1
	end

	-- refresh scroll frame
	self.scroll:DoLayout()
end

function GUI:RefreshTopicsNormal(topics)
	self:AdjustLines(topics)

	local widgetIdx = 1
	local curTime = GetTime()

	for key, topic in pairs(topics) do
		-- addon:Printf("RefreshTopics: " .. topics[key]["msg"])
		local secs = curTime - topic["time"]
		secs = math.floor(secs)

		local playerStr = ""
        local ccolor = RAID_CLASS_COLORS[topic["class"]].colorStr
        playerStr = "|c" .. ccolor .. topic["nameonly"]

        -- tostring(widgetIdx) .. " " .. 
		local dispMsg = "|cff00cc00" .. topic["keyword"] .. 
			" |cff7020d0[" ..playerStr .. 
			"|cff7020d0] |cff00cccc" .. topic["msg"] ..  
			" |cffcccccc[" .. tostring(secs) .. "s]";
		self.lines[widgetIdx]["msgLine"]:SetText(dispMsg)
		self.lines[widgetIdx]["topic"] = topic
		widgetIdx = widgetIdx + 1
	end

	-- refresh scroll frame
	self.scroll:DoLayout()
end

function GUI:RefreshTopics(topics)
	--self:RefreshTopicsNormal(topics)

	-- Sorted by last update time`
	GUI:RefreshTopicsSorted(topics, "time")

	-- Sorted by first create time
	--GUI:RefreshTopicsSorted(topics, "createtime")
end

function GUI:ShowTooltip(from_widget)
	--GameTooltip:SetOwner(from_widget, "ANCHOR_RIGHT")
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
	local itemLink = "|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r"
    if itemLink then
		--addon:Printf('ShowLabelTooltip')
        GameTooltip:SetHyperlink(itemLink)
    else
        GameTooltip:AddLine("Non-existant link !")
    end
    GameTooltip:Show()
end

function ShowLabelTooltip(from_widget)
	--GUI:ShowTooltip(from_widget)
end

--[[
function ChatBox_UnitPopup_OnClick()
	local index = this.value;
	local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
	local button = UnitPopupMenus[this.owner][index];
	local unit = dropdownFrame.unit;
	local name = dropdownFrame.name;
	local notFound = false;

	if ( button == "WHO" ) then
		SendWho("n-"..name);
	elseif ( button == "TARGET" ) then
		TargetByName(name);
	elseif ( button == "IGNORE" ) then
		AddIgnore(name);
	elseif ( button == "UNIGNORE" ) then
		DelIgnore(name);
	elseif ( button == "ADDFRIEND" ) then
		AddFriend(name);
	elseif ( button == "REMOVEFRIEND" ) then
		RemoveFriend(name);
	else
	   notFound = true;
	end

	if notFound then
		CB_Orig_UnitPopup_OnClick();
	else
	  	PlaySound("UChatScrollButton");
	end
end
]]

function GUI:WhisperPlayer(from_widget)
	for k, v in pairs(self.lines) do
		if v["msgLine"] == from_widget then
			ChatFrame_SendTell(v["topic"].from)
			break
		end
	end
end

function ClickLabel(from_widget)
	buttonName = GetMouseButtonClicked();
	--addon:Printf('ClickLabel:' .. buttonName)
	if buttonName == "LeftButton" then
		GUI:WhisperPlayer(from_widget)
	else
		if buttonName == "RightButton" then
			--local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
			--local name = dropdownFrame.name
			--ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
			--GameTooltip:SetHyperlink("item:16846:0:0:0:0:0:0:0")
		end
	end
end
------------------------------------------------------------------------------
-- EOF

