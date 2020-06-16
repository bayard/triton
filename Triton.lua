local addonName, addon = ...
addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local private = {}
------------------------------------------------------------------------------

addon.frame = CreateFrame("Frame")

addon.METADATA = {
	NAME = GetAddOnMetadata(..., "Title"),
	VERSION = GetAddOnMetadata(..., "Version")
}

-- called by AceAddon when Addon is fully loaded
function addon:OnInitialize()
	--addon:Printf(L["Triton running..."])
	--addon:Printf(L["Use /triton to open message topic tracking window"])

	-- makes Module ABC accessable as addon.ABC
	for module in pairs(addon.modules) do
		addon[module] = addon.modules[module]
	end

	-- loads data and options
	addon.db = AceDB:New(addonName .. "DB", addon.Options.defaults, true)
	AceConfigRegistry:RegisterOptionsTable(addonName, addon.Options.GetOptions)
	local optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addon.METADATA.NAME)
	addon.Options.frame = optionsFrame

	-- addon state flags
	addon.isDebug = false
	addon.isDemo = false
	addon.isInfight = false
	addon.isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

	-- initialize chat command
	local chatfunc = function()
		--addon:UIToggle()
    	-- addon:KeywordUI_OpenList()
    	addon:SwitchOn()
	end
	addon:RegisterChatCommand("triton", chatfunc)

	-- register minimap icon
	-- addon.Minimap:Load()

	-- initialize writing data on player logout
	addon:RegisterEvent("PLAYER_LOGOUT", function()
		addon:OnLogout()
		end)

	-- register triton layout
	AceGUI:RegisterLayout("Triton", TritonLayoutFunc)
end

-- called when Player logs out
function addon:OnLogout()
	-- Save session data
	addon.Options:SaveSession()
	--addon.GUI:OnLogout()
end

-- called by AceAddon on PLAYER_LOGIN
function addon:OnEnable()
	print("|cFF33FF99" .. addonName .. " (" .. addon.METADATA.VERSION .. ")|r: " .. L["enter /triton for main interface"])

	-- load options
	addon.Options:Load()

  	-- load keyword data
  	self:MainUI_UpdateList();

	-- Load last saved status
	if( addon.db.global.ui_switch_on ) then
		addon:SwitchOn()
	end
end


function addon:OptionClicked()
	--addon:Printf(L["Option clicked"])
end

function addon:SwitchOn()
	--addon:Printf(L["SwitchOn"])

	if(addon.GUI.display) then
		if(addon.GUI.display:IsShown()) then
			-- do nothing
				return
		end
	end 

	addon.GUI:Load_Ace_Custom()
	addon.GUI.display:Show()

	TritonKeywordUI:UpdateKeywordUIState();
end

function addon:SwitchOff()
	--addon:Printf(L["SwitchOff"])
	if(addon.GUI.display) then
		if(addon.GUI.display:IsShown()) then
			addon.GUI.display:Hide()
			--AceGUI:Release(addon.GUI.display)
			addon.GUI.display = nil

			TritonKeywordUI:UpdateKeywordUIState();
		end
	end
end

function addon:UIToggle()
	--addon:Printf(L["/triton launched"])

	-- open or release addon main frame
	if(addon.GUI.display) then
		if(addon.GUI.display:IsShown()) then
			addon:SwitchOff()
		else
			addon:SwitchOn()
		end
	else 
		addon:SwitchOn()
	end

	-- update ui components based on global active flag
	TritonKeywordUI:UpdateKeywordUIState()
end

--- Set addon state to current SV value
function addon:UpdateAddonState()
    if addon.db.global.globalswitch then
        addon.TritonMessage:HookMessages()
    else
        addon.TritonMessage:UnhookMessages()
    end
    -- addon:MinimapButtonUpdate();
end

-- EOF
