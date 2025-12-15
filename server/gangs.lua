-- ============================================================
-- SERVER GANGS (AUTHORITATIVE CORE SYSTEM – JSON PERSISTENCE)
-- ============================================================

print("^2[GangWars]^7 gangs.lua loaded")

Gangs = {}        -- gangId -> gang data
Players = {}      -- src -> { gangId }
GangsAPI = {}

local gangFile = "data/gangs.json"

------------------------------------------------------------
-- DEFAULT STRUCTURES
------------------------------------------------------------

local function defaultUpgrades()
    return {
        health = 0,
        armor = 0,
        accuracy = 0,
        backup = 0
    }
end

local function defaultWeapons()
    return {
        pistol = true,
        smg = false,
        rifle = false,
        shotgun = false
    }
end

local function defaultVehicles()
    return {
        primo = true
    }
end

local function defaultCarColors()
    return {
        primary = 0,
        secondary = 0
    }
end

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
end

local function nextGangId()
    local max = 0
    for id in pairs(Gangs) do
        if id > max then max = id end
    end
    return max + 1
end

local function syncGangs(target)
    TriggerClientEvent("gangwars:syncGangs", target or -1, Gangs)
end

------------------------------------------------------------
-- LOAD / SAVE
------------------------------------------------------------

local function saveGangs()
    Persistence.saveFile(gangFile, Gangs)
end

CreateThread(function()
    local saved = Persistence.loadFile(gangFile)
    if saved then
        Gangs = saved
    end

    local count = 0
    for _ in pairs(Gangs) do count = count + 1 end
    print(("[GangWars] Loaded %d gangs"):format(count))
end)

------------------------------------------------------------
-- API
------------------------------------------------------------

function GangsAPI.getGang(src)
    return Players[src] and Players[src].gangId
end

function GangsAPI.getGangData(gangId)
    return Gangs[gangId]
end

function GangsAPI.createGang(src, name)
    local identifier = getIdentifier(src)
    if not identifier then return nil end

    -- prevent duplicate gang membership
    for _, gang in pairs(Gangs) do
        if gang.members[identifier] then
            return nil
        end
    end

    local gangId = nextGangId()

    Gangs[gangId] = {
        id = gangId,
        name = name,
        owner = identifier,

        members = {
            [identifier] = {
                rank = "leader",
                joined = os.time()
            }
        },

        upgrades = defaultUpgrades(),
        weapons = defaultWeapons(),
        vehicles = defaultVehicles(),
        carColors = defaultCarColors(),
        blipColor = Config.GangColors[gangId] and Config.GangColors[gangId][1] or 0
    }

    Players[src] = { gangId = gangId }

    saveGangs()
    syncGangs()

    return gangId
end

function GangsAPI.renameGang(src, newName)
    local gangId = GangsAPI.getGang(src)
    if not gangId or not Gangs[gangId] then return false end

    Gangs[gangId].name = newName
    saveGangs()
    syncGangs()
    return true
end

function GangsAPI.addPlayer(src, gangId)
    local identifier = getIdentifier(src)
    if not identifier or not Gangs[gangId] then return end

    Gangs[gangId].members[identifier] = {
        rank = "soldier",
        joined = os.time()
    }

    Players[src] = { gangId = gangId }
    saveGangs()
    syncGangs()
end

function GangsAPI.removePlayer(src)
    local identifier = getIdentifier(src)
    local gangId = GangsAPI.getGang(src)
    if not identifier or not gangId or not Gangs[gangId] then return end

    Gangs[gangId].members[identifier] = nil
    Players[src] = nil

    saveGangs()
    syncGangs()
end

------------------------------------------------------------
-- PLAYER TRACKING
------------------------------------------------------------

AddEventHandler("playerDropped", function()
    Players[source] = nil
end)

RegisterNetEvent("gangwars:playerLoaded", function()
    local src = source
    local identifier = getIdentifier(src)
    if not identifier then return end

    for gangId, gang in pairs(Gangs) do
        if gang.members[identifier] then
            Players[src] = { gangId = gangId }
            TriggerClientEvent("gangwars:setMyGang", src, gangId)
            return
        end
    end
end)

------------------------------------------------------------
-- UPGRADES
------------------------------------------------------------

local function upgrade(gangId, key, max)
    local g = Gangs[gangId]
    if not g or g.upgrades[key] >= max then return end

    g.upgrades[key] = g.upgrades[key] + 1
    saveGangs()
    syncGangs()
end

RegisterNetEvent("gangwars:upgradeMemberHealth", function()
    upgrade(GangsAPI.getGang(source), "health", 5)
end)

RegisterNetEvent("gangwars:upgradeMemberArmor", function()
    upgrade(GangsAPI.getGang(source), "armor", 5)
end)

RegisterNetEvent("gangwars:upgradeMemberAccuracy", function()
    upgrade(GangsAPI.getGang(source), "accuracy", 5)
end)

RegisterNetEvent("gangwars:upgradeBackupSize", function()
    upgrade(GangsAPI.getGang(source), "backup", 3)
end)

------------------------------------------------------------
-- WEAPON / VEHICLE UNLOCKS
------------------------------------------------------------

RegisterNetEvent("gangwars:unlockWeapon", function(weapon)
    local g = Gangs[GangsAPI.getGang(source)]
    if not g then return end
    g.weapons[weapon] = true
    saveGangs()
    syncGangs()
end)

RegisterNetEvent("gangwars:unlockVehicle", function(model)
    local g = Gangs[GangsAPI.getGang(source)]
    if not g then return end
    g.vehicles[model] = true
    saveGangs()
    syncGangs()
end)

------------------------------------------------------------
-- COLORS
------------------------------------------------------------

RegisterNetEvent("gangwars:setBlipColor", function(color)
    local g = Gangs[GangsAPI.getGang(source)]
    if not g then return end
    g.blipColor = color
    saveGangs()
    syncGangs()
end)

RegisterNetEvent("gangwars:setCarPrimaryColor", function(color)
    local g = Gangs[GangsAPI.getGang(source)]
    if not g then return end
    g.carColors.primary = color
    saveGangs()
    syncGangs()
end)

RegisterNetEvent("gangwars:setCarSecondaryColor", function(color)
    local g = Gangs[GangsAPI.getGang(source)]
    if not g then return end
    g.carColors.secondary = color
    saveGangs()
    syncGangs()
end)

------------------------------------------------------------
-- CLIENT REQUEST
------------------------------------------------------------

RegisterNetEvent("gangwars:requestGangs", function()
    syncGangs(source)
end)
