return {
	"neovim/nvim-lspconfig",
	event = "VeryLazy",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- { "j-hui/fidget.nvim", opts = {} },
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
				"taplo",
				"omnisharp",
			},
			automatic_installation = true,
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"stylua",
				"codelldb", -- C++ debug
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
				if server_name ~= "clangd" then
					lspconfig[server_name].setup({
						on_attach = lsp_attach,
						capabilities = lsp_capabilities,
					})
				end
			end,
		})

		local open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded" -- Set border to rounded
			return open_floating_preview(contents, syntax, opts, ...)
		end
	end,
}
