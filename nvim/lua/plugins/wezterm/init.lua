return {
  "willothy/wezterm.nvim",
  cond = function()
    return vim.fn.has("win32") == 0
  end,
  config = true,
}
