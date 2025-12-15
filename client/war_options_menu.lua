------------------------------------------------------------
-- WAR OPTIONS SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.war = {
    title = "WAR OPTIONS",
    items = {
        { label = "Skip Current War", event = "gangwars:skipCurrentWar" },
        { label = "Show Reinforcement Counts", event = "gangwars:toggleReinforcementCounts" },
        { label = "Lock War Reinforcement Count", event = "gangwars:toggleLockWar" },
        { label = "War Potential Spawns...", go = "war_spawns" },
        { label = "Back", back = true },
    }
}
