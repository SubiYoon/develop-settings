local M = {}
M.npm_pids = {} -- 각 프로젝트의 PID 저장 테이블

-- npm install 함수
M.npm_install = function()
    -- npm 프로젝트 경로 입력 받기
    local path = vim.fn.input("Enter npm project path!!")

    if path == "" then
        print("Path is required.")
        return
    end

    -- npm install 실행
    local result = vim.fn.system("cd " .. path .. " && npm install")
    print(result)
end

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

    -- 자식 프로세스 종료
    local kill_cmd = "pkill -P " .. pid -- 부모 PID의 자식 프로세스 모두 종료
    vim.fn.system(kill_cmd)
    print("Stopped npm script in " .. path .. " with PID: " .. pid)
    M.npm_pids[path] = nil -- PID 정보 삭제
end

-- 모든 npm 스크립트를 종료하는 함수
M.kill_all_npm_scripts = function()
    for path, pid in pairs(M.npm_pids) do
        if pid then
            -- PID를 이용해 프로세스 종료
            local result = vim.fn.system("kill " .. pid)
            print("Stopped npm script in " .. path .. " with PID: " .. pid)
            M.npm_pids[path] = nil -- PID 정보 삭제
        end
    end
end

return M
