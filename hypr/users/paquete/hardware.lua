-- paquete's hardware config (this PC: monitors, input devices, env)

-- ===== MONITORS =====
-- DP-6: WAM IYVISION2718, 2560x1440@180, left monitor, position 0x0
hl.monitor({
    output   = "DP-6",
    mode     = "2560x1440@180",
    position = "0x0",
    scale    = 1,
})

-- DP-5: Dell U2724DE, 2560x1440@120, right monitor, position 2560x0
hl.monitor({
    output   = "DP-5",
    mode     = "2560x1440@120",
    position = "2560x0",
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
    kb_layout    = "pt",
    kb_variant   = "",
    kb_model     = "",
    kb_options   = "",
    kb_rules     = "",

    follow_mouse = 1,
    sensitivity  = 0,

    touchpad     = {
      natural_scroll = true,
    },
  },

  cursor = {
    no_warps = true,
  },
})
