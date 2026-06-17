-- Hyprland Lua configuration
-- Migrated from hyprlang format for Hyprland 0.55+
-- Based on default config at /usr/share/hypr/hyprland.lua

-- ===== DETECT CURRENT USER =====
-- Reads from state file if set (for on-the-fly profile switching), otherwise falls back to $USER
local state_file = os.getenv("HOME") .. "/.config/hypr/state/active-profile"
local user
local f = io.open(state_file, "r")
if f then
    user = f:read("*l")
    f:close()
end
user = user or os.getenv("USER") or "ecila"

-- ===== MONITORS =====
require("modules.monitors")

-- ===== ENVIRONMENT VARIABLES =====
require("modules.env")

-- ===== LOAD USER CONFIG =====
local userConfig = require("users." .. user)

-- ===== AUTOSTART (shared) =====
require("modules.autostart")

-- ===== USER-SPECIFIC STARTUP =====
if userConfig.init then
    hl.on("hyprland.start", userConfig.init)
end

-- ===== APPLY APPEARANCE (themed) =====
require("modules.appearance").apply(userConfig)

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
