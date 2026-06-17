-- pat's per-user config
local M = {}

M.colors = require("themes.colors.pink")
M.style  = require("themes.styles.pretty")

function M.init()
    hl.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh pat")
end

return M
