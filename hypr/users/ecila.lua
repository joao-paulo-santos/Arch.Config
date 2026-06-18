-- ecila's per-user config
local M = {}

M.colors = require("themes.colors.default")
M.style  = require("themes.styles.efficient")

function M.init()
    -- hl.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh ecila")
    hl.exec_cmd("NOCTALIA_CONFIG_HOME=~/.config/noctalia/ecila/conf NOCTALIA_STATE_HOME=~/.config/noctalia/ecila/state noctalia")
end

return M
