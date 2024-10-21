return {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        { "j-hui/fidget.nvim", opts = {} },
        { "folke/neodev.nvim", opts = {} },
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
                "cssls",
                "clangd",
                "omnisharp"
            },
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                "java-debug-adapter",
                "java-test",
                "google-java-format",
                "prettier",
                "prettierd",
                "eslint",
                "eslint_d",
            },
        })

        vim.api.nvim_command("MasonToolsInstall")

        local lspconfig = require("lspconfig")
        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
        local lsp_attach = function(client, bufnr)
            -- crate keybinding... this
        end

        -- Call setup on each LSP server
        require("mason-lspconfig").setup_handlers({
            function(server_name)
                -- Don't call setup for JDTLS Java LSP because it will be setup from a separate config
                if server_name ~= "jdtls" then
                    lspconfig[server_name].setup({
                        on_attach = lsp_attach,
                        capabilities = lsp_capabilities,
                    })
                end
            end,
        })

        local home = os.getenv("HOME")

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
        -- xml
        lspconfig.lemminx.setup({})
        -- javascript
        lspconfig.vtsls.setup({})
        -- html
        lspconfig.html.setup({})
        -- css
        lspconfig.cssls.setup({})
        -- C
        lspconfig.clangd.setup({
            cmd = { "clangd" },
            filetypes = { "c", "cpp", "objc", "objcpp" },        -- 지원 파일 타입
            root_dir = require 'lspconfig'.util.root_pattern(".git", "compile_commands.json", "compile_flags.txt",
                "Makefile", "CMakeLists.txt"),
            capabilities = require('cmp_nvim_lsp').default_capabilities(), -- nvim-cmp와 연동 시 사용
        })
        -- C#
        lspconfig.omnisharp.setup({
            cmd = { "omnisharp" },
            filetypes = { "cs", "vb" },
            init_options = { formatting = true },
            root_dir = require('lspconfig').util.root_pattern(".git", ".csproj"),
        })

        local open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or "rounded" -- Set border to rounded
            return open_floating_preview(contents, syntax, opts, ...)
        end
    end,
    opts = {
        servers = {
            jdtls = { enabled = true },
            vuels = { enabled = true },
            yamlls = { enabled = true },
            jsonls = { enabled = true },
            taplols = { enabled = true },
            lemminx = { enabled = true },
            lua_ls = { enabled = true },
        },
    },
}
