-- refactor/refactor.lua
-- Main entry point for refactoring operations
-- Detects language and delegates to appropriate language module

local api = vim.api
local core = require("refactor.core")

local M = {}

-- ============================================================================
-- Language Module Registry
-- ============================================================================

local language_modules = {}

-- Register a language module
function M.register_language(filetype, module)
	language_modules[filetype] = module
end

-- Get language module for current buffer
local function get_language_module()
	local ft = vim.bo.filetype

	-- Try exact match first
	if language_modules[ft] then
		return language_modules[ft]
	end

	-- Try to load language module
	local ok, module = pcall(require, "refactor.language." .. ft)
	if ok and module and module.is_supported_file and module.is_supported_file() then
		language_modules[ft] = module
		return module
	end

	return nil
end

-- ============================================================================
-- Extract Operations
-- ============================================================================

function M.extract_variable()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2] + 1
	local current_line = api.nvim_get_current_line()

	-- Check if multi-line chain
	local is_multiline = current_line:match("^%s*%.")

	local expressions, start_row, start_col, end_row, end_col, full_expr

	if is_multiline and lang.parse_multiline_chain then
		expressions, start_row, start_col, end_row, end_col, full_expr = lang.parse_multiline_chain(bufnr, row, col)
	else
		expressions = lang.parse_expressions(current_line, col)
		start_row, end_row = row, row
		start_col, end_col = 1, #current_line
		if #expressions > 0 then
			start_col = expressions[1].start_col or 1
			end_col = expressions[#expressions].end_col or #current_line
			full_expr = expressions[#expressions].text
		end
	end

	if #expressions == 0 then
		vim.notify("No extractable expression found", vim.log.levels.WARN)
		return
	end

	-- Build type cache
	local type_cache = {}
	for _, expr in ipairs(expressions) do
		local inferred = lang.infer_type_from_expression(expr.text)
		if inferred then
			type_cache[expr.text] = inferred
		else
			local lsp_type = lang.get_type_for_expression_sync(bufnr, row, expr.start_col, expr.text, 500)
			type_cache[expr.text] = lsp_type or "(?)"
		end
	end

	core.show_expression_selector(expressions, "Extract Variable", bufnr, row, type_cache, function(selected)
		local expr_text = selected.text
		local inferred_type = selected.cached_type

		if not inferred_type or inferred_type == "(?)" then
			inferred_type = lang.infer_type_from_expression(expr_text)
		end

		local function complete_extraction(final_type)
			local all_lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local suggested_name = core.generate_var_name(final_type, expr_text)
			suggested_name = core.get_unique_var_name(suggested_name, all_lines, start_row)

			vim.ui.input({
				prompt = "Variable name: ",
				default = suggested_name,
			}, function(var_name)
				if not var_name or var_name == "" then
					return
				end

				local start_line_content = all_lines[start_row]
				local indent = core.get_line_indent(start_line_content)

				if is_multiline and selected.text == full_expr then
					-- Multi-line chain extraction
					local orig_type, orig_var = start_line_content:match("^%s*([%w_<>%[%],%s%.]+)%s+([%w_]+)%s*=")
					if orig_type and orig_var then
						orig_type = orig_type:gsub("^%s+", ""):gsub("%s+$", "")
						local decl_line = lang.generate_variable_declaration(indent, final_type, var_name, expr_text)
						local assign_line = lang.generate_variable_declaration(indent, orig_type, orig_var, var_name)
						api.nvim_buf_set_lines(bufnr, start_row - 1, end_row, false, { decl_line, assign_line })
					else
						local decl_line = lang.generate_variable_declaration(indent, final_type, var_name, expr_text)
						api.nvim_buf_set_lines(bufnr, start_row - 1, end_row, false, { decl_line })
					end
				else
					-- Single line extraction
					local declaration = lang.generate_variable_declaration(indent, final_type, var_name, expr_text)

					if selected.start_col and selected.end_col then
						local new_line = current_line:sub(1, selected.start_col - 1) .. var_name .. current_line:sub(selected.end_col + 1)
						api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, { declaration })
						api.nvim_buf_set_lines(bufnr, row, row + 1, false, { new_line })
					else
						api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, { declaration })
					end
				end

				-- Add imports
				if lang.get_imports_for_type and lang.add_import then
					local imports = lang.get_imports_for_type(final_type)
					for _, imp in ipairs(imports) do
						lang.add_import(imp)
					end
				end

				vim.notify(string.format("Extracted: %s %s", final_type, var_name), vim.log.levels.INFO)
			end)
		end

		if inferred_type and inferred_type ~= "(?)" then
			complete_extraction(inferred_type)
		else
			lang.get_type_for_expression_async(bufnr, row, start_col, expr_text, function(lsp_type, err)
				vim.schedule(function()
					if lsp_type then
						complete_extraction(lsp_type)
					else
						vim.ui.input({
							prompt = "Type (LSP unavailable): ",
							default = "Object",
						}, function(user_type)
							if user_type and user_type ~= "" then
								complete_extraction(user_type)
							end
						end)
					end
				end)
			end)
		end
	end)
end

function M.extract_constant()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2] + 1
	local line = api.nvim_get_current_line()

	local expressions = lang.parse_expressions(line, col)

	if #expressions == 0 then
		vim.notify("No extractable expression found", vim.log.levels.WARN)
		return
	end

	-- Build type cache
	local type_cache = {}
	for _, expr in ipairs(expressions) do
		local inferred = lang.infer_type_from_expression(expr.text)
		if inferred then
			type_cache[expr.text] = inferred
		else
			local lsp_type = lang.get_type_for_expression_sync(bufnr, row, expr.start_col, expr.text, 500)
			type_cache[expr.text] = lsp_type or "(?)"
		end
	end

	core.show_expression_selector(expressions, "Extract Constant", bufnr, row, type_cache, function(selected)
		local expr_text = selected.text
		local inferred_type = selected.cached_type or lang.infer_type_from_expression(expr_text)

		local function complete_extraction(final_type)
			local suggested_name = core.generate_var_name(final_type, expr_text):upper()

			vim.ui.input({
				prompt = "Constant name: ",
				default = suggested_name,
			}, function(const_name)
				if not const_name or const_name == "" then
					return
				end

				local insert_pos = lang.find_insert_position and lang.find_insert_position() or 1
				local indent = "    "

				local declaration = lang.generate_constant_declaration(indent, final_type, const_name, expr_text)
				api.nvim_buf_set_lines(bufnr, insert_pos, insert_pos, false, { declaration, "" })

				-- Replace expression with constant name
				if selected.start_col and selected.end_col then
					-- Account for inserted lines
					local new_row = row + 2
					local current_line = api.nvim_buf_get_lines(bufnr, new_row - 1, new_row, false)[1]
					local new_line = current_line:sub(1, selected.start_col - 1) .. const_name:upper() .. current_line:sub(selected.end_col + 1)
					api.nvim_buf_set_lines(bufnr, new_row - 1, new_row, false, { new_line })
				end

				vim.notify(string.format("Extracted constant: %s", const_name:upper()), vim.log.levels.INFO)
			end)
		end

		if inferred_type and inferred_type ~= "(?)" then
			complete_extraction(inferred_type)
		else
			lang.get_type_for_expression_async(bufnr, row, selected.start_col, expr_text, function(lsp_type, err)
				vim.schedule(function()
					if lsp_type then
						complete_extraction(lsp_type)
					else
						vim.ui.input({
							prompt = "Type: ",
							default = "Object",
						}, function(user_type)
							if user_type and user_type ~= "" then
								complete_extraction(user_type)
							end
						end)
					end
				end)
			end)
		end
	end)
end

function M.extract_method()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	-- Get visual selection
	local start_row, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
	local end_row, end_col = unpack(vim.fn.getpos("'>"), 2, 3)

	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	if #lines == 0 then
		vim.notify("No selection", vim.log.levels.WARN)
		return
	end

	-- Adjust for visual selection
	lines[1] = lines[1]:sub(start_col)
	lines[#lines] = lines[#lines]:sub(1, end_col)

	local selected_code = table.concat(lines, "\n")
	local indent = core.get_line_indent(api.nvim_buf_get_lines(0, start_row - 1, start_row, false)[1])

	vim.ui.input({
		prompt = "Method name: ",
		default = "extractedMethod",
	}, function(method_name)
		if not method_name or method_name == "" then
			return
		end

		-- Generate method (simplified - doesn't analyze parameters/return type)
		local method_code = lang.generate_method({
			name = method_name,
			return_type = "void",
			params = {},
			body = selected_code,
			indent = "    ",
		})

		-- Find insert position and add method
		local insert_pos = lang.find_insert_position()
		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. method_code .. "\n", "\n"))

		-- Replace selection with method call
		local method_call = indent .. method_name .. "();"
		api.nvim_buf_set_lines(0, start_row - 1, end_row, false, { method_call })

		vim.notify(string.format("Extracted method: %s()", method_name), vim.log.levels.INFO)
	end)
end

function M.extract_parameter()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2] + 1
	local line = api.nvim_get_current_line()

	local expressions = lang.parse_expressions(line, col)

	if #expressions == 0 then
		vim.notify("No extractable expression found", vim.log.levels.WARN)
		return
	end

	-- Build type cache
	local type_cache = {}
	for _, expr in ipairs(expressions) do
		local inferred = lang.infer_type_from_expression(expr.text)
		if inferred then
			type_cache[expr.text] = inferred
		else
			local lsp_type = lang.get_type_for_expression_sync(bufnr, row, expr.start_col, expr.text, 500)
			type_cache[expr.text] = lsp_type or "(?)"
		end
	end

	core.show_expression_selector(expressions, "Extract Parameter", bufnr, row, type_cache, function(selected)
		local expr_text = selected.text
		local inferred_type = selected.cached_type or lang.infer_type_from_expression(expr_text)

		local function complete_extraction(final_type)
			local suggested_name = core.generate_var_name(final_type, expr_text)

			vim.ui.input({
				prompt = "Parameter name: ",
				default = suggested_name,
			}, function(param_name)
				if not param_name or param_name == "" then
					return
				end

				-- Replace expression with parameter name
				if selected.start_col and selected.end_col then
					local new_line = line:sub(1, selected.start_col - 1) .. param_name .. line:sub(selected.end_col + 1)
					api.nvim_buf_set_lines(bufnr, row - 1, row, false, { new_line })
				end

				-- Find method signature and add parameter
				local all_lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
				for i = row - 1, 1, -1 do
					local method_line = all_lines[i]
					local sig_start, sig_end = method_line:find("%b()")
					if sig_start then
						local before = method_line:sub(1, sig_end - 1)
						local after = method_line:sub(sig_end)
						local new_param = lang.generate_parameter(final_type, param_name)

						local new_sig
						if before:match("%(%)$") or before:match("%($") then
							new_sig = before:gsub("%($", "") .. "(" .. new_param .. after
						else
							new_sig = before .. ", " .. new_param .. after
						end

						api.nvim_buf_set_lines(bufnr, i - 1, i, false, { new_sig })
						break
					end
				end

				vim.notify(string.format("Extracted parameter: %s %s", final_type, param_name), vim.log.levels.INFO)
			end)
		end

		if inferred_type and inferred_type ~= "(?)" then
			complete_extraction(inferred_type)
		else
			lang.get_type_for_expression_async(bufnr, row, selected.start_col, expr_text, function(lsp_type, err)
				vim.schedule(function()
					if lsp_type then
						complete_extraction(lsp_type)
					else
						vim.ui.input({
							prompt = "Type: ",
							default = "Object",
						}, function(user_type)
							if user_type and user_type ~= "" then
								complete_extraction(user_type)
							end
						end)
					end
				end)
			end)
		end
	end)
end

function M.extract_field()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2] + 1
	local line = api.nvim_get_current_line()

	local expressions = lang.parse_expressions(line, col)

	if #expressions == 0 then
		vim.notify("No extractable expression found", vim.log.levels.WARN)
		return
	end

	-- Build type cache
	local type_cache = {}
	for _, expr in ipairs(expressions) do
		local inferred = lang.infer_type_from_expression(expr.text)
		if inferred then
			type_cache[expr.text] = inferred
		else
			local lsp_type = lang.get_type_for_expression_sync(bufnr, row, expr.start_col, expr.text, 500)
			type_cache[expr.text] = lsp_type or "(?)"
		end
	end

	core.show_expression_selector(expressions, "Extract Field", bufnr, row, type_cache, function(selected)
		local expr_text = selected.text
		local inferred_type = selected.cached_type or lang.infer_type_from_expression(expr_text)

		local function complete_extraction(final_type)
			local suggested_name = core.generate_var_name(final_type, expr_text)

			vim.ui.input({
				prompt = "Field name: ",
				default = suggested_name,
			}, function(field_name)
				if not field_name or field_name == "" then
					return
				end

				local insert_pos = lang.find_insert_position and lang.find_insert_position() or 1
				local indent = "    "

				local declaration = lang.generate_field_declaration(indent, final_type, field_name, expr_text)
				api.nvim_buf_set_lines(bufnr, insert_pos, insert_pos, false, { declaration, "" })

				-- Replace expression with field name
				if selected.start_col and selected.end_col then
					local new_row = row + 2
					local current_line = api.nvim_buf_get_lines(bufnr, new_row - 1, new_row, false)[1]
					local new_line = current_line:sub(1, selected.start_col - 1) .. "this." .. field_name .. current_line:sub(selected.end_col + 1)
					api.nvim_buf_set_lines(bufnr, new_row - 1, new_row, false, { new_line })
				end

				vim.notify(string.format("Extracted field: %s", field_name), vim.log.levels.INFO)
			end)
		end

		if inferred_type and inferred_type ~= "(?)" then
			complete_extraction(inferred_type)
		else
			lang.get_type_for_expression_async(bufnr, row, selected.start_col, expr_text, function(lsp_type, err)
				vim.schedule(function()
					if lsp_type then
						complete_extraction(lsp_type)
					else
						vim.ui.input({
							prompt = "Type: ",
							default = "Object",
						}, function(user_type)
							if user_type and user_type ~= "" then
								complete_extraction(user_type)
							end
						end)
					end
				end)
			end)
		end
	end)
end

-- ============================================================================
-- Generate Operations
-- ============================================================================

function M.generate_constructor()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	local class_name = lang.find_class_name()

	core.select_fields_with_ui(fields, "Select fields for constructor", function(selected_fields)
		local insert_pos = lang.find_insert_position()
		local code = lang.generate_constructor(class_name, selected_fields, "    ")

		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))
		vim.notify("Constructor generated", vim.log.levels.INFO)
	end)
end

function M.generate_getter()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	core.select_fields_with_ui(fields, "Select fields for getters", function(selected_fields)
		if #selected_fields == 0 then
			vim.notify("No fields selected", vim.log.levels.WARN)
			return
		end

		local insert_pos = lang.find_insert_position()
		local code_parts = {}

		for _, field in ipairs(selected_fields) do
			table.insert(code_parts, lang.generate_getter(field, "    "))
		end

		local code = table.concat(code_parts, "\n\n")
		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))
		vim.notify("Getter(s) generated", vim.log.levels.INFO)
	end)
end

function M.generate_setter()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	core.select_fields_with_ui(fields, "Select fields for setters", function(selected_fields)
		if #selected_fields == 0 then
			vim.notify("No fields selected", vim.log.levels.WARN)
			return
		end

		local insert_pos = lang.find_insert_position()
		local code_parts = {}

		for _, field in ipairs(selected_fields) do
			table.insert(code_parts, lang.generate_setter(field, "    "))
		end

		local code = table.concat(code_parts, "\n\n")
		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))
		vim.notify("Setter(s) generated", vim.log.levels.INFO)
	end)
end

function M.generate_getter_and_setter()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	core.select_fields_with_ui(fields, "Select fields for getters/setters", function(selected_fields)
		if #selected_fields == 0 then
			vim.notify("No fields selected", vim.log.levels.WARN)
			return
		end

		local insert_pos = lang.find_insert_position()
		local code_parts = {}

		for _, field in ipairs(selected_fields) do
			table.insert(code_parts, lang.generate_getter(field, "    "))
			table.insert(code_parts, lang.generate_setter(field, "    "))
		end

		local code = table.concat(code_parts, "\n\n")
		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))
		vim.notify("Getter(s) and Setter(s) generated", vim.log.levels.INFO)
	end)
end

function M.generate_equals()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	local class_name = lang.find_class_name()

	core.select_fields_with_ui(fields, "Select fields for equals/hashCode", function(selected_fields)
		if #selected_fields == 0 then
			vim.notify("No fields selected", vim.log.levels.WARN)
			return
		end

		local insert_pos = lang.find_insert_position()
		local code = lang.generate_equals(class_name, selected_fields, "    ")

		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))

		if lang.add_import then
			lang.add_import("java.util.Objects")
		end

		vim.notify("equals() and hashCode() generated", vim.log.levels.INFO)
	end)
end

function M.generate_tostring()
	local lang = get_language_module()
	if not lang then
		vim.notify("No refactoring support for this filetype", vim.log.levels.WARN)
		return
	end

	local fields = lang.extract_fields()
	if #fields == 0 then
		vim.notify("No fields found", vim.log.levels.WARN)
		return
	end

	local class_name = lang.find_class_name()

	core.select_fields_with_ui(fields, "Select fields for toString", function(selected_fields)
		if #selected_fields == 0 then
			vim.notify("No fields selected", vim.log.levels.WARN)
			return
		end

		local insert_pos = lang.find_insert_position()
		local code = lang.generate_tostring(class_name, selected_fields, "    ")

		api.nvim_buf_set_lines(0, insert_pos, insert_pos, false, vim.split("\n" .. code .. "\n", "\n"))
		vim.notify("toString() generated", vim.log.levels.INFO)
	end)
end

-- ============================================================================
-- Debug Functions
-- ============================================================================

function M.debug_hover()
	local lang = get_language_module()
	if not lang or not lang.get_lsp_client then
		vim.notify("No LSP support for this filetype", vim.log.levels.WARN)
		return
	end

	local client = lang.get_lsp_client()
	if not client then
		vim.notify("LSP not available", vim.log.levels.ERROR)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2]

	local params = {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = { line = row - 1, character = col },
	}

	client:request("textDocument/hover", params, function(err, result)
		if err then
			vim.notify("Error: " .. vim.inspect(err), vim.log.levels.ERROR)
			return
		end
		if not result then
			vim.notify("No hover result", vim.log.levels.WARN)
			return
		end

		local content = vim.inspect(result)
		local lines = vim.split(content, "\n")

		local buf = api.nvim_create_buf(false, true)
		api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		local width = math.min(100, vim.o.columns - 4)
		local height = math.min(30, #lines)

		local win = api.nvim_open_win(buf, true, {
			relative = "cursor",
			row = 1,
			col = 0,
			width = width,
			height = height,
			style = "minimal",
			border = "rounded",
			title = " LSP Hover Response ",
			title_pos = "center",
		})

		vim.keymap.set("n", "q", function()
			api.nvim_win_close(win, true)
		end, { buffer = buf })
		vim.keymap.set("n", "<Esc>", function()
			api.nvim_win_close(win, true)
		end, { buffer = buf })
	end, bufnr)
end

function M.debug_chain()
	local lang = get_language_module()
	if not lang or not lang.parse_multiline_chain then
		vim.notify("No chain parsing support for this filetype", vim.log.levels.WARN)
		return
	end

	local bufnr = api.nvim_get_current_buf()
	local cursor = api.nvim_win_get_cursor(0)
	local row, col = cursor[1], cursor[2] + 1

	local expressions, start_row, start_col, end_row, end_col, full_expr = lang.parse_multiline_chain(bufnr, row, col)

	local debug_info = {
		"=== Chain Parsing Debug ===",
		string.format("Cursor: row=%d, col=%d", row, col),
		string.format("Chain Range: [%d,%d] -> [%d,%d]", start_row or 0, start_col or 0, end_row or 0, end_col or 0),
		string.format("Expression Count: %d", #expressions),
		"",
		"=== Full Expression ===",
		full_expr or "(none)",
		"",
		"=== Parsed Expressions ===",
	}

	for i, expr in ipairs(expressions) do
		table.insert(debug_info, string.format("[%d] %s (col: %s-%s)", i, expr.text, expr.start_col or "?", expr.end_col or "?"))
	end

	local buf = api.nvim_create_buf(false, true)
	api.nvim_buf_set_lines(buf, 0, -1, false, debug_info)

	local width = math.min(100, vim.o.columns - 4)
	local height = math.min(30, #debug_info)

	local win = api.nvim_open_win(buf, true, {
		relative = "cursor",
		row = 1,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " Chain Parsing Debug ",
		title_pos = "center",
	})

	vim.keymap.set("n", "q", function()
		api.nvim_win_close(win, true)
	end, { buffer = buf })
	vim.keymap.set("n", "<Esc>", function()
		api.nvim_win_close(win, true)
	end, { buffer = buf })
end

-- ============================================================================
-- Test Navigation
-- ============================================================================

function M.goto_test()
	local lang = get_language_module()
	if not lang or not lang.goto_test then
		vim.notify("No test navigation support for this filetype", vim.log.levels.WARN)
		return
	end
	lang.goto_test()
end

function M.create_test_file()
	local lang = get_language_module()
	if not lang or not lang.create_test_file then
		vim.notify("No test creation support for this filetype", vim.log.levels.WARN)
		return
	end
	lang.create_test_file()
end

-- ============================================================================
-- Auto-load language modules
-- ============================================================================

local ok, java = pcall(require, "refactor.language.java")
if ok then
	M.register_language("java", java)
end

local ok_js, javascript = pcall(require, "refactor.language.javascript")
if ok_js then
	M.register_language("javascript", javascript)
	M.register_language("javascriptreact", javascript)
	M.register_language("typescript", javascript)
	M.register_language("typescriptreact", javascript)
end

return M
