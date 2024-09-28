return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { { "prettierd", "prettier" } },
				java = { { "prettierd", "prettier" } },
				vue = { { "prettierd", "prettier" } },
				html = { { "prettierd", "prettier" } },
				xml = { { "prettierd", "prettier" } },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_format = true,
			},
		})
	end,
}
