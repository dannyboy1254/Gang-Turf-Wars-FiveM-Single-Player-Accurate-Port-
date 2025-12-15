-- ============================================================
-- PERSISTENCE UTILS (SERVER)
-- ============================================================

local json = json or {}

Persistence = {}

------------------------------------------------------------
-- LOAD JSON FILE
------------------------------------------------------------

function Persistence.loadFile(path)
    local res = GetCurrentResourceName()
    local raw = LoadResourceFile(res, path)

    if not raw or raw == "" then
        return nil
    end

    local ok, data = pcall(json.decode, raw)
    if not ok then
        print(("[GangWars] ❌ Failed to decode JSON: %s"):format(path))
        return nil
    end

    return data
end

------------------------------------------------------------
-- SAVE JSON FILE
------------------------------------------------------------

function Persistence.saveFile(path, tbl)
    if type(tbl) ~= "table" then
        print(("[GangWars] ❌ Refusing to save non-table to %s"):format(path))
        return
    end

    local res = GetCurrentResourceName()
    local raw = json.encode(tbl, { indent = true })

    if not raw then
        print(("[GangWars] ❌ Failed to encode JSON: %s"):format(path))
        return
    end

    SaveResourceFile(res, path, raw, -1)
end
