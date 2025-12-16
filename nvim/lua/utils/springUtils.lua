local M = {}

-- Make Java Spring Boot Test Class Start
local api = vim.api
local fn = vim.fn

-- Java 함수 정의를 감지하기 위한 정규 표현식
local function extract_public_function_names(filepath)
  local function_names = {}
  for line in io.lines(filepath) do
    -- public으로 선언된 함수만 추출
    local function_name = line:match("^%s*public%s+[%w<>%[%]]+%s+(%w+)%s*%(")
    if function_name then
      table.insert(function_names, function_name)
    end
  end
  return function_names
end

-- 테스트 파일 생성 함수
M.create_test_file = function()
  -- 현재 파일 경로와 이름 가져오기
  local filepath = fn.expand("%:p")
  local class_name = fn.expand("%:t:r") -- 현재 파일의 클래스 이름
  local filename = class_name .. "Test.java"

  -- 소스 파일의 패키지 경로를 변환
  local package_path = filepath:match("src/main/java/(.+)/[^/]+.java")
  if not package_path then
    print("Spring Boot 프로젝트의 소스 파일이어야 합니다.")
    return
  end

  local package_name = package_path:gsub("/", ".")
  local test_file_path = "src/test/java/" .. package_path .. "/" .. filename

  -- 이미 파일이 존재하면 열기
  if fn.filereadable(test_file_path) == 1 then
    api.nvim_command("edit " .. test_file_path)
    return
  end

  -- 현재 Java 파일에서 public 함수명 추출
  local function_names = extract_public_function_names(filepath)
  if #function_names == 0 then
    print("public 함수가 없습니다.")
    return
  end

  -- 테스트 메서드 템플릿
  local test_method_template = [[
    @Test
    void %s() {
        //given


        //when


        //then

    }
    ]]

  -- 추출한 함수명으로 테스트 메서드 생성
  local test_methods = {}
  for _, func in ipairs(function_names) do
    table.insert(test_methods, string.format(test_method_template, func))
  end

  -- 테스트 파일 템플릿
  local test_template = [[
package %s;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import static org.assertj.core.api.Assertions.*;
import static org.junit.jupiter.api.Assertions.*;

// SpringBootTest를 사용할거면 주석 해제(현 시점 JUnit 사용)
// @SpringBootTest
class %sTest {

%s
}
]]
  local test_content = string.format(test_template, package_name, class_name, table.concat(test_methods, "\n"))

  -- 테스트 파일 생성
  fn.mkdir(fn.fnamemodify(test_file_path, ":h"), "p")
  fn.writefile(vim.split(test_content, "\n"), test_file_path)

  -- 생성된 파일 열기
  api.nvim_command("edit " .. test_file_path)
end
-- Make Java Spring Boot Test Class End

-- Build Tool Run Task Start
local function prompt_input(label, callback)
  vim.ui.input({ prompt = label .. ": " }, function(input)
    if input and input ~= "" then
      callback(input)
    else
      vim.notify("❌ Task name is required.", vim.log.levels.ERROR)
    end
  end)
end

-- 하단 20% 비율로 터미널 열기 함수
local function open_terminal_with_command(cmd)
  -- 전체 라인 수의 20% 계산
  local height = math.floor(vim.o.lines * 0.2)

  -- 아래쪽에 split 창 만들고 터미널 실행
  vim.cmd(height .. "split")
  vim.cmd("terminal " .. cmd)

  -- 터미널 모드 진입
  vim.cmd("startinsert")
end

function M.run_gradle_task()
  prompt_input("Enter Task Name", function(task_name)
    open_terminal_with_command("./gradlew " .. task_name)
  end)
end

function M.run_maven_task()
  prompt_input("Enter Task Name", function(task_name)
    open_terminal_with_command("./mvnw " .. task_name)
  end)
end
-- Build Tool Rund Task End

return M
