-- ecila's keybindings
-- Combines the former global.lua + ecila.lua into one complete set.

-- ===== MODIFIER LAYERS =====
local l1 = "SUPER"
local l2 = "SUPER + SHIFT"
local l3 = "SUPER + SHIFT + CTRL"
local l4 = "SUPER + CTRL"

local terminal = "kitty"
local menu     = "velo -e drun"
local hmenu    = "velo"
local tmuxMenu = "velo -e tmux"

-- ===== WINDOW MANAGEMENT =====
hl.bind(l1 .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(l1 .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(l1 .. " + Backspace", hl.dsp.window.close())
hl.bind(l1 .. " + Return", hl.dsp.exec_cmd(terminal))

-- Toggle floating
hl.bind(l3 .. " + f", hl.dsp.window.float({ action = "toggle" }))

-- ===== PROFILE / THEME SWITCHERS =====
hl.bind(l4 .. " + e", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprland-profile.sh menu"))
hl.bind(l4 .. " + w", hl.dsp.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh menu"))
hl.bind(l4 .. " + r", hl.dsp.exec_cmd("~/.config/kitty/scripts/kitty-theme.sh menu"))
hl.bind(l3 .. " + t", hl.dsp.exec_cmd("velo -e theme"))

-- ===== LAUNCHERS =====
hl.bind(l1 .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(l4 .. " + Space", hl.dsp.exec_cmd(hmenu))
hl.bind(l2 .. " + Space", hl.dsp.exec_cmd(tmuxMenu))

-- ===== FOCUS (vim + arrows) =====
hl.bind(l1 .. " + h", function() hl.dispatch(hl.dsp.focus({ direction = "left" })); warp_if_monitor_changed() end)
hl.bind(l1 .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(l1 .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(l1 .. " + l", function() hl.dispatch(hl.dsp.focus({ direction = "right" })); warp_if_monitor_changed() end)
hl.bind(l1 .. " + left",  function() hl.dispatch(hl.dsp.focus({ direction = "left" }));  warp_if_monitor_changed() end)
hl.bind(l1 .. " + right", function() hl.dispatch(hl.dsp.focus({ direction = "right" })); warp_if_monitor_changed() end)
hl.bind(l1 .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(l1 .. " + down",  hl.dsp.focus({ direction = "down" }))

-- ===== MOVE WINDOWS =====
hl.bind(l2 .. " + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(l2 .. " + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(l2 .. " + j", hl.dsp.window.move({ direction = "down" }))
hl.bind(l2 .. " + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(l2 .. " + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(l2 .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(l2 .. " + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(l2 .. " + down",  hl.dsp.window.move({ direction = "down" }))

-- ===== WORKSPACES (numbered) =====
for i = 1, 10 do
    local key = i % 10
    hl.bind(l1 .. " + " .. key, function() hl.dispatch(hl.dsp.focus({ workspace = i })); warp_if_monitor_changed() end)
    hl.bind(l2 .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- ===== WORKSPACES (named, ecila-specific) =====
-- Excludes h/j/k/l (reserved by focus binds above)
local ws_names = { "Q", "Web", "E", "R", "T", "Y", "U", "I", "O", "P",
                   "A", "S", "D", "F", "G", "Z", "X", "C", "V", "B", "N", "M" }
local ws_keys  = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
                   "A", "S", "D", "F", "G", "Z", "X", "C", "V", "B", "N", "M" }

for i = 1, #ws_keys do
    hl.bind(l1 .. " + " .. ws_keys[i], function() hl.dispatch(hl.dsp.focus({ workspace = "name:" .. ws_names[i] })); warp_if_monitor_changed() end)
    hl.bind(l2 .. " + " .. ws_keys[i], hl.dsp.window.move({ workspace = "name:" .. ws_names[i] }))
end

-- ===== MONITOR / WORKSPACE MANIPULATION =====
-- Workspace scrolling with layer4
hl.bind(l4 .. " + l", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(l4 .. " + h", hl.dsp.focus({ workspace = "m-1" }))

-- Alt+Tab cycle
hl.bind("ALT + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))

-- Move workspace to adjacent monitor (DP-4=left, DP-3=right)
hl.bind(l3 .. " + h", hl.dsp.workspace.move({ monitor = "DP-4" }))
hl.bind(l3 .. " + k", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(l3 .. " + j", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(l3 .. " + l", hl.dsp.workspace.move({ monitor = "DP-3" }))

-- Special workspace
hl.bind(l3 .. " + c", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(l3 .. " + s", hl.dsp.workspace.toggle_special("magic"))

-- Scroll through existing workspaces
hl.bind(l1 .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(l1 .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }))

-- ===== FULLSCREEN VARIANTS =====
hl.bind(l3 .. " + F11", hl.dsp.window.fullscreen(), { locked = true })
hl.bind(l3 .. " + M",   hl.dsp.window.fullscreen({ mode = 1 }), { locked = true })
hl.bind(l3 .. " + N",   hl.dsp.window.fullscreen(), { locked = true })

-- ===== UTILITIES =====
-- Toggle auto-clicker (Enter 2×/sec). First press starts, second press stops.
hl.bind(l3 .. " + A", hl.dsp.exec_cmd("~/.config/hypr/scripts/autoclicker.sh"))

-- ===== AUDIO =====
-- Volume (wpctl — locked so it works on lockscreen)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Volume with SUPER + F-keys (amixer — secondary)
hl.bind(l1 .. " + F5", hl.dsp.exec_cmd("amixer -q sset PCM 5%-"))
hl.bind(l1 .. " + F6", hl.dsp.exec_cmd("amixer -q sset PCM 5%+"))
hl.bind(l1 .. " + F7", hl.dsp.exec_cmd("amixer -q sset PCM toggle"))

-- Volume with SUPER + F-keys (wpctl)
hl.bind(l1 .. " + F9",  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind(l1 .. " + F10", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true })
hl.bind(l1 .. " + F11", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })

-- Monitor brightness (ddcutil)
hl.bind(l2 .. " + F11", hl.dsp.exec_cmd("/home/ecila/.config/hypr/scripts/mon-bright-hyprctl.sh increase 10"), { locked = true })
hl.bind(l2 .. " + F10", hl.dsp.exec_cmd("/home/ecila/.config/hypr/scripts/mon-bright-hyprctl.sh decrease 10"), { locked = true })

-- ===== SCREENSHOTS =====
hl.bind(l1 .. " + Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))
hl.bind(l2 .. " + Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
