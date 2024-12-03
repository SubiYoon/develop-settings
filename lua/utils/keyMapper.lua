--- 키맵핑 함수
---@param from string 입력키
---@param to any 동작키
---@param mode any 모드설정 (n, x, t, ...)
---@param opts table {desc = ${맵핑 설명}}
local keyMapper = function(from, to, mode, opts)
	local options = { noremap = true, silent = true } -- 노멀 모드에서만 맵핑
	mode = mode or "n"

	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	vim.keymap.set(mode, from, to, options)
end

return { mapKey = keyMapper }
