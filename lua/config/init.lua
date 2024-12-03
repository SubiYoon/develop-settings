-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("utils.commonUtils").install_ripgrep()
require("utils.commonUtils").install_common_package()
require("config.globals")
require("config.options")

local plugins = "plugins"
local language = "plugins.language"
local opts = {}

-- Setup lazy.nvim
require("lazy").setup({
	{ import = plugins },
	{ import = language },
}, opts)

require("config.dap-config")
for _, file in ipairs(require("utils.commonUtils").list_files("config", "/lua/config/snippets", true, true)) do
	require("config.snippets." .. file)
end
require("config.keymaps")
require("config.autocmd")
