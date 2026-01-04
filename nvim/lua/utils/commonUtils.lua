local M = {}

-- 인터넷 연결 상태 캐시 (세션당 1회만 체크)
local internet_status = nil

--- 인터넷 연결 확인 (Google DNS에 ping)
---@param force_check boolean|nil 강제로 다시 체크할지 여부
---@return boolean 인터넷 연결 여부
M.has_internet = function(force_check)
  -- 캐시된 결과가 있고 강제 체크가 아니면 캐시 반환
  if internet_status ~= nil and not force_check then
    return internet_status
  end

  local uname = vim.loop.os_uname().sysname
  local cmd

  if uname == "Darwin" or uname == "Linux" then
    -- macOS/Linux: ping 1회, 타임아웃 1초
    cmd = "ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1"
  elseif uname:find("Windows") then
    -- Windows: ping 1회, 타임아웃 1000ms
    cmd = "ping -n 1 -w 1000 8.8.8.8 >nul 2>&1"
  else
    internet_status = false
    return false
  end

  local result = os.execute(cmd)
  internet_status = (result == 0 or result == true)

  return internet_status
end

--- 인터넷 필요 플러그인용 조건 함수 (lazy.nvim cond에 사용)
---@return boolean
M.require_internet = function()
  return M.has_internet()
end

--- 키맵핑 함수
---@param from string 입력키
---@param to any 동작키
---@param mode any 모드설정 (n, x, t, ...)
---@param opts table {desc = ${맵핑 설명}}
M.mapKey = function(from, to, mode, opts)
  local options = { noremap = true, silent = true } -- 노멀 모드에서만 맵핑
  mode = mode or "n"

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  vim.keymap.set(mode, from, to, options)
end

--- lsp 경고별 모양 설정 함수
--- @param opts table {name : 경고이름, text : 아이콘}
M.sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = "",
  })
end

--- tab의 너비 조절
M.widthResize = function()
  local width = vim.fn.input("input change size!!")

  if width == "" then
    print("please input size!!")
    return -1
  end

  vim.cmd("vertical resize " .. width)
end

--- tab의 높이 조절
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
    local handle = vim.loop.spawn("command", {
      args = { "-v", command },
      stdio = { nil, vim.loop.new_pipe(false), vim.loop.new_pipe(false) },
      on_exit = function(code, signal)
        return code == 0
      end,
    })
    return handle
  end

  -- 비동기 실행 함수
  local function run_async(command, callback)
    local handle = vim.loop.spawn(command, {
      args = {},
      stdio = { nil, vim.loop.new_pipe(false), vim.loop.new_pipe(false) },
      on_exit = function(code, signal)
        if callback then
          callback(code, signal)
        end
      end,
    })

    if not handle then
      print("Failed to start process for: " .. command)
    end
  end

  -- macOS 설치 함수
  local function install_on_mac(tool, brew_package)
    if not is_installed(tool) then
      print("Installing " .. tool .. " via Homebrew...")
      run_async("brew", function(code, signal)
        if code == 0 then
          print(tool .. " installed successfully.")
        else
          print("Failed to install " .. tool)
        end
      end)
    else
      -- print(tool .. " is already installed.")
    end
  end

  -- Windows 설치 함수
  local function install_on_windows(tool, choco_package)
    local function run_as_admin(command)
      local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" .. command .. "' -NoNewWindow -RedirectStandardOutput $null"
      run_async('powershell -Command "' .. powershell_command .. '"', function(code, signal)
        if code == 0 then
          print(tool .. " installed successfully.")
        else
          print("Failed to install " .. tool)
        end
      end)
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
    install_on_mac("go", "go")
    install_on_mac("luarocks", "luarocks")
  elseif uname:find("Windows") then
    -- Windows
    install_on_windows("lazygit", "lazygit")
    install_on_windows("rg", "ripgrep")
    install_on_windows("platformio", "platformio")
    install_on_windows("arduino-cli", "arduino-cli")
    install_on_windows("ccls", "ccls")
    install_on_windows("go", "go")
    install_on_windows("luarocks", "luarocks")
  else
    print("Unsupported OS: " .. uname)
  end
end

--- OS감지하여 ripgrep 설치
M.install_ripgrep = function()
  -- OS 감지
  local uname = vim.loop.os_uname().sysname

  local function run_async(command, callback)
    vim.loop.spawn(command, {
      args = {},
      stdout = vim.loop.new_pipe(false),
      stderr = vim.loop.new_pipe(false),
      detached = true,
    }, function(code, signal)
      if code == 0 then
        print("Command completed successfully.")
      else
        print("Command failed with code:", code, "and signal:", signal)
      end
      if callback then
        callback()
      end
    end)
  end

  if uname == "Darwin" then
    -- macOS
    -- brew 설치 확인
    local function check_and_install_brew()
      local brew_installed = vim.fn.system("command -v brew >/dev/null 2>&1")
      if vim.v.shell_error ~= 0 then
        print("Homebrew not found, installing Homebrew...")
        run_async("/bin/bash", function()
          vim.fn.system('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
        end)
      else
        -- print("Homebrew is already installed.")
      end
    end

    local function check_and_install_ripgrep()
      local rg_installed = vim.fn.system("command -v rg >/dev/null 2>&1")
      if vim.v.shell_error ~= 0 then
        print("Installing ripgrep via Homebrew...")
        run_async("brew", function()
          vim.fn.system("brew install ripgrep")
        end)
      else
        -- print("Ripgrep is already installed.")
      end
    end

    check_and_install_brew()
    check_and_install_ripgrep()
  elseif uname:find("Windows") then
    -- Windows
    print("Detected Windows")

    -- 관리 권한으로 명령 실행 함수
    local function run_as_admin(command, callback)
      local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" .. command .. "'"
      vim.fn.system('powershell -Command "' .. powershell_command .. '"')
      if callback then
        callback()
      end
    end

    -- chocolatey 설치 확인
    local function check_and_install_choco()
      local choco_installed = vim.fn.system("choco -v >/dev/null 2>&1")
      if vim.v.shell_error ~= 0 then
        print("Chocolatey not found, installing Chocolatey as Administrator...")
        run_as_admin(
          "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
          function()
            print("Chocolatey installation command executed.")
          end
        )
      else
        -- print("Chocolatey is already installed.")
      end
    end

    local function check_and_install_ripgrep()
      local rg_installed = vim.fn.system("rg --version >/dev/null 2>&1")
      if vim.v.shell_error ~= 0 then
        print("Installing ripgrep via Chocolatey as Administrator...")
        run_as_admin("choco install ripgrep -y", function()
          print("Ripgrep installation command executed.")
        end)
      else
        -- print("Ripgrep is already installed.")
      end
    end

    check_and_install_choco()
    check_and_install_ripgrep()
  else
    print("Unsupported OS: " .. uname)
  end
end

--- custom document 생성
M.new_doc = function()
  local doc_type = vim.fn.input("c: class, f: function, F: file, t: type")
  if doc_type == "c" then
    doc_type = "class"
  elseif doc_type == "f" then
    doc_type = "func"
  elseif doc_type == "F" then
    doc_type = "file"
  elseif doc_type == "t" then
    doc_type = "type"
  elseif doc_type == "" then
    print("please select current type!!")
    return -1
  end

  vim.cmd("Neogen " .. doc_type)
end

--- 터미널을 20% 하단에 열고 닫는 토글 기능 설정
M.toggle_terminal = function(size)
  local term_buf = vim.fn.bufnr("term://*")

  if size == nil then
    size = 20
  end
  if term_buf == -1 then
    -- 터미널이 열려있지 않으면 새로 열기
    vim.cmd("botright split") -- 화면 하단에 가로로 분할
    vim.cmd("resize " .. size) -- 터미널 크기 설정
    vim.cmd("term") -- 터미널 열기

    -- 열 때는 barbar의 탭에 나타나지 않도록 처리
    vim.cmd("setlocal nobuflisted") -- 버퍼리스트에 나타나지 않도록 설정
  else
    -- 터미널이 열려있으면 숨기기/복원 처리
    local term_win = vim.fn.bufwinid(term_buf) -- 해당 터미널 창의 ID 확인

    if term_win == -1 then
      -- 터미널이 숨겨져 있으면 복원
      vim.cmd("botright split") -- 화면 하단에 가로로 분할
      vim.cmd("resize 20") -- 터미널 크기 설정
      vim.cmd("buffer " .. term_buf) -- 해당 버퍼로 돌아가서 복원
      vim.cmd("wincmd p") -- 창 복원
      vim.cmd("wincmd w") -- 터미널 커서이동
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

--- main파일 컴파일
M.c_complie = function()
  local file = vim.api.nvim_buf_get_name(0)

  -- 파일이 .c 또는 .cpp 확장자인지 확인
  if file:match("%.c$") or file:match("%.cpp$") then
    -- 현재 파일 저장
    vim.cmd("write")

    -- 현재 파일의 디렉토리 가져오기
    local dir = vim.fn.fnamemodify(file, ":h")

    -- 소스 파일을 저장할 테이블
    local sources = {}

    -- 터미널 출력 내용을 처리하는 콜백 함수
    local function on_stdout(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(sources, line)
          end
        end
      end
    end

    -- `find` 명령 실행
    local sources_cmd = { "find", dir, "-type", "f", "-name", "*.c", "-o", "-name", "*.cpp" }
    vim.fn.jobstart(sources_cmd, {
      stdout_buffered = true,
      on_stdout = on_stdout,
      on_exit = function()
        -- 소스 파일이 없으면 종료
        if #sources == 0 then
          print("컴파일할 .c 또는 .cpp 파일이 없습니다.")
          return
        end

        -- 소스 파일을 공백으로 구분된 문자열로 변환
        local sources_str = table.concat(sources, " ")
        print("컴파일할 파일들: " .. sources_str)

        -- 파일 이름만 추출 (확장자 제외)
        local output_file = vim.fn.fnamemodify(file, ":t:r")
        local output_path = vim.fn.getcwd() .. "/" .. output_file

        -- 컴파일 명령 실행
        local compile_cmd = { "clang", "-g", "-o", output_path }
        for _, src in ipairs(sources) do
          table.insert(compile_cmd, src)
        end

        vim.fn.jobstart(compile_cmd, {
          stdout_buffered = true,
          on_stdout = function(_, data, _)
            if data then
              for _, line in ipairs(data) do
                if line ~= "" then
                  print(line)
                end
              end
            end
          end,
          on_stderr = function(_, data, _)
            if data then
              for _, line in ipairs(data) do
                if line ~= "" then
                  print("에러: " .. line)
                end
              end
            end
          end,
          on_exit = function(_, exit_code, _)
            if exit_code == 0 then
              print("컴파일 성공: " .. output_file)
            else
              print("컴파일 실패: 종료 코드 " .. exit_code)
            end
          end,
        })
      end,
    })
  else
    print("이 파일은 C 또는 C++ 파일이 아닙니다.")
  end
end

--- 현재 열려있는 파일의 컴파일한 후 실행
M.c_run = function()
  local file = vim.api.nvim_buf_get_name(0)

  -- 파일이 .c 또는 .cpp 확장자인지 확인
  if file:match("%.c$") or file:match("%.cpp$") then
    -- 현재 파일 저장
    vim.cmd("write")

    -- 현재 파일의 디렉토리 가져오기
    local dir = vim.fn.fnamemodify(file, ":h")

    -- 소스 파일을 저장할 테이블
    local sources = {}

    -- 터미널 출력 내용을 처리하는 콜백 함수
    local function on_stdout(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(sources, line)
          end
        end
      end
    end

    -- `find` 명령 실행
    local sources_cmd = { "find", dir, "-type", "f", "-name", "*.c", "-o", "-name", "*.cpp" }
    vim.fn.jobstart(sources_cmd, {
      stdout_buffered = true, -- 출력이 버퍼링된 상태로 처리
      on_stdout = on_stdout, -- 표준 출력 시 실행할 함수
      on_exit = function()
        -- 소스 파일이 없으면 종료
        if #sources == 0 then
          print("컴파일할 .c 또는 .cpp 파일이 없습니다.")
          return
        end

        -- 파일 이름만 추출 (확장자 제외)
        local output_file = vim.fn.fnamemodify(file, ":t:r")
        local output_file_path = vim.fn.getcwd() .. "/" .. output_file
        local dSYM_path = output_file_path .. ".dSYM"

        -- 기존에 이미 컴파일된 파일과 .dSYM 폴더가 존재하는지 확인
        if vim.fn.glob(output_file_path) ~= "" and vim.fn.isdirectory(dSYM_path) == 1 then
          print("컴파일이 존재하여 과정을 스킵힙니다.")
        else
          -- 소스 파일을 공백으로 구분된 문자열로 변환
          local sources_str = table.concat(sources, " ")
          print("컴파일할 파일들: " .. sources_str)

          -- 컴파일 명령어 생성
          local compile_cmd = { "clang", unpack(sources), "-g", "-o", output_file_path }
          vim.fn.jobstart(compile_cmd, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_exit = function(_, code)
              if code == 0 then
                print("컴파일 성공: " .. output_file)

                -- 컴파일된 파일 실행
                local run_cmd = vim.fn.getcwd() .. "/" .. output_file
                vim.cmd("botright split | resize 15 | terminal " .. run_cmd)

                -- 실행 후 결과물 파일 삭제
                vim.cmd("autocmd TermClose * silent! lua require('utils.commonUtils').async_remove_file('" .. vim.fn.getcwd() .. "/" .. output_file .. "')")
                vim.cmd("autocmd TermClose * silent! lua require('utils.commonUtils').async_remove_file('" .. vim.fn.getcwd() .. "/" .. output_file .. ".dSYM')")
              else
                print("컴파일 실패.")
              end
            end,
            on_stderr = function(_, err_data)
              if err_data then
                for _, line in ipairs(err_data) do
                  print("에러: " .. line)
                end
              end
            end,
          })
        end
      end,
    })
  else
    print("이 파일은 C 또는 C++ 파일이 아닙니다.")
  end
end

--- C 파일 컴파일 후 자동 실행
M.c_debug = function()
  local file = vim.api.nvim_buf_get_name(0)

  -- 파일이 .c 또는 .cpp 확장자인지 확인
  if file:match("%.c$") or file:match("%.cpp$") then
    -- 현재 파일 저장
    vim.cmd("write")

    -- 현재 파일의 디렉토리 가져오기
    local dir = vim.fn.fnamemodify(file, ":h")

    -- 소스 파일을 저장할 테이블
    local sources = {}

    -- 터미널 출력 내용을 처리하는 콜백 함수
    local function on_stdout(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(sources, line)
          end
        end
      end
    end

    -- `find` 명령 실행
    local sources_cmd = { "find", dir, "-type", "f", "-name", "*.c", "-o", "-name", "*.cpp" }
    vim.fn.jobstart(sources_cmd, {
      stdout_buffered = true, -- 출력이 버퍼링된 상태로 처리
      on_stdout = on_stdout, -- 표준 출력 시 실행할 함수
      on_exit = function()
        -- 소스 파일이 없으면 종료
        if #sources == 0 then
          print("컴파일할 .c 또는 .cpp 파일이 없습니다.")
          return
        end

        -- 파일 이름만 추출 (확장자 제외)
        local output_file = vim.fn.fnamemodify(file, ":t:r")
        local output_file_path = vim.fn.getcwd() .. "/" .. output_file
        local dSYM_path = output_file_path .. ".dSYM"

        -- 기존에 이미 컴파일된 파일과 .dSYM 폴더가 존재하는지 확인
        if vim.fn.glob(output_file_path) ~= "" and vim.fn.isdirectory(dSYM_path) == 1 then
          print("컴파일이 존재하여 과정을 스킵힙니다.")
        else
          -- 컴파일 명령 실행
          local compile_cmd = { "clang", unpack(sources), "-g", "-o", output_file_path }
          vim.fn.jobstart(compile_cmd, {
            stdout_buffered = true,
            stderr_buffered = true,
            on_exit = function(_, code)
              if code == 0 then
                print("컴파일 성공: " .. output_file)

                -- 디버깅을 실행하기 위해 컴파일된 파일 경로를 nvim-dap에 자동으로 전달
                local run_cmd = vim.fn.getcwd() .. "/" .. output_file

                -- dap-continue 실행 전에 파일 경로를 설정
                local dap_config = {
                  type = "codelldb",
                  request = "launch",
                  name = "Launch Program",
                  cwd = "${workspaceFolder}",
                  stopOnEntry = false,
                  args = {},
                  program = run_cmd, -- 자동으로 컴파일된 파일 경로 입력
                }

                -- DAP 세션을 시작하고 실행
                require("dap").run(dap_config)

                -- 실행 후 결과물 파일 삭제
                vim.cmd("autocmd TermClose * silent! lua require('utils.commonUtils').async_remove_file('" .. output_file_path .. "')")
                vim.cmd("autocmd TermClose * silent! lua require('utils.commonUtils').async_remove_file('" .. dSYM_path .. "')")
              else
                print("컴파일 실패. 오류 코드를 확인하세요.")
              end
            end,
            on_stderr = function(_, err_data)
              if err_data then
                for _, line in ipairs(err_data) do
                  if line ~= "" then
                    print("에러: " .. line)
                  end
                end
              end
            end,
          })
        end
      end,
    })
  else
    print("이 파일은 C 또는 C++ 파일이 아닙니다.")
  end
end

--- 파일 삭제를 비동기적으로 실행
---@param file_path string path
M.async_remove_file = function(file_path)
  vim.fn.jobstart({ "rm", "-rf", file_path }, {
    on_exit = function(_, code)
      if code == 0 then
        print(file_path .. " 삭제 완료.")
      else
        print("파일 삭제 실패: " .. file_path)
      end
    end,
  })
end

--- 해당 폴더의 retun정보를 취합하여 가져오는 함수
---@param directory string 폴더 위치 root는 .config/nvim/lua
---@return table 취합한 테이블 주소
M.load_config_folder = function(directory)
  local home = os.getenv("HOME")
  -- config.secure 폴더 내의 Lua 파일을 읽어와서 테이블을 반환하는 함수
  local result = {}

  -- 폴더 내 모든 Lua 파일을 가져옵니다.
  local files = vim.fn.globpath(home .. "/.config/nvim/lua/" .. directory, "*.lua", false, true)

  -- 각 Lua 파일을 로드하고 테이블을 병합합니다.
  for _, file in ipairs(files) do
    local config = dofile(file) -- Lua 파일 실행 (테이블 반환)

    -- config가 테이블인지 확인 후 병합합니다.
    if type(config) == "table" then
      -- 테이블 병합: config 테이블을 result 테이블에 합칩니다.
      for key, value in pairs(config) do
        result[key] = value
      end
    else
      -- 테이블이 아닌 경우 경고 메시지 출력 (선택 사항)
      print("Warning: " .. file .. " returned a non-table value.")
    end
  end

  return result
end

--- config/snippets 폴더 안의 파일 목록을 가져와서 출력하는 함수
---@param root_path string lua하위의 첫번째 폴더(config: ~/.config/nvim, data: ~/.local/share/nvim )
---@param search_path string 그외 나머지 path ('/'로 시작해야함)
---@param is_delete_ext boolean 확장자 제거 여부
---@param is_only_name boolean 이름만 추출할건지 여부
---@return filenames table 목록 리스트
M.list_files = function(root_path, search_path, is_delete_ext, is_only_name)
  -- config/snippets 폴더 경로
  local snippet_dir = vim.fn.stdpath(root_path) .. search_path

  -- 디렉토리가 존재하는지 확인
  if vim.fn.isdirectory(snippet_dir) == 0 then
    print("Directory not found: " .. snippet_dir)
    return
  end

  -- 디렉토리 내 파일 목록을 가져오기
  local files = vim.fn.globpath(snippet_dir, "*", false, true)
  -- 파일이 없으면 출력
  if #files == 0 then
    print("No files found in the snippets directory.")
    return
  end

  -- 파일명만 추출하여 리스트로 반환
  local filenames = {}
  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t") -- 경로에서 파일명만 추출
    if filename ~= "README.md" then -- README.md 파일 제외
      if is_delete_ext then
        filename = vim.fn.fnamemodify(filename, ":r")
      end
      table.insert(filenames, filename)
    end
  end

  return filenames
end

--- 명령어 선택기 - 이름과 명령어 쌍을 받아 선택 UI를 표시
---@param items table {name1, cmd1, name2, cmd2, ...} 형태의 배열
M.command_selector = function(items)
  -- items를 파싱해서 {name, cmd} 쌍으로 변환
  local options = {}
  for i = 1, #items, 2 do
    if items[i] and items[i + 1] then
      table.insert(options, {
        name = items[i],
        cmd = items[i + 1],
      })
    end
  end

  -- 이름 목록 추출
  local names = {}
  for _, opt in ipairs(options) do
    table.insert(names, opt.name)
  end

  -- vim.ui.select로 선택 UI 표시
  vim.ui.select(names, {
    prompt = "Select command:",
  }, function(choice)
    if choice then
      for _, opt in ipairs(options) do
        if opt.name == choice then
          -- 명령어 실행
          if type(opt.cmd) == "function" then
            opt.cmd()
          elseif type(opt.cmd) == "string" then
            -- <Cmd>, <cmd>, : 형태의 키 시퀀스 지원
            local keys = vim.api.nvim_replace_termcodes(opt.cmd, true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
          end
          break
        end
      end
    end
  end)
end

return M
