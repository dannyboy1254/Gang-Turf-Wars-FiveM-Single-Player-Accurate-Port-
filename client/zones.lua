----------------------------------------------------------------
-- ZONE STATE SYNC (NO LEGACY UI)
-- Clean version for RageUI + Blips only
----------------------------------------------------------------

local Zones = {}
local Gangs = {}
local MyGang = nil
local WarStates = {}

----------------------------------------------------------------
-- SYNC EVENTS
----------------------------------------------------------------

RegisterNetEvent("gangwars:syncZones", function(z)
    Zones = z or {}
end)

RegisterNetEvent("gangwars:syncGangs", function(g)
    Gangs = g or {}
end)

RegisterNetEvent("gangwars:setMyGang", function(id)
    MyGang = id
end)

RegisterNetEvent("gangwars:syncWarState", function(zoneId, war)
    WarStates[zoneId] = war
end)

----------------------------------------------------------------
-- OPTIONAL CHAT NOTIFICATIONS (SAFE)
----------------------------------------------------------------

RegisterNetEvent("gangwars:notify", function(msg)
    TriggerEvent("chat:addMessage", {
        args = { "^2[GangWars]^7", msg }
    })
end)

----------------------------------------------------------------
-- NOTES
----------------------------------------------------------------
-- This file intentionally does NOT:
--  - Draw markers
--  - Show floating text
--  - Handle E key input
--  - Start wars client-side
--
-- All interaction is now handled via:
--  - RageUI gang menu
--  - Server-side validation
--  - Blips for visualization
--
-- This eliminates:
--  - UI nil errors
--  - Green debug visuals
--  - Marker artifacts
--  - Conflicting control logic
----------------------------------------------------------------
