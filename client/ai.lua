print("^2[GangWars]^7 Client AI controller loaded")

local ActiveAI = {}

------------------------------------------------------------
-- WAIT FOR PED
------------------------------------------------------------
local function waitForPed(netId)
    for _ = 1, 40 do
        local ped = NetToPed(netId)
        if ped ~= 0 and DoesEntityExist(ped) then
            return ped
        end
        Wait(100)
    end
end

------------------------------------------------------------
-- SETUP WAR AI
------------------------------------------------------------
RegisterNetEvent("gangwars:setupWarAI", function(zoneId, data)
    ActiveAI[zoneId] = { attackers = {}, defenders = {} }

    for _, id in ipairs(data.attackers or {}) do
        local ped = waitForPed(id)
        if ped then table.insert(ActiveAI[zoneId].attackers, ped) end
    end

    for _, id in ipairs(data.defenders or {}) do
        local ped = waitForPed(id)
        if ped then table.insert(ActiveAI[zoneId].defenders, ped) end
    end
end)

RegisterNetEvent("gangwars:cleanupWarAI", function(zoneId)
    ActiveAI[zoneId] = nil
end)

------------------------------------------------------------
-- COMBAT LOOP (WAR ONLY)
------------------------------------------------------------
CreateThread(function()
    while true do
        for _, data in pairs(ActiveAI) do
            for _, a in ipairs(data.attackers) do
                if DoesEntityExist(a) then
                    local t = data.defenders[math.random(#data.defenders)]
                    if t and DoesEntityExist(t) then
                        TaskCombatPed(a, t, 0, 16)
                    end
                end
            end
        end
        Wait(1200)
    end
end)

local Following = {}

RegisterNetEvent("gangwars:toggleFollow", function(ped)
    if not DoesEntityExist(ped) then return end

    if Following[ped] then
        ClearPedTasks(ped)
        TaskWanderStandard(ped, 1.0, 10)
        Following[ped] = nil
        return
    end

    Following[ped] = true
    TaskFollowToOffsetOfEntity(
        ped,
        PlayerPedId(),
        0.0, -1.5, 0.0,
        2.0,
        -1,
        2.0,
        true
    )
end)

RegisterNetEvent("gangwars:controlNearestMember", function()
    local playerPed = PlayerPedId()
    local peds = GetGamePool("CPed")
    local closest, dist

    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped)
        and Entity(ped).state
        and Entity(ped).state.gangId
        and not IsPedDeadOrDying(ped) then
            local d = #(GetEntityCoords(ped) - GetEntityCoords(playerPed))
            if not dist or d < dist then
                dist = d
                closest = ped
            end
        end
    end

    if closest then
        TriggerEvent("gangwars:takeControl", closest)
    end
end)
