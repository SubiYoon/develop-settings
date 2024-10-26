local common = require('utils.commonUtils')

vim.g.mapleader = " "      -- global leader
vim.g.maplocalleader = " " -- local leader
vim.opt.shell = "/bin/zsh"
vim.opt.shellcmdflag = "-ic"
vim.opt.shellxquote = ""
vim.g.transparency = 0.8
vim.opt.textwidth = 0
-- 주석줄에서 Enter시 자동 주석 해제
vim.opt_local.formatoptions:remove({ 'r', 'o' })
-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    command = "stopinsert",
})
-- xml에 쿼리문 자동 바인딩을 위한 파일타입 변경
vim.api.nvim_create_autocmd("FileType", {
    pattern = "xml",
    callback = function()
        vim.bo.filetype = "sql"
    end,
})
-- lspconfig 경고모양 변경
common.sign({ name = 'DiagnosticSignError', text = '🚨' })
common.sign({ name = 'DiagnosticSignWarn', text = '⚠️' })
common.sign({ name = 'DiagnosticSignHint', text = '✨' })
common.sign({ name = 'DiagnosticSignInfo', text = '🔍' })
