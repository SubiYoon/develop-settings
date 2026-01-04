-- 파일을 열었을 때 자동으로 Normal 모드로 전환
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  command = "stopinsert",
})
-- dadbod에서 autocommit 방지 커멘드 자동 삽입
local function check_and_set_autocommit()
  local db_type = vim.bo.filetype -- 현재 버퍼의 파일 타입을 확인
  local check_command
  local set_command

  -- 데이터베이스에 맞는 autocommit 확인 및 설정 명령어 설정
  if db_type == "mysql" or db_type == "mariadb" then
    check_command = "SHOW VARIABLES LIKE 'autocommit';"
    set_command = "SET autocommit=0;"
  elseif db_type == "postgresql" then
    check_command = "SELECT current_setting('autocommit');"
    set_command = "SET autocommit=off;"
  elseif db_type == "oracle" then
    check_command = "SHOW AUTOCOMMIT;" -- Oracle에서는 자동으로 확인할 수 없으므로, 이 명령어는 상황에 따라 다를 수 있음
    set_command = "SET AUTOCOMMIT OFF;"
  elseif db_type == "mongodb" then
    -- MongoDB는 기본적으로 autocommit이 꺼져있으므로 확인과 끄는 명령이 필요하지 않음
    check_command = "-- MongoDB는 autocommit이 기본적으로 OFF입니다."
    set_command = "-- MongoDB autocommit 설정은 기본적으로 OFF입니다."
  end

  -- 명령어가 설정되었으면 현재 버퍼에 삽입
  if check_command and set_command then
    local buf = vim.api.nvim_get_current_buf()

    -- 두 번째 줄에 삽입
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, { set_command }) -- 두 번째 줄에 설정 명령어 삽입
    vim.api.nvim_buf_set_lines(buf, 1, 1, false, { check_command }) -- 첫 번째 줄에 확인 명령어 삽입
  end
end

-- "FileType" 이벤트로 각 데이터베이스 파일 타입에 대해 호출
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "mysql", "mariadb", "oracle", "postgresql", "mongodb" },
  callback = check_and_set_autocommit,
})
-- VimLeavePre 이벤트(messages에 담겼던 내용 log로 저장)
-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	command = "redir > ~/.local/share/nvim/nvim_exit_messages.log | messages | redir",
-- })
--
-- Justfile 전용 설정
vim.api.nvim_create_autocmd("FileType", {
  pattern = "just",
  callback = function()
    vim.opt_local.expandtab = false -- 공백 대신 실제 탭 문자 사용
    vim.opt_local.tabstop = 4 -- 탭 너비 (탭 문자는 너비 4로 표시)
    vim.opt_local.shiftwidth = 4 -- 자동 들여쓰기 너비
    vim.opt_local.softtabstop = 4 -- 인서트 모드 탭 감도
  end,
})

-- claude code 실행시 codewindow close
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname:find("claude") then
      -- codewindow.close_minimap()
    end
  end,
})
