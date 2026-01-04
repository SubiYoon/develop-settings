-- refactor/language/java.lua
-- Java-specific refactoring implementation

local api = vim.api
local core = require("refactor.core")

local M = core.create_language_module()

-- ============================================================================
-- Type Mappings
-- ============================================================================

-- Implementation to Interface mapping
local INTERFACE_MAPPING = {
	HashMap = "Map",
	LinkedHashMap = "Map",
	TreeMap = "Map",
	ConcurrentHashMap = "Map",
	Hashtable = "Map",
	ArrayList = "List",
	LinkedList = "List",
	Vector = "List",
	Stack = "List",
	CopyOnWriteArrayList = "List",
	HashSet = "Set",
	LinkedHashSet = "Set",
	TreeSet = "Set",
	CopyOnWriteArraySet = "Set",
	ArrayDeque = "Deque",
	LinkedBlockingDeque = "Deque",
	PriorityQueue = "Queue",
	LinkedBlockingQueue = "Queue",
	ArrayBlockingQueue = "Queue",
	StringBuilder = "StringBuilder",
	StringBuffer = "StringBuffer",
}

-- Type to import mapping
local TYPE_IMPORTS = {
	List = "java.util.List",
	ArrayList = "java.util.ArrayList",
	Map = "java.util.Map",
	HashMap = "java.util.HashMap",
	Set = "java.util.Set",
	HashSet = "java.util.HashSet",
	Optional = "java.util.Optional",
	Stream = "java.util.stream.Stream",
	Collectors = "java.util.stream.Collectors",
	LocalDate = "java.time.LocalDate",
	LocalDateTime = "java.time.LocalDateTime",
	BigDecimal = "java.math.BigDecimal",
}

-- ============================================================================
-- Detection
-- ============================================================================

function M.is_supported_file()
	return vim.bo.filetype == "java"
end

function M.get_lsp_client()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	for _, client in ipairs(clients) do
		if client.name == "jdtls" then
			return client
		end
	end
	return nil
end

-- ============================================================================
-- Type Utilities
-- ============================================================================

-- Extract generic type parameters
local function extract_generics(type_str)
	local base = type_str:match("^([%w_%.]+)")
	local generics = type_str:match("<(.+)>$")
	return base, generics
end

-- Convert implementation type to interface type
function M.convert_to_interface_type(type_str)
	if not type_str then
		return type_str
	end
	local base_type, generics = extract_generics(type_str)
	local interface = INTERFACE_MAPPING[base_type]
	if interface then
		if generics then
			return interface .. "<" .. generics .. ">"
		else
			return interface
		end
	end
	return type_str
end

-- Strip package prefix from type
local function strip_package_from_type(type_str)
	if not type_str then
		return nil
	end

	-- Check for enum constant pattern: EnumType.CONSTANT_NAME
	local base, constant = type_str:match("^([%w_]+)%.([A-Z][A-Z0-9_]*)$")
	if base and constant then
		return base
	end

	-- Handle generic types
	local main_type = type_str:match("^([^<]+)")
	local generics = type_str:match("(<.+>)$")

	if not main_type then
		return type_str
	end

	-- Strip package from main type
	local stripped_main = main_type:match("([%w_]+)$") or main_type

	-- Handle generic parameters
	if generics then
		local stripped_generics = generics:gsub("([%w_%.]+%.)([%w_]+)", "%2")
		return stripped_main .. stripped_generics
	end

	return stripped_main
end

-- Check if expression is constructor call
local function is_constructor_call(expr)
	return expr:match("^%s*new%s+") ~= nil
end

-- Get type from new expression
local function get_type_from_new_expression(expr)
	local class_with_generics = expr:match("^%s*new%s+([%w_]+%s*<[^>]+>)")
	if class_with_generics then
		return M.convert_to_interface_type(class_with_generics:gsub("%s+", ""))
	end
	local class = expr:match("^%s*new%s+([%w_]+)")
	if class then
		return M.convert_to_interface_type(class)
	end
	return nil
end

-- Get implementation class from new expression
local function get_impl_from_new_expression(expr)
	return expr:match("^%s*new%s+([%w_]+)")
end

-- ============================================================================
-- Type Inference
-- ============================================================================

-- Infer type from expression pattern (literals and constructors)
function M.infer_type_from_expression(expr)
	if not expr then
		return nil
	end

	-- String literal
	if expr:match('^".*"$') then
		return "String"
	end

	-- Character literal
	if expr:match("^'.'$") then
		return "char"
	end

	-- Boolean literals
	if expr == "true" or expr == "false" then
		return "boolean"
	end

	-- null
	if expr == "null" then
		return "Object"
	end

	-- Numeric literals
	if expr:match("^%-?%d+[lL]$") then
		return "long"
	end
	if expr:match("^%-?%d+%.%d*[fF]$") or expr:match("^%-?%d*%.%d+[fF]$") then
		return "float"
	end
	if expr:match("^%-?%d+%.%d*[dD]?$") or expr:match("^%-?%d*%.%d+[dD]?$") then
		return "double"
	end
	if expr:match("^%-?%d+$") then
		return "int"
	end

	-- Hex literals
	if expr:match("^0[xX]%x+[lL]$") then
		return "long"
	end
	if expr:match("^0[xX]%x+$") then
		return "int"
	end

	-- Constructor call
	if is_constructor_call(expr) then
		return get_type_from_new_expression(expr)
	end

	-- Array creation
	if expr:match("^new%s+(%w+)%s*%[") then
		local array_type = expr:match("^new%s+(%w+)%s*%[")
		return array_type .. "[]"
	end

	return nil
end

-- Check for enum constant pattern
local function get_enum_type_from_pattern(expr_text)
	local enum_type, constant = expr_text:match("^([A-Z][%w_]*)%.([A-Z][A-Z0-9_]*)$")
	if enum_type and constant then
		return enum_type
	end
	return nil
end

-- Parse JDTLS hover response for type
function M.parse_hover_for_type(hover_content)
	if not hover_content then
		return nil
	end

	-- Extract string content
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

	-- Extract first line
	local java_block = content_str:match("```java\n([^\n]+)")
		or content_str:match("```\n([^\n]+)")
		or content_str:match("^([^\n]+)")

	if not java_block or java_block == "" then
		return nil
	end

	-- Clean up annotations
	java_block = java_block:gsub("@%w+%b()%s*", "")
	java_block = java_block:gsub("@%w+%s*", "")

	-- Remove modifiers
	local modifiers = { "public", "private", "protected", "static", "final", "abstract", "synchronized", "volatile", "transient", "native", "strictfp" }
	for _, mod in ipairs(modifiers) do
		java_block = java_block:gsub("^%s*" .. mod .. "%s+", "")
		java_block = java_block:gsub("%s+" .. mod .. "%s+", " ")
	end

	java_block = java_block:gsub("^%s+", ""):gsub("%s+$", "")

	-- Pattern 0: Static method with type params
	local type_param_and_rest = java_block:match("^<[^>]+>%s+(.+)")
	if type_param_and_rest then
		local return_type = type_param_and_rest:match("^([%w_%.%[%]<>,?%s]+)%s+[%w_%.]+%s*%(")
		if return_type then
			return_type = return_type:gsub("%s+$", "")
			return strip_package_from_type(return_type)
		end
	end

	-- Pattern 1: Method signature
	local return_type = java_block:match("^([%w_%.%[%]<>,?%s]+)%s+[%w_]+%s*%(")
	if return_type then
		return_type = return_type:gsub("%s+$", "")
		return strip_package_from_type(return_type)
	end

	-- Pattern 2: Enum constant with constructor
	local enum_type, enum_name = java_block:match("^([%w_%.]+)%s+([A-Z][A-Z0-9_]*)%s*%(")
	if enum_type and enum_name then
		return strip_package_from_type(enum_type)
	end

	-- Pattern 3: Field/Variable
	local field_type, field_name = java_block:match("^([%w_%.%[%]<>,?]+)%s+([%w_]+)$")
	if field_type and field_name then
		return strip_package_from_type(field_type)
	end

	-- Pattern 4: Type with generics
	local generic_type = java_block:match("^([%w_%.]+%s*<[^>]+>)%s+[%w_]+")
	if generic_type then
		return strip_package_from_type(generic_type:gsub("%s+", ""))
	end

	-- Pattern 5: Single type
	local single = java_block:match("^([%w_%.%[%]<>,?]+)$")
	if single then
		return strip_package_from_type(single)
	end

	-- Fallback
	local first_type = java_block:match("^([%w_%.]+)")
	if first_type and (first_type:match("^[A-Z]") or first_type == "int" or first_type == "long" or
		first_type == "short" or first_type == "byte" or first_type == "float" or
		first_type == "double" or first_type == "char" or first_type == "boolean") then
		return strip_package_from_type(first_type)
	end

	return nil
end

-- Async type inference via LSP
function M.get_type_for_expression_async(bufnr, row, expr_start_col, expr_text, callback)
	-- Check enum constant pattern first
	local enum_type = get_enum_type_from_pattern(expr_text)
	if enum_type then
		callback(enum_type, nil)
		return
	end

	local client = M.get_lsp_client()
	if not client then
		callback(nil, "JDTLS not available")
		return
	end

	-- Calculate hover position
	local hover_offset = #expr_text

	if expr_text:match("%)$") then
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

	-- Handle multi-line expressions
	local hover_col
	if expr_start_col then
		hover_col = expr_start_col + hover_offset - 1
	else
		local last_method = expr_text:match("%.([%w_]+)%([^%(]*%)$") or expr_text:match("%.([%w_]+)$")
		if last_method then
			local current_line = api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
			local method_pos = current_line:find(last_method, 1, true)
			if method_pos then
				hover_col = method_pos + math.floor(#last_method / 2)
			else
				hover_col = 1
			end
		else
			hover_col = 1
		end
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
	local angle_depth = 0
	local in_string = false
	local string_char = nil

	-- Go backwards to find expression start
	for i = col, 1, -1 do
		local char = line:sub(i, i)
		local prev_char = i > 1 and line:sub(i - 1, i - 1) or ""

		if (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
				string_char = nil
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		if not in_string then
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
			elseif char == ">" then
				angle_depth = angle_depth + 1
			elseif char == "<" then
				angle_depth = angle_depth - 1
			end

			if paren_depth == 0 and bracket_depth == 0 and angle_depth <= 0 then
				if char:match("[%s,;={+%-*/%%&|^!~?:]") then
					expr_start = i + 1
					break
				end
			end
		end
		expr_start = i
	end

	-- Handle "new" keyword
	local before_start = line:sub(1, expr_start - 1)
	if before_start:match("new%s*$") then
		expr_start = before_start:find("new[%s]*$")
	end

	-- Find expression end
	local expr_end = col
	paren_depth = 0
	bracket_depth = 0
	angle_depth = 0
	in_string = false
	string_char = nil

	for i = expr_start, #line do
		local char = line:sub(i, i)
		local prev_char = i > 1 and line:sub(i - 1, i - 1) or ""

		if (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
				string_char = nil
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		if not in_string then
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
			elseif char == "<" then
				angle_depth = angle_depth + 1
			elseif char == ">" then
				if angle_depth > 0 then
					angle_depth = angle_depth - 1
				end
			end

			if paren_depth == 0 and bracket_depth == 0 and angle_depth == 0 then
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

	for i = 1, #full_expr do
		local char = full_expr:sub(i, i)
		local prev_char = i > 1 and full_expr:sub(i - 1, i - 1) or ""

		if (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		current = current .. char

		if not in_string then
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

-- Parse multi-line chain
function M.parse_multiline_chain(bufnr, cursor_row, cursor_col)
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local current_line = lines[cursor_row]

	local is_chain_continuation = current_line:match("^%s*%.")

	local chain_start_row = cursor_row
	local chain_start_col = 1

	if is_chain_continuation then
		local paren_depth = 0

		-- Calculate initial paren depth
		for i = cursor_row, #lines do
			local line = lines[i]
			for j = 1, #line do
				local char = line:sub(j, j)
				if char == "(" then paren_depth = paren_depth + 1
				elseif char == ")" then paren_depth = paren_depth - 1
				end
			end
			if line:find(";") then break end
		end

		-- Go backwards tracking paren depth
		for i = cursor_row - 1, 1, -1 do
			local line = lines[i]

			for j = #line, 1, -1 do
				local char = line:sub(j, j)
				if char == ")" then paren_depth = paren_depth + 1
				elseif char == "(" then paren_depth = paren_depth - 1
				end
			end

			local is_chain_start = false

			if paren_depth <= 0 then
				-- Find assignment
				local eq_pos = nil
				for pos = 1, #line do
					local char = line:sub(pos, pos)
					local prev_char = pos > 1 and line:sub(pos - 1, pos - 1) or ""
					local next_char = pos < #line and line:sub(pos + 1, pos + 1) or ""
					if char == "=" and prev_char ~= "=" and prev_char ~= "!" and prev_char ~= "<" and prev_char ~= ">" and next_char ~= "=" then
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
	full_expr = full_expr:gsub("%s*%.%s*", ".")

	-- Build expressions list
	local expressions = {}
	local current = ""
	local paren_depth = 0
	local in_string = false
	local string_char = nil

	for i = 1, #full_expr do
		local char = full_expr:sub(i, i)
		local prev_char = i > 1 and full_expr:sub(i - 1, i - 1) or ""

		if (char == '"' or char == "'") and prev_char ~= "\\" then
			if in_string and char == string_char then
				in_string = false
			elseif not in_string then
				in_string = true
				string_char = char
			end
		end

		current = current .. char

		if not in_string then
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

function M.generate_variable_declaration(indent, type_str, name, expr)
	return string.format("%s%s %s = %s;", indent, type_str, name, expr)
end

function M.generate_constant_declaration(indent, type_str, name, expr)
	return string.format("%sprivate static final %s %s = %s;", indent, type_str, name:upper(), expr)
end

function M.generate_field_declaration(indent, type_str, name, expr)
	return string.format("%sprivate %s %s = %s;", indent, type_str, name, expr)
end

function M.generate_parameter(type_str, name)
	return string.format("%s %s", type_str, name)
end

function M.generate_method(params)
	local indent = params.indent or "    "
	local visibility = params.visibility or "private"
	local return_type = params.return_type or "void"
	local name = params.name
	local method_params = params.params or ""
	local body = params.body or ""
	local is_static = params.is_static and "static " or ""

	local lines = {
		string.format("%s%s %s%s %s(%s) {", indent, visibility, is_static, return_type, name, method_params),
	}

	for _, line in ipairs(vim.split(body, "\n")) do
		table.insert(lines, indent .. "    " .. line)
	end

	table.insert(lines, indent .. "}")

	return table.concat(lines, "\n")
end

function M.generate_constructor(class_name, fields, indent)
	indent = indent or "    "
	local params = {}
	local assignments = {}

	for _, field in ipairs(fields) do
		table.insert(params, field.type .. " " .. field.name)
		table.insert(assignments, indent .. "    this." .. field.name .. " = " .. field.name .. ";")
	end

	local lines = {
		indent .. "public " .. class_name .. "(" .. table.concat(params, ", ") .. ") {",
	}
	for _, a in ipairs(assignments) do
		table.insert(lines, a)
	end
	table.insert(lines, indent .. "}")

	return table.concat(lines, "\n")
end

function M.generate_getter(field, indent)
	indent = indent or "    "
	local method_name = "get" .. core.capitalize_first(field.name)
	if field.type == "boolean" then
		method_name = "is" .. core.capitalize_first(field.name)
	end

	return string.format(
		"%spublic %s %s() {\n%s    return this.%s;\n%s}",
		indent, field.type, method_name,
		indent, field.name,
		indent
	)
end

function M.generate_setter(field, indent)
	indent = indent or "    "
	local method_name = "set" .. core.capitalize_first(field.name)

	return string.format(
		"%spublic void %s(%s %s) {\n%s    this.%s = %s;\n%s}",
		indent, method_name, field.type, field.name,
		indent, field.name, field.name,
		indent
	)
end

function M.generate_equals(class_name, fields, indent)
	indent = indent or "    "
	local conditions = {}

	for _, field in ipairs(fields) do
		if field.type == "int" or field.type == "long" or field.type == "short" or
			field.type == "byte" or field.type == "char" or field.type == "boolean" then
			table.insert(conditions, field.name .. " == that." .. field.name)
		elseif field.type == "float" then
			table.insert(conditions, "Float.compare(that." .. field.name .. ", " .. field.name .. ") == 0")
		elseif field.type == "double" then
			table.insert(conditions, "Double.compare(that." .. field.name .. ", " .. field.name .. ") == 0")
		else
			table.insert(conditions, "Objects.equals(" .. field.name .. ", that." .. field.name .. ")")
		end
	end

	local lines = {
		indent .. "@Override",
		indent .. "public boolean equals(Object o) {",
		indent .. "    if (this == o) return true;",
		indent .. "    if (o == null || getClass() != o.getClass()) return false;",
		indent .. "    " .. class_name .. " that = (" .. class_name .. ") o;",
		indent .. "    return " .. table.concat(conditions, " &&\n" .. indent .. "           ") .. ";",
		indent .. "}",
		"",
		indent .. "@Override",
		indent .. "public int hashCode() {",
		indent .. "    return Objects.hash(" .. table.concat(vim.tbl_map(function(f) return f.name end, fields), ", ") .. ");",
		indent .. "}",
	}

	return table.concat(lines, "\n")
end

function M.generate_tostring(class_name, fields, indent)
	indent = indent or "    "
	local field_strs = {}

	for _, field in ipairs(fields) do
		table.insert(field_strs, string.format('"%s=" + %s', field.name, field.name))
	end

	local lines = {
		indent .. "@Override",
		indent .. "public String toString() {",
		indent .. '    return "' .. class_name .. '{" +',
	}

	for i, fs in ipairs(field_strs) do
		local suffix = i < #field_strs and ' + ", " +' or ' +'
		table.insert(lines, indent .. "            " .. fs .. suffix)
	end

	table.insert(lines, indent .. '            "}";')
	table.insert(lines, indent .. "}")

	return table.concat(lines, "\n")
end

-- ============================================================================
-- Import Handling
-- ============================================================================

function M.add_import(import_path)
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local import_statement = "import " .. import_path .. ";"

	-- Check if already exists
	for _, line in ipairs(lines) do
		if line:match("^%s*" .. vim.pesc(import_statement)) then
			return
		end
	end

	-- Find insert position
	local insert_pos = 0
	local last_import = 0

	for i, line in ipairs(lines) do
		if line:match("^package%s+") then
			insert_pos = i
		elseif line:match("^import%s+") then
			last_import = i
		end
	end

	if last_import > 0 then
		insert_pos = last_import
	end

	api.nvim_buf_set_lines(bufnr, insert_pos, insert_pos, false, { import_statement })
end

function M.get_imports_for_type(type_str)
	local imports = {}
	local base = type_str:match("^([%w_]+)")
	if base and TYPE_IMPORTS[base] then
		table.insert(imports, TYPE_IMPORTS[base])
	end

	-- Check generics
	local generics = type_str:match("<(.+)>")
	if generics then
		for generic_type in generics:gmatch("([%w_]+)") do
			if TYPE_IMPORTS[generic_type] then
				table.insert(imports, TYPE_IMPORTS[generic_type])
			end
		end
	end

	return imports
end

-- ============================================================================
-- Class Utilities
-- ============================================================================

function M.extract_fields()
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local fields = {}

	for _, line in ipairs(lines) do
		local field_type, field_name = line:match("^%s*private%s+([%w_<>,%s%[%]]+)%s+([%w_]+)%s*[;=]")
		if field_type and field_name then
			field_type = field_type:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
			table.insert(fields, { type = field_type, name = field_name })
		end
	end

	return fields
end

function M.find_class_name()
	local bufnr = api.nvim_get_current_buf()
	local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for _, line in ipairs(lines) do
		local class_name = line:match("^%s*public%s+class%s+([%w_]+)")
			or line:match("^%s*class%s+([%w_]+)")
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
	for i = #lines, 1, -1 do
		if lines[i]:match("^}") then
			return i - 1
		end
	end

	return #lines
end

-- ============================================================================
-- Test Navigation
-- ============================================================================

-- Java 함수 정의를 감지하기 위한 헬퍼
local function extract_public_function_names(filepath)
	local function_names = {}
	for line in io.lines(filepath) do
		local function_name = line:match("^%s*public%s+[%w<>%[%]]+%s+(%w+)%s*%(")
		if function_name then
			table.insert(function_names, function_name)
		end
	end
	return function_names
end

-- 테스트 파일 생성 (함수 선택 UI 사용)
function M.create_test_file()
	local fn = vim.fn
	local filepath = fn.expand("%:p")
	local class_name = fn.expand("%:t:r")
	local filename = class_name .. "Test.java"

	-- 소스 파일의 패키지 경로를 변환
	local package_path = filepath:match("src/main/java/(.+)/[^/]+.java")
	if not package_path then
		vim.notify("Spring Boot 프로젝트의 소스 파일이어야 합니다.", vim.log.levels.WARN)
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
		vim.notify("public 함수가 없습니다.", vim.log.levels.WARN)
		return
	end

	-- 함수 선택 UI 표시
	core.select_functions_with_ui(function_names, "Select methods for test", function(selected_functions)
		-- 테스트 메서드 템플릿
		local test_method_template = [[
    @Test
    void %s() {
        //given


        //when


        //then

    }
    ]]

		-- 선택된 함수명으로 테스트 메서드 생성
		local test_methods = {}
		for _, func in ipairs(selected_functions) do
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
		vim.notify("Test file created: " .. filename, vim.log.levels.INFO)
	end)
end

-- 테스트 클래스로 이동 (양방향, 없으면 생성)
function M.goto_test()
	local fn = vim.fn
	local filepath = fn.expand("%:p")
	local class_name = fn.expand("%:t:r")

	if class_name:match("Test$") then
		-- 테스트 → 소스로 이동
		local source_class = class_name:gsub("Test$", "")
		local source_path = filepath:gsub("src/test/java", "src/main/java"):gsub(class_name .. ".java", source_class .. ".java")

		if fn.filereadable(source_path) == 1 then
			api.nvim_command("edit " .. source_path)
		else
			vim.notify("Source file not found: " .. source_class .. ".java", vim.log.levels.WARN)
		end
	else
		-- 소스 → 테스트로 이동 (없으면 생성)
		local test_path = filepath:gsub("src/main/java", "src/test/java"):gsub(class_name .. ".java", class_name .. "Test.java")

		if fn.filereadable(test_path) == 1 then
			api.nvim_command("edit " .. test_path)
		else
			M.create_test_file()
		end
	end
end

return M
