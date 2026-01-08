-- refactor/language/javascript.lua
-- JavaScript/TypeScript refactoring implementation

local api = vim.api
local core = require("refactor.core")

local M = core.create_language_module()

-- ============================================================================
-- Detection
-- ============================================================================

function M.is_supported_file()
	local ft = vim.bo.filetype
	return ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact"
end

function M.get_lsp_client()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		if client.name == "ts_ls" or client.name == "tsserver" or client.name == "vtsls" then
			return client
		end
	end
	return nil
end

-- ============================================================================
-- Type Inference
-- ============================================================================

-- Infer type from expression pattern (for display purposes)
function M.infer_type_from_expression(expr)
	if not expr then
		return nil
	end

	-- String literal (single, double, or template)
	if expr:match('^".*"$') or expr:match("^'.*'$") or expr:match("^`.*`$") then
		return "string"
	end

	-- Boolean literals
	if expr == "true" or expr == "false" then
		return "boolean"
	end

	-- null/undefined
	if expr == "null" then
		return "null"
	end
	if expr == "undefined" then
		return "undefined"
	end

	-- Numeric literals
	if expr:match("^%-?%d+%.%d*$") or expr:match("^%-?%d*%.%d+$") then
		return "number"
	end
	if expr:match("^%-?%d+$") then
		return "number"
	end
	if expr:match("^0[xX]%x+$") then
		return "number"
	end
	if expr:match("^0[bB][01]+$") then
		return "number"
	end
	if expr:match("^0[oO][0-7]+$") then
		return "number"
	end

	-- BigInt
	if expr:match("^%-?%d+n$") then
		return "bigint"
	end

	-- Array literal
	if expr:match("^%[.*%]$") then
		return "Array"
	end

	-- Object literal
	if expr:match("^{.*}$") then
		return "object"
	end

	-- Arrow function
	if expr:match("^%(?[^)]*%)?%s*=>") then
		return "function"
	end

	-- Regular function
	if expr:match("^function%s*%(") or expr:match("^function%s+%w+%s*%(") then
		return "function"
	end

	-- new Constructor()
	local constructor = expr:match("^new%s+([%w_]+)")
	if constructor then
		return constructor
	end

	-- Promise.resolve/reject
	if expr:match("^Promise%.") then
		return "Promise"
	end

	-- Common method patterns
	if expr:match("%.map%([^)]*%)$") or expr:match("%.filter%([^)]*%)$") or expr:match("%.slice%([^)]*%)$") then
		return "Array"
	end
	if expr:match("%.toString%([^)]*%)$") or expr:match("%.trim%([^)]*%)$") or expr:match("%.toLowerCase%([^)]*%)$") then
		return "string"
	end
	if expr:match("%.json%([^)]*%)$") then
		return "Promise"
	end

	-- await expression
	if expr:match("^await%s+") then
		-- Can't determine type without more context
		return nil
	end

	return nil
end

-- Parse LSP hover response for type
function M.parse_hover_for_type(hover_content)
	if not hover_content then
		return nil
	end

	local content_str = nil
	if type(hover_content) == "string" then
		content_str = hover_content
	elseif type(hover_content) == "table" then
		if hover_content.value then
			content_str = hover_content.value
		elseif #hover_content > 0 then
			for _, item in ipairs(hover_content) do
				if type(item) == "string" then
					content_str = item
					break
				elseif type(item) == "table" and item.value then
					content_str = item.value
					break
				end
			end
		end
	end

	if not content_str then
		return nil
	end

	-- Extract TypeScript type annotation
	-- Pattern: (property) name: Type
	-- Pattern: const name: Type
	-- Pattern: let name: Type
	-- Pattern: function name(): Type

	local type_str = content_str:match(":%s*([^\n]+)")
	if type_str then
		-- Clean up the type
		type_str = type_str:gsub("^%s+", ""):gsub("%s+$", "")
		-- Remove trailing semicolon if present
		type_str = type_str:gsub(";$", "")
		return type_str
	end

	return nil
end

-- Async type inference via LSP
function M.get_type_for_expression_async(bufnr, row, expr_start_col, expr_text, callback)
	local client = M.get_lsp_client()
	if not client then
		callback(nil, "TypeScript LSP not available")
		return
	end

	-- Calculate hover position (middle of the expression or method name)
	local hover_offset = #expr_text

	if expr_text:match("%)$") then
		-- Find the method name position
		local depth = 0
		local open_paren_pos = nil
		for i = #expr_text, 1, -1 do
			local c = expr_text:sub(i, i)
			if c == ")" then
				depth = depth + 1
			elseif c == "(" then
				depth = depth - 1
				if depth == 0 then
					open_paren_pos = i
					break
				end
			end
		end

		if open_paren_pos then
			local method_end = open_paren_pos - 1
			local method_start = method_end
			for i = method_end, 1, -1 do
				local c = expr_text:sub(i, i)
				if c:match("[%w_]") then
					method_start = i
				else
					break
				end
			end
			hover_offset = math.floor((method_start + method_end) / 2)
		end
	else
		local last_dot = expr_text:match(".*()%.") or 0
		local identifier_start = last_dot + 1
		local identifier_end = #expr_text
		hover_offset = math.floor((identifier_start + identifier_end) / 2)
	end

	local hover_col
	if expr_start_col then
		hover_col = expr_start_col + hover_offset - 1
	else
		hover_col = 1
	end

	if hover_col < 1 then
		hover_col = 1
	end

	local params = {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = { line = row - 1, character = hover_col - 1 },
	}

	client:request("textDocument/hover", params, function(err, result)
		if err or not result or not result.contents then
			callback(nil, err)
			return
		end

		local parsed_type = M.parse_hover_for_type(result.contents)
		if parsed_type then
			callback(parsed_type, nil)
		else
			callback(nil, "Could not parse type from hover")
		end
	end, bufnr)
end

-- Sync wrapper
function M.get_type_for_expression_sync(bufnr, row, expr_start_col, expr_text, timeout_ms)
	timeout_ms = timeout_ms or 1000
	local result_type = nil
	local done = false

	M.get_type_for_expression_async(bufnr, row, expr_start_col, expr_text, function(type_str, err)
		result_type = type_str
		done = true
	end)

	vim.wait(timeout_ms, function()
		return done
	end, 10)

	return result_type
end

-- ============================================================================
-- Expression Parsing
-- ============================================================================

function M.parse_expressions(line, col)
	local expressions = {}

	local expr_start = col
	local paren_depth = 0
	local bracket_depth = 0
	local brace_depth = 0
	local in_string = false
	local string_char = nil
	local in_template = false
	local template_depth = 0

	-- Go backwards to find expression start
	for i = col, 1, -1 do
		local char = line:sub(i, i)
		local prev_char = i > 1 and line:sub(i - 1, i - 1) or ""

		-- Handle template literals
		if char == "`" and prev_char ~= "\\" then
			if in_template then
				in_template = false
			elseif not in_string then
				in_template = true
			end
		end

		-- Handle ${} in template literals
		if in_template then
			if char == "}" and prev_char ~= "\\" then
				template_depth = template_depth - 1
			elseif char == "{" and prev_char == "$" then
				template_depth = template_depth + 1
			end
		end

		-- Handle regular strings
		if not in_template and (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
				string_char = nil
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		if not in_string and not in_template then
			if char == ")" then
				paren_depth = paren_depth + 1
			elseif char == "(" then
				paren_depth = paren_depth - 1
				if paren_depth < 0 then
					expr_start = i + 1
					break
				end
			elseif char == "]" then
				bracket_depth = bracket_depth + 1
			elseif char == "[" then
				bracket_depth = bracket_depth - 1
				if bracket_depth < 0 then
					expr_start = i + 1
					break
				end
			elseif char == "}" then
				brace_depth = brace_depth + 1
			elseif char == "{" then
				brace_depth = brace_depth - 1
				if brace_depth < 0 then
					expr_start = i + 1
					break
				end
			end

			if paren_depth == 0 and bracket_depth == 0 and brace_depth == 0 then
				if char:match("[%s,;={+%-*/%%&|^!~?:]") then
					-- Check for arrow function
					if char == ">" and prev_char == "=" then
						-- Part of arrow function, continue
					else
						expr_start = i + 1
						break
					end
				end
			end
		end
		expr_start = i
	end

	-- Handle keywords (new, await, typeof, etc.)
	local before_start = line:sub(1, expr_start - 1)
	local keyword = before_start:match("(new)%s*$") or
		before_start:match("(await)%s*$") or
		before_start:match("(typeof)%s*$") or
		before_start:match("(void)%s*$")
	if keyword then
		expr_start = before_start:find(keyword .. "%s*$")
	end

	-- Find expression end
	local expr_end = col
	paren_depth = 0
	bracket_depth = 0
	brace_depth = 0
	in_string = false
	string_char = nil
	in_template = false
	template_depth = 0

	for i = expr_start, #line do
		local char = line:sub(i, i)
		local prev_char = i > 1 and line:sub(i - 1, i - 1) or ""

		-- Handle template literals
		if char == "`" and prev_char ~= "\\" then
			if in_template then
				in_template = false
			elseif not in_string then
				in_template = true
			end
		end

		-- Handle ${} in template literals
		if in_template then
			if char == "{" and prev_char == "$" then
				template_depth = template_depth + 1
			elseif char == "}" and template_depth > 0 then
				template_depth = template_depth - 1
			end
		end

		-- Handle regular strings
		if not in_template and (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
				string_char = nil
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		if not in_string and not in_template then
			if char == "(" then
				paren_depth = paren_depth + 1
			elseif char == ")" then
				if paren_depth > 0 then
					paren_depth = paren_depth - 1
				else
					expr_end = i - 1
					break
				end
			elseif char == "[" then
				bracket_depth = bracket_depth + 1
			elseif char == "]" then
				if bracket_depth > 0 then
					bracket_depth = bracket_depth - 1
				else
					expr_end = i - 1
					break
				end
			elseif char == "{" then
				brace_depth = brace_depth + 1
			elseif char == "}" then
				if brace_depth > 0 then
					brace_depth = brace_depth - 1
				else
					expr_end = i - 1
					break
				end
			end

			if paren_depth == 0 and bracket_depth == 0 and brace_depth == 0 then
				if char:match("[;,}]") then
					expr_end = i - 1
					break
				end
			end
		end
		expr_end = i
	end

	-- Extract full expression
	local full_expr = line:sub(expr_start, expr_end):gsub("^%s+", ""):gsub("%s+$", "")

	if full_expr == "" then
		return expressions
	end

	-- Build sub-expressions
	local current = ""
	paren_depth = 0
	in_string = false
	in_template = false

	for i = 1, #full_expr do
		local char = full_expr:sub(i, i)
		local prev_char = i > 1 and full_expr:sub(i - 1, i - 1) or ""

		-- Handle template literals
		if char == "`" and prev_char ~= "\\" then
			in_template = not in_template
		end

		-- Handle regular strings
		if not in_template and (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		current = current .. char

		if not in_string and not in_template then
			if char == "(" then
				paren_depth = paren_depth + 1
			elseif char == ")" then
				paren_depth = paren_depth - 1
				if paren_depth == 0 then
					local trimmed = current:gsub("^%s+", ""):gsub("%s+$", "")
					if trimmed ~= "" then
						local exists = false
						for _, e in ipairs(expressions) do
							if e.text == trimmed then exists = true; break end
						end
						if not exists then
							table.insert(expressions, {
								text = trimmed,
								start_col = expr_start,
								end_col = expr_start + #current - 1
							})
						end
					end
				end
			end
		end
	end

	-- Add final expression
	local final = current:gsub("^%s+", ""):gsub("%s+$", "")
	if final ~= "" then
		local exists = false
		for _, e in ipairs(expressions) do
			if e.text == final then exists = true; break end
		end
		if not exists then
			table.insert(expressions, {
				text = final,
				start_col = expr_start,
				end_col = expr_end
			})
		end
	end

	table.sort(expressions, function(a, b) return #a.text < #b.text end)

	return expressions
end

-- Parse multi-line chain (Promise chains, method chains, etc.)
function M.parse_multiline_chain(bufnr, cursor_row, cursor_col)
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[cursor_row]

	local is_chain_continuation = current_line:match("^%s*%.")
		or current_line:match("^%s*%?%.")  -- Optional chaining

	local chain_start_row = cursor_row
	local chain_start_col = 1

	if is_chain_continuation then
		local paren_depth = 0

		-- Calculate initial paren depth from cursor to end
		for i = cursor_row, #lines do
			local line = lines[i]
			for j = 1, #line do
				local char = line:sub(j, j)
				if char == "(" or char == "[" then paren_depth = paren_depth + 1
				elseif char == ")" or char == "]" then paren_depth = paren_depth - 1
				end
			end
			if line:find(";") or (line:find("[^%s]") and not line:match("[%.%(%,%?]%s*$") and not line:match("^%s*[%.%)]")) then
				break
			end
		end

		-- Go backwards tracking paren depth
		for i = cursor_row - 1, 1, -1 do
			local line = lines[i]

			for j = #line, 1, -1 do
				local char = line:sub(j, j)
				if char == ")" or char == "]" then paren_depth = paren_depth + 1
				elseif char == "(" or char == "[" then paren_depth = paren_depth - 1
				end
			end

			local is_chain_start = false

			if paren_depth <= 0 then
				-- Find assignment (const, let, var, or just =)
				local eq_pos = nil
				for pos = 1, #line do
					local char = line:sub(pos, pos)
					local prev_char = pos > 1 and line:sub(pos - 1, pos - 1) or ""
					local next_char = pos < #line and line:sub(pos + 1, pos + 1) or ""
					if char == "=" and prev_char ~= "=" and prev_char ~= "!" and prev_char ~= "<" and prev_char ~= ">" and next_char ~= "=" and next_char ~= ">" then
						eq_pos = pos
						break
					end
				end

				if eq_pos then
					chain_start_row = i
					local after_eq = line:sub(eq_pos + 1)
					local whitespace_len = #(after_eq:match("^%s*") or "")
					chain_start_col = eq_pos + 1 + whitespace_len
					is_chain_start = true
				elseif line:find("return%s+") then
					chain_start_row = i
					local return_pos = line:find("return%s+")
					local after_return = line:sub(return_pos):match("^return%s+")
					chain_start_col = return_pos + #after_return
					is_chain_start = true
				elseif not line:match("^%s*[%)%]%},]") and line:match("^%s*[%w_]") then
					chain_start_row = i
					local start_match = line:match("^(%s*)")
					chain_start_col = #start_match + 1
					is_chain_start = true
				end
			end

			if is_chain_start then
				break
			end
		end
	else
		local expr_start = cursor_col
		for i = cursor_col, 1, -1 do
			local char = current_line:sub(i, i)
			if char:match("[%s,;={]") then
				expr_start = i + 1
				break
			end
			expr_start = i
		end
		chain_start_col = expr_start
	end

	-- Find chain end
	local chain_end_row = cursor_row
	local chain_end_col = #current_line

	for i = cursor_row, #lines do
		local line = lines[i]
		local semi_pos = line:find(";")
		if semi_pos then
			chain_end_row = i
			chain_end_col = semi_pos - 1
			break
		end
		if i > cursor_row and not line:match("[%.%(%,]%s*$") and not line:match("^%s*[%.%)]") then
			chain_end_row = i - 1
			chain_end_col = #lines[i - 1]
			break
		end
	end

	-- Build full expression
	local expr_parts = {}
	for i = chain_start_row, chain_end_row do
		local line = lines[i]
		local start_c = (i == chain_start_row) and chain_start_col or 1
		local end_c = (i == chain_end_row) and chain_end_col or #line

		local part = line:sub(start_c, end_c)
		part = part:gsub("^%s+", ""):gsub("%s+$", "")
		if part ~= "" then
			table.insert(expr_parts, part)
		end
	end

	local full_expr = table.concat(expr_parts, "")
	full_expr = full_expr:gsub("%s*%.%s*", "."):gsub("%s*%?%.%s*", "?.")

	-- Build expressions list
	local expressions = {}
	local current = ""
	local paren_depth = 0
	local in_string = false
	local string_char = nil
	local in_template = false

	for i = 1, #full_expr do
		local char = full_expr:sub(i, i)
		local prev_char = i > 1 and full_expr:sub(i - 1, i - 1) or ""

		if char == "`" and prev_char ~= "\\" then
			in_template = not in_template
		end

		if not in_template and (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		current = current .. char

		if not in_string and not in_template then
			if char == "(" then
				paren_depth = paren_depth + 1
			elseif char == ")" then
				paren_depth = paren_depth - 1
				if paren_depth == 0 then
					local trimmed = current:gsub("^%s+", ""):gsub("%s+$", "")
					if trimmed ~= "" then
						local exists = false
						for _, e in ipairs(expressions) do
							if e.text == trimmed then exists = true; break end
						end
						if not exists then
							table.insert(expressions, { text = trimmed })
						end
					end
				end
			end
		end
	end

	-- Add final
	local final = current:gsub("^%s+", ""):gsub("%s+$", "")
	if final ~= "" then
		local exists = false
		for _, e in ipairs(expressions) do
			if e.text == final then exists = true; break end
		end
		if not exists then
			table.insert(expressions, { text = final })
		end
	end

	table.sort(expressions, function(a, b) return #a.text < #b.text end)

	return expressions, chain_start_row, chain_start_col, chain_end_row, chain_end_col, full_expr
end

-- ============================================================================
-- Code Generation
-- ============================================================================

-- Check if we're in TypeScript
local function is_typescript()
	local ft = vim.bo.filetype
	return ft == "typescript" or ft == "typescriptreact"
end

function M.generate_variable_declaration(indent, type_str, name, expr)
	-- In JavaScript, we don't use type annotations (unless TypeScript)
	if is_typescript() and type_str and type_str ~= "(?)" then
		return string.format("%sconst %s: %s = %s;", indent, name, type_str, expr)
	else
		return string.format("%sconst %s = %s;", indent, name, expr)
	end
end

function M.generate_constant_declaration(indent, type_str, name, expr)
	-- Constants in JS/TS are just const with UPPER_CASE naming
	if is_typescript() and type_str and type_str ~= "(?)" then
		return string.format("%sconst %s: %s = %s;", indent, name:upper(), type_str, expr)
	else
		return string.format("%sconst %s = %s;", indent, name:upper(), expr)
	end
end

function M.generate_field_declaration(indent, type_str, name, expr)
	-- Class field (for ES2022+ or TypeScript)
	if is_typescript() and type_str and type_str ~= "(?)" then
		return string.format("%sprivate %s: %s = %s;", indent, name, type_str, expr)
	else
		return string.format("%s#%s = %s;", indent, name, expr)  -- Private field syntax
	end
end

function M.generate_parameter(type_str, name)
	if is_typescript() and type_str and type_str ~= "(?)" then
		return string.format("%s: %s", name, type_str)
	else
		return name
	end
end

function M.generate_method(params)
	local indent = params.indent or "  "
	local name = params.name
	local method_params = params.params or ""
	local body = params.body or ""
	local return_type = params.return_type
	local is_async = params.is_async and "async " or ""

	local lines = {}

	if is_typescript() and return_type and return_type ~= "void" then
		table.insert(lines, string.format("%s%s%s(%s): %s {", indent, is_async, name, method_params, return_type))
	else
		table.insert(lines, string.format("%s%s%s(%s) {", indent, is_async, name, method_params))
	end

	for _, line in ipairs(vim.split(body, "\n")) do
		table.insert(lines, indent .. "  " .. line)
	end

	table.insert(lines, indent .. "}")

	return table.concat(lines, "\n")
end

function M.generate_constructor(class_name, fields, indent)
	indent = indent or "  "
	local params = {}
	local assignments = {}

	for _, field in ipairs(fields) do
		if is_typescript() then
			table.insert(params, field.name .. ": " .. field.type)
		else
			table.insert(params, field.name)
		end
		table.insert(assignments, indent .. "  this." .. field.name .. " = " .. field.name .. ";")
	end

	local lines = {
		indent .. "constructor(" .. table.concat(params, ", ") .. ") {",
	}
	for _, a in ipairs(assignments) do
		table.insert(lines, a)
	end
	table.insert(lines, indent .. "}")

	return table.concat(lines, "\n")
end

function M.generate_getter(field, indent)
	indent = indent or "  "
	local public_name = field.name:gsub("^[_#]", "")
	local backing_field = field.name

	if is_typescript() then
		return string.format(
			"%sget %s(): %s {\n%s  return this.%s;\n%s}",
			indent, public_name, field.type,
			indent, backing_field,
			indent
		)
	else
		return string.format(
			"%sget %s() {\n%s  return this.%s;\n%s}",
			indent, public_name,
			indent, backing_field,
			indent
		)
	end
end

function M.generate_setter(field, indent)
	indent = indent or "  "
	local public_name = field.name:gsub("^[_#]", "")
	local backing_field = field.name

	if is_typescript() then
		return string.format(
			"%sset %s(value: %s) {\n%s  this.%s = value;\n%s}",
			indent, public_name, field.type,
			indent, backing_field,
			indent
		)
	else
		return string.format(
			"%sset %s(value) {\n%s  this.%s = value;\n%s}",
			indent, public_name,
			indent, backing_field,
			indent
		)
	end
end

function M.generate_equals(class_name, fields, indent)
	indent = indent or "  "

	local conditions = {}
	for _, field in ipairs(fields) do
		table.insert(conditions, "this." .. field.name .. " === other." .. field.name)
	end

	local lines = {
		indent .. "equals(other) {",
		indent .. "  if (this === other) return true;",
		indent .. "  if (!other || !(other instanceof " .. class_name .. ")) return false;",
		indent .. "  return " .. table.concat(conditions, " &&\n" .. indent .. "         ") .. ";",
		indent .. "}",
	}

	return table.concat(lines, "\n")
end

function M.generate_tostring(class_name, fields, indent)
	indent = indent or "  "
	local field_strs = {}

	for _, field in ipairs(fields) do
		table.insert(field_strs, field.name .. ": ${this." .. field.name .. "}")
	end

	local lines = {
		indent .. "toString() {",
		indent .. "  return `" .. class_name .. " { " .. table.concat(field_strs, ", ") .. " }`;",
		indent .. "}",
	}

	return table.concat(lines, "\n")
end

-- ============================================================================
-- Import Handling
-- ============================================================================

function M.add_import(import_path)
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Check if already imported
	for _, line in ipairs(lines) do
		if line:match(vim.pesc(import_path)) then
			return
		end
	end

	-- Find insert position (after existing imports or at top)
	local insert_pos = 0
	local last_import = 0

	for i, line in ipairs(lines) do
		if line:match("^import%s+") or line:match("^const%s+.-=%s*require") then
			last_import = i
		end
	end

	if last_import > 0 then
		insert_pos = last_import
	end

	-- Determine import style (ESM vs CommonJS)
	local has_esm = false
	local has_cjs = false
	for _, line in ipairs(lines) do
		if line:match("^import%s+") then has_esm = true end
		if line:match("require%s*%(") then has_cjs = true end
	end

	local import_statement
	if has_cjs and not has_esm then
		-- CommonJS style
		local module_name = import_path:match("[^/]+$") or import_path
		import_statement = string.format("const %s = require('%s');", module_name, import_path)
	else
		-- ES Module style
		import_statement = string.format("import '%s';", import_path)
	end

	api.nvim_buf_set_lines(bufnr, insert_pos, insert_pos, false, { import_statement })
end

function M.get_imports_for_type(type_str)
	-- JavaScript doesn't have automatic imports like Java
	-- But we could add common patterns here
	return {}
end

-- ============================================================================
-- Class Utilities
-- ============================================================================

function M.extract_fields()
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local fields = {}
	local seen = {}

	for _, line in ipairs(lines) do
		local name, field_type = nil, nil

		-- TypeScript: private/public type name
		local ts_mod_type, ts_mod_name = line:match("^%s*private%s+([%w_<>|]+)%s+([%w_]+)")
		if not ts_mod_type then
			ts_mod_type, ts_mod_name = line:match("^%s*public%s+([%w_<>|]+)%s+([%w_]+)")
		end
		if ts_mod_type and ts_mod_name then
			name, field_type = ts_mod_name, ts_mod_type
		end

		-- TypeScript: name: type (with or without semicolon/initializer)
		if not name then
			local typed_name, typed_type = line:match("^%s*([%w_]+):%s*([%w_<>|%[%]]+)%s*[;=]")
			if not typed_name then
				typed_name, typed_type = line:match("^%s*([%w_]+):%s*([%w_<>|%[%]]+)%s*$")
			end
			if typed_name and typed_type and not line:match("%(") then
				name, field_type = typed_name, typed_type
			end
		end

		-- ES2022 private fields: #name = value
		if not name then
			local private_name = line:match("^%s*#([%w_]+)%s*[;=]")
			if private_name then
				name, field_type = "#" .. private_name, "any"
			end
		end

		-- JavaScript class field: name = value (no type annotation)
		if not name then
			local js_name = line:match("^%s*([%w_]+)%s*=%s*[^=]")
			if js_name and js_name ~= "constructor" and js_name ~= "static" then
				name, field_type = js_name, "any"
			end
		end

		if name and not seen[name] then
			seen[name] = true
			table.insert(fields, { type = field_type, name = name })
		end
	end

	return fields
end

function M.find_class_name()
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for _, line in ipairs(lines) do
		local class_name = line:match("^%s*class%s+([%w_]+)")
			or line:match("^%s*export%s+class%s+([%w_]+)")
			or line:match("^%s*export%s+default%s+class%s+([%w_]+)")
		if class_name then
			return class_name
		end
	end

	return vim.fn.expand("%:t:r")
end

function M.find_insert_position()
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	-- Find end of class (last })
	local brace_depth = 0
	local class_start = nil

	for i, line in ipairs(lines) do
		if line:match("^%s*class%s+") or line:match("^%s*export%s+.-class%s+") then
			class_start = i
		end
		if class_start then
			for j = 1, #line do
				local char = line:sub(j, j)
				if char == "{" then brace_depth = brace_depth + 1
				elseif char == "}" then brace_depth = brace_depth - 1
				end
			end
			if brace_depth == 0 and i > class_start then
				return i - 1
			end
		end
	end

	return #lines
end

-- ============================================================================
-- Test Navigation (Jest/Vitest patterns)
-- ============================================================================

function M.goto_test()
	local fn = vim.fn
	local filepath = fn.expand("%:p")
	local filename = fn.expand("%:t:r")
	local ext = fn.expand("%:e")

	-- Check if already in test file
	if filename:match("%.test$") or filename:match("%.spec$") or
		filepath:match("__tests__") or filepath:match("%.test%.") or filepath:match("%.spec%.") then
		-- Navigate to source file
		local source_name = filename:gsub("%.test$", ""):gsub("%.spec$", "")
		local source_path = filepath:gsub("__tests__/", ""):gsub("%.test%.", "."):gsub("%.spec%.", ".")
		source_path = source_path:gsub(filename, source_name)

		if fn.filereadable(source_path) == 1 then
			api.nvim_command("edit " .. source_path)
		else
			vim.notify("Source file not found: " .. source_name .. "." .. ext, vim.log.levels.WARN)
		end
	else
		-- Navigate to test file
		local test_patterns = {
			filepath:gsub("(.+)/([^/]+)%.(%w+)$", "%1/__tests__/%2.test.%3"),
			filepath:gsub("%.(%w+)$", ".test.%1"),
			filepath:gsub("%.(%w+)$", ".spec.%1"),
		}

		for _, test_path in ipairs(test_patterns) do
			if fn.filereadable(test_path) == 1 then
				api.nvim_command("edit " .. test_path)
				return
			end
		end

		-- Offer to create test file
		M.create_test_file()
	end
end

function M.create_test_file()
	local fn = vim.fn
	local filepath = fn.expand("%:p")
	local filename = fn.expand("%:t:r")
	local ext = fn.expand("%:e")
	local dir = fn.expand("%:p:h")

	-- Determine test file path
	local test_filename = filename .. ".test." .. ext
	local test_dir = dir .. "/__tests__"
	local test_path = test_dir .. "/" .. test_filename

	-- Alternative: same directory
	local alt_test_path = dir .. "/" .. test_filename

	vim.ui.select({ test_path, alt_test_path }, {
		prompt = "Create test file at:",
	}, function(choice)
		if not choice then return end

		-- Create directory if needed
		local test_file_dir = fn.fnamemodify(choice, ":h")
		fn.mkdir(test_file_dir, "p")

		-- Generate test template
		local test_content
		if ext == "ts" or ext == "tsx" then
			test_content = string.format([[
import { describe, it, expect } from 'vitest';
import { %s } from './%s';

describe('%s', () => {
  it('should work', () => {
    // Arrange

    // Act

    // Assert
    expect(true).toBe(true);
  });
});
]], filename, filename, filename)
		else
			test_content = string.format([[
const { %s } = require('./%s');

describe('%s', () => {
  it('should work', () => {
    // Arrange

    // Act

    // Assert
    expect(true).toBe(true);
  });
});
]], filename, filename, filename)
		end

		fn.writefile(vim.split(test_content, "\n"), choice)
		api.nvim_command("edit " .. choice)
		vim.notify("Test file created: " .. fn.fnamemodify(choice, ":t"), vim.log.levels.INFO)
	end)
end

return M
