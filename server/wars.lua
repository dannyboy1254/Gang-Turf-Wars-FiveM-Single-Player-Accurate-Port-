-- ============================================================
-- SERVER WAR ENGINE (AUTHORITATIVE, ONESYNC SAFE)
-- ============================================================

Wars = {}

local BASE_TICKETS = 50
local WAR_TICK_RATE = 10
local MAX_RENDER = 12

local GANG_STRENGTH = {
    default = { attack = 1.0, defend = 1.0 }
}

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function getGangStrength(gangId)
    return GANG_STRENGTH[gangId] or GANG_STRENGTH.default
end

local function getRenderCounts(war)
    return {
        attackers = math.min(war.attackerTickets, MAX_RENDER),
        defenders = math.min(war.defenderTickets, MAX_RENDER)
    }
end

local function broadcastWars()
    local out = {}
    for zoneId, war in pairs(Wars) do
        if war.active then
            out[zoneId] = true
        end
    end
    TriggerClientEvent("gangwars:syncWars", -1, out)
end

local function syncWar(zoneId)
    local war = Wars[zoneId]
    if not war then return end

    TriggerClientEvent("gangwars:syncWarState", -1, zoneId, {
        active = war.active,
        zoneId = zoneId,
        attackerGang = war.attackerGang,
        defenderGang = war.defenderGang,
        attackerTickets = war.attackerTickets,
        defenderTickets = war.defenderTickets,
        render = getRenderCounts(war)
    })
end

------------------------------------------------------------
-- PLAYER JOIN SYNC
------------------------------------------------------------

RegisterNetEvent("gangwars:requestWars", function()
    local src = source
    local out = {}
    for zoneId, war in pairs(Wars) do
        if war.active then
            out[zoneId] = true
        end
    end
    TriggerClientEvent("gangwars:syncWars", src, out)
end)

------------------------------------------------------------
-- START WAR
------------------------------------------------------------

RegisterNetEvent("gangwars:startWar", function(zoneId)
    local src = source
    local attackerGang = GangsAPI.getGang(src)
    if not attackerGang then return end

    local zone = ZonesAPI.getZone(zoneId)
    if not zone then return end

    -- Mod option: war lock
    if ModOptions and ModOptions.lockWars then
        TriggerClientEvent("gangwars:notify", src, "Wars are currently locked")
        return
    end

    local defenderGang = zone.ownerGangId or 0
    if defenderGang == attackerGang then return end
    if Wars[zoneId] then return end

    Wars[zoneId] = {
        active = true,
        zoneId = zoneId,
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        attackerTickets = BASE_TICKETS,
        defenderTickets = BASE_TICKETS,
        startedAt = os.time(),
        lastTick = os.time()
    }

    -- 🔥 WAR SPAWN SELECTION (SP-ACCURATE)
    local spawn = nil
    if getWarSpawn then
        spawn = getWarSpawn(zoneId)
    end

    TriggerClientEvent("gangwars:setupWarAI", -1, zoneId, {
        attackerGang = attackerGang,
        defenderGang = defenderGang,
        render = getRenderCounts(Wars[zoneId]),
        spawn = spawn -- may be nil; client handles fallback
    })

    TriggerClientEvent(
        "gangwars:notify",
        -1,
        ("War started at %s (Gang %d vs %d)")
            :format(zoneId, attackerGang, defenderGang)
    )

    syncWar(zoneId)
    broadcastWars()
end)

------------------------------------------------------------
-- WAR TICKET LOOP
------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(WAR_TICK_RATE * 1000)

        for zoneId, war in pairs(Wars) do
            if not war.active then goto continue end

            local now = os.time()
            if now - war.lastTick < WAR_TICK_RATE then goto continue end
            war.lastTick = now

            local atkStr = getGangStrength(war.attackerGang)
            local defStr = getGangStrength(war.defenderGang)

            war.attackerTickets = math.max(
                war.attackerTickets - math.random(1, 3) * defStr.defend,
                0
            )

            war.defenderTickets = math.max(
                war.defenderTickets - math.random(1, 3) * atkStr.attack,
                0
            )

            syncWar(zoneId)
            broadcastWars()

            -- END WAR
            if war.attackerTickets <= 0 or war.defenderTickets <= 0 then
                local winner =
                    (war.attackerTickets > war.defenderTickets)
                    and war.attackerGang
                    or war.defenderGang

                ZonesAPI.setOwner(zoneId, winner)

                TriggerClientEvent(
                    "gangwars:notify",
                    -1,
                    ("War ended at %s. Gang %d wins.")
                        :format(zoneId, winner)
                )

                TriggerClientEvent("gangwars:cleanupWarAI", -1, zoneId)
                TriggerClientEvent("gangwars:warEnded", -1, zoneId)

                Wars[zoneId] = nil
                broadcastWars()
            end

            ::continue::
        end
    end
end)

------------------------------------------------------------
-- ADMIN FORCE END
------------------------------------------------------------

RegisterNetEvent("gangwars:forceEndWar", function(zoneId)
    if not Wars[zoneId] then return end

    TriggerClientEvent("gangwars:cleanupWarAI", -1, zoneId)
    TriggerClientEvent("gangwars:warEnded", -1, zoneId)

    Wars[zoneId] = nil
    broadcastWars()
end)
