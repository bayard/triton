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
	--GUI:testmsg()
	--GUI:linktest();
	--GUI:linktest_ace_html()

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
	if GUI.display == nil then
		return
	end
	
	GUI.display:OnPowerButtonStatus(isactive)
	if isactive then
		GUI.display.titletext:SetTextColor(1, 0.82, 0, 1);
	else
		GUI.display.titletext:SetTextColor(1, 0, 0, 1);
	end
end

function GUI:linktest_ace_html()
	local msgLine = AceGUI:Create("TritonSimpleHTML")
	msgLine:SetRelativeWidth(1)
	msgLine:SetWidth(200)
	msgLine:SetHeight(addon.db.global.fontsize)
	msgLine:SetPoint("LEFT", 0, 0)
	--msgLine:SetFont(fontName, addon.db.global.fontsize)
	--msgLine:SetText("|cff9d9d9d|Hitem:7073::::::::::::|h[Broken Fang]|h|r")
	msgLine:SetText("<html><body><h1>Heading1</h1><p>A paragraph</p></body></html>")
	
	--msgLine:SetCallback("OnClick", function() GameTooltip:SetHyperlink("item:16846:0:0:0:0:0:0:0"); end)
	--msgLine:SetCallback("OnHyperlinkEnter", ChatFrame_OnHyperlinkShow)

	self.scroll:AddChild(msgLine)
end

function GUI:linktest()
	local msgLine = AceGUI:Create("TritonEntry")
	msgLine:SetRelativeWidth(1)
	msgLine:SetWidth(200)
	msgLine:SetHeight(addon.db.global.fontsize)
	msgLine:SetPoint("LEFT", 0, 0)
	msgLine:SetFont(fontName, addon.db.global.fontsize)
	msgLine:SetText("|cff9d9d9d|Hitem:7073::::::::::::|h[Broken Fang]|h|r")
	--msgLine:SetText("<html><body><h1>Heading1</h1><p>A paragraph</p></body></html>")
	
	--msgLine:SetCallback("OnClick", function() GameTooltip:SetHyperlink("item:16846:0:0:0:0:0:0:0"); end)
	--msgLine:SetCallback("OnHyperlinkEnter", ChatFrame_OnHyperlinkShow)

	self.scroll:AddChild(msgLine)
end

function GUI:testmsg()
	local newlines = 50

	local lines = {}

	for i = 1, newlines do

		local msgLine = AceGUI:Create("TritonEntry")
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetWidth(200)
		msgLine.label:SetWidth(200)
		msgLine.label:SetHeight(addon.db.global.fontsize)
		msgLine:SetPoint("LEFT", 0, 0)
		--msgLine:SetPoint("LEFT", self.scroll)
		--msgLine:SetFont(fontName, addon.db.global.fontsize)
		--msgLine:SetText("item:16846:0:0:0:0:0:0:0" .. " click")

		-- setup events
		-- msgLine:SetCallback("OnEnter", ShowLabelTooltip)
		--msgLine:SetCallback("OnClick", ClickLabel)
		msgLine.label:SetScript("OnHyperlinkEnter", ChatFrame_OnHyperlinkShow)
		msgLine.label:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)
		--msgLine.frame:SetScript("OnHyperlinkEnter", function() end)
		--msgLine.frame:SetScript("OnHyperlinkClick", function() end)


		msgLine:SetText(tostring(i) .. "|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r")

		lines[i] = msgLine
	end

	for i = 1, newlines do
		self.scroll:AddChild(lines[i])
		self.scroll:DoLayout()
	end

	--[[
	for i = 30,40 do
		--lines[i]:SetText(tostring(i) .. ' released')
		lines[i]:SetText("")
		--lines[i]:Hide()
		--AceGUI:Release(lines[i])
		--self.scroll:DoLayout()
	end

	for i = 5,10 do
		--lines[i]:SetText(tostring(i) .. ' released')
		lines[i]:SetText(nil)
		--lines[i]:Hide()
		--AceGUI:Release(lines[i])
		--self.scroll:DoLayout()
	end

	
	--self.scroll:DoLayout()
	]]

	--[[
	for i = 51, 55 do

		local msgLine = GUI:CreateNewLineWidget(topics)
		msgLine:SetText(tostring(i) .. "|cff9d9d9d|Hitem:3299::::::::20:257::::::|h[Fractured Canine]|h|r")

		lines[i] = msgLine
	end

	for i = 51, 55 do
		self.scroll:AddChild(lines[i])
	end
	]]

	self.scroll:DoLayout()

end

function GUI:CreateNewLineWidgetWithTritonEntry(topics)
		--local msgLine = AceGUI:Create("TritonLabel")
		local msgLine = AceGUI:Create("TritonEntry")
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetRelativeWidth(1)

		msgLine:SetWidth(200)
		msgLine.label:SetWidth(200)
		msgLine.label:SetHeight(addon.db.global.fontsize)

		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetPoint("LEFT", 0, 0)
		msgLine:SetFont(fontName, addon.db.global.fontsize)
		--msgLine:SetFont(fontName, addon.db.global.fontsize, "THICKOUTLINE")
		--msgLine:SetFont("Interface\\Addons\\Triton\\Media\\Emblem.ttf", addon.db.global.fontsize)

		-- setup events
		-- msgLine:SetCallback("OnEnter", ShowLabelTooltip)
		msgLine:SetCallback("OnClick", ClickLabel)
		
		msgLine.label:SetScript("OnHyperlinkEnter", ChatFrame_OnHyperlinkShow)
		msgLine.label:SetScript("OnHyperlinkClick", ChatFrame_OnHyperlinkShow)

		return msgLine
end

function GUI:CreateNewLineWidget(topics)
		--local msgLine = AceGUI:Create("TritonLabel")
		local msgLine = AceGUI:Create("TritonEntry")
		--msgLine:SetRelativeWidth(0.93)
		msgLine:SetRelativeWidth(1)
		msgLine:SetHeight(addon.db.global.fontsize)
		msgLine:SetPoint("LEFT", 0, 0)
		msgLine:SetFont(fontName, addon.db.global.fontsize)
		--msgLine:SetFont(fontName, addon.db.global.fontsize, "THICKOUTLINE")
		--msgLine:SetFont("Interface\\Addons\\Triton\\Media\\Emblem.ttf", addon.db.global.fontsize)
		-- msgLine:SetCallback("OnEnter", ShowLabelTooltip)
		msgLine:SetCallback("OnClick", ClickLabel)

		return msgLine
end

function OnHyperlinkEnter()
	addon:Printf("OnHyperlinkEnter");
end

function OnHyperlinkClick()
	addon:Printf("OnHyperlinkClick");
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
			" |cff008800" .. tostring(secs) .. "s";
		--self.lines[widgetIdx]["msgLine"]:SetText(dispMsg)
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
	local infoType, info1, info2 = GetCursorInfo()
	print("infoType=" .. tostring(infoType))
	GameTooltip:SetHyperlink("item:16846:0:0:0:0:0:0:0")
	if (infoType == "item") then
		print(info2)
	elseif (infoType == "spell") then
		local name, rank = GetSpellName(info1, info2)
	  	if (rank ~= "") then
	    	name = name .. "(" .. rank .. ")"
	  	end
	  	print(name)
	end
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

	local function CopyUserName(fullname)
		editBox = ChatEdit_ChooseBoxForSend()
        local hasText = (editBox:GetText() ~= "")
        ChatEdit_ActivateChat(editBox)
        editBox:Insert(fullname)
        if (not hasText) then editBox:HighlightText() end
	end

	local function UserDetails(fullname)
		C_FriendList.SendWho("n-"..fullname)
	end

	local menu = {
	    { text = L["Choose operation: |cff00cccc"] .. topic["nameonly"] , isTitle = true},
	    { text = L["Block user"], func = function() C_FriendList.AddIgnore(topic["from"]); print(topic["nameonly"] .. L[" had been ignored."]); end },
	    { text = L["Add friend"], func = function() C_FriendList.AddFriend(topic["from"]); end },
	    { text = L["Copy user name"], func = function() CopyUserName(topic["from"]); end },
	    { text = L["User details"], func = function() UserDetails(topic["nameonly"]); end },
	    { text = L["Whisper"], func = function() ChatFrame_SendTell(topic["from"]); end },
	    { text = L["|cffff9900Cancel"], func = function() return; end },
	}
	local menuFrame = CreateFrame("Frame", "TopicMenuFrame", from_widget.frame, "UIDropDownMenuTemplate")

	-- Make the menu appear at the cursor: 
	EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU");
	-- Or make the menu appear at the frame:
	-- menuFrame:SetPoint("LEFT", from_widget.frame, "Center")
	-- EasyMenu(menu, menuFrame, menuFrame, 0 , 0, "MENU");

	--addon:Printf('RightButton:')

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

--------------------------------------------
-- hyper link
function MsgHyperLinkEnter()
end

function MsgHyperLinkLeave()
end

------------------------------------------------------------------------------
-- unused
function GUI:AdjustLinesByRecreate(topics)
	local tsize = table_count(topics)
	local lsize = table_count(self.lines)
	--addon:Printf("topics size: " .. tostring(tsize) .. ", widgets size: " .. tostring(lsize))

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

