return {
  "cpea2506/one_monokai.nvim",
  priority = 1000, -- Ensure it loads first
  lazy = false,
  opts = {},
  config = function()
    vim.cmd([[colorscheme one_monokai]])
    vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- 배경을 투명하게 설정
  end,
}
