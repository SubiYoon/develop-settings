vim.g.mapleader = " "      -- global leader
vim.g.maplocalleader = " " -- local leader
vim.opt.shell = "/bin/zsh"
vim.opt.shellcmdflag = "-ic"
vim.opt.shellxquote = ""
vim.g.transparency = 0.8
-- 새로운 버퍼를 열었을 때 insert 모드로 자동 전환되는 것을 방지
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    -- 버퍼가 열릴 때 강제로 normal 모드로 전환
    if vim.api.nvim_get_mode().mode == 'i' then
      vim.cmd('stopinsert') -- insert 모드에서 나와 normal 모드로 전환
    end
  end
})
