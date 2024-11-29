local M = {}
M.npm_pids = {} -- 각 프로젝트의 PID 저장 테이블

-- npm install 함수
M.npm_install = function()
	-- npm 프로젝트 경로 입력 받기
	local path = vim.fn.input("Enter npm project path: ")

	if path == "" then
		print("Path is required.")
		return
	end

	-- 새로운 터미널 버퍼 생성
	local buf = vim.api.nvim_create_buf(false, true) -- 비표시(non-file), 임시 버퍼
	local term_win = nil

	-- 하단에 터미널 창 열기
	term_win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = vim.o.columns, -- 전체 너비
		height = 15, -- 높이 고정: 15
		row = vim.o.lines - 15, -- 화면 하단으로 배치
		col = 0, -- 왼쪽 끝에서 시작
		style = "minimal",
		border = "rounded", -- 테두리 스타일
	})

	-- 하단 터미널에서 명령 실행
	vim.fn.termopen({ "sh", "-c", "cd " .. path .. " && npm install" }, {
		on_exit = function(_, exit_code, _)
			-- 종료 시 창 닫기 또는 알림 표시
			if exit_code == 0 then
				print("npm install completed successfully!")
			else
				print("npm install failed with exit code: " .. exit_code)
			end

			-- 터미널 창 닫기
			if term_win and vim.api.nvim_win_is_valid(term_win) then
				vim.api.nvim_win_close(term_win, true)
			end
		end,
	})

	-- 터미널 창을 사용자가 이동할 수 있도록 설정
	vim.api.nvim_set_current_win(term_win)
end
-- M.npm_install = function()
--     -- npm 프로젝트 경로 입력 받기
--     local path = vim.fn.input("Enter npm project path!!")
--
--     if path == "" then
--         print("Path is required.")
--         return
--     end
--
--     -- npm install 실행
--     local result = vim.fn.system("cd " .. path .. " && npm install")
--     print(result)
-- end

-- npm run 스크립트 비동기 실행 및 PID 저장
M.start_npm_script = function()
	local path = vim.fn.input("Enter npm project path (e.g., ./test1): ")
	local script_cmd = vim.fn.input("Enter script command (default: dev): ")

	if path == "" then
		print("Path is required.")
		return
	end

	if script_cmd == "" then
		script_cmd = "dev"
	end

	-- 비동기적으로 npm run 스크립트 실행
	local handle = vim.loop.spawn("npm", {
		args = { "run", script_cmd },
		cwd = path,
		detached = true,
	}, function(code, signal)
		print("NPM script finished with code:", code, "signal:", signal)
	end)

	if handle then
		M.npm_pids[path] = handle:get_pid() -- 경로를 키로 사용하여 PID 저장
		print("Started npm script in " .. path .. " with PID: " .. M.npm_pids[path])
	else
		print("Failed to start npm script in " .. path)
	end
end

-- 특정 경로의 npm run 스크립트 종료
M.kill_npm_script = function()
	local path = vim.fn.input("Enter npm project path to kill (e.g., ./test1): ")
	local pid = M.npm_pids[path]

	if not pid then
		print("No running npm script found for " .. path)
		return
	end

	-- 비동기적으로 자식 프로세스 종료
	local kill_cmd = "kill -9 " .. pid
	local handle = vim.loop.spawn("sh", {
		args = { "-c", kill_cmd },
		detached = true,
	}, function(code, signal)
		print("Kill command finished with code:", code, "signal:", signal)
	end)

	if handle then
		print("Stopped npm script in " .. path .. " with PID: " .. pid)
		M.npm_pids[path] = nil -- PID 정보 삭제
	else
		print("Failed to kill npm script in " .. path)
	end
end
-- M.kill_npm_script = function()
-- 	local path = vim.fn.input("Enter npm project path to kill (e.g., ./test1): ")
-- 	local pid = M.npm_pids[path]
--
-- 	if not pid then
-- 		print("No running npm script found for " .. path)
-- 		return
-- 	end
--
-- 	-- 자식 프로세스 종료
-- 	local kill_cmd = "pkill -P " .. pid -- 부모 PID의 자식 프로세스 모두 종료
-- 	vim.fn.system(kill_cmd)
-- 	print("Stopped npm script in " .. path .. " with PID: " .. pid)
-- 	M.npm_pids[path] = nil -- PID 정보 삭제
-- end

-- 모든 npm 스크립트를 종료하는 함수
M.kill_all_npm_scripts = function()
	for path, pid in pairs(M.npm_pids) do
		if pid then
			-- PID를 이용해 비동기적으로 프로세스 종료
			local kill_cmd = "kill -9 " .. pid
			local handle = vim.loop.spawn("sh", {
				args = { "-c", kill_cmd },
				detached = true,
			}, function(code, signal)
				print("Kill command finished for path:", path, "with code:", code, "signal:", signal)
			end)

			if handle then
				print("Stopped npm script in " .. path .. " with PID: " .. pid)
				M.npm_pids[path] = nil -- PID 정보 삭제
			else
				print("Failed to kill npm script in " .. path)
			end
		end
	end
end

-- M.kill_all_npm_scripts = function()
-- 	for path, pid in pairs(M.npm_pids) do
-- 		if pid then
-- 			-- PID를 이용해 프로세스 종료
-- 			local result = vim.fn.system("kill " .. pid)
-- 			print("Stopped npm script in " .. path .. " with PID: " .. pid)
-- 			M.npm_pids[path] = nil -- PID 정보 삭제
-- 		end
-- 	end
-- end

return M
