--[[-----------------------------------------------------------------------------
Label Widget
Displays text and optionally an icon.
-------------------------------------------------------------------------------]]
local Type, Version = "TritonEntry", 26
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local max, select, pairs = math.max, select, pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: GameFontHighlightSmall

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function UpdateAnchor(self, shouldHide)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local label = self.label
	local height

	-- fix by Triton
	local extra_height_only_with_content = 2

	label:ClearAllPoints()

	if shouldHide then
		frame:SetHeight(0)
		frame.height = 0
		frame:SetWidth(0)
		frame,width = 0
	else
		-- no image shown
		label:SetPoint("TOPLEFT")
		label:SetWidth(width)
		--height = label:GetStringHeight()
		height = 20

		-- avoid zero-height labels, since they can used as spacers
		if not height or height == 0 then
			height = 0
		end

		self.resizing = true
		-- print('resizing frame to ' .. tostring(height))
		if height == 0 then
			frame:SetHeight(0)
			frame.height = 0
			frame:SetWidth(0)
			frame,width = 0
		else
			height = height + extra_height_only_with_content
			frame:SetHeight(height)
			frame.height = height
		end
		self.resizing = nil
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		-- set the flag to stop constant size updates
		self.resizing = true
		-- height is set dynamically by the text and image size
		self:SetWidth(200)
		self:SetText()
		--self:SetColor()
		--self:SetFontObject()
		self:SetJustifyH("LEFT")
		self:SetJustifyV("TOP")

		-- reset the flag
		self.resizing = nil
		-- run the update explicitly
		UpdateAnchor(self, false)
	end,

	-- ["OnRelease"] = nil,

	["OnWidthSet"] = function(self, width)
		UpdateAnchor(self, false)
	end,

	["SetText"] = function(self, text)
		if text == nil then
			return
		end
		--print("AddMessage:" .. tostring(text))
		--self.label:SetText(text)
		self.label:AddMessage(text, 0.0, 0.0, 1.0);
		UpdateAnchor(self, false)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and g and b) then
			r, g, b = 1, 1, 1
		end
		self.label:SetVertexColor(r, g, b)
	end,

	["SetFont"] = function(self, font, height, flags)
		self.label:SetFont(font, height, flags)
	end,

	["SetFontObject"] = function(self, font)
		self:SetFont((font or GameFontHighlightSmall):GetFont())
	end,

	["SetJustifyH"] = function(self, justifyH)
		self.label:SetJustifyH(justifyH)
	end,

	["SetJustifyV"] = function(self, justifyV)
		self.label:SetJustifyV(justifyV)
	end,

	["Hide"] = function(self)
		--self.resizing = true
		UpdateAnchor(self, true)
		self.frame:Hide()
	end,

	["Show"] = function(self)
		--self.resizing = true
		UpdateAnchor(self, false)
		self.frame:Show()
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local lineHeight

	_,lineHeight,_ = GameFontNormalSmall:GetFont()

	-- print("lineHeight=" .. lineHeight)
	lineHeight = 9

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(260)
	frame:SetHeight(lineHeight)
	--frame:Hide()

	local Backdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background", 
		--edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = false, 
		tileSize = 1, 
		edgeSize = 5, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}

	local labelcontainer = CreateFrame("Frame", nil, frame)
	labelcontainer:SetWidth(300)
	labelcontainer:SetHeight(lineHeight)
	labelcontainer:SetBackdrop(Backdrop)
	labelcontainer:SetBackdropColor(1, 0, 0, 0.5)

	labelcontainer:SetParent(frame)
	labelcontainer:SetPoint("TOPLEFT", frame)

	--local label = labelcontainer:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	--label:SetParent(labelcontainer)
	--label:SetPoint("LEFT", labelcontainer)

  	----[[
	local label = CreateFrame("ScrollingMessageFrame", nil, frame)
	label:SetPoint("TOPLEFT", frame);
	label:SetBackdrop(Backdrop)
	label:SetBackdropColor(0, 1, 0, 0.3)
  	--label:SetWidth(260); 
  	--label:SetHeight(30);
  	label:SetMaxLines(1)
  	label:SetHyperlinksEnabled(true)
  	label:SetTimeVisible(600)
  	label:SetFontObject(GameFontNormalSmall)
  	--label:AddMessage("testtesttest",1,0,0)
	--]]

	-- create widget
	local widget = {
		label = label,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
