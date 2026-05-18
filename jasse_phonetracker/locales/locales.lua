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
    ui_title                = 'Puhelinträkkeri',
    ui_tab                  = 'Puhelinträkkeri',
    ui_dept                 = 'Poliisilaitos',
    ui_close_title          = 'Sulje',

    ui_card_track           = 'Seuraa puhelinnumeroa',
    ui_phone_label          = 'Puhelinnumero',
    ui_placeholder          = 'esim. 555-1234',
    ui_search_title         = 'Hae',
    ui_btn_start            = 'Aloita seuranta',

    ui_card_cooldowns       = 'Cooldownit',
    ui_no_cooldowns         = 'Ei cooldowneja',

    ui_card_active          = 'Aktiiviset seurannat',
    ui_no_tracks            = 'Ei aktiivisia seurantoja',

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
    ui_title                = 'Phone Tracker',
    ui_tab                  = 'Phone Tracker',
    ui_dept                 = 'Police Department',
    ui_close_title          = 'Close',

    ui_card_track           = 'Track Phone Number',
    ui_phone_label          = 'Phone Number',
    ui_placeholder          = 'e.g. 555-1234',
    ui_search_title         = 'Search',
    ui_btn_start            = 'Start Tracking',

    ui_card_cooldowns       = 'Cooldowns',
    ui_no_cooldowns         = 'No cooldowns',

    ui_card_active          = 'Active Tracks',
    ui_no_tracks            = 'No active tracks',

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
