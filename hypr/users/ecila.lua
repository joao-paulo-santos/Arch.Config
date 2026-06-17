-- ecila's per-user config
local M = {}

M.colors = require("themes.colors.default")
M.style  = require("themes.styles.efficient")

function M.init()
    hl.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh ecila")
end

return M
