local home = os.getenv("HOME")
local VENV_PATTERNS = { ".venv", ".venv-*", "venv", "venv-*" }
local KERNEL_DIR = home .. "/Library/Jupyter/kernels"
local registered_kernels = {}

local function show_loading(msg)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = #msg + 4
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = 1,
    col = (vim.o.columns - width) / 2,
    row = (vim.o.lines - 1) / 2,
    style = "minimal",
    border = "rounded",
  })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  " .. msg .. "  " })
  vim.cmd("redraw")
  return win, buf
end

local function close_loading(win, buf)
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local function find_workspace_venvs()
  local cwd = vim.fn.getcwd()
  local venvs = {}
  for _, pattern in ipairs(VENV_PATTERNS) do
    local matches = vim.fn.glob(cwd .. "/" .. pattern, false, true)
    for _, path in ipairs(matches) do
      local python_path = path .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        table.insert(venvs, { path = path, python = python_path })
      end
    end
  end
  return venvs
end

local function get_kernel_info(venv)
  local workspace = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local venv_name = vim.fn.fnamemodify(venv.path, ":t")

  local handle = io.popen(venv.python .. " -c \"import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')\"")
  if not handle then
    return nil
  end
  local version = handle:read("*a"):gsub("%s+", "")
  handle:close()

  local kernel_name = workspace .. "-" .. venv_name .. "-python-" .. version
  local display_name = workspace .. "/" .. venv_name .. " (Python " .. version .. ")"

  return kernel_name, venv.python, display_name
end

local function get_project_root(venv_path)
  -- venv_path: /path/to/project/.venv/bin/python
  -- Return: /path/to/project
  local venv_dir = vim.fn.fnamemodify(venv_path, ":h:h")  -- Remove /bin/python
  local project_root = vim.fn.fnamemodify(venv_dir, ":h")  -- Remove /.venv
  return project_root
end

local function install_ipykernel(python_path, max_retries)
  max_retries = max_retries or 3
  local project_root = get_project_root(python_path)

  local install_cmd
  if vim.fn.executable("uv") == 1 then
    -- Check if pyproject.toml exists (uv project mode)
    if vim.fn.filereadable(project_root .. "/pyproject.toml") == 1 then
      -- Use 'uv add --dev' to add to project dependencies
      install_cmd = string.format("cd %s && uv add --dev ipykernel 2>&1", vim.fn.shellescape(project_root))
    else
      -- Fallback to uv pip install
      install_cmd = string.format("uv pip install --python %s ipykernel 2>&1", python_path)
    end
  else
    -- Fallback to standard pip
    install_cmd = string.format("%s -m pip install ipykernel 2>&1", python_path)
  end

  for attempt = 1, max_retries do
    local output = vim.fn.system(install_cmd)
    local exit_code = vim.v.shell_error

    if exit_code == 0 then
      local verify_output = vim.fn.system(python_path .. ' -c "import ipykernel" 2>&1')
      if vim.v.shell_error == 0 then
        return true
      end
    end

    if attempt < max_retries then
      vim.wait(1000)
    else
      vim.notify(string.format("ipykernel install failed after %d attempts:\n%s", max_retries, output), vim.log.levels.DEBUG)
    end
  end

  return false
end

local function register_kernel(venv)
  local kernel_name, python_path, display_name = get_kernel_info(venv)
  if not kernel_name then
    return false, "Failed to get kernel info"
  end

  local kernel_path = KERNEL_DIR .. "/" .. kernel_name
  if vim.fn.isdirectory(kernel_path) == 1 then
    table.insert(registered_kernels, kernel_name)
    return true
  end

  local win, buf = show_loading("Registering kernel: " .. kernel_name .. "...")

  -- Check if ipykernel is installed
  vim.fn.system(python_path .. ' -c "import ipykernel" 2>&1')
  if vim.v.shell_error ~= 0 then
    if not install_ipykernel(python_path, 3) then
      close_loading(win, buf)
      vim.notify("Failed to install ipykernel for " .. kernel_name, vim.log.levels.ERROR)
      return false, "ipykernel installation failed"
    end
  end

  -- Register kernel using vim.fn.system for better error handling
  local install_cmd = string.format(
    '%s -m ipykernel install --user --name=%s --display-name=%s',
    vim.fn.shellescape(python_path),
    vim.fn.shellescape(kernel_name),
    vim.fn.shellescape(display_name)
  )

  local output = vim.fn.system(install_cmd)
  local exit_code = vim.v.shell_error

  close_loading(win, buf)

  if exit_code == 0 and vim.fn.isdirectory(kernel_path) == 1 then
    table.insert(registered_kernels, kernel_name)
    return true
  else
    vim.notify(string.format("Failed to register kernel: %s\n%s", kernel_name, output), vim.log.levels.ERROR)
    return false, "kernel registration failed"
  end
end

local function register_kernels()
  local venvs = find_workspace_venvs()
  if #venvs == 0 then
    return
  end

  local success_count = 0
  local failure_count = 0
  local failures = {}

  for _, venv in ipairs(venvs) do
    local success, err = register_kernel(venv)
    if success then
      success_count = success_count + 1
    else
      failure_count = failure_count + 1
      table.insert(failures, { venv = venv.path, error = err })
    end
  end

  if success_count > 0 then
    vim.notify(string.format("Registered %d kernel(s) successfully", success_count), vim.log.levels.INFO)
  end

  if failure_count > 0 then
    local msg = string.format("Failed to register %d kernel(s)", failure_count)
    for _, failure in ipairs(failures) do
      msg = msg .. string.format("\n  • %s: %s", vim.fn.fnamemodify(failure.venv, ":t"), failure.error)
    end
    vim.notify(msg, vim.log.levels.WARN)
  end
end

local function unregister_kernels()
  for _, name in ipairs(registered_kernels) do
    local path = KERNEL_DIR .. "/" .. name
    if vim.fn.isdirectory(path) == 1 then
      vim.fn.delete(path, "rf")
    end
  end
  registered_kernels = {}
end

return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_win_max_height = 12
      vim.g.molten_enter_output_behavior = "open_and_enter"
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_pos = "eol"
      vim.g.molten_image_provider = "image.nvim"
    end,
    config = function()
      register_kernels()

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = unregister_kernels,
      })
    end,
    cond = function()
      return vim.fn.has("win32") == 0
    end,
  },
}
