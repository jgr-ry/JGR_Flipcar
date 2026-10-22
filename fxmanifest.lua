fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'JGR_Flipcar'
author 'JGR (Ryder)'
description 'Dar la vuelta a vehículos volcados (QBCore, Qbox, ESX y standalone)'
version '1.2.0'
jgr_version_key 'JGR_Flipcar'
repository 'https://github.com/jgr-ry/JGR_Flipcar'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'bridge/client.lua',
    'client.lua',
}

server_scripts {
    'server/version_check.lua',
}

dependency 'ox_lib'
