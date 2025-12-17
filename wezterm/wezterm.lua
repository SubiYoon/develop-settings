-- ===========================
-- ===========================
--        WezTerm 설정
-- ===========================
-- ===========================

local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- ===========================
--    SHELL
-- ===========================
-- 로그인 셸로 실행하여 .zshrc가 제대로 로드되도록 함
config.default_prog = { '/bin/zsh', '-l' }

-- ===========================
--    모듈 로드
-- ===========================
-- 각 카테고리별 설정을 별도 파일에서 로드
require('colors').apply_to_config(config)
require('fonts').apply_to_config(config)
require('appearance').apply_to_config(config)
require('keybindings').apply_to_config(config)
require('tabs').apply_to_config(config)
require('performance').apply_to_config(config)

return config
