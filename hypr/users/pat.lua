-- pat's per-user config
local M = {}

M.colors = require("themes.colors.pink")
M.style  = require("themes.styles.pretty")

function M.init()
    -- hl.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh pat")
    hl.exec_cmd("NOCTALIA_CONFIG_HOME=~/.config/noctalia/pat/conf NOCTALIA_STATE_HOME=~/.config/noctalia/pat/state noctalia")
end

return M
