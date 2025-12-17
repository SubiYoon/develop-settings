-- ===========================
--  KEY BINDINGS
-- ===========================

local wezterm = require 'wezterm'
local module = {}

function module.apply_to_config(config)
  config.keys = {
    -- Alt+j, Alt+k 키 전송
    {
      key = 'j',
      mods = 'ALT',
      action = wezterm.action.SendString('\x1bj'),
    },
    {
      key = 'k',
      mods = 'ALT',
      action = wezterm.action.SendString('\x1bk'),
    },

    -- 윈도우 네비게이션 (Ctrl+Cmd+h/j/k/l)
    {
      key = 'h',
      mods = 'CTRL|CMD',
      action = wezterm.action.ActivatePaneDirection('Left'),
    },
    {
      key = 'j',
      mods = 'CTRL|CMD',
      action = wezterm.action.ActivatePaneDirection('Down'),
    },
    {
      key = 'k',
      mods = 'CTRL|CMD',
      action = wezterm.action.ActivatePaneDirection('Up'),
    },
    {
      key = 'l',
      mods = 'CTRL|CMD',
      action = wezterm.action.ActivatePaneDirection('Right'),
    },

    -- 새 윈도우 열기 (Cmd+Enter: 오른쪽 스플릿)
    {
      key = 'Enter',
      mods = 'CMD',
      action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- 새 윈도우 열기 (Cmd+Shift+Enter: 아래쪽 스플릿)
    {
      key = 'Enter',
      mods = 'CMD|SHIFT',
      action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },

    -- Shift+Enter: 줄바꿈 문자 전송
    {
      key = 'Enter',
      mods = 'SHIFT',
      action = wezterm.action.SendString('\n'),
    },

    -- 복사/붙여넣기 (macOS 네이티브는 기본 동작)
    {
      key = 'c',
      mods = 'CMD',
      action = wezterm.action.CopyTo('Clipboard'),
    },
    {
      key = 'v',
      mods = 'CMD',
      action = wezterm.action.PasteFrom('Clipboard'),
    },

    -- 탭 이동 (Cmd+1~9, Cmd+0)
    {
      key = '1',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(0),
    },
    {
      key = '2',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(1),
    },
    {
      key = '3',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(2),
    },
    {
      key = '4',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(3),
    },
    {
      key = '5',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(4),
    },
    {
      key = '6',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(5),
    },
    {
      key = '7',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(6),
    },
    {
      key = '8',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(7),
    },
    {
      key = '9',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(8),
    },
    {
      key = '0',
      mods = 'CMD',
      action = wezterm.action.ActivateTab(-1), -- 마지막 탭
    },
  }

  -- ===========================
  --  MOUSE BINDINGS
  -- ===========================
  config.mouse_bindings = {
    -- URL 클릭 시 브라우저에서 열기
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
  }
end

return module
