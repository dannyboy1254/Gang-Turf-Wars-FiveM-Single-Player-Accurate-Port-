print("^1[SERVER] GangWars main.lua LOADED^7")

------------------------------------------------------------
-- GANG COMMANDS
------------------------------------------------------------

RegisterCommand("creategang", function(src, args)
    if not args[1] then
        TriggerClientEvent("gangwars:notify", src, "Usage: /creategang [name]")
        return
    end

    local name = table.concat(args, " ")
    local gangId = GangsAPI.createGang(src, name)

    if not gangId then
        TriggerClientEvent("gangwars:notify", src, "Gang creation failed.")
        return
    end

    TriggerClientEvent(
        "gangwars:notify",
        -1,
        ("A new gang has been formed: %s (ID %s)"):format(name, gangId)
    )
end)

RegisterCommand("joingang", function(src, args)
    local id = tonumber(args[1])
    if not id or not Gangs[id] then
        TriggerClientEvent("gangwars:notify", src, "Invalid gang ID.")
        return
    end

    GangsAPI.addPlayer(src, id)

    TriggerClientEvent(
        "gangwars:notify",
        src,
        ("You joined gang: %s"):format(Gangs[id].name)
    )
end)

RegisterCommand("leavegang", function(src)
    GangsAPI.removePlayer(src)
    TriggerClientEvent("gangwars:notify", src, "You left your gang.")
end)

------------------------------------------------------------
-- CLIENT → SERVER SYNC
------------------------------------------------------------

RegisterNetEvent("gangwars:requestMyGang", function()
    local src = source
    TriggerClientEvent("gangwars:setMyGang", src, GangsAPI.getGang(src))
end)

RegisterNetEvent("gangwars:requestGangs", function()
    TriggerClientEvent("gangwars:syncGangs", source, Gangs)
end)

RegisterNetEvent("gangwars:requestZones", function()
    TriggerClientEvent("gangwars:syncZones", source, Zones)
end)

------------------------------------------------------------
-- PLAYER JOIN (SAFE SYNC)
------------------------------------------------------------

AddEventHandler("playerJoining", function()
    local src = source

    SetTimeout(1500, function()
        TriggerClientEvent("gangwars:syncGangs", src, Gangs)
        TriggerClientEvent("gangwars:syncZones", src, Zones)
        TriggerClientEvent("gangwars:setMyGang", src, GangsAPI.getGang(src))
        TriggerClientEvent("gangwars:syncWars", src, Wars or {})
    end)
end)

------------------------------------------------------------
-- ZONE CAPTURE
------------------------------------------------------------

RegisterNetEvent("gangwars:captureZone", function(zoneId)
    local src = source
    local gangId = GangsAPI.getGang(src)
    if not gangId then
        TriggerClientEvent("gangwars:notify", src, "Join a gang first.")
        return
    end

    local zone = ZonesAPI.getZone(zoneId)
    if not zone then
        TriggerClientEvent("gangwars:notify", src, "Invalid zone.")
        return
    end

    ZonesAPI.setOwner(zoneId, gangId)

    TriggerClientEvent(
        "gangwars:notify",
        -1,
        ("Gang %s captured turf %s"):format(gangId, zoneId)
    )
end)

------------------------------------------------------------
-- WAR EVENT RELAY (🔥 CRITICAL)
------------------------------------------------------------
-- These forward war events to roaming systems

RegisterNetEvent("gangwars:internalWarStarted", function(zoneId)
    TriggerEvent("gangwars:warStarted", zoneId)
end)

RegisterNetEvent("gangwars:internalWarEnded", function(zoneId)
    TriggerEvent("gangwars:warEnded", zoneId)
end)

------------------------------------------------------------
-- BACKUP VEHICLE (TEST / FOUNDATION)
------------------------------------------------------------

RegisterNetEvent("gangwars:callBackupVehicle", function()
    local src = source
    local ped = GetPlayerPed(src)
    if not ped then return end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicle = CreateVehicle(
        joaat("baller"),
        coords.x + 6.0,
        coords.y,
        coords.z,
        heading,
        true,
        true
    )

    if not DoesEntityExist(vehicle) then return end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(netId, true)
    SetEntityAsMissionEntity(vehicle, true, true)

    TriggerClientEvent("gangwars:setupBackupVehicle", src, netId)

    print("[GangWars] Backup vehicle created for", src)
end)