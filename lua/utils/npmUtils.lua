local M = {}
local toggleterm = require("toggleterm.terminal").Terminal
M.npm_pids = M.npm_pids or {} -- npm 스크립트별 Job ID 저장
M.npm_terminals = M.npm_terminals or {} -- 프로젝트 경로별 터미널 관리
M.terminal_buffers = M.terminal_buffers or {} -- 출력 데이터를 위한 버퍼 관리

--- npm install 함수
M.npm_install = function()
	-- npm 프로젝트 경로 입력 받기
	local path = vim.fn.input("Enter npm project path (ex: ./tset1) ")

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
			-- if term_win and vim.api.nvim_win_is_valid(term_win) then
			-- 	vim.api.nvim_win_close(term_win, true)
			-- end
		end,
	})

	-- 터미널 창을 사용자가 이동할 수 있도록 설정
	vim.api.nvim_set_current_win(term_win)
end

--- npm 스크립트 실행 함수
M.start_npm_script = function()
	local path = vim.fn.input("Enter npm project path (ex: ./test1): ")
	local script_cmd = vim.fn.input("Enter script command (default: dev): ")

	if path == "" then
		print("Path is required.")
		return
	end

	if script_cmd == "" then
		script_cmd = "dev"
	end

	-- npm 실행 명령어 설정
	local cmd = { "npm", "run", script_cmd }

	-- 출력 데이터를 저장할 새로운 버퍼 생성
	local buf_nr = vim.api.nvim_create_buf(false, true)
	M.terminal_buffers[path] = buf_nr

	-- 비동기적으로 npm run 스크립트 실행
	local job_id = vim.fn.jobstart(cmd, {
		cwd = path, -- 실행 경로 설정
		on_exit = function(_, code, signal)
			print("NPM script finished with code:", code, "signal:", signal)
			-- 작업 종료 시 PID 및 터미널 정보 삭제
			M.npm_pids[path] = nil
			M.npm_terminals[path] = nil
			M.terminal_buffers[path] = nil
		end,
		on_stderr = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						-- 터미널 버퍼에 실시간 출력
						vim.api.nvim_buf_set_lines(M.terminal_buffers[path], -1, -1, false, { "Error: " .. line })
					end
				end
			end
		end,
		on_stdout = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						-- 터미널 버퍼에 실시간 출력
						vim.api.nvim_buf_set_lines(M.terminal_buffers[path], -1, -1, false, { line })
					end
				end
			end
		end,
	})

	if job_id > 0 then
		M.npm_pids[path] = job_id -- 경로를 키로 사용하여 Job ID 저장

		-- 해당 경로의 터미널 생성 및 관리
		if not M.npm_terminals[path] then
			M.npm_terminals[path] = toggleterm:new({
				cmd = "", -- 초기 명령어 없이 생성
				close_on_exit = false,
				auto_scroll = true,
				direction = "horizontal", -- 터미널 방향: 하단 창
				size = 15, -- 터미널 창 크기 (15라인)
				on_open = function(term)
					-- 터미널이 열리면 출력 데이터를 설정한 버퍼로 연동
					vim.api.nvim_win_set_buf(term.window, M.terminal_buffers[path])
				end,
			})
		end

		print("Started npm script in " .. path .. " with Job ID: " .. job_id)
	else
		print("Failed to start npm script in " .. path)
	end
end

--- 터미널 출력 창 열기 함수
M.open_npm_terminal = function()
	local path = vim.fn.input("Enter npm project path to view logs (ex: ./test) ")

	if not M.npm_terminals[path] then
		print("No active terminal for this path: " .. path)
		return
	end

	-- 터미널 창을 하단 15라인 크기로 열기
	local term = M.npm_terminals[path]
	-- 열려 있는 터미널이 있다면, 기존 터미널 옆에 `vsplit`로 열기
	if vim.fn.bufexists(term.buffer) == 1 then
		-- `vsplit`으로 현재 터미널 창을 열기
		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, term.buffer)
	else
		-- 새로 터미널을 열기
		term:toggle()
	end
end

--- 특정 경로의 npm run 스크립트 종료
M.kill_npm_script = function()
	local path = vim.fn.input("Enter npm project path to stop (ex: ./test1): ")

	if path == "" or not M.npm_pids[path] then
		print("No running npm script found for the given path.")
		return
	end

	-- 실행 중인 Job ID 종료
	local job_id = M.npm_pids[path]
	vim.fn.jobstop(job_id)
	M.npm_pids[path] = nil
	print("Stopped npm script in " .. path)
end

--- 모든 npm 스크립트를 종료하는 함수
M.kill_all_npm_scripts = function()
	if not next(M.npm_pids) then
		print("No running npm scripts to stop.")
		return
	end

	for path, job_id in pairs(M.npm_pids) do
		if job_id then
			-- 실행 중인 Job ID 종료
			vim.fn.jobstop(job_id)
			print("Stopped npm script in " .. path .. " (Job ID: " .. job_id .. ")")
			M.npm_pids[path] = nil -- Job ID 정보 삭제
		else
			print("No valid Job ID found for path: " .. path)
		end
	end
end

return M
