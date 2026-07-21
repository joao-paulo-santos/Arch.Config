-- pat's keybindings
local M = {}

function M.setup(ctx)
  local l1    = ctx.layer1
  local l2    = ctx.layer2
  local l3    = ctx.layer3
  local l4    = ctx.layer4

  local menu  = "velo -e drun"
  local hmenu = "velo"
  local tmuxMenu = "velo -e tmux"

  -- Launchers
  hl.bind(l1 .. " + Space", hl.dsp.exec_cmd(menu))
  hl.bind(l4 .. " + Space", hl.dsp.exec_cmd(hmenu))
  hl.bind(l2 .. " + Space", hl.dsp.exec_cmd(tmuxMenu))

  -- Super+B opens Brave
  hl.bind(l1 .. " + B", hl.dsp.exec_cmd("brave"))
end

return M
