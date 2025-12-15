print("^2[GangWars]^7 Controls loaded")

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local lastBlipMode = 1 -- 1 = nearest, 2 = all, 3 = none

------------------------------------------------------------
-- UTILS
------------------------------------------------------------
local function isAiming()
    return IsPlayerFreeAiming(PlayerId())
end

local function getEntityPlayerIsAimingAt()
    local hit, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if hit and entity and DoesEntityExist(entity) then
        return entity
    end
    return nil
end

local function isFriendly(entity)
    if not Entity(entity).state then return false end
    return Entity(entity).state.gangId ~= nil
end

------------------------------------------------------------
-- B : OPEN GANG / MOD MENU
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlJustPressed(0, 29) then -- B
            TriggerEvent("gangwars:openMainMenu")
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- SHIFT + B : CONTEXTUAL REGISTRATION MENU
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlPressed(0, 21) and IsControlJustPressed(0, 29) then -- Shift + B
            local ped = PlayerPedId()

            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                TriggerEvent("gangwars:openVehicleRegistration", veh)
            else
                local target = getEntityPlayerIsAimingAt()
                if target and IsEntityAPed(target) and not IsPedAPlayer(target) then
                    TriggerEvent("gangwars:openMemberRegistration", target)
                else
                    TriggerEvent("gangwars:notify", "No valid target.")
                end
            end
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- N : SHOW CURRENT ZONE INFO
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlJustPressed(0, 249) then -- N
            TriggerEvent("gangwars:showZoneInfo")
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- SHIFT + N : OPEN ZONE CONTROLS MENU
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlPressed(0, 21) and IsControlJustPressed(0, 249) then
            TriggerEvent("gangwars:openZoneMenu")
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- CTRL + N : TOGGLE BLIP MODES
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlPressed(0, 36) and IsControlJustPressed(0, 249) then -- Ctrl + N
            lastBlipMode = lastBlipMode + 1
            if lastBlipMode > 3 then lastBlipMode = 1 end
            TriggerEvent("gangwars:setBlipMode", lastBlipMode)
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- AIM + H : FOLLOW / BACKUP VEHICLE
------------------------------------------------------------
CreateThread(function()
    while true do
        if isAiming() and IsControlJustPressed(0, 74) then -- H
            local entity = getEntityPlayerIsAimingAt()
            if entity and isFriendly(entity) then
                if IsEntityAPed(entity) then
                    TriggerEvent("gangwars:toggleFollow", entity)
                elseif IsEntityAVehicle(entity) then
                    TriggerEvent("gangwars:vehicleBackup", entity)
                end
            end
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- AIM + J : TAKE CONTROL OF MEMBER / RETURN
------------------------------------------------------------
CreateThread(function()
    while true do
        if isAiming() and IsControlJustPressed(0, 306) then -- J
            local entity = getEntityPlayerIsAimingAt()
            if entity and IsEntityAPed(entity) and isFriendly(entity) then
                TriggerEvent("gangwars:takeControl", entity)
            end
        end
        Wait(0)
    end
end)

------------------------------------------------------------
-- SPACE : CONTROL NEAREST MEMBER (WHEN DEAD)
------------------------------------------------------------
CreateThread(function()
    while true do
        if IsControlJustPressed(0, 22) then -- SPACE
            TriggerEvent("gangwars:controlNearestMember")
        end
        Wait(0)
    end
end)

print("^2[GangWars]^7 Controls loaded")

local KEY_B = 29          -- B
local KEY_SHIFT = 21      -- Shift

CreateThread(function()
    while true do
        Wait(0)

        -- Shift + B = registration menu
        if IsControlPressed(0, KEY_SHIFT) and IsControlJustPressed(0, KEY_B) then
            TriggerEvent("gangwars:tryRegisterTarget")
        end
    end
end)

