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
				filter = function(bufnr)
					-- bufnr이 유효한 숫자인지 확인
					if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
						return false
					end
					-- 파일 형식 확인
					local filetype = vim.bo[bufnr].filetype
					return filetype ~= "html" -- HTML 제외
				end,
			},
		})
	end,
}
