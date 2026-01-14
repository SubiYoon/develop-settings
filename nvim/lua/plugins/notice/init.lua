return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- enabled = false,
    opts = {
      -- 알림(notify) 기능을 완전히 끕니다.
      notify = {
        enabled = true,
      },
      -- 하단 메시지(LSP 알림 등)를 끕니다.
      messages = {
        enabled = true,
      },
      -- LSP 서명 도움말이나 호버 창은 유지하고 싶을 수 있으므로
      -- 필요 없다면 아래도 false로 설정하세요.
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify", -- 알림을 안 쓸 것이므로 삭제하거나 주석 처리합니다.
    },
  },
}
