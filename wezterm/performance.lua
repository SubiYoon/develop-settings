-- ===========================
--  PERFORMANCE
-- ===========================

local module = {}

function module.apply_to_config(config)
  config.max_fps = 120
  config.animation_fps = 60
  config.scrollback_lines = 20000

  -- URL 감지 활성화
  config.hyperlink_rules = require('wezterm').default_hyperlink_rules()

  -- 벨 비활성화
  config.audible_bell = 'Disabled'
end

return module
