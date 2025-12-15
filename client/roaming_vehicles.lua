print("^2[GangWars]^7 Vehicle roaming client loaded (SERVER-OWNED, FINAL)")

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local WANDER_SPEED = 14.0
local DRIVE_STYLE  = 786603 -- defensive / obey traffic
local PROCESS_INTERVAL = 2000

------------------------------------------------------------
-- WAIT FOR CONFIG
------------------------------------------------------------
CreateThread(function()
    while not Config or not Config.Zones or not Config.GangData do
        Wait(500)
    end
    print("^2[GangWars]^7 Vehicle roaming config ready")
end)

------------------------------------------------------------
-- ZONE LOOKUP
------------------------------------------------------------
local function getZoneById(zoneId)
    for _, z in ipairs(Config.Zones) do
        if z.id == zoneId then return z end
    end
end

------------------------------------------------------------
-- DRIVER SETUP (SAFE, IDPOTENT)
------------------------------------------------------------
local function ensureDriver(veh, gangId, zoneId)
    if not DoesEntityExist(veh) then return end
    if GetPedInVehicleSeat(veh, -1) ~= 0 then return end
    if not NetworkHasControlOfEntity(veh) then return end

    local gd = Config.GangData[gangId]
    if not gd or not gd.peds or #gd.peds == 0 then return end

    local model = gd.peds[math.random(#gd.peds)]
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePedInsideVehicle(veh, 4, model, -1, true, true)
    if not DoesEntityExist(ped) then return end

    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 17, false)
    SetPedCombatAttributes(ped, 46, false)

    SetPedSeeingRange(ped, 0.0)
    SetPedHearingRange(ped, 0.0)
    SetPedAlertness(ped, 0)

    SetDriverAbility(ped, 1.0)
    SetDriverAggressiveness(ped, 0.0)

    TaskVehicleDriveWander(ped, veh, WANDER_SPEED, DRIVE_STYLE)

    Entity(ped).state:set("gangId", gangId, true)
    Entity(ped).state:set("zoneId", zoneId, true)
    Entity(ped).state:set("aiRole", "roaming_vehicle_driver", true)
end

------------------------------------------------------------
-- PASSENGER FILL (OPTIONAL, SP STYLE)
------------------------------------------------------------
local function fillPassengers(veh, gangId, zoneId)
    if not DoesEntityExist(veh) then return end
    if not NetworkHasControlOfEntity(veh) then return end

    local gd = Config.GangData[gangId]
    if not gd or not gd.peds or #gd.peds == 0 then return end

    for seat = 0, 2 do
        if IsVehicleSeatFree(veh, seat) and math.random() < 0.6 then
            local model = gd.peds[math.random(#gd.peds)]
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end

            local ped = CreatePedInsideVehicle(veh, 4, model, seat, true, true)
            if DoesEntityExist(ped) then
                SetBlockingOfNonTemporaryEvents(ped, true)
                SetPedSeeingRange(ped, 0.0)
                SetPedHearingRange(ped, 0.0)
                SetPedAlertness(ped, 0)

                Entity(ped).state:set("gangId", gangId, true)
                Entity(ped).state:set("zoneId", zoneId, true)
                Entity(ped).state:set("aiRole", "roaming_vehicle_passenger", true)
            end
        end
    end
end

------------------------------------------------------------
-- MAIN CONTROL LOOP
------------------------------------------------------------
CreateThread(function()
    while true do
        for _, veh in ipairs(GetGamePool("CVehicle")) do
            if DoesEntityExist(veh) then
                local state = Entity(veh).state
                if state and state.aiRole == "roaming_vehicle" then
                    local gangId = state.gangId
                    local zoneId = state.zoneId

                    if gangId and zoneId then
                        ensureDriver(veh, gangId, zoneId)
                        fillPassengers(veh, gangId, zoneId)
                    end
                end
            end
        end

        Wait(PROCESS_INTERVAL)
    end
end)

------------------------------------------------------------
-- MAINTAIN DRIVE TASK (ANTI-IDLE)
------------------------------------------------------------
CreateThread(function()
    while true do
        for _, veh in ipairs(GetGamePool("CVehicle")) do
            if DoesEntityExist(veh) then
                local state = Entity(veh).state
                if state and state.aiRole == "roaming_vehicle" then
                    local driver = GetPedInVehicleSeat(veh, -1)
                    if DoesEntityExist(driver) then
                        if GetScriptTaskStatus(driver, `SCRIPT_TASK_VEHICLE_DRIVE_WANDER`) ~= 1 then
                            ClearPedTasks(driver)
                            TaskVehicleDriveWander(driver, veh, WANDER_SPEED, DRIVE_STYLE)
                        end
                    end
                end
            end
        end
        Wait(5000)
    end
end)

------------------------------------------------------------
-- BACKUP / ESCORT SUPPORT
------------------------------------------------------------
RegisterNetEvent("gangwars:vehicleBackup", function(vehicle)
    if not DoesEntityExist(vehicle) then return end
    if not NetworkHasControlOfEntity(vehicle) then return end

    local driver = GetPedInVehicleSeat(vehicle, -1)
    if not DoesEntityExist(driver) then return end

    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, false) then
        TaskVehicleEscort(
            driver,
            vehicle,
            GetVehiclePedIsIn(playerPed, false),
            -1,
            20.0,
            DRIVE_STYLE,
            5.0,
            10.0,
            5.0
        )
    else
        TaskVehicleDriveToCoord(
            driver,
            vehicle,
            GetEntityCoords(playerPed),
            18.0,
            0,
            GetEntityModel(vehicle),
            DRIVE_STYLE,
            2.0,
            true
        )
    end
end)
