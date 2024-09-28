return {
	{
		"goolord/alpha-nvim",
		-- dependencies = { 'echasnovski/mini.icons' },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- set header
			dashboard.section.header.val = {
				"                                                                           ",
				"                                                                           ",
				" █████╗ ██████╗  ██████╗    ████████╗ ██████╗     ██████╗ ███████╗██╗   ██╗",
				"██╔══██╗██╔══██╗██╔════╝    ╚══██╔══╝██╔═══██╗    ██╔══██╗██╔════╝██║   ██║",
				"███████║██████╔╝██║            ██║   ██║   ██║    ██║  ██║█████╗  ██║   ██║",
				"██╔══██║██╔══██╗██║            ██║   ██║   ██║    ██║  ██║██╔══╝  ╚██╗ ██╔╝",
				"██║  ██║██████╔╝╚██████╗       ██║   ╚██████╔╝    ██████╔╝███████╗ ╚████╔╝ ",
				"╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝    ╚═════╝     ╚═════╝ ╚══════╝  ╚═══╝  ",
				"                                                                           ",
				"                                                                           ",
				"                                                                           ",
				"gcc : single line comment                                                  ",
				"gc  : multi line comment                                                   ",
				"                                                                           ",
				"za  : single group fold/unfold                                             ",
				"zM  : all group fold                                                       ",
				"zR  : all group unfold                                                     ",
			}

			-- set memu button
			dashboard.section.buttons.val = {
				dashboard.button("n", "📝  > New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("f", "📁  > Find file", ":Telescope find_files<CR>"),
				dashboard.button("w", "🔍  > Find Word", ":Telescope live_grep <CR>"),
				dashboard.button("r", "🗂️  > Recent", ":Telescope oldfiles<CR>"),
				dashboard.button("q", "🚪  > Quit NVIM", ":qa<CR>"),
			}

			alpha.setup(dashboard.opts)
		end,
	},
}
