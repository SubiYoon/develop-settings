-- ===========================
--    COLOR SCHEME (Catppuccin-Mocha)
-- ===========================

local module = {}

function module.apply_to_config(config)
  config.color_scheme = 'Catppuccin Mocha'

  -- Catppuccin-Mocha 색상 커스터마이징
  config.colors = {
    -- The basic colors
    foreground = '#CDD6F4',
    background = '#1E1E2E',
    cursor_bg = '#F5E0DC',
    cursor_fg = '#1E1E2E',
    cursor_border = '#F5E0DC',
    selection_fg = '#1E1E2E',
    selection_bg = '#F5E0DC',

    -- The 16 terminal colors
    ansi = {
      '#45475A', -- black
      '#F38BA8', -- red
      '#A6E3A1', -- green
      '#F9E2AF', -- yellow
      '#89B4FA', -- blue
      '#F5C2E7', -- magenta
      '#94E2D5', -- cyan
      '#BAC2DE', -- white
    },
    brights = {
      '#585B70', -- bright black
      '#F38BA8', -- bright red
      '#A6E3A1', -- bright green
      '#F9E2AF', -- bright yellow
      '#89B4FA', -- bright blue
      '#F5C2E7', -- bright magenta
      '#94E2D5', -- bright cyan
      '#A6ADC8', -- bright white
    },

    -- Tab bar colors
    tab_bar = {
      background = '#11111B',
      active_tab = {
        bg_color = '#CBA6F7',
        fg_color = '#11111B',
        intensity = 'Bold',
        italic = true,
      },
      inactive_tab = {
        bg_color = '#181825',
        fg_color = '#CDD6F4',
      },
      inactive_tab_hover = {
        bg_color = '#313244',
        fg_color = '#CDD6F4',
      },
      new_tab = {
        bg_color = '#11111B',
        fg_color = '#CDD6F4',
      },
      new_tab_hover = {
        bg_color = '#313244',
        fg_color = '#CDD6F4',
      },
    },

    -- Split/Pane border colors (kitty의 window_border 대응)
    split = '#B4BEFE', -- active border (Catppuccin lavender)
  }
end

return module
