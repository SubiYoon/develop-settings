local home = os.getenv("HOME")

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
				sql = { "sql_formatter" },
				c = { "clang-format" },
				cpp = { "clang-format" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = "fallback",
			},
		})
	end,
}
