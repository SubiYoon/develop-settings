-- lazyvim에서는 neotree 대신 snacks를 사용함
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true,
      ignored = true,
      -- exclude = {
      -- "**/.git/*",
      --},
    },
    explorer = {
      position = "right", -- 파일 탐색기를 오른쪽에 표시
    },
  },
}
