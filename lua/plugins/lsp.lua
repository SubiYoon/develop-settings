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
				"google-java-format",
				"java-debug-adapter",
				"java-test",
				"prettier",
				"prettierd",
				"eslint",
				"eslint_d",
				"sql-formatter",
				"stylua",
				"codelldb", -- C++ debug
				"clang-format",
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

		-- vim.lsp.set_log_level("debug") -- 로그 레벨을 디버그로 설정

		-- C/C++ 선택 함수
		local function select_lsp_by_platformio()
			local project_root = vim.fn.getcwd()

			-- platformio.ini 파일이 존재하면 ccls를 사용
			if vim.fn.filereadable(project_root .. "/platformio.ini") == 1 then
				return "ccls"
			else
				return "clangd"
			end
		end

		local lsp_name = select_lsp_by_platformio()
		if lsp_name == "ccls" then
			lspconfig.ccls.setup({
				cmd = { "ccls" }, -- ccls 실행 파일의 경로 (PATH에 추가되어 있어야 함)
				init_options = {
					cache = { directory = ".ccls-cache" },
					clang = { extraArgs = { "-std=c11", "-std=c17" } },
				},
				root_dir = function(fname)
					return lspconfig.util.root_pattern(".ccls", "platformio.ini")(fname) or vim.loop.cwd() -- 기본적으로 현재 작업 디렉토리 사용
				end,
				on_attach = lsp_attach,
				capabilities = require("cmp_nvim_lsp").default_capabilities(), -- 자동 완성 기능 추가 시
			})
		elseif lsp_name == "clangd" then
			lspconfig.clangd.setup({
				cmd = { "clangd", "--header-insertion=always" }, -- ccls 실행 파일의 경로 (PATH에 추가되어 있어야 함)
				init_options = {
					clang = { extraArgs = { "-std=c11", "-std=c17" } },
				},
				root_dir = function(fname)
					return lspconfig.util.root_pattern("compile_commands.json", ".git")(fname) or vim.loop.cwd() -- 기본적으로 현재 작업 디렉토리 사용
				end,
				on_attach = lsp_attach,
				capabilities = require("cmp_nvim_lsp").default_capabilities(), -- 자동 완성 기능 추가 시
			})
		end

		local open_floating_preview = vim.lsp.util.open_floating_preview
		function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
			opts = opts or {}
			opts.border = opts.border or "rounded" -- Set border to rounded
			return open_floating_preview(contents, syntax, opts, ...)
		end
	end,
}
