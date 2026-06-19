-- Window rules (from Hyprland default config)

-- Suppress maximize events from all apps
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Confine pointer to fullscreen games
hl.window_rule({
    match           = { class = "steam_app_.*|steam_proton|.*\\.exe", fullscreen = true },
    confine_pointer = true,
})

-- Fix XWayland drag issues
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
