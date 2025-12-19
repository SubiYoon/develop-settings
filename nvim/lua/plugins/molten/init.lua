return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    init = function()
      -- this is an example, not a default. Please see the readme for more configuration options
      -- Result window setting
      vim.g.molten_auto_open_output = false -- 코드를 실행하면 자동으로 결과창 오픈
      vim.g.molten_output_win_max_height = 12 -- 결과창의 최대 높이를 제한
      vim.g.molten_enter_output_behavior = "open_and_enter" -- :MoltenEnterOutput 동작이후 자동으로 포커싱되게 설정

      -- Virtual text setting
      vim.g.molten_virt_lines_off_by_1 = false -- 줄 밀림 방지
      vim.g.molten_virt_text_output = true -- 코드 옆에 가상 텍스트로 결과를 간단히 표시
      vim.g.molten_virt_text_pos = "eol" -- 가상 텍스트가 표시될 위치 설정 ('eol'은 줄 끝에 표시)
    end,
    cond = function()
      return vim.fn.has("win32") == 0
    end,
  },
}
