------------------------------------------------------------
-- MOD OPTIONS SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.mod = {
    title = "MOD OPTIONS",
    items = {
        { label = "Toggle AI Roaming", event = "gangwars:toggleRoamingAI" },
        { label = "Toggle Gang Wars", event = "gangwars:toggleWars" },
        { label = "Reset Gang Data", event = "gangwars:resetGangData" },
        { label = "Back", back = true },
    }
}
