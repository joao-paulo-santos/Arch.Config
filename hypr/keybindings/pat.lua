-- pat's keybindings
local M = {}

function M.setup(ctx)
  local l1    = ctx.layer1
  local l4    = ctx.layer4

  local menu  = "/mnt/prometheus/Dev/Repos/velo/build/velo -t cherry-blossom -e drun"
  local hmenu = "/mnt/prometheus/Dev/Repos/velo/build/velo -t cherry-blossom"

  -- Launchers
  hl.bind(l1 .. " + Space", hl.dsp.exec_cmd(menu))
  hl.bind(l4 .. " + Space", hl.dsp.exec_cmd(hmenu))

  -- Super+B opens Brave
  hl.bind(l1 .. " + B", hl.dsp.exec_cmd("brave"))
end

return M
