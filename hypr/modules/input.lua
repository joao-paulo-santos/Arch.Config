-- Input configuration
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = false,
        },
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
