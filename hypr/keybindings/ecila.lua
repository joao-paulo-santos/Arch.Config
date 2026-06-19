-- ecila's advanced keybindings
local M = {}

function M.setup(ctx)
  local l1       = ctx.layer1
  local l2       = ctx.layer2
  local l3       = ctx.layer3
  local l4       = ctx.layer4

  local menu     = "/mnt/prometheus/Dev/Repos/velo/build/velo -e drun"
  local hmenu    = "/mnt/prometheus/Dev/Repos/velo/build/velo"
  local tmuxMenu = "/mnt/prometheus/Dev/Repos/velo/build/velo -e tmux"

  -- Launchers
  hl.bind(l1 .. " + Space", hl.dsp.exec_cmd(menu))
  hl.bind(l4 .. " + Space", hl.dsp.exec_cmd(hmenu))

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

  -- tmux menu
  hl.bind(l2 .. " + Space", hl.dsp.exec_cmd(tmuxMenu))

  -- Named workspaces with layer1 + letters (excludes h/j/k/l — reserved by global focus binds)
  local ws_names = { "Q", "Web", "E", "R", "T", "Y", "U", "I", "O", "P",
    "A", "S", "D", "F", "G", "Z", "X", "C", "V", "B", "N", "M" }
  local ws_keys  = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
    "A", "S", "D", "F", "G", "Z", "X", "C", "V", "B", "N", "M" }

  for i = 1, #ws_keys do
    hl.bind(l1 .. " + " .. ws_keys[i], function() hl.dispatch(hl.dsp.focus({ workspace = "name:" .. ws_names[i] })); warp_if_monitor_changed() end)
    hl.bind(l2 .. " + " .. ws_keys[i], hl.dsp.window.move({ workspace = "name:" .. ws_names[i] }))
  end

  -- Special workspace
  hl.bind(l3 .. " + c", hl.dsp.window.move({ workspace = "special:magic" }))
  hl.bind(l3 .. " + s", hl.dsp.workspace.toggle_special("magic"))

  -- Monitor brightness (ddcutil)
  hl.bind(l2 .. " + F11", hl.dsp.exec_cmd("/home/ecila/.config/hypr/scripts/mon-bright-hyprctl.sh increase 10"),
    { locked = true })
  hl.bind(l2 .. " + F10", hl.dsp.exec_cmd("/home/ecila/.config/hypr/scripts/mon-bright-hyprctl.sh decrease 10"),
    { locked = true })

  -- Fullscreen variants
  hl.bind(l3 .. " + F11", hl.dsp.window.fullscreen(), { locked = true })
  hl.bind(l3 .. " + M", hl.dsp.window.fullscreen({ mode = 1 }), { locked = true })
  hl.bind(l3 .. " + N", hl.dsp.window.fullscreen(), { locked = true })
end

return M
