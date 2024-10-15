local M = {}

-- git add 함수 공백으로 입력시 전체를 add
M.gitAdd = function()
  local paths = vim.fn.input('input add file path!! default: all')

  if paths == '' then
    paths = '.'
  end

  vim.cmd('Git add ' .. paths)
end

-- git commit
M.gitCommit = function()
  local message = vim.fn.input('input commit message!!')

  if message == '' then
    print('please input commit message!!')
    return -1
  end

  vim.cmd('Git commit -m "' .. message .. '"')
end

-- git push
M.gitPush = function()
  local branch = vim.fn.input('input branch name!!')

  if branch == '' then
    print('please input branch name!!')
    return -1
  end

  vim.cmd('Git push origin ' .. branch)
end

-- git reset
M.gitReset = function()
  local option = vim.fn.input('input option(--soft, --mixed, --hard)!! default: --hard')
  local commit_id = vim.fn.input('input commit id!! default: HEAD^')

  if option == '' then
    option = '--hard'
  end

  if commit_id == '' then
    commit_id = 'HEAD^'
  end

  vim.cmd('Git reset ' .. option)
end

-- git reset add
M.gitResetAdd = function()
  local restore_paths = vim.fn.input('input restore staged file path!! default: all')

  if restore_paths == '' then
    restore_paths = '.'
  end

  vim.cmd('Git restore --staged ' .. restore_paths)
end
return M
