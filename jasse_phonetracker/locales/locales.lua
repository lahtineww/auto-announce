-- ──────────────────────────────────────────────────────────────────
-- jasse_phonetracker | locales/locales.lua
-- Vaihda kieli: Config.Locale = 'fi' tai 'en'
-- ──────────────────────────────────────────────────────────────────

local Locales = {}

-- ══════════════════════════════════════════════════════════════════
-- 🇫🇮  SUOMI
-- ══════════════════════════════════════════════════════════════════
Locales['fi'] = {

    -- ── Ilmoitusotsikko ──────────────────────────────────────────
    notify_title            = 'Puhelinträkkeri',

    -- ── Palvelinviestit (lähetetään pelaajalle takaisin) ────────
    response_access_denied  = 'Pääsy kielletty',
    response_invalid_number = 'Virheellinen numero',
    response_cooldown       = 'Cooldown aktiivinen: %dh %dm jäljellä',
    response_already        = 'Numero on jo seurannassa',
    response_no_phone       = 'Kohteella ei ole puhelinta',
    response_initiated      = 'Seuranta aloitettu',

    -- ── Asiakasilmoitukset ───────────────────────────────────────
    notify_signal_found     = 'Träkätään %s – signaali löydetty',
    notify_no_phone         = 'Kohteella ei ole puhelinta',
    notify_offline          = 'Kohde on offline',
    notify_no_signal        = 'Signaalia ei löydetty',
    notify_ended            = 'Seuranta päättyi: %s',
    notify_invalid_number   = 'Syötä kelvollinen numero',

    -- ── Karttamerkinnät ──────────────────────────────────────────
    blip_name               = 'Puhelin: %s',
    keybind_desc            = 'Avaa puhelinträkkeri',

    -- ── UI – staattinen teksti ───────────────────────────────────
    ui_brand                = 'Poliisi',
    ui_tab                  = 'Puhelinträkkeri',
    ui_dept                 = 'Poliisilaitos',
    ui_close_title          = 'Sulje',

    ui_nav_main             = 'Seuranta',
    ui_nav_history          = 'Historia',

    ui_col_search           = 'Hae numeroa',
    ui_col_tracks           = 'Aktiiviset seurannat',
    ui_col_cooldowns        = 'Cooldownit',
    ui_placeholder          = 'Kirjoita numero…',
    ui_search_hint          = 'Kirjoita puhelinnumero alle ja paina lähetä',

    ui_no_cooldowns         = 'Ei cooldowneja',
    ui_no_tracks            = 'Ei aktiivisia seurantoja',

    ui_history_title        = 'Historia',
    ui_no_history           = 'Ei träkkäyshistoriaa tältä sessiolta',
    ui_history_expired      = 'Päättyi',
    ui_history_manual       = 'Lopetettu',

    -- ── UI – seurantakohteen tila ────────────────────────────────
    ui_status_found         = 'Signaali löydetty',
    ui_status_offline       = 'Kohde offline',
    ui_status_no_phone      = 'Ei puhelinta',
    ui_status_no_signal     = 'Ei signaalia',
    ui_status_syncing       = 'Synkronoidaan…',
    ui_status_unknown       = 'Tuntematon',

    -- ── UI – seurantakohteen rivitekstit ────────────────────────
    ui_btn_stop             = 'Lopeta',
    ui_time_left            = 'Aikaa jäljellä:',
    ui_update_label         = 'Päivitys #',

    -- ── UI – hälytysviestit ──────────────────────────────────────
    ui_alert_invalid        = 'Syötä kelvollinen puhelinnumero',
    ui_alert_sent           = 'Seurantapyyntö lähetetty…',
}

-- ══════════════════════════════════════════════════════════════════
-- 🇬🇧  ENGLISH
-- ══════════════════════════════════════════════════════════════════
Locales['en'] = {

    -- ── Notification title ────────────────────────────────────────
    notify_title            = 'Phone Tracker',

    -- ── Server response messages ─────────────────────────────────
    response_access_denied  = 'Access denied',
    response_invalid_number = 'Invalid number',
    response_cooldown       = 'Cooldown active: %dh %dm remaining',
    response_already        = 'Already tracking this number',
    response_no_phone       = 'Target has no phone',
    response_initiated      = 'Tracking initiated',

    -- ── Client notifications ──────────────────────────────────────
    notify_signal_found     = 'Tracking %s – signal found',
    notify_no_phone         = 'Target has no phone',
    notify_offline          = 'Target is offline',
    notify_no_signal        = 'No signal found',
    notify_ended            = 'Tracking ended: %s',
    notify_invalid_number   = 'Enter a valid number',

    -- ── Map blip ─────────────────────────────────────────────────
    blip_name               = 'Phone: %s',
    keybind_desc            = 'Open Phone Tracker',

    -- ── UI – static text ─────────────────────────────────────────
    ui_brand                = 'Police',
    ui_tab                  = 'Phone Tracker',
    ui_dept                 = 'Police Department',
    ui_close_title          = 'Close',

    ui_nav_main             = 'Tracker',
    ui_nav_history          = 'History',

    ui_col_search           = 'Search Number',
    ui_col_tracks           = 'Active Tracks',
    ui_col_cooldowns        = 'Cooldowns',
    ui_placeholder          = 'Type number…',
    ui_search_hint          = 'Type a phone number below and press send',

    ui_no_cooldowns         = 'No cooldowns',
    ui_no_tracks            = 'No active tracks',

    ui_history_title        = 'History',
    ui_no_history           = 'No tracking history this session',
    ui_history_expired      = 'Expired',
    ui_history_manual       = 'Stopped',

    -- ── UI – track status labels ──────────────────────────────────
    ui_status_found         = 'Signal Found',
    ui_status_offline       = 'Target Offline',
    ui_status_no_phone      = 'No Phone',
    ui_status_no_signal     = 'No Signal',
    ui_status_syncing       = 'Syncing…',
    ui_status_unknown       = 'Unknown',

    -- ── UI – track item row text ──────────────────────────────────
    ui_btn_stop             = 'Stop',
    ui_time_left            = 'Time left:',
    ui_update_label         = 'Update #',

    -- ── UI – alert messages ───────────────────────────────────────
    ui_alert_invalid        = 'Enter a valid phone number',
    ui_alert_sent           = 'Tracking request sent…',
}

-- ──────────────────────────────────────────────────────────────────
-- _L(key, ...) – hae käännetty teksti
-- Palauttaa käännetyn merkkijonon, fallback englantiin, fallback avaimeen.
-- Tuki format-argumenteille: _L('response_cooldown', 2, 30)
-- ──────────────────────────────────────────────────────────────────
function _L(key, ...)
    local lang = Locales[Config.Locale] or Locales['en']
    local str  = (lang and lang[key]) or (Locales['en'] and Locales['en'][key]) or key
    if select('#', ...) > 0 then
        return str:format(...)
    end
    return str
end

-- Palauttaa koko JS-locale-taulukon NUI:lle lähetettäväksi
function GetUILocale()
    local lang = Locales[Config.Locale] or Locales['en']
    local result = {}
    for k, v in pairs(lang) do
        -- Lähetä vain ui_ -avaimet JavaScriptille
        if k:sub(1, 3) == 'ui_' then
            result[k] = v
        end
    end
    return result
end
