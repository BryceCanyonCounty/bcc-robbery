game 'rdr3'
fx_version "cerulean"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

lua54 'yes'
author 'BCC Team'

shared_scripts {
    'configs/*.lua',
    'locale.lua',
    'languages/*.lua'
}

server_scripts {
    'server/server.lua'
}

client_scripts {
    'client/client.lua',
}

dependency {
    'vorp_core',
    'vorp_inventory',
    'bcc-utils',
    'bcc-minigames',
    'bcc-job-alerts'
}

version '1.1.2'
