local VENV_PATTERNS = { ".venv", ".venv-*", "venv", "venv-*" }
local KERNEL_DIR = vim.fn.expand("~/Library/Jupyter/kernels")
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

local function find_workspace_venv()
  local cwd = vim.fn.getcwd()
  for _, pattern in ipairs(VENV_PATTERNS) do
    local matches = vim.fn.glob(cwd .. "/" .. pattern, false, true)
    for _, path in ipairs(matches) do
      local python_path = path .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        return { path = path, python = python_path }
      end
    end
  end
  return nil
end

local function get_kernel_name()
  local workspace = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local venv = find_workspace_venv()
  if not venv then
    return nil
  end

  local handle = io.popen(venv.python .. " -c \"import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')\"")
  if not handle then
    return nil
  end
  local version = handle:read("*a"):gsub("%s+", "")
  handle:close()

  return workspace .. "-python-" .. version, venv.python, workspace .. " (Python " .. version .. ")"
end

local function register_kernel()
  local kernel_name, python_path, display_name = get_kernel_name()
  if not kernel_name then
    return
  end

  local kernel_path = KERNEL_DIR .. "/" .. kernel_name
  if vim.fn.isdirectory(kernel_path) == 1 then
    table.insert(registered_kernels, kernel_name)
    return
  end

  local win, buf = show_loading("Registering kernel: " .. kernel_name .. "...")

  local check = os.execute(python_path .. " -c \"import ipykernel\" 2>/dev/null")
  if check ~= 0 then
    local install_cmd = vim.fn.executable("uv") == 1
        and "uv pip install --python " .. python_path .. " ipykernel --quiet"
        or python_path .. " -m pip install ipykernel --quiet"
    os.execute(install_cmd)
  end

  os.execute(string.format('%s -m ipykernel install --user --name="%s" --display-name="%s" 2>&1', python_path, kernel_name, display_name))

  close_loading(win, buf)
  vim.notify("[Molten] Kernel registered: " .. kernel_name, vim.log.levels.INFO)
  table.insert(registered_kernels, kernel_name)
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
      if find_workspace_venv() then
        register_kernel()
      end

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = unregister_kernels,
      })
    end,
    cond = function()
      return vim.fn.has("win32") == 0
    end,
  },
}
