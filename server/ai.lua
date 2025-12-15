-- ============================================================
-- SERVER WAR AI CONTROLLER (ONESYNC SAFE, TURF-LOCKED)
-- ============================================================

print("^2[GangWars]^7 War AI server loaded")

WarAI = {} -- zoneId -> { attackers = {}, defenders = {} }

------------------------------------------------------------
-- UTIL
------------------------------------------------------------
local function getZone(zoneId)
    for _, z in ipairs(Config.Zones) do
        if z.id == zoneId then return z end
    end
end

local function getValidPedModel(gangId)
    local gd = Config.GangData and Config.GangData[gangId]
    if not gd or not gd.peds then return nil end

    for _ = 1, #gd.peds do
        local model = gd.peds[math.random(#gd.peds)]
        if IsModelInCdimage(model) and IsModelValid(model) then
            return model
        end
    end

    return nil
end

local function loadModel(hash)
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 200 do
        tries += 1
        Wait(0)
    end
    return HasModelLoaded(hash)
end

------------------------------------------------------------
-- SAFE TURF SPAWN (NO STREETS)
------------------------------------------------------------
local function getTurfSpawn(zone)
    for _ = 1, 25 do
        local ox = zone.coords.x + math.random(-zone.radius + 6, zone.radius - 6)
        local oy = zone.coords.y + math.random(-zone.radius + 6, zone.radius - 6)
        local oz = zone.coords.z

        local found, safe = GetSafeCoordForPed(ox, oy, oz, false, 16)
        if found then
            return safe
        end
    end
    return zone.coords
end

------------------------------------------------------------
-- PED SPAWN
------------------------------------------------------------
local function spawnPedForGang(gangId, zone)
    local model = getValidPedModel(gangId)
    if not model then
        print("^1[GangWars]^7 Invalid model for gangId:", gangId)
        return nil
    end

    if not loadModel(model) then return nil end

    local pos = getTurfSpawn(zone)

    local ped = CreatePed(
        4,
        model,
        pos.x,
        pos.y,
        pos.z,
        math.random(0,360),
        true,
        true
    )

    if not DoesEntityExist(ped) then return nil end

    -- Kill civilian behavior immediately
    ClearPedTasksImmediately(ped)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanPlayAmbientAnims(ped, false)
    SetPedCanPlayGestureAnims(ped, false)
    SetPedConfigFlag(ped, 208, true)

    return ped
end

------------------------------------------------------------
-- PED EQUIP
------------------------------------------------------------
local function equipPed(ped, gangId)
    local gd = Config.GangData[gangId]

    local weapon = `WEAPON_PISTOL`
    if gd and gd.weapons and #gd.weapons > 0 then
        weapon = gd.weapons[math.random(#gd.weapons)]
    end

    GiveWeaponToPed(ped, weapon, 9999, false, true)
    SetCurrentPedWeapon(ped, weapon, true)

    SetPedCombatAbility(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedAccuracy(ped, (gd and gd.accuracy) or 45)
    SetPedArmour(ped, (gd and gd.armor) or 30)
    SetPedFleeAttributes(ped, 0, false)
end

------------------------------------------------------------
-- KEEP AI INSIDE ZONE (ANTI-STREET)
------------------------------------------------------------
local function keepPedInZone(ped, zone)
    if not DoesEntityExist(ped) then return end

    local dist = #(GetEntityCoords(ped) - zone.coords)
    if dist > zone.radius then
        ClearPedTasksImmediately(ped)
        TaskGoStraightToCoord(
            ped,
            zone.coords.x,
            zone.coords.y,
            zone.coords.z,
            2.0,
            -1,
            0.0,
            0.0
        )
    end
end

------------------------------------------------------------
-- SPAWN WAR AI (ONLY CALLED WHEN WAR STARTS)
------------------------------------------------------------
function SpawnWarAI(zoneId, war)
    if WarAI[zoneId] then return end

    local zone = getZone(zoneId)
    if not zone then return end

    WarAI[zoneId] = { attackers = {}, defenders = {} }

    for i = 1, 12 do
        local a = spawnPedForGang(war.attackerGang, zone)
        local d = spawnPedForGang(war.defenderGang, zone)

        if a then
            equipPed(a, war.attackerGang)
            Entity(a).state:set("gangId", war.attackerGang, true)
            Entity(a).state:set("zoneId", zoneId, true)
            Entity(a).state:set("aiRole", "war", true)
            table.insert(WarAI[zoneId].attackers, a)
        end

        if d then
            equipPed(d, war.defenderGang)
            Entity(d).state:set("gangId", war.defenderGang, true)
            Entity(d).state:set("zoneId", zoneId, true)
            Entity(d).state:set("aiRole", "war", true)
            table.insert(WarAI[zoneId].defenders, d)
        end
    end
end

------------------------------------------------------------
-- SERVER COMBAT LOOP (NO ROAMING)
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(1500)

        for zoneId, data in pairs(WarAI) do
            local zone = getZone(zoneId)
            if not zone then goto continue end

            for _, a in ipairs(data.attackers) do
                if DoesEntityExist(a) and not IsPedDeadOrDying(a) then
                    keepPedInZone(a, zone)
                    local t = data.defenders[math.random(#data.defenders)]
                    if t and DoesEntityExist(t) then
                        TaskCombatPed(a, t, 0, 16)
                    end
                end
            end

            for _, d in ipairs(data.defenders) do
                if DoesEntityExist(d) and not IsPedDeadOrDying(d) then
                    keepPedInZone(d, zone)
                    local t = data.attackers[math.random(#data.attackers)]
                    if t and DoesEntityExist(t) then
                        TaskCombatPed(d, t, 0, 16)
                    end
                end
            end

            ::continue::
        end
    end
end)

------------------------------------------------------------
-- CLEANUP (CALLED WHEN WAR ENDS)
------------------------------------------------------------
RegisterNetEvent("gangwars:cleanupWarAI", function(zoneId)
    local data = WarAI[zoneId]
    if not data then return end

    for _, p in ipairs(data.attackers) do
        if DoesEntityExist(p) then DeleteEntity(p) end
    end
    for _, p in ipairs(data.defenders) do
        if DoesEntityExist(p) then DeleteEntity(p) end
    end

    WarAI[zoneId] = nil
end)
