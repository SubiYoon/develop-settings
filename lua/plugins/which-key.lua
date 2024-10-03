-- local keymaps = require("config.keymaps")
local builtin = require("telescope/builtin")

return {
  "folke/which-key.nvim", -- 플러그인 설치
  config = function()
    local wk = require("which-key")
    wk.setup({
      -- 기본 설정
      plugins = {
        marks = true,       -- 마크에 대한 매핑 표시
        registers = true,   -- 레지스터에 대한 매핑 표시
        spelling = {
          enabled = true,   -- 맞춤법 제안
          suggestions = 20, -- 맞춤법 제안 갯수
        },
      },
      key_labels = {
        -- 사용자 정의 키 레이블 (예: <space>를 공백으로 표시)
        ["<space>"] = "SPC",
        ["<CR>"] = "RET",
        ["t"] = "TAB",
      },
      window = {
        border = "rounded",  -- 팝업 창 테두리 모양 (rounded, single, double 등)
        position = "bottom", -- 팝업 창 위치 (bottom, top)
      },
      layout = {
        align = "center",    -- 키맵 정렬
      },
      ignore_missing = true, -- 매핑되지 않은 키는 무시
    })

    -- mapping Keys settings
    wk.register({
      -- telescope
      f = {
        name = "File",
        f = { builtin.find_files, "Find File" },
        r = { builtin.oldfiles, "Recent File" },
        w = { builtin.live_grep, "Find Word" },
        b = { builtin.buffers, "Find Buffer" },
        h = { builtin.help_tags, "Help Tags" },
      },
      t = {},
    }, { prefix = "<leader>" })
  end,
}
