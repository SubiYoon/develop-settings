-- ===========================
--  WINDOW / APPEARANCE
-- ===========================

local module = {}

function module.apply_to_config(config)
	-- 윈도우 크기 설정
	config.initial_cols = 150
	config.initial_rows = 40

	-- 배경 투명도
	config.window_background_opacity = 0.9

	-- 배경 이미지 설정
	config.background = {
		{
			source = {
				File = "/Users/ABCD/Pictures/배경화면/동물/cat01.png",
			},
			-- 이미지 크기 조정 방식
			width = "100%",
			height = "100%",
			-- opacity = 0.80,
			hsb = {
				brightness = 0.120,
			},
		},
	}

	-- 패딩 설정
	config.window_padding = {
		left = 8,
		right = 8,
		top = 0,
		bottom = 8,
	}

	-- 윈도우 장식 (탭을 타이틀 바에 통합)
	config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
	config.integrated_title_button_style = "MacOsNative"
	config.integrated_title_buttons = { "Hide", "Maximize", "Close" }

	-- 타이틀 바 / 탭 바 스타일 (Chrome 스타일)
	local wezterm = require("wezterm")
	config.window_frame = {
		font_size = 12.0,
		active_titlebar_bg = "#1E1E2E", -- Catppuccin base
		inactive_titlebar_bg = "#181825", -- Catppuccin mantle
		border_top_color = "#1E1E2E",
		border_bottom_color = "#1E1E2E",
	}
	config.show_tab_index_in_tab_bar = true
	config.tab_bar_at_bottom = false
	config.tab_max_width = 250

	-- 탭 바 색상 (Chrome 스타일)
	config.colors = {
		tab_bar = {
			background = "#1E1E2E",
			active_tab = {
				bg_color = "#313244",
				fg_color = "#CDD6F4",
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "#1E1E2E",
				fg_color = "#6C7086",
			},
			inactive_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
			},
			new_tab = {
				bg_color = "#1E1E2E",
				fg_color = "#6C7086",
			},
			new_tab_hover = {
				bg_color = "#45475A",
				fg_color = "#CDD6F4",
			},
		},
	}

	config.native_macos_fullscreen_mode = false

	-- 스크롤바 비활성화
	config.enable_scroll_bar = false

	-- 확인 프롬프트 비활성화
	config.window_close_confirmation = "NeverPrompt"

	config.initial_cols = 300
	config.initial_rows = 60
end

return module
