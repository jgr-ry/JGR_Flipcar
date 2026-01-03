fx_version 'cerulean'
game 'gta5'
name 'JGR Flip-car'
repository 'https://github.com/jgr-ry/Flip-car'
version '1.1.6'
author 'Ryder'
lua54 'yes'

shared_scripts {
    -- Si usas ESX, quita los guiones '--' de la línea de abajo:
    -- '@es_extended/imports.lua',

    -- 1. ox_lib debe ir ANTES que qbx_core para evitar el error de 'nil value (global lib)'
    '@ox_lib/init.lua',

    -- 2. QBX shared utilities
    '@qbx_core/modules/lib.lua',

    -- 3. Configuración del script
    'config.lua',
}

client_scripts {
    -- QBX client PlayerData
    '@qbx_core/modules/playerdata.lua',
    'client.lua',
}

server_scripts {
    'check_update.lua',
}

-- Declare runtime dependencies
dependencies {
    'qbx_core',
    'ox_lib',
    'ox_inventory'
}
