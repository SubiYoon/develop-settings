return {
  'nvim-java/nvim-java',
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("java").setup({})
  end
}
