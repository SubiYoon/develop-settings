return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = {},
                java = {},
                css = { "prettierd", "prettier" },
                vue = { "prettierd", "prettier" },
                html = {},
                xml = { "prettierd", "prettier" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "first",
            },
        })
    end,
}
