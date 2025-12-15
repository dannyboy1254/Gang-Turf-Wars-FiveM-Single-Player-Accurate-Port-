print("^2[GangWars]^7 Blips client loaded (Gang & Turf style)")
local GangNames = {
    [1] = "Families",
    [2] = "Ballas",
    [3] = "Vagos",
    [4] = "Aztecas",
    [5] = "Lost",
    [6] = "Korean",
    [7] = "Triads",
    [8] = "Armenian",
    [9] = "Rednecks",
    [10] = "Merryweather"
}

------------------------------------------------------------
-- WAIT FOR CONFIG
------------------------------------------------------------
CreateThread(function()
    while not Config or not Config.Zones do
        Wait(0)
    end
end)

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local PlayerGangId = nil
local Zones = {}
local ActiveWars = {}

local ZoneRadiusBlips = {}
local ZoneIconBlips   = {}
local AIBlips         = {} -- roaming peds
local VehicleBlips    = {} -- roaming vehicles

local MAX_AI_BLIP_DIST      = 350.0
local MAX_VEHICLE_BLIP_DIST = 350.0

------------------------------------------------------------
-- COLORS (BLIP COLORS BY GANG)
------------------------------------------------------------
local GANG_BLIP_COLORS = {
    [1]  = 2,   -- Families
    [2]  = 7,   -- Ballas
    [3]  = 46,  -- Vagos
    [4]  = 5,   -- Aztecas
    [5]  = 0,   -- Lost
    [6]  = 3,   -- Korean
    [7]  = 1,   -- Triads
    [8]  = 47,  -- Armenian
    [9]  = 52,  -- Rednecks
    [10] = 6,   -- Merryweather
}

------------------------------------------------------------
-- ZONE ICON SPRITES (SP STYLE)
------------------------------------------------------------
local SPRITE_OWNED   = 417
local SPRITE_UNOWNED = 418

------------------------------------------------------------
-- EVENTS
------------------------------------------------------------
RegisterNetEvent("gangwars:setMyGang", function(id)
    PlayerGangId = id
end)

RegisterNetEvent("gangwars:syncZones", function(z)
    Zones = z or {}
end)

RegisterNetEvent("gangwars:syncWars", function(wars)
    ActiveWars = {}
    for zoneId in pairs(wars or {}) do
        ActiveWars[zoneId] = true
    end
end)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function getZoneOwner(zoneId, zoneCfg)
    local st = Zones[zoneId]
    if type(st) == "table" and st.ownerGangId ~= nil then
        return st.ownerGangId
    end
    if zoneCfg and zoneCfg.ownerGangId ~= nil then
        return zoneCfg.ownerGangId
    end
    return nil
end

local function getBlipColorForGang(gangId)
    return GANG_BLIP_COLORS[gangId] or 0
end

local function getGangName(gangId)
    return gangId and Gangs and Gangs[gangId] and Gangs[gangId].name or "Unowned"
end

------------------------------------------------------------
-- ZONE BLIPS (RADIUS + ICON, BOTH NAMED)
------------------------------------------------------------
local function clearZoneBlips()
    for _, b in pairs(ZoneRadiusBlips) do RemoveBlip(b) end
    for _, b in pairs(ZoneIconBlips)   do RemoveBlip(b) end
    ZoneRadiusBlips = {}
    ZoneIconBlips   = {}
end

local function updateZoneBlips()
    if not Config or not Config.Zones then return end

    for _, zone in ipairs(Config.Zones) do
        local ownerGangId = getZoneOwner(zone.id, zone)
        local color = getBlipColorForGang(ownerGangId)
        local gangName = getGangName(ownerGangId)

        -- RADIUS (NAMED)
        if not ZoneRadiusBlips[zone.id] then
            local r = AddBlipForRadius(
                zone.coords.x, zone.coords.y, zone.coords.z, zone.radius
            )
            SetBlipAlpha(r, 90)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(gangName .. " Territory")
            EndTextCommandSetBlipName(r)

            ZoneRadiusBlips[zone.id] = r
        end
        SetBlipColour(ZoneRadiusBlips[zone.id], color)

        -- ICON (NAMED)
        if not ZoneIconBlips[zone.id] then
            local b = AddBlipForCoord(
                zone.coords.x, zone.coords.y, zone.coords.z
            )
            SetBlipScale(b, 0.85)
            SetBlipAsShortRange(b, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(gangName .. " Turf")
            EndTextCommandSetBlipName(b)

            ZoneIconBlips[zone.id] = b
        end

        SetBlipSprite(
            ZoneIconBlips[zone.id],
            ownerGangId and SPRITE_OWNED or SPRITE_UNOWNED
        )
        SetBlipColour(ZoneIconBlips[zone.id], color)
    end
end

CreateThread(function()
    while not Config or not Config.Zones do Wait(0) end
    clearZoneBlips()
    updateZoneBlips()
end)

CreateThread(function()
    while true do
        updateZoneBlips()
        Wait(5000)
    end
end)

RegisterNetEvent("gangwars:zoneOwnerChanged", function(zoneId, newGangId)
    local color = getBlipColorForGang(newGangId)
    local gangName = getGangName(newGangId)

    if ZoneRadiusBlips[zoneId] then
        SetBlipColour(ZoneRadiusBlips[zoneId], color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(gangName .. " Territory")
        EndTextCommandSetBlipName(ZoneRadiusBlips[zoneId])
    end

    if ZoneIconBlips[zoneId] then
        SetBlipSprite(
            ZoneIconBlips[zoneId],
            newGangId and SPRITE_OWNED or SPRITE_UNOWNED
        )
        SetBlipColour(ZoneIconBlips[zoneId], color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(gangName .. " Turf")
        EndTextCommandSetBlipName(ZoneIconBlips[zoneId])
    end
end)

------------------------------------------------------------
-- ROAMING PED BLIPS (NAMED)
------------------------------------------------------------
local function ensureAIBlip(ped)
    if AIBlips[ped] then return end

    local b = AddBlipForEntity(ped)
    SetBlipSprite(b, 1)
    SetBlipScale(b, 0.6)
    SetBlipAsShortRange(b, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Gang Member")
    EndTextCommandSetBlipName(b)

    AIBlips[ped] = b
end

local function removeAIBlip(ped)
    if AIBlips[ped] then
        RemoveBlip(AIBlips[ped])
        AIBlips[ped] = nil
    end
end

CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())

        for _, ped in ipairs(GetGamePool("CPed")) do
            if DoesEntityExist(ped)
            and Entity(ped).state
            and Entity(ped).state.aiRole == "roaming" then

                local dist = #(GetEntityCoords(ped) - playerPos)
                if dist <= MAX_AI_BLIP_DIST then
                    ensureAIBlip(ped)
                    SetBlipColour(AIBlips[ped], getBlipColorForGang(Entity(ped).state.gangId))
                else
                    removeAIBlip(ped)
                end
            else
                removeAIBlip(ped)
            end
        end

        Wait(1000)
    end
end)

------------------------------------------------------------
-- ROAMING VEHICLE BLIPS (NAMED)
------------------------------------------------------------
local function ensureVehicleBlip(veh)
    if VehicleBlips[veh] then return end

    local b = AddBlipForEntity(veh)
    SetBlipSprite(b, 1)
    SetBlipScale(b, 0.65)
    SetBlipAsShortRange(b, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Gang Vehicle")
    EndTextCommandSetBlipName(b)

    VehicleBlips[veh] = b
end

local function removeVehicleBlip(veh)
    if VehicleBlips[veh] then
        RemoveBlip(VehicleBlips[veh])
        VehicleBlips[veh] = nil
    end
end

CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())

        for _, veh in ipairs(GetGamePool("CVehicle")) do
            if DoesEntityExist(veh)
            and Entity(veh).state
            and Entity(veh).state.aiRole == "roaming_vehicle" then

                local dist = #(GetEntityCoords(veh) - playerPos)
                if dist <= MAX_VEHICLE_BLIP_DIST then
                    ensureVehicleBlip(veh)
                    SetBlipColour(VehicleBlips[veh], getBlipColorForGang(Entity(veh).state.gangId))
                else
                    removeVehicleBlip(veh)
                end
            else
                removeVehicleBlip(veh)
            end
        end

        Wait(1000)
    end
end)

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end

    for _, b in pairs(AIBlips) do RemoveBlip(b) end
    for _, b in pairs(VehicleBlips) do RemoveBlip(b) end
    clearZoneBlips()
end)
