fx_version 'cerulean'
game 'gta5'

author 'Veldora'
description 'Sistema completo de logs para Discord'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
}

server_scripts {
    'utils.lua',
    'server.lua',
    'server_hooks.lua',
    'server_integrations.lua',
}
