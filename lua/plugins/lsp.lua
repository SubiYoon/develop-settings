local keyMapper = require("utils/keyMapper").mapKey

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
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
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      -- lua
      lspconfig.lua_ls.setup({}
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

      -- vim.lsp.buf.hover
      -- vim.lsp.buf.definition
      -- vim.lsp.buf.code_action
      keyMapper("K", vim.lsp.buf.hover)
      keyMapper("gd", vim.lsp.buf.definition)
      keyMapper("gr", vim.lsp.buf.references)
      keyMapper("<leader>ca", vim.lsp.buf.code_action)
    end,
  },
}
