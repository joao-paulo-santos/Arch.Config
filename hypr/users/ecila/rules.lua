-- ecila's window rules
-- Combines the former shared window_rules.lua + ecila's per-user rules.

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

-- ===== App workspace assignment =====
hl.window_rule({
    name      = "discord-on-d",
    match     = { class = "^discord$" },
    workspace = "name:D silent",
})

hl.window_rule({
    name      = "github-desktop-on-g",
    match     = { class = "^GitHub Desktop$" },
    workspace = "name:G silent",
})

hl.window_rule({
    name      = "steam-on-p",
    match     = { class = "^steam$" },
    workspace = "name:P silent",
})
