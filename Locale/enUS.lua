local addonName, _ = ...
local silent = true
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true, silent)
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the triton main window."] = true

L["TRITON"] = "Triton";

L["minbid"] = true
L["buyout"] = true

-- EOF
