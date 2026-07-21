-- ecila's hardware config (this PC: monitors, input devices, env)
-- Differs per machine — keep this file specific to the box it runs on.

-- ===== MONITORS =====
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

-- ===== ENVIRONMENT VARIABLES =====
hl.env("TERMINAL", "kitty")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- ===== INPUT =====
hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        no_warps = true,
    },
})

-- Per-device configuration
hl.device({
    name        = "logitech-g502-hero-gaming-mouse",
    sensitivity = 0.6,
})

-- 3-finger horizontal swipe for workspace switching
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})
