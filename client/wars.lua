------------------------------------------------------------
-- CLIENT WAR STATE + HUD + AI BRIDGE
------------------------------------------------------------

local WarStates = {}        -- zoneId -> war table
local GangsForWars = {}    -- gang cache for names
local myServerId = GetPlayerServerId(PlayerId())

------------------------------------------------------------
-- RECEIVE GANG DATA (for HUD names)
------------------------------------------------------------
RegisterNetEvent("gangwars:syncGangs", function(gangs)
    GangsForWars = gangs or {}
end)

------------------------------------------------------------
-- RECEIVE WAR STATE FROM SERVER
------------------------------------------------------------
RegisterNetEvent("gangwars:syncWarState", function(zoneId, war)
    WarStates[zoneId] = war

    print("^2[WAR]^7 syncWarState received for zone", zoneId)

    -- Inform AI system (AI file MUST define this)
    if AI_OnWarSync then
        AI_OnWarSync(zoneId, war)
    else
        print("^1[WAR]^7 AI_OnWarSync not loaded")
    end
end)

------------------------------------------------------------
-- WAR ENDED
------------------------------------------------------------
RegisterNetEvent("gangwars:warEnded", function(zoneId)
    WarStates[zoneId] = nil

    print("^3[WAR]^7 warEnded for zone", zoneId)

    if AI_OnWarEnd then
        AI_OnWarEnd(zoneId)
    end
end)

------------------------------------------------------------
-- ZONE LOOKUP
------------------------------------------------------------
local function getZoneById(id)
    for _, z in ipairs(Config.Zones) do
        if z.id == id then
            return z
        end
    end
    return nil
end

------------------------------------------------------------
-- PLAYER INSIDE ZONE CHECK
------------------------------------------------------------
local function isPlayerInsideZone(zoneId)
    local zone = getZoneById(zoneId)
    if not zone then return false end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    return #(pos - zone.coords) <= zone.radius
end

------------------------------------------------------------
-- HUD DRAW LOOP
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)

        for zoneId, war in pairs(WarStates) do
            if war.active and isPlayerInsideZone(zoneId) then

                local attackerName =
                    (GangsForWars[war.attackerGang] and GangsForWars[war.attackerGang].name)
                    or ("Gang "..tostring(war.attackerGang))

                local defenderName =
                    (GangsForWars[war.defenderGang] and GangsForWars[war.defenderGang].name)
                    or ("Gang "..tostring(war.defenderGang))

                ------------------------------------------------
                -- HEADER
                ------------------------------------------------
                SetTextFont(4)
                SetTextScale(0.55, 0.55)
                SetTextCentre(true)
                SetTextOutline()

                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName("~w~~h~AI GANG WAR~h~")
                EndTextCommandDisplayText(0.5, 0.05)

                ------------------------------------------------
                -- COUNTS
                ------------------------------------------------
                local hudText = string.format(
                    "~b~%s: %d~w~     ~r~%s: %d",
                    defenderName,
                    war.defenderTickets or 0,
                    attackerName,
                    war.attackerTickets or 0
                )

                BeginTextCommandDisplayText("STRING")
                AddTextComponentSubstringPlayerName(hudText)
                EndTextCommandDisplayText(0.5, 0.095)

                break
            end
        end
    end
end)
