local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local AceGUI = LibStub("AceGUI-3.0")

local TritonMessage = addon:NewModule("TritonMessage", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")

local private = {}

local handlers = {}

local searchcache = {}
searchcache.blocker = {}

local serverName  = GetRealmName()

if(addonName == nil) then
	bit = bit32
end

-- Rewrite message
local function RewriteMessage(ori)
    if (ori == nil) then
        return nil
    end

    local len = string.len(ori)

    if len<2 then
        return ori
    end

    --[[
    haslink = find_link(ori)
    -- skip message with item link
    if(haslink) then
        return
    end    
    ]]

    local mmsg = nil

    --[[
    if((len>=4) and (len%2==0)) then
        -- fast, the function only find dups of: ABCABCABC
        -- output ABC
        --mmsg = find_repeat_pattern_fast(ori)
    end
    ]]

    -- fast and tuned algorithm, the function find dups of: xxABCABCABCyy
    -- output xxABCyy
    --mmsg = remove_dups(ori)

    -- fastest and working better
    mmsg = remove_dups_fast(ori)

    if(mmsg == nil) then
        return ori
    end

    -- second stage rewrite currently disabled because of in-consistency
    --[[
    if(mmsg == nil) then
        mmsg = remove_char_repeats_fast(ori)
        -- only keep modify string which can be rewrite to more than half of the length
        if(mmsg ~= nil) then
            if(string.len(mmsg) > len/2) then
                mmsg = nil
            end
        end
    end
    ]]

    return mmsg
end

-- merge dups sub funtions
function remove_dups_fast(str, deep) 
    local t = utf8_to_tbl_fast(str)
    --print(table2string(t))
    local prob = estimate_dup_probability(t)
    --print("size=" .. #t .. ", prob=" .. prob)

    local skip = false
    if prob<0.33 then
    	skip = true
	elseif (#t>256 and prob<0.4) then
		skip = true
	elseif (#t>128 and prob<0.45) then
		skip = true
	elseif (#t>64 and prob<0.47) then
		skip = true
	elseif (#t>32 and prob<0.5) then
		skip = true
	end

	-- skip very low probability of duplicates
	if(skip) then
		--print("Skip low probability")
		return nil
	end

    local dflag = false
    if deep ~= nil then 
    	dflag = deep
    else
    	--print("deep not set, estimating...")
		if (#t>256 and prob>0.7) then
			dflag = true
		elseif (#t>128 and prob>0.6) then
			dflag = true
		elseif (#t>64 and prob>0.55) then
			dflag = true
		elseif (#t>32 and prob>0.5) then
			dflag = true
		end
    end
    --print("size=" .. #t .. ", prob=" .. prob .. ", deepflag=" .. tostring(dflag))


    local rt = remove_dups_tbl_fast(t, dflag)
 	return unicode_tbl_to_utf8_fast(rt)
end

function estimate_dup_probability(tbl)
	local prob = 0.0
	if tbl == nil then
		return prob
	end

	local uc = {}
	for k, v in pairs(tbl) do
		if uc[v] ~= nil then
			uc[v] = uc[v] + 1
		else
			uc[v] = 1
		end
	end

	local counter = 0
	for k, v in pairs(uc) do
		counter = counter + 1
		-- print( unicode_tbl_to_utf8_fast({k}), "=", v)
	end

	--print(counter, #tbl, 1-counter/#tbl)
	return math.floor((1-counter/#tbl)*100)/100
end

-- utf8 to unicode table
function utf8_to_tbl_fast(utf8str, start, stop)
    assert(type(utf8str) == "string")

    if start == nil then
        start = 1
    end    

    if stop == nil then
        stop = #utf8str
    end

    local res, seq, val = {}, 0, nil
    for i = start, stop do
        local c = string.byte(utf8str, i)
        if seq == 0 then
            table.insert(res, val)
            seq = c < 0x80 and 1 or c < 0xE0 and 2 or c < 0xF0 and 3 or
                  c < 0xF8 and 4 or --c < 0xFC and 5 or c < 0xFE and 6 or
                  error("invalid UTF-8 character sequence")
            val = bit.band(c, 2^(8-seq) - 1)
        else
            val = bit.bor(bit.lshift(val, 6), bit.band(c, 0x3F))
        end
        seq = seq - 1
    end
    table.insert(res, val)
    return res
end

-- unicode table to utf8
function unicode_tbl_to_utf8_fast(tbl, start, stop)
	if tbl == nil then
		return nil
	end

    if start == nil then
        start = 1
    end    

    if stop == nil then
        stop = #tbl
    end

    local rets=""
    for i = start, stop do
        local unicode = tbl[i]

        if unicode <= 0x007f then
            rets=rets..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            rets=rets..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            rets=rets..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            rets=rets..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    --rets=rets..'\0'
    return rets
end

-- if t[p1+i]==0xa0 or t[p1+i]==0x20 or t[p1+i]==0x3000
function compare_tables_part_nospace_fast(t, p1, p2, size)
	local ncounter = 0
	local p1pos = 1
	local p2pos = 1

	local result = false

	while(p1pos<=size) do
		-- p1 not space
		local c1 = t[p1+p1pos]
		if c1~=0xa0 and c1~=0x20 and c1~=0x3000 then
			local c2 = nil
			local i

			while(p2pos<=size) do
				c2 = t[p2+p2pos]
				if c2~=0xa0 and c2~=0x20 and c2~=0x3000 then
					p2pos = p2pos + 1
					break
				end
				p2pos = p2pos + 1
			end

			--print(c1, c2)

			if c1 ~= c2 then 
            	return false 
            end

        	 -- number
	        if c1 >= 0x30 and c1 <= 0x39 then
	        	ncounter = ncounter + 1
	        end
		end
	    p1pos = p1pos + 1
	end

    -- ignore all number repeats
    if ncounter == size then
    	return false
    end

	for i=p2pos, size do
		local extrac2 = t[p2+i]
		--p2 has non-space chars
		if extrac2~=0xa0 and extrac2~=0x20 and extrac2~=0x3000 then
			return false
		end
	end

	--print (size, p1pos, p2pos)
	if p1pos  == size+1 then
		result = true
	end

    return result
end

function remove_dups_tbl_fast(t, deep)
	local i, k
    -- offset, window_size
    local off, w
    -- length
    local n = #t
    -- half of length
    local h = math.floor(n/2)

    -- offset from 0 to n
    for off=0, n do
        local maxwin = h

        -- calc max window size
        if h>(n-off) then
        	maxwin = n-off
        end

        -- window size from large to small
        for w=maxwin, 3, -1 do
	        local dups = 0
            -- fist element index = 0
            for k = 1, (n-off)/w-1 do
	            --if compare_tables_part(t, dups*w+off, (dups+1)*w+off, w) then
	            --print(unicode_tbl_to_utf8_fast(t, off+1, off+w) .. " vs " .. unicode_tbl_to_utf8_fast(t, k*w+off+1, k*w+off+w) )
	            --if compare_tables_part_fast(t, off, k*w+off, w) then
	            if compare_tables_part_nospace_fast(t, off, k*w+off, w) then
	                dups = dups + 1
	                --print("dups=", dups, "w=", w)
	            else
	            	break
	            end
            end

            if(dups>0) then
            	local rt = {}
            	for i = 1, off+w do
            		table.insert(rt, t[i])
            	end

				--print(unicode_tbl_to_utf8_fast(rt))

            	for i = (dups+1)*w+off+1, n do
            		table.insert(rt, t[i])
            	end
				--print(unicode_tbl_to_utf8_fast(rt))

            	--ft = nil
            	-- find dups again
            	if deep then
	            	ft = remove_dups_tbl_fast(rt, deep)
	            	if ft ~= nil then
	            		return ft
	            	else
	            		return rt
	            	end
            	else
            		return rt
            	end
            end
        end
    end
end

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
        local server = string.sub(name, index + 1, string.len(name));
        
        if strict == true or server == serverName then
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
                            --addon:Printf("msg:" .. msg)
                            return true 
                        end
                    end                    
                end
            end
        end
    end
    --addon:Printf("msg:" .. msg)
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

-- cleaner timer
function timer_cleaner_cancel()
    if TritonMessage.cleanerTimer and TritonMessage.cleanerTimer:IsCancelled() == false then
        TritonMessage.cleanerTimer:Cancel()
    end
end

function timer_cleaner_func()
    timer_cleaner_cancel()

    -- do cleaning
    TritonMessage:RemoveExpired();

    -- If hooked, setup timer for next run, otherwise just end the timer
    if TritonMessage.hooked then
        -- addon:Printf("cleaner timer fired in " .. tostring(addon.db.global.cleaner_run_interval) .. ' seconds' )
        --C_Timer.After(addon.db.global.cleaner_run_interval, timer_test)
        TritonMessage.cleanerTimer = C_Timer.NewTimer(addon.db.global.cleaner_run_interval, timer_cleaner_func)
    end
end

function TritonMessage:SetupCleanerTimers()
    timer_cleaner_func()
end

-- refresh timer
function timer_refresh_cancel()
    if TritonMessage.refreshTimer and TritonMessage.refreshTimer:IsCancelled() == false then
        TritonMessage.refreshTimer:Cancel()
    end
end

function timer_refresh_func()
    timer_refresh_cancel()

    -- do refreshing
    TritonMessage:UpdateTopicsUIFromTimer()

    -- If hooked, setup timer for next run, otherwise just end the timer
    if TritonMessage.hooked then
        --addon:Printf("refresh timer fired in " .. tostring(addon.db.global.refresh_interval) .. ' seconds' )
        --C_Timer.After(addon.db.global.cleaner_run_interval, timer_test)
        TritonMessage.cleanerTimer = C_Timer.NewTimer(addon.db.global.refresh_interval, timer_refresh_func)
    end
end

function TritonMessage:SetupRefreshTimers()
    timer_refresh_func()
end

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

    --addon:Printf("TritonMessage:HookMessages()")
    addon.frame:RegisterEvent("CHAT_MSG_CHANNEL");
    self.hooked = true

    -- wipe topics 
    if(self.topics) then
        wipe(self.topics)
    else
        self.topics = {}
    end

    -- setup topic cleaner run interval
    self.lastTopicClean = GetTime();

    -- setup cleaner timer
    self:SetupCleanerTimers()

    -- setup refresh timer
    self:SetupRefreshTimers()

    -- setup refresh interval flag
    self.lastRefresh = GetTime() - addon.db.global.refresh_interval;

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

    --addon:Printf("TritonMessage:UnhookMessages()")
    addon.frame:UnregisterEvent("CHAT_MSG_CHANNEL");

    self.hooked = false

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
function TritonMessage:SearchMessage(msg, from, source, guid)

    -- Skipped from if found in Global Ignore List
    if GlobalIgnoreDB and has_value(GlobalIgnoreDB.ignoreList, from)  then 
        -- If from is in global ignore list, skip
        --addon:Printf("skip " .. from .. ' in GlobalIgnoreDB')
        return;
    end

    -- Skipped from if IsBlock return true in Acamar's API
    local tritonapi = _G["AcamarAPIHelper"]
    --addon:Printf("Triton addon=" .. tostring(tritonapi))
    if tritonapi ~= nil then
        local blocked, spamscore = tritonapi:IsBlock(guid)
        --addon:Printf("block=" .. tostring(blocked) .. " (" .. spamscore .. ") user:" .. from)
        -- if blocked by Acamar spam engine, skip the message
        if blocked then
            return
        end
    end

    local nameNoDash = RemoveServerDash(from);

    -- get player info
    local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
    -- skip null player class
    if engClass == nil or engClass == '' then
        return
    end

    --local salted_msg = "<guid:" .. guid .. "><class:" .. engClass .. "><race:" .. engRace .. "><name:" .. name .. "><server:" .. getServer(from) .. ">" .. msg
    local salted_msg = "<guid:" .. guid .. "><class:" .. locClass .. "><race:" .. locRace .. "><name:" .. name .. "><server:" .. getServer(from) .. ">" .. msg
    salted_msg = salted_msg:lower()

    -- addon:Printf("addon.db.global.filters = " .. addon.db.global.filters.include.line1)
    -- addon:Printf("TritonMessage:salted_msg " .. salted_msg)

    -- check if message pass or not
    local pass, keyword = self:FilterTopics(msg, salted_msg, from, source, guid)

    if pass then
        -- merge dup substrings in msg
        msg = RewriteMessage(msg)

        --msg = source .. ":" .. msg

        -- build topics and do cleaner
        self:BuildTopics(msg, salted_msg, from, source, guid, engClass, keyword, nameNoDash)
        -- Update topics once message received
        -- self:UpdateTopicsUI()
    end
end

function handlers.CHAT_MSG_CHANNEL(text, playerName, _, channelName, _, _, _, _, _, _, _, guid)
    TritonMessage:SearchMessage(text, playerName, channelName, guid);
end

function handlers.CHAT_MSG_SAY(text, playerName,  _, _, _, _, _, _, _, _, _, guid)
    TritonMessage:SearchMessage(text, playerName, L["TRITON"]);
end

function handlers.CHAT_MSG_YELL(text, playerName,  _, _, _, _, _, _, _, _, _, guid)
    TritonMessage:SearchMessage(text, playerName, L["TRITON"]);
end

addon.frame:SetScript( "OnEvent", function(self, event, ...) 
    handlers[event](...);
end)


function TritonMessage:OnInitialize()
    --addon:Printf("TritonMessage:OnInitialize()")
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

-- Remove expired messages
function TritonMessage:RemoveExpired()
    -- addon:Printf("Running cleaner ...");

    if self.topics == nil then
        return
    end

    for key, t in pairs(self.topics) do
        if ((GetTime() - t["time"]) > addon.db.global.max_topic_live_secs) then
            -- simply set the topic to nil to avoid memory leak
            --addon:Printf("Removed topic:" .. key);
            self.topics[key] = nil
        end
    end
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
        topic["keyword"] = keyword
        topic["class"] = engClass
        topic["animated"] = false
        topic["guid"] = guid
        
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
        topic["keyword"] = keyword
        topic["class"] = engClass
        topic["animated"] = false
        topic["guid"] = guid

        -- print(table_to_string(topic))
        
        -- add the new topic in topics table
        self.topics[topic_idx] = topic    
    end

    -- addtional cleaner in case timer stop functioning
    -- if cleaner run time reached
    if ((GetTime() - self.lastTopicClean) > addon.db.global.safe_cleaner_run_interval) then
        -- remove long exists topic
        self:RemoveExpired()
        self.lastTopicClean = GetTime()
    end
end


function TritonMessage:UpdateTopicsUI()
    --addon:Printf("Refresh topics upon message receiving ...");
    --print(table_to_string(self.topics))
    -- Only refresh when refresh every interval
    if GetTime() - self.lastRefresh > addon.db.global.refresh_interval then
        addon.GUI:RefreshTopics(self.topics)
        self.lastRefresh = GetTime()
    end
end

function TritonMessage:UpdateTopicsUIFromTimer()
    --addon:Printf("Refresh topics by timer ...");
    self:RemoveExpired()
    addon.GUI:RefreshTopics(self.topics)
    self.lastRefresh = GetTime()
end

