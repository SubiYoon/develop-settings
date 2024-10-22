vim.g.mapleader = " "      -- global leader
vim.g.maplocalleader = " " -- local leader
vim.opt.shell = "/bin/zsh"
vim.opt.shellcmdflag = "-ic"
vim.opt.shellxquote = ""
vim.g.transparency = 0.8
-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    command = "stopinsert",
})
