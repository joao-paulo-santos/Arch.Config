-- paquete's window rules
-- Combines shared rules + paquete's per-user rules.

-- Bind workspace 1 to DP-5 so apps open there by default,
-- even though DP-6 sits at position 0x0 (physically on the left).
hl.workspace_rule({
    workspace = "1",
    monitor   = "DP-5",
    default   = true,
})

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

-- TODO: add paquete's app workspace assignments here
