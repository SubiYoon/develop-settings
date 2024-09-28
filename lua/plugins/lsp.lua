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
					"nginx_language_server",
					"vuels",
					"yamlls",
					"jsonls",
					"taplo",
					"ast_grep",
					"lemminx",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({})
			lspconfig.jdtls.setup({})
			lspconfig.nginx_language_server.setup({})
			lspconfig.vuels.setup({})
			lspconfig.yamlls.setup({})
			lspconfig.jsonls.setup({})
			lspconfig.taplo.setup({})
			lspconfig.ast_grep.setup({})
			lspconfig.lemminx.setup({})

			-- vim.lsp.buf.hover
			-- vim.lsp.buf.definition
			-- vim.lsp.buf.code_action
			keyMapper("K", vim.lsp.buf.hover)
			keyMapper("gd", vim.lsp.buf.definition)
			keyMapper("<leader>ca", vim.lsp.buf.code_action)
		end,
	},
}
