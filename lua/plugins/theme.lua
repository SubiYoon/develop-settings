return {
	-- gruvbox start
	-- "ellisonleao/gruvbox.nvim",
	-- priority = 1000,
	-- lazy = false,
	-- config = function()
	-- 	vim.cmd([[colorscheme gruvbox]])
	-- 	vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- 배경을 투명하게 설정
	-- end,
	-- opts = {},
	-- gruvbox end
	--
	-- one_monokai start
	"cpea2506/one_monokai.nvim",
	priority = 1000, -- Ensure it loads first
	config = function()
		vim.cmd([[colorscheme one_monokai]])
		vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- 배경을 투명하게 설정
	end,
	-- one_monokai end
}
