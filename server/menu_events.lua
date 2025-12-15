print("^2[GangWars]^7 menu_events loaded")

----------------------------------------------------------------
-- BACKUP & SUPPORT (MENU → SERVER)
----------------------------------------------------------------

RegisterNetEvent("gangwars:callBackupVehicle", function()
    local src = source
    print("[MENU] Call backup vehicle by", src)

    -- TEMP TEST ACTION (proves menu works)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    local model = joaat("chino")

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local veh = CreateVehicle(
        model,
        coords.x + 4.0,
        coords.y,
        coords.z,
        GetEntityHeading(ped),
        true,
        true
    )

    SetVehicleOnGroundProperly(veh)
end)

RegisterNetEvent("gangwars:callParaMember", function()
    local src = source
    print("[MENU] Parachuting member requested by", src)
end)

RegisterNetEvent("gangwars:openEnemyGangPicker", function()
    local src = source
    TriggerClientEvent("gangwars:notify", src, "Enemy gang picker coming next")
end)

----------------------------------------------------------------
-- WAR OPTIONS
----------------------------------------------------------------

RegisterNetEvent("gangwars:skipCurrentWar", function()
    print("[MENU] Skip war requested by", source)
end)

RegisterNetEvent("gangwars:toggleReinforcementCounts", function()
    print("[MENU] Toggle reinforcement counts")
end)

RegisterNetEvent("gangwars:toggleLockWar", function()
    print("[MENU] Toggle lock war reinforcement")
end)

RegisterNetEvent("gangwars:addWarSpawnHere", function()
    print("[MENU] Add war spawn here by", source)
end)

RegisterNetEvent("gangwars:removeWarSpawnNearby", function()
    print("[MENU] Remove war spawn by", source)
end)

----------------------------------------------------------------
-- GANG CUSTOMIZATION
----------------------------------------------------------------

RegisterNetEvent("gangwars:openPickGangMenu", function()
    TriggerClientEvent("gangwars:notify", source, "Pick-A-Gang menu coming next")
end)

RegisterNetEvent("gangwars:createAIGang", function()
    print("[MENU] Create AI gang by", source)
end)

RegisterNetEvent("gangwars:confirmDeleteGang", function()
    TriggerClientEvent("gangwars:notify", source, "Delete confirmation coming next")
end)

----------------------------------------------------------------
-- MOD OPTIONS
----------------------------------------------------------------

RegisterNetEvent("gangwars:toggleRoamingAI", function()
    print("[MENU] Toggle AI roaming")
end)

RegisterNetEvent("gangwars:toggleWars", function()
    print("[MENU] Toggle wars")
end)

RegisterNetEvent("gangwars:resetGangData", function()
    print("[MENU] Reset gang data")
end)
