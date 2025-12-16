return {
  {
    "nvim-focus/focus.nvim",
    version = "*", -- 최신 안정 버전 사용
    config = function()
      require("focus").setup({
        -- 필요하면 여기에 옵션 추가
      })
    end,
  },
}
