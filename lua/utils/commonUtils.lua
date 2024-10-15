local M = {}

M.widthResize = function()
  local width = vim.fn.input("input change size!!")

  if width == '' then
    print("please input size!!")
    return -1
  end

  vim.cmd("vertical resize " .. width)
end

M.heightResize = function()
  local height = vim.fn.input("input change size!!")

  if height == '' then
    print("please input size!!")
    return -1
  end

  vim.cmd("resize " .. height)
end

M.install_lazygit = function()
  -- OS 감지
  local uname = vim.loop.os_uname().sysname

  if uname == "Darwin" then
    -- macOS
    print("Detected macOS")

    -- brew 설치 확인
    local brew_installed = os.execute("command -v brew >/dev/null 2>&1")
    if brew_installed ~= 0 then
      print("Homebrew not found, installing Homebrew...")
      os.execute('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
    else
      print("Homebrew is already installed.")
    end

    -- lazygit 설치
    local lazygit_installed = os.execute("command -v lazygit >/dev/null 2>&1")
    if lazygit_installed ~= 0 then
      print("Installing lazygit via Homebrew...")
      os.execute("brew install lazygit")
    else
      print("Lazygit is already installed.")
    end
  elseif uname:find("Windows") then
    -- Windows
    print("Detected Windows")

    -- 관리 권한으로 명령 실행 함수
    local function run_as_admin(command)
      local powershell_command = "Start-Process powershell -Verb runAs -ArgumentList '" .. command .. "'"
      os.execute('powershell -Command "' .. powershell_command .. '"')
    end

    -- Chocolatey 설치 전 사전 작업 처리
    local function prepare_chocolatey_install()
      print("Preparing system for Chocolatey installation...")

      -- PowerShell 실행 정책을 Bypass로 설정하여 스크립트 실행 허용
      run_as_admin("Set-ExecutionPolicy Bypass -Scope Process -Force")

      -- TLS 1.2 설정 (Chocolatey 설치에 필요)
      run_as_admin("[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12")

      print("System is prepared for Chocolatey installation.")
    end

    -- chocolatey 설치 확인
    local choco_installed = os.execute("choco -v >/dev/null 2>&1")
    if choco_installed ~= 0 then
      print("Chocolatey not found, installing Chocolatey as Administrator...")
      prepare_chocolatey_install()
      run_as_admin("iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))")
    else
      print("Chocolatey is already installed.")
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

return M
