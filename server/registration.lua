print("^2[GangWars]^7 Registration server loaded")

------------------------------------------------------------
-- ADD / REMOVE MODEL FROM GANG
------------------------------------------------------------
RegisterNetEvent("gangwars:toggleGangModel", function(model)
    local src = source
    local gangId = GangsAPI.getGang(src)
    if not gangId then return end

    local gang = Gangs[gangId]
    gang.models = gang.models or {}

    -- toggle
    for i, m in ipairs(gang.models) do
        if m == model then
            table.remove(gang.models, i)
            saveGangs()
            TriggerClientEvent("gangwars:notify", src, "Removed gang member model.")
            return
        end
    end

    table.insert(gang.models, model)
    saveGangs()
    TriggerClientEvent("gangwars:notify", src, "Added gang member model.")
end)
