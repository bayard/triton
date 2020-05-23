local addonName, addon = ...
local Options = addon:NewModule("Options", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LSM = LibStub("LibSharedMedia-3.0")
local WidgetLists = AceGUIWidgetLSMlists
--------------------------------------------------------------------------------------------------------

--  Options
Options.defaults = {
	global = {
		globalswitch = true,
		cleaner_run_interval = 60,
		safe_cleaner_run_interval = 300,
		max_topic_live_secs = 120,
		refresh_interval = 2,
		fontsize = 12.8,
		minimap = {},
		ui = {
			height = 160,
			top = 260,
			left = 950,
			width = 320,
		},
	},
}

function Options:Load()
	--addon:Printf("On option load():")

	--[[    
    -- Initialize keywords with db value or empty table if no value in db
    addon.db.global.keywords =  addon.db.global.keywords or {}

    -- Topic cleaner run interval
    addon.db.global.cleaner_run_interval = addon.db.global.cleaner_run_interval or cleaner_run_interval
    --addon.db.global.max_topic_live_secs = addon.db.global.max_topic_live_secs or 30
    addon.db.global.max_topic_live_secs = 120

    -- Refresh interval
    --addon.db.global.refresh_interval = addon.db.global.refresh_interval or 2
    addon.db.global.refresh_interval = 2

    -- Set font size
    addon.db.global.fontsize = addon.db.global.fontsize or 12.5
    
    -- no need
    --addon.db.global.globalswitch =  addon.db.global.globalswitch or true
    ]]

    local keywords_enUS = {
		["ONY"] = {
			["words"] = {
				"onyxia,ony,ol", -- [1]
			},
			["active"] = true,
		},
		["ZG,ZUG,GURUB"] = {
			["words"] = {
				"zg", -- [1]
				"zug", -- [2]
				"gurub", -- [3]
			},
			["active"] = true,
		},
		["BWL,BLACKWING"] = {
			["words"] = {
				"bwl", -- [1]
				"blackwing", -- [2]
			},
			["active"] = true,
		},
		["-class:warlock"] = {
			["words"] = {
				"-class:warlock", -- [1]
			},
			["active"] = false,
		},
		["MC,MOLTEN"] = {
			["words"] = {
				"mc", -- [1]
				"molten", -- [2]
			},
			["active"] = true,
		},
    };

    local keywords_zhCN = {
		["黑龙"] = {
			["words"] = {
				"黑龙", -- [1]
			},
			["active"] = true,
		},
		["ZG,ZUG,祖格"] = {
			["words"] = {
				"zg", -- [1]
				"zug", -- [2]
				"祖格", -- [3]
			},
			["active"] = true,
		},
		["BWL,黑翼"] = {
			["words"] = {
				"bwl", -- [1]
				"黑翼", -- [2]
			},
			["active"] = true,
		},
		["-class:warlock,-航空公司"] = {
			["words"] = {
				"-class:warlock", -- [1]
				"-航空公司", -- [2]
			},
			["active"] = false,
		},
		["MC,熔火之心"] = {
			["words"] = {
				"mc", -- [1]
				"熔火之心", -- [2]
			},
			["active"] = true,
		},
    };

    -- loading default keywords based on locale
	if( addon.db.global.keywords == nil ) then
		if( GetLocale() == "zhCN" ) then
			addon.db.global.keywords = keywords_zhCN
		else 
			addon.db.global.keywords = keywords_enUS
		end
	end

	--addon:Printf("globalswitch=" .. tostring(addon.db.global.globalswitch))
end

function Options:SaveSession()
	if addon.GUI.display ~= nil and addon.GUI.display:IsShown() then
		addon.db.global.ui_switch_on = true
	else
		addon.db.global.ui_switch_on = false
	end
end

--- Add new entry to the list
-- @param search The string to search for
function addon:AddToList(search)
    local ntable = {
        active = true,
        words = {}
    };
    
    for found in string.gmatch(search, "([^,]+)") do
        table.insert(ntable.words, strtrim(found):lower());
    end

    addon.db.global.keywords[search] = ntable;
    addon:MainUI_UpdateList();
end

--- Remove entry from list
-- @param search The string to remove
function addon:RemoveFromList(search)
    addon.db.global.keywords[search] = nil;
    addon:MainUI_UpdateList();
end

--- Toggle entry active state
-- @param search The search string to toggle
-- @return the new state
function addon:ToggleEntry(search)
    if addon.db.global.keywords[search] ~= nil then
        addon.db.global.keywords[search].active = not addon.db.global.keywords[search].active;
        return addon.db.global.keywords[search].active;
    end
    return false;
end

--- Clear the whole list
function addon:ClearList()
    wipe(addon.db.global.keywords);
    addon:MainUI_UpdateList();
end

--- Toggle search on/off
function addon:ToggleAddon()
    addon.db.global.globalswitch = not addon.db.global.globalswitch
end

function Options.GetOptions(uiType, uiName, appName)
	if appName == addonName then

		local options = {
			type = "group",
			name = addon.METADATA.NAME .. " (" .. addon.METADATA.VERSION .. ")",
			get = function(info)
					return addon.db.global[info[#info]] or ""
				end,
			set = function(info, value)
					addon.db.global[info[#info]] = value
					--[[
					addon.Data:UpdateSession()
					if addon.GUI.display then
						addon.GUI.container:Reload()
					end
					]]
				end,
			args = {

				addoninfo = {
					type = "description",
					name = L["ADDON_INFO"],
					descStyle = L["ADDON_INFO"],
					order = 0.1,
				},

				header01 = {
					type = "header",
					name = "",
					order = 1.01,
				},

				max_topic_live_secs = {
					type = "range",
					width = "double",
					min = 10,
					max = 600,
					step = 1,
					softMin = 10,
					softMax = 600,
					name = L["Message alive time"],
					desc = L["How long will message be removed from event (default to 120 seconds)?"],
					width = "normal",
					order = 1.1,
				},

				header02 = {
					type = "header",
					name = "",
					order = 2.01,
				},

				fontsize = {
					type = "range",
					width = "double",
					min = 3,
					max = 60,
					step = 0.1,
					softMin = 3,
					softMax = 60,
					name = L["Font size"],
					desc = L["Font size of event window (default to 12.8)."],
					width = "normal",
					order = 2.1,
				},

				header03 = {
					type = "header",
					name = "",
					order = 3.01,
				},

				refresh_interval = {
					type = "range",
					width = "double",
					min = 1,
					max = 60,
					step = 1,
					softMin = 1,
					softMax = 60,
					name = L["Refresh interval"],
					desc = L["How frequent to refresh event window (default to 2 seconds)?"],
					width = "normal",
					order = 3.1,
				},

				header06 = {
					type = "header",
					name = "",
					order = 6.01,
				},

				authorinfo = {
					type = "description",
					name = L["AUTHOR_INFO"],
					descStyle = L["AUTHOR_INFO"],
					order = 6.1,
				},
			},
		}
		return options
	end
end

-- EOF
