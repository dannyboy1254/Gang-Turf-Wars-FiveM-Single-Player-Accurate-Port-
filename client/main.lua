CreateThread(function()
    Wait(1500) -- allow network + scripts to load

    TriggerServerEvent("gangwars:requestZones")
    TriggerServerEvent("gangwars:requestGangs")
    TriggerServerEvent("gangwars:requestMyGang")
	TriggerServerEvent("gangwars:requestRoamingVehicles")
end)

------------------------------------------------------------
-- BACKUP VEHICLE SETUP (CLIENT)
------------------------------------------------------------

RegisterNetEvent("gangwars:setupBackupVehicle", function(netId)
    print("[TEST] setupBackupVehicle fired, netId =", netId)

    local timeout = GetGameTimer() + 5000
    local vehicle = NetToVeh(netId)

    while not DoesEntityExist(vehicle) and GetGameTimer() < timeout do
        Wait(50)
        vehicle = NetToVeh(netId)
    end

    print("[TEST] vehicle exists:", DoesEntityExist(vehicle))

    if not DoesEntityExist(vehicle) then
        print("[TEST] FAIL: vehicle never replicated")
        return
    end

    -- Force control
    while not NetworkHasControlOfEntity(vehicle) do
        NetworkRequestControlOfEntity(vehicle)
        Wait(50)
    end

    print("[TEST] have network control of vehicle")

    -- Load model
    local pedModel = joaat("g_m_y_famfor_01")
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end

    print("[TEST] ped model loaded")

    ------------------------------------------------------------
    -- TEST 1: Spawn AI OUTSIDE the vehicle (guaranteed)
    ------------------------------------------------------------
    local playerCoords = GetEntityCoords(PlayerPedId())

    local testPed = CreatePed(
        4,
        pedModel,
        playerCoords.x + 2.0,
        playerCoords.y,
        playerCoords.z,
        0.0,
        false,
        false
    )

    print("[TEST] standalone AI spawned:", DoesEntityExist(testPed))

    if DoesEntityExist(testPed) then
        GiveWeaponToPed(testPed, joaat("WEAPON_PISTOL"), 120, false, true)
        TaskCombatHatedTargetsAroundPed(testPed, 50.0)
    end

    ------------------------------------------------------------
    -- TEST 2: Try AI inside vehicle
    ------------------------------------------------------------
    for seat = -1, 1 do
        local ai = CreatePedInsideVehicle(
            vehicle,
            4,
            pedModel,
            seat,
            true,
            true
        )

        print("[TEST] AI seat", seat, "exists:", DoesEntityExist(ai))
    end

    SetModelAsNoLongerNeeded(pedModel)
end)



