------------------------------------------------------------
-- GANG UPGRADES SUBMENU
------------------------------------------------------------
MENUS = MENUS or {}

MENUS.upgrades = {
    title = "GANG UPGRADES",
    items = {
        { label = "Upgrade Member Health", event = "gangwars:upgradeMemberHealth" },
        { label = "Upgrade Member Armor", event = "gangwars:upgradeMemberArmor" },
        { label = "Upgrade Member Accuracy", event = "gangwars:upgradeMemberAccuracy" },
        { label = "Increase Backup Size", event = "gangwars:upgradeBackupSize" },
        { label = "Improve Reinforcement Rate", event = "gangwars:upgradeReinforcements" },
        { label = "Back", back = true },
    }
}
