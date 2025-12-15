-- ============================================================
-- CLIENT ROAMING AI (SP-ACCURATE, SAFE, SERVER-CONTROLLED)
-- ============================================================

print("^2[GangWars]^7 Roaming AI client loaded (FINAL w/ return logic)")

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local STREAM_DIST  = 300.0

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local ActiveWars = {}
local Assigned   = {}        -- ped -> true
local Returning  = {}        -- ped -> true (walking back)

------------------------------------------------------------
-- EVENTS
------------------------------------------------------------
RegisterNetEvent("gangwars:syncWars", function(wars)
    ActiveWars = {}
    for z in pairs(wars or {}) do
        ActiveWars[z] = true
    end
end)

------------------------------------------------------------
-- CONTROL HELPER
------------------------------------------------------------
local function ensureControl(ent)
    if NetworkHasControlOfEntity(ent) then return true end
    NetworkRequestControlOfEntity(ent)

    local timeout = GetGameTimer() + 500
    while not NetworkHasControlOfEntity(ent) and GetGameTimer() < timeout do
        Wait(0)
    end

    return NetworkHasControlOfEntity(ent)
end

------------------------------------------------------------
-- ASSIGN SP WANDER
------------------------------------------------------------
local function assignRoam(ped)
    if Assigned[ped] then return end
    if not ensureControl(ped) then return end

    ClearPedTasks(ped)

    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, false)

    TaskWanderStandard(ped, 1.0, 10)
    SetPedKeepTask(ped, true)

    Assigned[ped] = true
    Returning[ped] = nil
end

------------------------------------------------------------
-- WALK BACK TO ZONE (SERVER REQUEST)
------------------------------------------------------------
local function walkBackToZone(ped, zoneId)
    if Returning[ped] then return end
    if not ensureControl(ped) then return end

    local zone
    for _, z in ipairs(Config.Zones) do
        if z.id == zoneId then
            zone = z
            break
        end
    end
    if not zone then return end

    ClearPedTasks(ped)

    TaskGoStraightToCoord(
        ped,
        zone.coords.x,
        zone.coords.y,
        zone.coords.z,
        1.0,
        -1,
        0.0,
        0.0
    )

    SetPedKeepTask(ped, true)
    Returning[ped] = true
    Assigned[ped]  = nil
end

------------------------------------------------------------
-- MAIN LOOP (SERVER-DRIVEN BEHAVIOR)
------------------------------------------------------------
CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())

        for _, ped in ipairs(GetGamePool("CPed")) do
            if DoesEntityExist(ped)
            and not IsPedDeadOrDying(ped)
            and Entity(ped).state
            and Entity(ped).state.aiRole == "roaming" then

                local zoneId = Entity(ped).state.zoneId
                if not zoneId then goto continue end

                local dist = #(GetEntityCoords(ped) - playerPos)

                -- SERVER REQUEST: RETURN TO ZONE
                if Entity(ped).state.returnToZone then
                    walkBackToZone(ped, zoneId)
                    goto continue
                end

                -- NORMAL WANDER (ONLY WHEN STREAMED)
                if dist < STREAM_DIST and not ActiveWars[zoneId] then
                    assignRoam(ped)
                end
            else
                Assigned[ped]  = nil
                Returning[ped] = nil
            end

            ::continue::
        end

        Wait(2000)
    end
end)

------------------------------------------------------------
-- AMBIENT POPULATION SUPPRESSION (CRITICAL)
------------------------------------------------------------
CreateThread(function()
    while true do
        SetPedDensityMultiplierThisFrame(0.0)
        SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        Wait(0)
    end
end)

------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    Assigned  = {}
    Returning = {}
end)
