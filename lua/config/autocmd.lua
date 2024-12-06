-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	command = "stopinsert",
})
-- VimLeavePre 이벤트(모든 NPM프로 젝트 실행 종료)
vim.api.nvim_create_autocmd("VimLeavePre", {
	command = 'lua require("utils.npmUtils").kill_all_npm_scripts()',
})
-- VimLeavePre 이벤트(messages에 담겼던 내용 log로 저장)
-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	command = "redir > ~/.local/share/nvim/nvim_exit_messages.log | messages | redir",
-- })
