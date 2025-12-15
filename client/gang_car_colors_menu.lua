------------------------------------------------------------
-- GANG CAR COLORS SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.car_colors = {
    title = "GANG CAR COLORS",
    items = {
        { label = "Primary Color", event = "gangwars:setCarPrimaryColor" },
        { label = "Secondary Color", event = "gangwars:setCarSecondaryColor" },
        { label = "Back", back = true },
    }
}
