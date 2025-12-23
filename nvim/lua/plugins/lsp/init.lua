-- add pyright to lspconfig
return {
  "neovim/nvim-lspconfig",
  ---@class PluginLspOpts
  opts = {
    ---@type lspconfig.options
    servers = {
      -- pyright will be automatically installed with mason and loaded with lspconfig
      pyright = {
        enabled = true,
      },
      jdtls = {},
      lua_ls = {},
      ruff = {
        enabled = false,
      },
      -- SQL LSP
      sqls = {
        settings = {
          sqls = {
            -- DB 연결은 DBee와 별도로 설정하거나 비워둠
            -- connections = {
            --   {
            --     driver = "mysql",
            --     dataSourceName = "user:password@tcp(localhost:3306)/dbname",
            --   },
            -- },
          },
        },
      },
    },
  },
}
