-- ============================================================
-- GANG & TURF – SINGLE PLAYER ZONES (FIVEM PORT)
-- Shared between server & client
-- ============================================================
Config = Config or {}
Config.Zones = Config.Zones or {}

Config.Zones = {

    -- ======================
    -- FAMILIES
    -- ======================
    {
        id = "grove_street",
        name = "Grove Street",
        coords = vector3(102.3, -1938.6, 20.0),
        radius = 80.0,
        baseValue = 13,
        ownerGangId = 1,
    },
    {
        id = "forum_drive",
        name = "Forum Drive",
        coords = vector3(-157.0, -1605.0, 33.0),
        radius = 70.0,
        baseValue = 11,
        ownerGangId = 1,
    },
    {
        id = "carson_avenue",
        name = "Carson Avenue",
        coords = vector3(-95.0, -1745.0, 29.0),
        radius = 65.0,
        baseValue = 10,
        ownerGangId = 1,
    },

    -- ======================
    -- BALLAS
    -- ======================
    {
        id = "chamberlain_hills",
        name = "Chamberlain Hills",
        coords = vector3(145.0, -1765.0, 28.0),
        radius = 75.0,
        baseValue = 15,
        ownerGangId = 2,
    },
    {
        id = "strawberry",
        name = "Strawberry",
        coords = vector3(252.4, -1741.9, 29.3),
        radius = 75.0,
        baseValue = 11,
        ownerGangId = 2,
    },

    -- ======================
    -- VAGOS
    -- ======================
    {
        id = "rancho",
        name = "Rancho",
        coords = vector3(410.0, -1605.0, 29.0),
        radius = 85.0,
        baseValue = 14,
        ownerGangId = 3,
    },
    {
        id = "davis",
        name = "Davis",
        coords = vector3(85.0, -1950.0, 20.0),
        radius = 80.0,
        baseValue = 12,
        ownerGangId = 3,
    },

    -- ======================
    -- AZTECAS
    -- ======================
    {
        id = "el_burro_heights",
        name = "El Burro Heights",
        coords = vector3(1180.0, -1640.0, 45.0),
        radius = 90.0,
        baseValue = 16,
        ownerGangId = 4,
    },

    -- ======================
    -- TRIADS
    -- ======================
    {
        id = "textile_city",
        name = "Textile City",
        coords = vector3(435.0, -785.0, 28.0),
        radius = 75.0,
        baseValue = 14,
        ownerGangId = 5,
    },

    -- ======================
    -- LOST MC
    -- ======================
    {
        id = "east_vinewood",
        name = "East Vinewood",
        coords = vector3(950.0, -125.0, 74.0),
        radius = 90.0,
        baseValue = 18,
        ownerGangId = 6,
    },

    -- ======================
    -- NEUTRAL ZONES
    -- ======================
    {
        id = "vespucci_beach",
        name = "Vespucci Beach",
        coords = vector3(-1305.0, -1555.0, 4.0),
        radius = 110.0,
        baseValue = 12,
        ownerGangId = nil,
    },
}
