local mapKey = require("utils.keymapper").mapKey
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope/builtin")
			mapKey("<leader>ff", builtin.find_files)
			mapKey("<leader>fw", builtin.live_grep)
			mapKey("<leader>fb", builtin.buffers)
			mapKey("<leader>fh", builtin.help_tags)
			mapKey("<leader>fr", builtin.oldfiles)
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
