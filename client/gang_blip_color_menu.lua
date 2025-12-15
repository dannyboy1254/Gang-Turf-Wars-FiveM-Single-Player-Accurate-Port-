------------------------------------------------------------
-- GANG BLIP COLOR SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.blip_colors = {
    title = "GANG BLIP COLOR",
    items = {
        { label = "Red", event = "gangwars:setBlipRed" },
        { label = "Blue", event = "gangwars:setBlipBlue" },
        { label = "Green", event = "gangwars:setBlipGreen" },
        { label = "Back", back = true },
    }
}
