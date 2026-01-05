local wezterm = require("wezterm")
local module = {}

-- 배터리 정보 캐싱 (10분 = 600초)
local battery_cache = {
	last_check = 0,
	data = nil,
	interval = 600,
}

-- Catppuccin Mocha 색상 팔레트
local colors = {
	rosewater = "#F5E0DC",
	flamingo = "#F2CDCD",
	pink = "#F5C2E7",
	mauve = "#CBA6F7",
	red = "#F38BA8",
	maroon = "#EBA0AC",
	peach = "#FAB387",
	yellow = "#F9E2AF",
	green = "#A6E3A1",
	teal = "#94E2D5",
	sky = "#89DCEB",
	sapphire = "#74C7EC",
	blue = "#89B4FA",
	lavender = "#B4BEFE",
	text = "#CDD6F4",
	subtext1 = "#BAC2DE",
	subtext0 = "#A6ADC8",
	overlay2 = "#9399B2",
	overlay1 = "#7F849C",
	overlay0 = "#6C7086",
	surface2 = "#585B70",
	surface1 = "#45475A",
	surface0 = "#313244",
	base = "#1E1E2E",
	mantle = "#181825",
	crust = "#11111B",
}

function module.apply_to_config(config)
	config.enable_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.use_fancy_tab_bar = true
	config.tab_bar_at_bottom = false
	config.tab_max_width = 60

	-- 화려한 탭 제목 포맷
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local pane = tab.active_pane
		local process = pane.foreground_process_name
		local cwd = pane.current_working_dir

		-- 프로세스 아이콘과 색상 매핑
		local process_info = {
			["zsh"] = { icon = "󰆍", color = colors.green },
			["bash"] = { icon = "󰆍", color = colors.green },
			["nvim"] = { icon = "📝", color = colors.teal },
			["vim"] = { icon = "📝", color = colors.teal },
			["vi"] = { icon = "📝", color = colors.teal },
			["node"] = { icon = "📦", color = colors.green },
			["python"] = { icon = "🐍", color = colors.yellow },
			["docker"] = { icon = "🐳", color = colors.blue },
			["kubectl"] = { icon = "󱃾", color = colors.blue },
			["cargo"] = { icon = "", color = colors.peach },
			["npm"] = { icon = "📦", color = colors.red },
			["brew"] = { icon = "󰳤", color = colors.yellow },
			["ssh"] = { icon = "󰣀", color = colors.pink },
			["btop"] = { icon = "", color = colors.red },
			["htop"] = { icon = "", color = colors.red },
		}

		-- 프로세스 이름 추출
		local process_name = "zsh"
		if process then
			process_name = process:match("([^/]+)$") or process
		end

		-- 프로세스 정보 가져오기
		local info = process_info[process_name] or { icon = "⚡", color = colors.lavender }

		-- 디렉토리 이름 추출
		local dir_name = "~"
		if cwd then
			-- Url 객체를 안전하게 문자열로 변환
			local cwd_path = cwd.file_path or tostring(cwd)
			if cwd_path and type(cwd_path) == "string" then
				cwd_path = cwd_path:gsub("file://[^/]*", "")
				dir_name = cwd_path:match("([^/]+)/?$") or cwd_path
				-- 홈 디렉토리를 ~로 표시
				local home = os.getenv("HOME")
				if cwd_path == home then
					dir_name = "~"
				end
			end
		end

		-- 탭 번호
		local tab_index = tab.tab_index + 1

		-- 스타일 설정
		local background = colors.surface0
		local foreground = colors.text
		local separator_bg = colors.base
		local separator_fg = colors.surface0

		if tab.is_active then
			background = colors.mauve
			foreground = colors.crust
			separator_fg = colors.mauve
		elseif hover then
			background = colors.surface1
			separator_fg = colors.surface1
		end

		-- Powerline 스타일 separator
		local left_sep = ""
		local right_sep = ""

		return {
			-- 왼쪽 separator
			{ Background = { Color = separator_bg } },
			{ Foreground = { Color = separator_fg } },
			{ Text = left_sep },

			-- 탭 내용
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = string.format("%d %s %s ", tab_index, info.icon, dir_name) },

			-- 오른쪽 separator
			{ Background = { Color = separator_bg } },
			{ Foreground = { Color = separator_fg } },
			{ Text = right_sep },
		}
	end)

	-- 오른쪽 상태바 (배터리 → 날짜 → 시간)
	wezterm.on("update-right-status", function(window, pane)
		local cells = {}

		-- 배터리 정보 (캐싱 적용)
		local now = os.time()
		if now - battery_cache.last_check >= battery_cache.interval then
			battery_cache.data = wezterm.battery_info()
			battery_cache.last_check = now
		end
		local battery_info = battery_cache.data
		if battery_info and #battery_info > 0 then
			local battery = battery_info[1]
			local battery_pct = battery.state_of_charge * 100
			local battery_icon = "󰁹"
			local battery_color = colors.green

			if battery_pct < 20 then
				battery_icon = "󰁺"
				battery_color = colors.red
			elseif battery_pct < 40 then
				battery_icon = "󰁼"
				battery_color = colors.yellow
			elseif battery_pct < 60 then
				battery_icon = "󰁾"
			elseif battery_pct < 80 then
				battery_icon = "󰂀"
			else
				battery_icon = "󰁹"
			end

			if battery.state == "Charging" then
				battery_icon = "󰂄"
				battery_color = colors.teal
			end

			table.insert(cells, {
				bg = battery_color,
				fg = colors.crust,
				icon = battery_icon,
				text = string.format("%4s", string.format("%.0f%%", battery_pct)),
			})
		end

		-- 7. 날짜 (고정 너비: 5자)
		local date = wezterm.strftime("%m/%d")
		table.insert(cells, {
			bg = colors.pink,
			fg = colors.crust,
			icon = "󰃭",
			text = string.format("%5s", date),
		})

		-- 8. 시간 (고정 너비: 5자)
		local time = wezterm.strftime("%H:%M")
		table.insert(cells, {
			bg = colors.mauve,
			fg = colors.crust,
			icon = "󰥔",
			text = string.format("%5s", time),
		})

		-- 상태바 렌더링
		local elements = {}
		local prev_bg = colors.base

		for i, cell in ipairs(cells) do
			-- 왼쪽 separator
			table.insert(elements, { Background = { Color = prev_bg } })
			table.insert(elements, { Foreground = { Color = cell.bg } })
			table.insert(elements, { Text = "" })

			-- 셀 내용
			table.insert(elements, { Background = { Color = cell.bg } })
			table.insert(elements, { Foreground = { Color = cell.fg } })
			table.insert(elements, { Text = " " .. cell.icon .. " " .. cell.text .. " " })

			prev_bg = cell.bg
		end

		-- 마지막 오른쪽 separator
		table.insert(elements, { Background = { Color = colors.base } })
		table.insert(elements, { Foreground = { Color = prev_bg } })
		table.insert(elements, { Text = "" })

		window:set_right_status(wezterm.format(elements))
	end)
end

return module
