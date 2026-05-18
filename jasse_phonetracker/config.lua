Config = {}

-- ──────────────────────────────────────────────────────────────────
-- Kieli / Language:  'fi' | 'en'
-- ──────────────────────────────────────────────────────────────────
Config.Locale = 'fi'

-- ──────────────────────────────────────────────────────────────────
-- Framework:  'auto' | 'esx' | 'qbcore' | 'qbox'
-- ──────────────────────────────────────────────────────────────────
Config.Framework = 'auto'

-- ──────────────────────────────────────────────────────────────────
-- Inventory:  'auto' | 'ox_inventory' | 'qb-inventory' | 'qs-inventory'
--             'ps-inventory' | 'core_inventory' | 'origen_inventory'
--             'CodeM_Inventory' | 'esx_native'
-- ──────────────────────────────────────────────────────────────────
Config.Inventory = 'auto'

-- ──────────────────────────────────────────────────────────────────
-- Phone script used on the server for number lookups.
-- 'auto' detects: lb-phone, qs-smartphone, 17_phone, gksphone, npwd,
--                 esx_phone, and framework charinfo as fallback.
-- ──────────────────────────────────────────────────────────────────
Config.PhoneScript = 'auto'

-- ──────────────────────────────────────────────────────────────────
-- Notification library: 'auto' | 'ox_lib' | 'lation' | 'qb' | 'esx' | 'native'
-- ──────────────────────────────────────────────────────────────────
Config.Notify = 'auto'

-- ──────────────────────────────────────────────────────────────────
-- Jobs that are allowed to use the tracker (add all police-type jobs)
-- ──────────────────────────────────────────────────────────────────
Config.PoliceJobs = {
    'police',
    'sheriff',
    'lspd',
    'bcso',
    'sasp',
    'fib',
    'swat',
}

-- ──────────────────────────────────────────────────────────────────
-- Phone items checked in inventory (all common FiveM phone items)
-- ──────────────────────────────────────────────────────────────────
Config.PhoneItems = {
    -- lb-phone
    'lb_phone',
    -- qs-smartphone
    'qs_smartphone', 'smartphone',
    -- 17_phone / 17movement phonix
    'phone_17', 'phonix', '17phone',
    -- gks-phone
    'gksphone',
    -- npwd / pn-phone
    'phone',
    -- esx/qb generic
    'iphone', 'iPhone',
    'android_phone', 'ios_phone',
    -- misc
    'phone_1', 'phone_2',
    'burner_phone', 'burnerphone',
}

-- ──────────────────────────────────────────────────────────────────
-- Tracking probabilities (must sum to 100)
-- ──────────────────────────────────────────────────────────────────
Config.SuccessChance  = 70   -- accurate area (phone inside 60m circle, not at center)
Config.NoSignalChance = 20   -- no location returned
Config.FakeChance     = 10   -- completely wrong/fake location

-- Uncertainty circle radius shown to police (meters)
Config.LocationRadius = 60

-- How far the circle center is offset from the real phone (min / max meters)
-- Phone will always be inside the circle, just not at its center
Config.OffsetMin = 15
Config.OffsetMax = 45

-- ──────────────────────────────────────────────────────────────────
-- Timing
-- ──────────────────────────────────────────────────────────────────
Config.TrackDuration    = 300    -- total tracking time (seconds, 5 min)
Config.UpdateInterval   = 30     -- update every N seconds
Config.Cooldown         = 43200  -- cooldown per number after tracking (12 h)

-- ──────────────────────────────────────────────────────────────────
-- Command to open the UI  (/phonetracker)
-- ──────────────────────────────────────────────────────────────────
Config.Command       = 'phonetracker'
Config.UseCommand    = true        -- rekisteröi /phonetracker komento
Config.UseKeybind    = false
Config.Keybind       = 'F6'        -- only used when UseKeybind = true

-- ──────────────────────────────────────────────────────────────────
-- Map blip
-- ──────────────────────────────────────────────────────────────────
Config.BlipSprite        = 1     -- standard dot
Config.BlipColor         = 3     -- blue
Config.RadiusBlipColor   = 3     -- blue
Config.RadiusBlipAlpha   = 80    -- 0-255, circle transparency

Config.NotifyTitle = 'Phone Tracker'
