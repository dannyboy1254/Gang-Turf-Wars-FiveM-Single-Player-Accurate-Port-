print("^2[GangWars]^7 Registration client loaded")

------------------------------------------------------------
-- GET PED YOU ARE AIMING AT
------------------------------------------------------------
local function getAimedPed()
    local _, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
    if entity and DoesEntityExist(entity) and IsEntityAPed(entity) then
        return entity
    end
end

------------------------------------------------------------
-- REGISTER / UNREGISTER
------------------------------------------------------------
RegisterNetEvent("gangwars:tryRegisterTarget", function()
    local ped = getAimedPed()
    if not ped then
        TriggerEvent("chat:addMessage", {
            args = { "^1GangWars", "No ped targeted." }
        })
        return
    end

    local model = GetEntityModel(ped)

    TriggerServerEvent("gangwars:toggleGangModel", model)
end)
