return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true, -- disables setting the background color.
      float = {
        transparent = true, -- enable transparent floating windows
        solid = true, -- use solid styling for floating windows, see |winborder|
      },
      color_overrides = {},
      highlight_overrides = {
        mocha = function(colors)
          return {
            WinSeparator = { fg = "orange", bold = true },
          }
        end,
      },
    },
  },
}
