-- Monitor configuration
-- DP-4: 1920x1080@143.86, left monitor, position 0x0
hl.monitor({
    output   = "DP-4",
    mode     = "1920x1080@143.86",
    position = "0x0",
    scale    = 1,
})

-- DP-3: 2560x1440@120, right monitor, position 1920x0
hl.monitor({
    output   = "DP-3",
    mode     = "2560x1440@120",
    position = "1920x0",
    scale    = 1,
})
