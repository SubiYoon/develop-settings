local keyMapper = require("utils/keyMapper").mapKey

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "jdtls",
          "vuels",
          "yamlls",
          "jsonls",
          "taplo",
          "lemminx",
          "vtsls",
        },
      })
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          "google-java-format",
          "prettier",
          "eslint",
          "eslint_d",
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- lua
      lspconfig.lua_ls.setup({})
      -- java
      lspconfig.jdtls.setup({})
      -- vue
      lspconfig.vuels.setup({})
      -- yaml
      lspconfig.yamlls.setup({})
      -- json
      lspconfig.jsonls.setup({})
      -- toml
      lspconfig.taplo.setup({})
      -- css
      lspconfig.lemminx.setup({})
      -- javascript
      lspconfig.vtsls.setup({})
    end,
  },
}
