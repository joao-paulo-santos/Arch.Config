-- Hyprland entry point / dispatcher
-- Reads active profile from state file (set by hyprland-profile.sh),
-- falls back to $USER, then loads that user's self-contained config tree.

local state_file = os.getenv("HOME") .. "/.config/hypr/state/active-profile"
local user
local f = io.open(state_file, "r")
if f then
    user = f:read("*l")
    f:close()
end
if not user or user == "" then
    user = os.getenv("USER") or "ecila"
end

require("users." .. user .. ".init")

-- Noctalia color template engine (shared)
require("noctalia")
