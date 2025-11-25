fx_version 'cerulean'
game 'gta5'

author 'ZaK2BaK5906'
description 'Système de pêche avancé avec progression, NUI et ox_lib'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/boutique/index.html',
    'nui/boutique/style.css',
    'nui/boutique/script.js',
    'nui/tablette/index.html',
    'nui/tablette/style.css',
    'nui/tablette/script.js'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql'
}
