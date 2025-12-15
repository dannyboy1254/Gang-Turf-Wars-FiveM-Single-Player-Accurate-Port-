------------------------------------------------------------
-- WAR POTENTIAL SPAWNS SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.war_spawns = {
    title = "WAR POTENTIAL SPAWNS",
    items = {
        { label = "Show Spawns on Map", event = "gangwars:toggleSpawnBlips" },
        { label = "Add New Spawn Here", event = "gangwars:addWarSpawnHere" },
        { label = "Remove Nearby Spawn", event = "gangwars:removeWarSpawnNearby" },
        { label = "Back", back = true },
    }
}
