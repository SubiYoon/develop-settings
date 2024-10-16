local keyMapper = require("utils/keyMapper").mapKey

return {
  "neovim/nvim-lspconfig",
  event = 'VeryLazy',
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },

  },
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
        "html",
        "cssls"
      },
    })

    require('mason-tool-installer').setup({
      ensure_installed = {
        "java-debug-adapter",
        'java-test',
        "google-java-format",
        "prettier",
        "prettierd",
        "eslint",
        "eslint_d",
      }
    })

    vim.api.nvim_command('MasonToolsInstall')

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lsp_attach = function(client, bufnr)
      -- crate keybinding... this
    end

    -- Call setup on each LSP server
    require('mason-lspconfig').setup_handlers({
      function(server_name)
        -- Don't call setup for JDTLS Java LSP because it will be setup from a separate config
        if server_name ~= 'jdtls' then
          lspconfig[server_name].setup({
            on_attach = lsp_attach,
            capabilities = lsp_capabilities,
          })
        end
      end
    })


    -- lua
    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            global = { 'vim' },
          }
        }
      }
    })
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
    -- xml
    lspconfig.lemminx.setup({})
    -- javascript
    lspconfig.vtsls.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
    })
    -- html
    lspconfig.html.setup({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      filetypes = { "html", "htm", "thymeleaf" },
    })
    -- css
    lspconfig.cssls.setup({})

    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded" -- Set border to rounded
      return open_floating_preview(contents, syntax, opts, ...)
    end
  end,
  opts = {
    servers = {
      -- jdtls = { enabled = true },
      vuels = { enabled = true },
      yamlls = { enabled = true },
      jsonls = { enabled = true },
      taplols = { enabled = true },
      lemminx = { enabled = true },
      lua_ls = { enabled = true },
    }
  },
}
