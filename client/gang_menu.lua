MENUS = MENUS or {}

print("^2[GANG MENU]^7 Native Gang & Turf menu loaded")

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local menuOpen = false
local selected = 1
local currentMenu = "main"
local menuStack = {}

------------------------------------------------------------
-- POSITION / SIZE
------------------------------------------------------------
local MENU_X = 0.095
local MENU_Y = 0.32

local BOX_WIDTH  = 0.22
local BOX_HEIGHT = 0.30

local TEXT_LEFT_PADDING = 0.015
local TEXT_X = MENU_X + TEXT_LEFT_PADDING
local BOX_CENTER_X = MENU_X + (BOX_WIDTH / 2)

------------------------------------------------------------
-- MAIN MENU ONLY
------------------------------------------------------------
MENUS.main = {
    title = "GANG AND TURF MOD",
    items = {
        { label = "Call Backup Vehicle", event = "gangwars:callBackupVehicle" },
        { label = "Call Parachuting Member", event = "gangwars:callParaMember" },
        { label = "Spawn Enemy Backup Vehicle", event = "gangwars:openEnemyGangPicker" },

        { label = "War Options...", go = "war" },
        { label = "Gang Customization / Upgrades...", go = "customize" },
        { label = "Mod Options...", go = "mod" },
    }
}

------------------------------------------------------------
-- DRAW TEXT
------------------------------------------------------------
local function drawText(x, y, text, selected)
    SetTextFont(4)
    SetTextScale(0.36, 0.36)
    SetTextOutline()

    if selected then
        SetTextColour(0, 140, 255, 255)
    else
        SetTextColour(140, 185, 255, 220)
    end

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 29) and not IsPauseMenuActive() then
            menuOpen = not menuOpen
            selected = 1
            currentMenu = "main"
            menuStack = {}
        end

        if menuOpen then
            local menu = MENUS[currentMenu]
            if not menu then return end
            local items = menu.items

            DrawRect(BOX_CENTER_X, MENU_Y, BOX_WIDTH, BOX_HEIGHT, 8, 18, 45, 190)

            SetTextCentre(true)
            drawText(BOX_CENTER_X, MENU_Y - (BOX_HEIGHT / 2) + 0.030, menu.title, true)
            SetTextCentre(false)

            if IsControlJustPressed(0, 172) then
                selected = math.max(1, selected - 1)
            elseif IsControlJustPressed(0, 173) then
                selected = math.min(#items, selected + 1)
            elseif IsControlJustPressed(0, 191) then
                local item = items[selected]
                if item then
                    if item.go then
                        table.insert(menuStack, currentMenu)
                        currentMenu = item.go
                        selected = 1
                    elseif item.back then
                        currentMenu = table.remove(menuStack) or "main"
                        selected = 1
                    elseif item.event then
                        TriggerServerEvent(item.event)
                    end
                end
            elseif IsControlJustPressed(0, 177) then
                menuOpen = false
            end

            local spacing = 0.028
            local listTop = MENU_Y - ((#items - 1) * spacing / 2) + 0.020

            for i = 1, #items do
                drawText(
                    TEXT_X,
                    listTop + ((i - 1) * spacing),
                    ((i == selected) and "> " or "  ") .. items[i].label,
                    i == selected
                )
            end
        end
    end
end)

RegisterNetEvent("gangwars:openMainMenu", function()
    menuOpen = true
    selected = 1
    currentMenu = "main"
    menuStack = {}
end)


RegisterNetEvent("gangwars:openZoneMenu", function()
    menuOpen = true
    selected = 1
    currentMenu = "zone" -- or whatever your zone menu key is
    menuStack = {}
end)
