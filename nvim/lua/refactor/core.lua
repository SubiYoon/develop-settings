-- refactor/core.lua
-- Language-agnostic core utilities for refactoring operations

local api = vim.api
local M = {}

-- ============================================================================
-- String Utilities
-- ============================================================================

function M.capitalize_first(str)
	if not str or str == "" then return str end
	return str:sub(1, 1):upper() .. str:sub(2)
end

function M.uncapitalize_first(str)
	if not str or str == "" then return str end
	return str:sub(1, 1):lower() .. str:sub(2)
end

-- ============================================================================
-- Indentation Utilities
-- ============================================================================

function M.get_line_indent(line)
	return line:match("^(%s*)") or ""
end

function M.get_indent_string(level, use_tabs, tab_width)
	use_tabs = use_tabs or vim.bo.expandtab == false
	tab_width = tab_width or vim.bo.tabstop or 4

	if use_tabs then
		return string.rep("\t", level)
	else
		return string.rep(" ", level * tab_width)
	end
end

-- ============================================================================
-- Scope Utilities
-- ============================================================================

function M.is_name_used_in_scope(name, lines, current_line)
	for i, line in ipairs(lines) do
		if i ~= current_line then
			if line:match("%f[%w_]" .. name .. "%f[^%w_]") then
				return true
			end
		end
	end
	return false
end

function M.get_unique_var_name(base_name, lines, current_line)
	local name = base_name
	local counter = 1
	while M.is_name_used_in_scope(name, lines, current_line) do
		counter = counter + 1
		name = base_name .. counter
	end
	return name
end

-- ============================================================================
-- Variable Name Generation
-- ============================================================================

function M.generate_var_name(type_str, expr)
	if not type_str or type_str == "" or type_str == "(?)" then
		-- Try to infer from expression
		local method = expr:match("%.([%w_]+)%([^)]*%)$")
		if method then
			if method:match("^get") then
				return M.uncapitalize_first(method:sub(4))
			elseif method:match("^is") then
				return M.uncapitalize_first(method:sub(3))
			elseif method:match("^find") then
				return "found" .. method:sub(5)
			elseif method:match("^create") then
				return "created" .. method:sub(7)
			end
			return method
		end
		return "result"
	end

	-- Extract base type (remove generics)
	local base = type_str:match("^([%w_]+)") or type_str

	-- Common type mappings
	local type_to_name = {
		String = "str",
		Integer = "num",
		Long = "num",
		Double = "num",
		Float = "num",
		Boolean = "flag",
		List = "list",
		Set = "set",
		Map = "map",
		Optional = "optional",
		Array = "array",
		Object = "obj",
	}

	local name = type_to_name[base]
	if name then
		return name
	end

	-- Default: uncapitalize type name
	return M.uncapitalize_first(base)
end

-- ============================================================================
-- UI Components
-- ============================================================================

function M.prompt_input(label, callback)
	vim.ui.input({ prompt = label }, function(input)
		if input and input ~= "" then
			callback(input)
		end
	end)
end

function M.show_expression_selector(expressions, title, bufnr, row, type_cache, callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	if #expressions == 0 then
		vim.notify("No extractable expressions found", vim.log.levels.WARN)
		return
	end

	if #expressions == 1 then
		expressions[1].cached_type = type_cache[expressions[1].text]
		callback(expressions[1])
		return
	end

	-- Reverse so most complete expression is first
	local reversed = {}
	for i = #expressions, 1, -1 do
		table.insert(reversed, expressions[i])
	end

	pickers
		.new({}, {
			prompt_title = title,
			finder = finders.new_table({
				results = reversed,
				entry_maker = function(expr)
					local type_str = type_cache[expr.text] or "(?)"
					local display = string.format("[%s] %s", type_str, expr.text)
					return {
						value = expr,
						display = display,
						ordinal = expr.text,
						type_str = type_str,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewers.new_buffer_previewer({
				title = "Expression Preview",
				define_preview = function(self, entry)
					local type_str = entry.type_str or type_cache[entry.value.text] or "(?)"
					local expr_text = entry.value.text

					-- Calculate box width based on content
					local type_len = vim.fn.strdisplaywidth("Type: " .. type_str)
					local expr_len = vim.fn.strdisplaywidth(expr_text)
					local content_width = math.max(type_len, expr_len, 20)
					local box_width = content_width + 4

					local function make_line(content)
						local pad = box_width - vim.fn.strdisplaywidth(content) - 2
						return "│ " .. content .. string.rep(" ", math.max(0, pad)) .. "│"
					end

					local h_line = string.rep("─", box_width)
					local preview_lines = {
						"╭" .. h_line .. "╮",
						make_line("Type: " .. type_str),
						"├" .. h_line .. "┤",
						make_line(expr_text),
						"╰" .. h_line .. "╯",
					}
					api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
					api.nvim_buf_set_option(self.state.bufnr, "filetype", "")
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						selection.value.cached_type = type_cache[selection.value.text]
						callback(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

function M.select_fields_with_ui(fields, title, callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- 선택 상태를 저장하는 Set (field.name -> boolean)
	local selected_set = {}

	-- finder 생성 함수 (선택 상태 반영)
	local function make_finder()
		return finders.new_table({
			results = fields,
			entry_maker = function(field)
				local is_selected = selected_set[field.name] or false
				local prefix = is_selected and "✓ " or "  "
				local display = prefix .. string.format("%s %s", field.type, field.name)

				return {
					value = field,
					display = display,
					ordinal = field.name,
				}
			end,
		})
	end

	local picker = pickers.new({}, {
		prompt_title = title .. " (Space: 선택, C-a: 전체, Enter: 확정)",
		finder = make_finder(),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			-- 선택된 필드 수 표시
			local function show_count()
				local count = 0
				for _ in pairs(selected_set) do
					count = count + 1
				end
				vim.notify(string.format("Selected: %d / %d", count, #fields), vim.log.levels.INFO)
			end

			-- 이동 기록 queue (이 picker 인스턴스에서만 유효)
			local movement_queue = {}

			-- picker 새로고침 (queue replay로 커서 위치 유지)
			local function refresh_picker_keep_cursor()
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				current_picker:refresh(make_finder(), { reset_prompt = false })

				-- queue에 저장된 이동 재실행
				vim.defer_fn(function()
					for _, move in ipairs(movement_queue) do
						if move == "next" then
							actions.move_selection_next(prompt_bufnr)
						elseif move == "prev" then
							actions.move_selection_previous(prompt_bufnr)
						end
					end
				end, 10)
			end

			-- 이동 키 매핑 (queue에 기록)
			map("i", "<Down>", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("i", "<Up>", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)
			map("i", "<C-n>", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("i", "<C-p>", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)
			map("n", "j", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("n", "k", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)

			-- Space: 개별 선택/해제 토글
			map("i", "<Space>", function()
				local entry = action_state.get_selected_entry()
				if entry then
					local name = entry.value.name
					selected_set[name] = not selected_set[name]
					if not selected_set[name] then
						selected_set[name] = nil
					end
					refresh_picker_keep_cursor()
					show_count()
				end
			end)

			-- Ctrl+a: 전체 선택/해제 토글
			map("i", "<C-a>", function()
				local all_selected = true
				for _, field in ipairs(fields) do
					if not selected_set[field.name] then
						all_selected = false
						break
					end
				end

				if all_selected then
					-- 전체 해제
					selected_set = {}
				else
					-- 전체 선택
					for _, field in ipairs(fields) do
						selected_set[field.name] = true
					end
				end
				refresh_picker_keep_cursor()
				show_count()
			end)

			-- Enter: 확정
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)

				-- 선택된 필드들 수집
				local selected = {}
				for _, field in ipairs(fields) do
					if selected_set[field.name] then
						table.insert(selected, field)
					end
				end

				-- 아무것도 선택 안했으면 커서 위치의 항목 선택
				if #selected == 0 then
					local entry = action_state.get_selected_entry()
					if entry then
						selected = { entry.value }
					end
				end

				if #selected > 0 then
					callback(selected)
				else
					vim.notify("No fields selected", vim.log.levels.WARN)
				end
			end)

			-- Esc: 취소
			map("i", "<Esc>", function()
				actions.close(prompt_bufnr)
				vim.notify("Cancelled", vim.log.levels.INFO)
			end)

			return true
		end,
	})

	picker:find()
end

-- ============================================================================
-- Function Selection UI (for test generation)
-- ============================================================================

function M.select_functions_with_ui(functions, title, callback)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	-- 선택 상태를 저장하는 Set (function name -> boolean)
	local selected_set = {}

	-- finder 생성 함수 (선택 상태 반영)
	local function make_finder()
		return finders.new_table({
			results = functions,
			entry_maker = function(func)
				local is_selected = selected_set[func] or false
				local prefix = is_selected and "✓ " or "  "
				local display = prefix .. func

				return {
					value = func,
					display = display,
					ordinal = func,
				}
			end,
		})
	end

	local picker = pickers.new({}, {
		prompt_title = title .. " (Space: 선택, C-a: 전체, Enter: 확정)",
		finder = make_finder(),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			-- 선택된 함수 수 표시
			local function show_count()
				local count = 0
				for _ in pairs(selected_set) do
					count = count + 1
				end
				vim.notify(string.format("Selected: %d / %d", count, #functions), vim.log.levels.INFO)
			end

			-- 이동 기록 queue
			local movement_queue = {}

			-- picker 새로고침 (queue replay로 커서 위치 유지)
			local function refresh_picker_keep_cursor()
				local current_picker = action_state.get_current_picker(prompt_bufnr)
				current_picker:refresh(make_finder(), { reset_prompt = false })

				vim.defer_fn(function()
					for _, move in ipairs(movement_queue) do
						if move == "next" then
							actions.move_selection_next(prompt_bufnr)
						elseif move == "prev" then
							actions.move_selection_previous(prompt_bufnr)
						end
					end
				end, 10)
			end

			-- 이동 키 매핑 (queue에 기록)
			map("i", "<Down>", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("i", "<Up>", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)
			map("i", "<C-n>", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("i", "<C-p>", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)
			map("n", "j", function()
				table.insert(movement_queue, "next")
				actions.move_selection_next(prompt_bufnr)
			end)
			map("n", "k", function()
				table.insert(movement_queue, "prev")
				actions.move_selection_previous(prompt_bufnr)
			end)

			-- Space: 개별 선택/해제 토글
			map("i", "<Space>", function()
				local entry = action_state.get_selected_entry()
				if entry then
					local name = entry.value
					selected_set[name] = not selected_set[name]
					if not selected_set[name] then
						selected_set[name] = nil
					end
					refresh_picker_keep_cursor()
					show_count()
				end
			end)

			-- Ctrl+a: 전체 선택/해제 토글
			map("i", "<C-a>", function()
				local all_selected = true
				for _, func in ipairs(functions) do
					if not selected_set[func] then
						all_selected = false
						break
					end
				end

				if all_selected then
					selected_set = {}
				else
					for _, func in ipairs(functions) do
						selected_set[func] = true
					end
				end
				refresh_picker_keep_cursor()
				show_count()
			end)

			-- Enter: 확정
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)

				local selected = {}
				for _, func in ipairs(functions) do
					if selected_set[func] then
						table.insert(selected, func)
					end
				end

				-- 아무것도 선택 안했으면 커서 위치의 항목 선택
				if #selected == 0 then
					local entry = action_state.get_selected_entry()
					if entry then
						selected = { entry.value }
					end
				end

				if #selected > 0 then
					callback(selected)
				else
					vim.notify("No functions selected", vim.log.levels.WARN)
				end
			end)

			-- Esc: 취소
			map("i", "<Esc>", function()
				actions.close(prompt_bufnr)
				vim.notify("Cancelled", vim.log.levels.INFO)
			end)

			return true
		end,
	})

	picker:find()
end

-- ============================================================================
-- Language Interface Definition
-- ============================================================================

-- This defines the interface that language modules must implement
M.LanguageInterface = {
	-- Detection
	is_supported_file = function() return false end,
	get_lsp_client = function() return nil end,

	-- Type Inference
	get_type_for_expression_async = function(bufnr, row, col, expr, callback) callback(nil) end,
	get_type_for_expression_sync = function(bufnr, row, col, expr, timeout) return nil end,
	infer_type_from_expression = function(expr) return nil end,
	parse_hover_for_type = function(hover_content) return nil end,

	-- Expression Parsing
	parse_expressions = function(line, col) return {} end,
	parse_multiline_chain = function(bufnr, row, col) return {} end,

	-- Code Generation - Extract
	generate_variable_declaration = function(indent, type_str, name, expr) return "" end,
	generate_constant_declaration = function(indent, type_str, name, expr) return "" end,
	generate_field_declaration = function(indent, type_str, name, expr) return "" end,
	generate_parameter = function(type_str, name) return "" end,
	generate_method = function(params) return "" end,

	-- Code Generation - Generate
	generate_constructor = function(fields) return "" end,
	generate_getter = function(field) return "" end,
	generate_setter = function(field) return "" end,
	generate_equals = function(class_name, fields) return "" end,
	generate_tostring = function(class_name, fields) return "" end,
	generate_builder = function(class_name, fields) return "" end,

	-- Imports/Includes
	add_import = function(import_path) end,
	get_imports_for_type = function(type_str) return {} end,

	-- Utilities
	extract_fields = function() return {} end,
	find_class_name = function() return nil end,
	find_insert_position = function() return nil end,
	convert_to_interface_type = function(type_str) return type_str end,
}

-- Create a new language module with default implementations
function M.create_language_module()
	local module = {}
	setmetatable(module, { __index = M.LanguageInterface })
	return module
end

return M
