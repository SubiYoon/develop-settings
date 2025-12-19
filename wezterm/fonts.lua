-- ===========================
--    FONTS
-- ===========================

local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	config.font = wezterm.font_with_fallback({
		{ family = "JetBrains Mono", weight = "Regular" },
		"JetBrainsMono Nerd Font Mono",
		"FiraMono Nerd Font Mono",
		"MesloLGM Nerd Font",
		"MesloLGL Nerd Font",
	})
	config.font_size = 14.0
	config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" } -- 리그리처 활성화

	-- 텍스트 렌더링 최적화
	config.front_end = "OpenGL"
	config.freetype_load_target = "Normal"
	config.freetype_render_target = "Normal"
end

return module
