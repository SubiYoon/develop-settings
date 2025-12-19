-- ===========================
--  KEY BINDINGS
-- ===========================

local wezterm = require 'wezterm'
local module = {}

-- OS 감지
local function is_macos()
  return wezterm.target_triple:find('darwin') ~= nil
end

local function is_linux()
  return wezterm.target_triple:find('linux') ~= nil
end

-- macOS는 CMD, 그 외(Linux, Windows)는 CTRL
local MOD = is_macos() and 'CMD' or 'CTRL'

-- 복사 키: Linux에서는 Ctrl+C가 SIGINT이므로 Ctrl+Shift+C 사용
local COPY_MOD = (is_linux()) and 'CTRL|SHIFT' or MOD

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

    -- 윈도우 네비게이션 (Ctrl+Mod+h/j/k/l)
    {
      key = 'h',
      mods = 'CTRL|' .. MOD,
      action = wezterm.action.ActivatePaneDirection('Left'),
    },
    {
      key = 'j',
      mods = 'CTRL|' .. MOD,
      action = wezterm.action.ActivatePaneDirection('Down'),
    },
    {
      key = 'k',
      mods = 'CTRL|' .. MOD,
      action = wezterm.action.ActivatePaneDirection('Up'),
    },
    {
      key = 'l',
      mods = 'CTRL|' .. MOD,
      action = wezterm.action.ActivatePaneDirection('Right'),
    },

    -- 새 윈도우 열기 (Mod+Enter: 오른쪽 스플릿)
    {
      key = 'Enter',
      mods = MOD,
      action = wezterm.action.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- 새 윈도우 열기 (Mod+Shift+Enter: 아래쪽 스플릿)
    {
      key = 'Enter',
      mods = MOD .. '|SHIFT',
      action = wezterm.action.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },

    -- Shift+Enter: 줄바꿈 문자 전송
    {
      key = 'Enter',
      mods = 'SHIFT',
      action = wezterm.action.SendString('\n'),
    },

    -- 복사/붙여넣기 (Linux: Ctrl+Shift+C/V, 그 외: Mod+C/V)
    {
      key = 'c',
      mods = COPY_MOD,
      action = wezterm.action.CopyTo('Clipboard'),
    },
    {
      key = 'v',
      mods = COPY_MOD,
      action = wezterm.action.PasteFrom('Clipboard'),
    },

    -- 새 탭 열기 (Mod+T)
    {
      key = 't',
      mods = MOD,
      action = wezterm.action.SpawnTab('CurrentPaneDomain'),
    },

    -- 탭/패널 닫기 (Mod+W)
    {
      key = 'w',
      mods = MOD,
      action = wezterm.action.CloseCurrentPane({ confirm = true }),
    },

    -- 탭 이동 (Mod+1~9, Mod+0)
    {
      key = '1',
      mods = MOD,
      action = wezterm.action.ActivateTab(0),
    },
    {
      key = '2',
      mods = MOD,
      action = wezterm.action.ActivateTab(1),
    },
    {
      key = '3',
      mods = MOD,
      action = wezterm.action.ActivateTab(2),
    },
    {
      key = '4',
      mods = MOD,
      action = wezterm.action.ActivateTab(3),
    },
    {
      key = '5',
      mods = MOD,
      action = wezterm.action.ActivateTab(4),
    },
    {
      key = '6',
      mods = MOD,
      action = wezterm.action.ActivateTab(5),
    },
    {
      key = '7',
      mods = MOD,
      action = wezterm.action.ActivateTab(6),
    },
    {
      key = '8',
      mods = MOD,
      action = wezterm.action.ActivateTab(7),
    },
    {
      key = '9',
      mods = MOD,
      action = wezterm.action.ActivateTab(8),
    },
    {
      key = '0',
      mods = MOD,
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
