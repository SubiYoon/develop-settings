return {
	"nvim-java/nvim-java",
	dependencies = { "neovim/nvim-lspconfig" },
	priority = 1000, -- Ensure it loads first
	config = function()
		require("java").setup({})
	end,
}
