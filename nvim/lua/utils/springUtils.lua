local M = {}

-- ============================================================================
-- Build Tool Integration
-- ============================================================================

local function prompt_input(label, callback)
	vim.ui.input({ prompt = label .. ": " }, function(input)
		if input and input ~= "" then
			callback(input)
		else
			vim.notify("Task name is required.", vim.log.levels.ERROR)
		end
	end)
end

-- 하단 20% 비율로 터미널 열기 함수
local function open_terminal_with_command(cmd)
	local height = math.floor(vim.o.lines * 0.2)
	vim.cmd(height .. "split")
	vim.cmd("terminal " .. cmd)
	vim.cmd("startinsert")
end

function M.run_gradle_task()
	prompt_input("Enter Task Name", function(task_name)
		open_terminal_with_command("./gradlew " .. task_name)
	end)
end

function M.run_maven_task()
	prompt_input("Enter Task Name", function(task_name)
		open_terminal_with_command("./mvnw " .. task_name)
	end)
end

return M
