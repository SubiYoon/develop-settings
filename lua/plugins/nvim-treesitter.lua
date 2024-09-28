return {
        "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = {"lua", "java", "javascript", "html", "json", "xml", "properties", "css", "yaml"},
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },
        })
    end
}
