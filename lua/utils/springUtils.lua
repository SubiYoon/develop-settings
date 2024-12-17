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
		api.nvim_err_writeln("Spring Boot 프로젝트의 소스 파일이어야 합니다.")
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
		api.nvim_err_writeln("public 함수가 없습니다.")
		return
	end

	-- 테스트 메서드 템플릿
	local test_method_template = [[
    @Test
    void %s() {
        // TODO: 테스트 로직 작성
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

@SpringBootTest
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
return M
