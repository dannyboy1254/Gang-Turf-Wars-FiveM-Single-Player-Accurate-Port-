-- ============================================================
-- SERVER WAR SPAWNS (PERSISTENT, ZONE-BASED)
-- ============================================================

WarSpawns = {}

local spawnFile = "data/war_spawns.json"

------------------------------------------------------------
-- LOAD / SAVE
------------------------------------------------------------

local function saveSpawns()
    Persistence.saveFile(spawnFile, WarSpawns)
end

local function loadSpawns()
    local saved = Persistence.loadFile(spawnFile)
    if saved then
        WarSpawns = saved
    else
        WarSpawns = {}
        saveSpawns()
    end
end

------------------------------------------------------------
-- INIT
------------------------------------------------------------

CreateThread(function()
    loadSpawns()
    print("^2[GangWars]^7 War spawns loaded")
end)

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function getZoneAtCoords(coords)
    for _, z in ipairs(Config.Zones) do
        if #(coords - z.coords) <= z.radius then
            return z.id
        end
    end
end

local function getClosestSpawn(zoneId, coords)
    if not WarSpawns[zoneId] then return nil end

    local best, bestDist
    for _, s in ipairs(WarSpawns[zoneId]) do
        local d = #(coords - vector3(s.x, s.y, s.z))
        if not bestDist or d < bestDist then
            best = s
            bestDist = d
        end
    end
    return best, bestDist
end

------------------------------------------------------------
-- MENU → SERVER EVENTS
------------------------------------------------------------

-- ADD SPAWN AT PLAYER POSITION
RegisterNetEvent("gangwars:menu_addWarSpawnHere", function()
    local src = source
    local ped = GetPlayerPed(src)
    if not ped then return end

    local coords = GetEntityCoords(ped)
    local zoneId = getZoneAtCoords(coords)
    if not zoneId then
        TriggerClientEvent("gangwars:notify", src, "You are not inside a turf zone")
        return
    end

    WarSpawns[zoneId] = WarSpawns[zoneId] or {}

    table.insert(WarSpawns[zoneId], {
        x = coords.x,
        y = coords.y,
        z = coords.z
    })

    saveSpawns()

    TriggerClientEvent(
        "gangwars:notify",
        src,
        ("War spawn added for zone %s"):format(zoneId)
    )
end)

-- REMOVE NEAREST SPAWN
RegisterNetEvent("gangwars:menu_removeWarSpawnNearby", function()
    local src = source
    local ped = GetPlayerPed(src)
    if not ped then return end

    local coords = GetEntityCoords(ped)
    local zoneId = getZoneAtCoords(coords)
    if not zoneId or not WarSpawns[zoneId] then
        TriggerClientEvent("gangwars:notify", src, "No war spawns here")
        return
    end

    local spawn, dist = getClosestSpawn(zoneId, coords)
    if not spawn or dist > 15.0 then
        TriggerClientEvent("gangwars:notify", src, "No nearby war spawn found")
        return
    end

    for i, s in ipairs(WarSpawns[zoneId]) do
        if s == spawn then
            table.remove(WarSpawns[zoneId], i)
            break
        end
    end

    saveSpawns()

    TriggerClientEvent(
        "gangwars:notify",
        src,
        ("War spawn removed from zone %s"):format(zoneId)
    )
end)

------------------------------------------------------------
-- API (USED BY WAR ENGINE)
------------------------------------------------------------

function getWarSpawn(zoneId)
    local list = WarSpawns[zoneId]
    if not list or #list == 0 then return nil end
    return list[math.random(#list)]
end
