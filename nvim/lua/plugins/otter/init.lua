return {
  "jmbuhr/otter.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  ft = { "markdown", "quarto" },
  opts = {},
  config = function(_, opts)
    local otter = require("otter")
    otter.setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdown", "quarto" },
      callback = function()
        otter.activate(nil, true, false)
      end,
    })
  end,
}
