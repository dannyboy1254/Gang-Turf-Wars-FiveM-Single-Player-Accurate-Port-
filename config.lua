-- ============================================================
-- CONFIG BOOTSTRAP (MUST BE FIRST)
-- ============================================================

Config = Config or {}
Config.GangData = Config.GangData or {}

-- ============================================================
-- GENERAL SETTINGS
-- ============================================================

Config.ZoneInteractRadius = 50.0
Config.IncomeIntervalMinutes = 10

Config.GangColors = {
    [1] = {255, 50, 50},
    [2] = {50, 255, 50},
    [3] = {50, 50, 255},
}

-- ============================================================
-- GANG DATA (SP-ACCURATE, 4–8 MODELS EACH)
-- ============================================================

Config.GangData[1] = { -- Families
    peds = {
        `g_m_y_famca_01`,
        `g_m_y_famca_02`,
        `g_m_y_famdnf_01`,
        `g_m_y_famdnf_02`,
        `g_m_y_famfor_01`,
        `g_f_y_families_01`
    },
    vehicles = { `primo`, `baller` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_MICROSMG` },
    armor = 30,
    accuracy = 35
}

Config.GangData[2] = { -- Ballas
    peds = {
        `g_m_y_ballasout_01`,
        `g_m_y_ballasout_02`,
        `g_m_y_ballasout_03`,
        `g_m_y_ballaeast_01`,
        `g_m_y_ballaorig_01`,
        `g_f_y_ballas_01`
    },
    vehicles = { `emperor`, `greenwood` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_MICROSMG` },
    armor = 30,
    accuracy = 35
}

Config.GangData[3] = { -- Vagos
    peds = {
        `g_m_y_mexgang_01`,
        `g_m_y_mexgang_02`,
        `g_m_y_mexgoon_01`,
        `g_m_y_mexgoon_02`,
        `g_f_y_vagos_01`
    },
    vehicles = { `tornado`, `buccaneer` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_MICROSMG` },
    armor = 30,
    accuracy = 35
}

Config.GangData[4] = { -- Aztecas
    peds = {
        `g_m_y_mexgoon_01`,
        `g_m_y_mexgoon_02`,
        `g_m_y_mexgang_01`,
        `g_f_y_mexgoon_01`
    },
    vehicles = { `tornado`, `buccaneer` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_MICROSMG` },
    armor = 30,
    accuracy = 35
}

Config.GangData[5] = { -- Lost MC
    peds = {
        `g_m_y_lost_01`,
        `g_m_y_lost_02`,
        `g_m_y_lost_03`,
        `g_f_y_lost_01`,
        `g_m_y_lost_02`,
        `g_m_y_lost_03`
    },
    vehicles = { `daemon`, `slamvan` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_SAWNOFFSHOTGUN` },
    armor = 35,
    accuracy = 40
}

Config.GangData[6] = { -- Korean Mob
    peds = {
        `g_m_y_korean_01`,
        `g_m_y_korean_02`,
        `g_m_y_korean_03`,
        `g_f_y_korean_01`
    },
    vehicles = { `sultan`, `oracle` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_SMG` },
    armor = 35,
    accuracy = 45
}

Config.GangData[7] = { -- Triads
    peds = {
        `g_m_y_strpunk_01`,
        `g_m_y_strpunk_02`,
        `g_m_y_strpunk_03`,
        `g_m_y_strpunk_04`,
        `g_f_y_strpunk_01`
    },
    vehicles = { `premier`, `tailgater` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_MICROSMG` },
    armor = 40,
    accuracy = 45
}

Config.GangData[8] = { -- Armenian Mob
    peds = {
        `g_m_m_armboss_01`,
        `g_m_m_armlieut_01`,
        `g_m_y_armgoon_01`,
        `g_m_y_armgoon_02`,
        `g_f_y_armgoon_01`
    },
    vehicles = { `cavalcade`, `granger` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_SMG` },
    armor = 40,
    accuracy = 45
}

Config.GangData[9] = { -- Rednecks
    peds = {
        `g_m_y_salvagoon_01`,
        `g_m_y_salvagoon_02`,
        `g_m_y_salvagoon_03`,
        `g_f_y_salvagoon_01`
    },
    vehicles = { `bodhi2`, `sandking` },
    weapons = { `WEAPON_PISTOL`, `WEAPON_PUMPSHOTGUN` },
    armor = 35,
    accuracy = 35
}

Config.GangData[10] = { -- Merryweather
    peds = {
        `s_m_y_blackops_01`,
        `s_m_y_blackops_02`,
        `s_m_y_blackops_03`,
        `s_f_y_blackops_01`,
        `s_m_y_marine_01`,
        `s_m_y_marine_03`
    },
    vehicles = { `crusader`, `mesa` },
    weapons = { `WEAPON_CARBINERIFLE`, `WEAPON_SMG` },
    armor = 60,
    accuracy = 65
}
