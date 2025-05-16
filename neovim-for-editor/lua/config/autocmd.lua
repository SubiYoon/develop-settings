-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	command = "stopinsert",
})
