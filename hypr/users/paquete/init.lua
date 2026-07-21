-- paquete's Hyprland config — assembly point
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
require("users.paquete.hardware")
require("users.paquete.theme")
require("users.paquete.rules")
require("users.paquete.autostart")
require("users.paquete.keybinds")
