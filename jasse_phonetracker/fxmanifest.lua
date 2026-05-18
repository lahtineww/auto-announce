fx_version 'cerulean'
game 'gta5'

name 'jasse_phonetracker'
author 'Jasse'
version '1.0.0'
description 'Phone Number Tracker for Police | ESX/QBCore/QBox'

shared_scripts {
    'config.lua',
    'locales/locales.lua',
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
