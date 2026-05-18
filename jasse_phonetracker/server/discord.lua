-- ──────────────────────────────────────────────────────────────────
-- jasse_phonetracker | server/discord.lua
--
-- TÄMÄ TIEDOSTO ON VAIN SERVER-SIDE (server_scripts).
-- Webhookkeja ei jaeta clienteille eikä shared scripteihin.
-- ──────────────────────────────────────────────────────────────────

Discord = {}

-- ── Webhookit ─────────────────────────────────────────────────────
-- Aseta haluamasi URL tai jätä nil jos et halua logia.

-- Seuranta aloitettu: näyttää kuka träkkää, minkä numeron, onko kohde online
Discord.TrackStart   = 'WEBHOOK_URL_HERE'

-- Seuranta päättyi tai lopetettu manuaalisesti: kesto, syy, lopettaja
Discord.TrackStop    = 'WEBHOOK_URL_HERE'

-- Joka 30s sijaintipäivitys — jätä nil jos lokit täyttyvät liikaa
Discord.TrackUpdate  = nil

-- Joku ilman poliisi-jobbia yritti avata träkkerin
Discord.AccessDenied = 'WEBHOOK_URL_HERE'

-- Cooldown esti träkkäyksen — jätä nil jos ei kiinnosta
Discord.Cooldown     = nil

-- ── Botin asetukset ───────────────────────────────────────────────
Discord.BotName   = 'Puhelinträkkeri'
Discord.BotAvatar = ''   -- Botin avatar-URL tai tyhjä

-- ── Embed-värit (Discord desimaaliluku) ───────────────────────────
Discord.ColorStart  = 3447003   -- sininen  #3498db
Discord.ColorUpdate = 9807270   -- harmaa   #95a5a6
Discord.ColorStop   = 15158332  -- punainen #e74c3c
Discord.ColorDenied = 15158332  -- punainen #e74c3c
Discord.ColorCooldown = 16776960 -- keltainen #ffff00
