-- Appearance: general + decoration, parameterized by theme
local M = {}

function M.apply(theme)
  local c = theme.colors
  local s = theme.style

  hl.config({
    general = {
      gaps_in          = s.gaps_in,
      gaps_out         = s.gaps_out,
      border_size      = s.border_size,

      col              = {
        active_border   = c.accent,
        inactive_border = c.inactive,
      },

      resize_on_border = false,
      allow_tearing    = false,
      layout           = "dwindle",

      snap             = {
        enabled = true,
        window_gap = 10,
        monitor_gap = 10,
        border_overlap = true,
        respect_gaps = false,
      },
    },

    decoration = {
      rounding         = s.rounding,
      rounding_power   = 2,

      active_opacity   = s.active_opacity,
      inactive_opacity = s.inactive_opacity,

      dim_inactive     = true,
      dim_strength     = s.dim_strength,

      shadow           = {
        enabled      = true,
        range        = 4,
        render_power = 3,
        color        = c.shadow,
      },

      blur             = {
        enabled  = true,
        size     = s.blur_size,
        passes   = s.blur_passes,
        vibrancy = 0.3696,
      },
    },
  })
end

return M
