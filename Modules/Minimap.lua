local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local Minimap = addon:NewModule("Minimap", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

local private = {}


function Minimap:OnInitialize()
    local LDB = LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

    if LDB then
        local MinimapBtn = LDB:NewDataObject("TritonBtn", {
            type = "launcher",
    		text = addonName,
            icon = "Interface\\AddOns\\Triton\\Media\\logo",

            OnClick = function(_, button)
                if button == "LeftButton" then 
                    addon:UIToggle()
                end
            end,

            OnTooltipShow = function(tt)
                tt:AddLine(addonName)
                tt:AddLine(L["|cffffff00Click|r to toggle the triton main window."])
            end,

            OnLeave = HideTooltip
        })
        if LDBIcon then
            addon.db.global.minimap = addon.db.global.minimap or {}
            LDBIcon:Register(addonName, MinimapBtn, addon.db.global.minimap)
        end
    end
end
