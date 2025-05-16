local snip = require("utils.snippetUtils")
local luasnip = snip.luasnip
local s = snip.s
local t = snip.t
local i = snip.i
local f = snip.f
local d = snip.d
local sn = snip.sn
local all_arg_count = 0
local all_arg_type_list = {}

-- 현재 파일명에서 확장자를 제외한 부분을 가져오는 함수
local function filename_base()
	local filename = vim.fn.expand("%:t") -- 현재 파일명 (경로 제외)
	return filename:match("^(.*)%.%w+$") or filename -- 확장자 제거
end

-- all arg 생성자 생성
local function create_all_arg_constructor(args)
	-- args[1]에 입력된 문자열을 ','로 분리
	local param_str = vim.inspect(args[1]) or ""
	local params = {}

	-- 쉼표(,)로 매개변수를 분리
	for item in string.gmatch(param_str, "([^,]+)") do
		table.insert(params, item)
	end

	local nodes = {}

	-- 분리된 매개변수 갯수만큼 반복
	for index = 1, #params do
		-- 각 매개변수를 공백 기준으로 나누기 (타입과 변수명 분리)
		local param = vim.inspect(params[index])
		-- 양쪽 공백을 제거한 후 공백 기준으로 분리
		param = param:gsub("^%s*(.-)%s*$", "%1") -- 양쪽 공백 제거
		param = param:gsub("[{}\"']", "")
		param = param:gsub("^%s*(.-)%s*$", "%1") -- 양쪽 공백 제거

		-- 공백을 기준으로 첫 번째와 두 번째 값을 분리 (정규식 수정)
		local type_name, var_name = param:match("^(%S+)%s*(%S+)$")

		-- 타입(type_name)과 변수명(var_name)이 잘 분리되었는지 확인
		if type_name and var_name then
			-- this.test = test; 형태로 노드 생성
			table.insert(nodes, t("this."))
			table.insert(nodes, t(var_name))
			table.insert(nodes, t(" = "))
			table.insert(nodes, t(var_name))
			table.insert(nodes, t(";"))

			-- 마지막 매개변수가 아니면 공백 추가
			if index ~= #params then
				table.insert(nodes, t({ "", "        " }))
			end
			table.insert(all_arg_type_list, type_name)
		end
	end

	all_arg_count = #params
	return sn(3, nodes)
end

-- all arg 생성자 생성
local function create_arg_constructor(args)
	-- args[1]에 입력된 문자열을 ','로 분리
	local param_str = vim.inspect(args[1]) or ""
	local params = {}

	-- 쉼표(,)로 매개변수를 분리
	for item in string.gmatch(param_str, "([^,]+)") do
		table.insert(params, item)
	end

	local nodes = {}

	table.insert(nodes, t("this("))
	-- 분리된 매개변수 갯수만큼 반복
	for index = 1, #params do
		-- 각 매개변수를 공백 기준으로 나누기 (타입과 변수명 분리)
		local param = vim.inspect(params[index])
		-- 양쪽 공백을 제거한 후 공백 기준으로 분리
		param = param:gsub("^%s*(.-)%s*$", "%1") -- 양쪽 공백 제거
		param = param:gsub("[{}\"']", "")
		param = param:gsub("^%s*(.-)%s*$", "%1") -- 양쪽 공백 제거

		-- 공백을 기준으로 첫 번째와 두 번째 값을 분리 (정규식 수정)
		local type_name, var_name = param:match("^(%S+)%s*(%S+)$")

		-- 타입(type_name)과 변수명(var_name)이 잘 분리되었는지 확인
		if type_name and var_name then
			-- this.test = test; 형태로 노드 생성
			table.insert(nodes, t(var_name))
			if index ~= #params then
				table.insert(nodes, t(", "))
			else
				for temp_index = #params + 1, all_arg_count do
					table.insert(nodes, t(", "))

					if all_arg_type_list[temp_index] == "String" then
						table.insert(nodes, t('""'))
					elseif all_arg_type_list[temp_index] == "byte" then
						table.insert(nodes, t("0"))
					elseif all_arg_type_list[temp_index] == "short" then
						table.insert(nodes, t("0"))
					elseif all_arg_type_list[temp_index] == "long" then
						table.insert(nodes, t("0L"))
					elseif all_arg_type_list[temp_index] == "int" then
						table.insert(nodes, t("0"))
					elseif all_arg_type_list[temp_index] == "float" then
						table.insert(nodes, t("0.0f"))
					elseif all_arg_type_list[temp_index] == "double" then
						table.insert(nodes, t("0.0d"))
					elseif all_arg_type_list[temp_index] == "char" then
						table.insert(nodes, t("'\\u0000'"))
					elseif all_arg_type_list[temp_index] == "boolean" then
						table.insert(nodes, t("false"))
					else
						table.insert(nodes, t("null"))
					end
				end
			end
		end
	end

	table.insert(nodes, t(");"))
	all_arg_type_list = {}
	all_arg_count = 0
	return sn(3, nodes)
end

-- 현재 파일 위치를 감지하여 Java 패키지를 생성하는 함수
function create_java_package_from_path()
	local package_path = ""

	local current_file_path = vim.fn.expand("%:p") -- 전체 경로를 가져옴
	local current_file_dir = vim.fn.fnamemodify(current_file_path, ":p:h") -- 디렉토리 경로만 가져옴

	local src_path_start = current_file_dir:find("java/") -- "src/"가 포함된 위치 찾기
	if not src_path_start then
		local current_dir = vim.fn.getcwd()
		local last_folder = vim.fn.fnamemodify(current_dir, ":t")
		src_path_start = current_file_dir:find(last_folder) -- "src/"가 포함된 위치 찾기
		package_path = current_file_dir:sub(src_path_start + #last_folder + 1) -- "src/" 이후 부분 추출
		package_path = package_path:gsub("/", ".") -- 디렉토리 구분자를 '.'로 변환
	else
		-- "src" 이후 부분만 추출 (패키지 경로)
		package_path = current_file_dir:sub(src_path_start + 5) -- "src/" 이후 부분 추출
		package_path = package_path:gsub("/", ".") -- 디렉토리 구분자를 '.'로 변환
	end

	return "package " .. package_path .. ";"
end

-- Java 스니펫 예시
luasnip.add_snippets("java", {
	-- class 스니펫
	s("class", {
		f(create_java_package_from_path, {}),
		t({ "", "", "" }),
		t("public class "),
		f(filename_base, {}),
		t({
			" {",
			"    ",
		}),
		i(1, ""),
		t({
			"",
			"}",
		}),
	}),

	-- interface 스니펫
	s("interface", {
		f(create_java_package_from_path, {}),
		t({ "", "", "" }),
		t("public interface "),
		f(filename_base, {}),
		t({
			" {",
			"    ",
		}),
		i(1, ""),
		t({
			"",
			"}",
		}),
	}),

	-- record 스니펫
	s("record", {
		f(create_java_package_from_path, {}),
		t({ "", "", "" }),
		t("public record "),
		f(filename_base, {}),
		t({ "(", "    " }),
		i(1, "type arg"),
		t({ ") {", "    public " }),
		f(filename_base, {}),
		t("("),
		d(2, function(args)
			return sn(1, { i(1, args[1]) })
		end, { 1 }),
		t({ ") {", "        " }),
		d(3, function(arg)
			return create_all_arg_constructor(arg)
		end, { 1 }),
		t({
			"",
			"    }",
		}),
		t({
			"",
			"",
			"    public ",
		}),
		f(filename_base, {}),
		t("("),
		i(4, "type args"),
		t({ ") {", "        " }),
		d(5, function(arg)
			return create_arg_constructor(arg)
		end, { 4 }),
		t({
			"",
			"    }",
			"}",
		}),
	}),
})
