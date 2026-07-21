-- ecila's theme: colors, style, appearance, animations, layout, visual misc

-- ===== PALETTE (was themes/colors/default.lua) =====
local colors = {
    accent   = "rgba(1c6585ff)",
    inactive = "rgba(000000ff)",
    shadow   = "rgba(1a1a1aee)",
}

-- ===== STYLE (was themes/styles/efficient.lua) =====
local style = {
    gaps_in          = 2,
    gaps_out         = 0,
    border_size      = 1,
    rounding         = 0,
    active_opacity   = 1.0,
    inactive_opacity = 1.0,
    dim_strength     = 0.05,
    blur_size        = 2,
    blur_passes      = 2,
}

-- ===== APPEARANCE (general + decoration) =====
hl.config({
    general = {
        gaps_in          = style.gaps_in,
        gaps_out         = style.gaps_out,
        border_size      = style.border_size,

        col = {
            active_border   = colors.accent,
            inactive_border = colors.inactive,
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",

        snap = {
            enabled        = true,
            window_gap     = 10,
            monitor_gap    = 10,
            border_overlap = true,
            respect_gaps   = false,
        },
    },

    decoration = {
        rounding         = style.rounding,
        rounding_power   = 2,

        active_opacity   = style.active_opacity,
        inactive_opacity = style.inactive_opacity,

        dim_inactive     = true,
        dim_strength     = style.dim_strength,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = colors.shadow,
        },

        blur = {
            enabled  = true,
            size     = style.blur_size,
            passes   = style.blur_passes,
            vibrancy = 0.3696,
        },
    },

    -- ===== LAYOUT (was modules/misc.lua) =====
    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        fullscreen_on_one_column = true,
    },

    -- ===== VISUAL MISC =====
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
    },
})

-- ===== ANIMATIONS =====
-- Bezier curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Spring
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

-- Animation definitions
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })
