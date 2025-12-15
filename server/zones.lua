-- ============================================================
-- SERVER ZONES (AUTHORITATIVE OWNERSHIP + PERSISTENCE)
-- ============================================================

Zones = {}
ZonesAPI = {}

local zoneFile = "data/zones.json"

------------------------------------------------------------
-- INIT
------------------------------------------------------------

CreateThread(function()
    -- Initialize from SP Config (STATIC DEFINITIONS)
    for _, z in ipairs(Config.Zones) do
        Zones[z.id] = {
            id = z.id,
            ownerGangId = z.ownerGangId or nil,
            baseValue = z.baseValue or 0
        }
    end

    -- Load persisted ownership
    local saved = Persistence.loadFile(zoneFile)
    if saved then
        for zoneId, data in pairs(saved) do
            if Zones[zoneId] then
                Zones[zoneId].ownerGangId = data.ownerGangId
                Zones[zoneId].baseValue = data.baseValue or Zones[zoneId].baseValue
            end
        end
    end

    print(("[GangWars] Zones initialized (%d zones)"):format(#Config.Zones))
end)

------------------------------------------------------------
-- INTERNAL HELPERS
------------------------------------------------------------

local function saveZones()
    Persistence.saveFile(zoneFile, Zones)
end

local function syncZones(target)
    if target then
        TriggerClientEvent("gangwars:syncZones", target, Zones)
    else
        TriggerClientEvent("gangwars:syncZones", -1, Zones)
    end
end

------------------------------------------------------------
-- ZONES API
------------------------------------------------------------

function ZonesAPI.getZone(zoneId)
    return Zones[zoneId]
end

function ZonesAPI.setOwner(zoneId, gangId)
    if not Zones[zoneId] then return end

    -- 🔒 SP ACCURACY: prevent ownership change during war
    if Wars and Wars[zoneId] then return end

    Zones[zoneId].ownerGangId = gangId
    saveZones()
    syncZones()

    -- Inform roaming systems
    TriggerEvent("gangwars:zoneOwnerChanged", zoneId)
end

------------------------------------------------------------
-- CLIENT REQUESTS
------------------------------------------------------------

RegisterNetEvent("gangwars:requestZones", function()
    syncZones(source)
end)

------------------------------------------------------------
-- INCOME LOOP (SERVER ONLY)
------------------------------------------------------------

CreateThread(function()
    while true do
        Wait(Config.IncomeIntervalMinutes * 60000)

        for zoneId, zone in pairs(Zones) do
            if zone.ownerGangId then
                for src, pdata in pairs(Players or {}) do
                    if pdata.gangId == zone.ownerGangId then
                        TriggerClientEvent(
                            "gangwars:notify",
                            src,
                            ("Your gang earned $%d from zone %s")
                                :format(zone.baseValue, zoneId)
                        )
                    end
                end
            end
        end
    end
end)
