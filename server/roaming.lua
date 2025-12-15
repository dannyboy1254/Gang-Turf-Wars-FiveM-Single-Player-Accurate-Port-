-- ============================================================
-- SERVER ROAMING AI (GANG & TURF SP-ACCURATE, FIXED)
-- ============================================================

print("^2[GangWars]^7 SP-accurate roaming AI server loaded")

local MAX_PEDS_PER_ZONE    = 6
local SPAWN_DELAY_MS      = 12000
local PLAYER_ACTIVE_DIST  = 420.0
local PLAYER_DESPAWN_DIST = 650.0
local Z_SPAWN_OFFSET      = 1.5

-- zoneId -> { peds = {}, lastSpawn = 0 }
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
-- SPAWN PED (SERVER SAFE)
------------------------------------------------------------
local function spawnGangPed(zone, gangId)
    local gd = Config.GangData[gangId]
    if not gd or not gd.peds or #gd.peds == 0 then return nil end

    local model = gd.peds[math.random(#gd.peds)]

    local angle = math.random() * math.pi * 2
    local dist  = math.random(5, zone.radius - 5)

    local pos = vector3(
        zone.coords.x + math.cos(angle) * dist,
        zone.coords.y + math.sin(angle) * dist,
        zone.coords.z + Z_SPAWN_OFFSET
    )

    local ped = CreatePed(4, model, pos.x, pos.y, pos.z, math.random(0,360), true, true)
    if not DoesEntityExist(ped) then return nil end

    Entity(ped).state:set("aiRole", "roaming", true)
    Entity(ped).state:set("gangId", gangId, true)
    Entity(ped).state:set("zoneId", zone.id, true)

    return ped
end

------------------------------------------------------------
-- MAIN LOOP (PLAYER-CENTRIC, SP-STYLE)
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(4000)

        for _, zone in ipairs(Config.Zones) do
            if not zone.ownerGangId then goto continue end

            Zones[zone.id] = Zones[zone.id] or {
                peds = {},
                lastSpawn = 0
            }

            local data = Zones[zone.id]
            local near = isAnyPlayerNear(zone.coords, PLAYER_ACTIVE_DIST)

            ------------------------------------------------
            -- CLEANUP (PLAYER DISTANCE)
            ------------------------------------------------
            for i = #data.peds, 1, -1 do
                local ped = data.peds[i]
                if not DoesEntityExist(ped) or
                   not isAnyPlayerNear(GetEntityCoords(ped), PLAYER_DESPAWN_DIST) then
                    if DoesEntityExist(ped) then DeleteEntity(ped) end
                    table.remove(data.peds, i)
                end
            end

            if not near then goto continue end

            ------------------------------------------------
            -- SOFT RETURN FLAG (SP-STYLE)
            ------------------------------------------------
            for _, ped in ipairs(data.peds) do
                if DoesEntityExist(ped) then
                    local dist = #(GetEntityCoords(ped) - zone.coords)

                    if dist > (zone.radius * 1.15) then
                        Entity(ped).state:set("returnToZone", true, true)
                    else
                        Entity(ped).state:set("returnToZone", false, true)
                    end
                end
            end

            ------------------------------------------------
            -- SPAWN ONE AT A TIME (THROTTLED)
            ------------------------------------------------
            if #data.peds < MAX_PEDS_PER_ZONE and
               GetGameTimer() - data.lastSpawn > SPAWN_DELAY_MS then

                local ped = spawnGangPed(zone, zone.ownerGangId)
                if ped then
                    table.insert(data.peds, ped)
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

    for _, ped in ipairs(data.peds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end

    Zones[zoneId] = nil
end)
