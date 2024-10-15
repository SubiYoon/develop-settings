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

return M
