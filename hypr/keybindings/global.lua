-- Global keybindings shared by all users
local M = {}

function M.setup(ctx)
  local l1       = ctx.layer1
  local l2       = ctx.layer2
  local terminal = ctx.terminal

  -- Window management
  hl.bind(l1 .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(l1 .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  hl.bind(l1 .. " + Backspace", hl.dsp.window.close())
  hl.bind(l1 .. " + Return", hl.dsp.exec_cmd(terminal))

  -- Toggle floating
  hl.bind(ctx.layer3 .. " + f", hl.dsp.window.float({ action = "toggle" }))

  -- Switch Hyprland profile (theme + keybinds)
  hl.bind(ctx.layer4 .. " + e", hl.dsp.exec_cmd("~/.config/hypr/scripts/hyprland-profile.sh menu"))

  -- Switch waybar profile
  hl.bind(ctx.layer4 .. " + w", hl.dsp.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh menu"))

  -- Switch kitty theme
  hl.bind(ctx.layer4 .. " + r", hl.dsp.exec_cmd("~/.config/kitty/scripts/kitty-theme.sh menu"))

  -- hypr-tofi theme switcher
  hl.bind(ctx.layer3 .. " + t", hl.dsp.exec_cmd("/mnt/prometheus/Dev/Repos/hypr-tofi/build/hypr-tofi -e theme"))

  -- Move focus with hjkl (vim) and arrow keys
  hl.bind(l1 .. " + h", hl.dsp.focus({ direction = "left" }))
  hl.bind(l1 .. " + k", hl.dsp.focus({ direction = "up" }))
  hl.bind(l1 .. " + j", hl.dsp.focus({ direction = "down" }))
  hl.bind(l1 .. " + l", hl.dsp.focus({ direction = "right" }))
  hl.bind(l1 .. " + left", hl.dsp.focus({ direction = "left" }))
  hl.bind(l1 .. " + right", hl.dsp.focus({ direction = "right" }))
  hl.bind(l1 .. " + up", hl.dsp.focus({ direction = "up" }))
  hl.bind(l1 .. " + down", hl.dsp.focus({ direction = "down" }))

  -- Move windows with layer2 + hjkl and arrow keys
  hl.bind(l2 .. " + h", hl.dsp.window.move({ direction = "left" }))
  hl.bind(l2 .. " + k", hl.dsp.window.move({ direction = "up" }))
  hl.bind(l2 .. " + j", hl.dsp.window.move({ direction = "down" }))
  hl.bind(l2 .. " + l", hl.dsp.window.move({ direction = "right" }))
  hl.bind(l2 .. " + left", hl.dsp.window.move({ direction = "left" }))
  hl.bind(l2 .. " + right", hl.dsp.window.move({ direction = "right" }))
  hl.bind(l2 .. " + up", hl.dsp.window.move({ direction = "up" }))
  hl.bind(l2 .. " + down", hl.dsp.window.move({ direction = "down" }))

  -- Switch workspaces with layer1 + [0-9]
  -- Move active window to workspace with layer2 + [0-9]
  for i = 1, 10 do
    local key = i % 10
    hl.bind(l1 .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(l2 .. " + " .. key, hl.dsp.window.move({ workspace = i }))
  end

  -- Scroll through existing workspaces
  hl.bind(l1 .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }))
  hl.bind(l1 .. " + mouse_up", hl.dsp.focus({ workspace = "m-1" }))

  -- Volume (wpctl — locked so it works on lockscreen)
  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
  hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

  -- Volume with SUPER + F-keys (amixer — secondary controls)
  hl.bind(l1 .. " + F5", hl.dsp.exec_cmd("amixer -q sset PCM 5%-"))
  hl.bind(l1 .. " + F6", hl.dsp.exec_cmd("amixer -q sset PCM 5%+"))
  hl.bind(l1 .. " + F7", hl.dsp.exec_cmd("amixer -q sset PCM toggle"))

  -- Volume with SUPER + F-keys (wpctl)
  hl.bind(l1 .. " + F9", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
  hl.bind(l1 .. " + F10", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
  hl.bind(l1 .. " + F11", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })

  -- Screenshots
  hl.bind(l1 .. " + Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"))
  hl.bind(l2 .. " + Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))
  -- hl.bind(l1 .. " + Print", hl.dsp.exec_cmd("hyprshot -m output -r -z --clipboard-only | satty -c ~/.config/satty/config.toml -o $HOME/Media/Screenshots/%Y-%m-%d_%H:%M:%S.png -f -"))
  -- hl.bind(l2 .. " + Print", hl.dsp.exec_cmd("hyprshot -m region -r -z --clipboard-only | satty -c ~/.config/satty/config.toml -o $HOME/Media/Screenshots/%Y-%m-%d_%H:%M:%S.png -f -"))
end

return M
