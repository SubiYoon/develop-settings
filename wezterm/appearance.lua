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
		top = 8,
		bottom = 8,
	}

	-- 윈도우 장식
	config.window_decorations = "RESIZE"
	config.native_macos_fullscreen_mode = false

	-- 스크롤바 비활성화
	config.enable_scroll_bar = false

	-- 확인 프롬프트 비활성화
	config.window_close_confirmation = "NeverPrompt"

	config.initial_cols = 300
	config.initial_rows = 60
end

return module
