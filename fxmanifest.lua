fx_version 'cerulean'
game 'gta5'

author 'Dark_Phantom'
description 'Gang Wars System (AI vs AI Turf Wars)'
version '1.0.0'

lua54 'yes'

------------------------------------------------------------
-- SHARED
------------------------------------------------------------

shared_scripts {
    'config.lua',
    'shared/zones_sp.lua' -- must define Config.Zones
}

------------------------------------------------------------
-- SERVER
------------------------------------------------------------

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/persistence.lua',

    -- CORE STATE
    'server/gangs.lua',
    'server/zones.lua',
    'server/mod_options.lua',

    -- WAR SYSTEMS
    'server/war_spawns.lua',
    'server/wars.lua',

    -- ROAMING
    'server/roaming.lua',
    'server/roaming_vehicles.lua',

    -- ENTRY
    'server/main.lua'
}

------------------------------------------------------------
-- CLIENT
------------------------------------------------------------

client_scripts {

    -- CORE MENU ENGINE (MUST BE FIRST)
    'client/gang_menu.lua',
    'client/controls.lua',
    -- MENU SUBFILES
    'client/war_options_menu.lua',
    'client/war_spawns_menu.lua',
    'client/gang_customize_menu.lua',
    'client/gang_upgrades_menu.lua',
    'client/gang_weapons_menu.lua',
    'client/gang_car_colors_menu.lua',
    'client/gang_blip_color_menu.lua',
    'client/mod_options_menu.lua',

    -- GAMEPLAY SYSTEMS
    'client/roaming.lua',
    'client/roaming_vehicles.lua',
    'client/ai.lua',
    'client/zones.lua',
    'client/wars.lua',
    'client/blips.lua',

    -- CLIENT ENTRY POINT (LAST)
    'client/main.lua'
}
