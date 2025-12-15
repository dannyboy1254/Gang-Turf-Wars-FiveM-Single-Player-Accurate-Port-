-- ============================================================
-- SERVER VEHICLE ROAMING (GANG & TURF SP-ACCURATE, FIXED)
-- ============================================================

print("^2[GangWars]^7 SP-accurate vehicle roaming server loaded")

local MAX_VEHICLES_PER_ZONE = 1
local VEHICLE_SPAWN_DELAY  = 20000
local PLAYER_ACTIVE_DIST   = 420.0
local PLAYER_DESPAWN_DIST  = 650.0

-- zoneId -> { vehicles = {}, lastSpawn = 0 }
local Zones = {}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------
local function isAnyPlayerNear(pos, dist)
    for _, pid in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(pid)
        if ped ~= 0 and #(GetEntityCoords(ped) - pos) < dist then
            return true
        end
    end
    return false
end

------------------------------------------------------------
-- SPAWN VEHICLE (SERVER SAFE)
------------------------------------------------------------
local function spawnGangVehicle(zone, gangId)
    local gd = Config.GangData[gangId]
    if not gd or not gd.vehicles or #gd.vehicles == 0 then return nil end

    local model = gd.vehicles[math.random(#gd.vehicles)]

    local veh = CreateVehicle(
        model,
        zone.coords.x + math.random(-15,15),
        zone.coords.y + math.random(-15,15),
        zone.coords.z,
        math.random(0,360),
        true,
        true
    )

    if not DoesEntityExist(veh) then return nil end

    SetVehicleOnGroundProperly(veh)

    Entity(veh).state:set("aiRole", "roaming_vehicle", true)
    Entity(veh).state:set("gangId", gangId, true)
    Entity(veh).state:set("zoneId", zone.id, true)

    return veh
end

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(5000)

        for _, zone in ipairs(Config.Zones) do
            if not zone.ownerGangId then goto continue end

            Zones[zone.id] = Zones[zone.id] or {
                vehicles = {},
                lastSpawn = 0
            }

            local data = Zones[zone.id]
            local near = isAnyPlayerNear(zone.coords, PLAYER_ACTIVE_DIST)

            -- CLEANUP
            for i = #data.vehicles, 1, -1 do
                local veh = data.vehicles[i]
                if not DoesEntityExist(veh) or
                   not isAnyPlayerNear(GetEntityCoords(veh), PLAYER_DESPAWN_DIST) then
                    if DoesEntityExist(veh) then DeleteEntity(veh) end
                    table.remove(data.vehicles, i)
                end
            end

            if not near then goto continue end

            -- SPAWN ONE VEHICLE MAX
            if #data.vehicles < MAX_VEHICLES_PER_ZONE and
               GetGameTimer() - data.lastSpawn > VEHICLE_SPAWN_DELAY then

                local veh = spawnGangVehicle(zone, zone.ownerGangId)
                if veh then
                    table.insert(data.vehicles, veh)
                    data.lastSpawn = GetGameTimer()
                end
            end

            ::continue::
        end
    end
end)

------------------------------------------------------------
-- OWNER CHANGE
------------------------------------------------------------
RegisterNetEvent("gangwars:zoneOwnerChanged", function(zoneId)
    local data = Zones[zoneId]
    if not data then return end

    for _, veh in ipairs(data.vehicles) do
        if DoesEntityExist(veh) then DeleteEntity(veh) end
    end

    Zones[zoneId] = nil
end)
