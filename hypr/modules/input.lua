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

-- Cursor configuration
hl.config({
    cursor = {
        no_warps = true,
    },
})

-- Warp cursor to focused monitor's center if the monitor changed after a focus action.
-- Used to wrap keybinds so cursor follows on monitor switches but not on mouse movement.
function _G.warp_if_monitor_changed()
    local mon = hl.get_active_monitor()
    if not mon then return end
    local pos = hl.get_cursor_pos()
    if not pos then return end
    local mw = mon.width / mon.scale
    local mh = mon.height / mon.scale
    if pos.x >= mon.x and pos.x < mon.x + mw and pos.y >= mon.y and pos.y < mon.y + mh then
        return
    end
    hl.dispatch(hl.dsp.cursor.move({x = mon.x + mw / 2, y = mon.y + mh / 2}))
end

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
