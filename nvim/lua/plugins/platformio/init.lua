return {
  "anurag3301/nvim-platformio.lua",
  dependencies = {
    { "akinsho/nvim-toggleterm.lua" },
    { "nvim-telescope/telescope.nvim" },
    { "nvim-lua/plenary.nvim" },
  },
  cond = function()
    return vim.fn.has("win32") == 0
  end,
  -- opts = {
  --     cmd = {
  --         "Pioinit",
  --         "Piorun",
  --         "Piocmd",
  --         "Piolib",
  --         "Piomon",
  --         "Piodebug",
  --         "Piodb",
  --     },
  -- }
}
