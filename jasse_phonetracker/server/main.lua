-- ──────────────────────────────────────────────────────────────────
-- jasse_phonetracker | server/main.lua
-- ──────────────────────────────────────────────────────────────────

local FW       = nil   -- framework object (ESX shared / QBCore / QBox)
local fwName   = nil   -- 'esx' | 'qbcore' | 'qbox'

-- [phoneNumber] = { targetId, startTime, updates, timer }
local activeTracks  = {}
-- [phoneNumber] = os.time() expiry
local trackCooldowns = {}

-- ──────────────────────────────────────────────────────────────────
-- Framework bootstrap (wait until other resources are ready)
-- ──────────────────────────────────────────────────────────────────
CreateThread(function()
    Wait(500)

    local detected = Config.Framework ~= 'auto' and Config.Framework or nil

    if not detected then
        if GetResourceState('qbx_core') == 'started' then
            detected = 'qbox'
        elseif GetResourceState('qb-core') == 'started' then
            detected = 'qbcore'
        elseif GetResourceState('es_extended') == 'started' then
            detected = 'esx'
        end
    end

    fwName = detected or 'native'

    if fwName == 'qbox' then
        FW = exports['qbx_core']:GetCoreObject()
    elseif fwName == 'qbcore' then
        FW = exports['qb-core']:GetCoreObject()
    elseif fwName == 'esx' then
        FW = exports['es_extended']:getSharedObject()
    end

    print(('[jasse_phonetracker] Framework: %s | Locale: %s'):format(fwName, Config.Locale))
end)

-- ──────────────────────────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────────────────────────

local function HasPoliceJob(src)
    local job = nil

    if fwName == 'esx' and FW then
        local xp = FW.GetPlayerFromId(src)
        if xp then job = xp.job.name end

    elseif (fwName == 'qbcore' or fwName == 'qbox') and FW then
        local player = FW.Functions.GetPlayer(src)
        if player then job = player.PlayerData.job.name end
    end

    if not job then
        return IsPlayerAceAllowed(tostring(src), 'phonetracker.use')
    end

    for _, v in ipairs(Config.PoliceJobs) do
        if v == job then return true end
    end
    return false
end

-- Try every supported phone script to get a player's number
local function GetPlayerPhoneNumber(src)
    local num = nil

    -- lb-phone
    if not num and GetResourceState('lb-phone') == 'started' then
        local ok, v = pcall(function() return exports['lb-phone']:GetPlayerPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- qs-smartphone
    if not num and GetResourceState('qs-smartphone') == 'started' then
        local ok, v = pcall(function() return exports['qs-smartphone']:GetNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- 17_phone / phonix (17movement)
    if not num and GetResourceState('17_phone') == 'started' then
        local ok, v = pcall(function() return exports['17_phone']:GetPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end
    if not num and GetResourceState('phonix') == 'started' then
        local ok, v = pcall(function() return exports['phonix']:GetPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- gks-phone
    if not num and GetResourceState('gksphone') == 'started' then
        local ok, v = pcall(function() return exports['gksphone']:GetPlayerPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- npwd / pn-phone
    if not num and GetResourceState('npwd') == 'started' then
        local ok, v = pcall(function() return exports['npwd']:getPlayerPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end
    if not num and GetResourceState('pn-phone') == 'started' then
        local ok, v = pcall(function() return exports['pn-phone']:GetPlayerPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- esx_phone
    if not num and GetResourceState('esx_phone') == 'started' then
        local ok, v = pcall(function() return exports['esx_phone']:getPhoneNumber(src) end)
        if ok and v then num = tostring(v) end
    end

    -- Framework charinfo fallback
    if not num then
        if (fwName == 'qbcore' or fwName == 'qbox') and FW then
            local ok, player = pcall(function() return FW.Functions.GetPlayer(src) end)
            if ok and player and player.PlayerData.charinfo then
                num = tostring(player.PlayerData.charinfo.phone or '')
            end
        elseif fwName == 'esx' and FW then
            local ok, xp = pcall(function() return FW.GetPlayerFromId(src) end)
            if ok and xp then
                local meta = xp.get('phone_number')
                if meta then num = tostring(meta) end
            end
        end
    end

    return (num and #num > 0) and num or nil
end

-- Find which connected player owns the given phone number
local function FindPlayerByPhone(targetNumber)
    targetNumber = targetNumber:gsub('%s+', '')

    for _, rawSrc in ipairs(GetPlayers()) do
        local src = tonumber(rawSrc)
        local n   = GetPlayerPhoneNumber(src)
        if n and n:gsub('%s+', '') == targetNumber then
            return src
        end
    end
    return nil
end

-- Check if player has a phone item in their inventory
local function HasPhoneItem(src)
    local inv = Config.Inventory

    -- ox_inventory
    local useOx = inv == 'ox_inventory'
        or (inv == 'auto' and GetResourceState('ox_inventory') == 'started')
    if useOx then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, count = pcall(function() return exports.ox_inventory:Search(src, 'count', item) end)
            if ok and count and count > 0 then return true end
        end
        return false
    end

    -- qs-inventory
    local useQs = inv == 'qs-inventory'
        or (inv == 'auto' and GetResourceState('qs-inventory') == 'started')
    if useQs then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, res = pcall(function() return exports['qs-inventory']:GetItemByName(src, item) end)
            if ok and res and (res.amount or 0) > 0 then return true end
        end
        return false
    end

    -- ps-inventory
    local usePs = inv == 'ps-inventory'
        or (inv == 'auto' and GetResourceState('ps-inventory') == 'started')
    if usePs then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, has = pcall(function() return exports['ps-inventory']:HasItem(src, item, 1) end)
            if ok and has then return true end
        end
        return false
    end

    -- core_inventory
    local useCore = inv == 'core_inventory'
        or (inv == 'auto' and GetResourceState('core_inventory') == 'started')
    if useCore then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, count = pcall(function() return exports['core_inventory']:GetItemCount(src, item) end)
            if ok and count and count > 0 then return true end
        end
        return false
    end

    -- origen_inventory
    local useOrigen = inv == 'origen_inventory'
        or (inv == 'auto' and GetResourceState('origen_inventory') == 'started')
    if useOrigen then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, count = pcall(function() return exports['origen_inventory']:GetItemAmount(src, item) end)
            if ok and count and count > 0 then return true end
        end
        return false
    end

    -- CodeM_Inventory
    local useCodeM = inv == 'CodeM_Inventory'
        or (inv == 'auto' and GetResourceState('CodeM_Inventory') == 'started')
    if useCodeM then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, count = pcall(function() return exports['CodeM_Inventory']:GetItemCount(src, item) end)
            if ok and count and count > 0 then return true end
        end
        return false
    end

    -- qb-inventory (via QBCore HasItem)
    if (fwName == 'qbcore' or fwName == 'qbox') and FW then
        for _, item in ipairs(Config.PhoneItems) do
            local ok, has = pcall(function() return FW.Functions.HasItem and FW.Functions.HasItem(src, item) end)
            if ok and has then return true end
        end
        return false
    end

    -- ESX native
    if fwName == 'esx' and FW then
        local ok, xp = pcall(function() return FW.GetPlayerFromId(src) end)
        if ok and xp then
            for _, item in ipairs(Config.PhoneItems) do
                local ok2, it = pcall(function() return xp.getInventoryItem(item) end)
                if ok2 and it and it.count > 0 then return true end
            end
        end
        return false
    end

    -- No inventory detected — allow by default so tracking still works
    return true
end

-- Calculate a tracking result based on probability rolls
local function CalcTrackResult(targetSrc)
    local ped = GetPlayerPed(targetSrc)
    if not ped or ped == 0 then return nil end

    local coords = GetEntityCoords(ped)
    local roll   = math.random(1, 100)

    if roll <= Config.SuccessChance then
        -- Accurate: offset center so real phone is inside circle but not at center
        local angle = math.random() * 2 * math.pi
        local dist  = math.random(Config.OffsetMin, Config.OffsetMax)
        return {
            found  = true,
            status = 'found',
            x      = coords.x + math.cos(angle) * dist,
            y      = coords.y + math.sin(angle) * dist,
            z      = coords.z,
            radius = Config.LocationRadius,
        }
    elseif roll <= Config.SuccessChance + Config.NoSignalChance then
        return { found = false, status = 'no_signal' }
    else
        -- Fake: random spot inside greater Los Santos area
        local fakeX = math.random(-2000, 2000) + (math.random() - 0.5) * 200
        local fakeY = math.random(-3500, 500)  + (math.random() - 0.5) * 200
        return {
            found  = true,
            status = 'found',
            x      = fakeX,
            y      = fakeY,
            z      = 30.0,
            radius = Config.LocationRadius,
        }
    end
end

-- Send an event to every online police officer
local function BroadcastToPolice(event, data)
    for _, rawSrc in ipairs(GetPlayers()) do
        local src = tonumber(rawSrc)
        if HasPoliceJob(src) then
            TriggerClientEvent(event, src, data)
        end
    end
end

-- ──────────────────────────────────────────────────────────────────
-- Tracking lifecycle
-- ──────────────────────────────────────────────────────────────────

local function StopTracking(number, reason)
    local track = activeTracks[number]
    if not track then return end

    if track.timer then ClearTimeout(track.timer) end

    trackCooldowns[number] = os.time() + Config.Cooldown

    BroadcastToPolice('jasse_phonetracker:trackStopped', {
        number       = number,
        reason       = reason or 'expired',
        cooldownEnds = trackCooldowns[number],
    })

    activeTracks[number] = nil
end

local function DoTrackUpdate(number)
    local track = activeTracks[number]
    if not track then return end

    track.updates = track.updates + 1

    local elapsed   = os.time() - track.startTime
    local remaining = Config.TrackDuration - elapsed

    if remaining <= 0 then
        StopTracking(number, 'expired')
        return
    end

    -- Re-verify target is still online (re-lookup if needed)
    if track.targetId then
        local ped = GetPlayerPed(track.targetId)
        if not ped or ped == 0 then
            track.targetId = FindPlayerByPhone(number)
        end
    else
        track.targetId = FindPlayerByPhone(number)
    end

    local hasPhone = track.targetId and HasPhoneItem(track.targetId)
    local result

    if track.targetId and hasPhone then
        result = CalcTrackResult(track.targetId)
    elseif track.targetId and not hasPhone then
        result = { found = false, status = 'no_phone' }
    else
        result = { found = false, status = 'offline' }
    end

    result.number        = number
    result.remaining     = remaining
    result.totalDuration = Config.TrackDuration
    result.updateNum     = track.updates

    BroadcastToPolice('jasse_phonetracker:trackUpdate', result)

    -- Schedule next update unless we've exhausted the full duration
    local maxUpdates = math.ceil(Config.TrackDuration / Config.UpdateInterval)
    if track.updates < maxUpdates then
        track.timer = SetTimeout(Config.UpdateInterval * 1000, function()
            DoTrackUpdate(number)
        end)
    else
        StopTracking(number, 'expired')
    end
end

-- ──────────────────────────────────────────────────────────────────
-- Net events
-- ──────────────────────────────────────────────────────────────────

RegisterNetEvent('jasse_phonetracker:startTracking', function(number)
    local src = source

    if not HasPoliceJob(src) then
        TriggerClientEvent('jasse_phonetracker:response', src, { success = false, message = _L('response_access_denied') })
        return
    end

    number = tostring(number):gsub('%s+', '')
    if #number < 3 then
        TriggerClientEvent('jasse_phonetracker:response', src, { success = false, message = _L('response_invalid_number') })
        return
    end

    -- Cooldown check
    if trackCooldowns[number] and trackCooldowns[number] > os.time() then
        local left = trackCooldowns[number] - os.time()
        local h    = math.floor(left / 3600)
        local m    = math.floor((left % 3600) / 60)
        TriggerClientEvent('jasse_phonetracker:response', src, {
            success = false,
            message = _L('response_cooldown', h, m),
        })
        return
    end

    if activeTracks[number] then
        TriggerClientEvent('jasse_phonetracker:response', src, { success = false, message = _L('response_already') })
        return
    end

    -- Target lookup
    local targetId = FindPlayerByPhone(number)

    if targetId and not HasPhoneItem(targetId) then
        TriggerClientEvent('jasse_phonetracker:response', src, { success = false, message = _L('response_no_phone') })
        return
    end

    activeTracks[number] = {
        targetId  = targetId,
        startTime = os.time(),
        updates   = 0,
        timer     = nil,
    }

    TriggerClientEvent('jasse_phonetracker:response', src, { success = true, message = _L('response_initiated') })

    -- Immediate first update
    DoTrackUpdate(number)
end)

RegisterNetEvent('jasse_phonetracker:stopTracking', function(number)
    local src = source
    if not HasPoliceJob(src) then return end
    if activeTracks[tostring(number)] then
        StopTracking(tostring(number), 'manual')
    end
end)

RegisterNetEvent('jasse_phonetracker:requestTracks', function()
    local src = source
    if not HasPoliceJob(src) then return end

    local tracks    = {}
    local coolsList = {}

    for number, track in pairs(activeTracks) do
        tracks[#tracks + 1] = {
            number    = number,
            remaining = Config.TrackDuration - (os.time() - track.startTime),
        }
    end

    for number, expires in pairs(trackCooldowns) do
        if expires > os.time() then
            coolsList[#coolsList + 1] = {
                number    = number,
                remaining = expires - os.time(),
            }
        end
    end

    TriggerClientEvent('jasse_phonetracker:syncTracks', src, {
        tracks    = tracks,
        cooldowns = coolsList,
    })
end)

-- ──────────────────────────────────────────────────────────────────
-- Exports
-- ──────────────────────────────────────────────────────────────────

-- Direct location lookup (no tracking loop, just a single roll)
exports('GetLocation', function(number)
    if not number then return nil end
    number = tostring(number):gsub('%s+', '')

    local targetId = FindPlayerByPhone(number)
    if not targetId              then return nil end
    if not HasPhoneItem(targetId) then return nil end

    local result = CalcTrackResult(targetId)
    if result and result.found then
        return vector3(result.x, result.y, result.z)
    end
    return nil
end)

exports('IsTracking', function(number)
    return activeTracks[tostring(number)] ~= nil
end)

exports('GetActiveTracks', function()
    local list = {}
    for number in pairs(activeTracks) do
        list[#list + 1] = number
    end
    return list
end)

exports('StartTracking', function(number, callerSrc)
    TriggerEvent('jasse_phonetracker:startTracking', number)
end)
