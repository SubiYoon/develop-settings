-- ===========================
--    FONTS
-- ===========================

local wezterm = require 'wezterm'
local module = {}

function module.apply_to_config(config)
  config.font = wezterm.font('JetBrains Mono', { weight = 'Regular' })
  config.font_size = 14.0
  config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' } -- 리그리처 활성화

  -- macOS 텍스트 렌더링 최적화
  config.front_end = 'WebGpu'
  config.freetype_load_target = 'Normal'
  config.freetype_render_target = 'Normal'
end

return module
