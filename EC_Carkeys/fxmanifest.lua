fx_version 'cerulean'
game 'gta5'

author 'FinantyX'
description 'Simple Doorlock System'
version '1.0.0'

shared_script '@ox_lib/init.lua'
lua54 'yes'
client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}