local M = {}

-- tab의 너비 조절
M.widthResize = function()
  local width = vim.fn.input("input change size!!")

  if width == '' then
    print("please input size!!")
    return -1
  end

  vim.cmd("vertical resize " .. width)
end

-- tab의 높이 조절
M.heightResize = function()
  local height = vim.fn.input("input change size!!")

  if height == '' then
    print("please input size!!")
    return -1
  end

  vim.cmd("resize " .. height)
end

-- lazygit 설치
M.install_lazygit = function()
  -- OS 감지
  local uname = vim.loop.os_uname().sysname

  if uname == "Darwin" then
    -- macOS
    -- lazygit 설치 확인
    local lazygit_installed = os.execute("command -v lazygit >/dev/null 2>&1")
    if lazygit_installed ~= 0 then
      print("Installing lazygit via Homebrew...")
      os.execute("brew install lazygit")
    else
      print("Lazygit is already installed.")
    end
  elseif uname:find("Windows") then
    -- Windows
    -- 관리 권한으로 명령 실행 함수
    local function run_as_admin(command)
      local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" .. command .. "'"
      os.execute('powershell -Command "' .. powershell_command .. '"')
    end

    -- lazygit 설치 확인
    local lazygit_installed = os.execute("lazygit --version >/dev/null 2>&1")
    if lazygit_installed ~= 0 then
      print("Installing lazygit via Chocolatey as Administrator...")
      run_as_admin("choco install lazygit -y")
    else
      print("Lazygit is already installed.")
    end
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
      os.execute('/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"')
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

return M
