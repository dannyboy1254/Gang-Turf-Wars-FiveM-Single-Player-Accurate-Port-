-- ============================================================
-- SERVER MOD OPTIONS (GLOBAL TOGGLE SYSTEM)
-- ============================================================

ModOptions = {}

local optionsFile = "data/mod_options.json"

------------------------------------------------------------
-- DEFAULTS (SAFE + SP-LIKE)
------------------------------------------------------------

local DEFAULT_OPTIONS = {
    ambientSpawning = true,        -- roaming AI on/off
    showReinforcements = true,     -- war reinforcement numbers
    lockWars = false               -- prevent starting new wars
}

------------------------------------------------------------
-- LOAD / SAVE
------------------------------------------------------------

local function saveOptions()
    Persistence.saveFile(optionsFile, ModOptions)
end

local function loadOptions()
    local saved = Persistence.loadFile(optionsFile)
    if saved then
        ModOptions = saved
    else
        ModOptions = DEFAULT_OPTIONS
        saveOptions()
    end
end

------------------------------------------------------------
-- SYNC
------------------------------------------------------------

local function syncOptions(target)
    if target then
        TriggerClientEvent("gangwars:syncModOptions", target, ModOptions)
    else
        TriggerClientEvent("gangwars:syncModOptions", -1, ModOptions)
    end
end

------------------------------------------------------------
-- INIT
------------------------------------------------------------

CreateThread(function()
    loadOptions()
    print("^2[GangWars]^7 Mod options loaded")
end)

------------------------------------------------------------
-- CLIENT REQUEST
------------------------------------------------------------

RegisterNetEvent("gangwars:requestModOptions", function()
    syncOptions(source)
end)

------------------------------------------------------------
-- MENU → SERVER EVENTS
------------------------------------------------------------

-- Toggle ambient roaming AI
RegisterNetEvent("gangwars:menu_toggleAmbientSpawning", function()
    ModOptions.ambientSpawning = not ModOptions.ambientSpawning
    saveOptions()
    syncOptions()

    print("[GangWars] Ambient spawning:", ModOptions.ambientSpawning)
end)

-- Toggle reinforcement count visibility
RegisterNetEvent("gangwars:menu_toggleReinforcementCounts", function()
    ModOptions.showReinforcements = not ModOptions.showReinforcements
    saveOptions()
    syncOptions()

    print("[GangWars] Reinforcement counts:", ModOptions.showReinforcements)
end)

-- Lock / unlock wars
RegisterNetEvent("gangwars:menu_toggleLockWar", function()
    ModOptions.lockWars = not ModOptions.lockWars
    saveOptions()
    syncOptions()

    print("[GangWars] War lock:", ModOptions.lockWars)
end)

-- Reload options from disk (admin-safe)
RegisterNetEvent("gangwars:menu_reloadOptions", function()
    loadOptions()
    syncOptions()

    print("[GangWars] Mod options reloaded from disk")
end)
