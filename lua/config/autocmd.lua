-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    command = "stopinsert",
})
-- VimLeavePre 이벤트에 함수 연결
vim.api.nvim_create_autocmd("VimLeavePre", {
    command = 'lua require("utils.npmUtils").kill_all_npm_scripts()',
})
