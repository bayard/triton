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

	self:CreateScrollContainer()

	--addon:Printf('Wipe self.lines table')
	-- the table to save widgets
	if(self.lines ~=nil ) then
		wipe(self.lines)
	end
	self.lines = {}

	-- test insert lines
	-- GUI:testmsg()

	return GUI.display
end

function GUI:CreateScrollContainer()
	-- Add children
	local scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	--local frame = scrollcontainer
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!
	GUI.display:AddChild(scrollcontainer)

	local scroll = AceGUI:Create("TritonScrollFrame")
	-- customized layout
	scroll:SetLayout("Triton")
	scroll:SetFullWidth(true)
	scroll:SetFullHeight(true)
	scroll:SetAutoAdjustHeight(true)
	scrollcontainer:AddChild(scroll)

	-- the scroll container is to hold message widgets
	self.scroll = scroll
	self.scrollcontainer = scrollcontainer
end

function GUI:UpdateAddonUIStatus(isactive)
  GUI.display:OnPowerButtonStatus(isactive)
  if isactive then
    GUI.display.titletext:SetTextColor(1, 0.82, 0, 1);
  else
    GUI.display.titletext:SetTextColor(1, 0, 0, 1);
  end
end

function GUI:testmsg()
	local newlines = 50

	local lines = {}

	self.scroll:PauseLayout()

	for i = 1, newlines do

		local msgLine = AceGUI:Create("TritonBasicLabel")
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetPoint("LEFT", 0, 0)
		msgLine:SetRelativeWidth(1)
		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetText(tostring(i))
		msgLine:SetFont(fontName, addon.db.global.fontsize)
		--msgLine:SetFont(fontName, addon.db.global.fontsize, "THICKOUTLINE")
		--msgLine:SetFont("Interface\\Addons\\Triton\\Media\\Emblem.ttf", addon.db.global.fontsize)
		msgLine:SetCallback("OnEnter", ShowLabelTooltip)
		msgLine:SetCallback("OnClick", ClickLabel)

		lines[i] = msgLine
	end

	for i = 1, newlines do
		self.scroll:AddChild(lines[i])
		--self.scroll:DoLayout()
	end

	for i = 30,40 do
		--lines[i]:SetText(tostring(i) .. ' released')
		lines[i]:SetText("")
		lines[i]:Hide()
		--AceGUI:Release(lines[i])
		--self.scroll:DoLayout()
	end

	for i = 5,10 do
		--lines[i]:SetText(tostring(i) .. ' released')
		lines[i]:SetText(nil)
		lines[i]:Hide()
		--AceGUI:Release(lines[i])
		--self.scroll:DoLayout()
	end

	
	--self.scroll:DoLayout()

	----[[
	for i = 51, 55 do

		local msgLine = AceGUI:Create("TritonBasicLabel")
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetPoint("LEFT", 0, 0)
		msgLine:SetRelativeWidth(1)
		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetText(tostring(i))
		msgLine:SetFont(fontName, addon.db.global.fontsize)
		--msgLine:SetFont(fontName, addon.db.global.fontsize, "THICKOUTLINE")
		--msgLine:SetFont("Interface\\Addons\\Triton\\Media\\Emblem.ttf", addon.db.global.fontsize)
		msgLine:SetCallback("OnEnter", ShowLabelTooltip)
		msgLine:SetCallback("OnClick", ClickLabel)

		lines[i] = msgLine
	end

	for i = 51, 55 do
		self.scroll:AddChild(lines[i])
	end
	--]]

	self.scroll:ResumeLayout()
	self.scroll:DoLayout()

end

function GUI:CreateNewLineWidget(topics)
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

		return msgLine
end

function GUI:AdjustLines(topics)
	local tsize = table_count(topics)
	local lsize = table_count(self.lines)
	--addon:Printf("topics size: " .. tostring(tsize) .. ", widgets size: " .. tostring(lsize))

	for i = 1, tsize do
		if( self.lines[i] == nil ) then
			--addon:Printf("create new widget: " .. tostring(i))
			-- apppend widgets in lines table
			local line_widgets = {}
			line_widgets["msgLine"] = self:CreateNewLineWidget()
			line_widgets["hided"] = false
			self.lines[i] = line_widgets
			self.scroll:AddChild(self.lines[i]["msgLine"])
		else
			if( self.lines[i]["hided"] == true ) then
				self.lines[i]["msgLine"]:Show()
				self.lines[i]["hided"] = false
			end
		end
	end

	-- release extra lines
	if(lsize>tsize) then
		for i = lsize, tsize+1, -1 do
			if( not self.lines[i]["released"] ) then
				-- important:
				-- ace3gui have bug, remove label widget cause UI issue
				-- proven fix:
				-- 1. using modified version of TritonBasicLabel and TritonLabel
				-- 2. set target widget text to nil
				-- 3. set target widge height and width to 0,0 via modified version of UpdateImageAnchor
				self.lines[i]["msgLine"]:SetText("")
				self.lines[i]["msgLine"]:Hide()

				-- set released line object to nil
				self.lines[i]["hided"] = true
			end
		end
	end

	self.scroll:DoLayout()
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
			" |cff999900" .. tostring(secs) .. "s";
		self.lines[widgetIdx]["msgLine"]:SetText(dispMsg)
		--self.lines[widgetIdx]["msgLine"]:Show()

		-- if new update on old message
		if( not topics[key]['animated'] ) then
			-- create animation
			--addon:Printf("do alpha animation")
			f = self.lines[widgetIdx]["msgLine"].frame
			flasher = f:CreateAnimationGroup() 

			fade1 = flasher:CreateAnimation("Alpha")
			fade1:SetDuration(0.21)
			fade1:SetFromAlpha(1)
			fade1:SetToAlpha(0.5)
			fade1:SetOrder(1)

			fade2 = flasher:CreateAnimation("Alpha")
			fade2:SetDuration(0.39)
			fade2:SetFromAlpha(0.5)
			fade2:SetToAlpha(1)
			fade2:SetOrder(2)

			flasher:Play()

			topics[key]["animated"] = true
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
			" |cffcccc00[" .. tostring(secs) .. "s]";
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

function GUI:WhisperPlayer(from_widget)
	for k, v in pairs(self.lines) do
		if v["msgLine"] == from_widget then
			ChatFrame_SendTell(v["topic"].from)
			break
		end
	end
end

function GUI:PlayerMenu(from_widget)
	local topic = nil
	for k, v in pairs(self.lines) do
		if v["msgLine"] == from_widget then
			topic = v["topic"]
			break
		end
	end

	if topic == nil then
		return
	end

	local menu = {
	    { text = L["Choose operation: |cff00cccc"] .. topic["nameonly"] , isTitle = true},
	    { text = L["Block user"], func = function() C_FriendList.AddIgnore(topic["from"]); print(topic["nameonly"] .. L[" had been ignored."]); end },
	    { text = L["Whisper"], func = function() ChatFrame_SendTell(topic["from"]); end },
	    { text = L["|cffff9900Cancel"], func = function() return; end },
	}
	local menuFrame = CreateFrame("Frame", "TopicMenuFrame", from_widget.frame, "UIDropDownMenuTemplate")

	-- Make the menu appear at the cursor: 
	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
	-- Or make the menu appear at the frame:
	-- menuFrame:SetPoint("LEFT", from_widget.frame, "Center")
	-- EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");

	addon:Printf('RightButton:')

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

			--[[
			CreateFrame( "GameTooltip", "SenderTooltip", nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil
			SenderTooltip:SetOwner( GUI.display.frame, "ANCHOR_NONE" );
			-- Allow tooltip SetX() methods to dynamically add new lines based on these
			--SenderTooltip:AddFontStrings(
			--    SenderTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
			--    SenderTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" ) );
			SenderTooltip:AddLine("New tooltip line", 1, 1, 1)
			SenderTooltip:Show()
			]]

			--[[
			GameTooltip:SetOwner(from_widget.frame, "ANCHOR_LEFT", 50, 0)
			GameTooltip:AddLine("New tooltip line", 1, 1, 1)
			GameTooltip:Show()
			]]

			GUI:PlayerMenu(from_widget)
		end
	end
end

------------------------------------------------------------------------------
-- unused functions
------------------------------------------------------------------------------

function GUI:AdjustLinesOri(topics)
		local tsize = table_count(topics)
	local lsize = table_count(self.lines)
	local newlines = tsize - lsize
	addon:Printf("newlines: " .. tostring(tsize) .. "-" .. tostring(lsize) .. "=" .. tostring(newlines))

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
			-- important:
			-- ace3gui have bug, remove label widget cause UI issue
			-- proven fix:
			-- 1. using modified version of TritonBasicLabel and TritonLabel
			-- 2. set target widget text to nil
			-- 3. set target widge height and width to 0,0 via modified version of UpdateImageAnchor
			-- 4. Release the line
			self.lines[i]["msgLine"]:SetText(nil)
			self.lines[i]["msgLine"]:Hide()
			--AceGUI:Release(self.lines[i]["msgLine"])

			-- set released line object to nil
			--self.lines[i] = nil
		end
	end

	self.scroll:DoLayout()

end

function GUI:RefreshTopicsSortedOri(topics, sort_field)
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
			" |cffcccc00" .. tostring(secs) .. "s";
		self.lines[widgetIdx]["msgLine"]:SetText(dispMsg)
		self.lines[widgetIdx]["msgLine"]:Show()

		-- if new update on old message
		if( not topics[key]['animated'] ) then
			-- create animation
			--addon:Printf("do alpha animation")
			f = self.lines[widgetIdx]["msgLine"].frame
			flasher = f:CreateAnimationGroup() 

			fade1 = flasher:CreateAnimation("Alpha")
			fade1:SetDuration(0.1)
			fade1:SetFromAlpha(1)
			fade1:SetToAlpha(0.5)
			fade1:SetOrder(1)

			fade2 = flasher:CreateAnimation("Alpha")
			fade2:SetDuration(0.26)
			fade2:SetFromAlpha(0.5)
			fade2:SetToAlpha(1)
			fade2:SetOrder(2)

			flasher:Play()

			topics[key]["animated"] = true
		end

		-- save current top in widget line's container
		self.lines[widgetIdx]["topic"] = topics[key]

		-- increase index to access next widget line
		widgetIdx = widgetIdx + 1
	end

	-- refresh scroll frame
	self.scroll:DoLayout()
end

function GUI:AdjustLinesByRecreate(topics)
	local tsize = table_count(topics)
	local lsize = table_count(self.lines)
	addon:Printf("topics size: " .. tostring(tsize) .. ", widgets size: " .. tostring(lsize))

	self.scroll:ReleaseChildren()

	for i = 1, tsize do
		local msgLine = nil
		addon:Printf("create new widget: " .. tostring(i))
		msgLine = self:CreateNewLineWidget()
		-- apppend widgets in lines table
		local line_widgets = {}
		line_widgets["msgLine"] = msgLine
		line_widgets["released"] = false
		self.lines[i] = line_widgets

		self.scroll:AddChild(self.lines[i]["msgLine"])
	end
	
	self.scroll:DoLayout()
end

--[[
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
]]

--------------------------------
-- EOF

