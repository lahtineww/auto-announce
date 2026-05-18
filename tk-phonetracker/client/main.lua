-- ──────────────────────────────────────────────────────────────────
-- tk-phonetracker | client/main.lua
-- ──────────────────────────────────────────────────────────────────

local isUIOpen      = false
local posBlips      = {}     -- [number] = blipHandle
local radiusBlips   = {}     -- [number] = blipHandle
local activeCircles = {}     -- [number] = {x, y, z, radius}  (for 3D marker)

-- ──────────────────────────────────────────────────────────────────
-- Notifications
-- ──────────────────────────────────────────────────────────────────

local fwName = nil

CreateThread(function()
    Wait(500)
    if Config.Framework ~= 'auto' then
        fwName = Config.Framework
        return
    end
    if GetResourceState('qbx_core') == 'started' then
        fwName = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        fwName = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        fwName = 'esx'
    end
end)

local function Notify(msg, notifType)
    notifType = notifType or 'inform'

    -- ox_lib
    if Config.Notify == 'ox_lib'
    or (Config.Notify == 'auto' and GetResourceState('ox_lib') == 'started') then
        local ok = pcall(function()
            lib.notify({ title = Config.NotifyTitle, description = msg, type = notifType })
        end)
        if ok then return end
    end

    -- lation_ui
    if Config.Notify == 'lation'
    or (Config.Notify == 'auto' and GetResourceState('lation_ui') == 'started') then
        local ok = pcall(function()
            exports['lation_ui']:Notify(Config.NotifyTitle, msg, notifType, 5000)
        end)
        if ok then return end
    end

    -- QBCore notify
    if Config.Notify == 'qb'
    or (Config.Notify == 'auto' and (fwName == 'qbcore' or fwName == 'qbox')) then
        local ok = pcall(function()
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.Notify(('[%s] %s'):format(Config.NotifyTitle, msg), notifType)
        end)
        if ok then return end
    end

    -- ESX notify
    if Config.Notify == 'esx'
    or (Config.Notify == 'auto' and fwName == 'esx') then
        local ok = pcall(function()
            local ESX = exports['es_extended']:getSharedObject()
            ESX.ShowNotification(('[%s] %s'):format(Config.NotifyTitle, msg))
        end)
        if ok then return end
    end

    -- Native GTA notification
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(('[%s]\n%s'):format(Config.NotifyTitle, msg))
    EndTextCommandThefeedPostTicker(false, false)
end

-- ──────────────────────────────────────────────────────────────────
-- Blip management
-- ──────────────────────────────────────────────────────────────────

local function RemoveTrackBlips(number)
    if posBlips[number]    then RemoveBlip(posBlips[number]);    posBlips[number]    = nil end
    if radiusBlips[number] then RemoveBlip(radiusBlips[number]); radiusBlips[number] = nil end
    activeCircles[number] = nil
end

local function SetTrackBlip(number, x, y, z, radius)
    RemoveTrackBlips(number)

    local blip = AddBlipForCoord(x, y, z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipScale(blip, 0.85)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(('Phone: %s'):format(number))
    EndTextCommandSetBlipName(blip)
    posBlips[number] = blip

    local rBlip = AddBlipForRadius(x, y, z, radius)
    SetBlipColour(rBlip, Config.RadiusBlipColor)
    SetBlipAlpha(rBlip, Config.RadiusBlipAlpha)
    radiusBlips[number] = rBlip

    activeCircles[number] = { x = x, y = y, z = z, radius = radius }
end

-- ──────────────────────────────────────────────────────────────────
-- NUI callbacks
-- ──────────────────────────────────────────────────────────────────

RegisterNUICallback('startTracking', function(data, cb)
    local number = tostring(data.number or ''):gsub('%s+', '')
    if #number < 3 then cb({ success = false, message = 'Enter a valid number' }) return end
    TriggerServerEvent('tk-phonetracker:startTracking', number)
    cb({ success = true })
end)

RegisterNUICallback('stopTracking', function(data, cb)
    TriggerServerEvent('tk-phonetracker:stopTracking', tostring(data.number))
    cb({ success = true })
end)

RegisterNUICallback('requestTracks', function(_, cb)
    TriggerServerEvent('tk-phonetracker:requestTracks')
    cb({})
end)

RegisterNUICallback('closeUI', function(_, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    cb({})
end)

-- ──────────────────────────────────────────────────────────────────
-- Server → client events
-- ──────────────────────────────────────────────────────────────────

RegisterNetEvent('tk-phonetracker:response', function(data)
    Notify(data.message, data.success and 'success' or 'error')
end)

RegisterNetEvent('tk-phonetracker:trackUpdate', function(data)
    if data.found then
        SetTrackBlip(data.number, data.x, data.y, data.z, data.radius)
        if data.updateNum == 1 then
            Notify(('Tracking %s – signal found'):format(data.number), 'success')
        end
    else
        RemoveTrackBlips(data.number)
        if data.updateNum == 1 then
            local msgs = {
                no_phone  = 'Target has no phone',
                offline   = 'Target is offline',
                no_signal = 'No signal found',
            }
            Notify(msgs[data.status] or 'No signal', 'error')
        end
    end

    SendNUIMessage({
        action        = 'trackUpdate',
        number        = data.number,
        found         = data.found,
        status        = data.status,
        remaining     = data.remaining,
        totalDuration = data.totalDuration,
        updateNum     = data.updateNum,
    })
end)

RegisterNetEvent('tk-phonetracker:trackStopped', function(data)
    RemoveTrackBlips(data.number)

    if data.reason == 'expired' then
        Notify(('Tracking ended for %s'):format(data.number), 'inform')
    end

    SendNUIMessage({
        action        = 'trackStopped',
        number        = data.number,
        reason        = data.reason,
        cooldownEnds  = data.cooldownEnds,
    })
end)

RegisterNetEvent('tk-phonetracker:syncTracks', function(data)
    SendNUIMessage({
        action    = 'syncTracks',
        tracks    = data.tracks,
        cooldowns = data.cooldowns,
    })
end)

-- ──────────────────────────────────────────────────────────────────
-- UI open / close
-- ──────────────────────────────────────────────────────────────────

local function OpenUI()
    if isUIOpen then return end
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'show' })
    TriggerServerEvent('tk-phonetracker:requestTracks')
end

local function CloseUI()
    if not isUIOpen then return end
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
end

-- ──────────────────────────────────────────────────────────────────
-- Commands & exports
-- ──────────────────────────────────────────────────────────────────

if Config.UseCommand then
    RegisterCommand(Config.Command, function()
        OpenUI()
    end, false)
end

if Config.UseKeybind then
    RegisterKeyMapping(Config.Command, 'Open Phone Tracker', 'keyboard', Config.Keybind)
end

exports('OpenUI', OpenUI)
exports('CloseUI', CloseUI)

-- Client-side export fires the tracking just like the command does
exports('TrackNumber', function(number)
    TriggerServerEvent('tk-phonetracker:startTracking', tostring(number))
end)

-- ──────────────────────────────────────────────────────────────────
-- 3D uncertainty-circle rendering thread
-- ──────────────────────────────────────────────────────────────────

CreateThread(function()
    while true do
        local hasAny = false

        for _, circle in pairs(activeCircles) do
            hasAny = true
            -- Small pulsing cone marks the center of the estimated area
            DrawMarker(
                27,
                circle.x, circle.y, circle.z + 0.05,
                0.0, 0.0, 0.0,
                0.0, 180.0, 0.0,
                1.2, 1.2, 0.6,
                30, 120, 255, 160,
                false, false, 2, true, nil, nil, false
            )
        end

        Wait(hasAny and 0 or 1000)
    end
end)
