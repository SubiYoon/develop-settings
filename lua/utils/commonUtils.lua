local M = {}

-- tab의 너비 조절
M.widthResize = function()
    local width = vim.fn.input("input change size!!")

    if width == "" then
        print("please input size!!")
        return -1
    end

    vim.cmd("vertical resize " .. width)
end

-- tab의 높이 조절
M.heightResize = function()
    local height = vim.fn.input("input change size!!")

    if height == "" then
        print("please input size!!")
        return -1
    end

    vim.cmd("resize " .. height)
end

-- 필요한 공통 패키지 설치
M.install_common_package = function()
    -- OS 감지
    local uname = vim.loop.os_uname().sysname

    -- 설치 확인 함수
    local function is_installed(command)
        return os.execute("command -v " .. command .. " >/dev/null 2>&1") == 0
    end

    -- macOS 설치 함수
    local function install_on_mac(tool, brew_package)
        if not is_installed(tool) then
            print("Installing " .. tool .. " via Homebrew...")
            os.execute("brew install " .. brew_package .. " >/dev/null 2>&1")
        else
            -- print(tool .. " is already installed.")
        end
    end

    -- Windows 설치 함수
    local function install_on_windows(tool, choco_package)
        local function run_as_admin(command)
            local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" ..
                command .. "' -NoNewWindow -RedirectStandardOutput $null"
            os.execute('powershell -Command "' .. powershell_command .. '"')
        end

        if not is_installed(tool) then
            print("Installing " .. tool .. " via Chocolatey as Administrator...")
            run_as_admin("choco install " .. choco_package .. " -y")
        else
            -- print(tool .. " is already installed.")
        end
    end

    if uname == "Darwin" then
        -- macOS
        install_on_mac("lazygit", "lazygit")
        install_on_mac("rg", "ripgrep")
        install_on_mac("platformio", "platformio")
        install_on_mac("arduino-cli", "arduino-cli")
        install_on_mac("ccls", "ccls")
    elseif uname:find("Windows") then
        -- Windows
        install_on_windows("lazygit", "lazygit")
        install_on_windows("rg", "ripgrep")
        install_on_windows("platformio", "platformio")
        install_on_windows("arduino-cli", "arduino-cli")
        install_on_windows("ccls", "ccls")
    else
        print("Unsupported OS: " .. uname)
    end
end

M.install_ripgrep = function()
    -- OS 감지
    local uname = vim.loop.os_uname().sysname

    if uname == "Darwin" then
        -- macOS
        -- brew 설치 확인
        local brew_installed = os.execute("command -v brew >/dev/null 2>&1")
        if brew_installed ~= 0 then
            print("Homebrew not found, installing Homebrew...")
            os.execute(
                '/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"')
        else
            -- print("Homebrew is already installed.")
        end

        -- ripgrep 설치 확인
        local rg_installed = os.execute("command -v rg >/dev/null 2>&1")
        if rg_installed ~= 0 then
            print("Installing ripgrep via Homebrew...")
            os.execute("brew install ripgrep")
        else
            -- print("Ripgrep is already installed.")
        end
    elseif uname:find("Windows") then
        -- Windows
        print("Detected Windows")

        -- 관리 권한으로 명령 실행 함수
        local function run_as_admin(command)
            local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" .. command .. "'"
            os.execute('powershell -Command "' .. powershell_command .. '"')
        end

        -- chocolatey 설치 확인
        local choco_installed = os.execute("choco -v >/dev/null 2>&1")
        if choco_installed ~= 0 then
            print("Chocolatey not found, installing Chocolatey as Administrator...")
            run_as_admin(
                "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))")
        else
            -- print("Chocolatey is already installed.")
        end

        -- ripgrep 설치 확인
        local rg_installed = os.execute("rg --version >/dev/null 2>&1")
        if rg_installed ~= 0 then
            print("Installing ripgrep via Chocolatey as Administrator...")
            run_as_admin("choco install ripgrep -y")
        else
            -- print("Ripgrep is already installed.")
        end
    else
        print("Unsupported OS: " .. uname)
    end
end

M.new_doc = function()
    local doc_type = vim.fn.input("c: class, f: function, F: file, t: type")
    if doc_type == 'c' then
        doc_type = 'class'
    elseif doc_type == 'f' then
        doc_type = 'func'
    elseif doc_type == 'F' then
        doc_type = 'file'
    elseif doc_type == 't' then
        doc_type = 'type'
    elseif doc_type == '' then
        print("please select current type!!")
        return -1
    end

    vim.cmd("Neogen " .. doc_type)
end

-- 터미널을 20% 하단에 열고 닫는 토글 기능 설정
M.toggle_terminal = function(size)
    local term_buf = vim.fn.bufnr("term://*")

    if size == nil then
        size = 20
    end
    if term_buf == -1 then
        -- 터미널이 열려있지 않으면 새로 열기
        vim.cmd("botright split")  -- 화면 하단에 가로로 분할
        vim.cmd("resize " .. size) -- 터미널 크기 설정
        vim.cmd("term")            -- 터미널 열기

        -- 열 때는 barbar의 탭에 나타나지 않도록 처리
        vim.cmd("setlocal nobuflisted") -- 버퍼리스트에 나타나지 않도록 설정
    else
        -- 터미널이 열려있으면 숨기기/복원 처리
        local term_win = vim.fn.bufwinid(term_buf) -- 해당 터미널 창의 ID 확인

        if term_win == -1 then
            -- 터미널이 숨겨져 있으면 복원
            vim.cmd("botright split")              -- 화면 하단에 가로로 분할
            vim.cmd("resize 20")                   -- 터미널 크기 설정
            vim.cmd("buffer " .. term_buf)         -- 해당 버퍼로 돌아가서 복원
            vim.cmd("wincmd p")                    -- 창 복원
            vim.cmd("wincmd w")                    -- 터미널 커서이동
        else
            local current_win = vim.fn.win_getid() -- 현재 창 ID 확인
            local term_win_id = vim.fn.bufwinid(term_buf)

            if current_win == term_win_id then
                vim.cmd("hide") -- 터미널 커서이동
            else
                print("터미널 창으로 커서를 이동해주세요.")
            end
        end
    end
end

-- C언어 컴파일
M.c_complie = function()
    -- 현재 열려 있는 파일 경로
    local file = vim.api.nvim_buf_get_name(0)

    -- 파일이 .c 확장자인지 확인
    if file:match("%.c$") then
        -- 현재 파일 저장
        vim.cmd('write')

        -- 파일이름만 추출
        -- t: 경로에서 이름만 추출
        -- r: 이름에서 확장자 제거
        local output_file = vim.fn.fnamemodify(file, ":t:r")

        -- gcc 명령어 실행
        local compile_cmd = "clang " .. file .. " -o " .. vim.fn.getcwd() .. "/" .. output_file
        local result = vim.fn.system(compile_cmd)

        -- 컴파일 결과 출력
        if vim.v.shell_error == 0 then
            print("컴파일 성공: " .. output_file)
        else
            print("컴파일 실패:\n" .. result)
        end
    else
        print("이 파일은 C 파일이 아닙니다.")
    end
end

-- 현재 열려있는 파일의 컴파일한 파일을 찾아 실행
M.c_run = function()
    local input_file = vim.fn.input("input compile file path!! (default: root_dir)")
    -- 현재 열려 있는 파일 경로
    local file = nil
    if input_file ~= "" then
        file = vim.fn.getcwd() .. "/" .. input_file
    else
        file = vim.api.nvim_buf_get_name(0)

        -- 파일이 .c 확장자인지 확인
        if file:match("%.c$") then
            -- 현재 파일 저장
            vim.cmd('write')
            -- 파일이름만 추출
            -- t: 경로에서 이름만 추출
            -- r: 이름에서 확장자 제거
        else
            print("이 파일은 C 파일이 아닙니다.")
        end
    end

    local output_file = vim.fn.fnamemodify(file, ":t:r")

    if output_file == "" then
        print("파일이 존재하지 않습니다.")
        return -1
    end

    -- gcc 명령어 실행
    local run_cmd = vim.fn.getcwd() .. "/" .. output_file
    local result = vim.fn.system(run_cmd)

    -- 컴파일 결과 출력
    if vim.v.shell_error == 0 then
        print("실행 성공: " .. output_file)
    else
        print("컴파일 실패:\n" .. result)
    end
end

return M
