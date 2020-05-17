local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local TritonMessage = addon:NewModule("TritonMessage", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

local private = {}

local handlers = {}

local searchcache = {}
searchcache.blocker = {}

local serverName  = Proper(GetRealmName())

-- get sorted keys
function getKeysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    return keys
end

-- for sort table
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- Convert a lua table into a lua syntactically correct string
function table_to_string(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        -- Check the value type
        if type(v) == "table" then
            result = result..table_to_string(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "{" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

function table_count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count+1
    end

    return count
end

function getServer (name, def)

    local index = string.find(name, "-", 1, true)
    
    if index ~= nil then
        return string.sub(name, index + 1, string.len(name))
    end
    
    if def then return def else return serverName end
end

function removeServer (name, strict)
    
    if name == nil then
        return nil
    end

    result = name
    
    local index = string.find(name, "-", 1, true)
    
    if strict == nil then
        strict = false
    end
    
    if index ~= nil then
        local server = Proper(string.sub(name, index + 1, string.len(name)));
        
        if strict == true or server == Proper(serverName) then
            result = string.sub(name, 1, index - 1)
        end
    end
    
    return result   
end

function addServer (name)

    if not name then return nil end

    if string.find(name, "-", 1, true) == nil then
        return name .. "-" .. serverName
    end
    
    return name
end

local function addToCache(search)
    local t = {}
    t["block"] = {}
    t["match"] = {}
    t.blocker = false
    for k in string.gmatch(search, "-([^&%-]+)") do
        table.insert(t.block, k)
    end
    for k in string.gmatch(search, "&([^&%-]+)") do
        table.insert(t.match, k)
    end

    if string.sub(search, 1, 1) ~= "-" then     
        local head = string.match(search, "^(.-)[&%-]")
        if head then 
            table.insert(t.match, head) 
        end
    end
    if next(t.match)==nil then t.isBlocker = true end
    searchcache[search] = t
end

local function _hfind(msglow, search)
    local fstart, fend
    if string.find(search,"[&%-]") then
        if not searchcache[search] then addToCache(search) end
        local t = searchcache[search]
        if t.isBlocker then return nil, nil end
        for _, k in pairs(t.block) do
            fstart = string.find(msglow, k)
            if fstart then return nil, nil end
        end
        for _, k in pairs(t.match) do
            fstart, fend = string.find(msglow, k)
            if not fstart then return nil, nil end
        end
        return fstart, fend
    end
    return string.find(msglow, search)    
end

local function ShouldBlock(msg)
    for _, data in pairs(addon.db.global.keywords) do
        if data.active then
            for word, search in pairs(data.words) do
                if string.sub(search, 1, 1) == "-" and not string.find(search,"&") then
                    for k in string.gmatch(search, "-([^%-]+)") do
                        if string.find(msg, k) then 
                            return true 
                        end
                    end                    
                end
            end
        end
    end
    return false;
end

--[[

CChatNotifier_data = {"bwl&LR","mc","zg","黑龙","-买号", "-刷", "-关服"}

a = ShouldBlock("刷到关服务器")
print(a)

c, d = _hfind("bwl刷到关服务LR器", "bwl&LR")
print(c)
print(d)

c, d = _hfind("okok mc开组 刷关服", "mc")
print(c)
print(d)
]]

--[[
function TritonMessage:DoFilter(self, event, message, from, t1, t2, t3, t4, t5, chnum, chname, unknown5, index, playerGUID, ...)

    if not playerGUID then return end
    local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(playerGUID)
    -- if characterName or IsFriend(guid) or flag == "GM" or flag == "DEV" then return end

    if (from ~= nil) and (from ~= "") then
        addon:Printf(from .. " : " .. englishClass  .. " : " .. message)
    end
end

local function TritonChatFilter(self, event, message, from, t1, t2, t3, t4, t5, chnum, chname, unknown5, index, playerGUID, ...)
    TritonMessage:DoFilter(self, event, message, from, t1, t2, t3, t4, t5, chnum, chname, unknown5, index, playerGUID, ...)
end

]]


function TritonMessage:HookMessages()
    local chatEvents = (
        {
        "CHAT_MSG_ACHIEVEMENT",
        "CHAT_MSG_BATTLEGROUND",
        "CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_CHANNEL_JOIN",
        "CHAT_MSG_CHANNEL_LEAVE",
        "CHAT_MSG_CHANNEL_NOTICE_USER",
        "CHAT_MSG_EMOTE",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_GUILD_ACHIEVEMENT",   
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_MONSTER_EMOTE",
        "CHAT_MSG_MONSTER_PARTY",
        "CHAT_MSG_MONSTER_SAY",
        "CHAT_MSG_MONSTER_WHISPER",
        "CHAT_MSG_MONSTER_YELL",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_SAY",
        "CHAT_MSG_SYSTEM",
        "CHAT_MSG_TEXT_EMOTE",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_YELL"
        }
    )

    addon:Printf("TritonMessage:HookMessages()")
    addon.frame:RegisterEvent("CHAT_MSG_CHANNEL");

    -- setup topic cleaner run interval
    self.lastTopicClean = GetTime();

    -- setup refresh interval flag
    self.lastRefresh = GetTime() - addon.db.global.refresh_interval;

    -- wipe topics 
    if(self.topics) then
        wipe(self.topics)
    else
        self.topics = {}
    end

    --for key, value in pairs (chatEvents) do
    --    ChatFrame_AddMessageEventFilter(value, TritonChatFilter)
    --end
end

function TritonMessage:UnhookMessages()
    local chatEvents = (
        {
        "CHAT_MSG_ACHIEVEMENT",
        "CHAT_MSG_BATTLEGROUND",
        "CHAT_MSG_BATTLEGROUND_LEADER",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_CHANNEL_JOIN",
        "CHAT_MSG_CHANNEL_LEAVE",
        "CHAT_MSG_CHANNEL_NOTICE_USER",
        "CHAT_MSG_EMOTE",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_GUILD_ACHIEVEMENT",   
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_MONSTER_EMOTE",
        "CHAT_MSG_MONSTER_PARTY",
        "CHAT_MSG_MONSTER_SAY",
        "CHAT_MSG_MONSTER_WHISPER",
        "CHAT_MSG_MONSTER_YELL",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_SAY",
        "CHAT_MSG_SYSTEM",
        "CHAT_MSG_TEXT_EMOTE",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_YELL"
        }
    )

    addon:Printf("TritonMessage:UnhookMessages()")
    addon.frame:UnregisterEvent("CHAT_MSG_CHANNEL");

    --for key, value in pairs (chatEvents) do
    --    ChatFrame_RemoveMessageEventFilter(value, TritonChatFilter)
    --end
end

--- Remove server names from names given as "Character-Servername"
-- @param name The name to remove the dash server part from
local function RemoveServerDash(name)
    local dash = name:find("-");
    if dash then 
        return name:sub(1, dash-1); 
    end
    return name;
end

local function has_value (tab, v)
    for index, value in ipairs(tab) do
        if value == v then
            return true
        end
    end
    return false
end

--- Search message for searched terms
-- If one is found then trigger notification.
-- @param msg The message to search in
-- @param from The player it is from
-- @param source The source of the message (SAY, CHANNEL)
-- @param channelName If source is CHANNEL this is the channel name
local function SearchMessage(msg, from, source, guid)

    -- Skipped from if found in Global Ignore List
    if GlobalIgnoreDB and has_value(GlobalIgnoreDB.ignoreList, from)  then 
        -- If from is in global ignore list, skip
        addon:Printf("skip " .. from .. ' in GlobalIgnoreDB')
        return;
    end

    local nameNoDash = RemoveServerDash(from);

    -- get player info
    local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
    -- skip null player class
    if engClass == nil or engClass == '' then
        return
    end

    local salted_msg = "<guid:" .. guid .. "><class:" .. engClass .. "><race:" .. engRace .. "><name:" .. name .. "><server:" .. getServer(from) .. ">" .. msg
    salted_msg = salted_msg:lower()

    -- addon:Printf("addon.db.global.filters = " .. addon.db.global.filters.include.line1)
    -- addon:Printf("TritonMessage:salted_msg " .. salted_msg)

    -- check if message pass or not
    local pass, keyword = TritonMessage:FilterTopics(msg, salted_msg, from, source, guid)

    if pass then
        -- build topics and do cleaner
        TritonMessage:BuildTopics(msg, salted_msg, from, source, guid, engClass, keyword, nameNoDash)
        -- Update topics
        TritonMessage:UpdateTopicsUI()
        -- mark message had been displayed
        TritonMessage:MarkTopic(msg, salted_msg, from, source, guid, engClass, keyword, nameNoDash)
    end
end

function handlers.CHAT_MSG_CHANNEL(text, playerName, _, channelName, _, _, _, _, _, _, _, guid)
    SearchMessage(text, playerName, channelName, guid);
end

function handlers.CHAT_MSG_SAY(text, playerName,  _, _, _, _, _, _, _, _, _, guid)
    SearchMessage(text, playerName, L["TRITON"]);
end

function handlers.CHAT_MSG_YELL(text, playerName,  _, _, _, _, _, _, _, _, _, guid)
    SearchMessage(text, playerName, L["TRITON"]);
end

addon.frame:SetScript( "OnEvent", function(self, event, ...) 
    handlers[event](...);
end)


function TritonMessage:OnInitialize()
    addon:Printf("TritonMessage:OnInitialize()")
end

------------- messages handling ---------------

function TritonMessage:FilterTopics(msg, salted_msg, from, source, guid)
    local block = ShouldBlock(salted_msg)
    if block then
        return false
    end

    -- addon:Printf("TritonMessage:BuildTopics block:[" .. tostring(block) .. "], salted_msg=" .. salted_msg)

    local fstart, fend;
    for _, data in pairs(addon.db.global.keywords) do
        if data.active then
            for word, search in pairs(data.words) do
                fstart, fend = _hfind(salted_msg, search);
                if fstart ~= nil then
    --[[--{ anti spam
                    t = GetTime()
                    if lasttenseconds and lasttenseconds[nameNoDash] and t-lasttenseconds[nameNoDash]<CChatNotifier_settings.antiSpamWindow then 
                        return;
                    end
                    lasttenseconds[nameNoDash] = t
    -- hk } ]]
                    return true, search
                end
            end
        end
    end

    return false
end

function TritonMessage:BuildTopicsOld(msg, salted_msg, from, source, guid, engClass, keyword)
    -- addon:Printf("TritonMessage:BuildTopics keyword:[" .. tostring(keyword) .. "], salted_msg=" .. salted_msg)

    local topic_idx = guid .. ":" .. keyword

    -- find if the topic exists in topics table
    local foundtopic = self.topics[topic_idx]

    -- existing topic
    if foundtopic ~= nil then
        local topic = foundtopic

        addon.GUI:TouchTopic(topic)

        -- update fields
        topic["first"] = false
        topic["time"] = GetTime()
        topic["msg"] = msg
        topic["from"] = from
        topic["class"] = engClass
        self.topics[topic_idx] = topic

    -- new topic
    else

        -- set widget and container info in topic obj        
        local topic = {}
        topic["idx"] = topic_idx
        topic["first"] = true
        topic["time"] = GetTime()
        topic["msg"] = msg
        topic["from"] = from
        topic["class"] = engClass

        -- insert new widget into scroll container
        msgWidget, lineContainer = addon.GUI:AddTopics(self.topics, topic)

        topic["widget"] = lineContainer
        topic["label"] = msgWidget

        -- print(table_to_string(topic))
        
        -- add the new topic in topics table
        self.topics[topic_idx] = topic    
    end

    -- if cleaner run time reached
    if ((GetTime() - self.lastTopicClean) > addon.db.global.cleaner_run_interval) then
        -- remove long exists topic
        addon:Printf("Running cleaner...");
        for key, t in pairs(self.topics) do
            if ((GetTime() - t["time"]) > addon.db.global.max_topic_live_secs) then
                -- remove existing widget from line container
                addon.GUI:RemoveTopics(t)

                -- simply set the topic to nil to avoid memory leak
                addon:Printf("Removed topic:" .. key);
                self.topics[key] = nil
            end
        end

        self.lastTopicClean = GetTime()
    end

    ----[[
    --print(table_to_string(self.topics))
    --]]
end

function TritonMessage:BuildTopics(msg, salted_msg, from, source, guid, engClass, keyword, nameNoDash)
    -- addon:Printf("TritonMessage:BuildTopics keyword:[" .. tostring(keyword) .. "], salted_msg=" .. salted_msg)

    local topic_idx = guid .. ":" .. keyword

    -- find if the topic exists in topics table
    local foundtopic = self.topics[topic_idx]

    -- existing topic
    if foundtopic ~= nil then
        local topic = foundtopic

        -- update fields
        topic["time"] = GetTime()
        topic["first"] = false
        topic["msg"] = msg
        topic["from"] = from
        topic["nameonly"] = nameNoDash
        topic["keyword"] = string.upper(keyword)
        topic["class"] = engClass
        topic["animate"] = true
        self.topics[topic_idx] = topic

    -- new topic
    else
        -- set widget and container info in topic obj        
        local topic = {}
        topic["idx"] = topic_idx
        topic["time"] = GetTime()
        topic["first"] = true
        topic["createtime"] = topic["time"]
        topic["msg"] = msg
        topic["from"] = from
        topic["nameonly"] = nameNoDash
        topic["keyword"] = string.upper(keyword)
        topic["class"] = engClass
        topic["animate"] = true

        -- print(table_to_string(topic))
        
        -- add the new topic in topics table
        self.topics[topic_idx] = topic    
    end

    -- if cleaner run time reached
    if ((GetTime() - self.lastTopicClean) > addon.db.global.cleaner_run_interval) then
        -- remove long exists topic
        addon:Printf("Running cleaner...");
        for key, t in pairs(self.topics) do
            if ((GetTime() - t["time"]) > addon.db.global.max_topic_live_secs) then
                -- simply set the topic to nil to avoid memory leak
                addon:Printf("Removed topic:" .. key);
                self.topics[key] = nil
            end
        end

        self.lastTopicClean = GetTime()
    end

    ----[[
    --print(table_to_string(self.topics))
    --]]
end

-- mark topic had been animated
function TritonMessage:MarkTopic(msg, salted_msg, from, source, guid, engClass, keyword, nameNoDash)
    local topic_idx = guid .. ":" .. keyword

    -- find if the topic exists in topics table
    local foundtopic = self.topics[topic_idx]

    -- existing topic
    if foundtopic ~= nil then
        local topic = foundtopic

        -- update fields
        topic["animate"] = false

        self.topics[topic_idx] = topic
    end
end

function TritonMessage:UpdateTopicsUI()
    --print(table_to_string(self.topics))
    -- Only refresh when refresh every set interval
    if GetTime() - self.lastRefresh > addon.db.global.refresh_interval then
        addon.GUI:RefreshTopics(self.topics)
        self.lastRefresh = GetTime()
    end

end