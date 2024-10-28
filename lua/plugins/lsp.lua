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
                "vuels",
                "yamlls",
                "jsonls",
                "taplo",
                "vtsls",
                "html",
                "cssls",
                "omnisharp",
                "pylsp",
                "sqls",
            },
            automatic_installation = true,
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
                lspconfig[server_name].setup({
                    on_attach = lsp_attach,
                    capabilities = lsp_capabilities,
                })
            end,
        })

        -- vim.lsp.set_log_level("debug") -- 로그 레벨을 디버그로 설정

        -- custom install lsp Start
        lspconfig.ccls.setup {
            cmd = { "ccls" }, -- ccls 실행 파일의 경로 (PATH에 추가되어 있어야 함)
            init_options = {
                cache = {
                    directory = ".ccls-cache",
                },
            },
            root_dir = function(fname)
                return lspconfig.util.root_pattern(".ccls", "platformio.ini", ".git")(fname) or
                    vim.loop.cwd() -- 기본적으로 현재 작업 디렉토리 사용
            end,
            on_attach = function(client, bufnr)
                -- 여기에 추가적인 LSP 설정을 넣을 수 있습니다.
            end,
            capabilities = require('cmp_nvim_lsp').default_capabilities(), -- 자동 완성 기능 추가 시
        }
        -- custom install lsp End

        local open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or "rounded" -- Set border to rounded
            return open_floating_preview(contents, syntax, opts, ...)
        end
    end,
}
