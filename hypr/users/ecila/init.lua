-- ecila's Hyprland config — assembly point
-- Loads each concern in order. Edit sibling files to change behavior.

-- Shared cursor helper used by keybinds.lua
require("lib.warp")

-- Permissions (one-line globals)
hl.permission({
    binary = "/usr/(bin|local/bin)/hyprpm",
    type   = "plugin",
    mode   = "allow",
})

-- Per-concern configuration
require("users.ecila.hardware")
require("users.ecila.theme")
require("users.ecila.rules")
require("users.ecila.autostart")
require("users.ecila.keybinds")
