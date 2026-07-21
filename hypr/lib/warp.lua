-- Shared cursor warp helper used by keybinds.
-- Warps the cursor to the focused monitor's center if it isn't already there,
-- so monitor-switching keybinds feel natural without warping on every mouse move.

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
    hl.dispatch(hl.dsp.cursor.move({ x = mon.x + mw / 2, y = mon.y + mh / 2 }))
end
