-- Hyprland Lua configuration
-- Migrated from hyprlang format for Hyprland 0.55+
-- Based on default config at /usr/share/hypr/hyprland.lua

-- ===== DETECT CURRENT USER =====
local user = "ecila" -- os.getenv("USER") or "ecila"

-- ===== MONITORS =====
require("modules.monitors")

-- ===== ENVIRONMENT VARIABLES =====
require("modules.env")

-- ===== AUTOSTART =====
require("modules.autostart")

-- ===== LOAD USER THEME =====
local theme = require("users." .. user)

-- ===== APPLY APPEARANCE (themed) =====
require("modules.appearance").apply(theme)

-- ===== ANIMATIONS =====
require("modules.animations")

-- ===== INPUT =====
require("modules.input")

-- ===== MISC / LAYOUTS =====
require("modules.misc")

-- ===== WINDOW RULES =====
require("modules.window_rules")

-- ===== KEYBINDINGS =====
local ctx = {
  terminal = "kitty",
  layer1   = "SUPER",
  layer2   = "SUPER + SHIFT",
  layer3   = "SUPER + SHIFT + CTRL",
  layer4   = "SUPER + CTRL",
}

require("keybindings.global").setup(ctx)

-- Load user-specific keybinds (pcall in case user has no custom binds)
pcall(function()
  require("keybindings." .. user).setup(ctx)
end)
