MENUS = MENUS or {}

MENUS.customize = {
    title = "GANG CUSTOMIZATION / UPGRADES",
    items = {
        { label = "Select Gang to Edit", event = "gangwars:openPickGangMenu" },

        { label = "Rename Gang", event = "gangwars:renameGang" },

        { label = "Gang Upgrades...", go = "upgrades" },
        { label = "Gang Weapons...", go = "weapons" },
        { label = "Gang Car Colors...", go = "car_colors" },
        { label = "Gang Blip Color...", go = "blip_colors" },

        { label = "Delete This Gang", event = "gangwars:confirmDeleteGang" },
        { label = "Create New AI Gang", event = "gangwars:createAIGang" },

        { label = "Back", back = true },
    }
}
